// GlassMorphismCard.swift
// Resonance UX — Shared Components
//
// Reusable SwiftUI building blocks that embody the Resonance aesthetic:
// glass morphism, organic shapes, intentional status indicators,
// energy-level badges, waveform visualization, and breathe animations.

import SwiftUI

// MARK: - Glass Morphism Card

struct GlassMorphismCard<Content: View>: View {
    let isDeepRest: Bool
    let cornerRadius: CGFloat
    let padding: CGFloat
    @ViewBuilder let content: () -> Content

    @State private var isPressed = false

    init(
        isDeepRest: Bool = false,
        cornerRadius: CGFloat = ResonanceTheme.Radius.lg,
        padding: CGFloat = ResonanceTheme.Spacing.lg,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.isDeepRest = isDeepRest
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Base glass layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)

                    // Inner highlight (top-left inset glow)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isDeepRest ? 0.06 : 0.5),
                                    Color.white.opacity(0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )

                    // Subtle surface tint
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            (isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                                .opacity(isDeepRest ? 0.3 : 0.4)
                        )
                }
            )
            .shadow(
                color: Color.black.opacity(isDeepRest ? 0.25 : 0.06),
                radius: isPressed ? 4 : 12,
                y: isPressed ? 1 : 4
            )
            .scaleEffect(isPressed ? 0.985 : 1.0)
            .animation(ResonanceTheme.Animation.gentle, value: isPressed)
            .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Intentional Status Badge

struct IntentionalStatusBadge: View {
    let status: IntentionalStatus
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: compact ? 6 : 8, height: compact ? 6 : 8)

            if !compact {
                Image(systemName: status.icon)
                    .font(.system(size: 10))
                    .foregroundColor(status.color)
            }

            Text(status.rawValue)
                .font(compact ? ResonanceTheme.Typography.caption : ResonanceTheme.Typography.bodySmall)
                .foregroundColor(status.color)
        }
        .padding(.horizontal, compact ? 0 : ResonanceTheme.Spacing.sm)
        .padding(.vertical, compact ? 0 : 3)
        .background(
            compact
            ? AnyView(Color.clear)
            : AnyView(
                Capsule()
                    .fill(status.color.opacity(0.08))
              )
        )
    }
}

// MARK: - Energy Level Indicator

struct EnergyLevelIndicator: View {
    let level: EnergyLevel
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.icon)
                .font(.system(size: compact ? 10 : 12))

            if !compact {
                Text(level.rawValue)
                    .font(ResonanceTheme.Typography.caption)
            }
        }
        .foregroundColor(level.color)
        .padding(.horizontal, compact ? 4 : ResonanceTheme.Spacing.sm)
        .padding(.vertical, compact ? 2 : 3)
        .background(
            Capsule()
                .fill(level.color.opacity(0.08))
        )
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    var barCount: Int = 24
    var isAnimating: Bool = false
    var baseColor: Color = ResonanceTheme.Light.gold

    @State private var heights: [CGFloat] = []

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(baseColor.opacity(0.3 + Double(index) / Double(barCount) * 0.7))
                    .frame(width: 2, height: barHeight(at: index))
                    .animation(
                        isAnimating
                        ? .easeInOut(duration: Double.random(in: 0.3...0.7))
                              .repeatForever(autoreverses: true)
                              .delay(Double(index) * 0.05)
                        : .default,
                        value: heights
                    )
            }
        }
        .onAppear {
            generateHeights()
            if isAnimating {
                startAnimationCycle()
            }
        }
    }

    private func barHeight(at index: Int) -> CGFloat {
        guard index < heights.count else { return 4 }
        return heights[index]
    }

    private func generateHeights() {
        heights = (0..<barCount).map { i in
            let normalized = sin(Double(i) * 0.4) * 0.5 + 0.5
            return CGFloat(4 + normalized * 24)
        }
    }

    private func startAnimationCycle() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            heights = (0..<barCount).map { _ in
                CGFloat.random(in: 4...28)
            }
        }
    }
}

// MARK: - Organic Blob View (Breathe Animation)

struct OrganicBlobView: View {
    var primaryColor: Color = ResonanceTheme.Light.gold
    var secondaryColor: Color = Color(hex: 0x122E21)
    var breatheDuration: Double = 17.0  // 15-20 second cycles

    @State private var phase: CGFloat = 0
    @State private var scale: CGFloat = 0.9

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let baseRadius = min(size.width, size.height) * 0.35
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Draw multiple layered blobs
                for layer in 0..<3 {
                    let layerOffset = Double(layer) * 0.7
                    let layerScale = 1.0 - Double(layer) * 0.15
                    let opacity = 0.3 - Double(layer) * 0.08

                    let path = organicPath(
                        center: center,
                        radius: baseRadius * layerScale,
                        time: time + layerOffset,
                        pointCount: 8
                    )

                    let gradient = Gradient(colors: [
                        primaryColor.opacity(opacity),
                        secondaryColor.opacity(opacity * 0.6)
                    ])
                    let shading = GraphicsContext.Shading.radialGradient(
                        gradient,
                        center: center,
                        startRadius: 0,
                        endRadius: baseRadius * layerScale
                    )
                    context.fill(path, with: shading)
                }
            }
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(
                .easeInOut(duration: breatheDuration)
                .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
            }
        }
    }

    private func organicPath(
        center: CGPoint,
        radius: CGFloat,
        time: Double,
        pointCount: Int
    ) -> Path {
        var path = Path()
        var points: [CGPoint] = []

        for i in 0..<pointCount {
            let angle = (Double(i) / Double(pointCount)) * .pi * 2
            let noise = sin(time * 0.3 + Double(i) * 1.2) * 0.15 + 1.0
            let r = radius * noise

            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            points.append(CGPoint(x: x, y: y))
        }

        guard points.count >= 3 else { return path }

        path.move(to: midpoint(points[points.count - 1], points[0]))

        for i in 0..<points.count {
            let current = points[i]
            let next = points[(i + 1) % points.count]
            let mid = midpoint(current, next)
            path.addQuadCurve(to: mid, control: current)
        }

        path.closeSubpath()
        return path
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}

// MARK: - Spaciousness Gauge

struct SpaciousnessGauge: View {
    var value: Double
    var maxValue: Double = 8.0

    @State private var animatedValue: Double = 0

    private var progress: Double {
        min(animatedValue / maxValue, 1.0)
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    ResonanceTheme.Light.gold.opacity(0.12),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            ResonanceTheme.Light.gold.opacity(0.4),
                            ResonanceTheme.Light.gold
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center value
            VStack(spacing: 0) {
                Text(String(format: "%.1f", value))
                    .font(ResonanceTheme.Typography.sans(16, weight: .bold))
                    .foregroundColor(ResonanceTheme.Light.gold)
                Text("hrs")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(ResonanceTheme.Light.gold.opacity(0.6))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedValue = value
            }
        }
    }
}

// MARK: - Phase Progress Ring

struct PhaseProgressRing: View {
    let phase: DailyPhaseKind
    let progress: Double  // 0.0 – 1.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(phase.color.opacity(0.1), lineWidth: 3)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    phase.color,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)

            Image(systemName: phase.icon)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(phase.color)
        }
    }
}

// MARK: - Calm Divider

struct CalmDivider: View {
    var color: Color = ResonanceTheme.Light.gold
    var opacity: Double = 0.2

    var body: some View {
        HStack(spacing: ResonanceTheme.Spacing.md) {
            line
            Circle()
                .fill(color.opacity(opacity))
                .frame(width: 4, height: 4)
            line
        }
        .padding(.vertical, ResonanceTheme.Spacing.md)
    }

    private var line: some View {
        Rectangle()
            .fill(color.opacity(opacity * 0.5))
            .frame(height: 0.5)
    }
}

// MARK: - Frequency Display (Compact)

struct CompactFrequencyDisplay: View {
    let value: Double
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ResonanceTheme.Light.gold.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )

            Circle()
                .stroke(ResonanceTheme.Light.gold.opacity(0.3), lineWidth: 1.5)

            Text(String(format: "%.1f", value))
                .font(ResonanceTheme.Typography.sans(size * 0.35, weight: .bold))
                .foregroundColor(ResonanceTheme.Light.gold)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Resonance Button Styles

struct ResonancePrimaryButton: ButtonStyle {
    var color: Color = ResonanceTheme.Light.gold

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResonanceTheme.Typography.sans(16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, ResonanceTheme.Spacing.lg)
            .padding(.vertical, ResonanceTheme.Spacing.md)
            .background(
                Capsule()
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(ResonanceTheme.Animation.gentle, value: configuration.isPressed)
    }
}

struct ResonanceSecondaryButton: ButtonStyle {
    @Environment(\.isDeepRestMode) private var isDeepRest

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResonanceTheme.Typography.sans(15, weight: .medium))
            .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
            .padding(.horizontal, ResonanceTheme.Spacing.md)
            .padding(.vertical, ResonanceTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill((isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface))
                    .overlay(
                        Capsule()
                            .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(ResonanceTheme.Animation.gentle, value: configuration.isPressed)
    }
}

// MARK: - Shimmer Loading Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.2),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 2)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 1
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Adaptive Background

struct AdaptiveBackground: ViewModifier {
    @Environment(\.isDeepRestMode) private var isDeepRest

    func body(content: Content) -> some View {
        content
            .background(
                (isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base)
                    .ignoresSafeArea()
            )
    }
}

extension View {
    func resonanceBackground() -> some View {
        modifier(AdaptiveBackground())
    }
}
