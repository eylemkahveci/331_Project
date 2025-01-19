//
//  splashScreenView.swift
//  ACE
//
//  Created by Emre Uğur on 12.12.2024.
//

import SwiftUI

// MARK: - SplashScreenView
/// A view displayed briefly at the app launch with a logo and animation.
/// Transitions to the `AuthView` after a delay.
struct SplashScreenView: View {
    
    // MARK: - State Variables
    @State private var isActive = false // Tracks whether to transition to `AuthView`
    @State private var size = 0.8 // Initial scale of the animation
    @State private var opacity = 0.5 // Initial opacity of the animation

    var body: some View {
        // Conditional rendering: Shows `AuthView` or splash screen
        if isActive {
            AuthView()
        } else {
            VStack {
                // Logo and text for the splash screen
                VStack {
                    // Icon
                    Image(systemName: "basket.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    
                    // App Name
                    Text("ACE")
                        .font(.title)
                        .foregroundColor(.mint)
                        .padding(0.5)
                }
                // Apply scaling and opacity animations
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    // Animate scale and opacity when the view appears
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            // Transition to the next view after a delay
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        self.isActive = true // Activate the transition to `AuthView`
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashScreenView()
        .environmentObject(ProfileData()) // Provides `ProfileData` as a shared object
}
