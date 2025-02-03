//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import Foundation
import Combine
import CoreGraphics

class TagLocationUpdater: ObservableObject {
    @Published var tagPlaneLocation: CGPoint = .zero  // UWB plane location
    @Published var gpsLatitude: Double = 0.0          // GPS latitude
    @Published var gpsLongitude: Double = 0.0         // GPS longitude
    
    private let localTagDataPath = "/Users/kensu/Documents/tagData.json"
    private var timer: Timer?
    
    init() {
        startPeriodicUpdates()
    }
    
    func startPeriodicUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchTagDataAndUpdate()
        }
    }
    
    private func fetchTagDataAndUpdate() {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: localTagDataPath))
            let tagLocation = try JSONDecoder().decode(UWBTagLocation.self, from: data)
            print("✅ Loaded tag location from: \(localTagDataPath)")
            
            DispatchQueue.main.async {
                self.tagPlaneLocation = CGPoint(x: tagLocation.x, y: tagLocation.y)
                self.gpsLatitude = tagLocation.latitude
                self.gpsLongitude = tagLocation.longitude
            }
        } catch {
            print("❌ Error loading tagData.json: \(error)")
        }
    }
    
    
    private func convertAndUpdate(tagLocation: UWBTagLocation) {
        let anchors = loadAnchorsFromJSON()
        
        guard !anchors.isEmpty else {
            print("❌ No anchors available for conversion")
            return
        }
        
        // Use UWB coordinates directly or fall back to GPS conversion
        let useUWB = true  // Toggle this if needed
        let convertedPoint: CGPoint
        
        if useUWB {
            // Use UWB (x, y) directly
            convertedPoint = CGPoint(x: tagLocation.x, y: tagLocation.y)
        } else {
            // Use GPS to plane conversion
            convertedPoint = convertGPSToPlane(latitude: tagLocation.latitude, longitude: tagLocation.longitude)
        }
        
        print("🌍 Tag Location: (x: \(tagLocation.x), y: \(tagLocation.y)) -> Converted: \(convertedPoint)")
        
        DispatchQueue.main.async {
            self.tagPlaneLocation = convertedPoint
        }
    }
}
