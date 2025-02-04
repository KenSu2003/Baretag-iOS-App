//
//  LocationUtils.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//
import SwiftUI

struct LocationView: View {
    @State private var anchors: [Anchor] = []
    @StateObject private var tagWatcher = TagDataWatcher(useLocalFile: true)  // Change to `true` for local data

    var body: some View {
        GeometryReader { geometry in
            let maxX = (anchors.map { $0.position.x }.max() ?? 100)
            let maxY = (anchors.map { $0.position.y }.max() ?? 100)

            let dynamicMaxX = tagWatcher.tagLocation != nil ? max(maxX, tagWatcher.tagLocation!.x) : maxX
            let dynamicMaxY = tagWatcher.tagLocation != nil ? max(maxY, tagWatcher.tagLocation!.y) : maxY

            ZStack {
                ForEach(anchors, id: \.id) { anchor in
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
            loadAnchors()
            tagWatcher.startUpdating()
        }
    }

    private func loadAnchors() {
        if let url = Bundle.main.url(forResource: "anchors", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let jsonObjects = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            anchors = jsonObjects.compactMap { obj in
                if let id = obj["id"] as? String,
                   let name = obj["name"] as? String,
                   let posX = obj["positionX"] as? CGFloat,
                   let posY = obj["positionY"] as? CGFloat {
                    return Anchor(id: id, name: name, position: CGPoint(x: posX, y: posY))
                }
                return nil
            }
        }
    }
}
