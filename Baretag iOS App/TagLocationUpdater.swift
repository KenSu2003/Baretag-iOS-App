import Foundation
import Combine
import CoreLocation

class TagLocationUpdater: ObservableObject {
    @Published var tagPlaneLocation: CGPoint = .zero  // Holds the tag's converted (x, y) location
    
//    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/tagData.json"
    private let serverURL = ""
    private var timer: Timer?

    init() {
        startUpdating()
    }

    func startUpdating() {
        // Periodically fetch the tag data every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchLocalOrServerTagDataAndConvert()
        }
    }

    deinit {
        timer?.invalidate()
    }

    // First check the local file, fallback to server if necessary
    private func fetchLocalOrServerTagDataAndConvert() {
        if let localTagLocation = fetchTagDataFromLocalFile() {
            print("✅ Loaded tag location from local file")
            self.convertAndUpdate(tagLocation: localTagLocation)
        } else {
            print("ℹ️ Local file not available or failed to load. Fetching from server.")
            fetchTagDataFromServer()
        }
    }

    // Fetch tag data from the server and convert it
    private func fetchTagDataFromServer() {
        guard let url = URL(string: serverURL) else {
            print("❌ Invalid server URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("❌ Error fetching JSON from server: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                return
            }

            do {
                let tagLocation = try JSONDecoder().decode(TagLocation.self, from: data)
                print("✅ Fetched tag location from server: \(tagLocation)")
                
                // Convert GPS to (x, y) and update
                self?.convertAndUpdate(tagLocation: tagLocation)
                
            } catch {
                print("❌ Decoding error from server: \(error)")
            }
        }
        task.resume()
    }

    // Fetch tag data from the local file
    private func fetchTagDataFromLocalFile() -> TagLocation? {
        // Specify the full path to tagData.json
        let customPath = "/Users/kensu/Documents/tagData.json"
        let fileURL = URL(fileURLWithPath: customPath)

        do {
            let data = try Data(contentsOf: fileURL)
            let tagLocation = try JSONDecoder().decode(TagLocation.self, from: data)
            print("✅ Loaded tag location from: \(customPath)")
            return tagLocation
        } catch {
            print("❌ Error loading or decoding tagData.json from: \(customPath) — \(error)")
            return nil
        }
    }


    // Convert GPS coordinates to (x, y) and update the UI
    private func convertAndUpdate(tagLocation: TagLocation) {
        let convertedPoint = convertGPSToPlane(latitude: tagLocation.latitude, longitude: tagLocation.longitude)
        DispatchQueue.main.async {
            self.tagPlaneLocation = convertedPoint
        }
    }

    // GPS-to-plane conversion logic
    private func convertGPSToPlane(latitude: Double, longitude: Double) -> CGPoint {
        let anchor1 = [42.393583596734885, -72.52876433552545]
        let anchor2 = [42.39367105634477, -72.52959509675617]
        
        let bottomLeftAnchor = CLLocationCoordinate2D(latitude: anchor1[0], longitude: anchor1[1])
        let topRightAnchor = CLLocationCoordinate2D(latitude: anchor2[0], longitude: anchor2[1])
        
        let normalizedX = CGFloat((longitude - bottomLeftAnchor.longitude) / (topRightAnchor.longitude - bottomLeftAnchor.longitude))
        let normalizedY = CGFloat((latitude - bottomLeftAnchor.latitude) / (topRightAnchor.latitude - bottomLeftAnchor.latitude))
        
        let x = normalizedX * 100  // Convert to plane scale
        let y = normalizedY * 100  // Convert to plane scale
        
        return CGPoint(x: x, y: y)
    }
}
