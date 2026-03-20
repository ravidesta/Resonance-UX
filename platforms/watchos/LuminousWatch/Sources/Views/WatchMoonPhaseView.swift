// WatchMoonPhaseView.swift
// Luminous Cosmic Architecture™ — watchOS Moon Phase
// Beautiful moon visualization with phase name and illumination

import SwiftUI

struct WatchMoonPhaseView: View {
    @EnvironmentObject var watchState: WatchState
    @State private var glowPulse: Bool = false

    var body: some View {
        VStack(spacing: WatchTheme.Spacing.lg) {
            Spacer()

            // Moon visualization
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                WatchTheme.Colors.goldLight.opacity(0.12),
                                WatchTheme.Colors.gold.opacity(0.04),
                                Color.clear,
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(glowPulse ? 1.05 : 0.95)

                // Moon body
                Circle()
                    .fill(WatchTheme.Colors.surface)
                    .frame(width: 64, height: 64)
                    .overlay(
                        WatchMoonShape(illumination: watchState.currentMoonPhase.illumination)
                            .fill(
                                LinearGradient(
                                    colors: [WatchTheme.Colors.goldLight, WatchTheme.Colors.gold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(WatchTheme.Colors.gold.opacity(0.4), lineWidth: 1)
                    )
            }

            // Phase info
            VStack(spacing: WatchTheme.Spacing.sm) {
                Text(watchState.currentMoonPhase.rawValue)
                    .font(WatchTheme.Typography.title)
                    .foregroundStyle(WatchTheme.Colors.textPrimary)

                Text("in \(watchState.moonSign)")
                    .font(WatchTheme.Typography.caption)
                    .foregroundStyle(WatchTheme.Colors.gold)

                // Illumination bar
                HStack(spacing: WatchTheme.Spacing.sm) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(WatchTheme.Colors.surface)
                                .frame(height: 4)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [WatchTheme.Colors.goldDark, WatchTheme.Colors.gold],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * watchState.currentMoonPhase.illumination, height: 4)
                        }
                    }
                    .frame(height: 4)

                    Text("\(Int(watchState.currentMoonPhase.illumination * 100))%")
                        .font(WatchTheme.Typography.caption2)
                        .foregroundStyle(WatchTheme.Colors.textSecondary)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(.horizontal, WatchTheme.Spacing.xl)
            }

            Spacer()
        }
        .background(WatchTheme.Colors.background)
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Moon Shape (Watch)

struct WatchMoonShape: Shape {
    var illumination: Double

    var animatableData: Double {
        get { illumination }
        set { illumination = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: false)

        let controlOffset = radius * (1 - 2 * illumination)
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - radius),
            control1: CGPoint(x: center.x + controlOffset, y: center.y + radius * 0.55),
            control2: CGPoint(x: center.x + controlOffset, y: center.y - radius * 0.55)
        )

        return path
    }
}
