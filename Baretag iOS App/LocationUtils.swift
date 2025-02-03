//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import CoreGraphics
import Foundation

func convertGPSToPlane(latitude: Double, longitude: Double, anchors: [Anchor]) -> CGPoint {
    // Dynamically calculate bounds with a small buffer to prevent clamping issues
    let minLatitude = (anchors.map { $0.latitude }.min() ?? 0.0) - 0.0001
    let maxLatitude = (anchors.map { $0.latitude }.max() ?? 1.0) + 0.0001
    let minLongitude = (anchors.map { $0.longitude }.min() ?? 0.0) - 0.0001
    let maxLongitude = (anchors.map { $0.longitude }.max() ?? 1.0) + 0.0001

    print("📏 Bounding Box - minLat: \(minLatitude), maxLat: \(maxLatitude), minLong: \(minLongitude), maxLong: \(maxLongitude)")

    // Normalize latitude and longitude within the dynamic bounds
    let normalizedX = CGFloat((longitude - minLongitude) / (maxLongitude - minLongitude))
    let normalizedY = CGFloat((latitude - minLatitude) / (maxLatitude - minLatitude))

    // Clamp normalized values to ensure they stay within [0, 1]
    let clampedX = min(max(normalizedX, 0), 1)
    let clampedY = min(max(normalizedY, 0), 1)

    print("🧭 Normalized (x, y): (\(normalizedX), \(normalizedY))")
    print("🔒 Clamped (x, y): (\(clampedX), \(clampedY))")

    // Scale to the plane (0 to 100)
    let x = clampedX * 100
    let y = clampedY * 100

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
