// BioluminescentEffects.swift
// Resonance UX — Living visual effects
// Breathing blobs, chromatic orbs, particle fields, paper noise

import SwiftUI

// MARK: - Breathing Blob (Ambient Background)

struct BreathingBlob: View {
    let color: Color
    let size: CGFloat
    let delay: Double

    @State private var phase: Double = 0

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [color.opacity(0.25), color.opacity(0)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.7
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 60)
            .scaleEffect(1.0 + 0.05 * sin(phase))
            .offset(
                x: 10 * sin(phase * 0.7),
                y: 15 * cos(phase * 0.5)
            )
            .onAppear {
                withAnimation(.linear(duration: 16).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
    }
}

// MARK: - Chromatic Orb (Status Indicator — Bioluminescent)

struct ChromaticOrb: View {
    let color: Color
    let size: CGFloat
    let pulse: Bool

    @State private var glowing = false

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: size * 2.5, height: size * 2.5)
                .blur(radius: size * 0.8)
                .scaleEffect(glowing ? 1.15 : 1.0)

            // Inner orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.9), color.opacity(0.5)],
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            // Highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.3, height: size * 0.3)
                .offset(x: -size * 0.12, y: -size * 0.12)
        }
        .onAppear {
            guard pulse else { return }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowing = true
            }
        }
    }
}

// MARK: - Living Surface (Breathing Card)

struct LivingSurface<Content: View>: View {
    let accentColor: Color
    let content: () -> Content

    @Environment(\.colorScheme) var scheme
    @State private var breathe: Double = 0

    var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: ResonanceSpacing.cornerStandard)
                    .fill(scheme == .dark
                        ? Color.white.opacity(0.03 + 0.015 * sin(breathe))
                        : Color.white.opacity(0.85)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceSpacing.cornerStandard)
                            .stroke(
                                scheme == .dark
                                    ? Color.white.opacity(0.06 + 0.03 * sin(breathe))
                                    : ResonanceColors.borderLight,
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: scheme == .dark
                            ? Color.black.opacity(0.5)
                            : accentColor.opacity(0.08),
                        radius: 24, x: 0, y: 8
                    )
            )
            .onAppear {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    breathe = .pi * 2
                }
            }
    }
}

// MARK: - Paper Noise Texture Overlay

struct PaperNoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<Int(size.width * size.height * 0.003) {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let gray = CGFloat.random(in: 0.3...0.7)
                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(Color(white: gray, opacity: 0.035))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Bioluminescent Background

struct BioluminescentBackground: View {
    let portfolioColor: Color

    @Environment(\.colorScheme) var scheme

    var body: some View {
        ZStack {
            // Base
            (scheme == .dark ? ResonanceColors.bgDeep : ResonanceColors.bgBase)
                .ignoresSafeArea()

            // Breathing blobs
            BreathingBlob(color: ResonanceColors.green200, size: 350, delay: 0)
                .position(x: 100, y: 200)
                .opacity(scheme == .dark ? 0.15 : 0.3)

            BreathingBlob(color: portfolioColor, size: 400, delay: -5)
                .position(x: 300, y: 500)
                .opacity(scheme == .dark ? 0.1 : 0.2)

            BreathingBlob(color: ResonanceColors.goldPrimary, size: 300, delay: -10)
                .position(x: 500, y: 150)
                .opacity(scheme == .dark ? 0.08 : 0.15)

            // Paper noise
            PaperNoiseOverlay()
                .ignoresSafeArea()
        }
    }
}

// MARK: - Glass Panel

struct GlassPanel: ViewModifier {
    @Environment(\.colorScheme) var scheme

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ResonanceSpacing.cornerCompact))
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceSpacing.cornerCompact)
                    .stroke(
                        scheme == .dark
                            ? Color.white.opacity(0.08)
                            : ResonanceColors.borderLight,
                        lineWidth: 0.5
                    )
            )
    }
}

extension View {
    func glassPanel() -> some View {
        modifier(GlassPanel())
    }
}

// MARK: - Indicator Light (Discrete Bioluminescent)

struct IndicatorLight: View {
    let status: BackupStatus
    let size: CGFloat

    var color: Color {
        switch status {
        case .synced: return ResonanceColors.growthGreen
        case .syncing: return ResonanceColors.warmthAmber
        case .error: return ResonanceColors.rhythmCoral
        case .idle: return ResonanceColors.strategicBlue
        case .queued: return ResonanceColors.signalTeal
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * 2.2, height: size * 2.2)
                .blur(radius: size * 0.6)

            Circle()
                .fill(color)
                .frame(width: size, height: size)
        }
    }
}

enum BackupStatus: String, Codable, CaseIterable {
    case synced = "Synced"
    case syncing = "Syncing"
    case error = "Error"
    case idle = "Idle"
    case queued = "Queued"
}
