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

    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/user.json"  // Replace with actual URL
    private let localFilePath = "/Users/kensu/Documents/user.json"  // Adjust path if needed
    private var timer: Timer?
    private var useLocalFile: Bool

    init(useLocalFile: Bool = false) {
        self.useLocalFile = useLocalFile
        fetchUserLocation()  // Load initial location
        startUpdating()      // Periodically refresh location
    }

    func startUpdating() {
        // Refresh user location every 5 seconds
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
            fetchServerUserLocation()
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
            }
            print("✅ Loaded user location from local file: \(location)")
        } catch {
            print("❌ Failed to load or decode local user location data: \(error)")
        }
    }

    private func fetchServerUserLocation() {
        guard let url = URL(string: serverURL) else {
            print("❌ Invalid server URL: \(serverURL)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching user location from server: \(error.localizedDescription)")
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
                }
                print("✅ Fetched and decoded user location from server: \(location)")
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
        task.resume()
    }
}

// Model for decoding JSON
struct SimulatedLocation: Codable {
    let latitude: Double
    let longitude: Double
}
