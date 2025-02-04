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
            
            // BareTag icons section at the bottom
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tags, id: \.id) { tag in
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
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGray6))  // Light background for tag section
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
    
    // Zoom to the selected tag’s location
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
    private let zoomedInSpan = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)  // Zoomed in on the tag
    private let zoomedOutSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)  // Default wide view
    
    // Placeholder for multiple BareTags (replace this with actual tag data from the watcher)
    private var tags: [BareTag] {
        return [
            BareTag(id: UUID(), name: "Sample Tag 1", latitude: 37.7749, longitude: -122.4194),
            BareTag(id: UUID(), name: "Sample Tag 2", latitude: 37.7750, longitude: -122.4195),
            BareTag(id: UUID(), name: "Sample Tag 3", latitude: 37.7751, longitude: -122.4196)
        ]
    }
    
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

// Updated BareTag struct with coordinates
struct BareTag: Identifiable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
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
