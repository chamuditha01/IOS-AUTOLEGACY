import SwiftUI

struct ContentView: View {
    @State private var showLandingPage = true
    @State private var showGetStartedPage = false
    @State private var authScreen: AuthScreen = .login
    @State private var isCheckingSession = true

    private enum AuthScreen {
        case login
        case signup
        case otp(phoneNumber: String)
        case home
    }
    
    var body: some View {
        ZStack {
            if isCheckingSession {
                // Show loading while checking for existing session
                ZStack {
                    AppTheme.Gradients.auth
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .tint(AppTheme.Colors.whiteSurface)
                            .scaleEffect(1.5)
                    }
                }
            } else if showLandingPage {
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
                            authScreen = .signup
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
                    LoginView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authScreen = .home
                        }
                    }
                case .signup:
                    SignupView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authScreen = .home
                        }
                    }
                case .otp(let phoneNumber):
                    OTPVerificationView(phoneNumber: phoneNumber) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authScreen = .home
                        }
                    }
                case .home:
                    MainTabView(onLogout: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            authScreen = .login
                        }
                    })
                }
            }
        }
        .onAppear {
            checkExistingSession()
        }
    }
    
    private func checkExistingSession() {
        // Check if user has an existing session saved
        if SessionManager.shared.isUserLoggedIn() {
            // User is already logged in, skip to home
            authScreen = .home
            isCheckingSession = false
        } else {
            // No existing session, show landing page
            isCheckingSession = false
        }
    }
}

#Preview {
    ContentView()
}
