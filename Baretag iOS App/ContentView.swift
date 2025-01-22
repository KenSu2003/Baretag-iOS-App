//
//  ContentView.swift
//  BareTag Anchor Locator
//
//  Created by Ken Su on 11/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationBluetoothManager = LocationBluetoothManager()
    @State private var locationText: String = "Location: Not yet fetched"
    
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
        
        // Updated UI on change
        .onChange(of: locationBluetoothManager.latitude) { newValue, oldValue in
            // Update location text when latitude changes
            if let latitude = newValue,
               let longitude = locationBluetoothManager.longitude {
                locationText = "Lat: \(latitude), Lon: \(longitude)"
            }
        }
    }
}

#Preview {
    ContentView()
}
