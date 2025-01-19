//
//  EditProfileView.swift
//  ACE
//
//  Created by Emre Uğur on 23.12.2024.
//

import SwiftUI

// MARK: - EditProfileView
/// View for editing the user's profile information.
struct EditProfileView: View {
    @EnvironmentObject var profileData: ProfileData // Shared profile data object
    @State private var showAlert: Bool = false // Controls the visibility of the success alert

    var body: some View {
        Form {
            // Section for personal information
            Section(header: Text("Personal Information")) {
                TextField("First Name", text: $profileData.firstName) // Input for first name
                TextField("Last Name", text: $profileData.lastName) // Input for last name
            }

            // Section for contact details
            Section(header: Text("Contact Details")) {
                TextField("Phone Number", text: $profileData.phoneNumber)
                    .keyboardType(.phonePad) // Numeric keyboard for phone number
                TextField("Email", text: $profileData.email)
                    .keyboardType(.emailAddress) // Email keyboard for email address
            }

            // Section for address
            Section(header: Text("Address")) {
                TextField("Address", text: $profileData.address) // Input for address
            }

            // Save button section
            Section {
                Button(action: saveProfile) {
                    Text("Save")
                        .frame(maxWidth: .infinity) // Makes the button stretch to fill the row
                        .padding()
                        .background(Color.blue) // Button background color
                        .foregroundColor(.white) // Button text color
                        .cornerRadius(8) // Rounded corners for the button
                }
            }
        }
        .navigationTitle("Edit Profile") // Sets the title for the navigation bar
        .alert(isPresented: $showAlert) {
            // Success alert after saving the profile
            Alert(
                title: Text("Success"),
                message: Text("Profile saved successfully."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Save Profile
    /// Saves the user's profile data to Firestore and displays a success alert if successful.
    private func saveProfile() {
        profileData.saveToFirestore { success in
            if success {
                showAlert = true // Show success alert
            } else {
                print("Failed to save profile.") // Log failure message
            }
        }
    }
}

// MARK: - Preview
#Preview {
    EditProfileView()
        .environmentObject(ProfileData()) // Provides ProfileData for the preview
}
