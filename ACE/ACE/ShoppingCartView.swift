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
    let price: Double
    var quantity: Int
    let imageUrl: String
}

struct ShoppingCartView: View {
    @State private var cartItems: [CartItem] = []
    @State private var total: Double = 0.0
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
                                    
                                    Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
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
                            
                            Text("$\(total, specifier: "%.2f")")
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
            }
            .alert(isPresented: $showAlert) {
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
                    if quantity > 0 { // Eğer ürün miktarı 0'dan büyükse işlem yap
                        db.collection("products").document(productID).getDocument { productDoc, error in
                            if let productDoc = productDoc, productDoc.exists {
                                if let productData = productDoc.data() {
                                    let name = productData["name"] as? String ?? "Unknown Product"
                                    let price = productData["price"] as? Double ?? 0.0
                                    let imageUrl = productData["imageUrl"] as? String ?? ""
                                    
                                    let cartItem = CartItem(id: productID, name: name, price: price, quantity: quantity, imageUrl: imageUrl)
                                    fetchedItems.append(cartItem)
                                    
                                    if fetchedItems.count == items.filter({ $0.value > 0 }).count {
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
    }
    
    func calculateTotal() {
        total = cartItems.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
    }
    
    func reduceQuantity(for item: Binding<CartItem>) {
        if item.wrappedValue.quantity > 1 {
            // Miktar 1'den fazla ise miktarı azalt ve güncelle
            item.wrappedValue.quantity -= 1
            updateCart(item: item.wrappedValue)
        } else {
            // Miktar 1 ise uyarıyı göster ve Firestore'daki miktarı sıfırla
            selectedItemForRemoval = item.wrappedValue
            showAlert = true
        }
    }

    func removeItem(_ item: CartItem) {
        let db = Firestore.firestore()
        let userID = "user_id"
        let cartRef = db.collection("carts").document(userID)
        
        // Firestore'daki miktarı 0 yap
        cartRef.updateData([
            "items.\(item.id)": 0
        ]) { error in
            if let error = error {
                print("Error updating quantity to 0 in Firestore: \(error.localizedDescription)")
            } else {
                print("Item quantity updated to 0 in Firestore")
                
                // Yerel `cartItems` dizisinden kaldır
                DispatchQueue.main.async {
                    self.cartItems.removeAll { $0.id == item.id }
                    self.calculateTotal() // Toplamı yeniden hesapla
                }
            }
        }
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
