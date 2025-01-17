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
    @EnvironmentObject var profileData: ProfileData

    var body: some View {
        if isLoggedIn {
            ContentView() // Giriş başarılıysa ana ekran
        } else {
            NavigationStack {
                VStack(spacing: 16) {
                    Text(isLoginMode ? "Login" : "Create Account")
                        .font(.largeTitle)
                        .bold()

                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: handleAuthAction) {
                        Text(isLoginMode ? "Login" : "Create Account")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

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

    private func handleAuthAction() {
        if isLoginMode {
            loginUser()
        } else {
            createUser()
        }
    }

    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            // `self` burada bir struct olduğundan doğrudan kullanabilirsiniz.
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self.errorMessage = "Failed to login: \(error.localizedDescription)"
                return
            }

            // Oturum açma başarılı
            self.isLoggedIn = true

            // Kullanıcı verilerini Firestore'dan çek
            self.profileData.fetchProfile()

            // Kullanıcı verilerini Firestore'da güncelle
        }
    }
    
    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Failed to create account: \(error.localizedDescription)"
                return
            }
            self.isLoggedIn = true
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(ProfileData())
}

