//
//  TagLocatorView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 3/2/25.
//

//
//  TagLocatorView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 3/2/25.
//

import SwiftUI
import CoreLocation

struct TagLocatorView: View {
    @StateObject private var locationManager = TagLocationManager()
    
    @State private var tagName: String = ""
    @State private var statusMessage: String?
    @State private var isSubmitting = false
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer().frame(height: 10)

            TextField("Enter Tag Name", text: $tagName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: submitTag) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                } else {
                    Text("Fetch Location & Add Tag")
                        .font(.system(size: 18, weight: .semibold))
                        .padding()
                }
            }
            .frame(maxWidth: 250)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding(.top, 10)
            .disabled(isSubmitting)

            // Display the fetched location
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 80)
                .overlay(
                    Text(locationManager.geo_location ?? "Fetching GPS location...")
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                )
                .padding(.horizontal)

            if let statusMessage = statusMessage {
                Text(statusMessage)
                    .foregroundColor(statusMessage.contains("Error") ? .red : .green)
                    .padding()
            }

            Spacer()
        }
        .padding(.top, 40)
    }

    private func submitTag() {
        guard let latitude = locationManager.latitude, let longitude = locationManager.longitude else {
            statusMessage = "Location not available"
            return
        }

        guard !tagName.isEmpty else {
            statusMessage = "Please enter a tag name"
            return
        }

        guard let url = URL(string: "\(BASE_URL)/add_tag") else {
            statusMessage = "Invalid server URL"
            return
        }

        let body: [String: Any] = [
            "tag_name": tagName,
            "x_offset": latitude,   // ✅ Replace latitude with x_offset
            "y_offset": longitude   // ✅ Replace longitude with y_offset
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        isSubmitting = true
        statusMessage = nil

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    statusMessage = "Invalid response from server"
                    return
                }

                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if httpResponse.statusCode == 201 {
                        statusMessage = jsonResponse?["message"] as? String ?? "Tag added successfully!"
                    } else {
                        statusMessage = jsonResponse?["error"] as? String ?? "Unexpected error."
                    }
                } catch {
                    statusMessage = "Failed to decode response"
                }
            }
        }.resume()
    }

}
