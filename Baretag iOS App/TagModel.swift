//
//  TagModel.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import Foundation

struct TagLocation: Decodable, Identifiable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
}

func loadTagData() -> TagLocation? {
    // Check if the file URL exists
    guard let url = Bundle.main.url(forResource: "tagData", withExtension: "json") else {
        print("❌ JSON file not found in the bundle")
        return nil
    }

    print("✅ JSON file URL: \(url)")

    // Attempt to read the file contents
    guard let data = try? Data(contentsOf: url) else {
        print("❌ Failed to load data from JSON file")
        return nil
    }

    print("✅ JSON file loaded successfully")

    // Attempt to decode the JSON into a TagLocation object
    guard let tag = try? JSONDecoder().decode(TagLocation.self, from: data) else {
        print("❌ Failed to decode JSON")
        return nil
    }

    print("✅ JSON decoded successfully: \(tag)")
    return tag
}
