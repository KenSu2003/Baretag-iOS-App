import Foundation
import CoreLocation
import SwiftUI

class TagLocationUpdater: ObservableObject {
    @Published var tagPlaneLocation: CGPoint = .zero  // Holds the tag's converted (x, y) location
    
    private let useLocalFiles = true  // Toggle between local or server files
    private let localTagDataPath = "/Users/kensu/Documents/tagData.json"  // Local path to tagData.json
    private var timer: Timer?

    init() {
        startPeriodicUpdates()
    }

    func startPeriodicUpdates() {
        // Periodically fetch the tag data every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchLocalOrServerTagDataAndConvert()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func fetchLocalOrServerTagDataAndConvert() {
        if useLocalFiles {
            if let localTagLocation = fetchTagDataFromLocalFile() {
                print("✅ Loaded tag location from local file")
                self.convertAndUpdate(tagLocation: localTagLocation)
            } else {
                print("❌ Local file not available or failed to load.")
            }
        }
    }

    private func fetchTagDataFromLocalFile() -> TagLocation? {
        let fileURL = URL(fileURLWithPath: localTagDataPath)

        do {
            let data = try Data(contentsOf: fileURL)
            let tagLocation = try JSONDecoder().decode(TagLocation.self, from: data)
            print("✅ Loaded tag location from: \(localTagDataPath)")
            return tagLocation
        } catch {
            print("❌ Error loading or decoding tagData.json from: \(localTagDataPath) — \(error)")
            return nil
        }
    }

    private func convertAndUpdate(tagLocation: TagLocation) {
        let anchors = loadAnchorsFromJSON()

        guard !anchors.isEmpty else {
            print("❌ No anchors available for conversion")
            return
        }

        let convertedPoint = convertGPSToPlane(latitude: tagLocation.latitude, longitude: tagLocation.longitude, anchors: anchors)
        print("🌍 Tag GPS Location: (\(tagLocation.latitude), \(tagLocation.longitude))")
        print("📍 Converted to (x, y): \(convertedPoint)")

        DispatchQueue.main.async {
            self.tagPlaneLocation = convertedPoint
        }
    }
}
