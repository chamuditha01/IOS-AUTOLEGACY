//
//  GetStartedPageView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-16.
//

import SwiftUI

struct GetStartedPageView: View {
    var onGetStarted: () -> Void

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
                    .black.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(maxHeight: .infinity)

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
                        .font(AppTheme.Typography.getStartedBody(scale: 1.0))
                        .foregroundColor(AppTheme.Colors.dimText)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: {
                        onGetStarted()
                    }) {
                        Text("Get Started")
                            .font(AppTheme.Typography.getStartedButton(scale: 1.0))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Layout.getStartedButtonHeight)
                            .background(AppTheme.Layout.getStartedPrimaryButtonColor)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.getStartedButtonCornerRadius, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                .padding(.top, 12)
                .background(.clear)
            }
        }
    }
}

#Preview {
    GetStartedPageView {
        print("Get Started")
    }
}
