//
//  ProductListView.swift
//  ACE
//
//  Created by Emre Uğur on 16.01.2025.
//

import SwiftUI

import SwiftUI

struct ProductListView: View {
    @StateObject private var productData = ProductData()

    var body: some View {
        NavigationView {
            List {
                ForEach(productData.categorizedProducts.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category).font(.headline)) {
                        ForEach(productData.categorizedProducts[category] ?? []) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
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
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Products by Category")
            .onAppear {
                productData.fetchProducts()
            }
        }
    }
}

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        VStack(spacing: 20) {
            Text(product.name)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Price: $\(product.price, specifier: "%.2f")")
                .font(.title2)

            Text("Category: \(product.category)")
                .font(.headline)
                .foregroundColor(.secondary)

            if product.bestSeller {
                Text("Best Seller")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProductListView()
}
