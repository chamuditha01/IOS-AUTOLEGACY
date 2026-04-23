import SwiftUI

struct OTPVerificationView: View {
    let phoneNumber: String
    var onLogin: () -> Void = {}

    @State private var otp = ""
    @FocusState private var isOtpFieldFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            let scale = AppTheme.Layout.screenScale(for: geometry.size.width)
            let horizontalPadding = AppTheme.Metrics.horizontalPadding(scale: scale)

            ZStack {
                authBackground

                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: AppTheme.Metrics.headerSpacerTopOTP(scale: scale))

                    AutoLegacyHeader(showTitle: true, scale: scale)
                        .frame(maxWidth: .infinity)

                    Spacer(minLength: 44 * scale)

                    Text("Enter OTP")
                        .font(AppTheme.Typography.authSectionTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    Spacer(minLength: 4 * scale)

                    otpCodeInput(scale: scale)

                    Spacer(minLength: 6 * scale)

                    Button(action: onLogin) {
                        Text("Login")
                            .font(AppTheme.Typography.authPrimaryButton(scale: scale))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Metrics.buttonHeight(scale: scale))
                            .background(AppTheme.Colors.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.buttonCornerRadius(scale: scale), style: .continuous))
                    }

                    Spacer(minLength: 12 * scale)
                }
                .padding(.horizontal, horizontalPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    isOtpFieldFocused = true
                }
            }
        }
    }

    private func otpCodeInput(scale: CGFloat) -> some View {
        HStack(spacing: 12 * scale) {
            Image(systemName: "number")
                .font(.system(size: 18 * scale, weight: .semibold))
                .foregroundColor(AppTheme.Colors.phoneBlue)

            TextField("Enter OTP", text: $otp)
                .font(AppTheme.Typography.authInput(scale: scale))
                .foregroundColor(AppTheme.Colors.fieldText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .focused($isOtpFieldFocused)
                .onChange(of: otp) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    otp = String(filtered.prefix(6))
                }
        }
        .padding(.horizontal, 18 * scale)
        .frame(height: AppTheme.Metrics.inputHeight(scale: scale))
        .background(AppTheme.Colors.whiteSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            isOtpFieldFocused = true
        }
    }

    private var authBackground: some View {
        AppTheme.Gradients.auth
        .ignoresSafeArea()
    }
}

#Preview {
    OTPVerificationView(phoneNumber: "")
}
