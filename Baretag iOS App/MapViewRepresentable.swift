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
    @Binding var polygonCoords: [CLLocationCoordinate2D]


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
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polygon = overlay as? MKPolygon {
                let renderer = MKPolygonRenderer(polygon: polygon)
                renderer.fillColor = UIColor.systemGreen.withAlphaComponent(0.2)
                renderer.strokeColor = UIColor.green
                renderer.lineWidth = 2
                return renderer
            }

            return MKOverlayRenderer()
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
        
        let existingPolygons = uiView.overlays.compactMap { $0 as? MKPolygon }

        let currentCoordsMatch = existingPolygons.first?.coordinatesEqual(to: polygonCoords) ?? false

        if !currentCoordsMatch {
            uiView.removeOverlays(uiView.overlays)
            if polygonCoords.count >= 3 {
                print("🟩 Drawing polygon with coords: \(polygonCoords)")
                let polygon = MKPolygon(coordinates: polygonCoords, count: polygonCoords.count)
                uiView.addOverlay(polygon)
                // After `uiView.addOverlay(polygon)`
                let boundingMapRect = polygon.boundingMapRect
                uiView.setVisibleMapRect(boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)


                // 👇 Auto-zoom to polygon region
                var zoomRect = MKMapRect.null
                for coordinate in polygonCoords {
                    let point = MKMapPoint(coordinate)
                    let rect = MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1)
                    zoomRect = zoomRect.union(rect)
                }
                uiView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
            }

        } else {
            print("🔁 Skipped redraw — coords unchanged")
        }
    }
}

extension MKPolygon {
    func coordinatesEqual(to coords: [CLLocationCoordinate2D]) -> Bool {
        guard self.pointCount == coords.count else { return false }
        var polygonCoords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        self.getCoordinates(&polygonCoords, range: NSRange(location: 0, length: self.pointCount))
        return zip(polygonCoords, coords).allSatisfy { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
    }
}
