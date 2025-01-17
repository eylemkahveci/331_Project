//
//  categoryView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore


import SwiftUI

struct CategoryListView: View {
    @StateObject private var productData = ProductData()

    var body: some View {
        NavigationView {
            VStack {
                
                if productData.categorizedProducts.isEmpty {
                    Text("Loading...")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                } else {
                    List(productData.categorizedProducts.keys.sorted(), id: \.self) { category in
                        NavigationLink(
                            destination: ProductListView(category: category, products: productData.categorizedProducts[category] ?? [])
                        ) {
                            Text(category)
                                .font(.headline)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .onAppear {
                productData.fetchProducts()
            }
        }
    }
}
struct ProductListView: View {
    let category: String
    let products: [Product]

    var body: some View {
        VStack {
            if products.isEmpty {
                Text("These is no item in this category.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
            } else {
                List(products) { product in
                    HStack {
                        AsyncImage(url: URL(string: product.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else if phase.error != nil {
                                Color.red // Hata durumunda kırmızı placeholder
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else {
                                Color.gray // Yüklenirken gri placeholder
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text("Price: $\(product.price, specifier: "%.2f")")
                                .font(.subheadline)
                            if product.bestSeller {
                                Text("Best Seller")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(category)
    }
}

