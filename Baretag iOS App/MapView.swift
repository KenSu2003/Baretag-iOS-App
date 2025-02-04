//
//  TagMapView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//



// "Map" Guide: https://developer.apple.com/documentation/mapkit/map
// "Annotation" Guide: https://developer.apple.com/documentation/mapkit/annotation

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
                Map(coordinateRegion: $centerCoordinateRegion, showsUserLocation: false, annotationItems: [userAnnotation, tagAnnotation]) { item in
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
                            
                            if isMapLocked, let userLocation = userLocationManager.userLocation {
                                centerCoordinateRegion.center = userLocation.coordinate
                                centerCoordinateRegion.span = zoomedInSpan
                            } else {
                                centerCoordinateRegion.center = centerCoordinate  // Go back to the tag
                                centerCoordinateRegion.span = zoomedOutSpan
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
            
            // Display tag information
            if let tag = tagDataWatcher.tagLocation {
                Text("Current Tag: \(tag.name)")
                    .font(.subheadline)
                    .padding()
            } else {
                Text("Loading tag data...")
                    .font(.headline)
            }
        }
        .onAppear {
            tagDataWatcher.startUpdating()
            
            // Initialize the centerCoordinate and zoom to the tag's location
            if let tag = tagDataWatcher.tagLocation {
                centerCoordinate = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                centerCoordinateRegion.center = centerCoordinate
                centerCoordinateRegion.span = zoomedInSpan  // Zoom in on the tag
            }
        }
        .onChange(of: userLocationManager.userLocation) { _, newValue in
            if let userLocation = newValue {
                print("📍 User location updated: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                if isMapLocked {
                    centerCoordinateRegion.center = userLocation.coordinate
                }
            }
        }
        .onChange(of: tagDataWatcher.tagLocation) { _, newValue in
            if let tag = newValue {
                print("🔄 Tag location updated: \(tag.latitude), \(tag.longitude)")
                
                // Re-center and zoom in on the updated tag location if the map is not locked
                if !isMapLocked {
                    centerCoordinate = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                    centerCoordinateRegion.center = centerCoordinate
                    centerCoordinateRegion.span = zoomedInSpan  // Zoom in on the tag
                }
            }
        }
    }
    
    // Map region binding to center coordinates dynamically
    @State private var centerCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),  // Placeholder, set dynamically
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Define zoom levels
    private let zoomedInSpan = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)  // Zoomed in on the tag
    private let zoomedOutSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)  // Default wide view
    
    // User and tag annotations
    private var userAnnotation: MapAnnotationItem {
        if let userLocation = userLocationManager.userLocation {
            return MapAnnotationItem(type: .user, coordinate: userLocation.coordinate)
        } else {
            return MapAnnotationItem(type: .user, coordinate: centerCoordinateRegion.center)
        }
    }
    
    private var tagAnnotation: MapAnnotationItem {
        if let tag = tagDataWatcher.tagLocation {
            return MapAnnotationItem(type: .tag, coordinate: CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude))
        } else {
            return MapAnnotationItem(type: .tag, coordinate: centerCoordinateRegion.center)
        }
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
