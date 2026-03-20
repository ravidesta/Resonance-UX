// GlassModifier.swift
// Luminous Cosmic Architecture™
// Glassmorphism Effects for Resonance UX

import SwiftUI

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    @Environment(\.resonanceTheme) var theme

    var cornerRadius: CGFloat
    var intensity: GlassIntensity
    var showBorder: Bool

    enum GlassIntensity {
        case subtle, standard, prominent

        var blur: CGFloat {
            switch self {
            case .subtle: return 10
            case .standard: return 20
            case .prominent: return 40
            }
        }

        var opacity: CGFloat {
            switch self {
            case .subtle: return 0.3
            case .standard: return 0.45
            case .prominent: return 0.6
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Frosted glass base
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    // Themed tint overlay
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(theme.glassFill.opacity(intensity.opacity))

                    // Inner highlight (top edge glow)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(theme.isDark ? 0.08 : 0.25),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                Group {
                    if showBorder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        theme.glassStroke,
                                        theme.glassStroke.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.75
                            )
                    }
                }
            )
            .shadow(
                color: ResonanceColors.shadowGold,
                radius: 12,
                x: 0,
                y: 4
            )
            .shadow(
                color: ResonanceColors.shadowDark,
                radius: 2,
                x: 0,
                y: 1
            )
    }
}

// MARK: - Glass Button Modifier

struct GlassButtonModifier: ViewModifier {
    @Environment(\.resonanceTheme) var theme
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, ResonanceSpacing.lg)
            .padding(.vertical, ResonanceSpacing.sm)
            .background(
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)

                    Capsule()
                        .fill(theme.glassFill.opacity(0.5))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(theme.isDark ? 0.06 : 0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            )
            .overlay(
                Capsule()
                    .strokeBorder(theme.glassStroke, lineWidth: 0.5)
            )
            .shadow(color: ResonanceColors.shadowGold, radius: 8, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(ResonanceAnimation.springBouncy, value: isPressed)
    }
}

// MARK: - Gold Accent Button

struct GoldButtonModifier: ViewModifier {
    @Environment(\.resonanceTheme) var theme

    func body(content: Content) -> some View {
        content
            .font(ResonanceTypography.sansBold(15))
            .foregroundColor(theme.isDark ? ResonanceColors.nightDeep : .white)
            .padding(.horizontal, ResonanceSpacing.xl)
            .padding(.vertical, ResonanceSpacing.md)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                ResonanceColors.goldDark,
                                ResonanceColors.goldPrimary,
                                ResonanceColors.goldLight
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                ResonanceColors.goldLight.opacity(0.8),
                                ResonanceColors.goldDark.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: ResonanceColors.goldPrimary.opacity(0.4), radius: 16, x: 0, y: 6)
            .shadow(color: ResonanceColors.goldDark.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Paper Noise Overlay

struct PaperNoiseOverlay: View {
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        Canvas { context, size in
            // Procedural noise pattern
            for _ in 0..<Int(size.width * size.height * 0.003) {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.06)
                let dotSize = CGFloat.random(in: 0.5...1.5)

                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: dotSize, height: dotSize)),
                    with: .color(theme.isDark ? .white.opacity(opacity) : .black.opacity(opacity))
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        ResonanceColors.goldLight.opacity(0.15),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 300
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func glassCard(
        cornerRadius: CGFloat = ResonanceRadius.lg,
        intensity: GlassCardModifier.GlassIntensity = .standard,
        showBorder: Bool = true
    ) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            intensity: intensity,
            showBorder: showBorder
        ))
    }

    func glassButton() -> some View {
        modifier(GlassButtonModifier())
    }

    func goldButton() -> some View {
        modifier(GoldButtonModifier())
    }

    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func paperNoise() -> some View {
        overlay(PaperNoiseOverlay())
    }
}
