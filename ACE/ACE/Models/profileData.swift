//
//  profileData.swift
//  ACE
//
//  Created by Emre Uğur on 15.01.2025.
//

import SwiftUI
import Combine

class ProfileData: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var phoneNumber: String
    @Published var email: String
    @Published var address: String

    init() {
        self.firstName = UserDefaults.standard.string(forKey: "firstName") ?? "John"
        self.lastName = UserDefaults.standard.string(forKey: "lastName") ?? "Doe"
        self.phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") ?? "+1 123 456 7890"
        self.email = UserDefaults.standard.string(forKey: "email") ?? "john.doe@example.com"
        self.address = UserDefaults.standard.string(forKey: "address") ?? "123 Apple Street, Cupertino, CA"
    }

    func saveProfile() {
        UserDefaults.standard.set(firstName, forKey: "firstName")
        UserDefaults.standard.set(lastName, forKey: "lastName")
        UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(address, forKey: "address")
    }
}
