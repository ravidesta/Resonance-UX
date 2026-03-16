// ResonanceTheme.swift
// Resonance UX GitHub Backup — Design System
// Bioluminescent, breathing surfaces, chromatic intelligence
// Ported from Resonance-UX + Luminous OS design language

import SwiftUI

// MARK: - Color Palette

struct ResonanceColors {
    // Forest Greens (Nature/Calm)
    static let green900 = Color(hex: "0A1C14")
    static let green800 = Color(hex: "122E21")
    static let green700 = Color(hex: "1B402E")
    static let green200 = Color(hex: "D1E0D7")
    static let green100 = Color(hex: "E8F0EA")

    // Gold Accents (Warm, intentional)
    static let goldPrimary = Color(hex: "C5A059")
    static let goldLight = Color(hex: "E6D0A1")
    static let goldDark = Color(hex: "9A7A3A")

    // Bioluminescent Portfolio Colors (from Luminous OS)
    static let growthGreen = Color(hex: "59C9A5")
    static let strategicBlue = Color(hex: "7B8CDE")
    static let creativeMagenta = Color(hex: "E040FB")
    static let warmthAmber = Color(hex: "F4A261")
    static let signalTeal = Color(hex: "4ECDC4")
    static let rhythmCoral = Color(hex: "EF6461")

    // Backgrounds
    static let bgBase = Color(hex: "FAFAF8")
    static let bgSurface = Color.white
    static let bgDeep = Color(hex: "05100B")
    static let bgDeepSurface = Color(hex: "0A1C14")

    // Text
    static let textMain = Color(hex: "122E21")
    static let textMuted = Color(hex: "5C7065")
    static let textLight = Color(hex: "8A9C91")

    // Borders
    static let borderLight = Color(hex: "E5EBE7")

    // Status Indicators (bioluminescent)
    static let statusActive = Color(hex: "59C9A5").opacity(0.8)
    static let statusWarning = Color(hex: "F4A261").opacity(0.8)
    static let statusError = Color(hex: "EF6461").opacity(0.8)
    static let statusIdle = Color(hex: "7B8CDE").opacity(0.4)

    // All portfolio accent colors for cycling
    static let portfolioAccents: [Color] = [
        growthGreen, strategicBlue, creativeMagenta,
        warmthAmber, signalTeal, rhythmCoral
    ]

    static func accentFor(index: Int) -> Color {
        portfolioAccents[index % portfolioAccents.count]
    }
}

// MARK: - Typography

struct ResonanceTypography {
    static let titleFont = Font.custom("Cormorant Garamond", size: 28).weight(.semibold)
    static let headingFont = Font.custom("Cormorant Garamond", size: 22).weight(.medium)
    static let subheadingFont = Font.custom("Cormorant Garamond", size: 18).weight(.medium)
    static let bodyFont = Font.custom("Manrope", size: 14).weight(.regular)
    static let captionFont = Font.custom("Manrope", size: 12).weight(.light)
    static let monoFont = Font.system(.caption, design: .monospaced)

    // Fallback system fonts
    static let titleSystem = Font.system(size: 28, weight: .semibold, design: .serif)
    static let headingSystem = Font.system(size: 22, weight: .medium, design: .serif)
    static let subheadingSystem = Font.system(size: 18, weight: .medium, design: .serif)
    static let bodySystem = Font.system(size: 14, weight: .regular, design: .default)
    static let captionSystem = Font.system(size: 12, weight: .light, design: .default)
    static let callsignFont = Font.system(size: 11, weight: .bold, design: .monospaced)
}

// MARK: - Spacing & Radii

struct ResonanceSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    static let cornerCompact: CGFloat = 14
    static let cornerStandard: CGFloat = 20
    static let cornerLarge: CGFloat = 28
}

// MARK: - Shadows

struct ResonanceShadows {
    static func glass(scheme: ColorScheme) -> some View {
        scheme == .dark
            ? Color.black.opacity(0.7)
            : Color(hex: "9A7A3A").opacity(0.12)
    }

    static func card(scheme: ColorScheme) -> CGFloat {
        scheme == .dark ? 0.5 : 0.08
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
