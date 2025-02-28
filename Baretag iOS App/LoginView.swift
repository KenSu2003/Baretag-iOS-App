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
    @State private var showRegister = false  // ✅ Control navigation to RegisterView
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("BareTag Login")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)

                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

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
            .ignoresSafeArea(.keyboard)  // ✅ Ensures keyboard doesn’t mess with layout
        }

    }
    
    
    // Login User
    func loginUser() {
        guard let url = URL(string: "https://vital-dear-rattler.ngrok-free.app/login") else {
            errorMessage = "Invalid server URL"
            return
        }

        let body: [String: Any] = ["username": username, "password": password]
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
                        if httpResponse.statusCode == 200 {
                            if let userID = jsonResponse["user_id"] as? Int {
                                isAuthenticated = true
                            } else {
                                errorMessage = "Unexpected response format"
                            }
                        } else if httpResponse.statusCode == 401 {
                            errorMessage = jsonResponse["error"] as? String ?? "Invalid username or password"
                        } else {
                            errorMessage = "Unexpected server response"
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Invalid response from server"
                }
            }
        }.resume()
    }
}

//#Preview {
//    LoginView(isAuthenticated: .constant(false))
//}
