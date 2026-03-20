import SwiftUI

// MARK: - Resonance Design Tokens

enum ResonanceTheme {
    // Green palette
    static let green900 = Color(hex: "0A1C14")
    static let green800 = Color(hex: "122E21")
    static let green700 = Color(hex: "1B402E")
    static let green600 = Color(hex: "2D5A44")
    static let green500 = Color(hex: "3D7A5C")
    static let green400 = Color(hex: "5C9A78")
    static let green300 = Color(hex: "8ABFA0")
    static let green200 = Color(hex: "D1E0D7")
    static let green100 = Color(hex: "E8F0EA")

    // Accent colors
    static let gold = Color(hex: "C5A059")
    static let goldLight = Color(hex: "E6D0A1")
    static let goldDark = Color(hex: "9A7A3A")
    static let terraCotta = Color(hex: "D87050")

    // Backgrounds
    static let bgBase = Color(hex: "FAFAF8")
    static let bgSurface = Color.white

    // Text
    static let textMain = Color(hex: "122E21")
    static let textMuted = Color(hex: "5C7065")
    static let textLight = Color(hex: "8A9C91")
    static let borderLight = Color(hex: "E5EBE7")

    // Chromatic palette
    static let growthGreen = Color(hex: "59C9A5")
    static let strategicBlue = Color(hex: "7B8CDE")
    static let creativeMagenta = Color(hex: "E040FB")
    static let warmthAmber = Color(hex: "F4A261")
    static let signalTeal = Color(hex: "4ECDC4")
    static let rhythmCoral = Color(hex: "EF6461")

    static let chromaticPalette: [Color] = [
        growthGreen, strategicBlue, creativeMagenta,
        warmthAmber, signalTeal, rhythmCoral,
        Color(hex: "A78BFA"), Color(hex: "F472B6"),
        Color(hex: "34D399"), Color(hex: "FBBF24"),
    ]

    // Surface colors for dark mode
    static let surfacePrimary = Color.white.opacity(0.04)
    static let surfaceBorder = Color.white.opacity(0.06)
    static let surfaceHover = Color.white.opacity(0.1)

    // Typography
    static let headlineFont = Font.custom("Cormorant Garamond", size: 22)
    static let bodyFont = Font.custom("Manrope", size: 14)
    static let monoFont = Font.custom("JetBrains Mono", size: 12)
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
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
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
