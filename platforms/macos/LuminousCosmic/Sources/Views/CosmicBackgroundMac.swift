// CosmicBackgroundMac.swift
// Luminous Cosmic Architecture™ — macOS Animated Background
// Subtle organic blobs optimized for desktop with gentle movement

import SwiftUI

struct CosmicBackgroundMac: View {
    let isNightMode: Bool
    @State private var phase1: Bool = false
    @State private var phase2: Bool = false
    @State private var phase3: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base
                Rectangle()
                    .fill(
                        isNightMode
                            ? ResonanceMacTheme.Colors.nightBackground
                            : ResonanceMacTheme.Colors.cream
                    )

                // Organic blob 1 — large, top-right
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: isNightMode
                                ? [ResonanceMacTheme.Colors.forestMid.opacity(0.2), Color.clear]
                                : [ResonanceMacTheme.Colors.forestLight.opacity(0.06), Color.clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 300
                        )
                    )
                    .frame(width: 600, height: 500)
                    .rotationEffect(.degrees(phase1 ? 5 : -5))
                    .offset(
                        x: geo.size.width * 0.3 + (phase1 ? 20 : -20),
                        y: -geo.size.height * 0.15 + (phase1 ? 10 : -10)
                    )
                    .blur(radius: 60)

                // Organic blob 2 — medium, bottom-left
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: isNightMode
                                ? [ResonanceMacTheme.Colors.gold.opacity(0.06), Color.clear]
                                : [ResonanceMacTheme.Colors.gold.opacity(0.04), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 350)
                    .rotationEffect(.degrees(phase2 ? -8 : 8))
                    .offset(
                        x: -geo.size.width * 0.25 + (phase2 ? -15 : 15),
                        y: geo.size.height * 0.25 + (phase2 ? 15 : -15)
                    )
                    .blur(radius: 50)

                // Organic blob 3 — small accent, center-left
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: isNightMode
                                ? [ResonanceMacTheme.Colors.forestLight.opacity(0.12), Color.clear]
                                : [ResonanceMacTheme.Colors.mutedGreen.opacity(0.04), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 260)
                    .rotationEffect(.degrees(phase3 ? 12 : -12))
                    .offset(
                        x: -geo.size.width * 0.1 + (phase3 ? 10 : -10),
                        y: -geo.size.height * 0.05 + (phase3 ? -8 : 8)
                    )
                    .blur(radius: 40)

                // Gold shimmer — very subtle, top
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                ResonanceMacTheme.Colors.goldLight.opacity(isNightMode ? 0.03 : 0.025),
                                Color.clear,
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 250
                        )
                    )
                    .frame(width: 500, height: 200)
                    .offset(
                        x: geo.size.width * 0.1,
                        y: -geo.size.height * 0.35
                    )
                    .blur(radius: 30)
                    .opacity(phase1 ? 0.8 : 1.0)

                // Noise texture overlay (simulated with a grid)
                Canvas { context, size in
                    // Subtle dot pattern for texture
                    for x in stride(from: 0, to: size.width, by: 4) {
                        for y in stride(from: 0, to: size.height, by: 4) {
                            let hash = (Int(x) * 374761393 + Int(y) * 668265263) &* 1274126177
                            let normalized = Double(abs(hash % 1000)) / 1000.0
                            if normalized > 0.97 {
                                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                                context.fill(
                                    Path(ellipseIn: rect),
                                    with: .color(
                                        isNightMode
                                            ? ResonanceMacTheme.Colors.cream.opacity(0.02)
                                            : ResonanceMacTheme.Colors.forestDeep.opacity(0.01)
                                    )
                                )
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: phase1)
            .animation(.easeInOut(duration: 15).repeatForever(autoreverses: true), value: phase2)
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: phase3)
            .onAppear {
                phase1 = true
                phase2 = true
                phase3 = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Day Mode") {
    CosmicBackgroundMac(isNightMode: false)
        .frame(width: 800, height: 600)
}

#Preview("Night Mode") {
    CosmicBackgroundMac(isNightMode: true)
        .frame(width: 800, height: 600)
}
