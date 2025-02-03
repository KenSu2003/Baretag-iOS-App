//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import CoreGraphics
import Foundation

func convertGPSToPlane(latitude: Double, longitude: Double, anchors: [Anchor]) -> CGPoint {
    // Determine min and max bounds with a buffer
    let minLatitude = (anchors.map { $0.latitude }.min() ?? 0.0) - 0.0001
    let maxLatitude = (anchors.map { $0.latitude }.max() ?? 1.0) + 0.0001
    let minLongitude = (anchors.map { $0.longitude }.min() ?? 0.0) - 0.0001
    let maxLongitude = (anchors.map { $0.longitude }.max() ?? 1.0) + 0.0001

    print("📏 Bounding Box - minLat: \(minLatitude), maxLat: \(maxLatitude), minLong: \(minLongitude), maxLong: \(maxLongitude)")

    // Normalize lat/lon within bounds
    let normalizedX = CGFloat((longitude - minLongitude) / (maxLongitude - minLongitude))
    let normalizedY = CGFloat((latitude - minLatitude) / (maxLatitude - minLatitude))

    // Scale to a larger plane and add an offset to the Y-axis
    let planeWidth: CGFloat = 800  // Increased plane width for better spread
    let planeHeight: CGFloat = 800
    let yOffset: CGFloat = 100  // Offset to adjust vertical placement

    let x = normalizedX * planeWidth
    let y = (normalizedY * planeHeight) + yOffset

    print("🧭 Normalized (x, y): (\(normalizedX), \(normalizedY)) -> Plane (x, y): (\(x), \(y))")

    return CGPoint(x: x, y: y)
}



func loadAnchorsFromJSON() -> [Anchor] {
    let customPath = "/Users/kensu/Documents/anchors.json"  // Manually specify the local path
    let fileURL = URL(fileURLWithPath: customPath)

    do {
        let data = try Data(contentsOf: fileURL)
        let anchors = try JSONDecoder().decode([Anchor].self, from: data)
        print("✅ Loaded anchors from JSON: \(anchors)")
        return anchors
    } catch {
        print("❌ Error loading or decoding anchors.json: \(error)")
        return []
    }
}
