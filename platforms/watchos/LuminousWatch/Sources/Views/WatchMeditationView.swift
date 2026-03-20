// WatchMeditationView.swift
// Luminous Cosmic Architecture™ — watchOS Meditation
// Breathing timer with cosmic animation for small screen

import SwiftUI

struct WatchMeditationView: View {
    @State private var isActive: Bool = false
    @State private var breathPhase: WatchBreathPhase = .ready
    @State private var breathScale: CGFloat = 0.5
    @State private var elapsedSeconds: Int = 0
    @State private var ringProgress: Double = 0
    @State private var timer: Timer?

    private let totalDuration: Int = 180 // 3 minutes

    var body: some View {
        VStack(spacing: WatchTheme.Spacing.md) {
            if isActive {
                activeView
            } else {
                readyView
            }
        }
        .background(WatchTheme.Colors.background)
    }

    // MARK: - Ready State

    private var readyView: some View {
        VStack(spacing: WatchTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "moon.stars")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundStyle(WatchTheme.Colors.gold)

            Text("Cosmic Breath")
                .font(WatchTheme.Typography.title)
                .foregroundStyle(WatchTheme.Colors.textPrimary)

            Text("3 minutes")
                .font(WatchTheme.Typography.caption)
                .foregroundStyle(WatchTheme.Colors.textSecondary)

            Spacer()

            Button(action: { startMeditation() }) {
                Text("Begin")
                    .font(WatchTheme.Typography.headline)
                    .foregroundStyle(WatchTheme.Colors.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, WatchTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: WatchTheme.Radius.lg)
                            .fill(
                                LinearGradient(
                                    colors: [WatchTheme.Colors.gold, WatchTheme.Colors.goldDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, WatchTheme.Spacing.xl)
        }
    }

    // MARK: - Active State

    private var activeView: some View {
        VStack(spacing: WatchTheme.Spacing.md) {
            Spacer()

            // Breathing orb with progress ring
            ZStack {
                // Progress ring
                Circle()
                    .strokeBorder(WatchTheme.Colors.surface, lineWidth: 3)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        LinearGradient(
                            colors: [WatchTheme.Colors.goldDark, WatchTheme.Colors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                // Inner glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                WatchTheme.Colors.gold.opacity(0.2),
                                WatchTheme.Colors.gold.opacity(0.05),
                                Color.clear,
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(breathScale)

                // Core orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                WatchTheme.Colors.goldLight.opacity(0.5),
                                WatchTheme.Colors.surfaceAccent.opacity(0.8),
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 20
                        )
                    )
                    .frame(width: 36, height: 36)
                    .scaleEffect(breathScale)
                    .overlay(
                        Circle()
                            .strokeBorder(WatchTheme.Colors.gold.opacity(0.5), lineWidth: 0.5)
                            .scaleEffect(breathScale)
                    )
            }

            // Breath label
            Text(breathPhase.label)
                .font(WatchTheme.Typography.caption)
                .foregroundStyle(WatchTheme.Colors.goldLight)
                .tracking(2)
                .animation(.easeInOut(duration: 0.3), value: breathPhase)

            // Timer
            Text(formatTime(elapsedSeconds))
                .font(WatchTheme.Typography.data)
                .foregroundStyle(WatchTheme.Colors.textSecondary)
                .monospacedDigit()

            Spacer()

            // Stop button
            Button(action: { stopMeditation() }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(WatchTheme.Colors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle().fill(WatchTheme.Colors.surface)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Timer Logic

    private func startMeditation() {
        isActive = true
        elapsedSeconds = 0
        startBreathCycle()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
            withAnimation(.linear(duration: 1)) {
                ringProgress = Double(elapsedSeconds) / Double(totalDuration)
            }
            if elapsedSeconds >= totalDuration {
                stopMeditation()
            }
        }
    }

    private func stopMeditation() {
        timer?.invalidate()
        timer = nil
        withAnimation(.easeOut(duration: 0.5)) {
            isActive = false
            breathScale = 0.5
            breathPhase = .ready
            ringProgress = 0
        }
    }

    private func startBreathCycle() {
        func cycle() {
            guard isActive else { return }
            breathPhase = .inhale
            withAnimation(.easeInOut(duration: 4)) { breathScale = 1.0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                guard self.isActive else { return }
                self.breathPhase = .hold
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    guard self.isActive else { return }
                    self.breathPhase = .exhale
                    withAnimation(.easeInOut(duration: 4)) { self.breathScale = 0.5 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { cycle() }
                }
            }
        }
        cycle()
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

enum WatchBreathPhase {
    case ready, inhale, hold, exhale

    var label: String {
        switch self {
        case .ready: return "READY"
        case .inhale: return "BREATHE IN"
        case .hold: return "HOLD"
        case .exhale: return "RELEASE"
        }
    }
}
