//
//  profileData.swift
//  ACE
//
//  Created by Emre Uğur on 15.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - ProfileData Class
/// Manages user profile data, including fetching and saving to Firestore.
class ProfileData: ObservableObject {
    // MARK: - Published Properties
    /// User profile fields to bind with the UI
    @Published var firstName: String = "John"
    @Published var lastName: String = "Doe"
    @Published var phoneNumber: String = "+1 123 456 7890"
    @Published var email: String = "john.doe@example.com"
    @Published var address: String = "123 Apple Street, Cupertino, CA"

    private var db = Firestore.firestore() // Firestore database reference

    // MARK: - Fetch User Profile
    /// Fetches the user's profile from Firestore and updates the local properties.
    /// - Parameter completion: A closure to indicate success or failure.
    func fetchProfile(completion: @escaping (Bool) -> Void = { _ in }) {
        // Ensure the user is authenticated
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            completion(false) // Notify the caller that fetching failed
            return
        }

        // Fetch the user document from the Firestore `users` collection
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching profile data: \(error.localizedDescription)")
                completion(false) // Notify the caller that fetching failed
                return
            }

            if let document = document, document.exists {
                let data = document.data() // Extract data from the document
                DispatchQueue.main.async {
                    // Update local properties with Firestore data, keeping defaults if fields are missing
                    self?.firstName = data?["firstName"] as? String ?? self?.firstName ?? "John"
                    self?.lastName = data?["lastName"] as? String ?? self?.lastName ?? "Doe"
                    self?.phoneNumber = data?["phoneNumber"] as? String ?? self?.phoneNumber ?? "+1 123 456 7890"
                    self?.email = data?["email"] as? String ?? self?.email ?? "john.doe@example.com"
                    self?.address = data?["address"] as? String ?? self?.address ?? "123 Apple Street, Cupertino, CA"
                }
                completion(true) // Notify the caller that fetching was successful
            } else {
                print("Document does not exist.")
                completion(false) // Notify the caller that fetching failed
            }
        }
    }

    // MARK: - Save User Profile
    /// Saves the user's profile to Firestore.
    /// - Parameter completion: A closure to indicate success or failure.
    func saveToFirestore(completion: @escaping (Bool) -> Void) {
        // Ensure the user is authenticated
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            completion(false) // Notify the caller that saving failed
            return
        }

        // Prepare user data to save
        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "email": email,
            "address": address
        ]

        // Save the user data to Firestore, merging with existing data
        db.collection("users").document(userID).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving profile to Firestore: \(error.localizedDescription)")
                completion(false) // Notify the caller that saving failed
            } else {
                print("Profile saved successfully to Firestore.")
                completion(true) // Notify the caller that saving was successful
            }
        }
    }
}
