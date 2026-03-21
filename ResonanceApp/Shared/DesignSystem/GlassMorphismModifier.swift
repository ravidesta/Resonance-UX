// GlassMorphismModifier.swift
// Resonance — Design for the Exhale
//
// Frosted glass effect panels — the signature Resonance surface treatment.

import SwiftUI

// MARK: - Glass Panel Modifier

struct GlassPanelModifier: ViewModifier {
    let theme: ResonanceTheme
    let cornerRadius: CGFloat
    let raised: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(raised ? theme.bgGlassRaised : theme.bgGlass)
                    .background {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(theme.borderLight.opacity(0.5), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: theme.currentTheme == .deepRest
                    ? .black.opacity(0.3)
                    : Color(hex: "122E21").opacity(0.06),
                radius: raised ? 20 : 12,
                y: raised ? 8 : 4
            )
    }

    private var currentTheme: ResonanceTheme { theme }
}

extension GlassPanelModifier {
    // Workaround for accessing theme enum case
    init(theme: ResonanceTheme, cornerRadius: CGFloat = ResonanceTheme.cornerLarge, raised: Bool = false) {
        self.theme = theme
        self.cornerRadius = cornerRadius
        self.raised = raised
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    let theme: ResonanceTheme
    let isHovered: Bool

    func body(content: Content) -> some View {
        content
            .padding(ResonanceTheme.spacingM)
            .background {
                RoundedRectangle(cornerRadius: ResonanceTheme.cornerMedium, style: .continuous)
                    .fill(theme.bgSurface.opacity(isHovered ? 1.0 : 0.8))
            }
            .overlay {
                RoundedRectangle(cornerRadius: ResonanceTheme.cornerMedium, style: .continuous)
                    .stroke(
                        isHovered ? theme.goldPrimary.opacity(0.3) : theme.borderLight.opacity(0.3),
                        lineWidth: 0.5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.cornerMedium, style: .continuous))
            .shadow(
                color: isHovered
                    ? theme.goldPrimary.opacity(0.08)
                    : Color.black.opacity(0.04),
                radius: isHovered ? 12 : 6,
                y: isHovered ? 4 : 2
            )
    }
}

// MARK: - Glass Nav Bar

struct GlassNavBarModifier: ViewModifier {
    let theme: ResonanceTheme

    func body(content: Content) -> some View {
        content
            .background {
                Rectangle()
                    .fill(theme.bgGlass)
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(theme.borderLight)
                            .frame(height: 0.5)
                    }
            }
    }
}

// MARK: - View Extensions

extension View {
    func glassPanel(
        theme: ResonanceTheme,
        cornerRadius: CGFloat = ResonanceTheme.cornerLarge,
        raised: Bool = false
    ) -> some View {
        modifier(GlassPanelModifier(theme: theme, cornerRadius: cornerRadius, raised: raised))
    }

    func glassCard(theme: ResonanceTheme, isHovered: Bool = false) -> some View {
        modifier(GlassCardModifier(theme: theme, isHovered: isHovered))
    }

    func glassNavBar(theme: ResonanceTheme) -> some View {
        modifier(GlassNavBarModifier(theme: theme))
    }
}
