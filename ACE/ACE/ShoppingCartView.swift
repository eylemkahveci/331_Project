//
//  ShoppingCartView.swift
//  ACE
//
//  Created by Emre Uğur on 17.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct CartItem: Identifiable {
    var id: String
    let name: String
    let price: Int
    var quantity: Int
    let imageUrl: String
}

struct ShoppingCartView: View {
    @State private var cartItems: [CartItem] = []
    @State private var total: Int = 0
    @State private var showAlert: Bool = false
    @State private var selectedItemForRemoval: CartItem?
    
    var body: some View {
        NavigationView {
            VStack {
                if cartItems.isEmpty {
                    VStack {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        Text("Your cart is empty")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach($cartItems) { $item in
                                VStack(spacing: 8) {
                                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        } else if phase.error != nil {
                                            Color.red
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        } else {
                                            Color.gray.opacity(0.3)
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        }
                                    }
                                    
                                    Text(item.name)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    
                                    HStack {
                                        Button(action: {
                                            reduceQuantity(for: $item)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title2)
                                        }
                                        
                                        Text("\(item.quantity)")
                                            .font(.title3)
                                            .frame(width: 40)
                                        
                                        Button(action: {
                                            increaseQuantity(for: $item)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.title2)
                                        }
                                    }
                                    
                                    Text("$\(item.price * item.quantity)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                        .padding()
                    }
                    
                    VStack {
                        HStack {
                            Text("Total:")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("$\(total)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        
                        Button(action: checkoutTapped) {
                            Text("Checkout Now")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Shopping Cart")
            .onAppear {
                loadCart()
            }.alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Remove Item"),
                    message: Text("Are you sure you want to remove \(selectedItemForRemoval?.name ?? "this item") from the cart?"),
                    primaryButton: .destructive(Text("Yes")) {
                        if let item = selectedItemForRemoval {
                            removeItem(item)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // MARK: - Functions
    
    func loadCart() {
        let db = Firestore.firestore()
        let userID = "user_id"
        let cartRef = db.collection("carts").document(userID)
        
        cartRef.getDocument { document, error in
            if let error = error {
                print("Error fetching cart: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("No cart data found.")
                return
            }
            
            if let items = document.data()?["items"] as? [String: Int] {
                var fetchedItems: [CartItem] = []
                
                for (productID, quantity) in items {
                    db.collection("products").document(productID).getDocument { productDoc, error in
                        if let productDoc = productDoc, productDoc.exists {
                            if let productData = productDoc.data() {
                                let name = productData["name"] as? String ?? "Unknown Product"
                                let price = productData["price"] as? Int ?? 0
                                let imageUrl = productData["imageUrl"] as? String ?? ""
                                
                                let cartItem = CartItem(id: productID, name: name, price: price, quantity: quantity, imageUrl: imageUrl)
                                fetchedItems.append(cartItem)
                                
                                if fetchedItems.count == items.count {
                                    self.cartItems = fetchedItems
                                    calculateTotal()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func calculateTotal() {
        total = cartItems.reduce(0) { $0 + $1.price * $1.quantity }
    }
    
    func reduceQuantity(for item: Binding<CartItem>) {
        if item.wrappedValue.quantity > 1 {
            // Miktar 1'den fazla ise azalt
            item.wrappedValue.quantity -= 1
            updateCart(item: item.wrappedValue)
        } else {
            // Miktar 1 ise uyarı göster
            selectedItemForRemoval = item.wrappedValue
            showAlert = true
        }
    }

    // Ürünü sepetten kaldırma
    func removeItem(_ item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
        updateCart(item: item) // Firestore'u güncelle
    }
    
    func increaseQuantity(for item: Binding<CartItem>) {
        if item.wrappedValue.quantity < 10 {
            item.wrappedValue.quantity += 1
            updateCart(item: item.wrappedValue)
        }
    }
    
    func updateCart(item: CartItem) {
        let db = Firestore.firestore()
        let userID = "user_id"
        let cartRef = db.collection("carts").document(userID)
        
        cartRef.updateData([
            "items.\(item.id)": item.quantity
        ]) { error in
            if let error = error {
                print("Error updating cart: \(error.localizedDescription)")
            } else {
                print("Cart updated successfully!")
                if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
                    cartItems[index] = item
                    calculateTotal()
                }
            }
        }
    }
    
    func checkoutTapped() {
        print("Checkout Confirmed with total: \(total)$")
    }
}

// Preview
struct ShoppingCartView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartView()
    }
}
