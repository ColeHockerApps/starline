import SwiftUI

enum MyUSTheme {

    // MARK: - Base Colors

    static let background = Color(red: 0.04, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.08, green: 0.09, blue: 0.14)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.65)

    // MARK: - Accents

    static let accent = Color(red: 0.45, green: 0.78, blue: 0.98)
    static let accentSoft = Color(red: 0.55, green: 0.62, blue: 0.98)

    static let mint = Color(red: 0.42, green: 0.92, blue: 0.72)
    static let sun = Color(red: 0.98, green: 0.82, blue: 0.40)
    static let rose = Color(red: 0.98, green: 0.55, blue: 0.68)

    // MARK: - Gradients

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.04, blue: 0.08),
            Color(red: 0.06, green: 0.07, blue: 0.14),
            Color(red: 0.04, green: 0.05, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [
            accent,
            accentSoft,
            mint
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Shadows

    static let shadowSoft = Color.black.opacity(0.25)
    static let shadowStrong = Color.black.opacity(0.45)

    // MARK: - Helpers

    static func cardBackground(cornerRadius: CGFloat = 22) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(surface.opacity(0.65))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}
