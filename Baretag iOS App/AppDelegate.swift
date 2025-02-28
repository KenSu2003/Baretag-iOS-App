////
////  AppDelegate.swift
////  Baretag iOS App
////
////  Created by Ken Su on 2/28/25.
////
//
//import UIKit
//
//
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    func applicationWillTerminate(_ application: UIApplication) {
//        logoutUser()  // ✅ Auto log out when app is closed
//    }
//
//    private func logoutUser() {
//        guard let url = URL(string: "\(BASE_URL)/logout") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Error logging out: \(error.localizedDescription)")
//                return
//            }
//            print("✅ User logged out successfully.")
//        }.resume()
//    }
//}
