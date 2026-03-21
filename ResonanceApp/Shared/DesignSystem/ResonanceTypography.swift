// ResonanceTypography.swift
// Resonance — Design for the Exhale
//
// Typography system using Cormorant Garamond (serif) and system sans-serif.

import SwiftUI

// MARK: - Typography

enum ResonanceFont {
    // Serif — for headlines, names, intention labels
    static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Cormorant Garamond", size: size).weight(weight)
    }

    // Sans — for body text, labels, UI elements
    static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // Predefined styles
    static let displayLarge = serif(40, weight: .light)
    static let displayMedium = serif(32, weight: .light)
    static let displaySmall = serif(28, weight: .regular)

    static let headlineLarge = serif(24, weight: .medium)
    static let headlineMedium = serif(20, weight: .medium)
    static let headlineSmall = serif(18, weight: .medium)

    static let bodyLarge = sans(17, weight: .regular)
    static let bodyMedium = sans(15, weight: .regular)
    static let bodySmall = sans(13, weight: .regular)

    static let labelLarge = sans(14, weight: .medium)
    static let labelMedium = sans(12, weight: .medium)
    static let labelSmall = sans(11, weight: .medium)

    static let caption = sans(11, weight: .regular)

    // Intention text — italic serif
    static let intention = serif(15, weight: .regular)

    // Writer — large serif for writing
    static let writerBody = serif(20, weight: .light)
    static let writerTitle = serif(36, weight: .light)

    #if os(watchOS)
    // Watch-optimized sizes
    static let watchTitle = serif(20, weight: .medium)
    static let watchBody = sans(14, weight: .regular)
    static let watchCaption = sans(11, weight: .regular)
    static let watchLargeTime = serif(44, weight: .light)
    #endif
}

// MARK: - Text Styles

struct ResonanceTextStyle: ViewModifier {
    let font: Font
    let color: Color
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
            .tracking(tracking)
    }
}

extension View {
    func resonanceStyle(
        _ font: Font,
        color: Color,
        tracking: CGFloat = 0
    ) -> some View {
        modifier(ResonanceTextStyle(font: font, color: color, tracking: tracking))
    }

    // Uppercase label style with wide tracking
    func resonanceLabel(_ theme: ResonanceTheme) -> some View {
        self
            .font(ResonanceFont.labelSmall)
            .foregroundStyle(theme.textMuted)
            .tracking(2)
            .textCase(.uppercase)
    }
}
