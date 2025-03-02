//
//  AnchorLocatorView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import SwiftUI

struct AnchorLocatorView: View {
    @StateObject private var anchorLocationManager = AnchorLocationManager()
    
    // User-input fields for anchor details
    @State private var anchorName: String = ""
    @State private var anchorID: String = ""
    @State private var positionX: Double = -1.0
    @State private var positionY: Double = -1.0
    
    var body: some View {
        VStack(spacing: 15) {

            // Push content slightly higher
            Spacer().frame(height: 10)

            // Text Fields for User Input
            TextField("Enter Anchor Name", text: $anchorName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            
            // Does not check whether the Anchor ID has already been used.
            TextField("Enter Anchor ID", text: $anchorID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Fixed Numeric Input Fields (X, Y Coordinates)
//            TextField("Enter x Coordinate", text: Binding(
//                get: { String(positionX) },
//                set: { positionX = Double($0) ?? -1.0 }
//            ))
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .padding(.horizontal)
//            .keyboardType(.decimalPad)  // Only allow the number pad
//
//            TextField("Enter y Coordinate", text: Binding(
//                get: { String(positionY) },
//                set: { positionY = Double($0) ?? -1.0 }
//            ))
//            .textFieldStyle(RoundedBorderTextFieldStyle())
//            .padding(.horizontal)
//            .keyboardType(.decimalPad)  // Only allow the number pad

            // Fetch and Forward Location Button (Centered)
            Button(action: {
                anchorLocationManager.fetchLocationAndSend(name: anchorName, id: anchorID)
            }) {
                Text("Fetch Location & Send via BLE")
                    .font(.system(size: 18, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity) // Center Button
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .frame(maxWidth: 250, alignment: .center)
            .padding(.top, 10)

            // Progress Display (Status Box)
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 80)
                .overlay(
                    Text(anchorLocationManager.geo_location ?? "Fetching Location")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                )
                .padding(.horizontal)

            // Display the current status
            Text(anchorLocationManager.status)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 10)

            Spacer() // Pushes everything upwards slightly
        }
        .frame(maxHeight: .infinity, alignment: .top) // Aligns to top
        .padding(.top, 40) // Adjust for better positioning
    }
}
