//
//  RegisterView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/24/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode  // To close view on success

    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)

            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            if let successMessage = successMessage {  // ✅ Show success message properly
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }

            Button(action: registerUser) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }

    func registerUser() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard let url = URL(string: "\(BASE_URL)/registration") else {
            errorMessage = "Invalid server URL"
            return
        }

        let body: [String: Any] = ["username": username, "password": password, "phoneNumber": "1234567890", "email": "user@example.com"]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, let data = data, error == nil else {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        if httpResponse.statusCode == 201, let success = jsonResponse["message"] as? String {
                            successMessage = success
                            errorMessage = nil
                        } else if httpResponse.statusCode == 400 || httpResponse.statusCode == 409, let error = jsonResponse["error"] as? String {
                            errorMessage = error
                            successMessage = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {  // ✅ Delay for user to see message
                                presentationMode.wrappedValue.dismiss()  // ✅ Close view
                            }
                        } else {
                            errorMessage = "Unexpected server response."
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
}

//#Preview {
//    RegisterView()
//}
