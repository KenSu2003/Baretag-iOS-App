//
//  TagMapView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//  Last Edited by Ken Su on 2/4/25.


// "Map" Guide: https://developer.apple.com/documentation/mapkit/map
// "Annotation" Guide: https://developer.apple.com/documentation/mapkit/annotation

import SwiftUI
import MapKit
import Combine

struct MapView: View {

    @StateObject private var tagDataWatcher = TagDataWatcher(useLocalFile: false)
    @StateObject private var anchorDataWatcher = AnchorDataWatcher(useLocalFile: false)
    @StateObject private var userLocationManager = UserLocationManager()  // Real-time GPS location

    @State private var centerCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),  // Initial location
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var isMapLocked = false  // Start unlocked by default
    @State private var selectedAnchor: MapAnnotationItem?
    @State private var showAnchorOptions = false
    @State private var anchorName = ""
    @State private var anchorLatitude = 0.0
    @State private var anchorLongitude = 0.0

    private let recenterTolerance: Double = 5.0  // 5 meters tolerance to avoid false unlocks
    private var updateTimer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ZStack {
                Map(coordinateRegion: $centerCoordinateRegion, annotationItems: mapAnnotations) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        if item.type == .user {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                        } else if item.type == .tag {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        } else if item.type == .anchor {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.green)
                                .font(.title)
                                .onLongPressGesture {
                                    selectedAnchor = item
                                    anchorName = item.name ?? ""
                                    anchorLatitude = item.coordinate.latitude
                                    anchorLongitude = item.coordinate.longitude
                                    showAnchorOptions = true
                                }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .onReceive(updateTimer) { _ in
                    print("🔄 Timer-based update triggered.")
                    tagDataWatcher.startUpdating()
                    anchorDataWatcher.startUpdating()
                }

                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: { toggleMapLock() }) {
                            Image(systemName: isMapLocked ? "location.north.fill" : "scope")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tagDataWatcher.tagLocations, id: \.id) { tag in
                        VStack {
                            Image(systemName: "tag.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    zoomToTag(tag: tag)
                                }
                            Text(tag.name)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
        }
        .onAppear {
            print("🔓 Initializing map in unlocked state.")
            tagDataWatcher.startUpdating()
            if anchorDataWatcher.anchors.isEmpty {
                anchorDataWatcher.startUpdating()
            }
            if anchorDataWatcher.anchors.isEmpty {
                tagDataWatcher.startUpdating()
            }
        }

        .alert("Anchor Options", isPresented: $showAnchorOptions) {
            TextField("Anchor Name", text: $anchorName)
            TextField("Latitude", value: $anchorLatitude, format: .number)
            TextField("Longitude", value: $anchorLongitude, format: .number)
            
            Button("Save Changes") { updateAnchor() }
            Button("Delete", role: .destructive) { deleteAnchor() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func toggleMapLock() {
        isMapLocked.toggle()
        if isMapLocked {
            print("🔒 Map locked: Re-centering on user location.")
            if let userLocation = userLocationManager.userLocation?.coordinate {
                centerCoordinateRegion.center = userLocation
                centerCoordinateRegion.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
            }
        } else {
            print("🔓 Map unlocked manually.")
        }
    }

    private func zoomToTag(tag: BareTag) {
        print("🔓 Unlocking map and zooming to tag: \(tag.name)")
        isMapLocked = false
        centerCoordinateRegion.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
        centerCoordinateRegion.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
    }

    private var mapAnnotations: [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []

        // ✅ Fix: Provide a default name for the user location
        if let userLocation = userLocationManager.userLocation {
            annotations.append(MapAnnotationItem(type: .user, coordinate: userLocation.coordinate, name: "User"))
        }

        for tag in tagDataWatcher.tagLocations {
            annotations.append(MapAnnotationItem(type: .tag, coordinate: tag.coordinate, name: tag.name))
        }

        for anchor in anchorDataWatcher.anchors {
            annotations.append(MapAnnotationItem(type: .anchor, coordinate: CLLocationCoordinate2D(latitude: anchor.latitude, longitude: anchor.longitude), name: anchor.name))
        }

        return annotations
    }


    func updateAnchor() {
        guard let anchor = selectedAnchor else { return }

        let requestBody: [String: Any] = [
            "anchor_name": anchor.name ?? "",
            "new_anchor_name": anchorName,
            "latitude": anchorLatitude,
            "longitude": anchorLongitude
        ]

        guard let url = URL(string: "\(BASE_URL)/edit_anchor") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // ✅ Ensure session cookies are sent
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error updating anchor: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                print("📡 Server Response: \(jsonResponse)")
                
                DispatchQueue.main.async {
                    self.anchorDataWatcher.fetchAnchors()  // ✅ Fetch updated anchors after update
                }
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }
        task.resume()
    }


    private func deleteAnchor() {
        guard let anchor = selectedAnchor else {
            print("❌ No anchor selected for deletion")
            return
        }

        // Only send the anchor_name, since user_id is already in the session on the server
        let requestBody: [String: Any] = [
            "anchor_name": anchor.name  // Send only the anchor's name
        ]

        print("📡 Sending Delete Request: \(requestBody)")

        guard let url = URL(string: "\(BASE_URL)/delete_anchor") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ JSON Encoding Error: \(error)")
            return
        }

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error deleting anchor: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                return
            }

            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                print("📡 Server Response: \(jsonResponse)")

                DispatchQueue.main.async {
                    self.selectedAnchor = nil  // ✅ Prevent crash by removing reference
                    self.anchorDataWatcher.fetchAnchors()  // ✅ Refresh UI after deletion
                }
            } catch {
                print("❌ JSON Decoding Error: \(error)")
            }
        }.resume()
    }

}

// **Wrapper for CLLocationCoordinate2D to make it conform to Equatable**
struct CLLocationCoordinate2DWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CLLocationCoordinate2DWrapper, rhs: CLLocationCoordinate2DWrapper) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// Updated BareTag struct to include map coordinates
struct BareTag: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let x: Double
    let y: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// Enum to distinguish between user and tag annotations
enum AnnotationType {
    case user, tag, anchor
}

// Annotation model for user and tag locations
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let type: AnnotationType
    let coordinate: CLLocationCoordinate2D
    let name: String?
}
