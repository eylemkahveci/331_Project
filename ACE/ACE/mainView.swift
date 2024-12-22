//
//  mainView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI

struct mainView: View {
    
    let bestSellers = ["urun1", "urun2", "urun3", "urun4"]
    let recommended = ["urunA", "urunB", "urunC", "urunD"]
    @State private var textForSearch: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    TextField("Search for item", text: $textForSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(5)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Best Sellers")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(bestSellers, id: \.self) { product in
                                    ProductView(productName: product)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 150)
                        
                        Text("Recommended")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(recommended, id: \.self) { product in
                                    ProductView(productName: product)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 150)
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Main")
            .background(Color.white.ignoresSafeArea())
        }
    }
}

struct ProductView: View {
    let productName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 150)
            Text(productName)
                .foregroundColor(.black)
                .font(.caption)
        }
    }
}

#Preview {
    mainView()
}
