// YogaNidraLibraryView.swift
// Haute Lumière — Yoga Nidra Library (100+ Sessions)

import SwiftUI

struct YogaNidraLibraryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var sessions = SessionGenerator.generateYogaNidraLibrary()
    @State private var selectedTheme: YogaNidraTheme?
    @State private var selectedDuration: Int?
    @State private var showingSession: YogaNidraSession?
    @State private var searchText = ""

    let durations = [15, 20, 25, 30, 45, 60]

    var filteredSessions: [YogaNidraSession] {
        sessions.filter { session in
            let themeMatch = selectedTheme == nil || session.theme == selectedTheme
            let durationMatch = selectedDuration == nil || session.duration == selectedDuration
            let searchMatch = searchText.isEmpty || session.title.localizedCaseInsensitiveContains(searchText)
            return themeMatch && durationMatch && searchMatch
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
                    // Session count
                    Text("\(sessions.count) Sessions Available")
                        .font(HLTypography.bodySmall)
                        .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HLSpacing.lg)

                    // Theme filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HLSpacing.sm) {
                            FilterChip(title: "All Themes", isSelected: selectedTheme == nil) {
                                selectedTheme = nil
                            }
                            ForEach(YogaNidraTheme.allCases, id: \.self) { theme in
                                FilterChip(title: theme.rawValue, isSelected: selectedTheme == theme) {
                                    selectedTheme = selectedTheme == theme ? nil : theme
                                }
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Duration filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HLSpacing.sm) {
                            FilterChip(title: "Any Length", isSelected: selectedDuration == nil) {
                                selectedDuration = nil
                            }
                            ForEach(durations, id: \.self) { dur in
                                FilterChip(title: "\(dur) min", isSelected: selectedDuration == dur) {
                                    selectedDuration = selectedDuration == dur ? nil : dur
                                }
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Featured section
                    if selectedTheme == nil && selectedDuration == nil {
                        featuredSection
                    }

                    // Session list
                    LazyVStack(spacing: HLSpacing.sm) {
                        ForEach(filteredSessions.prefix(50)) { session in
                            YogaNidraSessionRow(session: session) {
                                showingSession = session
                            }
                        }

                        if filteredSessions.count > 50 {
                            Text("Showing 50 of \(filteredSessions.count) sessions")
                                .font(HLTypography.bodySmall)
                                .foregroundColor(.hlTextTertiary)
                                .padding(.top, HLSpacing.md)
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Yoga Nidra")
        .sheet(item: $showingSession) { session in
            YogaNidraPlayerView(session: session)
        }
    }

    // MARK: - Featured
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Featured Journeys")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                .padding(.horizontal, HLSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HLSpacing.md) {
                    ForEach(sessions.prefix(5)) { session in
                        FeaturedNidraCard(session: session) {
                            showingSession = session
                        }
                    }
                }
                .padding(.horizontal, HLSpacing.lg)
            }
        }
    }
}

// MARK: - Session Row
struct YogaNidraSessionRow: View {
    let session: YogaNidraSession
    let onTap: () -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: HLSpacing.md) {
                // Theme icon
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.sm)
                        .fill(themeGradient)
                        .frame(width: 48, height: 48)
                    Image(systemName: themeIcon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: HLSpacing.sm) {
                        Text("\(session.duration) min")
                            .font(HLTypography.caption)
                        Text("·")
                        Text(session.theme.rawValue)
                            .font(HLTypography.caption)
                        if session.binauralFrequency != nil {
                            Text("·")
                            Image(systemName: "waveform")
                                .font(.system(size: 10))
                        }
                    }
                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextTertiary)
                }

                Spacer()

                if session.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.hlGold)
                        .font(.system(size: 14))
                }

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.hlGold)
            }
            .padding(HLSpacing.sm)
            .padding(.trailing, HLSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(appState.isNightMode ? Color.white.opacity(0.04) : .hlSurface)
            )
        }
    }

    private var themeGradient: LinearGradient {
        switch session.theme {
        case .deepSleep: return LinearGradient(colors: [Color(hex: "1a1a3e"), Color(hex: "2d2d6e")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .stressRelease: return LinearGradient(colors: [.hlAzure, .hlAzureLight], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .emotionalHealing: return LinearGradient(colors: [Color(hex: "7B5EA7"), Color(hex: "A87BC4")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .grounding: return LinearGradient(colors: [.hlGreen700, .hlGreen500], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.hlGreen600, .hlGreen400], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var themeIcon: String {
        switch session.theme {
        case .deepSleep: return "moon.zzz.fill"
        case .stressRelease: return "wind"
        case .emotionalHealing: return "heart.fill"
        case .bodyRestoration: return "figure.mind.and.body"
        case .innerPeace: return "leaf.fill"
        case .creativity: return "paintbrush.fill"
        case .confidence: return "star.fill"
        case .gratitude: return "sun.max.fill"
        case .selfLove: return "heart.circle.fill"
        case .abundance: return "sparkles"
        case .clarity: return "diamond.fill"
        case .energyBalance: return "circle.dotted"
        case .release: return "wind"
        case .grounding: return "mountain.2.fill"
        case .expansion: return "arrow.up.left.and.arrow.down.right"
        }
    }
}

// MARK: - Featured Card
struct FeaturedNidraCard: View {
    let session: YogaNidraSession
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: HLSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "0A1C14"), Color(hex: "1B402E")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 100)

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.hlGoldLight.opacity(0.6))
                }

                Text(session.title)
                    .font(HLTypography.label)
                    .foregroundColor(.hlTextPrimary)
                    .lineLimit(1)

                Text("\(session.duration) min")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }
            .frame(width: 160)
        }
    }
}

// MARK: - Player
struct YogaNidraPlayerView: View {
    let session: YogaNidraSession
    @EnvironmentObject var audioEngine: AudioEngine
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            // Immersive background
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21"), Color(hex: "0D2118")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Fireflies
            ForEach(0..<15, id: \.self) { i in
                FireflyParticle(index: i)
            }

            VStack(spacing: HLSpacing.xxl) {
                // Close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.hlNightText)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.system(size: 18))
                            .foregroundColor(.hlGold)
                    }
                }
                .padding(.horizontal, HLSpacing.lg)

                Spacer()

                // Session info
                VStack(spacing: HLSpacing.md) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(.hlGoldLight.opacity(0.8))

                    Text(session.title)
                        .font(HLTypography.serifMedium(28))
                        .foregroundColor(.hlGoldLight)
                        .multilineTextAlignment(.center)

                    Text(session.subtitle)
                        .font(HLTypography.body)
                        .foregroundColor(.hlNightTextMuted)

                    HStack(spacing: HLSpacing.md) {
                        Label("\(session.duration) min", systemImage: "clock")
                        Label(session.theme.rawValue, systemImage: "sparkles")
                        if session.binauralFrequency != nil {
                            Label("Theta", systemImage: "waveform")
                        }
                    }
                    .font(HLTypography.caption)
                    .foregroundColor(.hlNightTextMuted)
                }

                Spacer()

                // Intention
                VStack(spacing: HLSpacing.sm) {
                    Text("Sankalpa")
                        .font(HLTypography.caption)
                        .foregroundColor(.hlGold)
                    Text(session.intention)
                        .font(HLTypography.serifItalic(18))
                        .foregroundColor(.hlNightText.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, HLSpacing.xl)

                Spacer()

                // Controls
                VStack(spacing: HLSpacing.lg) {
                    // Progress
                    VStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.hlGold)
                                    .frame(width: geo.size.width * audioEngine.progress, height: 4)
                            }
                        }
                        .frame(height: 4)

                        HStack {
                            Text(audioEngine.elapsedFormatted)
                            Spacer()
                            Text(audioEngine.durationFormatted)
                        }
                        .font(HLTypography.caption)
                        .foregroundColor(.hlNightTextMuted)
                    }

                    // Play controls
                    HStack(spacing: HLSpacing.xxl) {
                        Button(action: {
                            audioEngine.seek(to: max(0, audioEngine.progress - 0.05))
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.system(size: 24))
                                .foregroundColor(.hlNightText)
                        }

                        Button(action: {
                            if isPlaying {
                                audioEngine.pause()
                            } else {
                                audioEngine.play(session: session.title, type: .yogaNidra, durationMinutes: session.duration)
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

                        Button(action: {
                            audioEngine.seek(to: min(1, audioEngine.progress + 0.05))
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.system(size: 24))
                                .foregroundColor(.hlNightText)
                        }
                    }
                }
                .padding(.horizontal, HLSpacing.xl)
                .padding(.bottom, HLSpacing.xxl)
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(HLTypography.caption)
                .foregroundColor(isSelected ? .hlGreen900 : .hlTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isSelected ? Color.hlGold : Color.hlGreen100)
                )
        }
    }
}
