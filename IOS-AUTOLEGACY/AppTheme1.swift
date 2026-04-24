import SwiftUI

enum AppTheme {
    enum Colors {
        static let landingTop = Color(red: 0.30, green: 0.40, blue: 0.60)
        static let landingBottom = Color(red: 0.20, green: 0.30, blue: 0.50)

        static let authTop = Color(red: 0.36, green: 0.38, blue: 0.52)
        static let authBottom = Color(red: 0.13, green: 0.29, blue: 0.44)

        static let getStartedTop = Color(red: 0.07, green: 0.11, blue: 0.22)
        static let getStartedMid = Color(red: 0.12, green: 0.19, blue: 0.36)
        static let getStartedBottom = Color(red: 0.22, green: 0.30, blue: 0.50)

        static let primaryButton = Color(red: 0.62, green: 0.73, blue: 0.96)
        static let accentBlue = Color(red: 0.16, green: 0.62, blue: 0.95)
        static let phoneBlue = Color(red: 0.12, green: 0.51, blue: 0.95)
        static let secondaryText = Color.white.opacity(0.9)
        static let dimText = Color.white.opacity(0.78)
        static let mutedText = Color.white.opacity(0.35)
        static let line = Color.white.opacity(0.85)
        static let fieldText = Color.black.opacity(0.75)
        static let buttonText = Color.black.opacity(0.85)
        static let inputText = Color.gray
        static let inputDivider = Color.gray.opacity(0.65)
        static let cardBackground = Color.white.opacity(0.08)
        static let cardStroke = Color.white.opacity(0.10)
        static let pillBackground = Color.white.opacity(0.10)
        static let pillStroke = Color.white.opacity(0.18)
        static let whiteSurface = Color.white
        static let orange = Color.orange
    }

    enum Gradients {
        static let landing = LinearGradient(
            gradient: Gradient(colors: [Colors.landingTop, Colors.landingBottom]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let auth = LinearGradient(
            colors: [Colors.authTop, Colors.authBottom],
            startPoint: .top,
            endPoint: .bottom
        )

        static let getStarted = LinearGradient(
            colors: [Colors.getStartedTop, Colors.getStartedMid, Colors.getStartedBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    enum Layout {
        static func screenScale(for width: CGFloat) -> CGFloat {
            min(max(width / 430, 0.88), 1.0)
        }

        static let getStartedCardHeight: CGFloat = 460
        static let getStartedButtonHeight: CGFloat = 56
        static let getStartedCardCornerRadius: CGFloat = 36
        static let getStartedButtonCornerRadius: CGFloat = 18
        static let getStartedCircleOpacity: CGFloat = 0.08
        static let getStartedAccentCircleOpacity: CGFloat = 0.15
        static let getStartedCardShadowOpacity: CGFloat = 0.20
        static let getStartedCardStrokeOpacity: CGFloat = 0.10
        static let getStartedPrimaryButtonColor = Color(red: 0.86, green: 0.90, blue: 0.97)
    }

    enum Typography {
        static func landingTitle(scale: CGFloat) -> Font { .system(size: 36 * scale, weight: .light) }
        static func landingSubtitle(scale: CGFloat) -> Font { .system(size: 12 * scale, weight: .regular) }

        static func authTitle(scale: CGFloat) -> Font { .system(size: 34 * scale, weight: .bold) }
        static func authSubtitle(scale: CGFloat) -> Font { .system(size: 20 * scale, weight: .semibold) }
        static func authSectionTitle(scale: CGFloat) -> Font { .system(size: 24 * scale, weight: .semibold) }
        static func authInput(scale: CGFloat) -> Font { .system(size: 22 * scale, weight: .regular) }
        static func authButton(scale: CGFloat) -> Font { .system(size: 28 * scale, weight: .medium) }
        static func authPrimaryButton(scale: CGFloat) -> Font { .system(size: 32 * scale, weight: .medium) }

        static func otpDigit(scale: CGFloat) -> Font { .system(size: 24 * scale, weight: .medium) }
        static func headerTitle(scale: CGFloat) -> Font { .system(size: 56 * scale, weight: .light) }
        static func headerSubtitle(scale: CGFloat) -> Font { .system(size: 14 * scale, weight: .medium) }
        static func getStartedTitle(scale: CGFloat) -> Font { .system(size: 30 * scale, weight: .semibold, design: .rounded) }
        static func getStartedBody(scale: CGFloat) -> Font { .system(size: 16 * scale, weight: .regular, design: .rounded) }
        static func getStartedButton(scale: CGFloat) -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    }

    enum Metrics {
        static func horizontalPadding(scale: CGFloat) -> CGFloat { 32 * scale }
        static func headerSpacerTop(scale: CGFloat) -> CGFloat { 56 * scale }
        static func headerSpacerTopOTP(scale: CGFloat) -> CGFloat { 62 * scale }
        static func titleSpacing(scale: CGFloat) -> CGFloat { 44 * scale }
        static func otpSpacing(scale: CGFloat) -> CGFloat { 68 * scale }
        static func buttonHeight(scale: CGFloat) -> CGFloat { 72 * scale }
        static func buttonCornerRadius(scale: CGFloat) -> CGFloat { 20 * scale }
        static func inputHeight(scale: CGFloat) -> CGFloat { 72 * scale }
        static func inputCornerRadius(scale: CGFloat) -> CGFloat { 20 * scale }
        static let dividerHeight: CGFloat = 2.5
        static func boxSpacing(scale: CGFloat) -> CGFloat { 10 * scale }
        static func otpCornerRadius(scale: CGFloat) -> CGFloat { 14 * scale }
        static func otpBoxMaxWidth(scale: CGFloat) -> CGFloat { 62 * scale }
        static let otpBoxAspectRatio: CGFloat = 1.23
        static let cardPadding: CGFloat = 20
        static let cardInnerPadding: CGFloat = 28
        static let featurePillSpacing: CGFloat = 10
        static let featurePillCornerRadius: CGFloat = 12
    }
}
