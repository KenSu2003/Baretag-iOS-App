//
//  TagDataWatcher.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/22/25.
//

import Foundation
import Combine

class TagDataWatcher: ObservableObject {
    @Published var tagLocation: TagLocation?

    private var timer: Timer?

    init() {
        loadData()
    }

    func startUpdating() {
        // Refresh data every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.loadData()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func loadData() {
        guard let tag = loadTagData() else {
            print("❌ Failed to load tag data")
            return
        }
        DispatchQueue.main.async {
            self.tagLocation = tag
        }
        print("✅ Updated tag location: \(tag)")
    }
}
