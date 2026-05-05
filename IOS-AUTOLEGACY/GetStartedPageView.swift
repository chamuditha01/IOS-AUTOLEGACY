//
//  GetStartedPageView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-16.
//

import SwiftUI

struct GetStartedPageView: View {
    var onGetStarted: () -> Void
    var onLogin: () -> Void // Added for navigation logic

    var body: some View {
        ZStack {
            // Background Image
            Image("carBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Overlay for better text visibility
            LinearGradient(
                gradient: Gradient(colors: [
                    .clear,
                    .black.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Maintain Services")
                            .font(AppTheme.Typography.getStartedTitle(scale: 1.0))
                            .foregroundColor(AppTheme.Colors.whiteSurface)

                        Text("& Vault")
                            .font(AppTheme.Typography.getStartedTitle(scale: 1.0))
                            .foregroundColor(AppTheme.Colors.whiteSurface)
                    }

                    Text("Track all vehicle details in one secure place.")
                        .font(AppTheme.Typography.getStartedBody(scale: 1.1))
                        .foregroundColor(AppTheme.Colors.dimText)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 16) {
                    // Primary Action
                    Button(action: {
                        onGetStarted()
                    }) {
                        Text("Get Started")
                            .font(AppTheme.Typography.getStartedButton(scale: 1.2))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Layout.getStartedButtonHeight)
                            .background(AppTheme.Layout.getStartedPrimaryButtonColor)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.getStartedButtonCornerRadius, style: .continuous))
                    }
                    // Secondary Action
                    Button(action: {
                        onLogin()
                    }) {
                        Text("Already have an account? Log in")
                            .font(AppTheme.Typography.getStartedBody(scale: 1.1))
                            .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.8))
                    }
                    .padding(.bottom, 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
    }
}

#Preview {
    GetStartedPageView(onGetStarted: {}, onLogin: {})
}