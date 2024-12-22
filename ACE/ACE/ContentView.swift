//
//  ContentView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
            TabView{
                mainView()
                    .tabItem { Image(systemName: "house") }
                CategoryListView(categories: sampleCategories)
                    .tabItem { Image(systemName: "list.bullet") }
            }
    }
}

#Preview {
    ContentView()
}
