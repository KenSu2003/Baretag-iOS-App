//
//  UWBManager.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/5/25.
//

import Foundation
import NearbyInteraction
import CoreLocation

//class UWBManager: NSObject, ObservableObject {
//    private var session: NISession?  // UWB session
//    @Published var distance: Double = 0.0
//    @Published var angle: Double = 0.0
//    
//    override init() {
//        super.init()
//        session = NISession()
//        session?.delegate = self
//    }
//
//    // Start UWB ranging session using BareTag (simulated token exchange)
//    func startRanging() {
//        print("🔍 Starting UWB ranging session...")
//        
//        // Simulate a discovery token or fetch it from the BareTag
//        guard let discoveryToken = getSimulatedDiscoveryToken() else {
//            print("❌ Failed to get discovery token.")
//            return
//        }
//        
//        let config = NINearbyPeerConfiguration(peerToken: discoveryToken)
//        session?.run(config)
//    }
//
////    private func getSimulatedDiscoveryToken() -> NIDiscoveryToken? {
////        // In a real implementation, this token would be exchanged with the BareTag via UWB or BLE pairing.
////        // For now, simulate or mock the token as if it's known
////        return NIDiscoveryToken()  // Replace this with actual token fetching logic if possible
////    }
//
//    func stopRanging() {
//        session?.invalidate()
//        print("🛑 Stopped UWB ranging session.")
//    }
//}
//
//// MARK: - NISessionDelegate for handling UWB ranging updates
//extension UWBManager: NISessionDelegate {
//    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
//        guard let object = nearbyObjects.first else { return }
//        
//        // Extract distance and angle if available
//        if let distance = object.distance {
//            self.distance = Double(distance)
//        }
//        if let direction = object.direction {
//            self.angle = Double(direction.azimuth.radiansToDegrees)
//        }
//        
//        print("📏 Distance: \(self.distance) meters, 🔄 Angle: \(self.angle) degrees")
//    }
//    
//    func session(_ session: NISession, didInvalidateWith error: Error) {
//        print("❌ UWB session invalidated: \(error.localizedDescription)")
//    }
//}
