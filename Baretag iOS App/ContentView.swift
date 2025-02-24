//
//  ContentView.swift
//  BareTag Anchor Locator
//
//  Created by Ken Su on 11/11/24.
//

// https://stackoverflow.com/questions/56514998/find-all-available-images-for-imagesystemname

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false

    var body: some View {
        if isAuthenticated {
            MainTabView()
        } else {
            LoginView(isAuthenticated: $isAuthenticated)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            AnchorLocatorView()
                .tabItem {
                    Label("Localizer", systemImage: "signpost.right.and.left.circle.fill")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            LocationView()
                .tabItem {
                    Label("UWB", systemImage: "airtag")
                }
        }
    }
}

//#Preview {
//    ContentView()
//}
