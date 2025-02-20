//
//  AnchorLocatorView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import SwiftUI

struct AnchorLocatorView: View {
    @StateObject private var locationBluetoothManager = LocationBluetoothManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // Fetch and Forward Location Button
            Button(action: {
                locationBluetoothManager.fetchLocationAndSend()
            }) {
                Text("Fetch Location & Send via BLE")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Progress Display
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 80)
                .overlay(
                    Text(locationBluetoothManager.geo_location ?? "Fetching Location")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                )
                .padding(.horizontal)
            
            // Display the current status
            Text(locationBluetoothManager.status)
                .font(.body)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .padding()
    }
}
