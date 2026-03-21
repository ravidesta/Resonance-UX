// VisualizationView.swift
// Haute Lumière — Generative Visualization Meditations

import SwiftUI

struct VisualizationView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var audioEngine: AudioEngine
    @State private var currentVisualization: VisualizationMeditation?
    @State private var savedVisualizations: [VisualizationMeditation] = []
    @State private var selectedTheme: VisualizationTheme?
    @State private var isGenerating = false
    @State private var showingSaved = false

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Header
                    VStack(spacing: HLSpacing.sm) {
                        Text("Every Journey Is Unique")
                            .font(HLTypography.sectionTitle)
                            .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                        Text("Each visualization is generated fresh — never repeated. Save your favorites.")
                            .font(HLTypography.bodySmall)
                            .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Generate button
                    Button(action: generateNew) {
                        HStack(spacing: HLSpacing.sm) {
                            if isGenerating {
                                ProgressView()
                                    .tint(.hlGreen900)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(isGenerating ? "Creating Your Journey..." : "Generate New Visualization")
                                .font(HLTypography.sansMedium(15))
                        }
                        .foregroundColor(.hlGreen900)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.hlGold)
                        .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                    }
                    .padding(.horizontal, HLSpacing.lg)
                    .disabled(isGenerating)

                    // Theme selection
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        Text("Choose a Theme")
                            .font(HLTypography.label)
                            .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                            .padding(.horizontal, HLSpacing.lg)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: HLSpacing.sm) {
                                ForEach(VisualizationTheme.allCases, id: \.self) { theme in
                                    ThemeCard(
                                        theme: theme,
                                        isSelected: selectedTheme == theme
                                    ) {
                                        selectedTheme = theme
                                    }
                                }
                            }
                            .padding(.horizontal, HLSpacing.lg)
                        }
                    }

                    // Current visualization
                    if let viz = currentVisualization {
                        currentVisualizationCard(viz)
                    }

                    // Saved section
                    if !savedVisualizations.isEmpty {
                        VStack(alignment: .leading, spacing: HLSpacing.md) {
                            HStack {
                                Text("Saved Favorites")
                                    .font(HLTypography.sectionTitle)
                                    .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                                Spacer()
                                Text("\(savedVisualizations.count)")
                                    .font(HLTypography.label)
                                    .foregroundColor(.hlGold)
                            }

                            ForEach(savedVisualizations) { viz in
                                SavedVisualizationRow(visualization: viz, isNightMode: appState.isNightMode)
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Visualization")
    }

    // MARK: - Generate
    private func generateNew() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let prefs = UserPreferences()
            var viz = SessionGenerator.generateUniqueVisualization(
                preferences: prefs,
                phase: appState.currentCyclePhase
            )
            if let theme = selectedTheme {
                viz = VisualizationMeditation(
                    title: viz.title,
                    prompt: viz.generatedPrompt,
                    duration: viz.duration,
                    theme: theme,
                    elements: viz.sceneElements,
                    soundscape: viz.backgroundSoundscape
                )
            }
            currentVisualization = viz
            isGenerating = false
        }
    }

    // MARK: - Current Visualization Card
    private func currentVisualizationCard(_ viz: VisualizationMeditation) -> some View {
        VStack(spacing: HLSpacing.md) {
            // Scene preview
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: themeColors(viz.theme),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)

                VStack(spacing: HLSpacing.md) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 36, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.8))

                    Text(viz.title)
                        .font(HLTypography.serifMedium(22))
                        .foregroundColor(.white)

                    Text("\(viz.duration) min · \(viz.theme.rawValue)")
                        .font(HLTypography.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            // Scene elements
            VStack(alignment: .leading, spacing: HLSpacing.sm) {
                Text("Your Scene Contains")
                    .font(HLTypography.label)
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)

                FlowLayout(spacing: HLSpacing.sm) {
                    ForEach(viz.sceneElements, id: \.self) { element in
                        Text(element)
                            .font(HLTypography.caption)
                            .foregroundColor(.hlGold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(Color.hlGold.opacity(0.12))
                            )
                    }
                }
            }

            // Actions
            HStack(spacing: HLSpacing.md) {
                Button(action: {
                    audioEngine.play(session: viz.title, type: .visualizationMeditation, durationMinutes: viz.duration)
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Begin Journey")
                    }
                    .font(HLTypography.sansMedium(14))
                    .foregroundColor(.hlGreen900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.hlGold)
                    .clipShape(Capsule())
                }

                Button(action: {
                    var saved = viz
                    saved.isFavorite = true
                    savedVisualizations.append(saved)
                }) {
                    Image(systemName: viz.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.hlGold)
                        .padding(12)
                        .background(Circle().fill(Color.hlGold.opacity(0.15)))
                }

                Button(action: generateNew) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.hlGold)
                        .padding(12)
                        .background(Circle().fill(Color.hlGold.opacity(0.15)))
                }
            }
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
        )
        .hlShadowMedium()
        .padding(.horizontal, HLSpacing.lg)
    }

    private func themeColors(_ theme: VisualizationTheme) -> [Color] {
        switch theme {
        case .sacredGrove: return [Color(hex: "1B402E"), Color(hex: "2A5A42")]
        case .mountainSummit: return [Color(hex: "3A4A5A"), Color(hex: "5A7A8A")]
        case .oceanHorizon: return [Color(hex: "1A3A5A"), Color(hex: "3A6A8A")]
        case .desertStarscape: return [Color(hex: "1A1A3A"), Color(hex: "3A2A4A")]
        case .waterfallSanctuary: return [Color(hex: "1A3A3A"), Color(hex: "2A5A5A")]
        case .meadowOfLight: return [Color(hex: "3A5A2A"), Color(hex: "5A7A4A")]
        case .crystalCave: return [Color(hex: "2A1A3A"), Color(hex: "4A3A5A")]
        case .templeOfSilence: return [Color(hex: "3A2A1A"), Color(hex: "5A4A3A")]
        case .gardenOfPresence: return [Color(hex: "1A2A1A"), Color(hex: "3A4A3A")]
        case .cosmicJourney: return [Color(hex: "0A0A2A"), Color(hex: "1A1A4A")]
        case .forestCanopy: return [Color(hex: "0A1C14"), Color(hex: "1B402E")]
        case .riverOfTime: return [Color(hex: "1A2A3A"), Color(hex: "2A4A5A")]
        }
    }
}

// MARK: - Theme Card
struct ThemeCard: View {
    let theme: VisualizationTheme
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(
                        LinearGradient(colors: [.hlGreen700, .hlGreen500], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 70, height: 50)
                    .overlay(
                        Image(systemName: "eye.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    )

                Text(theme.rawValue)
                    .font(HLTypography.caption)
                    .foregroundColor(isSelected ? .hlGold : .hlTextSecondary)
                    .lineLimit(1)
            }
            .frame(width: 80)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .stroke(isSelected ? Color.hlGold : .clear, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Saved Row
struct SavedVisualizationRow: View {
    let visualization: VisualizationMeditation
    let isNightMode: Bool

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            Image(systemName: "heart.fill")
                .foregroundColor(.hlGold)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(visualization.title)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                Text("\(visualization.duration) min · \(visualization.theme.rawValue)")
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
                .fill(isNightMode ? Color.white.opacity(0.04) : .hlSurface)
        )
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
