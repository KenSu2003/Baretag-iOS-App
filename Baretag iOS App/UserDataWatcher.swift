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
    
    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/user.json"
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
            fetchLocalUserLocation()  // ✅ Only use local JSON
        } else if useServer {
            fetchServerUserLocation() // ✅ Fetch from the server
        } else {
            // ✅ Only use GPS if neither local nor server is selected
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

    private func fetchServerUserLocation() {
        guard let url = URL(string: serverURL) else {
            print("❌ Invalid server URL: \(serverURL)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                return
            }

            do {
                let locationData = try JSONDecoder().decode(SimulatedLocation.self, from: data)
                let location = CLLocation(latitude: locationData.latitude, longitude: locationData.longitude)
                DispatchQueue.main.async {
                    self.userLocation = location
                    print("📡 Updated user location from server: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                }
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
        task.resume()
    }
}

// Model for JSON decoding
struct SimulatedLocation: Codable {
    let latitude: Double
    let longitude: Double
}
