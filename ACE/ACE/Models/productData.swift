//
//  productData.swift
//  ACE
//
//  Created by Emre Uğur on 16.01.2025.
//

import SwiftUI
import FirebaseFirestore
import Combine

// MARK: - Product Model
/// Represents a single product with its details, conforming to `Identifiable` for use in SwiftUI lists.
struct Product: Identifiable {
    let id: String          // Unique identifier for the product (Firestore document ID)
    let name: String
    let price: Double
    let category: String
    let bestSeller: Bool
    let imageUrl: String
}

// MARK: - ProductData Class
/// Manages product data by fetching and categorizing products from Firestore.
class ProductData: ObservableObject {
    // Published property to store products categorized by their category names
    @Published var categorizedProducts: [String: [Product]] = [:]

    private var db = Firestore.firestore() // Reference to Firestore database

    // MARK: - Fetch Products from Firestore
    /// Fetches products from Firestore and categorizes them based on their `category` field.
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                // Log error if fetching fails
                print("Error fetching products: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                // Log if no documents are found
                print("No documents found.")
                return
            }

            // Process documents and categorize products
            DispatchQueue.main.async {
                var categorized: [String: [Product]] = [:] // Temporary dictionary to hold categorized products

                for document in documents {
                    let data = document.data()
                    // Safely unwrap and validate required fields from Firestore
                    guard
                        let name = data["name"] as? String,
                        let price = data["price"] as? Double,
                        let category = data["category"] as? String,
                        let bestSeller = data["bestSeller"] as? Bool,
                        let imageUrl = data["imageUrl"] as? String
                    else {
                        // Log invalid data and skip the current product
                        print("Invalid product data for document ID \(document.documentID)")
                        continue
                    }

                    // Create a `Product` instance
                    let product = Product(
                        id: document.documentID,
                        name: name,
                        price: price,
                        category: category,
                        bestSeller: bestSeller,
                        imageUrl: imageUrl
                    )

                    // Add the product to the corresponding category
                    if categorized[category] != nil {
                        categorized[category]?.append(product)
                    } else {
                        categorized[category] = [product]
                    }
                }

                // Update the categorized products
                self.categorizedProducts = categorized
            }
        }
    }
}
