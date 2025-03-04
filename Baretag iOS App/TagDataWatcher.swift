import Foundation
import Combine

class TagDataWatcher: ObservableObject {
    @Published var tagLocations: [BareTag] = []  // ✅ Store multiple tags

//    private let serverURL = "https://baretag-tag-data.s3.us-east-2.amazonaws.com/tags.json"
    private let serverURL = "\(BASE_URL)/get_tags"
    private let localFilePath = "/Users/kensu/Documents/tags.json"
    private var timer: Timer?
    private var useLocalFile: Bool

    init(useLocalFile: Bool = false) {
        self.useLocalFile = useLocalFile
        fetchData()
    }

    func startUpdating() {
        if timer == nil {  // ✅ Prevent duplicate timers
            print("⏰ Starting tag data update timer...")
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                print("🔄 Timer fired: fetching tag data...")
                self.fetchData()
            }
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

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from server.")
                return
            }

            do {
                struct APIResponse: Codable {
                    let tags_location: [BareTag]
                }

                let decodedResponse = try JSONDecoder().decode(APIResponse.self, from: data)

                DispatchQueue.main.async {
                    self.tagLocations = decodedResponse.tags_location
                }
                print("✅ Successfully fetched \(decodedResponse.tags_location.count) tags from server.")
            } catch {
                print("❌ JSON decoding error: \(error)")
            }
        }
        task.resume()
    }

}
