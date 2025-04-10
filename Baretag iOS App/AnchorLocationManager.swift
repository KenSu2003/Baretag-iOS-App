//
//  LocationBluetoothManager.swift
//  BareTag Anchor Locator
//
//  Created by Ken Su on 11/11/24.
//

import SwiftUI
import CoreLocation     // Core Location Documentation: https://developer.apple.com/documentation/corelocation
import CoreBluetooth    // Core Bluetooth Documentation: https://developer.apple.com/documentation/corebluetooth


//class AnchorLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
class AnchorLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()       // Location
    
    // CBPeripheralManager: An object that manages and advertises peripheral services exposed by this app. NECESSARY FOR BLUETOOTH.
    // Documentation: https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager
    private var peripheralManager: CBPeripheralManager?     // BLE Advertising
    
    // @Published holds the latest location data to update the UI in real-time
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var altitude: Double?
    @Published var geo_location: String?
    
    // Anchor Data
    private var anchorName = ""
    private var anchorID = ""
    
    // Status update for the user UI
    @Published private(set) var status: String = "Initialzing ..."
    private var canUpdateStatus = true // Flag to control updates to `status`
    
    // Initialized Delegates
    override init() {
        super.init()
        
        // Location Manager
        locationManager.delegate = self                                         // Initialize Location Delegate
        locationManager.requestWhenInUseAuthorization()                         // Requests permission to use location services
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation  // Sets the location accuracy level to the highest
        
        // Bluetooth Manager
//        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)     // Initialize Bluetooth Delegate
        if canUpdateStatus { status = "Requesting location permissions..." }
    }
    
    
    func fetchLocationAndSend(name: String, id: String) {
        if canUpdateStatus { status = "Fetching GPS location..." }
        
        // Store user-entered or randomized name and ID
        self.anchorName = name
        self.anchorID = id

        locationManager.startUpdatingLocation() // Start fetching GPS
        
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            status = "Fetching GPS location..."
            locationManager.startUpdatingLocation()
        case .notDetermined:
            status = "Waiting for location permission..."
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            status = "❌ Location permission denied or restricted."
        default:
            status = "⚠️ Unknown location permission state."
        }
    }
    
    // didUpdateLocations: Tells the delegate that new location data is available.
    // CLLocation contatins at least one object representing the current location (Data Structure: QUEUE)
    // Altitude uses Core Location approximates mean sea level using the Earth Gravitational Model 2008
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            status = "❌ Failed to get location."
            return
        }
        latitude = location.coordinate.latitude.rounded(toPlaces: 5)
        longitude = location.coordinate.longitude.rounded(toPlaces: 5)
        altitude = location.altitude.rounded(toPlaces: 2)

        locationManager.stopUpdatingLocation()                  // Stops running locations updates to save phone's battery
        
        geo_location = "Lat: \(latitude!), Lon: \(longitude!), Alt: \(altitude!)"
        status = "📍 Location fetched. Sending to server..."
        print("✅ Location: \(geo_location!)")

        
        if canUpdateStatus { status = "Location fetched." }
        
//        sendDataOverBluetooth()
        
        sendLocationToServer(
            latitude: latitude!,
            longitude: longitude!,
            altitude: altitude ?? 0,
            name: anchorName,
            id: anchorID
        )
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location access granted.")
        case .denied, .restricted:
            print("❌ Location access denied or restricted.")
            status = "Location access denied."
        case .notDetermined:
            print("⏳ Location permission not determined yet.")
        @unknown default:
            print("⚠️ Unknown authorization status.")
        }
    }

    // Called when the state of the bluetooth device changes.
//    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
//        switch peripheral.state {
//        case (.poweredOff):
//            if canUpdateStatus{ status = "Bluetooth is not powered on." }
//            canUpdateStatus = false
//        case (.poweredOn):
//            if canUpdateStatus{ status = "Bluetooth is powered on." }
//            canUpdateStatus = true
//        case (.unauthorized):
//            if canUpdateStatus{ status = "Device is not authorized to use BLE." }
//            canUpdateStatus = false
//        case (.unsupported):
//            if canUpdateStatus{ status = "Device does not support BLE." }
//            canUpdateStatus = false
//        case (.resetting):
//            if canUpdateStatus{ status = "Connection is resetting ..." }
//            canUpdateStatus = true
//        default:
//            status = "Unknown State"
//        }
//        print(status)
//    }
    
    // Documentation: https://developer.apple.com/documentation/corebluetooth/transferring-data-between-bluetooth-low-energy-devices
    // Need the NSLocationWhenInUseUsageDescription key in your app Info.plist
    private func sendDataOverBluetooth() {
        guard let latitude = latitude, let longitude = longitude else {
            status = "Failed to fetch location."
            return
        }

        let locationData = "Lat: \(latitude), Lon: \(longitude)"
        geo_location = locationData
        print(locationData)

        // Packages the data to be advertised = The local name of the peripheral (iPhone): iPhone's Location Data
        let advertisementData: [String: Any] = [CBAdvertisementDataLocalNameKey: locationData]

        // Start Advertising the Data to Anchor
        peripheralManager?.startAdvertising(advertisementData)
        status = "Location data is now being advertised over Bluetooth."
    }

    
    
    // Send location to server with user-entered or randomized name and ID
    func sendLocationToServer(latitude: Double, longitude: Double, altitude: Double, name: String, id: String) {
//        let url = URL(string: "\(BASE_URL)/add_anchor")! // Use the ngrok HTTPS URL
        guard let url = URL(string: "\(BASE_URL)/add_anchor") else {
           status = "❌ Invalid server URL."
           return
       }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let locationData: [String: Any] = [
            "anchor_id": id,
            "anchor_name": name,
            "latitude": latitude,
            "longitude": longitude,
            "altitude": altitude
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: locationData, options: [])
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Request Error: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    print("✅ HTTP Status Code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 200 {
                        self.status = "Location sent to server!"
                    } else if (httpResponse.statusCode == 400){
                        self.status = "Missing data (anchor_name, latitude, or longitude)"
                    }
                }
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("📡 Server Response: \(responseString)")
//                    self.status = "Server Response: \(responseString)"
                }
            }
        }
        task.resume()
    }


    
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}






