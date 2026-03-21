// WatchBreathingView.swift
// Resonance — Design for the Exhale
//
// Guided breathing exercise for Apple Watch — the heart of Resonance.

import SwiftUI

#if os(watchOS)
struct WatchBreathingView: View {
    let theme: ResonanceTheme
    @State private var isBreathing = false
    @State private var phase: BreathPhase = .ready
    @State private var cycleCount = 0

    enum BreathPhase: String {
        case ready = "Begin when ready"
        case inhale = "Breathe in"
        case hold = "Hold gently"
        case exhale = "Release"
    }

    var body: some View {
        ZStack {
            theme.bgBase.ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                // Breathing circle
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(theme.goldPrimary.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isBreathing ? 1.2 : 0.8)

                    // Middle ring
                    Circle()
                        .stroke(theme.goldPrimary.opacity(0.2), lineWidth: 1)
                        .frame(width: 90, height: 90)
                        .scaleEffect(isBreathing ? 1.15 : 0.85)

                    // Inner circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.goldLight.opacity(0.5),
                                    theme.goldPrimary.opacity(0.2)
                                ],
                                center: .center,
                                startRadius: 5,
                                endRadius: 35
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(isBreathing ? 1.1 : 0.9)

                    // Center dot
                    Circle()
                        .fill(theme.goldPrimary)
                        .frame(width: 8, height: 8)
                }
                .animation(.easeInOut(duration: 4), value: isBreathing)

                // Phase label
                Text(phase.rawValue)
                    .font(ResonanceFont.watchBody)
                    .foregroundStyle(theme.textMuted)

                if cycleCount > 0 {
                    Text("\(cycleCount) cycles")
                        .font(ResonanceFont.watchCaption)
                        .foregroundStyle(theme.textLight)
                }

                Spacer()

                // Start/Stop button
                Button {
                    if phase == .ready {
                        startBreathing()
                    } else {
                        stopBreathing()
                    }
                } label: {
                    Text(phase == .ready ? "Begin" : "End")
                        .font(ResonanceFont.watchBody)
                        .foregroundStyle(theme.goldPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .background {
                    Capsule()
                        .fill(theme.goldPrimary.opacity(0.12))
                }
            }
            .padding()
        }
        .navigationTitle("Breathe")
    }

    private func startBreathing() {
        breatheCycle()
    }

    private func stopBreathing() {
        phase = .ready
        isBreathing = false
    }

    private func breatheCycle() {
        // Inhale
        phase = .inhale
        withAnimation(.easeInOut(duration: 4)) {
            isBreathing = true
        }

        // Hold
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard phase != .ready else { return }
            phase = .hold
        }

        // Exhale
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            guard phase != .ready else { return }
            phase = .exhale
            withAnimation(.easeInOut(duration: 4)) {
                isBreathing = false
            }
        }

        // Next cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
            guard phase != .ready else { return }
            cycleCount += 1
            breatheCycle()
        }
    }
}
#endif
