//
//  Anchor.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//
import Foundation
import CoreGraphics

class Anchor: Identifiable, ObservableObject {
    let id: String
    let name: String
    @Published var position: CGPoint  // Dynamically track position updates

    // Initialize using the UWB position directly
    init(id: String, name: String, position: CGPoint) {
        self.id = id
        self.name = name
        self.position = position
    }
}
