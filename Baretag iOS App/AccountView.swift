import SwiftUI

struct AccountView: View {
    @Binding var isAuthenticated: Bool  // ✅ Binding to logout properly

    var body: some View {
        VStack {
            Text("Account Settings")
                .font(.largeTitle)
                .padding()

            Spacer()

            Button(action: {
                logout()
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
    }

    func logout() {
        guard let url = URL(string: "\(BASE_URL)/logout") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Logout failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    isAuthenticated = false  // ✅ Navigate back to LoginView
                }
            }
        }.resume()
    }
}
