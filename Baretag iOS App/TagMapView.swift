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

    // Timer to refresh data every 5 seconds
    private let updateInterval: TimeInterval = 5.0
    private var timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if let tag = tagLocation {
                Map{
                    // Add the annotation for the tag location
                    Annotation(
                        tag.id,
                        coordinate: CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                    ) {
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
                    // Center the map on the tag's location
                    region.center = CLLocationCoordinate2D(latitude: tag.latitude, longitude: tag.longitude)
                }
            } else {
                Text("Loading tag data...")
                    .font(.headline)
            }
        }
        .onAppear {
            loadData() // Load initial data
        }
        .onReceive(timer) { _ in
            loadData() // Refresh data at each interval
        }
    }

    private func loadData() {
        guard let tag = loadTagData() else {
            print("❌ Failed to load tag data")
            return
        }
        tagLocation = tag
        print("✅ Updated tag location: \(tag)")
    }
}
