//
//  categoryView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI


struct Category: Identifiable {
    let id = UUID()
    let name: String
    let subcategories: [Category]
}


let sampleCategories = [
    Category(name: "Temel gıda", subcategories: [
        Category(name: "Konserveler", subcategories: []),
        Category(name: "Bakliyat", subcategories: []),
        Category(name: "Baharatlar", subcategories: [])
    ]),
    Category(name: "İçecekler", subcategories: []),
    Category(name: "Kitap ve kırtasiye", subcategories: [])
]


struct CategoryListView: View {
    let categories: [Category]

    var body: some View {
        NavigationView {
            List(categories) { category in
                NavigationLink(
                    destination: destinationView(for: category)
                ) {
                    Text(category.name)
                }
            }
            .navigationTitle("Kategoriler")
        }
    }

    
    @ViewBuilder
    private func destinationView(for category: Category) -> some View {
        if category.subcategories.isEmpty {
            DetailView(category: category)
        } else {
            SubcategoryListView(category: category)
        }
    }
}

struct SubcategoryListView: View {
    let category: Category

    var body: some View {
        List(category.subcategories) { subcategory in
            NavigationLink(destination: DetailView(category: subcategory)) {
                Text(subcategory.name)
            }
        }
        .navigationTitle(category.name)
    }
}

struct DetailView: View {
    let category: Category

    var body: some View {
        VStack {
            Text(category.name)
                .font(.headline)
                .padding()

           
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    CategoryListView(categories: sampleCategories)
}

