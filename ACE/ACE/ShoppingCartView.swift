//
//  ShoppingCartView.swift
//  ACE
//
//  Created by Emre Uğur on 17.12.2024.
//

import SwiftUI

struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Int
    var quantity: Int
}

struct ShoppingCartView: View {
    // MARK: - Properties
    @State private var cartItems: [CartItem] = []
    @State private var total: Int = 0
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                // List for cart items
                List {
                    ForEach($cartItems) { $item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            HStack {
                                Button(action: {
                                    if item.quantity > 1 {
                                        item.quantity -= 1
                                        calculateTotal()
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                                
                                Text("\(item.quantity)")
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    if item.quantity < 10 { // Set maximum quantity to 10 for example
                                        item.quantity += 1
                                        calculateTotal()
                                    }
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                }
                            }
                            Spacer()
                            Text("\(item.price * item.quantity)$")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Total Label
                Text("Total: \(total)$")
                    .font(.headline)
                    .padding()
                
                // Checkout Button
                Button(action: checkoutTapped) {
                    Text("Confirm Checkout")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("Shopping Cart")
            .onAppear(perform: generateRandomItems)
        }
    }
    
    // MARK: - Functions
    private func generateRandomItems() {
        cartItems = [
            CartItem(name: "Apple", price: 3, quantity: 1),
            CartItem(name: "Banana", price: 2, quantity: 1),
            CartItem(name: "Orange", price: 4, quantity: 1)
        ]
        calculateTotal()
    }
    
    private func calculateTotal() {
        total = cartItems.reduce(0) { $0 + $1.price * $1.quantity }
    }
    
    private func checkoutTapped() {
        print("Checkout Confirmed with total: \(total)$")
    }
}

#Preview {
    ShoppingCartView()
}
