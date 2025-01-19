//
//  AuthView.swift
//  ACE
//
//  Created by Emre Uğur on 15.01.2025.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
    // MARK: - Properties
    @State private var email = "" // User's email input
    @State private var password = "" // User's password input
    @State private var isLoginMode = true // Toggle between Login and Sign Up modes
    @State private var errorMessage = "" // Display error messages
    @State private var isLoggedIn = false // Track login status
    @EnvironmentObject var profileData: ProfileData // Shared profile data for user information

    // MARK: - Body
    var body: some View {
        if isLoggedIn {
            ContentView() // Navigate to the main content view when logged in
        } else {
            NavigationStack {
                VStack(spacing: 16) {
                    // Title indicating the current mode
                    Text(isLoginMode ? "Login" : "Create Account")
                        .font(.largeTitle)
                        .bold()

                    // Email Input Field
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Password Input Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Error Message Display
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    // Authentication Button (Login or Sign Up)
                    Button(action: handleAuthAction) {
                        Text(isLoginMode ? "Login" : "Create Account")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // Reset Password Button (only in Login mode)
                    if isLoginMode {
                        Button(action: resetPassword) {
                            Text("Forgot your password?")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }

                    // Toggle between Login and Sign Up modes
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
                .navigationTitle("Authentication") // Navigation title for the view
            }
        }
    }

    // MARK: - Handle Authentication
    private func handleAuthAction() {
        if isLoginMode {
            loginUser() // Perform login action
        } else {
            createUser() // Perform account creation action
        }
    }

    // MARK: - Login User
    private func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                self.errorMessage = "Failed to login: \(error.localizedDescription)"
                return
            }

            // Successfully logged in
            self.isLoggedIn = true
            self.profileData.fetchProfile() // Fetch user profile from Firestore
        }
    }
    
    // MARK: - Create New User
    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Failed to create account: \(error.localizedDescription)"
                return
            }

            // Successfully created a new account
            self.isLoggedIn = true
        }
    }
    
    // MARK: - Reset Password
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

            // Successfully sent reset email
            self.errorMessage = "A password reset email has been sent to \(email)."
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(ProfileData()) // Provide the environment object for preview
}

