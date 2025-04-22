//
//  TagModel.swift
//  Baretag iOS App
//
//  Created by Ken Su on 1/21/25.
//

import Foundation
import CoreGraphics

// Model for individual tag locations
struct TagLocation: Codable, Equatable {
    let id: String?
    let name: String
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let status: Bool?
    let timestamp: String?
   

    // Define JSON keys explicitly
    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, altitude, status, timestamp
    }

    // Provide default values for if any of the keys are missing in the API response
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)  // ✅ Now safely handles missing id
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        altitude = try container.decode(Double.self, forKey: .altitude)
        status = try container.decode(Bool.self, forKey: .status)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)  // ✅ Also safely handles missing timestamp
    }

}

// Helper struct to decode API response for multiple tag locations
struct TagResponse: Codable {
    let tags_location: [TagLocation]
}

// Debugging function to print API response before decoding
func decodeTagResponse(from data: Data) {
    do {
        let responseString = String(data: data, encoding: .utf8)
        print("📡 API Response: \(responseString ?? "No response")")  // ✅ Debug JSON output
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase  // ✅ Handles snake_case to camelCase
        let decodedData = try decoder.decode(TagResponse.self, from: data)
        
        print("✅ Successfully Decoded Tags: \(decodedData.tags_location)")
    } catch {
        print("❌ JSON Decoding Error: \(error)")
    }
}


// Function to copy `tagData.json` to Documents directory (if not present)
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


// Function to load JSON from `/Users/kensu/Documents/tagData.json`
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
