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
            AppTheme.Gradients.getStarted
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.Colors.cardBackground)
                .frame(width: 240, height: 240)
                .blur(radius: 8)
                .offset(x: -120, y: -240)

            Circle()
                .fill(AppTheme.Colors.orange.opacity(AppTheme.Layout.getStartedAccentCircleOpacity))
                .frame(width: 180, height: 180)
                .blur(radius: 12)
                .offset(x: 130, y: -160)

            VStack(spacing: 0) {
                Spacer(minLength: 30)

                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(AppTheme.Colors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .stroke(AppTheme.Colors.cardStroke, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(AppTheme.Layout.getStartedCardShadowOpacity), radius: 24, x: 0, y: 16)

                    VStack(spacing: 20) {
                        Spacer()

                        Image(systemName: "car.side.fill")
                            .font(.system(size: 118, weight: .light))
                            .foregroundStyle(AppTheme.Colors.whiteSurface, AppTheme.Colors.orange.opacity(0.95))

                        VStack(spacing: 8) {
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
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        HStack(spacing: 10) {
                            featurePill(icon: "shield.lefthalf.filled", title: "Secure")
                            featurePill(icon: "clock.fill", title: "Service history")
                        }
                        .padding(.top, 6)

                        Spacer()
                    }
                    .padding(28)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 460)
                .padding(.horizontal, 20)

                Spacer()
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

                    Button(action: {
                        print("Learn More tapped")
                    }) {
                        Text("Learn More")
                            .font(AppTheme.Typography.getStartedButton(scale: 1.0))
                            .foregroundColor(AppTheme.Colors.whiteSurface)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Layout.getStartedButtonHeight)
                            .background(AppTheme.Colors.pillBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(AppTheme.Colors.pillStroke, lineWidth: 1)
                            )
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

    private func featurePill(icon: String, title: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.95))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.pillBackground)
        .clipShape(Capsule())
    }
}

#Preview {
    GetStartedPageView {
        print("Get Started")
    }
}
