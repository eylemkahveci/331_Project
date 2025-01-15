//
//  ACEApp.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct MyApp: App {
    @StateObject private var profileData = ProfileData() // ProfileData oluşturuluyor
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene{
        WindowGroup {
            SplashScreenView()
                .environmentObject(profileData) // Tüm görünümlerle paylaşılacak
        }
    }
}
