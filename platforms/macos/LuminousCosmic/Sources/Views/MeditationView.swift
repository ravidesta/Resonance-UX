// MeditationView.swift
// Luminous Cosmic Architecture™ — macOS Meditation
// Cosmic meditation player with animated visual atmosphere

import SwiftUI

struct MeditationView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedMeditation: MeditationSession?
    @State private var isPlaying: Bool = false
    @State private var elapsedSeconds: Int = 0
    @State private var breathPhase: BreathPhase = .inhale
    @State private var breathScale: CGFloat = 0.6
    @State private var cosmicPulse: Bool = false
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 0) {
            // Meditation list
            meditationList
                .frame(width: 280)

            Divider()
                .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

            // Player area
            if let meditation = selectedMeditation {
                playerView(meditation)
                    .frame(maxWidth: .infinity)
            } else {
                emptyPlayer
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Meditation List

    private var meditationList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.md) {
                Text("Meditations")
                    .font(ResonanceMacTheme.Typography.title2)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )
                    .padding(.horizontal, ResonanceMacTheme.Spacing.md)

                ForEach(MeditationSession.samples) { meditation in
                    meditationRow(meditation)
                }
            }
            .padding(.vertical, ResonanceMacTheme.Spacing.lg)
        }
        .background(
            appState.isNightMode
                ? ResonanceMacTheme.Colors.nightBackground.opacity(0.3)
                : ResonanceMacTheme.Colors.creamWarm.opacity(0.5)
        )
    }

    private func meditationRow(_ meditation: MeditationSession) -> some View {
        Button(action: {
            withAnimation(ResonanceMacTheme.Animation.spring) {
                selectedMeditation = meditation
                stopTimer()
            }
        }) {
            HStack(spacing: ResonanceMacTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: meditation.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: meditation.icon)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(ResonanceMacTheme.Colors.cream)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(meditation.title)
                        .font(ResonanceMacTheme.Typography.headline)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )
                        .lineLimit(1)

                    Text(meditation.subtitle)
                        .font(ResonanceMacTheme.Typography.caption)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                        .lineLimit(1)

                    Text("\(meditation.durationMinutes) min")
                        .font(ResonanceMacTheme.Typography.caption2)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                }

                Spacer()
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                    .fill(
                        selectedMeditation?.id == meditation.id
                            ? ResonanceMacTheme.Colors.gold.opacity(0.08)
                            : Color.clear
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, ResonanceMacTheme.Spacing.xs)
    }

    // MARK: - Player

    private func playerView(_ meditation: MeditationSession) -> some View {
        ZStack {
            // Cosmic animation background
            cosmicAnimationLayer(meditation)

            VStack(spacing: ResonanceMacTheme.Spacing.xxl) {
                Spacer()

                // Title
                VStack(spacing: ResonanceMacTheme.Spacing.sm) {
                    Text(meditation.title)
                        .font(ResonanceMacTheme.Typography.largeTitle)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )

                    Text(meditation.subtitle)
                        .font(ResonanceMacTheme.Typography.callout)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                }

                // Breathing orb
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ResonanceMacTheme.Colors.gold.opacity(0.15),
                                    ResonanceMacTheme.Colors.gold.opacity(0.05),
                                    Color.clear,
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 140
                            )
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(cosmicPulse ? 1.1 : 0.9)

                    // Inner orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: meditation.gradientColors.map { $0.opacity(0.6) } + [Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(breathScale)
                        .blur(radius: 2)

                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    ResonanceMacTheme.Colors.gold.opacity(0.5),
                                    ResonanceMacTheme.Colors.gold.opacity(0.1),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(breathScale)

                    // Breath label
                    if isPlaying {
                        Text(breathPhase.label)
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundStyle(ResonanceMacTheme.Colors.goldLight)
                            .tracking(2)
                            .transition(.opacity)
                    }
                }

                // Timer
                Text(formatTime(elapsedSeconds))
                    .font(ResonanceMacTheme.Typography.data)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                    .monospacedDigit()

                // Progress
                ProgressView(value: Double(elapsedSeconds), total: Double(meditation.durationMinutes * 60))
                    .tint(ResonanceMacTheme.Colors.gold)
                    .frame(maxWidth: 300)

                // Controls
                HStack(spacing: ResonanceMacTheme.Spacing.xl) {
                    Button(action: { stopTimer() }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(ResonanceMacTheme.Colors.mutedGreen.opacity(0.1)))
                    }
                    .buttonStyle(.plain)

                    Button(action: { togglePlayback() }) {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(ResonanceMacTheme.Colors.cream)
                            .frame(width: 64, height: 64)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [ResonanceMacTheme.Colors.gold, ResonanceMacTheme.Colors.goldDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: ResonanceMacTheme.Colors.gold.opacity(0.3), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)

                    Button(action: {}) {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 16))
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(ResonanceMacTheme.Colors.mutedGreen.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding(ResonanceMacTheme.Spacing.xl)
        }
    }

    // MARK: - Cosmic Animation Layer

    private func cosmicAnimationLayer(_ meditation: MeditationSession) -> some View {
        GeometryReader { geo in
            ZStack {
                // Floating orbs
                ForEach(0..<5) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    meditation.gradientColors[i % meditation.gradientColors.count].opacity(0.08),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80 + CGFloat(i) * 20
                            )
                        )
                        .frame(width: 160 + CGFloat(i) * 40, height: 160 + CGFloat(i) * 40)
                        .offset(
                            x: cosmicPulse
                                ? CGFloat.random(in: -100...100)
                                : CGFloat.random(in: -80...80),
                            y: cosmicPulse
                                ? CGFloat.random(in: -60...60)
                                : CGFloat.random(in: -40...40)
                        )
                        .blur(radius: 30 + CGFloat(i) * 5)
                        .position(
                            x: geo.size.width * (0.2 + CGFloat(i) * 0.15),
                            y: geo.size.height * (0.3 + CGFloat(i) * 0.1)
                        )
                }
            }
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: cosmicPulse)
            .onAppear { cosmicPulse = true }
        }
    }

    // MARK: - Empty Player

    private var emptyPlayer: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.md) {
            Image(systemName: "moon.stars")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight.opacity(0.5))

            Text("Choose a meditation to begin")
                .font(ResonanceMacTheme.Typography.body)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
        }
    }

    // MARK: - Timer Logic

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startBreathCycle()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedSeconds += 1
            }
        } else {
            timer?.invalidate()
        }
    }

    private func stopTimer() {
        isPlaying = false
        elapsedSeconds = 0
        timer?.invalidate()
        withAnimation(.easeOut(duration: 0.5)) {
            breathScale = 0.6
        }
    }

    private func startBreathCycle() {
        // 4 seconds inhale, 4 hold, 4 exhale cycle
        func cycle() {
            guard isPlaying else { return }
            breathPhase = .inhale
            withAnimation(.easeInOut(duration: 4)) { breathScale = 1.0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                guard self.isPlaying else { return }
                self.breathPhase = .hold
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    guard self.isPlaying else { return }
                    self.breathPhase = .exhale
                    withAnimation(.easeInOut(duration: 4)) { self.breathScale = 0.6 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { cycle() }
                }
            }
        }
        cycle()
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Breath Phase

enum BreathPhase {
    case inhale, hold, exhale

    var label: String {
        switch self {
        case .inhale: return "BREATHE IN"
        case .hold: return "HOLD"
        case .exhale: return "RELEASE"
        }
    }
}

// MARK: - Meditation Session Model

struct MeditationSession: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let durationMinutes: Int
    let gradientColors: [Color]

    static var samples: [MeditationSession] {
        [
            MeditationSession(
                title: "Lunar Stillness",
                subtitle: "Moon-guided body scan",
                icon: "moon",
                durationMinutes: 15,
                gradientColors: [ResonanceMacTheme.Colors.forestMid, ResonanceMacTheme.Colors.forestLight]
            ),
            MeditationSession(
                title: "Solar Breath",
                subtitle: "Energizing pranayama",
                icon: "sun.max",
                durationMinutes: 10,
                gradientColors: [ResonanceMacTheme.Colors.goldDark, ResonanceMacTheme.Colors.gold]
            ),
            MeditationSession(
                title: "Neptune's Dream",
                subtitle: "Deep imagination journey",
                icon: "water.waves",
                durationMinutes: 20,
                gradientColors: [Color(hex: 0x1B3A4B), ResonanceMacTheme.Colors.forestMid]
            ),
            MeditationSession(
                title: "Saturn's Discipline",
                subtitle: "Focused concentration",
                icon: "circle.circle",
                durationMinutes: 25,
                gradientColors: [ResonanceMacTheme.Colors.forestDeep, ResonanceMacTheme.Colors.mutedGreen]
            ),
            MeditationSession(
                title: "Venus Heart Opening",
                subtitle: "Loving-kindness practice",
                icon: "heart",
                durationMinutes: 12,
                gradientColors: [Color(hex: 0x4A2040), ResonanceMacTheme.Colors.goldDark]
            ),
            MeditationSession(
                title: "Cosmic Grounding",
                subtitle: "Earth-star connection",
                icon: "leaf",
                durationMinutes: 8,
                gradientColors: [ResonanceMacTheme.Colors.forestLight, ResonanceMacTheme.Colors.mutedGreen]
            ),
        ]
    }
}
