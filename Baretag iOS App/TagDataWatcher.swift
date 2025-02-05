import Foundation
import Combine

class TagDataWatcher: ObservableObject {
    @Published var tagLocations: [BareTag] = []  // ✅ Store multiple tags

    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/tags.json"
    private let localFilePath = "/Users/kensu/Documents/tags.json"
    private var timer: Timer?
    private var useLocalFile: Bool

    init(useLocalFile: Bool = false) {
        self.useLocalFile = useLocalFile
        fetchData()
    }

    func startUpdating() {
        print("⏰ Starting timer to fetch data every 5 seconds.")
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            print("🔄 Timer fired: fetching data...")
            self.fetchData()
        }
    }

    deinit {
        timer?.invalidate()
    }

    private func fetchData() {
        if !useLocalFile {
            fetchServerData()
        } else {
            fetchLocalData()
        }
    }

    private func fetchLocalData() {
        let url = URL(fileURLWithPath: localFilePath)
        do {
            let data = try Data(contentsOf: url)
            let tagLocations = try JSONDecoder().decode([BareTag].self, from: data)  // ✅ Decode all tags
            DispatchQueue.main.async {
                self.tagLocations = tagLocations  // ✅ Store all tags
            }
            print("✅ Loaded \(tagLocations.count) tag(s) from local file.")
        } catch {
            print("❌ Failed to load or decode local tag data: \(error)")
        }
    }

    private func fetchServerData() {
        guard let url = URL(string: serverURL) else {
            print("❌ Invalid URL: \(serverURL)")
            return
        }

        print("🌐 Starting fetch from server: \(serverURL)")

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
                let tagLocations = try JSONDecoder().decode([BareTag].self, from: data)  // ✅ Decode all tags
                DispatchQueue.main.async {
                    self.tagLocations = tagLocations  // ✅ Store all tags
                }
                print("✅ Fetched and decoded \(tagLocations.count) tag(s) from server.")
            } catch {
                print("❌ Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
