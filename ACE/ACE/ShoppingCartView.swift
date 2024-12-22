//
//  ShoppingCartView.swift
//  ACE
//
//  Created by Emre Uğur on 17.12.2024.
//

import UIKit

class ShoppingCartViewController: UIViewController {
    
    // MARK: - UI Components
    
    let tableView = UITableView()
    let totalLabel = UILabel()
    let checkoutButton = UIButton(type: .system)
    
    // MARK: - Data
    
    struct CartItem {
        let name: String
        let price: Int
    }
    
    var cartItems: [CartItem] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Shopping Cart"
        
        generateRandomItems()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        // TableView
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        // Total Label
        totalLabel.textAlignment = .center
        totalLabel.font = UIFont.boldSystemFont(ofSize: 20)
        totalLabel.text = "Total: \(calculateTotal())$"
        view.addSubview(totalLabel)
        
        // Checkout Button
        checkoutButton.setTitle("Confirm Checkout", for: .normal)
        checkoutButton.backgroundColor = .systemGreen
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        view.addSubview(checkoutButton)
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // TableView Constraints
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400),
            
            // Total Label Constraints
            totalLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            totalLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Checkout Button Constraints
            checkoutButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 20),
            checkoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkoutButton.widthAnchor.constraint(equalToConstant: 200),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Helper Methods
    
    func generateRandomItems() {
        let productNames = ["Apple", "Orange", "Banana", "Milk", "Bread", "Cheese", "Eggs"]
        for name in productNames {
            let randomPrice = Int.random(in: 1...10) // Rastgele 1-10 dolar arasında fiyat
            let item = CartItem(name: name, price: randomPrice)
            cartItems.append(item)
        }
    }
    
    func calculateTotal() -> Int {
        return cartItems.reduce(0) { $0 + $1.price }
    }
    
    @objc func checkoutTapped() {
        let alert = UIAlertController(title: "Checkout",
                                      message: "Your total is \(calculateTotal())$",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ShoppingCartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = cartItems[indexPath.row]
        cell.textLabel?.text = "\(item.name) - \(item.price)$"
        return cell
    }
}
#Preview {
    ShoppingCartViewController()
}
