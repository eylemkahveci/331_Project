//
//  mainView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI

struct mainView: View {
    
    @State var placeholder: String? = "searchBox"
    @State private var textForSearch: String = ""
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.white
                VStack {
                
                }
                .padding()
            }.ignoresSafeArea()
        }
        .searchable(text: $textForSearch, prompt: "search for item")
    }
}

#Preview {
    mainView()
}
