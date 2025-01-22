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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var tagLocation: TagLocation?

    var body: some View {
        VStack {
            if let tag = tagLocation {
                // Map using MapContentBuilder with an Annotation
                Map{
                    Annotation(
                        "tag",
                        coordinate: CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                    ) {
                        // Circle as annotation marker
                        Circle()
                            .fill(Color.blue.opacity(0.7))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(tag.name.prefix(1)) // Display the first letter of the tag's name
                                    .foregroundColor(.white)
                                    .bold()
                            )
                    }
                }
                .onAppear {
                    // Center map on the tag's location
                    region.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                }
            } else {
                Text("Loading tag data...")
                    .font(.headline)
            }
        }
        .onAppear {
            // Load tag data
            tagLocation = loadTagData()
        }
    }
}
