//
//  LandingPageView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-16.
//

import SwiftUI

struct LandingPageView: View {
    @State private var isLoading = true
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.3, green: 0.4, blue: 0.6),
                    Color(red: 0.2, green: 0.3, blue: 0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 16) {
                    // Car icon/logo
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("AutoLegacy")
                        .font(.system(size: 36, weight: .light, design: .default))
                        .foregroundColor(.white)
                    
                    Text("AUTOMOTIVE INTELLIGENCE")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .tracking(1.0)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .padding()
            .onAppear {
                // Simulate loading for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isLoading = false
                        onComplete()
                    }
                }
            }
        }
    }
}

#Preview {
    LandingPageView {
        print("Landing page complete")
    }
}
