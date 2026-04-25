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
            AppTheme.Gradients.landing
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppTheme.Colors.orange)
                    
                    Text("AutoLegacy")
                        .font(AppTheme.Typography.landingTitle(scale: 1.0))
                        .foregroundColor(AppTheme.Colors.whiteSurface)
                    
                    Text("AUTOMOTIVE INTELLIGENCE")
                        .font(AppTheme.Typography.landingSubtitle(scale: 1.0))
                        .tracking(1.0)
                        .foregroundColor(AppTheme.Colors.secondaryText.opacity(0.7))
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .tint(AppTheme.Colors.whiteSurface)
                        .scaleEffect(1.5)
                }
            }
            .padding()
            .onAppear {
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
