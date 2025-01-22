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
            ZStack(alignment: .topTrailing) {
                // MapView with Lock/Unlock functionality
                MapViewRepresentable(centerCoordinate: $centerCoordinate, isLocked: $isMapLocked)

                // Lock/Unlock Button
                Button(action: {
                    isMapLocked.toggle()
                }) {
                    Text(isMapLocked ? "Unlock" : "Lock")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
            }

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
        .onChange(of: tagDataWatcher.tagLocation) {
            if let tag = tagDataWatcher.tagLocation {
                centerCoordinate = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                print("🔄 Map re-centered to: \(centerCoordinate.latitude), \(centerCoordinate.longitude)")
            }
        }
    }
}
