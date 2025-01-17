//
//  mainView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct mainView: View {
    
    @StateObject private var productData = ProductData()  // ProductData'yı burada kullanıyoruz
    
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
                                ForEach(productData.categorizedProducts.flatMap { $0.value }, id: \.id) { product in
                                    if product.bestSeller {
                                        ProductView(product: product)
                                    }
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
                                ForEach(productData.categorizedProducts.flatMap { $0.value }, id: \.id) { product in
                                    if !product.bestSeller {
                                        ProductView(product: product)
                                    }
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
            .onAppear {
                productData.fetchProducts()  // Verileri almak için fonksiyonu çağırıyoruz
            }
        }
    }
}


#Preview {
    mainView()
}
