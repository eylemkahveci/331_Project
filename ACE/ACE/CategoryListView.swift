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
                        
                        Button(action: {
                            addToCart(product: product)
                        }) {
                            Text("Add to Cart")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(category)
    }
    
    
    private func addToCart(product: Product) {
        let db = Firestore.firestore()
        let userID = "user_id" // Burada gerçek kullanıcı kimliği kullanılmalı
        
        let cartRef = db.collection("carts").document(userID)
        
        cartRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Eğer sepet zaten varsa, items alanına ürün ekleyelim
                if var items = document.data()?["items"] as? [String: Int] {
                    items[product.id, default: 0] += 1
                    cartRef.updateData([
                        "items": items
                    ]) { error in
                        if let error = error {
                            print("Error updating cart: \(error)")
                        } else {
                            print("Product added to cart successfully!")
                        }
                    }
                }
            } else {
                // Sepet yoksa yeni bir sepet oluştur
                cartRef.setData([
                    "items": [
                        product.id: 1
                    ]
                ]) { error in
                    if let error = error {
                        print("Error creating cart: \(error)")
                    } else {
                        print("New cart created and product added!")
                    }
                }
            }
        }
    }
}
