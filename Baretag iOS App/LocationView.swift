//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import SwiftUI

struct LocationView: View {
    @ObservedObject var tagUpdater = TagLocationUpdater()

    @State private var useUWB = true  // Default to using UWB plane coordinates

    var anchors: [Anchor] = loadAnchorsFromJSON()

    var body: some View {
        GeometryReader { geometry in
            let zoom_scale = 0.8
            let scaleX = geometry.size.width / 100 * zoom_scale // Assuming UWB coordinates are scaled to 100x100
            let scaleY = geometry.size.height / 100 * zoom_scale

            VStack {
                // Toggle between UWB and GPS-based locations
                Toggle("Use UWB Coordinates", isOn: $useUWB)
                    .padding()
                    .foregroundColor(.white)

                ZStack {
                    // Draw the anchors
                    ForEach(anchors, id: \.id) { anchor in
                        Text(anchor.name)
                            .foregroundColor(.white)
                            .position(anchorPosition(for: anchor, scaleX: scaleX, scaleY: scaleY))
                            .font(.caption)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .position(anchorPosition(for: anchor, scaleX: scaleX, scaleY: scaleY))
                    }


                    // Draw the tag location
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(tagPosition(scaleX: scaleX, scaleY: scaleY))
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }

    // Helper function to calculate anchor positions
    private func anchorPosition(for anchor: Anchor, scaleX: CGFloat, scaleY: CGFloat) -> CGPoint {
        let x = useUWB ? anchor.position.x * scaleX : convertGPSToPlane(latitude: anchor.latitude, longitude: anchor.longitude).x * scaleX
        let y = useUWB ? anchor.position.y * scaleY : convertGPSToPlane(latitude: anchor.latitude, longitude: anchor.longitude).y * scaleY
        return CGPoint(x: x, y: y)
    }

    // Helper function to calculate tag position
    private func tagPosition(scaleX: CGFloat, scaleY: CGFloat) -> CGPoint {
        let x = useUWB ? tagUpdater.tagPlaneLocation.x * scaleX : convertGPSToPlane(latitude: tagUpdater.gpsLatitude, longitude: tagUpdater.gpsLongitude).x * scaleX
        let y = useUWB ? tagUpdater.tagPlaneLocation.y * scaleY : convertGPSToPlane(latitude: tagUpdater.gpsLatitude, longitude: tagUpdater.gpsLongitude).y * scaleY
        return CGPoint(x: x, y: y)
    }
}
