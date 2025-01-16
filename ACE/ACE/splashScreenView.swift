//
//  splashScreenView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    
    var body: some View {
        
        if isActive{
        }else{
            VStack{
                VStack{
                    Image(systemName: "basket.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    Text("ACE")
                        .font(.title)
                        .foregroundColor(.mint)
                        .padding(0.5)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
                
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                    withAnimation{
                        self.isActive = true
                    }
                }
            }
            
        }

        
    }
}
#Preview {
    SplashScreenView()
        .environmentObject(ProfileData())
        
}
