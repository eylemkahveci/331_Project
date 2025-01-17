//
//  ProductView.swift
//  ACE
//
//  Created by Ceyda Çendekçi on 17.01.2025.
//

import SwiftUICore
import SwiftUI
struct ProductView: View {
    let product: Product
    
    var body: some View {
        ZStack {
            // Resmi ekleyelim
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                        .frame(width: 100, height: 150)
                        .cornerRadius(12)
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 150)
                        .cornerRadius(12)
                case .failure:
                    Color.red
                        .frame(width: 100, height: 150)
                        .cornerRadius(12)
                @unknown default:
                    Color.gray.opacity(0.3)
                        .frame(width: 100, height: 150)
                        .cornerRadius(12)
                }
            }
            
            // Fiyatı kutu içinde göstermek
            VStack {
                HStack {
                    Spacer()
                    Text("$\(product.price, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .frame(width: 100, height: 150)
        }
        .frame(width: 100, height: 150) // Ürün görselinin boyutu
        .cornerRadius(12) // Ürün kutusunun köşelerini yuvarla
    }
}
