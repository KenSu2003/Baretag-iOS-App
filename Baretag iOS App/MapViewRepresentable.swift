import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var centerRegion: MKCoordinateRegion
    @Binding var isLocked: Bool
    @Binding var polygonCoords: [CLLocationCoordinate2D]
    var annotations: [MapAnnotationItem]
    var onTagTapped: (BareTag) -> Void
    var onAnchorLongPressed: (MapAnnotationItem) -> Void

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if !parent.isLocked {
                print("User moved the map. Lock disabled.")
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let customAnnotation = annotation as? CustomAnnotation else { return nil }

            let identifier = "Marker"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = false
            } else {
                view?.annotation = annotation
            }

            view?.clusteringIdentifier = nil // Disable clustering
            view?.displayPriority = .required // Ensure visibility

            switch customAnnotation.type {
            case .user:
                view?.glyphImage = UIImage(systemName: "circle.fill")
                view?.markerTintColor = .blue

            case .tag:
                view?.glyphImage = UIImage(systemName: "mappin.circle.fill")
                view?.markerTintColor = .red

            case .anchor:
                view?.glyphImage = UIImage(systemName: "flag.fill")
                view?.markerTintColor = .green
            }

            return view
        }


        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? CustomAnnotation else { return }

            switch annotation.type {
            case .tag:
                if let tag = annotation.bareTag {
                    parent.onTagTapped(tag)
                }
            case .anchor:
                if let item = annotation.item {
                    parent.onAnchorLongPressed(item)
                }
            default: break
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

        // MARK: 🔧 Render symbol as fully colored image
        private func renderSymbol(systemName: String, color: UIColor, pointSize: CGFloat) -> UIImage? {
            let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
            guard let symbolImage = UIImage(systemName: systemName)?.applyingSymbolConfiguration(config) else {
                return nil
            }

            let renderer = UIGraphicsImageRenderer(size: symbolImage.size)
            return renderer.image { _ in
                color.set()
                symbolImage.draw(at: .zero)
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
        if isLocked {
            uiView.setRegion(centerRegion, animated: true)
        }

        uiView.removeAnnotations(uiView.annotations)

        for annotation in annotations {
            let custom = CustomAnnotation(annotationItem: annotation)
            if annotation.type == .tag {
                custom.bareTag = annotation.bareTag
            }
            uiView.addAnnotation(custom)
        }

        let existingPolygons = uiView.overlays.compactMap { $0 as? MKPolygon }
        let currentCoordsMatch = existingPolygons.first?.coordinatesEqual(to: polygonCoords) ?? false

        if !currentCoordsMatch {
            uiView.removeOverlays(uiView.overlays)
            if polygonCoords.count >= 3 {
                let polygon = MKPolygon(coordinates: polygonCoords, count: polygonCoords.count)
                uiView.addOverlay(polygon)
            }
        }
    }
}

// MARK: - Custom Annotation Class
class CustomAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    let item: MapAnnotationItem?
    var bareTag: BareTag?

    init(annotationItem: MapAnnotationItem) {
        self.coordinate = annotationItem.coordinate
        self.type = annotationItem.type
        self.item = annotationItem
    }
}

// MARK: - Polygon Comparison
extension MKPolygon {
    func coordinatesEqual(to coords: [CLLocationCoordinate2D]) -> Bool {
        guard self.pointCount == coords.count else { return false }
        var polygonCoords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        self.getCoordinates(&polygonCoords, range: NSRange(location: 0, length: self.pointCount))
        return zip(polygonCoords, coords).allSatisfy { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
    }
}

func renderColoredSymbol(systemName: String, color: UIColor, pointSize: CGFloat) -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
    guard let baseImage = UIImage(systemName: systemName, withConfiguration: config) else { return nil }

    let renderer = UIGraphicsImageRenderer(size: baseImage.size)
    return renderer.image { context in
        color.set()
        baseImage.draw(at: .zero)
    }
}
