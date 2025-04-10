//
//  LoginView.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/24/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @Binding var isAuthenticated: Bool
    @State private var errorMessage: String?
    @State private var showRegister = false

    // ✅ Store user_id globally using `UserDefaults`
    @AppStorage("user_id") private var userID: Int?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("BareTag Login")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)

                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled(true)
                        .keyboardType(.default)
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button(action: loginUser) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()

                    Button(action: { showRegister = true }) {
                        Text("Create an Account")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .sheet(isPresented: $showRegister) {
                        RegisterView()
                    }
                }
                .padding()
            }
            .ignoresSafeArea(.keyboard)
        }
    }
    
    // Store user_id in `UserDefaults` after login
    func loginUser() {
        guard let url = URL(string: "\(BASE_URL)/login") else {
            errorMessage = "Invalid server URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from server"
                }
                return
            }

            // ✅ Debugging: Print raw JSON response
            let responseString = String(data: data, encoding: .utf8) ?? "No Response"
            print("📡 Server Response: \(responseString)")

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let userID = jsonResponse["user_id"] as? Int {
                            UserDefaults.standard.set(userID, forKey: "user_id")
                            isAuthenticated = true
                        } else if let errorMessage = jsonResponse["error"] as? String {
                            // ✅ Handle "Invalid credentials" error properly
                            self.errorMessage = errorMessage
                            print("❌ Login failed: \(errorMessage)")
                        } else {
                            self.errorMessage = "Unexpected response format"
                            print("⚠️ Unexpected JSON structure: \(jsonResponse)")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid JSON response"
                }
            }
        }
        task.resume()
    }

}
