import SwiftUI
import MapKit

struct GridOverlay: View {
    @Binding var isGridVisible: Bool
    var mapRegion: MKCoordinateRegion

    var body: some View {
        if isGridVisible {
            GeometryReader { geometry in
                let metersPerPoint = metersPerPixel(region: mapRegion, viewWidth: geometry.size.width)
                let spacing = max(metersToPixels(meters: 2, metersPerPoint: metersPerPoint), 1) // 🔥 Fix: Use 2m instead of 1m

                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    var x: CGFloat = 0
                    while x <= width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                        x += spacing
                    }

                    var y: CGFloat = 0
                    while y <= height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                        y += spacing
                    }
                }
                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
            }
            .allowsHitTesting(false)
        }
    }

    // **Fix: Convert 1m to pixels but adjust for correct spacing**
    private func metersToPixels(meters: Double, metersPerPoint: Double) -> CGFloat {
        return CGFloat(meters / metersPerPoint)
    }

    // **Calculate meters per pixel correctly**
    private func metersPerPixel(region: MKCoordinateRegion, viewWidth: CGFloat) -> Double {
        let latitudeMeters = region.span.latitudeDelta * 111320 // Convert degrees to meters
        return latitudeMeters / Double(viewWidth) // Meters per point on screen
    }
}
