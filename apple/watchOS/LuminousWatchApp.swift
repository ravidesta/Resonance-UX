// LuminousWatchApp.swift
// Luminous Integral Architecture™ — watchOS App
//
// Audiobook controls, daily reflection complication, somatic practice with haptic
// guidance, breathing exercise (Spatial Attunement), and minimal glanceable design.

import SwiftUI
#if os(watchOS)
import WatchKit
#endif

// MARK: - watchOS App Entry

@main
struct LuminousWatchApp: App {
    @StateObject private var appState = WatchAppState()

    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(appState)
        }
    }
}

// MARK: - Watch App State

@MainActor
final class WatchAppState: ObservableObject {
    @Published var isAudioPlaying = false
    @Published var currentChapterTitle = "Ch. 2: Four Quadrants"
    @Published var audioProgress: Double = 0.35
    @Published var playbackTime: TimeInterval = 347
    @Published var chapterDuration: TimeInterval = 3600
    @Published var dailyReflectionPrompt = "What perspective shift did you notice today?"
    @Published var practiceStreak: Int = 7
    @Published var breathPhase: BreathPhase = .inhale
    @Published var isBreathingActive = false
    @Published var breathTimeRemaining: Int = 0

    enum BreathPhase: String {
        case inhale  = "Breathe In"
        case hold    = "Hold"
        case exhale  = "Breathe Out"
        case rest    = "Rest"

        var hapticType: String {
            switch self {
            case .inhale:  return "start"
            case .hold:    return "click"
            case .exhale:  return "directionUp"
            case .rest:    return "stop"
            }
        }
    }

    func togglePlayback() {
        isAudioPlaying.toggle()
    }

    func skipForward() {
        playbackTime = min(playbackTime + 30, chapterDuration)
        audioProgress = playbackTime / chapterDuration
    }

    func skipBackward() {
        playbackTime = max(playbackTime - 15, 0)
        audioProgress = playbackTime / chapterDuration
    }

    func nextChapter() {
        currentChapterTitle = "Ch. 3: Levels"
        playbackTime = 0
        audioProgress = 0
    }

    func startBreathingPractice(durationSeconds: Int = 180) {
        isBreathingActive = true
        breathTimeRemaining = durationSeconds
        breathPhase = .inhale
        runBreathCycle()
    }

    func stopBreathingPractice() {
        isBreathingActive = false
        breathTimeRemaining = 0
    }

    private func runBreathCycle() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self, self.isBreathingActive else {
                    timer.invalidate()
                    return
                }
                self.breathTimeRemaining -= 1

                // 4-7-8 breathing pattern
                let cyclePosition = self.breathTimeRemaining % 19
                if cyclePosition >= 11 {
                    if self.breathPhase != .inhale {
                        self.breathPhase = .inhale
                        self.playHaptic(for: .inhale)
                    }
                } else if cyclePosition >= 4 {
                    if self.breathPhase != .hold {
                        self.breathPhase = .hold
                        self.playHaptic(for: .hold)
                    }
                } else {
                    if self.breathPhase != .exhale {
                        self.breathPhase = .exhale
                        self.playHaptic(for: .exhale)
                    }
                }

                if self.breathTimeRemaining <= 0 {
                    timer.invalidate()
                    self.isBreathingActive = false
                    self.playHaptic(for: .rest)
                }
            }
        }
    }

    func playHaptic(for phase: BreathPhase) {
        #if os(watchOS)
        let device = WKInterfaceDevice.current()
        switch phase {
        case .inhale:
            device.play(.start)
        case .hold:
            device.play(.click)
        case .exhale:
            device.play(.directionUp)
        case .rest:
            device.play(.success)
        }
        #endif
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Watch Main View

struct WatchMainView: View {
    @EnvironmentObject private var appState: WatchAppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Quick status header
                    watchStatusHeader

                    // Audiobook controls
                    NavigationLink(destination: WatchAudioPlayerView()) {
                        watchAudioCard
                    }
                    .buttonStyle(.plain)

                    // Daily reflection
                    NavigationLink(destination: WatchReflectionView()) {
                        watchReflectionCard
                    }
                    .buttonStyle(.plain)

                    // Somatic practice
                    NavigationLink(destination: WatchBreathingView()) {
                        watchPracticeCard
                    }
                    .buttonStyle(.plain)

                    // Practice streak
                    watchStreakCard
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Luminous")
        }
    }

    // MARK: Status Header

    private var watchStatusHeader: some View {
        HStack {
            ResonanceProgressRing(progress: appState.audioProgress, size: 28, lineWidth: 3)

            VStack(alignment: .leading, spacing: 1) {
                Text(appState.currentChapterTitle)
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(Int(appState.audioProgress * 100))% complete")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reading progress: \(Int(appState.audioProgress * 100)) percent, \(appState.currentChapterTitle)")
    }

    // MARK: Audio Card

    private var watchAudioCard: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "headphones")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Now Playing")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
            }

            Text(appState.currentChapterTitle)
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)

            HStack(spacing: 16) {
                Button { appState.skipBackward() } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 16))
                }
                .accessibilityLabel("Skip back 15 seconds")

                Button(action: appState.togglePlayback) {
                    Image(systemName: appState.isAudioPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.resonanceGoldPrimary)
                }
                .accessibilityLabel(appState.isAudioPlaying ? "Pause" : "Play")

                Button { appState.skipForward() } label: {
                    Image(systemName: "goforward.30")
                        .font(.system(size: 16))
                }
                .accessibilityLabel("Skip forward 30 seconds")
            }
            .foregroundStyle(.white)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.resonanceGreen800.opacity(0.6))
        )
    }

    // MARK: Reflection Card

    private var watchReflectionCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Daily Reflection")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }

            Text(appState.dailyReflectionPrompt)
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(3)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.resonanceGoldDark.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.resonanceGoldPrimary.opacity(0.2), lineWidth: 0.5)
                )
        )
        .accessibilityLabel("Daily reflection prompt: \(appState.dailyReflectionPrompt)")
    }

    // MARK: Practice Card

    private var watchPracticeCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.resonanceGreen400)
                Text("Spatial Attunement")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(Color.resonanceGreen400)
            }

            Text("3-min guided breathing with haptic cues")
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.resonanceGreen800.opacity(0.4))
        )
        .accessibilityLabel("Spatial Attunement breathing practice")
    }

    // MARK: Streak Card

    private var watchStreakCard: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color.resonanceGoldPrimary)
            Text("\(appState.practiceStreak) day streak")
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.resonanceGreen800.opacity(0.3))
        )
        .accessibilityLabel("Practice streak: \(appState.practiceStreak) days")
    }
}

// MARK: - Watch Audio Player View

struct WatchAudioPlayerView: View {
    @EnvironmentObject private var appState: WatchAppState

    var body: some View {
        VStack(spacing: 8) {
            Text(appState.currentChapterTitle)
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text("Luminous Integral Architecture")
                .font(ResonanceTypography.sansCaption2())
                .foregroundStyle(Color.resonanceGoldPrimary)

            ResonanceProgressBar(progress: appState.audioProgress, height: 3)
                .padding(.vertical, 4)

            HStack {
                Text(appState.formatTime(appState.playbackTime))
                Spacer()
                Text(appState.formatTime(appState.chapterDuration))
            }
            .font(ResonanceTypography.sansCaption2())
            .foregroundStyle(.white.opacity(0.4))
            .monospacedDigit()

            // Controls
            HStack(spacing: 16) {
                Button(action: appState.skipBackward) {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 20))
                }
                .accessibilityLabel("Skip back 15 seconds")

                Button(action: appState.togglePlayback) {
                    ZStack {
                        Circle()
                            .fill(Color.resonanceGoldPrimary)
                            .frame(width: 44, height: 44)

                        Image(systemName: appState.isAudioPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.resonanceGreen900)
                    }
                }
                .accessibilityLabel(appState.isAudioPlaying ? "Pause" : "Play")

                Button(action: appState.skipForward) {
                    Image(systemName: "goforward.30")
                        .font(.system(size: 20))
                }
                .accessibilityLabel("Skip forward 30 seconds")
            }
            .foregroundStyle(.white)

            // Chapter skip
            HStack {
                Button(action: {}) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 14))
                }
                .accessibilityLabel("Previous chapter")

                Spacer()

                Button(action: appState.nextChapter) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 14))
                }
                .accessibilityLabel("Next chapter")
            }
            .foregroundStyle(.white.opacity(0.6))
            .padding(.top, 4)
        }
        .padding(.horizontal, 8)
        .navigationTitle("Player")
    }
}

// MARK: - Watch Reflection View

struct WatchReflectionView: View {
    @EnvironmentObject private var appState: WatchAppState
    @State private var hasResponded = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.resonanceGoldPrimary)

                Text("Daily Reflection")
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)

                Text(appState.dailyReflectionPrompt)
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                if hasResponded {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.resonanceGreen400)
                        Text("Reflected")
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(Color.resonanceGreen400)
                    }
                    .padding(.top, 8)
                } else {
                    VStack(spacing: 8) {
                        Button("Record Response") {
                            // Open dictation or voice recording
                        }
                        .tint(Color.resonanceGoldPrimary)
                        .accessibilityLabel("Record your reflection")

                        Button("Mark as Reflected") {
                            hasResponded = true
                            #if os(watchOS)
                            WKInterfaceDevice.current().play(.success)
                            #endif
                        }
                        .tint(Color.resonanceGreen500)
                    }
                }
            }
            .padding(8)
        }
        .navigationTitle("Reflect")
    }
}

// MARK: - Watch Breathing View

struct WatchBreathingView: View {
    @EnvironmentObject private var appState: WatchAppState

    var body: some View {
        VStack(spacing: 12) {
            if appState.isBreathingActive {
                // Active breathing UI
                Spacer()

                Text(appState.breathPhase.rawValue)
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(Color.resonanceGoldPrimary)

                // Breathing circle with animation
                ZStack {
                    Circle()
                        .fill(Color.resonanceGreen500.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(Color.resonanceGreen500.opacity(0.3))
                        .frame(
                            width: appState.breathPhase == .inhale ? 90 : 50,
                            height: appState.breathPhase == .inhale ? 90 : 50
                        )
                        .animation(.easeInOut(duration: appState.breathPhase == .inhale ? 4 : 8), value: appState.breathPhase)
                }
                .accessibilityLabel("Breathing guide: \(appState.breathPhase.rawValue)")

                Text(appState.formatTime(TimeInterval(appState.breathTimeRemaining)))
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.5))
                    .monospacedDigit()

                Spacer()

                Button("End Practice") {
                    appState.stopBreathingPractice()
                }
                .tint(.red)
            } else {
                // Pre-practice UI
                Image(systemName: "figure.mind.and.body")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.resonanceGreen400)

                Text("Spatial Attunement")
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)

                Text("Guided breathing with haptic feedback")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)

                VStack(spacing: 8) {
                    Button("3 Minutes") {
                        appState.startBreathingPractice(durationSeconds: 180)
                    }
                    .tint(Color.resonanceGoldPrimary)

                    Button("5 Minutes") {
                        appState.startBreathingPractice(durationSeconds: 300)
                    }
                    .tint(Color.resonanceGreen500)

                    Button("1 Minute") {
                        appState.startBreathingPractice(durationSeconds: 60)
                    }
                    .tint(Color.resonanceGreen700)
                }
            }
        }
        .padding(4)
        .navigationTitle("Breathe")
    }
}

// MARK: - Complication Views

/// Data provider for watch complications showing daily reflection prompt.
struct ReflectionComplicationView: View {
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Reflect")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }
            Text(prompt)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.8))
                .lineLimit(2)
        }
        .accessibilityLabel("Daily reflection: \(prompt)")
    }
}

/// Circular complication showing practice streak.
struct StreakComplicationView: View {
    let streak: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.resonanceGreen800)
            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("\(streak)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel("Practice streak: \(streak) days")
    }
}

// MARK: - Preview

#if DEBUG
struct LuminousWatchApp_Previews: PreviewProvider {
    static var previews: some View {
        WatchMainView()
            .environmentObject(WatchAppState())
            .previewDisplayName("Watch Main")

        WatchBreathingView()
            .environmentObject(WatchAppState())
            .previewDisplayName("Breathing")

        WatchAudioPlayerView()
            .environmentObject(WatchAppState())
            .previewDisplayName("Audio Player")
    }
}
#endif
