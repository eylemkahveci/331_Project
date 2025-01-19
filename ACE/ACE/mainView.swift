//
//  mainView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

// MARK: - mainView
/// Main view displaying categorized products, a search bar, and a filter for products.
struct mainView: View {
    @StateObject private var productData = ProductData() // Holds product data fetched from Firestore
    @State private var textForSearch: String = "" // Text input for the search bar
    @State private var filteredProducts: [Product] = [] // Filtered products based on search query

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    TextField("Search for item", text: $textForSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Styled as a rounded text field
                        .padding(.horizontal)
                        .padding(5)
                        .onChange(of: textForSearch) { // Updates filtered products when search text changes
                            filterProducts()
                        }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // If search bar is empty, show categorized products
                        if textForSearch.isEmpty {
                            // Best Sellers Section
                            Text("Best Sellers")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    // Display products marked as best sellers
                                    ForEach(productData.categorizedProducts.flatMap { $0.value }, id: \.id) { product in
                                        if product.bestSeller {
                                            ProductView(product: product)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 150)
                            
                            // Recommended Products Section
                            Text("Recommended")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    // Display products that are not marked as best sellers
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
                            // Display search results
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
            .navigationTitle("Main") // Title for the navigation bar
            .background(Color.white.ignoresSafeArea()) // Background color
            .onAppear {
                productData.fetchProducts() // Fetch product data from Firestore on view load
            }
        }
    }

    // MARK: - Filter Products
    /// Filters products based on the search text.
    private func filterProducts() {
        let allProducts = productData.categorizedProducts.flatMap { $0.value } // Get all products
        if textForSearch.isEmpty {
            filteredProducts = [] // If search is empty, show no filtered products
        } else {
            // Filter products by name, ignoring case sensitivity
            filteredProducts = allProducts.filter { product in
                product.name.localizedCaseInsensitiveContains(textForSearch)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    mainView()
}
