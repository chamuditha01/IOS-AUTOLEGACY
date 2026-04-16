//
//  GetStartedPageView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-16.
//

import SwiftUI

struct GetStartedPageView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.11, blue: 0.22),
                    Color(red: 0.12, green: 0.19, blue: 0.36),
                    Color(red: 0.22, green: 0.30, blue: 0.50)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 240, height: 240)
                .blur(radius: 8)
                .offset(x: -120, y: -240)

            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 180, height: 180)
                .blur(radius: 12)
                .offset(x: 130, y: -160)

            VStack(spacing: 0) {
                Spacer(minLength: 30)

                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 36, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.20), radius: 24, x: 0, y: 16)

                    VStack(spacing: 20) {
                        Spacer()

                        Image(systemName: "car.side.fill")
                            .font(.system(size: 118, weight: .light))
                            .foregroundStyle(.white, Color.orange.opacity(0.95))

                        VStack(spacing: 8) {
                            Text("Maintain Services")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)

                            Text("& Vault")
                                .font(.system(size: 30, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        Text("Track all vehicle details in one secure place.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.78))
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
                        print("Get Started tapped")
                    }) {
                        Text("Get Started")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.86, green: 0.90, blue: 0.97))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Button(action: {
                        print("Learn More tapped")
                    }) {
                        Text("Learn More")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .foregroundColor(.white.opacity(0.95))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.10))
        .clipShape(Capsule())
    }
}

#Preview {
    GetStartedPageView()
}
