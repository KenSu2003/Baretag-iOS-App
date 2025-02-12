//
//  UWBView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/5/25.
//

//import SwiftUI
//
//struct UWBView: View {
//    @ObservedObject var uwbManager = UWBManager()
//    
//    var body: some View {
//        VStack {
//            Text("📏 Distance: \(String(format: "%.2f", uwbManager.distance)) meters")
//                .font(.headline)
//            
//            // Dynamic arrow representing direction to the BareTag
//            Image(systemName: "arrow.up.circle.fill")
//                .resizable()
//                .frame(width: 100, height: 100)
//                .rotationEffect(Angle(degrees: uwbManager.angle))
//                .padding()
//
//            Button(action: {
//                if uwbManager.distance > 0 {
//                    uwbManager.stopRanging()
//                } else {
//                    uwbManager.startRanging()
//                }
//            }) {
//                Text(uwbManager.distance > 0 ? "Stop Ranging" : "Start Ranging")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//        }
//        .padding()
//    }
//}
