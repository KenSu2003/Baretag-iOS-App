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

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        // Custom annotation view
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            let identifier = "TagAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                // Custom annotation view
                let circleView = UIView()
                circleView.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
                circleView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                circleView.layer.cornerRadius = 20

                annotationView?.addSubview(circleView)

                // Optional label
                let label = UILabel()
                label.text = "T"
                label.textColor = .white
                label.font = UIFont.boldSystemFont(ofSize: 14)
                label.textAlignment = .center
                label.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                circleView.addSubview(label)
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
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
        // Create a region with a smaller span for zooming
        let zoomRegion = MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025) // Smaller span for closer zoom
        )

        // Set the map's region with animation
        uiView.setRegion(zoomRegion, animated: true)

        // Remove existing annotations
        uiView.removeAnnotations(uiView.annotations)

        // Add a new custom annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = centerCoordinate
        annotation.title = "Tag Location"
        uiView.addAnnotation(annotation)
    }
}
