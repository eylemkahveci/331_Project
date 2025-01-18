//
//  ProfileView.swift
//  ACE
//
//  Created by Emre Uğur on 23.12.2024.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var profileData: ProfileData
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditingProfile: Bool = false
    @State private var showLogoutConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
                    .padding(.top, 20)

                Text("\(profileData.firstName) \(profileData.lastName)")
                    .font(.title)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "envelope.fill").foregroundColor(.blue)
                        Text(profileData.email)
                    }
                    HStack {
                        Image(systemName: "phone.fill").foregroundColor(.green)
                        Text(profileData.phoneNumber)
                    }
                    HStack {
                        Image(systemName: "house.fill").foregroundColor(.orange)
                        Text(profileData.address)
                            .lineLimit(2)
                    }
                }
                .font(.body)
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    isEditingProfile = true
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isEditingProfile) {
                EditProfileView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                profileData.fetchProfile() // Firestore'dan verileri çek
            }
            .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    logOut()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Logout Function
    private func logOut() {
        do {
            try Auth.auth().signOut()
            
            // Kullanıcı çıkış yapınca AuthView'a dön
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let window = windowScene.windows.first {
                    window.rootViewController = UIHostingController(rootView: AuthView().environmentObject(ProfileData()))
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileData())
}
