//
//  AppTheme.swift
//  IOS Clinic App
//
//  Design token system — matches Figma «Clinic Flow» designs.
//  Clean white surfaces, system blue CTA, teal-to-blue icon gradient.
//

import SwiftUI

enum AccessibilitySettingsKey {
    static let textScale = "accessibilityTextScale"
    static let defaultTextScale: Double = 1.0
    static let minTextScale: Double = 0.85
    static let maxTextScale: Double = 1.35
}

// MARK: - Colour Palette

extension Color {
    /// Primary CTA blue — matches Figma button colour.
    static let clinicPrimary     = Color(red: 0.11, green: 0.49, blue: 0.98)

    /// Icon gradient stops (shield: teal → blue).
    static let clinicIconTeal    = Color(red: 0.00, green: 0.76, blue: 0.70)
    static let clinicIconBlue    = Color(red: 0.07, green: 0.45, blue: 0.90)

    // Semantic — auto adaptive for Dark Mode
    static let clinicSurface       = Color(.systemBackground)
    static let clinicSurfaceSecond = Color(.secondarySystemBackground)
    static let clinicFieldBg       = Color(.systemGray6)
    static let clinicSeparator     = Color(.separator)
    static let clinicSubtitle      = Color(.secondaryLabel)
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

extension Font {
    private static var currentTextScale: CGFloat {
        let stored = UserDefaults.standard.object(forKey: AccessibilitySettingsKey.textScale) as? Double
        let scale = stored ?? AccessibilitySettingsKey.defaultTextScale
        return CGFloat(min(max(scale, AccessibilitySettingsKey.minTextScale), AccessibilitySettingsKey.maxTextScale))
    }

    static func app(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        .system(size: size * currentTextScale, weight: weight, design: design)
    }

    static let navTitleSize: Font = .app(size: 34, weight: .semibold)
    static let btnTitleSize: Font = .app(size: 17, weight: .semibold)
}

// MARK: - Icon Gradient

extension LinearGradient {
    /// Teal → blue gradient used on the shield app icon.
    static var clinicIcon: LinearGradient {
        LinearGradient(
            colors: [Color.clinicIconTeal, Color.clinicIconBlue],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
}


enum Gradients {
    static let landing = LinearGradient(
        gradient: Gradient(colors: [Color.landingTop, Color.landingBottom]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let auth = LinearGradient(
        colors: [Color.authTop, Color.authBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let getStarted = LinearGradient(
        colors: [Color.getStartedTop, Color.getStartedMid, Color.getStartedBottom],
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

// MARK: - Spacing Scale

enum AppSpacing {
    static let xxs:  CGFloat =  4
    static let xs:   CGFloat =  8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 27
    static let xl:   CGFloat = 32
    static let xxl:  CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius Scale

enum AppRadius {
    static let sm:   CGFloat =  8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32
    static let pill: CGFloat = 100
}

// MARK: - Component Sizing

enum AppSize {
    static let minTapTarget:   CGFloat = 44
    static let buttonPrimary:  CGFloat = 64
    static let buttonSecond:   CGFloat = 50
    static let fieldHeight:    CGFloat = 54
    static let iconField:      CGFloat = 20
    static let logoOnboarding: CGFloat = 140
    static let logoAuth:       CGFloat = 140
    static let logoWelcome:    CGFloat = 140
}
