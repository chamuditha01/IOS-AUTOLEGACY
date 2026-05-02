import SwiftUI

struct LoginView: View {
    @State private var mobile = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var isFaceUnlockLoading = false
    var onLogin: () -> Void
    var onSignupTap: (() -> Void)? = nil

    var body: some View {
        GeometryReader { geometry in
            let scale = AppTheme.Layout.screenScale(for: geometry.size.width)

            ZStack {
                authBackground

                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: AppTheme.Metrics.headerSpacerTop(scale: scale))

                    AutoLegacyHeader(showTitle: false)
                        .frame(maxWidth: .infinity)

                    Spacer(minLength: AppTheme.Metrics.titleSpacing(scale: scale))

                    Text("Welcome Back")
                        .font(AppTheme.Typography.authTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Sign in to your account")
                        .font(AppTheme.Typography.authSubtitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 30 * scale)

                    Button(action: {}) {
                        Text("Firebase Login")
                            .font(AppTheme.Typography.authButton(scale: scale))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Metrics.buttonHeight(scale: scale))
                            .background(AppTheme.Colors.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: 22 * scale, style: .continuous))
                    }

                    Spacer(minLength: 26 * scale)

                    HStack(spacing: 14 * scale) {
                        Rectangle()
                            .fill(AppTheme.Colors.line)
                            .frame(height: AppTheme.Metrics.dividerHeight)

                        Text("OR")
                            .font(.system(size: 24 * scale, weight: .bold))
                            .foregroundColor(AppTheme.Colors.line)
                            .padding(.horizontal, 4 * scale)

                        Rectangle()
                            .fill(AppTheme.Colors.accentBlue)
                            .frame(height: AppTheme.Metrics.dividerHeight)
                    }

                    Spacer(minLength: 24 * scale)

                    Text("Mobile Number")
                        .font(AppTheme.Typography.authSectionTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    Spacer(minLength: 14 * scale)

                    HStack(spacing: 12 * scale) {
                        Image(systemName: "phone")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.phoneBlue)

                        TextField("Enter your mobile number", text: $mobile)
                            .font(AppTheme.Typography.authInput(scale: scale))
                            .foregroundColor(AppTheme.Colors.fieldText)
                            .keyboardType(.numberPad)
                            .disabled(isLoading)
                    }
                    .padding(.horizontal, 18 * scale)
                    .frame(height: AppTheme.Metrics.inputHeight(scale: scale))
                    .background(AppTheme.Colors.whiteSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                    Spacer(minLength: 20 * scale)

                    Text("Password")
                        .font(AppTheme.Typography.authSectionTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    Spacer(minLength: 14 * scale)

                    HStack(spacing: 12 * scale) {
                        Image(systemName: "lock")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.phoneBlue)

                        if showPassword {
                            TextField("Enter your password", text: $password)
                                .font(AppTheme.Typography.authInput(scale: scale))
                                .foregroundColor(AppTheme.Colors.fieldText)
                                .disabled(isLoading)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .font(AppTheme.Typography.authInput(scale: scale))
                                .foregroundColor(AppTheme.Colors.fieldText)
                                .disabled(isLoading)
                        }

                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .font(.system(size: 16 * scale, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.phoneBlue)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.horizontal, 18 * scale)
                    .frame(height: AppTheme.Metrics.inputHeight(scale: scale))
                    .background(AppTheme.Colors.whiteSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                    Spacer(minLength: 20 * scale)
                    
                    // Face Unlock Button
                    if SessionManager.shared.isFaceUnlockEnabled() && BiometricAuthentication.shared.isBiometricAvailable() {
                        Button {
                            handleFaceUnlock()
                        } label: {
                            HStack(spacing: 12 * scale) {
                                Image(systemName: BiometricAuthentication.shared.getBiometricType() == .faceID ? "face.smiling" : "touchid")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                
                                if isFaceUnlockLoading {
                                    ProgressView()
                                        .tint(AppTheme.Colors.secondaryText)
                                } else {
                                    Text(BiometricAuthentication.shared.getBiometricType() == .faceID ? "Unlock with Face ID" : "Unlock with Touch ID")
                                        .font(.system(size: 14 * scale, weight: .semibold))
                                }
                            }
                            .foregroundColor(AppTheme.Colors.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Metrics.buttonHeight(scale: scale) - 4)
                            .background(AppTheme.Colors.whiteSurface.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.Metrics.buttonCornerRadius(scale: scale), style: .continuous)
                                    .stroke(AppTheme.Colors.accentBlue.opacity(0.5), lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.buttonCornerRadius(scale: scale), style: .continuous))
                        }
                        .disabled(isFaceUnlockLoading)
                    }

                    Spacer(minLength: 20 * scale)
                    
                    // Login Button
                    Button {
                        handleLogin()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(AppTheme.Colors.buttonText)
                        } else {
                            Text("Login")
                                .font(AppTheme.Typography.authButton(scale: scale))
                                .foregroundColor(AppTheme.Colors.buttonText)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.Metrics.buttonHeight(scale: scale))
                    .background(AppTheme.Colors.primaryButton)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.buttonCornerRadius(scale: scale), style: .continuous))
                    .disabled(isLoading || mobile.isEmpty || password.isEmpty)

                    Spacer(minLength: 20 * scale)

                    // Sign up link
                    HStack(spacing: 6) {
                        Text("Don't have an account?")
                            .font(.system(size: 14 * scale, weight: .regular))
                            .foregroundColor(AppTheme.Colors.secondaryText)

                        Button(action: {
                            onSignupTap?()
                        }) {
                            Text("Sign up")
                                .font(.system(size: 14 * scale, weight: .bold))
                                .foregroundColor(AppTheme.Colors.phoneBlue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 28 * scale)
                }
                .padding(.horizontal, 32 * scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .alert("Login Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An error occurred during login")
            }
        }
    }

    private func handleLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await loginWithMobileAndPassword(mobile: mobile, password: password)
                DispatchQueue.main.async {
                    SessionManager.shared.saveUserSession(userId: result.id, name: result.name, mobile: result.mobile)
                    onLogin()
                }
            } catch let error as NSError {
                DispatchQueue.main.async {
                    // Handle specific error codes
                    switch error.code {
                    case -1:
                        errorMessage = "Mobile number not found. Please check and try again."
                    case -2:
                        errorMessage = "Invalid password. Please try again."
                    case -4:
                        errorMessage = "Mobile number missing in database. Contact support."
                    default:
                        errorMessage = error.localizedDescription.isEmpty ? "An error occurred during login. Please try again." : error.localizedDescription
                    }
                    showError = true
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Connection error: \(error.localizedDescription)"
                    showError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func handleFaceUnlock() {
        isFaceUnlockLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await BiometricAuthentication.shared.authenticate(reason: "Unlock AutoLegacy with your biometrics")
                
                // Biometric auth successful - get stored mobile number
                if let storedMobile = SessionManager.shared.getUserMobile() {
                    DispatchQueue.main.async {
                        // Auto-populate mobile field
                        self.mobile = storedMobile
                        isFaceUnlockLoading = false
                        
                        // Show a brief success message then focus on password
                        errorMessage = "✅ Face recognized! Please enter your password."
                        showError = true
                    }
                } else {
                    // No stored mobile, ask user to login normally
                    DispatchQueue.main.async {
                        isFaceUnlockLoading = false
                        errorMessage = "Face verified! Please log in with your credentials."
                        showError = true
                    }
                }
            } catch let error as BiometricAuthentication.AuthenticationError {
                DispatchQueue.main.async {
                    isFaceUnlockLoading = false
                    errorMessage = error.errorDescription ?? "Biometric authentication failed"
                    showError = true
                }
            } catch {
                DispatchQueue.main.async {
                    isFaceUnlockLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private var authBackground: some View {
        AppTheme.Gradients.auth
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView(onLogin: {}, onSignupTap: {})
}
