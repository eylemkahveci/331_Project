//
//  ACEApp.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseCore

// MARK: - AppDelegate Class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Initialize Firebase
        return true
    }
}

// MARK: - Main App
@main
struct MyApp: App {
    @StateObject private var profileData = ProfileData() // Create a shared instance of ProfileData
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Set AppDelegate for Firebase configuration

    var body: some Scene {
        WindowGroup {
            SplashScreenView() // Set SplashScreenView as the initial view
                .environmentObject(profileData) // Share ProfileData across all views
        }
    }
}
