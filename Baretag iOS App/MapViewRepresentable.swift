//
//  MapViewRepresentable.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/22/25.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var isLocked: Bool

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        // Track user interaction
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if !parent.isLocked {
                print("User moved the map. Lock disabled.")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Recenter the map only when locked
        if isLocked {
            let zoomRegion = MKCoordinateRegion(
                center: centerCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Adjust zoom level
            )
            uiView.setRegion(zoomRegion, animated: true)
        }

        // Always ensure the annotation stays at the tag location
        uiView.removeAnnotations(uiView.annotations) // Remove old annotations
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = "Tag Location"
        uiView.addAnnotation(annotation)
    }
}
