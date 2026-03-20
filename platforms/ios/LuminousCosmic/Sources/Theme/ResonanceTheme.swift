// ResonanceTheme.swift
// Luminous Cosmic Architecture™
// Complete Resonance UX Design System for iOS

import SwiftUI

// MARK: - Color Palette

struct ResonanceColors {
    // Deep Forest Greens
    static let forestDeep = Color(hex: "0A1C14")
    static let forestMid = Color(hex: "122E21")
    static let forestLight = Color(hex: "1B402E")

    // Gold Accents
    static let goldPrimary = Color(hex: "C5A059")
    static let goldLight = Color(hex: "E6D0A1")
    static let goldDark = Color(hex: "9A7A3A")

    // Cream Base
    static let creamPrimary = Color(hex: "FAFAF8")
    static let creamWarm = Color(hex: "F5F4EE")

    // Muted Greens (Text)
    static let textMutedDark = Color(hex: "5C7065")
    static let textMutedLight = Color(hex: "8A9C91")

    // Night Mode
    static let nightDeep = Color(hex: "05100B")
    static let nightMid = Color(hex: "0A1C14")

    // Borders
    static let borderLight = Color(hex: "8A9C91").opacity(0.25)
    static let borderGold = Color(hex: "C5A059").opacity(0.3)

    // Shadows
    static let shadowGold = Color(hex: "C5A059").opacity(0.15)
    static let shadowDark = Color.black.opacity(0.2)

    // Semantic Colors
    static let fire = Color(hex: "C5604A")
    static let earth = Color(hex: "8B7D5C")
    static let air = Color(hex: "7BA5A0")
    static let water = Color(hex: "5C7D9E")
}

// MARK: - Adaptive Theme

struct ResonanceTheme {
    let isDark: Bool

    var background: Color { isDark ? ResonanceColors.nightDeep : ResonanceColors.creamPrimary }
    var backgroundSecondary: Color { isDark ? ResonanceColors.nightMid : ResonanceColors.creamWarm }
    var surface: Color { isDark ? ResonanceColors.forestDeep : .white }
    var surfaceElevated: Color { isDark ? ResonanceColors.forestMid : ResonanceColors.creamWarm }

    var textPrimary: Color { isDark ? ResonanceColors.creamPrimary : ResonanceColors.forestDeep }
    var textSecondary: Color { isDark ? ResonanceColors.textMutedLight : ResonanceColors.textMutedDark }
    var textTertiary: Color { isDark ? ResonanceColors.textMutedDark : ResonanceColors.textMutedLight }

    var accent: Color { ResonanceColors.goldPrimary }
    var accentLight: Color { ResonanceColors.goldLight }
    var accentDark: Color { ResonanceColors.goldDark }

    var border: Color { isDark ? ResonanceColors.borderGold : ResonanceColors.borderLight }

    var glassFill: Color {
        isDark
            ? ResonanceColors.forestMid.opacity(0.4)
            : Color.white.opacity(0.45)
    }

    var glassStroke: Color {
        isDark
            ? ResonanceColors.goldPrimary.opacity(0.15)
            : ResonanceColors.textMutedLight.opacity(0.25)
    }

    // Gradients
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: isDark
                ? [ResonanceColors.nightDeep, ResonanceColors.forestDeep, ResonanceColors.nightMid]
                : [ResonanceColors.creamPrimary, ResonanceColors.creamWarm, ResonanceColors.creamPrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var goldGradient: LinearGradient {
        LinearGradient(
            colors: [ResonanceColors.goldDark, ResonanceColors.goldPrimary, ResonanceColors.goldLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var forestGradient: LinearGradient {
        LinearGradient(
            colors: [ResonanceColors.forestDeep, ResonanceColors.forestMid, ResonanceColors.forestLight],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var cardGradient: LinearGradient {
        LinearGradient(
            colors: isDark
                ? [ResonanceColors.forestMid.opacity(0.6), ResonanceColors.forestDeep.opacity(0.4)]
                : [Color.white.opacity(0.8), ResonanceColors.creamWarm.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var cosmicGradient: RadialGradient {
        RadialGradient(
            colors: isDark
                ? [ResonanceColors.forestLight.opacity(0.3), ResonanceColors.nightDeep]
                : [ResonanceColors.goldLight.opacity(0.2), ResonanceColors.creamPrimary],
            center: .center,
            startRadius: 50,
            endRadius: 400
        )
    }
}

// MARK: - Typography

struct ResonanceTypography {
    // Serif Headers (Cormorant Garamond style - using system serif as fallback)
    static func serifDisplay(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size, relativeTo: .largeTitle)
    }

    static func serifTitle(_ size: CGFloat) -> Font {
        .custom("CormorantGaramond-Medium", size: size, relativeTo: .title)
    }

    static func serifBody(_ size: CGFloat) -> Font {
        .custom("CormorantGaramond-Regular", size: size, relativeTo: .body)
    }

    // Sans-serif Body (Manrope style - using system sans as fallback)
    static func sansBody(_ size: CGFloat) -> Font {
        .custom("Manrope-Regular", size: size, relativeTo: .body)
    }

    static func sansMedium(_ size: CGFloat) -> Font {
        .custom("Manrope-Medium", size: size, relativeTo: .body)
    }

    static func sansBold(_ size: CGFloat) -> Font {
        .custom("Manrope-Bold", size: size, relativeTo: .body)
    }

    // Fallback-safe tokens
    static let displayLarge: Font = .system(size: 40, weight: .light, design: .serif)
    static let displayMedium: Font = .system(size: 32, weight: .light, design: .serif)
    static let displaySmall: Font = .system(size: 28, weight: .regular, design: .serif)
    static let headlineLarge: Font = .system(size: 24, weight: .medium, design: .serif)
    static let headlineMedium: Font = .system(size: 20, weight: .medium, design: .serif)
    static let headlineSmall: Font = .system(size: 17, weight: .semibold, design: .serif)
    static let bodyLarge: Font = .system(size: 17, weight: .regular, design: .default)
    static let bodyMedium: Font = .system(size: 15, weight: .regular, design: .default)
    static let bodySmall: Font = .system(size: 13, weight: .regular, design: .default)
    static let caption: Font = .system(size: 12, weight: .medium, design: .default)
    static let overline: Font = .system(size: 11, weight: .semibold, design: .default)
}

// MARK: - Spacing

struct ResonanceSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radii

struct ResonanceRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let pill: CGFloat = 100
}

// MARK: - Animation

struct ResonanceAnimation {
    // Spring easing matching cubic-bezier(0.34, 1.56, 0.64, 1)
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3)
    static let springSmooth = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2)
    static let springGentle = Animation.spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.4)
    static let easeOut = Animation.easeOut(duration: 0.35)
    static let slowReveal = Animation.easeInOut(duration: 0.8)
    static let celestial = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    static let breathe = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
    static let orbit = Animation.linear(duration: 60).repeatForever(autoreverses: false)
}

// MARK: - Environment Key

struct ThemeKey: EnvironmentKey {
    static let defaultValue = ResonanceTheme(isDark: false)
}

extension EnvironmentValues {
    var resonanceTheme: ResonanceTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
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

// MARK: - Haptics

struct ResonanceHaptics {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
