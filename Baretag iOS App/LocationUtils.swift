//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import CoreGraphics
import Foundation

func convertGPSToPlane(latitude: Double, longitude: Double) -> CGPoint {
    // Define bounding box (use real-world GPS min/max for your anchors)
    let minLat = 42.39330456034727
    let maxLat = 42.39367166929857
    let minLong = -72.52969898450374
    let maxLong = -72.52874061779049

    let normalizedX = CGFloat((longitude - minLong) / (maxLong - minLong))
    let normalizedY = CGFloat((latitude - minLat) / (maxLat - minLat))

    let planeX = normalizedX * 100  // Scaling to match plane coordinates
    let planeY = normalizedY * 100

    return CGPoint(x: planeX, y: planeY)
}




func calculateBoundingBox(from anchors: [Anchor]) -> (minLat: Double, maxLat: Double, minLong: Double, maxLong: Double) {
    let minLat = anchors.map { $0.latitude }.min() ?? 0.0
    let maxLat = anchors.map { $0.latitude }.max() ?? 1.0
    let minLong = anchors.map { $0.longitude }.min() ?? 0.0
    let maxLong = anchors.map { $0.longitude }.max() ?? 1.0

    return (minLat, maxLat, minLong, maxLong)
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
