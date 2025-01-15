//
//  RegisterView.swift
//  ACE
//
//  Created by Emre Uğur on 16.01.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var birthDate = Date()
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.phonePad)

            Button(action: registerUser) {
                Text("Register")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .navigationTitle("Register")
    }

    // Kullanıcı Kaydı ve Firestore'a Yazma
    private func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                return
            }

            // Kullanıcının UID'sini al
            guard let userID = result?.user.uid else { return }

            // Firestore'a ek bilgiler yaz
            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "phoneNumber": phoneNumber,
                "birthDate": Timestamp(date: birthDate) // Tarihi Firestore Timestamp olarak sakla
            ]

            let db = Firestore.firestore()
            db.collection("users").document(userID).setData(userData) { error in
                if let error = error {
                    errorMessage = "Failed to save user data: \(error.localizedDescription)"
                } else {
                    errorMessage = "User registered successfully!"
                }
            }
        }
    }
}

#Preview {
    RegistrationView()
}
