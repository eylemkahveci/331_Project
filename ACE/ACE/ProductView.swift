//
//  ProductView.swift
//  ACE
//
//  Created by Ceyda Çendekçi on 17.01.2025.
//

import Firebase
import SwiftUI

struct ProductView: View {
    let product: Product
    @State private var cartItems: [CartItem] = []

    var body: some View {
        ZStack {
            // Resmi ekleyelim
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                case .failure:
                    Color.red
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                @unknown default:
                    Color.gray.opacity(0.3)
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                }
            }
            
            // Fiyatı kutu içinde göstermek
            VStack {
                HStack {
                    Spacer()
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .frame(width: 120, height: 150)
            
            // Sepete Ekle Butonu
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        addToCart(product: product)
                    }) {
                        Image(systemName: "cart.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                    }
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
        }
        .frame(width: 120, height: 180)
        .cornerRadius(12)
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
