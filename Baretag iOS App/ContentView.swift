//
//  ContentView.swift
//  BareTag Anchor Locator
//
//  Created by Ken Su on 11/11/24.
//

// https://stackoverflow.com/questions/56514998/find-all-available-images-for-imagesystemname

import SwiftUI

var BASE_URL = "http://172.24.131.25:5000"

struct ContentView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false  // ✅ Persistent login state

    var body: some View {
        if isAuthenticated {
            MainTabView(isAuthenticated: $isAuthenticated)  // ✅ Pass binding
        } else {
            LoginView(isAuthenticated: $isAuthenticated)  // ✅ Pass binding
        }
    }
}

struct MainTabView: View {
    @Binding var isAuthenticated: Bool  // ✅ Receive binding from ContentView

    var body: some View {
        TabView {
            AnchorLocatorView()
                .tabItem {
                    Label("Localizer", systemImage: "signpost.right.and.left.circle.fill")
                }
            TagLocatorView()
                .tabItem {
                    Label("Tag Locator", systemImage: "tag")
                }
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            AccountView(isAuthenticated: $isAuthenticated)  // ✅ Pass binding
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}
