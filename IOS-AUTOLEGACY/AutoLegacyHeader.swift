import SwiftUI

struct AutoLegacyHeader: View {
    var showTitle: Bool
    var scale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: scaled(18)) {
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: scaled(28)))
                    path.addQuadCurve(
                        to: CGPoint(x: scaled(166), y: scaled(12)),
                        control: CGPoint(x: scaled(90), y: scaled(2))
                    )
                    path.addQuadCurve(
                        to: CGPoint(x: scaled(280), y: scaled(28)),
                        control: CGPoint(x: scaled(235), y: scaled(8))
                    )
                }
                .stroke(AppTheme.Colors.orange, style: StrokeStyle(lineWidth: scaled(5), lineCap: .round, lineJoin: .round))

                Path { path in
                    path.move(to: CGPoint(x: scaled(46), y: scaled(28)))
                    path.addQuadCurve(
                        to: CGPoint(x: scaled(230), y: scaled(20)),
                        control: CGPoint(x: scaled(146), y: scaled(-2))
                    )
                }
                .stroke(AppTheme.Colors.orange, style: StrokeStyle(lineWidth: scaled(4), lineCap: .round, lineJoin: .round))
            }
            .frame(width: scaled(280), height: scaled(32))

            if showTitle {
                Text("AutoLegacy")
                    .font(AppTheme.Typography.headerTitle(scale: scale))
                    .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.82))

                Text("AUTOMOTIVE INTELLIGENCE")
                    .font(AppTheme.Typography.headerSubtitle(scale: scale))
                    .tracking(scaled(5))
                    .foregroundColor(AppTheme.Colors.mutedText)
            }
        }
    }

    private func scaled(_ value: CGFloat) -> CGFloat {
        value * scale
    }
}

#Preview {
    AutoLegacyHeader(showTitle: true)
}
