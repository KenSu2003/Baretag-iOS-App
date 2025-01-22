import Foundation
import Combine

class TagDataWatcher: ObservableObject {
    @Published var tagLocation: TagLocation?

    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/tagData.json" // Server URL
    private var timer: Timer?

    init() {
        fetchData()
    }

    func startUpdating() {
        // Refresh data every 5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.fetchData()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func fetchData() {
        guard let url = URL(string: serverURL) else {
            print("❌ Invalid URL: \(serverURL)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching JSON: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server")
                return
            }

            do {
                let tagLocation = try JSONDecoder().decode(TagLocation.self, from: data)
                DispatchQueue.main.async {
                    self.tagLocation = tagLocation
                }
                print("✅ Fetched and decoded tag data: \(tagLocation)")
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
