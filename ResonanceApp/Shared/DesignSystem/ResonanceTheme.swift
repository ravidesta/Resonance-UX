// ResonanceTheme.swift
// Resonance — Design for the Exhale
//
// Core design tokens: colors, spacing, corner radii, and theme management.

import SwiftUI

// MARK: - Theme Environment Key

struct ResonanceThemeKey: EnvironmentKey {
    static let defaultValue: ResonanceTheme = .light
}

extension EnvironmentValues {
    var resonanceTheme: ResonanceTheme {
        get { self[ResonanceThemeKey.self] }
        set { self[ResonanceThemeKey.self] = newValue }
    }
}

// MARK: - Theme

enum ResonanceTheme {
    case light
    case deepRest

    // MARK: - Backgrounds

    var bgBase: Color {
        switch self {
        case .light: return Color(hex: "FAFAF8")
        case .deepRest: return Color(hex: "05100B")
        }
    }

    var bgSurface: Color {
        switch self {
        case .light: return .white
        case .deepRest: return Color(hex: "0A1C14")
        }
    }

    var bgGlass: Color {
        switch self {
        case .light: return Color.white.opacity(0.7)
        case .deepRest: return Color(hex: "0A1C14").opacity(0.75)
        }
    }

    var bgGlassRaised: Color {
        switch self {
        case .light: return Color(hex: "F5F4EE").opacity(0.65)
        case .deepRest: return Color(hex: "122E21").opacity(0.65)
        }
    }

    // MARK: - Accent Colors

    var goldPrimary: Color { Color(hex: "C5A059") }
    var goldLight: Color { Color(hex: "E6D0A1") }
    var goldDark: Color { Color(hex: "9A7A3A") }

    // MARK: - Green Palette

    var green900: Color { Color(hex: "0A1C14") }
    var green800: Color { Color(hex: "122E21") }
    var green700: Color { Color(hex: "1B402E") }
    var green200: Color { Color(hex: "D1E0D7") }
    var green100: Color { Color(hex: "E8F0EA") }

    // MARK: - Text Colors

    var textMain: Color {
        switch self {
        case .light: return Color(hex: "122E21")
        case .deepRest: return Color(hex: "D1E0D7")
        }
    }

    var textMuted: Color {
        switch self {
        case .light: return Color(hex: "5C7065")
        case .deepRest: return Color(hex: "8A9C91")
        }
    }

    var textLight: Color {
        switch self {
        case .light: return Color(hex: "8A9C91")
        case .deepRest: return Color(hex: "5C7065")
        }
    }

    // MARK: - Borders

    var borderLight: Color {
        switch self {
        case .light: return Color(hex: "E5EBE7")
        case .deepRest: return Color(hex: "1B402E")
        }
    }

    var borderFocus: Color { Color(hex: "C5A059") }

    // MARK: - Semantic Colors

    var energyHigh: Color { Color(hex: "D87050") }
    var energyBalanced: Color { Color(hex: "9A7A3A") }
    var energyLow: Color { Color(hex: "5C7065") }
    var energyRestorative: Color { Color(hex: "8A9C91") }

    // MARK: - Corner Radii

    static let cornerSmall: CGFloat = 12
    static let cornerMedium: CGFloat = 16
    static let cornerLarge: CGFloat = 24
    static let cornerXLarge: CGFloat = 40

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
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

// MARK: - Theme Observable

@Observable
final class ThemeManager {
    var currentTheme: ResonanceTheme = .light

    var isDeepRest: Bool {
        get { currentTheme == .deepRest }
        set { currentTheme = newValue ? .deepRest : .light }
    }

    func toggle() {
        withAnimation(.easeInOut(duration: 0.8)) {
            currentTheme = currentTheme == .light ? .deepRest : .light
        }
    }
}
