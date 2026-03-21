// BreathingLibraryView.swift
// Haute Lumière — Guided Breathing Library (100+ Experiences)

import SwiftUI

struct BreathingLibraryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var sessions = SessionGenerator.generateBreathingLibrary()
    @State private var selectedLevel: ExperienceLevel?
    @State private var selectedPurpose: BreathingPurpose?
    @State private var showingSession: BreathingSession?

    var filteredSessions: [BreathingSession] {
        sessions.filter { s in
            let levelMatch = selectedLevel == nil || s.difficulty == selectedLevel
            let purposeMatch = selectedPurpose == nil || s.purpose == selectedPurpose
            return levelMatch && purposeMatch
        }
    }

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Count
                    Text("\(sessions.count) Breathing Experiences")
                        .font(HLTypography.bodySmall)
                        .foregroundColor(.hlTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HLSpacing.lg)

                    // Level tabs
                    levelTabsView

                    // Purpose filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HLSpacing.sm) {
                            FilterChip(title: "All", isSelected: selectedPurpose == nil) {
                                selectedPurpose = nil
                            }
                            ForEach(BreathingPurpose.allCases, id: \.self) { purpose in
                                FilterChip(title: purpose.rawValue, isSelected: selectedPurpose == purpose) {
                                    selectedPurpose = selectedPurpose == purpose ? nil : purpose
                                }
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Techniques overview
                    if selectedLevel == nil {
                        techniquesOverview
                    }

                    // Session list
                    LazyVStack(spacing: HLSpacing.sm) {
                        ForEach(filteredSessions.prefix(40)) { session in
                            BreathingSessionRow(session: session) {
                                showingSession = session
                            }
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Guided Breathing")
        .sheet(item: $showingSession) { session in
            BreathingPlayerView(session: session)
        }
    }

    // MARK: - Level Tabs
    private var levelTabsView: some View {
        HStack(spacing: HLSpacing.sm) {
            LevelTab(title: "All", count: sessions.count, isSelected: selectedLevel == nil) {
                selectedLevel = nil
            }
            LevelTab(title: "Beginner", count: 12, isSelected: selectedLevel == .beginner) {
                selectedLevel = .beginner
            }
            LevelTab(title: "Moderate", count: 6, isSelected: selectedLevel == .intermediate) {
                selectedLevel = .intermediate
            }
            LevelTab(title: "Qi Gung", count: 6, isSelected: selectedLevel == .advanced) {
                selectedLevel = .advanced
            }
        }
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Techniques Overview
    private var techniquesOverview: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Technique Mastery Path")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            VStack(spacing: HLSpacing.sm) {
                TechniquePathCard(
                    level: "Beginner",
                    count: 12,
                    description: "Foundation breathing — Box, 4-7-8, Diaphragmatic, and more",
                    color: .hlGreen400,
                    isNightMode: appState.isNightMode
                )
                TechniquePathCard(
                    level: "Moderate",
                    count: 6,
                    description: "Pranayama — Ujjayi, Kapalabhati, Bhramari, Nadi Shodhana",
                    color: .hlAzure,
                    isNightMode: appState.isNightMode
                )
                TechniquePathCard(
                    level: "Advanced · Qi Gung",
                    count: 6,
                    description: "Dantian, Reverse, Bone Marrow, Microcosmic Orbit, Embryonic, Five Elements",
                    color: .hlGold,
                    isNightMode: appState.isNightMode
                )
            }
        }
        .padding(.horizontal, HLSpacing.lg)
    }
}

// MARK: - Level Tab
struct LevelTab: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(title)
                    .font(HLTypography.label)
                Text("\(count)")
                    .font(HLTypography.caption)
            }
            .foregroundColor(isSelected ? .hlGreen900 : .hlTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(isSelected ? Color.hlGold : Color.hlGreen100)
            )
        }
    }
}

// MARK: - Technique Path Card
struct TechniquePathCard: View {
    let level: String
    let count: Int
    let description: String
    let color: Color
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 4, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(level)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                    Text("· \(count) techniques")
                        .font(HLTypography.caption)
                        .foregroundColor(.hlTextTertiary)
                }
                Text(description)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(isNightMode ? .hlNightTextMuted : .hlTextSecondary)
            }

            Spacer()
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
    }
}

// MARK: - Session Row
struct BreathingSessionRow: View {
    let session: BreathingSession
    let onTap: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: HLSpacing.md) {
                ZStack {
                    Circle()
                        .fill(levelColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "wind")
                        .font(.system(size: 18))
                        .foregroundColor(levelColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: HLSpacing.sm) {
                        Text("\(session.duration) min")
                        Text("·")
                        Text(session.difficulty.rawValue)
                        Text("·")
                        Text(session.purpose.rawValue)
                    }
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.hlGold)
            }
            .padding(HLSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(appState.isNightMode ? Color.white.opacity(0.04) : .hlSurface)
            )
        }
    }

    private var levelColor: Color {
        switch session.difficulty {
        case .beginner: return .hlGreen400
        case .intermediate: return .hlAzure
        case .advanced: return .hlGold
        }
    }
}

// MARK: - Breathing Player
struct BreathingPlayerView: View {
    let session: BreathingSession
    @EnvironmentObject var audioEngine: AudioEngine
    @Environment(\.dismiss) var dismiss
    @State private var isPlaying = false
    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.6

    enum BreathPhase: String {
        case inhale = "Breathe In"
        case hold = "Hold"
        case exhale = "Breathe Out"
        case pause = "Pause"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "1B402E")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: HLSpacing.xxl) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.hlNightText)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(session.technique.rawValue)
                            .font(HLTypography.label)
                            .foregroundColor(.hlGoldLight)
                        Text(session.purpose.rawValue)
                            .font(HLTypography.caption)
                            .foregroundColor(.hlNightTextMuted)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .foregroundColor(.hlGold)
                    }
                }
                .padding(.horizontal, HLSpacing.lg)

                Spacer()

                // Breathing circle
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color.hlGold.opacity(0.15), lineWidth: 2)
                        .frame(width: 240, height: 240)

                    // Animated breathing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.hlGold.opacity(0.3), .hlGold.opacity(0.05)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)

                    // Phase text
                    VStack(spacing: HLSpacing.sm) {
                        Text(breathPhase.rawValue)
                            .font(HLTypography.serifMedium(24))
                            .foregroundColor(.hlGoldLight)

                        Text(session.title)
                            .font(HLTypography.caption)
                            .foregroundColor(.hlNightTextMuted)
                    }
                }

                Spacer()

                // Technique description
                Text(session.technique.description)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.xl)

                // Controls
                HStack(spacing: HLSpacing.xxl) {
                    Button(action: {
                        if isPlaying {
                            audioEngine.pause()
                        } else {
                            audioEngine.play(session: session.title, type: .guidedBreathing, durationMinutes: session.duration)
                            startBreathAnimation()
                        }
                        isPlaying.toggle()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.hlGold)
                                .frame(width: 72, height: 72)
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.hlGreen900)
                        }
                    }
                }
                .padding(.bottom, HLSpacing.xxl)
            }
        }
    }

    private func startBreathAnimation() {
        breathPhase = .inhale
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            circleScale = circleScale == 0.6 ? 1.0 : 0.6
        }
    }
}
