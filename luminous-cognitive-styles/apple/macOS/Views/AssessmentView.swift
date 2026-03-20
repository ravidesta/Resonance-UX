// AssessmentView.swift
// Luminous Cognitive Styles™ — macOS
// Quick Profile and Full Assessment views adapted for desktop

import SwiftUI

// MARK: - Quick Profile (macOS)

struct MacQuickProfileView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var showResults = false
    @State private var generatedProfile: CognitiveProfile?

    var body: some View {
        ScrollView {
            VStack(spacing: LCSTheme.Spacing.xl) {
                // Header
                VStack(spacing: LCSTheme.Spacing.sm) {
                    Text("Quick Profile")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(LCSTheme.textPrimary)
                    Text("Rate yourself on each dimension to discover your cognitive signature")
                        .font(.subheadline)
                        .foregroundColor(LCSTheme.textSecondary)
                }
                .padding(.top, LCSTheme.Spacing.xl)

                // Two-column layout for sliders
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LCSTheme.Spacing.lg) {
                    ForEach(CognitiveDimension.allCases) { dim in
                        MacDimensionSlider(
                            dimension: dim,
                            score: Binding(
                                get: { viewModel.quickProfileItems[dim.rawValue].score },
                                set: { viewModel.updateQuickProfileScore(dimension: dim, score: $0) }
                            )
                        )
                    }
                }
                .padding(.horizontal, LCSTheme.Spacing.xl)

                // Generate button
                HStack(spacing: LCSTheme.Spacing.lg) {
                    Button("Reset All") {
                        viewModel.resetQuickProfile()
                    }
                    .buttonStyle(LCSTheme.SecondaryButtonStyle())

                    Button("Generate My Profile") {
                        let profile = viewModel.generateQuickProfile()
                        generatedProfile = profile
                        showResults = true
                    }
                    .buttonStyle(LCSTheme.PrimaryButtonStyle())
                }
                .padding(.vertical, LCSTheme.Spacing.lg)

                Spacer(minLength: LCSTheme.Spacing.xxl)
            }
        }
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
        .sheet(isPresented: $showResults) {
            if let profile = generatedProfile {
                CognitiveSignatureView(profile: profile)
                    .frame(minWidth: 600, minHeight: 700)
            }
        }
    }
}

// MARK: - Mac Dimension Slider

struct MacDimensionSlider: View {
    let dimension: CognitiveDimension
    @Binding var score: Double

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            HStack {
                Image(systemName: dimension.icon)
                    .font(.system(size: 16))
                    .foregroundColor(dimension.color)

                Text(dimension.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(LCSTheme.textPrimary)

                Spacer()

                Text(ScoreFormatter.formatted(score))
                    .font(.system(.title3, design: .monospaced).weight(.bold))
                    .foregroundColor(dimension.color)
            }

            HStack(spacing: LCSTheme.Spacing.sm) {
                Text(dimension.lowPole)
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
                    .frame(width: 90, alignment: .trailing)

                Slider(value: $score, in: 1...10, step: 0.5)
                    .tint(dimension.color)

                Text(dimension.highPole)
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
                    .frame(width: 110, alignment: .leading)
            }

            Text(dimension.interpretation(for: score))
                .font(.caption)
                .foregroundColor(LCSTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: 32)
        }
        .lcsCard()
    }
}

// MARK: - Full Assessment (macOS)

struct MacAssessmentView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedDimension: CognitiveDimension = .perceptualMode
    @State private var showResults = false
    @State private var generatedProfile: CognitiveProfile?

    var body: some View {
        HSplitView {
            // Left panel: dimension navigator
            VStack(spacing: 0) {
                Text("Dimensions")
                    .font(.headline)
                    .foregroundColor(LCSTheme.textPrimary)
                    .padding()

                ForEach(CognitiveDimension.allCases) { dim in
                    let questions = DSRQuestionBank.questions(for: dim)
                    let answered = questions.filter { viewModel.dsrAnswers[$0.id] != nil }.count

                    Button {
                        selectedDimension = dim
                    } label: {
                        HStack(spacing: LCSTheme.Spacing.sm) {
                            Circle()
                                .fill(dim.color)
                                .frame(width: 8, height: 8)

                            Text(dim.shortName)
                                .font(.subheadline.weight(selectedDimension == dim ? .bold : .regular))
                                .foregroundColor(selectedDimension == dim ? dim.color : LCSTheme.textPrimary)

                            Spacer()

                            if answered == questions.count {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(LCSTheme.emerald)
                                    .font(.caption)
                            } else {
                                Text("\(answered)/\(questions.count)")
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(LCSTheme.textTertiary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, LCSTheme.Spacing.sm)
                        .background(
                            selectedDimension == dim
                                ? dim.color.opacity(0.1)
                                : Color.clear
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                // Progress and complete
                VStack(spacing: LCSTheme.Spacing.sm) {
                    ProgressView(value: viewModel.dsrProgress)
                        .tint(LCSTheme.goldAccent)

                    Text("\(Int(viewModel.dsrProgress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)

                    if viewModel.isDSRComplete {
                        Button("See Results") {
                            let profile = viewModel.completeDSR()
                            generatedProfile = profile
                            showResults = true
                        }
                        .buttonStyle(LCSTheme.PrimaryButtonStyle())
                    }
                }
                .padding()
            }
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)
            .background(LCSTheme.deepNavy.opacity(0.95))

            // Right panel: questions
            ScrollView {
                VStack(spacing: LCSTheme.Spacing.xl) {
                    // Dimension header
                    VStack(spacing: LCSTheme.Spacing.sm) {
                        Image(systemName: selectedDimension.icon)
                            .font(.system(size: 32))
                            .foregroundColor(selectedDimension.color)

                        Text(selectedDimension.name)
                            .font(.title2.weight(.bold))
                            .foregroundColor(LCSTheme.textPrimary)

                        Text("\(selectedDimension.lowPole) ↔ \(selectedDimension.highPole)")
                            .font(.subheadline)
                            .foregroundColor(selectedDimension.color)
                    }
                    .padding(.top, LCSTheme.Spacing.xl)

                    // Questions
                    let questions = DSRQuestionBank.questions(for: selectedDimension)
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        MacQuestionView(
                            question: question,
                            questionNumber: index + 1,
                            answer: Binding(
                                get: { viewModel.dsrAnswers[question.id] },
                                set: { val in
                                    if let v = val {
                                        viewModel.answerDSRQuestion(questionId: question.id, answer: v)
                                    }
                                }
                            ),
                            color: selectedDimension.color
                        )
                    }

                    // Navigate to next dimension
                    if let nextDim = nextDimension {
                        Button {
                            withAnimation { selectedDimension = nextDim }
                        } label: {
                            Label("Next: \(nextDim.name)", systemImage: "arrow.right")
                        }
                        .buttonStyle(LCSTheme.SecondaryButtonStyle())
                        .padding(.vertical, LCSTheme.Spacing.lg)
                    }

                    Spacer(minLength: LCSTheme.Spacing.xxl)
                }
                .padding(.horizontal, LCSTheme.Spacing.xl)
            }
            .background(LCSTheme.backgroundGradient)
        }
        .onAppear {
            if viewModel.dsrAnswers.isEmpty {
                viewModel.startDSR()
            }
        }
        .sheet(isPresented: $showResults) {
            if let profile = generatedProfile {
                CognitiveSignatureView(profile: profile)
                    .frame(minWidth: 600, minHeight: 700)
            }
        }
    }

    private var nextDimension: CognitiveDimension? {
        let all = CognitiveDimension.allCases
        guard let idx = all.firstIndex(of: selectedDimension), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }
}

// MARK: - Mac Question View

struct MacQuestionView: View {
    let question: AssessmentQuestion
    let questionNumber: Int
    @Binding var answer: Int?
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            HStack(alignment: .top) {
                Text("Q\(questionNumber)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundColor(color)
                    .frame(width: 30, alignment: .leading)

                Text(question.text)
                    .font(.body)
                    .foregroundColor(LCSTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // 7-point scale as segmented buttons
            HStack(spacing: LCSTheme.Spacing.xs) {
                Text("Disagree")
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)
                    .frame(width: 55)

                ForEach(1...7, id: \.self) { value in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            answer = value
                        }
                    } label: {
                        Text("\(value)")
                            .font(.system(size: 13, weight: answer == value ? .bold : .medium, design: .monospaced))
                            .foregroundColor(answer == value ? LCSTheme.deepNavy : LCSTheme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(answer == value ? color : Color.white.opacity(0.06))
                            )
                            .overlay(
                                Circle()
                                    .stroke(answer == value ? color : Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Text("Agree")
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)
                    .frame(width: 40)
            }
            .padding(.leading, 30)
        }
        .lcsCard()
    }
}

// MARK: - Placeholder Views

struct MacBookView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedChapter: BookChapter?

    var body: some View {
        HSplitView {
            // Chapter list
            VStack(alignment: .leading, spacing: 0) {
                Text("Chapters")
                    .font(.headline)
                    .foregroundColor(LCSTheme.textPrimary)
                    .padding()

                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(BookChapter.chapters) { chapter in
                            Button {
                                selectedChapter = chapter
                            } label: {
                                HStack(spacing: LCSTheme.Spacing.sm) {
                                    Text("\(chapter.id)")
                                        .font(.caption.weight(.bold).monospacedDigit())
                                        .foregroundColor(LCSTheme.textTertiary)
                                        .frame(width: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(chapter.title)
                                            .font(.subheadline.weight(selectedChapter?.id == chapter.id ? .bold : .medium))
                                            .foregroundColor(selectedChapter?.id == chapter.id ? LCSTheme.goldAccent : LCSTheme.textPrimary)
                                        Text(chapter.subtitle)
                                            .font(.system(size: 10))
                                            .foregroundColor(LCSTheme.textTertiary)
                                    }

                                    Spacer()

                                    let progress = viewModel.bookProgress[chapter.id] ?? 0
                                    if progress >= 1.0 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(LCSTheme.emerald)
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, LCSTheme.Spacing.sm)
                                .background(
                                    selectedChapter?.id == chapter.id
                                        ? LCSTheme.goldAccent.opacity(0.08)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(minWidth: 240, idealWidth: 280)
            .background(LCSTheme.deepNavy.opacity(0.95))

            // Reading area
            if let chapter = selectedChapter {
                ScrollView {
                    VStack(alignment: .leading, spacing: LCSTheme.Spacing.lg) {
                        Text("Chapter \(chapter.id)")
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .tracking(2)
                            .foregroundColor(LCSTheme.goldAccent)

                        Text(chapter.title)
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(LCSTheme.textPrimary)

                        Text(chapter.subtitle)
                            .font(.title3)
                            .foregroundColor(LCSTheme.textSecondary)

                        Divider().background(Color.white.opacity(0.1))

                        Text(chapter.content)
                            .font(.system(size: 16, weight: .regular, design: .serif))
                            .foregroundColor(LCSTheme.textPrimary.opacity(0.9))
                            .lineSpacing(8)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 60)
                    }
                    .padding(LCSTheme.Spacing.xl)
                    .frame(maxWidth: 700, alignment: .leading)
                }
                .background(LCSTheme.backgroundGradient)
                .onDisappear {
                    viewModel.updateBookProgress(chapterId: chapter.id, progress: 1.0)
                }
            } else {
                VStack {
                    Spacer()
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(LCSTheme.textTertiary)
                    Text("Select a chapter to begin reading")
                        .foregroundColor(LCSTheme.textTertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LCSTheme.backgroundGradient)
            }
        }
    }
}

struct MacCoachingView: View {
    var body: some View {
        VStack(spacing: LCSTheme.Spacing.xl) {
            Spacer()
            Image(systemName: "message.fill")
                .font(.system(size: 48))
                .foregroundStyle(LCSTheme.goldGradient)

            Text("Coaching")
                .font(.title.weight(.bold))
                .foregroundColor(LCSTheme.textPrimary)

            Text("Personalized cognitive style coaching coming soon to macOS.\nUse the iOS app for full coaching features.")
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)

            HStack(spacing: LCSTheme.Spacing.xl) {
                VStack(spacing: LCSTheme.Spacing.sm) {
                    Text("Text Coaching")
                        .font(.headline)
                        .foregroundColor(LCSTheme.amberGold)
                    Text("$9.99/month")
                        .font(.title2.weight(.bold))
                        .foregroundColor(LCSTheme.textPrimary)
                    Text("AI-powered insights and exercises")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                }
                .lcsCard()

                VStack(spacing: LCSTheme.Spacing.sm) {
                    Text("Personal Tutor")
                        .font(.headline)
                        .foregroundColor(LCSTheme.violet)
                    Text("$19.99/week")
                        .font(.title2.weight(.bold))
                        .foregroundColor(LCSTheme.textPrimary)
                    Text("Live sessions with a certified coach")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                }
                .lcsCard()
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
    }
}

struct MacHistoryView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedProfile: CognitiveProfile?

    var body: some View {
        HSplitView {
            // Profile list
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("History")
                        .font(.headline)
                        .foregroundColor(LCSTheme.textPrimary)
                    Spacer()
                    Text("\(viewModel.profileHistory.count) profiles")
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                }
                .padding()

                if viewModel.profileHistory.isEmpty {
                    VStack {
                        Spacer()
                        Text("No assessments yet")
                            .foregroundColor(LCSTheme.textTertiary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(viewModel.profileHistory) { profile in
                                Button {
                                    selectedProfile = profile
                                } label: {
                                    HStack(spacing: LCSTheme.Spacing.sm) {
                                        CompactRadarChartView(profile: profile, size: 30)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(profile.profileTypeName)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(LCSTheme.textPrimary)
                                            Text("\(profile.assessmentType.rawValue) · \(profile.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.caption2)
                                                .foregroundColor(LCSTheme.textTertiary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, LCSTheme.Spacing.sm)
                                    .background(
                                        selectedProfile?.id == profile.id
                                            ? LCSTheme.goldAccent.opacity(0.08)
                                            : Color.clear
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 260, idealWidth: 300)
            .background(LCSTheme.deepNavy.opacity(0.95))

            // Detail
            if let profile = selectedProfile {
                CognitiveSignatureView(profile: profile)
            } else {
                VStack {
                    Spacer()
                    Text("Select a profile to view details")
                        .foregroundColor(LCSTheme.textTertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LCSTheme.backgroundGradient)
            }
        }
    }
}

struct MacSettingsView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var showClearAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LCSTheme.Spacing.xl) {
                Text("Settings")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(LCSTheme.textPrimary)

                GroupBox("Appearance") {
                    HStack {
                        Text("Theme")
                            .foregroundColor(LCSTheme.textPrimary)
                        Spacer()
                        Text("Dark (Default)")
                            .foregroundColor(LCSTheme.textTertiary)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("Data") {
                    VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
                        HStack {
                            Text("Profiles stored")
                                .foregroundColor(LCSTheme.textPrimary)
                            Spacer()
                            Text("\(viewModel.profileHistory.count)")
                                .foregroundColor(LCSTheme.textTertiary)
                        }

                        HStack {
                            Text("Book progress")
                                .foregroundColor(LCSTheme.textPrimary)
                            Spacer()
                            Text("\(Int(viewModel.totalBookProgress * 100))%")
                                .foregroundColor(LCSTheme.textTertiary)
                        }

                        Divider()

                        Button(role: .destructive) {
                            showClearAlert = true
                        } label: {
                            Label("Clear All Data", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox("About") {
                    VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
                        HStack {
                            Text("Version")
                                .foregroundColor(LCSTheme.textPrimary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(LCSTheme.textTertiary)
                        }
                        HStack {
                            Text("Framework")
                                .foregroundColor(LCSTheme.textPrimary)
                            Spacer()
                            Text("Luminous Cognitive Styles™")
                                .foregroundColor(LCSTheme.textTertiary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Spacer()
            }
            .padding(LCSTheme.Spacing.xl)
            .frame(maxWidth: 600, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
        .alert("Clear All Data?", isPresented: $showClearAlert) {
            Button("Clear", role: .destructive) { viewModel.clearAllData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all profiles, assessments, and reading progress.")
        }
    }
}
