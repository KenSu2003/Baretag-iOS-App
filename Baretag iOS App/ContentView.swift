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
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("user_id") private var userID: Int?

    var body: some View {
        if isAuthenticated {
            MainTabView(isAuthenticated: $isAuthenticated)
                .onAppear {
                    fetchUserData()  // 🔄 Ensure we reload user data
                }
        } else {
            LoginView(isAuthenticated: $isAuthenticated)
        }
    }

    private func fetchUserData() {
        guard let userID = userID else {
            print("❌ No user_id found in UserDefaults")
            return
        }

        let url = URL(string: "\(BASE_URL)/get_user_data?user_id=\(userID)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching user data: \(error)")
                return
            }
            guard let data = data else {
                print("❌ No data received")
                return
            }
            print("📡 Fetched user data: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
        }.resume()
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
