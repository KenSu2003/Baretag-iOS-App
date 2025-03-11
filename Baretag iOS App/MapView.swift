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

    // Data Watcher
    @StateObject private var tagDataWatcher = TagDataWatcher(useLocalFile: false)
    @StateObject private var anchorDataWatcher = AnchorDataWatcher(useLocalFile: false)
    @StateObject private var userLocationManager = UserLocationManager()  // Real-time GPS location

   
    
    // Centering Button Variables
//    @State private var centerCoordinateWrapper.region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),  // Initial location
//        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//    )
    
    @State private var centerCoordinateWrapper = EquatableCoordinateRegion(region: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))

    @State private var isMapLocked = false  // Start unlocked by default
    @State private var recenterTriggered = false  // Tracks if map movement is caused by recentering
    @State private var recenterTarget: CLLocationCoordinate2D?  // Store the target center when re-centering programmatically
    @State private var previousCenterCoordinateWrapper = CLLocationCoordinate2DWrapper(coordinate: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291))
    private let recenterTolerance: Double = 10.0
    
    // Anchor Variables
    @State private var selectedAnchor: MapAnnotationItem?
    @State private var showAnchorOptions = false
    @State private var anchorName = ""
    @State private var anchorLatitude = 0.0
    @State private var anchorLongitude = 0.0
    
    @State private var mapType: MKMapType = .satellite  // ✅ Default to Satellite view
    @StateObject private var mapData = MapViewModel()  // ✅ Track zoom changes
    @State private var isGridVisible = false  // ✅ Toggle grid ON/OFF

    
    // Timer Variables
    private var updateTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
    
        VStack {
            ZStack {
                Map(coordinateRegion: $centerCoordinateWrapper.region, annotationItems: mapAnnotations){ item in
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
                .onChange(of: CLLocationCoordinate2DWrapper(coordinate: centerCoordinateWrapper.region.center)) { newCenterWrapper in detectMapMovement(newCenterWrapper.coordinate)
                }
                .onChange(of: centerCoordinateWrapper) { newRegion in
                    mapData.region = newRegion.region
                }

//                GridOverlay(isGridVisible: $isGridVisible, mapRegion: mapData.region)
                if isGridVisible {
                    GridOverlay(isGridVisible: $isGridVisible, mapRegion: mapData.region)
                }


                
                VStack {
                    Spacer() // Push everything down

                    // Center Button (bottom-right)
                    HStack {
                        Spacer()
                        VStack {
                            // Grid Toggle Button - ABOVE Center Button
                            Button(action: { isGridVisible.toggle() }) {
                                Image(systemName: isGridVisible ? "checkmark.square.fill" : "square")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                            .padding(.bottom, 10)  // Moves it above the center button

                            // Center Button (BLUE)
                            Button(action: { withAnimation { toggleMapLock() } }) {
                                Image(systemName: isMapLocked ? "location.north.fill" : "scope")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .id(isMapLocked)
                        }
                        .padding(.trailing, 15) // Keep aligned to the right
                        .padding(.bottom, 15)
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
            previousCenterCoordinateWrapper = CLLocationCoordinate2DWrapper(coordinate: centerCoordinateWrapper.region.center)  // Initialize last coordinate

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
        
        print("🔄 Map lock state changed: \(isMapLocked ? "🔒 Locked" : "🔓 Unlocked")")

            DispatchQueue.main.async {
                self.isMapLocked = self.isMapLocked // ✅ Force SwiftUI refresh
            }
        
        if isMapLocked {
//            print("🔒 Map locked: Re-centering on user location.")
//            if let userLocation = userLocationManager.userLocation?.coordinate {
//                centerCoordinateWrapper.region.center = userLocation
//                centerCoordinateWrapper.region.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
//            }
            print("🔒 Map locked: Re-centering on user location.")
            recenterTriggered = true  // Set flag to indicate programmatic recentering
            recenterTarget = userLocationManager.userLocation?.coordinate  // Store the target location
            updateCenterCoordinateBasedOnLock()
        } else {
            print("🔓 Map unlocked manually.")
        }
    }
    
    // Detect when the map has been manually moved by comparing new and previous coordinates
    private func detectMapMovement(_ newCenter: CLLocationCoordinate2D) {
        // If recentering was triggered and we are still within the tolerance, ignore the movement
        if let target = recenterTarget, calculateDistance(from: target, to: newCenter) < recenterTolerance {
            print("📍 Ignoring map movement within tolerance during recentering.")
            return
        }

        // Reset recenter target after we leave the tolerance
        recenterTarget = nil

        let distance = calculateDistance(from: previousCenterCoordinateWrapper.coordinate, to: newCenter)

        print("📍 Detected map movement. Distance moved: \(distance) meters")

        // If the user has moved the map more than 5 meters, unlock the map
        if distance > recenterTolerance {
            print("🔓 Map unlocked due to manual movement.")
            isMapLocked = false  // Automatically unlock the map
        }

        previousCenterCoordinateWrapper = CLLocationCoordinate2DWrapper(coordinate: newCenter)  // Update the previous coordinate
    }

    // Calculate the distance between two coordinates
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    private func updateCenterCoordinateBasedOnLock() {
        if let userLocation = userLocationManager.userLocation {
            centerCoordinateWrapper.region.center = userLocation.coordinate
            centerCoordinateWrapper.region.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
        }
    }


    private func zoomToTag(tag: BareTag) {
        print("🔓 Unlocking map and zooming to tag: \(tag.name)")
        isMapLocked = false
        centerCoordinateWrapper.region.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
        centerCoordinateWrapper.region.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
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
struct BareTag: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

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

struct EquatableCoordinateRegion: Equatable {
    var region: MKCoordinateRegion

    static func == (lhs: EquatableCoordinateRegion, rhs: EquatableCoordinateRegion) -> Bool {
        return lhs.region.center.latitude == rhs.region.center.latitude &&
               lhs.region.center.longitude == rhs.region.center.longitude &&
               lhs.region.span.latitudeDelta == rhs.region.span.latitudeDelta &&
               lhs.region.span.longitudeDelta == rhs.region.span.longitudeDelta
    }
}
