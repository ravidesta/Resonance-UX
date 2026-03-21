// SoundscapeLibraryView.swift
// Haute Lumière — Soundscape Library (100+ Sounds)

import SwiftUI

struct SoundscapeLibraryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var soundscapes = SessionGenerator.generateSoundscapeLibrary()
    @State private var selectedCategory: SoundscapeCategory?
    @State private var showMixer = false

    var filteredSoundscapes: [Soundscape] {
        guard let cat = selectedCategory else { return soundscapes }
        return soundscapes.filter { $0.category == cat }
    }

    var groupedSoundscapes: [(String, [Soundscape])] {
        let grouped = Dictionary(grouping: filteredSoundscapes) { $0.category.rawValue }
        return grouped.sorted { $0.key < $1.key }
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
                    Text("\(soundscapes.count) Soundscapes")
                        .font(HLTypography.bodySmall)
                        .foregroundColor(.hlTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HLSpacing.lg)

                    // Active mixer
                    if !audioEngine.activeSoundscapes.isEmpty {
                        activeMixerCard
                    }

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HLSpacing.sm) {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(SoundscapeCategory.allCases, id: \.self) { cat in
                                FilterChip(title: cat.rawValue, isSelected: selectedCategory == cat) {
                                    selectedCategory = selectedCategory == cat ? nil : cat
                                }
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Binaural beats section
                    if selectedCategory == nil || selectedCategory == .binaural {
                        binauralBeatsSection
                    }

                    // Grouped soundscapes
                    ForEach(groupedSoundscapes, id: \.0) { category, scapes in
                        VStack(alignment: .leading, spacing: HLSpacing.md) {
                            Text(category)
                                .font(HLTypography.sectionTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
                                ForEach(scapes) { scape in
                                    SoundscapeTile(
                                        soundscape: scape,
                                        isActive: audioEngine.activeSoundscapes.contains { $0.type == scape.type },
                                        isNightMode: appState.isNightMode
                                    ) {
                                        if audioEngine.activeSoundscapes.contains(where: { $0.type == scape.type }) {
                                            audioEngine.activeSoundscapes.removeAll { $0.type == scape.type }
                                        } else {
                                            audioEngine.addSoundscape(scape.type)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Soundscapes")
    }

    // MARK: - Active Mixer
    private var activeMixerCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            HStack {
                Text("Now Playing")
                    .font(HLTypography.label)
                    .foregroundColor(.hlGold)
                Spacer()
                Button(action: { audioEngine.clearAllSoundscapes() }) {
                    Text("Clear All")
                        .font(HLTypography.caption)
                        .foregroundColor(.hlTextTertiary)
                }
            }

            ForEach(audioEngine.activeSoundscapes) { scape in
                HStack(spacing: HLSpacing.sm) {
                    Image(systemName: "waveform")
                        .foregroundColor(.hlGold)
                        .font(.system(size: 14))

                    Text(scape.type.displayName)
                        .font(HLTypography.bodySmall)
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)

                    Spacer()

                    // Volume slider placeholder
                    Capsule()
                        .fill(Color.hlGold.opacity(0.3))
                        .frame(width: 80, height: 4)

                    Button(action: { audioEngine.removeSoundscape(scape.id) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.hlTextTertiary)
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .fill(appState.isNightMode ? Color.hlGold.opacity(0.08) : Color.hlGold.opacity(0.05))
        )
        .hlGoldBorder()
        .padding(.horizontal, HLSpacing.lg)
    }

    // MARK: - Binaural Beats
    private var binauralBeatsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Binaural Beats")
                .font(HLTypography.sectionTitle)
                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

            VStack(spacing: HLSpacing.sm) {
                BinauralBeatRow(name: "Delta", frequency: "0.5-4 Hz", purpose: "Deep sleep & healing", color: Color(hex: "4A3A7A"), isNightMode: appState.isNightMode)
                BinauralBeatRow(name: "Theta", frequency: "4-8 Hz", purpose: "Meditation & creativity", color: Color(hex: "3A5A7A"), isNightMode: appState.isNightMode)
                BinauralBeatRow(name: "Alpha", frequency: "8-13 Hz", purpose: "Relaxation & calm focus", color: Color(hex: "3A7A5A"), isNightMode: appState.isNightMode)
                BinauralBeatRow(name: "Beta", frequency: "13-30 Hz", purpose: "Active focus & alertness", color: Color(hex: "7A5A3A"), isNightMode: appState.isNightMode)
                BinauralBeatRow(name: "Gamma", frequency: "30+ Hz", purpose: "Peak performance & insight", color: Color(hex: "7A3A5A"), isNightMode: appState.isNightMode)
            }
        }
        .padding(.horizontal, HLSpacing.lg)
    }
}

// MARK: - Soundscape Tile
struct SoundscapeTile: View {
    let soundscape: Soundscape
    let isActive: Bool
    let isNightMode: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .fill(isActive ? Color.hlGold.opacity(0.2) : (isNightMode ? Color.white.opacity(0.05) : Color.hlGreen50))
                        .frame(height: 56)
                    Image(systemName: soundscapeIcon)
                        .font(.system(size: 20))
                        .foregroundColor(isActive ? .hlGold : .hlGreen500)
                }

                Text(soundscape.name)
                    .font(HLTypography.caption)
                    .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                    .lineLimit(1)
            }
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .stroke(isActive ? Color.hlGold : .clear, lineWidth: 1.5)
                    .padding(.bottom, 20)
            )
        }
    }

    private var soundscapeIcon: String {
        switch soundscape.category {
        case .nature: return "leaf.fill"
        case .binaural: return "waveform.path.ecg"
        case .music: return "music.note"
        case .ambient: return "circle.dotted"
        }
    }
}

// MARK: - Binaural Beat Row
struct BinauralBeatRow: View {
    let name: String
    let frequency: String
    let purpose: String
    let color: Color
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 4, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(name)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                    Text(frequency)
                        .font(HLTypography.caption)
                        .foregroundColor(.hlTextTertiary)
                }
                Text(purpose)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(isNightMode ? .hlNightTextMuted : .hlTextSecondary)
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
        }
        .padding(HLSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(isNightMode ? Color.white.opacity(0.04) : .hlSurface)
        )
    }
}
