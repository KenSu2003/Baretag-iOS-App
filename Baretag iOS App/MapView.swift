//
//  TagMapView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//  Last Edited by Ken Su on 2/4/25.



// "Map" Guide: https://developer.apple.com/documentation/mapkit/map
// "Annotation" Guide: https://developer.apple.com/documentation/mapkit/annotation
//
//  TagMapView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @StateObject private var tagDataWatcher = TagDataWatcher(useLocalFile: false)
    @StateObject private var userLocationManager = UserLocationManager()  // Real-time GPS location
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)  // Initial placeholder
    @State private var isMapLocked = true

    var body: some View {
        VStack {
            ZStack {
                // Main map view
                Map(coordinateRegion: $centerCoordinateRegion, showsUserLocation: false, annotationItems: mapAnnotations) { item in
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

                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // Lock/Unlock Button
                        Button(action: {
                            isMapLocked.toggle()
                            if isMapLocked {
                                updateCenterCoordinateBasedOnLock()  // Only update center when locking
                            }
                        }) {
                            Image(systemName: isMapLocked ? "scope" : "location.north.fill")
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
            
            // BareTag icons section at the bottom
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let tag = tagDataWatcher.tagLocation {
                        VStack {
                            Image(systemName: "tag.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    // Zoom in on the selected tag’s location
                                    zoomToTag(tag: tag)
                                }
                            Text(tag.name)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                    } else {
                        Text("Loading tags...")
                            .font(.headline)
                            .padding()
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))  // Light background for tag section
        }
        .onAppear {
            tagDataWatcher.startUpdating()
            updateCenterCoordinateBasedOnLock()  // Set initial map center
        }
        .onChange(of: userLocationManager.userLocation) { _, _ in
            if isMapLocked {
                updateCenterCoordinateBasedOnLock()  // Keep the map centered on user location when locked
            }
        }
    }
    
    // Update the center coordinate and zoom level only when locking the map
    private func updateCenterCoordinateBasedOnLock() {
        if isMapLocked, let userLocation = userLocationManager.userLocation {
            print("🔍 Centering map on user location")
            centerCoordinateRegion.center = userLocation.coordinate
            centerCoordinateRegion.span = zoomedInSpan  // Zoom in on the user
        }
    }

    // Corrected zoom function to properly set the map region based on tag location
    private func zoomToTag(tag: BareTag) {
        print("🔍 Zooming to tag: \(tag.name) at \(tag.latitude), \(tag.longitude)")
        centerCoordinateRegion.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
        centerCoordinateRegion.span = zoomedInSpan
    }
    
    // Map region binding to center coordinates dynamically
    @State private var centerCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),  // Placeholder, set dynamically
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Define zoom levels
    private let zoomedInSpan = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)  // Zoomed in on the user or tag
    private let zoomedOutSpan = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)  // Default view for tags
    
    // Annotations for the user and tag locations
    private var mapAnnotations: [MapAnnotationItem] {
        var annotations: [MapAnnotationItem] = []
        
        // Add user location if available
        if let userLocation = userLocationManager.userLocation {
            annotations.append(MapAnnotationItem(type: .user, coordinate: userLocation.coordinate))
        }

        // Add tag location if available
        if let tag = tagDataWatcher.tagLocation {
            annotations.append(MapAnnotationItem(type: .tag, coordinate: CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)))
        }

        return annotations
    }
}

// Updated BareTag struct with coordinates (used in TagDataWatcher)
struct BareTag: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let x: Double
    let y: Double
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
