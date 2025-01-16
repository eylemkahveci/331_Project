//
//  profileData.swift
//  ACE
//
//  Created by Emre Uğur on 15.01.2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileData: ObservableObject {
    @Published var firstName: String = "John"
    @Published var lastName: String = "Doe"
    @Published var phoneNumber: String = "+1 123 456 7890"
    @Published var email: String = "john.doe@example.com"
    @Published var address: String = "123 Apple Street, Cupertino, CA"

    private var db = Firestore.firestore()

    
    func fetchProfile(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            completion(false)
            return
        }

        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching profile data: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self?.firstName = data?["firstName"] as? String ?? self?.firstName ?? "John"
                    self?.lastName = data?["lastName"] as? String ?? self?.lastName ?? "Doe"
                    self?.phoneNumber = data?["phoneNumber"] as? String ?? self?.phoneNumber ?? "+1 123 456 7890"
                    self?.email = data?["email"] as? String ?? self?.email ?? "john.doe@example.com"
                    self?.address = data?["address"] as? String ?? self?.address ?? "123 Apple Street, Cupertino, CA"
                }
                completion(true)
            } else {
                print("Document does not exist.")
                completion(false)
            }
        }
    }

    // Firestore'a kullanıcı verilerini kaydet
    func saveToFirestore(completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            completion(false)
            return
        }

        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "phoneNumber": phoneNumber,
            "email": email,
            "address": address
        ]

        db.collection("users").document(userID).setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving profile to Firestore: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Profile saved successfully to Firestore.")
                completion(true)
            }
        }
    }
}
