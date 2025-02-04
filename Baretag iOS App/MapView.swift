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
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)  // Default center
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
                                centerCoordinate = userLocation.coordinate
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
        }
        .onChange(of: userLocationManager.userLocation) { _, newValue in
            if let userLocation = newValue {
                print("📍 User location updated: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")
                if isMapLocked {
                    centerCoordinate = userLocation.coordinate
                }
            }
        }
        .onChange(of: tagDataWatcher.tagLocation) { _, newValue in
            if let tag = newValue {
                print("🔄 Tag location updated: \(tag.latitude), \(tag.longitude)")
            }
        }
    }
    
    // Map region binding to center coordinates dynamically
    @State private var centerCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
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
