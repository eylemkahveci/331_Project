//
//  AuthView.swift
//  ACE
//
//  Created by Emre Uğur on 15.01.2025.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            ContentView() // Giriş başarılıysa ana ekran
        } else {
            NavigationStack {
                VStack(spacing: 16) {
                    Text(isLoginMode ? "Login" : "Create Account")
                        .font(.largeTitle)
                        .bold()

                    // E-posta Girişi
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Şifre Girişi
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Hata Mesajı
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Giriş veya Kayıt Butonu
                    Button(action: handleAuthAction) {
                        Text(isLoginMode ? "Login" : "Create Account")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // Giriş/Kayıt Modu Değiştirici
                    Button(action: {
                        isLoginMode.toggle()
                        errorMessage = ""
                    }) {
                        Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Login")
                            .font(.caption)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Authentication")
            }
        }
    }

    // Firebase Giriş/Kayıt İşlemi
    private func handleAuthAction() {
        if isLoginMode {
            loginUser()
        } else {
            createUser()
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)") // Hata mesajını konsola yazdır
                errorMessage = "Failed to login: \(error.localizedDescription)"
                return
            }
            isLoggedIn = true
        }
    }

    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Failed to create account: \(error.localizedDescription)"
                return
            }
            isLoggedIn = true
        }
    }
}


#Preview {
    AuthView()
        .environmentObject(ProfileData())
}
