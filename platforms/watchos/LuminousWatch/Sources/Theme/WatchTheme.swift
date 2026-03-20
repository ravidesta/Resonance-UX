// WatchTheme.swift
// Luminous Cosmic Architecture™ — watchOS Theme
// Compact, high-contrast palette for small screens

import SwiftUI

struct WatchTheme {

    // MARK: - Colors

    struct Colors {
        // Deep greens (backgrounds)
        static let background = Color(hex: 0x05100B)
        static let surface = Color(hex: 0x0A1C14)
        static let surfaceElevated = Color(hex: 0x122E21)
        static let surfaceAccent = Color(hex: 0x1B402E)

        // Gold accents
        static let gold = Color(hex: 0xC5A059)
        static let goldLight = Color(hex: 0xE6D0A1)
        static let goldDark = Color(hex: 0x9A7A3A)

        // Text
        static let textPrimary = Color(hex: 0xFAFAF8)
        static let textSecondary = Color(hex: 0x8A9C91)
        static let textTertiary = Color(hex: 0x5C7065)

        // Semantic
        static let accent = gold
    }

    // MARK: - Typography

    struct Typography {
        static let largeTitle = Font.system(size: 20, weight: .light, design: .serif)
        static let title = Font.system(size: 17, weight: .medium, design: .serif)
        static let headline = Font.system(size: 15, weight: .semibold)
        static let body = Font.system(size: 14, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
        static let caption2 = Font.system(size: 10, weight: .medium)
        static let data = Font.system(size: 13, weight: .medium, design: .monospaced)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
    }

    // MARK: - Radius

    struct Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 14
    }
}

// MARK: - Color Extension (watchOS)

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Watch Card Modifier

struct WatchCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(WatchTheme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                    .fill(WatchTheme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                            .strokeBorder(WatchTheme.Colors.gold.opacity(0.15), lineWidth: 0.5)
                    )
            )
    }
}

extension View {
    func watchCard() -> some View {
        modifier(WatchCardModifier())
    }
}

// MARK: - Zodiac Glyphs (Watch)

struct WatchZodiacGlyph {
    static let all: [(name: String, glyph: String)] = [
        ("Aries", "\u{2648}"), ("Taurus", "\u{2649}"), ("Gemini", "\u{264A}"),
        ("Cancer", "\u{264B}"), ("Leo", "\u{264C}"), ("Virgo", "\u{264D}"),
        ("Libra", "\u{264E}"), ("Scorpio", "\u{264F}"), ("Sagittarius", "\u{2650}"),
        ("Capricorn", "\u{2651}"), ("Aquarius", "\u{2652}"), ("Pisces", "\u{2653}")
    ]

    static func glyph(for sign: String) -> String {
        all.first(where: { $0.name == sign })?.glyph ?? "\u{2729}"
    }
}
