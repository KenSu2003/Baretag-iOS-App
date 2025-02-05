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
    @StateObject private var userLocationManager = UserLocationManager()  // Real-time GPS location
    @State private var centerCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),  // Initial location
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isMapLocked = false  // Start unlocked by default
    @State private var recenterTriggered = false  // Tracks if map movement is caused by recentering
    @State private var recenterTarget: CLLocationCoordinate2D?  // Store the target center when re-centering programmatically
    @State private var previousCenterCoordinateWrapper = CLLocationCoordinate2DWrapper(coordinate: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291))
    private let recenterTolerance: Double = 5.0  // 5 meters tolerance to avoid false unlocks

    // ✅ Timer to trigger updates every 5 seconds
    private var updateTimer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            ZStack {
                // Main map view with dynamic annotations
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
                        }
                    }
                }
                .edgesIgnoringSafeArea(.top)
                .onReceive(updateTimer) { _ in
                    print("🔄 Timer-based update triggered.")
                    tagDataWatcher.startUpdating()  // Automatically fetch new tag data
                }
                .onChange(of: CLLocationCoordinate2DWrapper(coordinate: centerCoordinateRegion.center)) { newCenterWrapper in
                    detectMapMovement(newCenterWrapper.coordinate)
                }

                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()

                        // Lock/Unlock Button with consistent state updates
                        Button(action: {
                            toggleMapLock()
                        }) {
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
            
            // Tag slide bar at the bottom
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tagDataWatcher.tagLocations, id: \.id) { tag in
                        VStack {
                            Image(systemName: "tag.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    zoomToTag(tag: tag)  // Zoom to the selected tag’s location
                                }
                            Text(tag.name)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))  // Light background for tag section
        }
        .onAppear {
            print("🔓 Initializing map in unlocked state.")
            tagDataWatcher.startUpdating()  // Start fetching tag updates on appear
        }
    }

    // Toggle between map lock and unlock
    private func toggleMapLock() {
        isMapLocked.toggle()

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
        if distance > 5.0 {
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
            centerCoordinateRegion.center = userLocation.coordinate
            centerCoordinateRegion.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
        }
    }

    private func zoomToTag(tag: BareTag) {
        print("🔓 Unlocking map and zooming to tag: \(tag.name)")
        isMapLocked = false  // Unlock the map when zooming to a tag
        centerCoordinateRegion.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
        centerCoordinateRegion.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
    }

    // Dynamic annotations for the map
    private var mapAnnotations: [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []

        // Add user location if available
        if let userLocation = userLocationManager.userLocation {
            annotations.append(MapAnnotationItem(type: .user, coordinate: userLocation.coordinate))
        }

        // Add all tag locations
        for tag in tagDataWatcher.tagLocations {
            annotations.append(MapAnnotationItem(type: .tag, coordinate: CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)))
        }

        return annotations
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
    case user, tag
}

// Annotation model for user and tag locations
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let type: AnnotationType
    let coordinate: CLLocationCoordinate2D
}
