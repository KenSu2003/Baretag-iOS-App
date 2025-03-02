//
//  TagLocationManager.swift
//  Baretag iOS App
//
//  Created by Ken Su on 3/2/25.
//

//
//  TagLocationManager.swift
//  Baretag iOS App
//
//  Created by Ken Su on 3/2/25.
//

import Foundation
import CoreLocation

class TagLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var geo_location: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        geo_location = "Lat: \(latitude!), Lon: \(longitude!)"
    }
}
