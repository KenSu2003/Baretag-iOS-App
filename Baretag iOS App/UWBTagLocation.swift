//
//  UWBTagLocation.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import Foundation
import CoreGraphics

struct UWBTagLocation: Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let x: CGFloat
    let y: CGFloat
}
