//
//  TagModel.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import Foundation
import CoreGraphics

// ✅ Model for API response
struct TagLocationResponse: Codable {
    let recentTagLocations: [TagLocation]?
    let message: String?
}

// ✅ Model for individual tag locations
struct TagLocation: Codable, Equatable {
    let tagID: String
    let tagName: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
}

// ✅ Modify `Tag` struct if needed (optional)
struct Tag: Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let x: CGFloat
    let y: CGFloat

    // Provide default values for x and y during decoding if missing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)

        // Default to 0.0 if x and y are not present in the JSON
        x = try container.decodeIfPresent(CGFloat.self, forKey: .x) ?? 0.0
        y = try container.decodeIfPresent(CGFloat.self, forKey: .y) ?? 0.0
    }
}



func copyJSONToDocuments() -> URL? {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationURL = documentsURL.appendingPathComponent("tagData.json")

    // Only copy the file if it doesn't already exist
    if !fileManager.fileExists(atPath: destinationURL.path) {
        guard let bundleURL = Bundle.main.url(forResource: "tagData", withExtension: "json") else {
            print("❌ Failed to locate tagData.json in bundle")
            return nil
        }

        do {
            try fileManager.copyItem(at: bundleURL, to: destinationURL)
            print("✅ Copied tagData.json to Documents directory")
        } catch {
            print("❌ Failed to copy tagData.json: \(error)")
            return nil
        }
    } else {
        print("✅ tagData.json already exists in Documents directory")
    }

    return destinationURL
}



func loadTagData() -> Tag? {
    let customPath = "/Users/kensu/Documents/tagData.json"
    let url = URL(fileURLWithPath: customPath)
    
    do {
        let data = try Data(contentsOf: url)
        let tag = try JSONDecoder().decode(Tag.self, from: data)
        print("✅ JSON decoded successfully: \(tag)")
        return tag
    } catch {
        print("❌ Failed to load or decode JSON: \(error)")
        return nil
    }
}

