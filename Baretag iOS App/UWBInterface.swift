//
//  UWBInterface.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/5/25.
//

import Foundation

class UWBInterface {
    func sendUWBMessage(_ message: [UInt8], completion: @escaping ([UInt8]?) -> Void) {
        // Simulated sending of the UWB message. Replace this with your actual hardware logic.
        print("📡 Sending UWB message: \(message)")

        // Simulate a response after a short delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            // Simulate a response from BareTag (replace this with actual hardware response)
            let simulatedResponse = [UInt8.random(in: 1...10), UInt8.random(in: 0...255), UInt8.random(in: 0...255)]
            print("📡 Received response: \(simulatedResponse)")
            completion(simulatedResponse)
        }
    }
}
