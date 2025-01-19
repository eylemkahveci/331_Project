//
//  ContentView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

// MARK: - ContentView
/// The main entry point for the app after login.
/// Displays a TabView with different sections: Home, Categories, Shopping Cart, and Profile.
struct ContentView: View {
    @EnvironmentObject var profileData: ProfileData // Shared user profile data
    @StateObject private var productData = ProductData() // Holds product data fetched from Firestore

    var body: some View {
        TabView {
            // Home screen displaying main content
            mainView()
                .tabItem {
                    Image(systemName: "house") // Home icon
                }
            
            // Categories screen showing products grouped by category
            CategoryListView()
                .tabItem {
                    Image(systemName: "list.bullet") // List icon
                }
            
            // Shopping cart screen showing user's selected items
            ShoppingCartView()
                .tabItem {
                    Image(systemName: "cart") // Cart icon
                }
            
            // Profile screen showing user's profile details and logout option
            ProfileView()
                .tabItem {
                    Image(systemName: "person") // Profile icon
                }
        }
        .onAppear {
            productData.fetchProducts() // Fetch product data from Firestore when the view appears
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileData()) // Provide shared profile data for preview
}
