//
//  MapViewModel.swift
//  Baretag iOS App
//
//  Created by Ken Su on 3/11/25.
//

import MapKit
import Combine

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3936, longitude: -72.5291),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
}

