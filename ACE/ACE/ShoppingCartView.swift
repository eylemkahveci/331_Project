//
//  ShoppingCartView.swift
//  ACE
//
//  Created by Emre Uğur on 17.12.2024.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Model for CartItem
/// Represents an item in the shopping cart.
struct CartItem: Identifiable {
    var id: String // Unique identifier
    let name: String // Product name
    let price: Double // Product price
    var quantity: Int // Quantity of the product in the cart
    let imageUrl: String // URL for the product image
}

// MARK: - ShoppingCartView
/// Displays the shopping cart and allows users to manage their items.
struct ShoppingCartView: View {
    @State private var cartItems: [CartItem] = [] // Items in the cart
    @State private var total: Double = 0.0 // Total price of the cart
    @State private var showAlert: Bool = false // Tracks if the remove item alert is shown
    @State private var selectedItemForRemoval: CartItem? // Tracks the item to be removed

    var body: some View {
        NavigationView {
            VStack {
                if cartItems.isEmpty {
                    // MARK: - Empty Cart View
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
                    // MARK: - Cart Items Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach($cartItems) { $item in
                                // Individual product card
                                VStack(spacing: 8) {
                                    // AsyncImage for product image
                                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            Color.gray.opacity(0.3)
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        case .failure:
                                            Color.red
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        @unknown default:
                                            Color.gray.opacity(0.3)
                                                .frame(height: 120)
                                                .cornerRadius(10)
                                        }
                                    }

                                    // Product name
                                    Text(item.name)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)

                                    // Quantity controls
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

                                    // Product price
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

                    // MARK: - Total and Checkout
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

                        // Checkout Button
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
                loadCart() // Load cart items when the view appears
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

    // MARK: - Load Cart Items
    /// Fetches cart items from Firestore and updates the local state.
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

                for (productID, quantity) in items where quantity > 0 {
                    db.collection("products").document(productID).getDocument { productDoc, error in
                        if let productDoc = productDoc, productDoc.exists,
                           let productData = productDoc.data() {
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

    // MARK: - Calculate Total
    /// Calculates the total price of items in the cart.
    func calculateTotal() {
        total = cartItems.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
    }

    // MARK: - Reduce Quantity
    /// Decreases the quantity of an item in the cart.
    func reduceQuantity(for item: Binding<CartItem>) {
        if item.wrappedValue.quantity > 1 {
            item.wrappedValue.quantity -= 1
            updateCart(item: item.wrappedValue)
        } else {
            selectedItemForRemoval = item.wrappedValue
            showAlert = true
        }
    }

    // MARK: - Remove Item
    /// Removes an item from the cart and updates Firestore.
    func removeItem(_ item: CartItem) {
        let db = Firestore.firestore()
        let userID = "user_id"
        let cartRef = db.collection("carts").document(userID)

        cartRef.updateData([
            "items.\(item.id)": 0
        ]) { error in
            if let error = error {
                print("Error removing item from Firestore: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.cartItems.removeAll { $0.id == item.id }
                    self.calculateTotal()
                }
            }
        }
    }

    // MARK: - Increase Quantity
    /// Increases the quantity of an item in the cart.
    func increaseQuantity(for item: Binding<CartItem>) {
        if item.wrappedValue.quantity < 10 {
            item.wrappedValue.quantity += 1
            updateCart(item: item.wrappedValue)
        }
    }

    // MARK: - Update Cart
    /// Updates the cart in Firestore.
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

    // MARK: - Checkout
    /// Handles the checkout action.
    func checkoutTapped() {
        print("Checkout Confirmed with total: \(total)$")
    }
}

// MARK: - Preview
struct ShoppingCartView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCartView()
    }
}
