//
//  EditProfileView.swift
//  ACE
//
//  Created by Emre Uğur on 23.12.2024.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var profileData: ProfileData
    @State private var showAlert: Bool = false

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                TextField("First Name", text: $profileData.firstName)
                TextField("Last Name", text: $profileData.lastName)
            }

            Section(header: Text("Contact Details")) {
                TextField("Phone Number", text: $profileData.phoneNumber)
                    .keyboardType(.phonePad)
                TextField("Email", text: $profileData.email)
                    .keyboardType(.emailAddress)
            }

            Section(header: Text("Address")) {
                TextField("Address", text: $profileData.address)
            }

            Section {
                Button(action: saveProfile) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"), message: Text("Profile saved successfully."), dismissButton: .default(Text("OK")))
        }
    }

    private func saveProfile() {
        profileData.saveProfile()
        showAlert = true
    }
}

#Preview {
    EditProfileView()
        .environmentObject(ProfileData())
}
