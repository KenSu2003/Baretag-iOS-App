import SwiftUI
import CoreLocation

struct LocationView: View {
    @StateObject private var tagUpdater = TagLocationUpdater()
    @State private var anchors: [Anchor] = []

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let scaleX = screenWidth / 100
            let scaleY = screenHeight / 100

            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                // Draw anchors as white rectangles
                ForEach(anchors) { anchor in
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .position(
                            CGPoint(
                                x: anchor.position.x * scaleX,
                                y: anchor.position.y * scaleY
                            )
                        )
                }

                // Draw the tag's location as a red circle
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .position(
                        CGPoint(
                            x: tagUpdater.tagPlaneLocation.x * scaleX,
                            y: tagUpdater.tagPlaneLocation.y * scaleY
                        )
                    )
            }
        }
        .onAppear {
            loadAndConvertAnchors()
        }
    }

    private func loadAndConvertAnchors() {
        let loadedAnchors = loadAnchorsFromJSON()

        // Calculate positions dynamically and update anchors
        anchors = loadedAnchors.map { anchor in
            var updatedAnchor = anchor
            updatedAnchor.position = convertGPSToPlane(
                latitude: anchor.latitude,
                longitude: anchor.longitude,
                anchors: loadedAnchors
            )
            return updatedAnchor
        }
    }
}
