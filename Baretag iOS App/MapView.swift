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

var tagColorMap: [String: UIColor] = [:]

func getColorForTag(id: String) -> UIColor {
    if let color = tagColorMap[id] {
        return color
    } else {
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemOrange, .systemGreen, .systemPurple, .systemTeal, .systemYellow, .systemPink]
        let newColor = colors.randomElement() ?? .systemGray
        tagColorMap[id] = newColor
        return newColor
    }
}

struct MapView: View {

    @StateObject private var tagDataWatcher = TagDataWatcher(useLocalFile: false)
    @StateObject private var anchorDataWatcher = AnchorDataWatcher(useLocalFile: false)
    @StateObject private var userLocationManager = UserLocationManager()

    @State private var centerCoordinateWrapper = EquatableCoordinateRegion(region: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))

    @State private var isMapLocked = false
    @State private var recenterTriggered = false
    @State private var recenterTarget: CLLocationCoordinate2D?
    @State private var previousCenterCoordinateWrapper = CLLocationCoordinate2DWrapper(coordinate: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291))
    private let recenterTolerance: Double = 10.0

    @State private var selectedTag: BareTag?
    @State private var showTagInfo = false

    @State private var selectedAnchor: MapAnnotationItem?
    @State private var showAnchorOptions = false
    @State private var anchorName = ""
    @State private var anchorLatitude = 0.0
    @State private var anchorLongitude = 0.0

    @State private var isGridVisible = false
    @StateObject private var mapData = MapViewModel()

    @State private var isDrawingBoundary = false
    @State private var dragStartPoint: CGPoint?
    @State private var dragEndPoint: CGPoint?
    @State private var boundaryCoordinates: [CLLocationCoordinate2D] = []
    @State private var mapViewRef: MKMapView? = nil
    @State private var outOfBoundsTag: BareTag?
    @State private var showOutOfBoundsAlert = false
    @State private var seenOutOfBoundsTags: Set<String> = []


    


    private var updateTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ZStack {
                MapViewRepresentable(
                    centerRegion: $centerCoordinateWrapper.region,
                    isLocked: $isMapLocked,
                    polygonCoords: $boundaryCoordinates,
                    annotations: mapAnnotations,
                    onTagTapped: { tag in
                        selectedTag = tag
                        showTagInfo = true
                    },
                    onAnchorLongPressed: { anchor in
                        selectedAnchor = anchor
                        anchorName = anchor.name ?? ""
                        anchorLatitude = anchor.coordinate.latitude
                        anchorLongitude = anchor.coordinate.longitude
                        showAnchorOptions = true
                    },
                    mapViewRef: $mapViewRef
                )

                if isDrawingBoundary {
                    GeometryReader { _ in
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged {
                                        dragStartPoint = $0.startLocation
                                        dragEndPoint = $0.location
                                    }
                                    .onEnded { _ in
                                        if let start = dragStartPoint, let end = dragEndPoint {
                                            submitBoundaryFromDrag(start: start, end: end)
                                        }
                                        dragStartPoint = nil
                                        dragEndPoint = nil
                                        isDrawingBoundary = false
                                    }

                            )
                    }
                }

                

                if let start = dragStartPoint, let end = dragEndPoint {
                    GeometryReader { _ in
                        let rect = CGRect(
                            x: min(start.x, end.x),
                            y: min(start.y, end.y),
                            width: abs(start.x - end.x),
                            height: abs(start.y - end.y)
                        )
                        Path { $0.addRect(rect) }
                            .stroke(Color.blue, lineWidth: 2)
                            .background(Color.blue.opacity(0.2))
                    }
                    .allowsHitTesting(false)
                }

                if isGridVisible {
                    GridOverlay(isGridVisible: $isGridVisible, mapRegion: mapData.region)
                }

                controlsOverlay
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tagDataWatcher.tagLocations, id: \.id) { tag in
                        VStack {
                            Image(systemName: "tag.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(getColorForTag(id: tag.id)))
                                .onTapGesture { zoomToTag(tag: tag) }
                            Text(tag.name).font(.caption)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))
            .frame(maxWidth: .infinity)
            
        }
        .onReceive(updateTimer) { _ in
            tagDataWatcher.startUpdating()
            anchorDataWatcher.startUpdating()

            for tag in tagDataWatcher.tagLocations {
                if tag.status == false {
                    if !seenOutOfBoundsTags.contains(tag.id) {
                        outOfBoundsTag = tag
                        showOutOfBoundsAlert = true
                        seenOutOfBoundsTags.insert(tag.id)
                    }
                } else {
                    // Clear the tag from seen list if it has returned in-bounds
                    seenOutOfBoundsTags.remove(tag.id)
                }
            }
        }

        .onChange(of: CLLocationCoordinate2DWrapper(coordinate: centerCoordinateWrapper.region.center)) {
            detectMapMovement($0.coordinate)
        }
        .onChange(of: centerCoordinateWrapper) { newWrapper in
            mapData.region = newWrapper.region
        }

        .onAppear {
            tagDataWatcher.startUpdating()
            if anchorDataWatcher.anchors.isEmpty { anchorDataWatcher.startUpdating() }
            previousCenterCoordinateWrapper = CLLocationCoordinate2DWrapper(coordinate: centerCoordinateWrapper.region.center)
            fetchSavedBoundary()
        }
        .alert("Anchor Options", isPresented: $showAnchorOptions) {
            TextField("Anchor Name", text: $anchorName)
            TextField("Latitude", value: $anchorLatitude, format: .number)
            TextField("Longitude", value: $anchorLongitude, format: .number)
            Button("Save Changes") { updateAnchor() }
            Button("Delete", role: .destructive) { deleteAnchor() }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Tag Location Info", isPresented: $showTagInfo, presenting: selectedTag) { _ in
            Button("OK", role: .cancel) {}
        } message: { tag in
            Text("Name: \(tag.name)\nLat: \(tag.latitude)\nLon: \(tag.longitude)\nAlt: \(tag.altitude ?? 0.0)m")
        }
        .alert("⚠️ Tag Out of Bounds", isPresented: $showOutOfBoundsAlert, presenting: outOfBoundsTag) { tag in
            Button("OK", role: .cancel) {
                // Optional: Do something on dismiss
            }
        } message: { tag in
            Text("Tag '\(tag.name)' is outside the designated area.")
        }

    }

    private var controlsOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Button(action: { isGridVisible.toggle() }) {
                        Image(systemName: isGridVisible ? "checkmark.square.fill" : "square")
                            .font(.title).foregroundColor(.blue).padding()
                    }
                    .background(Color.white.opacity(0.7)).clipShape(Circle()).padding(.bottom, 10)

                    Button(action: { withAnimation { toggleMapLock() } }) {
                        Image(systemName: isMapLocked ? "location.north.fill" : "scope")
                            .font(.title2).padding().background(Color.blue)
                            .foregroundColor(.white).cornerRadius(8)
                    }

                    Button(action: {
                        isDrawingBoundary.toggle()
                        dragStartPoint = nil
                        dragEndPoint = nil
                    }) {
                        Image(systemName: isDrawingBoundary ? "xmark.circle.fill" : "pencil.tip.crop.circle")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(isDrawingBoundary ? Color.red : Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .accessibilityLabel(isDrawingBoundary ? "Cancel Drawing" : "Draw Boundary")
                    }
                }
                .padding(.trailing, 15)
                .padding(.bottom, 15)
            }
        }
    }

    private var mapAnnotations: [MapAnnotationItem] {
        let color = UIColor.systemRed // fallback
        var annotations: [MapAnnotationItem] = []

        if let userLocation = userLocationManager.userLocation {
            annotations.append(MapAnnotationItem(
                id: "user",
                type: .user,
                coordinate: userLocation.coordinate,
                name: "User",
                bareTag: nil,
                color: color
            ))
        }

        annotations += tagDataWatcher.tagLocations.map { tag in
            let color = getColorForTag(id: tag.id)

            return MapAnnotationItem(
                id: tag.id,
                type: .tag,
                coordinate: tag.coordinate,
                name: tag.name,
                bareTag: tag,
                color: color
            )
        }



        annotations += anchorDataWatcher.anchors.map { anchor in
            MapAnnotationItem(
                id: anchor.id,
                type: .anchor,
                coordinate: CLLocationCoordinate2D(latitude: anchor.latitude, longitude: anchor.longitude),
                name: anchor.name,
                bareTag: nil,  // Anchors don’t use this
                color: UIColor.green
            )
        }

        return annotations
    }


    private func annotationView(for item: MapAnnotationItem) -> some View {
        switch item.type {
        case .user:
            return AnyView(Circle().fill(Color.blue).frame(width: 10, height: 10))
        case .tag:
            return AnyView(Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
                .font(.title)
                .onTapGesture {
                    selectedTag = tagDataWatcher.tagLocations.first(where: {
                        $0.coordinate.latitude == item.coordinate.latitude &&
                        $0.coordinate.longitude == item.coordinate.longitude
                    })
                    showTagInfo = true
                })
        case .anchor:
            return AnyView(Image(systemName: "flag.fill")
                .foregroundColor(.green)
                .font(.title)
                .onLongPressGesture {
                    selectedAnchor = item
                    anchorName = item.name ?? ""
                    anchorLatitude = item.coordinate.latitude
                    anchorLongitude = item.coordinate.longitude
                    showAnchorOptions = true
                })
        }
    }

    private func toggleMapLock() {
        isMapLocked.toggle()
        
        print("🔄 Map lock state changed: \(isMapLocked ? "🔒 Locked" : "🔓 Unlocked")")

            DispatchQueue.main.async {
                self.isMapLocked = self.isMapLocked // ✅ Force SwiftUI refresh
            }
        
        if isMapLocked {
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
        isMapLocked = true // ⛔ Temporarily lock to suppress reactivity

        centerCoordinateWrapper.region.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
        centerCoordinateWrapper.region.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isMapLocked = false // 🔓 Unlock after a moment to allow user movement again
        }
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
    
    
    func submitBoundaryFromDrag(start: CGPoint, end: CGPoint) {
        let screenPoints = [
            CGPoint(x: min(start.x, end.x), y: min(start.y, end.y)), // top-left
            CGPoint(x: max(start.x, end.x), y: min(start.y, end.y)), // top-right
            CGPoint(x: max(start.x, end.x), y: max(start.y, end.y)), // bottom-right
            CGPoint(x: min(start.x, end.x), y: max(start.y, end.y))  // bottom-left
        ]
        
        guard let realMapView = mapViewRef else { return }

        let boundaryCoords = screenPoints.map { point in
            realMapView.convert(point, toCoordinateFrom: realMapView)
        }

        
        let points = boundaryCoords.map { ["lat": $0.latitude, "lon": $0.longitude] }

        let body: [String: Any] = ["points": points]
        print(body)
        guard let url = URL(string: "\(BASE_URL)/save_boundary") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error saving boundary: \(error)")
                return
            }
            print("📦 Boundary submitted.")
            DispatchQueue.main.async {
                fetchSavedBoundary() // ✅ Pull the updated boundary to re-render on screen
            }
        }.resume()
    }
    
    func fetchSavedBoundary() {
        guard let url = URL(string: "\(BASE_URL)/get_boundaries") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching boundary: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let points = json["points"] as? [[String: Double]] {
                    let coords: [CLLocationCoordinate2D] = points.compactMap { point in
                        guard let lat = point["lat"], let lon = point["lon"] else { return nil }
                        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }


                    DispatchQueue.main.async {
                        self.boundaryCoordinates = coords
                    }
                }
            } catch {
                print("❌ Failed to parse boundary response: \(error)")
            }
        }.resume()
    }
    
    
    func convertCoordinateToPoint(_ coordinate: CLLocationCoordinate2D) -> CGPoint {
        let region = centerCoordinateWrapper.region
        let mapWidth: CGFloat = UIScreen.main.bounds.width
        let mapHeight: CGFloat = UIScreen.main.bounds.height

        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta

        let latOffset = region.center.latitude - coordinate.latitude
        let lonOffset = coordinate.longitude - region.center.longitude

        let x = (mapWidth / 2) + (lonOffset / lonDelta) * mapWidth
        let y = (mapHeight / 2) + (latOffset / latDelta) * mapHeight

        return CGPoint(x: x, y: y)
    }




}

// **Wrapper for CLLocationCoordinate2D to make it conform to Equatable**
struct CLLocationCoordinate2DWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CLLocationCoordinate2DWrapper, rhs: CLLocationCoordinate2DWrapper) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

// BareTag struct
struct BareTag: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let status: Bool?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // 👇 Do NOT include this in the Codable conformance
    var assignedColor: UIColor? {
        getColorForTag(id: id) // pulled dynamically from map
    }

    // If you're using SwiftUI Color in the scroll view:
    var swiftUIColor: Color {
        Color(assignedColor ?? .gray)
    }
}




// Enum to distinguish between user and tag annotations
enum AnnotationType {
    case user, tag, anchor
}

// Annotation model for user and tag locations
struct MapAnnotationItem: Identifiable {
    let id: String
    let type: AnnotationType
    let coordinate: CLLocationCoordinate2D
    let name: String?
    let bareTag: BareTag?  // Add this line only if you use it
    let color: UIColor? // ← NEW: store color here
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

