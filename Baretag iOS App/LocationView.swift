//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//
import SwiftUI
import CoreLocation

struct LocationView: View {
    @StateObject private var anchorWatcher = AnchorDataWatcher(useLocalFile: true)
    @StateObject private var tagWatcher = TagDataWatcher(useLocalFile: true)
    @StateObject private var simulatedLocationManager = SimulatedLocationManager()  // Use simulated location

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
                        Text(anchor.name)
                            .foregroundColor(.white)
                            .font(.caption)
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
                    let userX = convertLongitudeToPlane(longitude: userLocation.coordinate.longitude)
                    let userY = convertLatitudeToPlane(latitude: userLocation.coordinate.latitude)

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 15, height: 15)
                        .position(
                            CGPoint(
                                x: (userX / dynamicMaxX) * geometry.size.width,
                                y: (1 - (userY / dynamicMaxY)) * geometry.size.height
                            )
                        )
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            anchorWatcher.startUpdating()
            tagWatcher.startUpdating()
        }
    }

    private func convertLongitudeToPlane(longitude: Double) -> CGFloat {
        return CGFloat((longitude + 180) / 360 * 100)  // Normalize to (0, 100) range
    }

    private func convertLatitudeToPlane(latitude: Double) -> CGFloat {
        return CGFloat((latitude + 90) / 180 * 100)  // Normalize to (0, 100) range
    }
}
