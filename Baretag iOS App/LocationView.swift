//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//
import SwiftUI

struct LocationView: View {
    @StateObject private var anchorWatcher = AnchorDataWatcher(useLocalFile: true)  // Dynamic anchors
    @StateObject private var tagWatcher = TagDataWatcher(useLocalFile: true)  // Dynamic tag updates

    var body: some View {
        GeometryReader { geometry in
            let maxX = (anchorWatcher.anchors.map { $0.position.x }.max() ?? 100)
            let maxY = (anchorWatcher.anchors.map { $0.position.y }.max() ?? 100)

            let dynamicMaxX = tagWatcher.tagLocation != nil ? max(maxX, tagWatcher.tagLocation!.x) : maxX
            let dynamicMaxY = tagWatcher.tagLocation != nil ? max(maxY, tagWatcher.tagLocation!.y) : maxY

            ZStack {
                // Dynamically position anchors
                ForEach(anchorWatcher.anchors, id: \.id) { anchor in
                    VStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                        Text(anchor.name)
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .position(
                        CGPoint(
                            x: (anchor.position.x / dynamicMaxX) * geometry.size.width,
                            y: (1 - (anchor.position.y / dynamicMaxY)) * geometry.size.height
                        )
                    )
                }

                // Position the tag dynamically
                if let tag = tagWatcher.tagLocation {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .position(
                            CGPoint(
                                x: (tag.x / dynamicMaxX) * geometry.size.width,
                                y: (1 - (tag.y / dynamicMaxY)) * geometry.size.height
                            )
                        )
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            anchorWatcher.startUpdating()
            tagWatcher.startUpdating()
        }
    }
}
