//
//  mainView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct mainView: View {
    @StateObject private var productData = ProductData()  // Ürün verileri
    @State private var textForSearch: String = ""  // Arama kutusu için metin
    @State private var filteredProducts: [Product] = []  // Filtrelenmiş ürünler

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Arama Kutusu
                HStack {
                    TextField("Search for item", text: $textForSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(5)
                        .onChange(of: textForSearch) {
                            filterProducts()
                        }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Eğer arama kutusu boşsa tüm ürünler gösterilir
                        if textForSearch.isEmpty {
                            // Best Sellers
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
                            
                            // Recommended
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
                        } else {
                            // Arama sonuçları
                            Text("Search Results")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(filteredProducts, id: \.id) { product in
                                    ProductView(product: product)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Main")
            .background(Color.white.ignoresSafeArea())
            .onAppear {
                productData.fetchProducts()  // Ürünleri getir
            }
        }
    }

    // MARK: - Ürünleri Filtreleme Fonksiyonu
    private func filterProducts() {
        let allProducts = productData.categorizedProducts.flatMap { $0.value }
        if textForSearch.isEmpty {
            filteredProducts = []
        } else {
            filteredProducts = allProducts.filter { product in
                product.name.localizedCaseInsensitiveContains(textForSearch)
            }
        }
    }
}


// Preview
#Preview {
    mainView()
}
