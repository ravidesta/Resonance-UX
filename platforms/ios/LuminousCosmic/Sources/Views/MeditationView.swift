// MeditationView.swift
// Luminous Cosmic Architecture™
// Guided Meditation Player - Stargazer's Attunement

import SwiftUI

// MARK: - Meditation View

struct MeditationView: View {
    @Environment(\.resonanceTheme) var theme
    @StateObject private var viewModel = MeditationViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackground(showStars: true, blobCount: 2)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: ResonanceSpacing.lg) {
                        headerSection

                        // Featured meditation
                        featuredMeditation

                        // Category cards
                        categorySection

                        // All meditations
                        meditationList

                        Spacer(minLength: ResonanceSpacing.xxxl)
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $viewModel.activeMeditation) { meditation in
                MeditationPlayerView(meditation: meditation)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
            Text("Guided Meditations")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)

            Text("Attune to the cosmic rhythms")
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResonanceSpacing.xxl)
        .padding(.horizontal, ResonanceSpacing.xs)
    }

    // MARK: - Featured

    private var featuredMeditation: some View {
        Button {
            viewModel.activeMeditation = viewModel.stargazerAttunement
            ResonanceHaptics.medium()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Background
                RoundedRectangle(cornerRadius: ResonanceRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: [
                                ResonanceColors.forestDeep,
                                ResonanceColors.forestMid,
                                ResonanceColors.forestLight.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)

                // Stars overlay
                StarFieldView()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: ResonanceRadius.xl))
                    .opacity(0.6)

                // Cosmic orb
                CosmicOrb(size: 120)
                    .offset(x: 220, y: -40)
                    .opacity(0.7)

                // Content
                VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                    Text("FEATURED")
                        .font(ResonanceTypography.overline)
                        .foregroundColor(ResonanceColors.goldPrimary)
                        .tracking(2)

                    Text("Stargazer's\nAttunement")
                        .font(ResonanceTypography.displaySmall)
                        .foregroundColor(ResonanceColors.creamPrimary)

                    HStack(spacing: ResonanceSpacing.sm) {
                        Label("12 min", systemImage: "clock")
                            .font(ResonanceTypography.caption)
                            .foregroundColor(ResonanceColors.creamWarm.opacity(0.8))

                        Text("From the book")
                            .font(ResonanceTypography.caption)
                            .foregroundColor(ResonanceColors.goldLight.opacity(0.7))
                    }
                }
                .padding(ResonanceSpacing.lg)
            }
            .clipShape(RoundedRectangle(cornerRadius: ResonanceRadius.xl))
            .shadow(color: ResonanceColors.shadowGold, radius: 20, y: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Categories

    private var categorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ResonanceSpacing.sm) {
                ForEach(MeditationCategory.allCases, id: \.self) { category in
                    Button {
                        viewModel.selectedCategory = category
                        ResonanceHaptics.selection()
                    } label: {
                        Text(category.rawValue)
                            .font(ResonanceTypography.bodySmall)
                            .foregroundColor(
                                viewModel.selectedCategory == category
                                    ? theme.textPrimary
                                    : theme.textTertiary
                            )
                            .padding(.horizontal, ResonanceSpacing.md)
                            .padding(.vertical, ResonanceSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(
                                        viewModel.selectedCategory == category
                                            ? theme.accent.opacity(0.15)
                                            : theme.surface.opacity(0.3)
                                    )
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        viewModel.selectedCategory == category
                                            ? theme.accent.opacity(0.3)
                                            : theme.border,
                                        lineWidth: 0.5
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, ResonanceSpacing.xs)
        }
    }

    // MARK: - Meditation List

    private var meditationList: some View {
        VStack(spacing: ResonanceSpacing.md) {
            ForEach(viewModel.filteredMeditations) { meditation in
                MeditationCard(meditation: meditation) {
                    viewModel.activeMeditation = meditation
                    ResonanceHaptics.medium()
                }
            }
        }
    }
}

// MARK: - Meditation Card

struct MeditationCard: View {
    let meditation: GuidedMeditation
    let onTap: () -> Void

    @Environment(\.resonanceTheme) var theme

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ResonanceSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: categoryIcon)
                        .font(.system(size: 22))
                        .foregroundColor(categoryColor)
                }

                VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                    Text(meditation.title)
                        .font(ResonanceTypography.headlineSmall)
                        .foregroundColor(theme.textPrimary)

                    Text(meditation.subtitle)
                        .font(ResonanceTypography.bodySmall)
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(2)

                    Text(formattedDuration)
                        .font(ResonanceTypography.caption)
                        .foregroundColor(theme.textTertiary)
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(theme.accent.opacity(0.7))
            }
            .padding(ResonanceSpacing.md)
            .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(meditation.title). \(meditation.subtitle). Duration: \(formattedDuration)")
        .accessibilityHint("Double tap to begin meditation")
    }

    private var categoryColor: Color {
        switch meditation.category {
        case .attunement: return ResonanceColors.goldPrimary
        case .planetary: return ResonanceColors.air
        case .elemental: return ResonanceColors.earth
        case .lunar: return ResonanceColors.water
        }
    }

    private var categoryIcon: String {
        switch meditation.category {
        case .attunement: return "sparkles"
        case .planetary: return "globe"
        case .elemental: return "leaf"
        case .lunar: return "moon.stars"
        }
    }

    private var formattedDuration: String {
        let minutes = Int(meditation.duration / 60)
        return "\(minutes) min"
    }
}

// MARK: - Meditation Player View

struct MeditationPlayerView: View {
    let meditation: GuidedMeditation
    @Environment(\.resonanceTheme) var theme
    @Environment(\.dismiss) var dismiss
    @StateObject private var player = MeditationPlayer()

    var body: some View {
        ZStack {
            CosmicBackground(showStars: true, blobCount: 3)

            VStack(spacing: ResonanceSpacing.xl) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        player.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(theme.surface.opacity(0.3)))
                    }
                }
                .padding(.horizontal, ResonanceSpacing.md)

                Spacer()

                // Breathing orb
                BreathingOrb(
                    isActive: player.isPlaying,
                    breathPattern: player.currentBreathPattern
                )

                // Title
                VStack(spacing: ResonanceSpacing.xs) {
                    Text(meditation.title)
                        .font(ResonanceTypography.displaySmall)
                        .foregroundColor(theme.textPrimary)

                    Text(meditation.subtitle)
                        .font(ResonanceTypography.bodyMedium)
                        .foregroundColor(theme.textSecondary)
                }

                // Current instruction
                Text(player.currentInstruction)
                    .font(ResonanceTypography.bodyLarge)
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, ResonanceSpacing.xl)
                    .frame(minHeight: 80)
                    .animation(ResonanceAnimation.easeOut, value: player.currentInstruction)

                Spacer()

                // Progress
                VStack(spacing: ResonanceSpacing.sm) {
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(theme.border)
                                .frame(height: 4)

                            Capsule()
                                .fill(theme.goldGradient)
                                .frame(width: geo.size.width * player.progress, height: 4)
                                .animation(.linear(duration: 0.5), value: player.progress)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, ResonanceSpacing.xl)

                    // Time
                    HStack {
                        Text(player.elapsedTimeString)
                            .font(ResonanceTypography.caption)
                            .foregroundColor(theme.textTertiary)
                            .monospacedDigit()

                        Spacer()

                        Text(player.remainingTimeString)
                            .font(ResonanceTypography.caption)
                            .foregroundColor(theme.textTertiary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, ResonanceSpacing.xl)
                }

                // Controls
                HStack(spacing: ResonanceSpacing.xxl) {
                    Button {
                        player.previousStep()
                        ResonanceHaptics.light()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.textSecondary)
                    }

                    Button {
                        player.togglePlayPause()
                        ResonanceHaptics.medium()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(theme.accent)
                                .frame(width: 72, height: 72)

                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(theme.isDark ? ResonanceColors.nightDeep : .white)
                        }
                        .shadow(color: ResonanceColors.shadowGold, radius: 16, y: 4)
                    }
                    .accessibilityLabel(player.isPlaying ? "Pause" : "Play")

                    Button {
                        player.nextStep()
                        ResonanceHaptics.light()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.textSecondary)
                    }
                }

                Spacer()
                    .frame(height: ResonanceSpacing.xxl)
            }
        }
        .onAppear {
            player.load(meditation: meditation)
        }
        .onDisappear {
            player.stop()
        }
    }
}

// MARK: - Breathing Orb

struct BreathingOrb: View {
    let isActive: Bool
    let breathPattern: BreathPattern?

    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3

    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3) { ring in
                Circle()
                    .stroke(
                        ResonanceColors.goldPrimary.opacity(0.1 - Double(ring) * 0.03),
                        lineWidth: 1
                    )
                    .frame(
                        width: 160 + CGFloat(ring) * 40,
                        height: 160 + CGFloat(ring) * 40
                    )
                    .scaleEffect(scale * (1.0 + CGFloat(ring) * 0.05))
            }

            // Core orb
            CosmicOrb(size: 140)
                .scaleEffect(scale)
        }
        .onChange(of: isActive) { _, active in
            if active {
                startBreathing()
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 1.0
                    glowOpacity = 0.3
                }
            }
        }
    }

    private func startBreathing() {
        guard let pattern = breathPattern else {
            withAnimation(ResonanceAnimation.breathe) {
                scale = 1.15
                glowOpacity = 0.6
            }
            return
        }

        let totalDuration = pattern.inhale + pattern.hold + pattern.exhale

        // Inhale
        withAnimation(.easeInOut(duration: pattern.inhale)) {
            scale = 1.2
            glowOpacity = 0.7
        }

        // Hold + Exhale
        DispatchQueue.main.asyncAfter(deadline: .now() + pattern.inhale + pattern.hold) {
            withAnimation(.easeInOut(duration: pattern.exhale)) {
                scale = 0.9
                glowOpacity = 0.3
            }
        }

        // Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            if isActive {
                startBreathing()
            }
        }
    }
}

// MARK: - Meditation Player

class MeditationPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentStepIndex = 0
    @Published var currentInstruction = "Press play to begin"
    @Published var currentBreathPattern: BreathPattern?
    @Published var progress: CGFloat = 0
    @Published var elapsedTime: TimeInterval = 0

    private var meditation: GuidedMeditation?
    private var timer: Timer?

    var elapsedTimeString: String { formatTime(elapsedTime) }
    var remainingTimeString: String {
        formatTime(max(0, (meditation?.duration ?? 0) - elapsedTime))
    }

    func load(meditation: GuidedMeditation) {
        self.meditation = meditation
        currentStepIndex = 0
        if let firstStep = meditation.steps.first {
            currentInstruction = firstStep.instruction
            currentBreathPattern = firstStep.breathPattern
        }
    }

    func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            startTimer()
        } else {
            timer?.invalidate()
        }
    }

    func stop() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        progress = 0
        currentStepIndex = 0
    }

    func nextStep() {
        guard let meditation = meditation else { return }
        if currentStepIndex < meditation.steps.count - 1 {
            currentStepIndex += 1
            updateStep()
        }
    }

    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
            updateStep()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let meditation = self.meditation else { return }
            self.elapsedTime += 1
            self.progress = min(1.0, CGFloat(self.elapsedTime / meditation.duration))

            // Check if we should advance to next step
            var accumulated: TimeInterval = 0
            for (index, step) in meditation.steps.enumerated() {
                accumulated += step.duration
                if self.elapsedTime <= accumulated && index != self.currentStepIndex {
                    self.currentStepIndex = index
                    self.updateStep()
                    break
                }
            }

            if self.elapsedTime >= meditation.duration {
                self.isPlaying = false
                self.timer?.invalidate()
                self.currentInstruction = "Meditation complete. Carry this awareness with you."
            }
        }
    }

    private func updateStep() {
        guard let meditation = meditation else { return }
        let step = meditation.steps[currentStepIndex]
        withAnimation(ResonanceAnimation.easeOut) {
            currentInstruction = step.instruction
            currentBreathPattern = step.breathPattern
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Meditation ViewModel

class MeditationViewModel: ObservableObject {
    @Published var selectedCategory: MeditationCategory = .attunement
    @Published var activeMeditation: GuidedMeditation?

    var stargazerAttunement: GuidedMeditation {
        GuidedMeditation(
            title: "Stargazer's Attunement",
            subtitle: "Connect with the cosmos through breath and awareness",
            duration: 720, // 12 minutes
            steps: [
                MeditationStep(
                    instruction: "Find a comfortable position. Close your eyes and take three deep, nourishing breaths.",
                    duration: 30,
                    breathPattern: BreathPattern(inhale: 4, hold: 2, exhale: 6)
                ),
                MeditationStep(
                    instruction: "Imagine yourself standing beneath a vast, star-filled sky. Feel the earth solid beneath your feet.",
                    duration: 60,
                    breathPattern: nil
                ),
                MeditationStep(
                    instruction: "With each breath, feel yourself becoming more attuned to the cosmic rhythms. You are both the observer and the observed.",
                    duration: 60,
                    breathPattern: BreathPattern(inhale: 4, hold: 4, exhale: 4)
                ),
                MeditationStep(
                    instruction: "Visualize your Sun sign glowing at your solar plexus. Feel its warmth radiating through your core identity.",
                    duration: 90,
                    breathPattern: nil
                ),
                MeditationStep(
                    instruction: "Now sense your Moon sign at your heart center. Notice the tidal pull of your emotional landscape.",
                    duration: 90,
                    breathPattern: BreathPattern(inhale: 5, hold: 3, exhale: 7)
                ),
                MeditationStep(
                    instruction: "Feel your Rising sign as a luminous aura surrounding you. This is your gift to the world, your visible light.",
                    duration: 90,
                    breathPattern: nil
                ),
                MeditationStep(
                    instruction: "Now expand your awareness to include all the planets in your chart. Each one is a note in your cosmic symphony.",
                    duration: 90,
                    breathPattern: BreathPattern(inhale: 4, hold: 4, exhale: 6)
                ),
                MeditationStep(
                    instruction: "Rest in this expanded awareness. You are a unique expression of the universe knowing itself.",
                    duration: 120,
                    breathPattern: nil
                ),
                MeditationStep(
                    instruction: "Slowly bring your attention back. Carry this cosmic attunement with you as you open your eyes.",
                    duration: 60,
                    breathPattern: BreathPattern(inhale: 4, hold: 2, exhale: 6)
                )
            ],
            category: .attunement
        )
    }

    var filteredMeditations: [GuidedMeditation] {
        allMeditations.filter { $0.category == selectedCategory }
    }

    var allMeditations: [GuidedMeditation] {
        [
            stargazerAttunement,
            GuidedMeditation(
                title: "Solar Return Reflection",
                subtitle: "Honor your birthday with a solar meditation",
                duration: 600,
                steps: [
                    MeditationStep(instruction: "Settle into stillness. Today we honor the return of the Sun to its natal position.", duration: 60, breathPattern: BreathPattern(inhale: 4, hold: 2, exhale: 6)),
                    MeditationStep(instruction: "Reflect on the year that has passed. What lessons has the Sun illuminated?", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "Set an intention for the solar year ahead. What do you wish to manifest?", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "Visualize golden light filling every cell. You are renewed.", duration: 180, breathPattern: BreathPattern(inhale: 5, hold: 5, exhale: 5)),
                    MeditationStep(instruction: "Return gently, carrying your intention like a seed of golden light.", duration: 60, breathPattern: nil)
                ],
                category: .attunement
            ),
            GuidedMeditation(
                title: "Mercury Mindfulness",
                subtitle: "Sharpen mental clarity through mercurial awareness",
                duration: 480,
                steps: [
                    MeditationStep(instruction: "Bring awareness to the quality of your thoughts. Notice without engaging.", duration: 90, breathPattern: BreathPattern(inhale: 3, hold: 3, exhale: 3)),
                    MeditationStep(instruction: "Imagine quicksilver light flowing through your mind, clarifying every thought.", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "Practice observing the space between thoughts. This is Mercury's gift of awareness.", duration: 150, breathPattern: nil),
                    MeditationStep(instruction: "Return with a clearer mind and sharper perception.", duration: 60, breathPattern: BreathPattern(inhale: 4, hold: 2, exhale: 4))
                ],
                category: .planetary
            ),
            GuidedMeditation(
                title: "Venus Heart Opening",
                subtitle: "Cultivate love and beauty through Venusian energy",
                duration: 600,
                steps: [
                    MeditationStep(instruction: "Place your hands on your heart. Feel its steady rhythm.", duration: 60, breathPattern: BreathPattern(inhale: 4, hold: 4, exhale: 6)),
                    MeditationStep(instruction: "Breathe in rose-gold light with each inhale. Let it fill your heart space.", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "Send this loving energy to yourself first, then to those you cherish.", duration: 180, breathPattern: nil),
                    MeditationStep(instruction: "Rest in the beauty of connection. You are worthy of love.", duration: 120, breathPattern: BreathPattern(inhale: 5, hold: 3, exhale: 7)),
                    MeditationStep(instruction: "Gently return, carrying Venus's grace in your heart.", duration: 60, breathPattern: nil)
                ],
                category: .planetary
            ),
            GuidedMeditation(
                title: "Earth Element Grounding",
                subtitle: "Root into stability and presence",
                duration: 420,
                steps: [
                    MeditationStep(instruction: "Feel the weight of your body. Let gravity be a comfort.", duration: 60, breathPattern: BreathPattern(inhale: 4, hold: 4, exhale: 8)),
                    MeditationStep(instruction: "Imagine roots extending from your body deep into the earth.", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "Draw up nourishing earth energy through these roots. Feel stability fill you.", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "You are supported. You are grounded. You are here.", duration: 60, breathPattern: BreathPattern(inhale: 4, hold: 4, exhale: 8))
                ],
                category: .elemental
            ),
            GuidedMeditation(
                title: "Full Moon Release",
                subtitle: "Let go under the light of the full moon",
                duration: 540,
                steps: [
                    MeditationStep(instruction: "Imagine the full moon above you, bathing you in silver light.", duration: 60, breathPattern: BreathPattern(inhale: 4, hold: 2, exhale: 6)),
                    MeditationStep(instruction: "What are you ready to release? Let it surface in the moonlight.", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "With each exhale, release what no longer serves you into the moon's light.", duration: 150, breathPattern: BreathPattern(inhale: 4, hold: 2, exhale: 8)),
                    MeditationStep(instruction: "Feel the spaciousness that remains. This is your sacred emptiness.", duration: 120, breathPattern: nil),
                    MeditationStep(instruction: "Thank the moon and return, lighter than before.", duration: 60, breathPattern: nil)
                ],
                category: .lunar
            )
        ]
    }
}
