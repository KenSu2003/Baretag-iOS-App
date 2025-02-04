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

struct TagMapView: View {
    @StateObject private var tagDataWatcher = TagDataWatcher()
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var isMapLocked = true

    var body: some View {
        VStack {
            ZStack {
                // MapView occupies most of the screen
                MapViewRepresentable(centerCoordinate: $centerCoordinate, isLocked: $isMapLocked)
                    .edgesIgnoringSafeArea(.top)  // Ensure it fills the top area
                
                VStack {
                    Spacer()  // Pushes the button to the bottom
                    
                    HStack {
                        Spacer()  // Pushes the button to the right
                        
                        // Lock/Unlock Button
                        Button(action: {
                            isMapLocked.toggle()
                        }) {
                            Image(systemName: isMapLocked ? "scope" : "location.north.fill")
                                .font(.title2)  // Adjust the icon size
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)  // Allow the map to expand fully
            
            // Tag data section at the bottom
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
        .onChange(of: tagDataWatcher.tagLocation) { oldValue, newValue in
            if let tag = newValue {
                centerCoordinate = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                print("🔄 Map re-centered to: \(centerCoordinate.latitude), \(centerCoordinate.longitude)")
            }
        }
    }
}

