//
//  productData.swift
//  ACE
//
//  Created by Emre Uğur on 16.01.2025.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct Product: Identifiable {
    let id: String
    let name: String
    let price: Double
    let category: String
    let bestSeller: Bool
    let imageUrl: String  // Fotoğraf URL'si ekleniyor
}

class ProductData: ObservableObject {
    @Published var categorizedProducts: [String: [Product]] = [:] // Kategorilere göre ürünler

    private var db = Firestore.firestore()

    
    // Firestore'dan ürünleri çek ve kategorilere ayır
    func fetchProducts() {
        db.collection("products").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            

            // Firestore'dan gelen belgeleri işleyip kategorilere ayır
            DispatchQueue.main.async {
                var categorized: [String: [Product]] = [:]

                for document in documents {
                    let data = document.data()
                    guard
                        let name = data["name"] as? String,
                        let price = data["price"] as? Double,
                        let category = data["category"] as? String,
                        let bestSeller = data["bestSeller"] as? Bool,
                        let imageUrl = data["imageUrl"] as? String // Yeni alan
                    else {
                        print("Invalid product data for document ID \(document.documentID)")
                        continue
                    }

                    // Ürünü oluştur
                    let product = Product(
                        id: document.documentID,
                        name: name,
                        price: price,
                        category: category,
                        bestSeller: bestSeller,
                        imageUrl: imageUrl // Fotoğraf URL'sini ekliyoruz
                    )

                    // Ürünü ilgili kategoriye ekle
                    if categorized[category] != nil {
                        categorized[category]?.append(product)
                    } else {
                        categorized[category] = [product]
                    }
                }

                // Kategorilere ayrılmış ürünleri güncelle
                self.categorizedProducts = categorized
            }
        }
    }
}
