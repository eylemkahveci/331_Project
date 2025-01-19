//
//  ProductView.swift
//  ACE
//
//  Created by Ceyda Çendekçi on 17.01.2025.
//

import Firebase
import SwiftUI

/// Represents a view displaying individual product details.
struct ProductView: View {
    let product: Product // The product to display
    @State private var cartItems: [CartItem] = [] // Tracks items added to the cart

    var body: some View {
        ZStack {
            // MARK: - Product Image
            /// Displays the product image with placeholder states for loading and failure.
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3) // Placeholder for loading state
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                case .failure:
                    Color.red // Placeholder for error state
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                @unknown default:
                    Color.gray.opacity(0.3) // Fallback for unknown states
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                }
            }
            
            // MARK: - Price Label
            /// Displays the product price in a box at the top-right corner.
            VStack {
                HStack {
                    Spacer()
                    Text("$\(product.price, specifier: "%.2f")") // Formats price to two decimal places
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.6)) // Semi-transparent background
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .frame(width: 120, height: 150)
            
            // MARK: - Add to Cart Button
            /// Button to add the product to the cart, positioned at the bottom-right corner.
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        addToCart(product: product) // Calls the function to add the product to the cart
                    }) {
                        Image(systemName: "cart.badge.plus") // Icon for the cart button
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7)) // Semi-transparent background
                            .cornerRadius(12)
                    }
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
        }
        .frame(width: 120, height: 180) // Sets the size of the product view
        .cornerRadius(12)
    }
    
    // MARK: - Add to Cart Function
    /// Adds the product to the user's cart in Firestore.
    private func addToCart(product: Product) {
        let db = Firestore.firestore()
        let userID = "user_id" // Replace with the actual user ID

        let cartRef = db.collection("carts").document(userID)
        
        cartRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // If the cart already exists, add or update the product quantity
                if var items = document.data()?["items"] as? [String: Int] {
                    items[product.id, default: 0] += 1 // Increment the quantity
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
                // If the cart doesn't exist, create a new cart with the product
                cartRef.setData([
                    "items": [
                        product.id: 1 // Set the initial quantity to 1
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


