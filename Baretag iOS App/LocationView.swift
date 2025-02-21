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
            let maxAnchorX = anchorWatcher.anchors.map { $0.position.x }.max() ?? 10
            let maxAnchorY = anchorWatcher.anchors.map { $0.position.y }.max() ?? 10
            let maxTagX = tagWatcher.tagLocations.map { $0.x }.max() ?? 10
            let maxTagY = tagWatcher.tagLocations.map { $0.y }.max() ?? 10

            let dynamicMaxX = max(maxAnchorX, maxTagX)
            let dynamicMaxY = max(maxAnchorY, maxTagY)

            ZStack {
                // Draw Anchors (White Squares)
                ForEach(anchorWatcher.anchors, id: \.id) { anchor in
                    let position = scaleGridToScreen(
                        x: anchor.position.x,
                        y: anchor.position.y,
                        maxX: dynamicMaxX,
                        maxY: dynamicMaxY,
                        geometry: geometry
                    )
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .position(position)
                }

                // Draw Tags (Red Circles)
                ForEach(tagWatcher.tagLocations, id: \.id) { tag in
                    let position = scaleGridToScreen(
                        x: tag.x,
                        y: tag.y,
                        maxX: dynamicMaxX,
                        maxY: dynamicMaxY,
                        geometry: geometry
                    )
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(position)
                }

                // Convert User GPS to Grid and Draw User Position
                if let userLocation = userDataWatcher.userLocation {
//                    print("📍 User GPS: \(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude)")

                    if let userGridPosition = convertUserGPSToGrid(userLocation: userLocation, anchors: anchorWatcher.anchors) {
                        let position = scaleGridToScreen(
                            x: userGridPosition.x,
                            y: userGridPosition.y,
                            maxX: dynamicMaxX,
                            maxY: dynamicMaxY,
                            geometry: geometry
                        )

//                        print("🖥️ User Screen Position: \(position)")

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 15, height: 15)
                            .position(position)
                    } else {
//                        print("⚠️ User grid conversion failed!")
                        Circle()
                            .fill(Color.blue.opacity(0.5))
                            .frame(width: 15, height: 15)
                            .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                    }
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
}

private func scaleGridToScreen(x: Double, y: Double, maxX: Double, maxY: Double, geometry: GeometryProxy) -> CGPoint {
    let screenX = (x / maxX) * geometry.size.width
    let screenY = (1 - (y / maxY)) * geometry.size.height
    return CGPoint(x: screenX, y: screenY)
}

private func convertUserGPSToGrid(userLocation: CLLocation, anchors: [Anchor]) -> (x: Double, y: Double)? {
    guard let referenceAnchor = anchors.first else {
        print("⚠️ No reference anchor found!")
        return nil
    }

    let minLatitude = anchors.map { $0.latitude }.min() ?? referenceAnchor.latitude
    let minLongitude = anchors.map { $0.longitude }.min() ?? referenceAnchor.longitude
    let maxLatitude = anchors.map { $0.latitude }.max() ?? minLatitude
    let maxLongitude = anchors.map { $0.longitude }.max() ?? minLongitude

    // Convert GPS to meters using Haversine formula
    var gridWidth = haversineDistance(lat1: minLatitude, lon1: minLongitude, lat2: minLatitude, lon2: maxLongitude)
    var gridHeight = haversineDistance(lat1: minLatitude, lon1: minLongitude, lat2: maxLatitude, lon2: minLongitude)

    // ✅ Prevent division by zero
    if gridWidth == 0 {
        gridWidth = 1  // Set to small nonzero value
        print("⚠️ Adjusted grid width to avoid zero.")
    }
    if gridHeight == 0 {
        gridHeight = 1  // Set to small nonzero value
        print("⚠️ Adjusted grid height to avoid zero.")
    }

    // Convert user GPS position to meters relative to reference anchor
    let userX = haversineDistance(lat1: minLatitude, lon1: minLongitude, lat2: minLatitude, lon2: userLocation.coordinate.longitude)
    let userY = haversineDistance(lat1: minLatitude, lon1: minLongitude, lat2: userLocation.coordinate.latitude, lon2: minLongitude)

    // Normalize to 50x100 grid
    let scaledX = (userX / gridWidth) * 50
    let scaledY = (userY / gridHeight) * 100

    if scaledX.isNaN || scaledY.isNaN || scaledX.isInfinite || scaledY.isInfinite {
        print("❌ Invalid user grid position (NaN or Infinity).")
        return nil
    }

    return (x: scaledX, y: scaledY)
}


// Function to calculate the distance between two GPS points in meters
private func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
    let R = 6371000.0 // Earth's radius in meters
    let dLat = (lat2 - lat1) * .pi / 180
    let dLon = (lon2 - lon1) * .pi / 180

    let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
            sin(dLon / 2) * sin(dLon / 2)

    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c
}
