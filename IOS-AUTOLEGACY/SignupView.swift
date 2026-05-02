import SwiftUI

struct SignupView: View {
    @State private var name = ""
    @State private var mobile = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    var onSignup: () -> Void
    var onLoginTap: (() -> Void)? = nil

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

                    Text("Create Account")
                        .font(AppTheme.Typography.authTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Join AutoLegacy today")
                        .font(AppTheme.Typography.authSubtitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 24 * scale)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16 * scale) {
                            // Name Field
                            Text("Full Name")
                                .font(AppTheme.Typography.authSectionTitle(scale: scale))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack(spacing: 12 * scale) {
                                Image(systemName: "person")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.phoneBlue)

                                TextField("Enter your full name", text: $name)
                                    .font(AppTheme.Typography.authInput(scale: scale))
                                    .foregroundColor(AppTheme.Colors.fieldText)
                                    .disabled(isLoading)
                            }
                            .padding(.horizontal, 18 * scale)
                            .frame(height: AppTheme.Metrics.inputHeight(scale: scale))
                            .background(AppTheme.Colors.whiteSurface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                            // Mobile Field
                            Text("Mobile Number")
                                .font(AppTheme.Typography.authSectionTitle(scale: scale))
                                .foregroundColor(AppTheme.Colors.secondaryText)

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

                            // Password Field
                            Text("Password")
                                .font(AppTheme.Typography.authSectionTitle(scale: scale))
                                .foregroundColor(AppTheme.Colors.secondaryText)

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

                            // Confirm Password Field
                            Text("Confirm Password")
                                .font(AppTheme.Typography.authSectionTitle(scale: scale))
                                .foregroundColor(AppTheme.Colors.secondaryText)

                            HStack(spacing: 12 * scale) {
                                Image(systemName: "lock")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.phoneBlue)

                                if showConfirmPassword {
                                    TextField("Confirm your password", text: $confirmPassword)
                                        .font(AppTheme.Typography.authInput(scale: scale))
                                        .foregroundColor(AppTheme.Colors.fieldText)
                                        .disabled(isLoading)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                        .font(AppTheme.Typography.authInput(scale: scale))
                                        .foregroundColor(AppTheme.Colors.fieldText)
                                        .disabled(isLoading)
                                }

                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 16 * scale, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.phoneBlue)
                                }
                                .disabled(isLoading)
                            }
                            .padding(.horizontal, 18 * scale)
                            .frame(height: AppTheme.Metrics.inputHeight(scale: scale))
                            .background(AppTheme.Colors.whiteSurface)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                            Spacer(minLength: 10 * scale)

                            Button {
                                handleSignup()
                            } label: {
                                if isLoading {
                                    ProgressView()
                                        .tint(AppTheme.Colors.buttonText)
                                } else {
                                    Text("Create Account")
                                        .font(AppTheme.Typography.authButton(scale: scale))
                                        .foregroundColor(AppTheme.Colors.buttonText)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Metrics.buttonHeight(scale: scale))
                            .background(AppTheme.Colors.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.buttonCornerRadius(scale: scale), style: .continuous))
                            .opacity(isLoading || !isFormValid ? 0.6 : 1.0)

                            Spacer(minLength: 20 * scale)

                            // Login link
                            HStack(spacing: 6) {
                                Text("Already have an account?")
                                    .font(.system(size: 14 * scale, weight: .regular))
                                    .foregroundColor(AppTheme.Colors.secondaryText)

                                Button(action: {
                                    onLoginTap?()
                                }) {
                                    Text("Log in")
                                        .font(.system(size: 14 * scale, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.phoneBlue)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal, 20 * scale)
                        .padding(.bottom, 40 * scale)
                    }

                    Spacer(minLength: 28 * scale)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .alert("Signup Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage ?? "An error occurred during signup")
            }
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && !mobile.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }

    private func handleSignup() {
        print("📱 handleSignup called - isLoading: \(isLoading), name: \(name), mobile: \(mobile), password: \(password), confirmPassword: \(confirmPassword)")
        print("📱 Form valid: \(isFormValid)")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("📱 Calling signUpWithMobileAndPassword...")
                let result = try await signUpWithMobileAndPassword(name: name, mobile: mobile, password: password)
                print("✅ Signup successful: \(result)")
                DispatchQueue.main.async {
                    print("📱 Saving session...")
                    SessionManager.shared.saveUserSession(userId: result.id, name: result.name, mobile: result.mobile)
                    print("📱 Calling onSignup callback...")
                    onSignup()
                }
            } catch let error as NSError {
                print("❌ Signup error: \(error.code) - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    // Handle specific error codes
                    switch error.code {
                    case -3:
                        errorMessage = "This mobile number is already registered. Please use a different number."
                    case -4:
                        errorMessage = "Failed to save mobile number. Please try again."
                    default:
                        errorMessage = error.localizedDescription.isEmpty ? "An error occurred during signup. Please try again." : error.localizedDescription
                    }
                    showError = true
                    isLoading = false
                }
            } catch {
                print("❌ Unexpected error: \(error)")
                DispatchQueue.main.async {
                    errorMessage = "Connection error: \(error.localizedDescription)"
                    showError = true
                    isLoading = false
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
    SignupView(onSignup: {}, onLoginTap: {})
}
