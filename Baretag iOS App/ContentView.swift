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
            TabView {
                // Tab 1: Fetch Location and Send via BLE
                AnchorLocatorView()
                    .tabItem {
                        Label("Location", systemImage: "location")
                    }

                // Tab 2: Display Received Data
                TagMapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                //Tab 3: Precise Relative Location
                LocationView()
                    .tabItem{
                        Label("Precise", systemImage: "circle")
                    }
            }
        }
}

#Preview {
    ContentView()
}
