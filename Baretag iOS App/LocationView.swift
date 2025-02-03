//
//  LocationView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import SwiftUI

struct LocationView: View {
    @StateObject private var tagDataWatcher = TagLocationUpdater()  // Correct object reference

    private let scaleFactor: CGFloat = 3.0  // Scales the (x, y) plane to fit the view

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                // Correct usage: Directly access the published variable
                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .position(tagDataWatcher.tagPlaneLocation.scaled(by: scaleFactor))
            }
        }
    }
}

// Utility to scale points for display
extension CGPoint {
    func scaled(by factor: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * factor, y: self.y * factor)
    }
}
