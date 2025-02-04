//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//
import SwiftUI
import CoreLocation

struct LocationView: View {
    
    // Set uselocal file here
    @StateObject private var anchorWatcher = AnchorDataWatcher(useLocalFile: false) // Set useLocalFile here
    @StateObject private var tagWatcher = TagDataWatcher(useLocalFile: false)       // Set useLocalFile here
    @StateObject private var simulatedLocationManager = SimulatedLocationManager()  // Simulated location

    var body: some View {
        GeometryReader { geometry in
            let maxX = (anchorWatcher.anchors.map { $0.position.x }.max() ?? 100)
            let maxY = (anchorWatcher.anchors.map { $0.position.y }.max() ?? 100)

            let dynamicMaxX = tagWatcher.tagLocation != nil ? max(maxX, tagWatcher.tagLocation!.x) : maxX
            let dynamicMaxY = tagWatcher.tagLocation != nil ? max(maxY, tagWatcher.tagLocation!.y) : maxY

            ZStack {
                // Dynamically position anchors
                ForEach(anchorWatcher.anchors, id: \.id) { anchor in
                    VStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
//                        Text(anchor.name)
//                            .foregroundColor(.white)
//                            .font(.caption)
                    }
                    .position(
                        CGPoint(
                            x: (anchor.position.x / dynamicMaxX) * geometry.size.width,
                            y: (1 - (anchor.position.y / dynamicMaxY)) * geometry.size.height
                        )
                    )
                }

                // Position the tag dynamically
                if let tag = tagWatcher.tagLocation {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(
                            CGPoint(
                                x: (tag.x / dynamicMaxX) * geometry.size.width,
                                y: (1 - (tag.y / dynamicMaxY)) * geometry.size.height
                            )
                        )
                }

                // Position the simulated user location dynamically
                if let userLocation = simulatedLocationManager.userLocation {
                    let userPosition = calculateUserPosition(userLocation: userLocation, dynamicMaxX: dynamicMaxX, dynamicMaxY: dynamicMaxY, geometry: geometry)

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 15, height: 15)
                        .position(userPosition)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            anchorWatcher.startUpdating()
            tagWatcher.startUpdating()
        }
    }

    // ✅ New method to handle position calculation and debugging
    private func calculateUserPosition(userLocation: CLLocation, dynamicMaxX: CGFloat, dynamicMaxY: CGFloat, geometry: GeometryProxy) -> CGPoint {
        let userX = convertLongitudeToPlane(longitude: userLocation.coordinate.longitude)
        let userY = convertLatitudeToPlane(latitude: userLocation.coordinate.latitude)

        // ✅ Print the debug message outside the view-building context
        print("🔵 User coordinates before scaling: (x: \(userX), y: \(userY))")

        // Return the scaled position for the blue circle
        return CGPoint(
            x: (userX / dynamicMaxX) * geometry.size.width,
            y: (1 - (userY / dynamicMaxY)) * geometry.size.height
        )
    }

    private func convertLongitudeToPlane(longitude: Double) -> CGFloat {
        let minLongitude = -72.53  // Adjust based on your region
        let maxLongitude = -72.52
        return CGFloat((longitude - minLongitude) / (maxLongitude - minLongitude) * 100)
    }

    private func convertLatitudeToPlane(latitude: Double) -> CGFloat {
        let minLatitude = 42.39  // Adjust based on your region
        let maxLatitude = 42.40
        return CGFloat((latitude - minLatitude) / (maxLatitude - minLatitude) * 100)
    }
}
