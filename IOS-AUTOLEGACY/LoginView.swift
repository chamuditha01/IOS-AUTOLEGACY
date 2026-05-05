import SwiftUI

struct LoginView: View {
    @State private var phoneNumber = ""
    var onGetCode: (String) -> Void

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

                    Text("Login")
                        .font(AppTheme.Typography.authTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Track your all vehicle details")
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

                    Text("Enter Phone No")
                        .font(AppTheme.Typography.authSectionTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    Spacer(minLength: 14 * scale)

                    HStack(spacing: 12 * scale) {
                        Image(systemName: "phone")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.phoneBlue)

                        Text("+94")
                            .font(.system(size: 20 * scale, weight: .medium))
                            .foregroundColor(AppTheme.Colors.inputText)

                        Rectangle()
                            .fill(AppTheme.Colors.inputDivider)
                            .frame(width: 2, height: 34 * scale)

                        TextField("Enter your Mobile Number", text: $phoneNumber)
                            .font(AppTheme.Typography.authInput(scale: scale))
                            .foregroundColor(AppTheme.Colors.fieldText)
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal, 18 * scale)
                    .frame(height: AppTheme.Metrics.inputHeight(scale: scale))
                    .background(AppTheme.Colors.whiteSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                    Spacer(minLength: 20 * scale)

                    Button {
                        onGetCode(phoneNumber)
                    } label: {
                        Text("Get Code")
                            .font(AppTheme.Typography.authButton(scale: scale))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Metrics.buttonHeight(scale: scale))
                            .background(AppTheme.Colors.primaryButton)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.buttonCornerRadius(scale: scale), style: .continuous))
                    }

                    Spacer(minLength: 28 * scale)
                }
                .padding(.horizontal, 32 * scale)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var authBackground: some View {
        AppTheme.Gradients.auth
        .ignoresSafeArea()
    }
}

#Preview {
    LoginView { _ in }
}
