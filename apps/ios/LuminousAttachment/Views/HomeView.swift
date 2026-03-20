// HomeView.swift
// Luminous Attachment — Resonance UX
// Daily insight, mood check-in, breathing widget, stats, and sharing

import SwiftUI

struct HomeView: View {
    @Environment(UserProfile.self) private var userProfile
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedMood: MoodLevel? = nil
    @State private var showMoodConfirmation = false
    @State private var showShareSheet = false
    @State private var breathingActive = false
    @State private var greetingOpacity: Double = 0
    @State private var cardsOffset: CGFloat = 30

    private var insight: DailyInsight {
        InsightsProvider.insightOfTheDay()
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<6: return "Rest well"
        case 6..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection
                dailyInsightCard
                moodCheckInCard
                breathingWidgetCard
                statsRow
                shareSection
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(ResonanceColors.background(for: colorScheme).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Luminous")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Settings
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                greetingOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                cardsOffset = 0
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityViewControllerRepresentable(
                activityItems: [
                    "\"\(insight.text)\" \u{2014} \(insight.author)\n\nFrom Luminous Attachment by Resonance UX"
                ]
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(greeting), \(userProfile.name.isEmpty ? "Explorer" : userProfile.name)")
                .font(.title.weight(.semibold))
                .foregroundStyle(ResonanceColors.text(for: colorScheme))

            if userProfile.streakDays > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                    Text("\(userProfile.streakDays)-day streak")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(greetingOpacity)
        .padding(.top, 8)
    }

    // MARK: - Daily Insight Card

    private var dailyInsightCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Daily Insight", systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Spacer()
                Text(insight.category.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(ResonanceColors.goldLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background {
                        Capsule().fill(ResonanceColors.goldPrimary.opacity(0.15))
                    }
            }

            Text("\"\(insight.text)\"")
                .font(.body.weight(.medium))
                .foregroundStyle(ResonanceColors.text(for: colorScheme))
                .lineSpacing(4)
                .italic()

            if !insight.author.isEmpty && insight.author != "Luminous Attachment" {
                Text("-- \(insight.author)")
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
            }

            Divider().overlay(ResonanceColors.goldPrimary.opacity(0.2))

            HStack {
                Button {
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }

                Spacer()

                Button {
                    // Bookmark insight
                } label: {
                    Image(systemName: "bookmark")
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ResonanceColors.goldPrimary.opacity(0.3),
                                    ResonanceColors.goldPrimary.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .shadow(color: ResonanceColors.goldPrimary.opacity(0.08), radius: 20, y: 10)
        .offset(y: cardsOffset)
    }

    // MARK: - Mood Check-In

    private var moodCheckInCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("How are you rooting today?")
                    .font(.headline)
                    .foregroundStyle(ResonanceColors.text(for: colorScheme))
                Spacer()
            }

            HStack(spacing: 12) {
                ForEach(MoodLevel.allCases) { mood in
                    moodButton(mood)
                }
            }

            if showMoodConfirmation, let mood = selectedMood {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Feeling like a \(mood.name.lowercased()) today. That is beautiful.")
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ResonanceColors.goldPrimary.opacity(0.1), lineWidth: 0.5)
                }
        }
        .offset(y: cardsOffset)
    }

    private func moodButton(_ mood: MoodLevel) -> some View {
        let isSelected = selectedMood == mood

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedMood = mood
                showMoodConfirmation = true
                let entry = MoodEntry(level: mood)
                userProfile.moodHistory.append(entry)
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? mood.color.opacity(0.2) : Color.clear)
                        .frame(width: 52, height: 52)

                    Image(systemName: mood.icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? mood.color : ResonanceColors.textSecondary(for: colorScheme))
                        .symbolEffect(.bounce, value: isSelected)
                }

                Text(mood.name)
                    .font(.caption2.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? mood.color : ResonanceColors.textSecondary(for: colorScheme)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(mood.name): \(mood.description)")
    }

    // MARK: - Breathing Widget

    private var breathingWidgetCard: some View {
        BreathingWidgetView(isActive: $breathingActive)
            .offset(y: cardsOffset)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 16) {
            miniStat(
                icon: "pencil.and.scribble",
                value: "\(userProfile.totalJournalEntries)",
                label: "Journal"
            )
            miniStat(
                icon: "bubble.left.and.text.bubble.right",
                value: "\(userProfile.totalCoachSessions)",
                label: "Sessions"
            )
            miniStat(
                icon: "wind",
                value: String(format: "%.0f", userProfile.totalMeditationMinutes),
                label: "Minutes"
            )
            miniStat(
                icon: "book.closed",
                value: "\(userProfile.completedChapters.count)",
                label: "Chapters"
            )
        }
        .offset(y: cardsOffset)
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(ResonanceColors.goldPrimary)

            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(ResonanceColors.text(for: colorScheme))

            Text(label)
                .font(.caption2)
                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ResonanceColors.goldPrimary.opacity(0.08), lineWidth: 0.5)
                }
        }
    }

    // MARK: - Share Section

    private var shareSection: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(ResonanceColors.goldPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Share Today's Insight")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ResonanceColors.text(for: colorScheme))
                    Text("Inspire someone on their journey")
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(ResonanceColors.surface(for: colorScheme))
            }
        }
        .buttonStyle(.plain)
        .offset(y: cardsOffset)
    }
}

// MARK: - Breathing Widget View

struct BreathingWidgetView: View {
    @Binding var isActive: Bool
    @Environment(\.colorScheme) private var colorScheme

    @State private var breathPhase: BreathPhase = .idle
    @State private var circleScale: CGFloat = 0.6
    @State private var phaseTimer: Timer?
    @State private var currentCycle = 0
    @State private var totalCycles = 4
    @State private var exercise = BreathingExercise.grounding

    enum BreathPhase: String {
        case idle = "Tap to begin"
        case inhale = "Breathe in..."
        case hold = "Hold gently..."
        case exhale = "Release slowly..."
        case complete = "Well done"
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Grounding Breath")
                    .font(.headline)
                    .foregroundStyle(ResonanceColors.text(for: colorScheme))
                Spacer()
                if isActive {
                    Text("Cycle \(currentCycle)/\(totalCycles)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }

            // Animated breathing circle
            ZStack {
                // Outer ring
                Circle()
                    .stroke(ResonanceColors.goldPrimary.opacity(0.15), lineWidth: 2)
                    .frame(width: 160, height: 160)

                // Animated fill
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ResonanceColors.goldPrimary.opacity(0.3),
                                ResonanceColors.goldPrimary.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(circleScale)

                // Inner glow
                Circle()
                    .fill(ResonanceColors.goldPrimary.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .scaleEffect(circleScale)

                // Phase label
                VStack(spacing: 4) {
                    Image(systemName: phaseIcon)
                        .font(.title2)
                        .foregroundStyle(ResonanceColors.goldPrimary)
                        .symbolEffect(.pulse, isActive: isActive)

                    Text(breathPhase.rawValue)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ResonanceColors.text(for: colorScheme))
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                if isActive {
                    stopBreathing()
                } else {
                    startBreathing()
                }
            }

            Text(exercise.description)
                .font(.caption)
                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(ResonanceColors.goldPrimary.opacity(0.1), lineWidth: 0.5)
                }
        }
    }

    private var phaseIcon: String {
        switch breathPhase {
        case .idle: return "wind"
        case .inhale: return "arrow.down.to.line"
        case .hold: return "pause.circle"
        case .exhale: return "arrow.up.to.line"
        case .complete: return "checkmark.circle"
        }
    }

    private func startBreathing() {
        isActive = true
        currentCycle = 1
        runCycle()
    }

    private func runCycle() {
        guard currentCycle <= totalCycles else {
            completeBreathing()
            return
        }

        // Inhale
        breathPhase = .inhale
        withAnimation(.easeInOut(duration: exercise.inhaleSeconds)) {
            circleScale = 1.0
        }

        // Hold after inhale
        DispatchQueue.main.asyncAfter(deadline: .now() + exercise.inhaleSeconds) {
            guard isActive else { return }
            if exercise.holdSeconds > 0 {
                breathPhase = .hold

                // Exhale after hold
                DispatchQueue.main.asyncAfter(deadline: .now() + exercise.holdSeconds) {
                    guard isActive else { return }
                    startExhale()
                }
            } else {
                startExhale()
            }
        }
    }

    private func startExhale() {
        breathPhase = .exhale
        withAnimation(.easeInOut(duration: exercise.exhaleSeconds)) {
            circleScale = 0.6
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + exercise.exhaleSeconds) {
            guard isActive else { return }
            currentCycle += 1
            runCycle()
        }
    }

    private func completeBreathing() {
        breathPhase = .complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            stopBreathing()
        }
    }

    private func stopBreathing() {
        isActive = false
        breathPhase = .idle
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.6
        }
        currentCycle = 0
    }
}

// MARK: - Activity View Controller

struct ActivityViewControllerRepresentable: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(UserProfile())
    .environment(ThemeManager())
}
