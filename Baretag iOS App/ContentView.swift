//
//  ContentView.swift
//  BareTag Anchor Locator
//
//  Created by Ken Su on 11/11/24.
//

// https://stackoverflow.com/questions/56514998/find-all-available-images-for-imagesystemname

import SwiftUI

struct ContentView: View {
    @StateObject private var locationBluetoothManager = LocationBluetoothManager()
    @State private var locationText: String = "Location: Not yet fetched"
    
    var body: some View {
            TabView {
                // Tab 1: Fetch Location and Send via BLE
                AnchorLocatorView()
                    .tabItem {
                        Label("Localizer", systemImage: "signpost.right.and.left.circle.fill")
                    }

                // Tab 2: Display Received Data
                TagMapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                //Tab 3: Precise Relative Location
                LocationView()
                    .tabItem{
                        Label("Precise GPS", systemImage: "airtag")
                    }
            }
        }
}

#Preview {
    ContentView()
}
