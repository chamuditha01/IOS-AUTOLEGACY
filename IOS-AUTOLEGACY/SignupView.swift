import SwiftUI

struct SignupView: View {
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

                    Text("SignUp")
                        .font(AppTheme.Typography.authTitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("Track your all vehicle details")
                        .font(AppTheme.Typography.authSubtitle(scale: scale))
                        .foregroundColor(AppTheme.Colors.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer(minLength: 30 * scale)

                   
                    Spacer(minLength: 26 * scale)


                    Spacer(minLength: 24 * scale)

                  
                    //Spacer(minLength: 14 * scale)

                    HStack(spacing: 12 * scale) {
                        Image(systemName: "person")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.phoneBlue)

                        Text("Name")
                            .font(.system(size: 20 * scale, weight: .medium))
                            .foregroundColor(AppTheme.Colors.inputText)

                        Rectangle()
                            .fill(AppTheme.Colors.inputDivider)
                            .frame(width: 2, height: 34 * scale)

                        TextField("Enter your Name", text: $phoneNumber)
                            .font(AppTheme.Typography.authInput(scale: scale))
                            .foregroundColor(AppTheme.Colors.fieldText)
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal, 18 * scale)
                    .padding(.vertical, 18 * scale)
                    .frame(height: AppTheme.Metrics.inputHeight(scale: 0.8))
                    .background(AppTheme.Colors.whiteSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                    Spacer(minLength: 0.1 * scale)
                    
                    HStack(spacing: 12 * scale) {
                        Image(systemName: "lock")
                            .font(.system(size: 18 * scale, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.phoneBlue)

                        Text("Pass")
                            .font(.system(size: 20 * scale, weight: .medium))
                            .foregroundColor(AppTheme.Colors.inputText)

                        Rectangle()
                            .fill(AppTheme.Colors.inputDivider)
                            .frame(width: 2, height: 34 * scale)

                        TextField("Enter Password", text: $phoneNumber)
                            .font(AppTheme.Typography.authInput(scale: scale))
                            .foregroundColor(AppTheme.Colors.fieldText)
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal, 18 * scale)
                    .padding(.vertical, 18 * scale)
                    .frame(height: AppTheme.Metrics.inputHeight(scale: 0.8))
                    .background(AppTheme.Colors.whiteSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                    Spacer(minLength: 0.1 * scale)

                 
                    //Spacer(minLength: 14 * scale)

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
                    .padding(.vertical, 18 * scale)
                    .frame(height: AppTheme.Metrics.inputHeight(scale: 0.8))
                    .background(AppTheme.Colors.whiteSurface)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Metrics.inputCornerRadius(scale: scale), style: .continuous))

                    Spacer(minLength: 0.1 * scale)

                    Button {
                        onGetCode(phoneNumber)
                    } label: {
                        Text("Get Code")
                            .font(AppTheme.Typography.authButton(scale: 1.2))
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .frame(height: AppTheme.Layout.getStartedButtonHeight)
                            .background(AppTheme.Layout.getStartedPrimaryButtonColor)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Layout.getStartedButtonCornerRadius, style: .continuous))
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
    SignupView { _ in }
}
