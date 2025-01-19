//
//  categoryView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

// MARK: - CategoryListView
// Displays a list of product categories fetched from Firestore.
struct CategoryListView: View {
    @StateObject private var productData = ProductData() // Holds the categorized product data.

    var body: some View {
        NavigationView {
            VStack {
                // Show loading state until categories are loaded.
                if productData.categorizedProducts.isEmpty {
                    Text("Loading...")
                        .foregroundColor(.gray)
                        .font(.headline)
                        .padding()
                } else {
                    // List of categories with navigation links to ProductListView.
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
            .navigationTitle("Categories") // Set navigation title.
            .onAppear {
                productData.fetchProducts() // Fetch product data on view appear.
            }
        }
    }
}

// MARK: - ProductListView
// Displays a list of products in a selected category.
struct ProductListView: View {
    let category: String // The selected category name.
    let products: [Product] // Products belonging to the selected category.

    var body: some View {
        VStack {
            // If no products exist in the category, display a placeholder message.
            if products.isEmpty {
                Text("There are no items in this category.")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding()
            } else {
                // List of products with add-to-cart functionality.
                List(products) { product in
                    HStack {
                        // Product image with AsyncImage.
                        AsyncImage(url: URL(string: product.imageUrl)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else if phase.error != nil {
                                Color.red // Placeholder for error.
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            } else {
                                Color.gray // Placeholder while loading.
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            }
                        }

                        // Product details: name, price, and bestseller tag.
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
                        
                        // Add to Cart Button
                        Button(action: {
                            addToCart(product: product) // Add product to cart.
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
        .navigationTitle(category) // Set the navigation title to the category name.
    }
    
    // MARK: - Add to Cart Function
    // Adds a product to the user's cart in Firestore.
    private func addToCart(product: Product) {
        let db = Firestore.firestore()
        let userID = "user_id" // Replace with actual user ID.
        
        let cartRef = db.collection("carts").document(userID)
        
        cartRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // If the cart exists, update the items.
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
                // If no cart exists, create a new cart with the product.
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
