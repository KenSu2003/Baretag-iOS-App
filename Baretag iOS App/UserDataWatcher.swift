//
//  UserDataWatcher.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/4/25.
//

import Foundation
import CoreLocation
import Combine

class UserDataWatcher: ObservableObject {
    @Published var userLocation: CLLocation?
    
    private let localFilePath = "/Users/kensu/Documents/user.json"
    private var timer: Timer?
    private let useLocalFile: Bool
    private let useServer: Bool
    private let locationManager = UserLocationManager()

    init(useLocalFile: Bool = false) {
        self.useLocalFile = useLocalFile
        self.useServer = false
        self.userLocation = locationManager.userLocation
        fetchUserLocation()
        startUpdating()
    }

    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchUserLocation()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func fetchUserLocation() {
        if useLocalFile {
            fetchLocalUserLocation()
        } else {
            if let gpsLocation = locationManager.userLocation {
                DispatchQueue.main.async {
                    self.userLocation = gpsLocation
                    print("📡 Using live GPS: \(gpsLocation.coordinate.latitude), \(gpsLocation.coordinate.longitude)")
                }
            } else {
                print("⚠️ No valid GPS location available.")
            }
        }
    }


    private func fetchLocalUserLocation() {
        let url = URL(fileURLWithPath: localFilePath)
        do {
            let data = try Data(contentsOf: url)
            let locationData = try JSONDecoder().decode(SimulatedLocation.self, from: data)
            let location = CLLocation(latitude: locationData.latitude, longitude: locationData.longitude)
            DispatchQueue.main.async {
                self.userLocation = location
                print("📂 Loaded user.json location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        } catch {
            print("❌ Failed to load local user location: \(error)")
        }
    }
}

// Model for JSON decoding
struct SimulatedLocation: Codable {
    let latitude: Double
    let longitude: Double
}
