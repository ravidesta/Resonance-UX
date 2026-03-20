// HomeView.swift
// Luminous Attachment — Resonance UX
// Daily insight card, mood check-in, breathing widget, stats, sharing

import SwiftUI

struct HomeView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(UserProfile.self) private var profile

    @State private var selectedMood: MoodLevel? = nil
    @State private var moodNote: String = ""
    @State private var showMoodDetail = false
    @State private var breathingActive = false
    @State private var breathPhase: BreathPhase = .idle
    @State private var breathProgress: CGFloat = 0
    @State private var breathCycleCount = 0
    @State private var currentExercise: BreathingExercise = .grounding
    @State private var showShareSheet = false
    @State private var dailyInsight: DailyInsight = InsightsProvider.insightOfTheDay()

    private let breathTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        let scheme = theme.effectiveScheme
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection(scheme: scheme)
                dailyInsightCard(scheme: scheme)
                moodCheckInSection(scheme: scheme)
                breathingWidget(scheme: scheme)
                statsRow(scheme: scheme)
                shareButton(scheme: scheme)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMoodDetail) {
            moodDetailSheet(scheme: scheme)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(
                activityItems: [
                    "\"\(dailyInsight.text)\" — \(dailyInsight.author)\n\nFrom Luminous Attachment by Resonance UX"
                ]
            )
        }
    }

    // MARK: - Header

    @ViewBuilder
    private func headerSection(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.weight(.medium))
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            Text(profile.name.isEmpty ? "Welcome back" : profile.name)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(ResonanceColors.text(for: scheme))
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("\(profile.currentStreak) day streak")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    // MARK: - Daily Insight Card

    @ViewBuilder
    private func dailyInsightCard(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("Daily Insight")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
                Text(dailyInsight.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(ResonanceColors.goldPrimary.opacity(0.15))
                    )
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }

            Text(dailyInsight.text)
                .font(.body.weight(.medium).leading(.loose))
                .foregroundStyle(scheme == .dark ? .white : ResonanceColors.green900)
                .fixedSize(horizontal: false, vertical: true)

            if dailyInsight.author != "Luminous Attachment" {
                Text("— \(dailyInsight.author)")
                    .font(.caption.italic())
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }

            HStack {
                Spacer()
                Button {
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                ResonanceColors.goldPrimary.opacity(0.08),
                                ResonanceColors.green800.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
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
        )
    }

    // MARK: - Mood Check-In

    @ViewBuilder
    private func moodCheckInSection(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How are you feeling?")
                .font(.headline)
                .foregroundStyle(ResonanceColors.text(for: scheme))

            HStack(spacing: 0) {
                ForEach(MoodLevel.allCases) { mood in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            selectedMood = mood
                        }
                        showMoodDetail = true
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        selectedMood == mood
                                            ? mood.color.opacity(0.2)
                                            : Color.clear
                                    )
                                    .frame(width: 52, height: 52)
                                Image(systemName: mood.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        selectedMood == mood
                                            ? mood.color
                                            : ResonanceColors.textSecondary(for: scheme)
                                    )
                                    .scaleEffect(selectedMood == mood ? 1.15 : 1.0)
                            }
                            Text(mood.name)
                                .font(.caption2)
                                .foregroundStyle(
                                    selectedMood == mood
                                        ? mood.color
                                        : ResonanceColors.textSecondary(for: scheme)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: selectedMood)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ResonanceColors.surface(for: scheme).opacity(0.5))
                )
        )
    }

    // MARK: - Mood Detail Sheet

    @ViewBuilder
    private func moodDetailSheet(scheme: ColorScheme) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let mood = selectedMood {
                    Image(systemName: mood.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(mood.color)
                    Text(mood.description)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(ResonanceColors.text(for: scheme))
                    TextField("Add a note about how you feel...", text: $moodNote, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .padding(.top, 30)
            .navigationTitle("Mood Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let mood = selectedMood {
                            let entry = MoodEntry(
                                level: mood,
                                note: moodNote.isEmpty ? nil : moodNote
                            )
                            profile.moodHistory.append(entry)
                        }
                        moodNote = ""
                        showMoodDetail = false
                    }
                    .tint(ResonanceColors.goldPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showMoodDetail = false
                    }
                }
            }
        }
    }

    // MARK: - Breathing Widget

    @ViewBuilder
    private func breathingWidget(scheme: ColorScheme) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentExercise.name)
                        .font(.headline)
                        .foregroundStyle(ResonanceColors.text(for: scheme))
                    Text(breathingActive ? breathPhase.instruction : currentExercise.description)
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                        .lineLimit(2)
                }
                Spacer()
                if breathingActive {
                    Text("Cycle \(breathCycleCount + 1)/\(currentExercise.cycles)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }

            // Animated breathing circle
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(
                        ResonanceColors.goldPrimary.opacity(0.15),
                        lineWidth: 3
                    )
                    .frame(width: 140, height: 140)

                // Progress ring
                Circle()
                    .trim(from: 0, to: breathProgress)
                    .stroke(
                        AngularGradient(
                            colors: [
                                ResonanceColors.goldPrimary.opacity(0.3),
                                ResonanceColors.goldPrimary,
                                ResonanceColors.goldLight
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                // Inner breathing circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ResonanceColors.goldPrimary.opacity(breathingActive ? 0.3 : 0.1),
                                ResonanceColors.goldPrimary.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 55
                        )
                    )
                    .frame(
                        width: breathingActive ? breathCircleSize : 80,
                        height: breathingActive ? breathCircleSize : 80
                    )
                    .animation(.easeInOut(duration: currentPhaseDuration), value: breathPhase)

                // Center label
                VStack(spacing: 2) {
                    Image(systemName: breathPhase.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                    Text(breathingActive ? breathPhase.label : "Start")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
            .onTapGesture {
                toggleBreathing()
            }
            .onReceive(breathTimer) { _ in
                updateBreathCycle()
            }

            // Exercise picker
            if !breathingActive {
                HStack(spacing: 12) {
                    ForEach([BreathingExercise.grounding, .heartOpening, .releaseAndLetGo], id: \.name) { exercise in
                        Button {
                            currentExercise = exercise
                        } label: {
                            Text(exercise.name.split(separator: " ").first ?? "")
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(
                                            currentExercise.name == exercise.name
                                                ? ResonanceColors.goldPrimary.opacity(0.2)
                                                : ResonanceColors.surfaceSecondary(for: scheme)
                                        )
                                )
                                .foregroundStyle(
                                    currentExercise.name == exercise.name
                                        ? ResonanceColors.goldPrimary
                                        : ResonanceColors.textSecondary(for: scheme)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ResonanceColors.surface(for: scheme).opacity(0.5))
                )
        )
    }

    private var breathCircleSize: CGFloat {
        switch breathPhase {
        case .inhale: return 110
        case .hold: return 110
        case .exhale: return 60
        case .idle: return 80
        }
    }

    private var currentPhaseDuration: Double {
        switch breathPhase {
        case .inhale: return currentExercise.inhaleSeconds
        case .hold: return currentExercise.holdSeconds
        case .exhale: return currentExercise.exhaleSeconds
        case .idle: return 0.5
        }
    }

    @State private var breathElapsed: TimeInterval = 0
    @State private var phaseStart: Date = .now

    private func toggleBreathing() {
        if breathingActive {
            breathingActive = false
            breathPhase = .idle
            breathProgress = 0
            breathCycleCount = 0
        } else {
            breathingActive = true
            breathPhase = .inhale
            phaseStart = .now
            breathCycleCount = 0
            breathProgress = 0
        }
    }

    private func updateBreathCycle() {
        guard breathingActive else { return }
        let elapsed = Date().timeIntervalSince(phaseStart)
        let phaseDuration: Double
        switch breathPhase {
        case .inhale: phaseDuration = currentExercise.inhaleSeconds
        case .hold: phaseDuration = currentExercise.holdSeconds
        case .exhale: phaseDuration = currentExercise.exhaleSeconds
        case .idle: return
        }

        let cycleTotalDuration = currentExercise.inhaleSeconds + currentExercise.holdSeconds + currentExercise.exhaleSeconds
        var accumulatedInCycle: Double = 0
        switch breathPhase {
        case .inhale: accumulatedInCycle = elapsed
        case .hold: accumulatedInCycle = currentExercise.inhaleSeconds + elapsed
        case .exhale: accumulatedInCycle = currentExercise.inhaleSeconds + currentExercise.holdSeconds + elapsed
        case .idle: break
        }
        breathProgress = min(CGFloat(accumulatedInCycle / cycleTotalDuration), 1.0)

        if elapsed >= phaseDuration {
            phaseStart = .now
            switch breathPhase {
            case .inhale:
                if currentExercise.holdSeconds > 0 {
                    breathPhase = .hold
                } else {
                    breathPhase = .exhale
                }
            case .hold:
                breathPhase = .exhale
            case .exhale:
                breathCycleCount += 1
                if breathCycleCount >= currentExercise.cycles {
                    breathingActive = false
                    breathPhase = .idle
                    breathProgress = 0
                    breathCycleCount = 0
                    profile.totalMeditationMinutes += currentExercise.totalDurationMinutes
                } else {
                    breathPhase = .inhale
                    breathProgress = 0
                }
            case .idle:
                break
            }
        }
    }

    // MARK: - Stats Row

    @ViewBuilder
    private func statsRow(scheme: ColorScheme) -> some View {
        HStack(spacing: 12) {
            statsCard(
                icon: "book.fill",
                value: "\(profile.completedChapters.count)/12",
                label: "Chapters",
                scheme: scheme
            )
            statsCard(
                icon: "pencil.and.scribble",
                value: "\(profile.totalJournalEntries)",
                label: "Entries",
                scheme: scheme
            )
            statsCard(
                icon: "wind",
                value: String(format: "%.0f", profile.totalMeditationMinutes),
                label: "Minutes",
                scheme: scheme
            )
            statsCard(
                icon: "bubble.left.fill",
                value: "\(profile.totalCoachSessions)",
                label: "Sessions",
                scheme: scheme
            )
        }
    }

    @ViewBuilder
    private func statsCard(icon: String, value: String, label: String, scheme: ColorScheme) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(ResonanceColors.goldPrimary)
            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundStyle(ResonanceColors.text(for: scheme))
            Text(label)
                .font(.caption2)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ResonanceColors.surface(for: scheme).opacity(0.5))
                )
        )
    }

    // MARK: - Share Button

    @ViewBuilder
    private func shareButton(scheme: ColorScheme) -> some View {
        Button {
            showShareSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.weight(.medium))
                Text("Share Today's Insight")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(ResonanceColors.green900)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [ResonanceColors.goldPrimary, ResonanceColors.goldLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Breath Phase

enum BreathPhase: String {
    case idle
    case inhale
    case hold
    case exhale

    var label: String {
        switch self {
        case .idle: return "Tap to start"
        case .inhale: return "Breathe in"
        case .hold: return "Hold"
        case .exhale: return "Breathe out"
        }
    }

    var instruction: String {
        switch self {
        case .idle: return "Tap the circle to begin"
        case .inhale: return "Slowly breathe in through your nose"
        case .hold: return "Gently hold your breath"
        case .exhale: return "Slowly release through your mouth"
        }
    }

    var icon: String {
        switch self {
        case .idle: return "wind"
        case .inhale: return "arrow.down.to.line"
        case .hold: return "pause"
        case .exhale: return "arrow.up.to.line"
        }
    }
}

// MARK: - Activity View Controller

struct ActivityViewController: UIViewControllerRepresentable {
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
    .environment(ThemeManager())
    .environment(UserProfile())
}
