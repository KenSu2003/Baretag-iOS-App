import Foundation
import Combine

class TagDataWatcher: ObservableObject {
    @Published var tagLocation: Tag?

    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/tagData.json"  // Server URL
    private let localFilePath = "/Users/kensu/Documents/tagData.json"  // Local file path
    private var timer: Timer?
    private var useLocalFile: Bool  // Toggle between server or local file

    init(useLocalFile: Bool = true) {
        self.useLocalFile = useLocalFile
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
        if useLocalFile {
            fetchLocalData()
        } else {
            fetchServerData()
        }
    }

    // Fetch tag data from the local file
    private func fetchLocalData() {
        let url = URL(fileURLWithPath: localFilePath)
        do {
            let data = try Data(contentsOf: url)
            let tagLocation = try JSONDecoder().decode(Tag.self, from: data)
            DispatchQueue.main.async {
                self.tagLocation = tagLocation
            }
            print("✅ Loaded tag location from local file: \(tagLocation)")
        } catch {
            print("❌ Failed to load or decode local tag data: \(error)")
        }
    }

    // Fetch tag data from the server
    private func fetchServerData() {
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
                let tagLocation = try JSONDecoder().decode(Tag.self, from: data)
                DispatchQueue.main.async {
                    self.tagLocation = tagLocation
                }
                print("✅ Fetched and decoded tag data from server: \(tagLocation)")
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
