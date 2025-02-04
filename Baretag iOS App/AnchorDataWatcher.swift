//
//  AnchorDataWatcher.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/3/25.
//

import Foundation
import Combine

class AnchorDataWatcher: ObservableObject {
    @Published var anchors: [Anchor] = []

    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/anchors.json"  // Replace with actual URL
    private let localFilePath = "/Users/kensu/Documents/anchors.json"  // Local file path
    private var timer: Timer?
    private var useLocalFile: Bool  // Toggle between server and local file

    init(useLocalFile: Bool = false) {
        self.useLocalFile = useLocalFile
        fetchAnchors()
    }

    func startUpdating() {
        // Refresh anchor data every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchAnchors()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func fetchAnchors() {
        if useLocalFile {
            fetchLocalAnchors()
        } else {
            fetchServerAnchors()
        }
    }

    private func fetchLocalAnchors() {
        let url = URL(fileURLWithPath: localFilePath)
        do {
            let data = try Data(contentsOf: url)
            let anchors = try JSONDecoder().decode([Anchor].self, from: data)
            DispatchQueue.main.async {
                self.anchors = anchors
            }
            print("✅ Loaded anchors from local file.")
        } catch {
            print("❌ Failed to load or decode local anchor data: \(error)")
        }
    }

    private func fetchServerAnchors() {
        guard let url = URL(string: serverURL) else {
            print("❌ Invalid URL: \(serverURL)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching JSON from server: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                return
            }

            do {
                let anchors = try JSONDecoder().decode([Anchor].self, from: data)
                DispatchQueue.main.async {
                    self.anchors = anchors
                }
                print("✅ Fetched and decoded anchor data from server.")
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
