//
//  SimulatedLocationManger.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import Foundation
import CoreLocation
import Combine

class SimulatedLocationManager: ObservableObject {
    @Published var userLocation: CLLocation?

    private let localFilePath = "/Users/kensu/Documents/userLocation.json"  // Adjust path as needed
    private var timer: Timer?

    init() {
        loadSimulatedLocation()  // Load initial location
        startUpdatingLocation()  // Periodically refresh location
    }

    private func startUpdatingLocation() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.loadSimulatedLocation()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func loadSimulatedLocation() {
        print("🔄 Loading simulated location...")
        let url = URL(fileURLWithPath: localFilePath)
        do {
            let data = try Data(contentsOf: url)
            let locationData = try JSONDecoder().decode(SimulatedLocation.self, from: data)
            let location = CLLocation(latitude: locationData.latitude, longitude: locationData.longitude)
            DispatchQueue.main.async {
                self.userLocation = location
            }
            print("✅ Simulated location updated: \(location)")
        } catch {
            print("❌ Failed to load simulated location: \(error)")
        }
    }
}

// Model for decoding JSON
struct SimulatedLocation: Codable {
    let latitude: Double
    let longitude: Double
}
