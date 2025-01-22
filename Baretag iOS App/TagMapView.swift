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

    var body: some View {
        VStack {
            if let tag = tagDataWatcher.tagLocation {
                MapViewRepresentable(centerCoordinate: $centerCoordinate)
                    .onAppear {
                        // Set the initial center
                        centerCoordinate = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                    }
                    .onChange(of: tagDataWatcher.tagLocation) {
                        if let tag = tagDataWatcher.tagLocation {
                            centerCoordinate = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                            print("🔄 Map re-centered to: \(centerCoordinate.latitude), \(centerCoordinate.longitude)")
                        }
                    }
            } else {
                Text("Loading tag data...")
                    .font(.headline)
            }
        }
        .onAppear {
            tagDataWatcher.startUpdating() // Start periodic updates
        }
    }
}
