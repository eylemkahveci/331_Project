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
    @State private var isEditingProfile: Bool = false

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
            .navigationDestination(isPresented: $isEditingProfile) {
                EditProfileView()
            }
            .onAppear {
                profileData.fetchProfile() // Firestore'dan verileri çek
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileData())
}
