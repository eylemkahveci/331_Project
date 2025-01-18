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

                    if isLoginMode {
                        Button(action: resetPassword) {
                            Text("Forgot your password?")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }

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
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self.errorMessage = "Failed to login: \(error.localizedDescription)"
                return
            }

            self.isLoggedIn = true
            self.profileData.fetchProfile()
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
    
    private func resetPassword() {
        guard !email.isEmpty else {
            self.errorMessage = "Please enter your email address to reset your password."
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Reset password error: \(error.localizedDescription)")
                self.errorMessage = "Failed to send password reset email: \(error.localizedDescription)"
                return
            }

            self.errorMessage = "A password reset email has been sent to \(email)."
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(ProfileData())
}

