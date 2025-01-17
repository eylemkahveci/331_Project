//
//  categoryView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI
import FirebaseFirestore

struct Category: Identifiable {
    let id: String
    let name: String
    let subcategories: [String]
}

class CategoryData: ObservableObject {
    @Published var categories: [Category] = []

    private var db = Firestore.firestore()

    func fetchCategories() {
        db.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No categories found.")
                return
            }

            DispatchQueue.main.async {
                self.categories = documents.compactMap { document in
                    let data = document.data()
                    guard
                        let name = data["name"] as? String,
                        let subcategories = data["subcategories"] as? [String]
                    else {
                        print("Invalid category data for document ID \(document.documentID)")
                        return nil
                    }

                    return Category(
                        id: document.documentID,
                        name: name,
                        subcategories: subcategories
                    )
                }
            }
        }
    }
}

struct CategoryListView: View {
    @StateObject private var categoryData = CategoryData()

    var body: some View {
        NavigationView {
            List(categoryData.categories) { category in
                NavigationLink(
                    destination: destinationView(for: category)
                ) {
                    Text(category.name)
                }
            }
            .navigationTitle("Kategoriler")
            .onAppear {
                categoryData.fetchCategories()
            }
        }
    }

    @ViewBuilder
    private func destinationView(for category: Category) -> some View {
        if category.subcategories.isEmpty {
            DetailView(category: category)
        } else {
            SubcategoryListView(subcategories: category.subcategories, parentCategory: category.name)
        }
    }
}

struct SubcategoryListView: View {
    let subcategories: [String]
    let parentCategory: String

    var body: some View {
        List(subcategories, id: \.self) { subcategory in
            NavigationLink(destination: DetailView(category: Category(id: UUID().uuidString, name: subcategory, subcategories: []))) {
                Text(subcategory)
            }
        }
        .navigationTitle(parentCategory)
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
    CategoryListView()
}
