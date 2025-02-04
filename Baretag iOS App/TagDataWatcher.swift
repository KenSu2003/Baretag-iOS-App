import Foundation
import Combine

class TagDataWatcher: ObservableObject {
    @Published var tagLocation: Tag?

    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/tags.json"  // Server URL
    private let localFilePath = "/Users/kensu/Documents/tags.json"  // Local file path
    private var timer: Timer?
    private var useLocalFile: Bool  // Toggle between server or local file

    
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

        print("🌐 Starting fetch from server: \(serverURL)")

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData  // Force fetching the latest version

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching JSON from server: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
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
                print("❌ Raw server response: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
            }
        }
        task.resume()
    }

}
