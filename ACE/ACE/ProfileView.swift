//
//  ProfileView.swift
//  ACE
//
//  Created by Emre Uğur on 23.12.2024.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

/// Displays the user's profile information and allows editing or logging out.
struct ProfileView: View {
    @EnvironmentObject var profileData: ProfileData // Shared profile data object
    @Environment(\.presentationMode) var presentationMode // Manages presentation mode for navigation
    @State private var isEditingProfile: Bool = false // Tracks if the user is editing their profile
    @State private var showLogoutConfirmation: Bool = false // Tracks if the logout confirmation alert is displayed

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Profile Image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .padding(.top, 20)

                // MARK: - User's Name
                Text("\(profileData.firstName) \(profileData.lastName)")
                    .font(.title)
                    .fontWeight(.bold)

                // MARK: - User Details
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                        Text(profileData.email)
                    }
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                        Text(profileData.phoneNumber)
                    }
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.orange)
                        Text(profileData.address)
                            .lineLimit(2) // Limits the address text to two lines
                    }
                }
                .font(.body)
                .padding(.horizontal)

                Spacer()

                // MARK: - Edit Profile Button
                Button(action: {
                    isEditingProfile = true // Opens the edit profile view
                }) {
                    Text("Edit Profile")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline) // Displays the title in a compact inline style
            .navigationDestination(isPresented: $isEditingProfile) {
                EditProfileView() // Navigates to the EditProfileView when editing is enabled
            }
            .toolbar {
                // MARK: - Logout Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLogoutConfirmation = true // Shows the logout confirmation alert
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red) // Red icon to indicate logout
                    }
                }
            }
            .onAppear {
                profileData.fetchProfile() // Fetches the user's profile data from Firestore
            }
            .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                // Logout confirmation alert
                Button("Log Out", role: .destructive) {
                    logOut() // Logs the user out
                }
                Button("Cancel", role: .cancel) {} // Dismisses the alert
            }
        }
    }

    // MARK: - Logout Function
    /// Logs the user out and redirects to the AuthView.
    private func logOut() {
        do {
            try Auth.auth().signOut() // Logs the user out from Firebase
            
            // Redirects to the AuthView
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: AuthView().environmentObject(ProfileData()))
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            print("Error logging out: \(error.localizedDescription)") // Prints the error if logout fails
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environmentObject(ProfileData()) // Provides the shared profile data object for the preview
}
