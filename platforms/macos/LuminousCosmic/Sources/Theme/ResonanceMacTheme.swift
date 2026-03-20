// ResonanceMacTheme.swift
// Luminous Cosmic Architecture™ — macOS Theme
// Resonance UX design system adapted for desktop

import SwiftUI

struct ResonanceMacTheme {

    // MARK: - Color Palette

    struct Colors {
        // Deep forest greens
        static let forestDeep = Color(hex: 0x0A1C14)
        static let forestMid = Color(hex: 0x122E21)
        static let forestLight = Color(hex: 0x1B402E)

        // Gold accents
        static let gold = Color(hex: 0xC5A059)
        static let goldLight = Color(hex: 0xE6D0A1)
        static let goldDark = Color(hex: 0x9A7A3A)

        // Cream base
        static let cream = Color(hex: 0xFAFAF8)
        static let creamWarm = Color(hex: 0xF5F4EE)

        // Muted greens
        static let mutedGreen = Color(hex: 0x5C7065)
        static let mutedGreenLight = Color(hex: 0x8A9C91)

        // Night mode
        static let nightBackground = Color(hex: 0x05100B)

        // Semantic colors
        static let background = cream
        static let surfacePrimary = Color.white.opacity(0.85)
        static let surfaceSecondary = Color.white.opacity(0.6)
        static let textPrimary = forestDeep
        static let textSecondary = mutedGreen
        static let accent = gold
        static let accentSubtle = goldLight

        // Sidebar
        static let sidebarBackground = forestDeep
        static let sidebarText = creamWarm
        static let sidebarSelection = forestLight
        static let sidebarIcon = gold

        // Card surfaces
        static let cardBackground = Color.white.opacity(0.72)
        static let cardBorder = goldLight.opacity(0.3)
    }

    // MARK: - Typography

    struct Typography {
        // Serif headers
        static let largeTitle = Font.system(size: 32, weight: .light, design: .serif)
        static let title = Font.system(size: 24, weight: .regular, design: .serif)
        static let title2 = Font.system(size: 20, weight: .regular, design: .serif)
        static let title3 = Font.system(size: 17, weight: .medium, design: .serif)

        // Sans-serif body
        static let headline = Font.system(size: 15, weight: .semibold, design: .default)
        static let body = Font.system(size: 14, weight: .regular, design: .default)
        static let callout = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 11, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 10, weight: .medium, design: .default)

        // Monospaced for data
        static let data = Font.system(size: 13, weight: .medium, design: .monospaced)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    struct Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: - Shadows

    struct Shadows {
        static let cardShadow = Shadow(
            color: Colors.gold.opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )

        static let subtleShadow = Shadow(
            color: Colors.gold.opacity(0.05),
            radius: 6,
            x: 0,
            y: 2
        )

        static let elevatedShadow = Shadow(
            color: Colors.gold.opacity(0.12),
            radius: 20,
            x: 0,
            y: 8
        )
    }

    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Animation

    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.1)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let quick = SwiftUI.Animation.easeOut(duration: 0.2)
        static let cosmic = SwiftUI.Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    }
}

// MARK: - Color Hex Extension

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

// MARK: - View Modifiers

struct GlassmorphismModifier: ViewModifier {
    var isNightMode: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                if isNightMode {
                    RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.lg)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.lg)
                                .fill(ResonanceMacTheme.Colors.nightBackground.opacity(0.5))
                        )
                } else {
                    RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.lg)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.lg)
                                .fill(ResonanceMacTheme.Colors.cardBackground)
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.lg)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                ResonanceMacTheme.Colors.goldLight.opacity(0.3),
                                ResonanceMacTheme.Colors.goldLight.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: ResonanceMacTheme.Shadows.cardShadow.color,
                radius: ResonanceMacTheme.Shadows.cardShadow.radius,
                x: ResonanceMacTheme.Shadows.cardShadow.x,
                y: ResonanceMacTheme.Shadows.cardShadow.y
            )
    }
}

struct CosmicCardModifier: ViewModifier {
    var isNightMode: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(ResonanceMacTheme.Spacing.lg)
            .modifier(GlassmorphismModifier(isNightMode: isNightMode))
    }
}

extension View {
    func cosmicCard(isNightMode: Bool = false) -> some View {
        modifier(CosmicCardModifier(isNightMode: isNightMode))
    }

    func glassmorphism(isNightMode: Bool = false) -> some View {
        modifier(GlassmorphismModifier(isNightMode: isNightMode))
    }
}

// MARK: - Zodiac Glyphs

struct ZodiacGlyph {
    static let aries = "\u{2648}"
    static let taurus = "\u{2649}"
    static let gemini = "\u{264A}"
    static let cancer = "\u{264B}"
    static let leo = "\u{264C}"
    static let virgo = "\u{264D}"
    static let libra = "\u{264E}"
    static let scorpio = "\u{264F}"
    static let sagittarius = "\u{2650}"
    static let capricorn = "\u{2651}"
    static let aquarius = "\u{2652}"
    static let pisces = "\u{2653}"

    static let all: [(name: String, glyph: String)] = [
        ("Aries", aries), ("Taurus", taurus), ("Gemini", gemini),
        ("Cancer", cancer), ("Leo", leo), ("Virgo", virgo),
        ("Libra", libra), ("Scorpio", scorpio), ("Sagittarius", sagittarius),
        ("Capricorn", capricorn), ("Aquarius", aquarius), ("Pisces", pisces)
    ]
}

struct PlanetGlyph {
    static let sun = "\u{2609}"
    static let moon = "\u{263D}"
    static let mercury = "\u{263F}"
    static let venus = "\u{2640}"
    static let mars = "\u{2642}"
    static let jupiter = "\u{2643}"
    static let saturn = "\u{2644}"
    static let uranus = "\u{2645}"
    static let neptune = "\u{2646}"
    static let pluto = "\u{2647}"

    static let all: [(name: String, glyph: String)] = [
        ("Sun", sun), ("Moon", moon), ("Mercury", mercury),
        ("Venus", venus), ("Mars", mars), ("Jupiter", jupiter),
        ("Saturn", saturn), ("Uranus", uranus), ("Neptune", neptune),
        ("Pluto", pluto)
    ]
}
