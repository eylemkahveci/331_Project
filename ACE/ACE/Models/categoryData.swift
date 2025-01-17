//
//  categoryData.swift
//  ACE
//
//  Created by Emre Uğur on 17.01.2025.
//
/*/
import Foundation
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

*/
