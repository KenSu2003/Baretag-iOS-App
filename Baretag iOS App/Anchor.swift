//
//  Anchor.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//
import Foundation
import CoreGraphics

struct Anchor: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let position: CGPoint  // ✅ Combine positionX and positionY into a CGPoint

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, positionX, positionY
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
//        id = try container.decode(String.self, forKey: .id)
        // ✅ Convert `id` from `Int` to `String`
        if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)

        // ✅ If `positionX` or `positionY` are missing, default to `0`
        let x = try container.decodeIfPresent(CGFloat.self, forKey: .positionX) ?? 0.0
        let y = try container.decodeIfPresent(CGFloat.self, forKey: .positionY) ?? 0.0
        position = CGPoint(x: x, y: y)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
    }
}
