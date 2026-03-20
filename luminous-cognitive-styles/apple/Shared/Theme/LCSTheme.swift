// LCSTheme.swift
// Luminous Cognitive Styles™
// Centralized theme definitions: colors, fonts, spacing, gradients

import SwiftUI

struct LCSTheme {

    // MARK: - Dimension Colors

    static let crystalBlue   = Color(hex: "#4FC3F7")
    static let amberGold     = Color(hex: "#FFB74D")
    static let emerald       = Color(hex: "#66BB6A")
    static let violet        = Color(hex: "#AB47BC")
    static let rose          = Color(hex: "#EF5350")
    static let teal          = Color(hex: "#26A69A")
    static let indigo        = Color(hex: "#5C6BC0")

    static let dimensionColors: [Color] = [
        crystalBlue, amberGold, emerald, violet, rose, teal, indigo
    ]

    // MARK: - Brand Colors

    static let gold          = Color(hex: "#FFD54F")
    static let goldAccent    = Color(hex: "#FFC107")
    static let deepNavy      = Color(hex: "#0D1B2A")
    static let darkSurface   = Color(hex: "#1B2838")
    static let midSurface    = Color(hex: "#243447")
    static let lightSurface  = Color(hex: "#2E4057")

    // MARK: - Text Colors

    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary  = Color.white.opacity(0.45)

    // MARK: - Gradients

    static let backgroundGradient = LinearGradient(
        colors: [deepNavy, Color(hex: "#1A237E").opacity(0.6), deepNavy],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#FFD54F"), Color(hex: "#FFB300")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cardGradient = LinearGradient(
        colors: [darkSurface, midSurface.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            crystalBlue.opacity(0.3),
            violet.opacity(0.3),
            indigo.opacity(0.3),
            teal.opacity(0.3),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func dimensionGradient(for dimension: CognitiveDimension) -> LinearGradient {
        let baseColor = dimension.color
        return LinearGradient(
            colors: [baseColor.opacity(0.6), baseColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Spacing

    struct Spacing {
        static let xs:    CGFloat = 4
        static let sm:    CGFloat = 8
        static let md:    CGFloat = 16
        static let lg:    CGFloat = 24
        static let xl:    CGFloat = 32
        static let xxl:   CGFloat = 48
    }

    // MARK: - Corner Radius

    struct Radius {
        static let sm:    CGFloat = 8
        static let md:    CGFloat = 12
        static let lg:    CGFloat = 16
        static let xl:    CGFloat = 24
        static let pill:  CGFloat = 100
    }

    // MARK: - Shadows

    static let cardShadow = Color.black.opacity(0.3)
    static let glowShadow = Color.white.opacity(0.1)

    // MARK: - View Modifiers

    struct CardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(darkSurface.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.lg)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .shadow(color: cardShadow, radius: 8, x: 0, y: 4)
        }
    }

    struct GlassStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: Radius.lg)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.lg)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
        }
    }

    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(deepNavy)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    Capsule()
                        .fill(goldGradient)
                )
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .foregroundColor(gold)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    Capsule()
                        .stroke(gold, lineWidth: 1.5)
                )
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

// MARK: - View Extensions

extension View {
    func lcsCard() -> some View {
        modifier(LCSTheme.CardStyle())
    }

    func lcsGlass() -> some View {
        modifier(LCSTheme.GlassStyle())
    }
}
