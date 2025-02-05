//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import SwiftUI
import CoreLocation

struct LocationView: View {
    
    @StateObject private var anchorWatcher = AnchorDataWatcher(useLocalFile: false)
    @StateObject private var tagWatcher = TagDataWatcher(useLocalFile: false)
    @StateObject private var userDataWatcher = UserDataWatcher(useLocalFile: false)

    var body: some View {
        GeometryReader { geometry in
            // Precompute max bounds for scaling
            let maxAnchorX = anchorWatcher.anchors.map { $0.position.x }.max() ?? 100
            let maxAnchorY = anchorWatcher.anchors.map { $0.position.y }.max() ?? 100
            let maxTagX = tagWatcher.tagLocations.map { $0.x }.max() ?? 0
            let maxTagY = tagWatcher.tagLocations.map { $0.y }.max() ?? 0

            let dynamicMaxX = max(maxAnchorX, maxTagX)
            let dynamicMaxY = max(maxAnchorY, maxTagY)

            ZStack {
                // Position all anchors dynamically
                ForEach(anchorWatcher.anchors, id: \.id) { anchor in
                    let anchorPosition = CGPoint(
                        x: (anchor.position.x / dynamicMaxX) * geometry.size.width,
                        y: (1 - (anchor.position.y / dynamicMaxY)) * geometry.size.height
                    )
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .position(anchorPosition)
                }

                // Position all tags dynamically
                ForEach(tagWatcher.tagLocations, id: \.id) { tag in
                    let tagPosition = CGPoint(
                        x: (tag.x / dynamicMaxX) * geometry.size.width,
                        y: (1 - (tag.y / dynamicMaxY)) * geometry.size.height
                    )
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(tagPosition)
                }

                // Position user location dynamically
                if let userLocation = userDataWatcher.userLocation {
                    let userPosition = calculateUserPosition(
                        userLocation: userLocation,
                        dynamicMaxX: dynamicMaxX,
                        dynamicMaxY: dynamicMaxY,
                        geometry: geometry
                    )
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
            userDataWatcher.startUpdating()
        }
    }

    private func calculateUserPosition(userLocation: CLLocation, dynamicMaxX: CGFloat, dynamicMaxY: CGFloat, geometry: GeometryProxy) -> CGPoint {
        let userX = convertLongitudeToPlane(longitude: userLocation.coordinate.longitude)
        let userY = convertLatitudeToPlane(latitude: userLocation.coordinate.latitude)

        print("🔵 User coordinates before scaling: (x: \(userX), y: \(userY))")

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
