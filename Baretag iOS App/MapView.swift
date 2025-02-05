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
    @State private var centerCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),  // Initial location
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isMapLocked = true

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
                                    // Zoom to the selected tag’s location
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
            .background(Color(UIColor.systemGray6))  // Light background for tag section
        }
        .onAppear {
            tagDataWatcher.startUpdating()
        }
    }

    private func updateCenterCoordinateBasedOnLock() {
        if isMapLocked, let userLocation = userLocationManager.userLocation {
            centerCoordinateRegion.center = userLocation.coordinate
            centerCoordinateRegion.span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)
        }
    }

    private func zoomToTag(tag: BareTag) {
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
