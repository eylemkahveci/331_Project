//
//  ContentView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    
    @EnvironmentObject var profileData: ProfileData
    @StateObject private var productData = ProductData()  // Ürün verisi

    var body: some View {
        TabView {
            mainView()
                .tabItem { Image(systemName: "house") }
            
            // Kategoriler ekranını Firebase'den çekilen ürün verisi ile güncelledik
            CategoryListView()
                .tabItem { Image(systemName: "list.bullet") }
            
            ShoppingCartView()
                .tabItem{ Image(systemName: "cart") }
            
            ProfileView()
                .tabItem{ Image(systemName: "person")}
        }
        .onAppear {
            productData.fetchProducts() // Ürünleri Firebase'den çekmeye başla
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileData()) // Tüm alt görünümler için sağlanıyor
}
