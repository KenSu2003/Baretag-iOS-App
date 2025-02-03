//
//  Anchor.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import Foundation
import CoreGraphics

struct Anchor: Identifiable, Decodable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    var position: CGPoint = .zero  // Calculated later

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude
    }
}
