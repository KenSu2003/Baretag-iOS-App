import SwiftUI
import MapKit

struct GridOverlay: View {
    @Binding var isGridVisible: Bool
    var mapRegion: MKCoordinateRegion
    
    var body: some View {
        if isGridVisible {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let metersPerPoint = mapRegion.span.longitudeDelta * 111_139 / width
                    let spacing = max(10, 1 / metersPerPoint * 50) // Adjust grid size dynamically
                    
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
            .edgesIgnoringSafeArea(.all)
            .allowsHitTesting(false) // Ensure interactions go through to the map
        }
    }


    // ✅ Keep grid at 1m per square when zoomed in
    func calculateGridSize(mapRegion: MKCoordinateRegion, viewSize: CGSize) -> CGFloat {
        let metersPerLatitude = 111_320.0  // Meters per degree of latitude
        let metersPerPixel = (mapRegion.span.latitudeDelta * metersPerLatitude) / viewSize.height
        return 1.0 / metersPerPixel  // 1 meter in pixels
    }
}
