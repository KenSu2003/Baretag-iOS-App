//
//  TagModel.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import Foundation

import Foundation
import CoreGraphics

struct TagLocation: Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let x: CGFloat  // UWB plane x-coordinate
    let y: CGFloat  // UWB plane y-coordinate

    // Automatic conformance works as long as all properties conform to `Equatable`
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



func loadTagData() -> TagLocation? {
    let customPath = "/Users/kensu/Documents/tagData.json"
    let url = URL(fileURLWithPath: customPath)
    
    do {
        let data = try Data(contentsOf: url)
        let tag = try JSONDecoder().decode(TagLocation.self, from: data)
        print("✅ JSON decoded successfully: \(tag)")
        return tag
    } catch {
        print("❌ Failed to load or decode JSON: \(error)")
        return nil
    }
}

