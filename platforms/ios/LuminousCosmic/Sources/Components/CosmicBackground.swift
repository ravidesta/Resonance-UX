// CosmicBackground.swift
// Luminous Cosmic Architecture™
// Animated Organic Blob Background with Paper Noise

import SwiftUI

// MARK: - Cosmic Background

struct CosmicBackground: View {
    @Environment(\.resonanceTheme) var theme
    @State private var animateBlobs = false
    @State private var phase: CGFloat = 0

    var showStars: Bool = true
    var blobCount: Int = 3

    var body: some View {
        ZStack {
            // Base gradient
            theme.backgroundGradient
                .ignoresSafeArea()

            // Organic blobs with blur
            GeometryReader { geo in
                ForEach(0..<blobCount, id: \.self) { index in
                    OrganicBlob(
                        index: index,
                        size: geo.size,
                        animate: animateBlobs,
                        theme: theme
                    )
                }
            }
            .blur(radius: 60)
            .ignoresSafeArea()

            // Star field (night mode or optional)
            if showStars && theme.isDark {
                StarFieldView()
                    .ignoresSafeArea()
            }

            // Cosmic radial glow
            theme.cosmicGradient
                .ignoresSafeArea()
                .opacity(0.5)

            // Paper noise texture overlay
            PaperNoiseOverlay()
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(ResonanceAnimation.celestial) {
                animateBlobs = true
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Organic Blob

struct OrganicBlob: View {
    let index: Int
    let size: CGSize
    let animate: Bool
    let theme: ResonanceTheme

    private var blobColor: Color {
        let colors: [Color] = theme.isDark
            ? [
                ResonanceColors.forestLight.opacity(0.25),
                ResonanceColors.goldPrimary.opacity(0.08),
                ResonanceColors.forestMid.opacity(0.2)
            ]
            : [
                ResonanceColors.goldLight.opacity(0.15),
                ResonanceColors.forestLight.opacity(0.08),
                ResonanceColors.goldPrimary.opacity(0.1)
            ]
        return colors[index % colors.count]
    }

    private var position: (x: CGFloat, y: CGFloat) {
        let positions: [(CGFloat, CGFloat)] = [
            (0.2, 0.15),
            (0.75, 0.4),
            (0.35, 0.75)
        ]
        let pos = positions[index % positions.count]
        return (pos.0 * size.width, pos.1 * size.height)
    }

    private var blobSize: CGFloat {
        let sizes: [CGFloat] = [280, 220, 260]
        return sizes[index % sizes.count]
    }

    var body: some View {
        Ellipse()
            .fill(blobColor)
            .frame(
                width: blobSize * (animate ? 1.15 : 0.85),
                height: blobSize * (animate ? 0.9 : 1.1)
            )
            .rotationEffect(.degrees(animate ? Double(index) * 40 : Double(index) * -20))
            .position(
                x: position.x + (animate ? 20 : -20),
                y: position.y + (animate ? -15 : 15)
            )
            .animation(
                Animation.easeInOut(duration: Double(4 + index))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.5),
                value: animate
            )
    }
}

// MARK: - Star Field

struct StarFieldView: View {
    @State private var stars: [Star] = []
    @State private var twinkle = false

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
        let twinkleDelay: Double
    }

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for star in stars {
                    let rect = CGRect(
                        x: star.x * size.width,
                        y: star.y * size.height,
                        width: star.size,
                        height: star.size
                    )
                    context.opacity = star.opacity * (twinkle ? 1.0 : 0.4)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(ResonanceColors.creamPrimary)
                    )
                }
            }
            .onAppear {
                stars = (0..<80).map { _ in
                    Star(
                        x: CGFloat.random(in: 0...1),
                        y: CGFloat.random(in: 0...1),
                        size: CGFloat.random(in: 0.5...2.5),
                        opacity: Double.random(in: 0.2...0.8),
                        twinkleDelay: Double.random(in: 0...3)
                    )
                }
                withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    twinkle = true
                }
            }
        }
    }
}

// MARK: - Cosmic Gradient Orb

struct CosmicOrb: View {
    @Environment(\.resonanceTheme) var theme
    @State private var pulse = false

    var size: CGFloat = 200

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ResonanceColors.goldPrimary.opacity(0.2),
                            ResonanceColors.goldLight.opacity(0.05),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.5, height: size * 1.5)
                .scaleEffect(pulse ? 1.1 : 0.95)

            // Core orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ResonanceColors.goldLight,
                            ResonanceColors.goldPrimary,
                            ResonanceColors.goldDark.opacity(0.6)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.5, height: size * 0.5)
                .shadow(color: ResonanceColors.goldPrimary.opacity(0.5), radius: 20)

            // Highlight
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.4),
                            .clear
                        ],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: -size * 0.05, y: -size * 0.05)
        }
        .onAppear {
            withAnimation(ResonanceAnimation.breathe) {
                pulse = true
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Minimal Cosmic Background (for lighter views)

struct CosmicBackgroundMinimal: View {
    @Environment(\.resonanceTheme) var theme

    var body: some View {
        ZStack {
            theme.backgroundGradient
                .ignoresSafeArea()

            // Single subtle blob
            Circle()
                .fill(ResonanceColors.goldPrimary.opacity(theme.isDark ? 0.04 : 0.06))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: 100, y: -200)

            PaperNoiseOverlay()
                .ignoresSafeArea()
        }
        .accessibilityHidden(true)
    }
}
