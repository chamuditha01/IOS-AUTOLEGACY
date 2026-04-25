//
//  ContentView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-05.
//

import SwiftUI

struct ContentView: View {
    @State private var showLandingPage = true
    @State private var showGetStartedPage = false
    @State private var authScreen: AuthScreen = .login

    private enum AuthScreen {
        case login
        case otp(phoneNumber: String)
        case home
    }
    
    var body: some View {
        ZStack {
            if showLandingPage {
                LandingPageView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showLandingPage = false
                            showGetStartedPage = true
                        }
                    }
                }
            } else if showGetStartedPage {
                GetStartedPageView(
                    onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showGetStartedPage = false
                            authScreen = .login
                        }
                    },
                    onLogin: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showGetStartedPage = false
                            authScreen = .login
                        }
                    }
                )
            } else {
                switch authScreen {
                case .login:
                    LoginView { phoneNumber in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authScreen = .otp(phoneNumber: phoneNumber)
                        }
                    }
                case .otp(let phoneNumber):
                    OTPVerificationView(phoneNumber: phoneNumber) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authScreen = .home
                        }
                    }
                case .home:
                    HomeView()
                MainTabView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
