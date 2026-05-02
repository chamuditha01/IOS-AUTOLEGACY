import SwiftUI

struct LoginView: View {
    @State private var mobile = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    var onLogin: () -> Void

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
                SessionManager.shared.saveUserSession(userId: result.id, name: result.name, mobile: result.mobile)
                onLogin()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }

    private var authBackground: some View {
        AppTheme.Gradients.auth
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView { }
}
