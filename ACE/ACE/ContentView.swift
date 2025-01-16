//
//  ContentView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI


struct ContentView: View {
    
    @EnvironmentObject var profileData: ProfileData
    
    var body: some View {
        TabView{
            mainView()
                .tabItem { Image(systemName: "house") }
            CategoryListView(categories: sampleCategories)
                .tabItem { Image(systemName: "list.bullet") }
            ShoppingCartView()
                .tabItem{ Image(systemName: "cart") }
            ProfileView()
                .tabItem{ Image(systemName: "person")}
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileData()) // Tüm alt görünümler için sağlanıyor
}
