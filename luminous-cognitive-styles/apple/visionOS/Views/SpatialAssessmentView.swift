// SpatialAssessmentView.swift
// Luminous Cognitive Styles™ — visionOS
// Assessment adapted for spatial computing with gesture-based responses

import SwiftUI

struct SpatialAssessmentView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var assessmentMode: AssessmentMode = .chooser
    @State private var generatedProfile: CognitiveProfile?
    @State private var showResults = false

    enum AssessmentMode {
        case chooser
        case quickProfile
        case fullDSR
    }

    var body: some View {
        Group {
            switch assessmentMode {
            case .chooser:
                assessmentChooser
            case .quickProfile:
                spatialQuickProfile
            case .fullDSR:
                spatialFullAssessment
            }
        }
        .sheet(isPresented: $showResults) {
            if let profile = generatedProfile {
                CognitiveSignatureView(profile: profile)
                    .frame(minWidth: 700, minHeight: 600)
            }
        }
    }

    // MARK: - Assessment Chooser

    private var assessmentChooser: some View {
        VStack(spacing: 32) {
            Text("Choose Your Assessment")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)

            HStack(spacing: 24) {
                // Quick Profile card
                Button {
                    withAnimation { assessmentMode = .quickProfile }
                } label: {
                    SpatialAssessmentCard(
                        icon: "bolt.fill",
                        title: "Quick Profile",
                        duration: "2 minutes",
                        description: "Rate yourself on 7 dimensions using intuitive spatial sliders.",
                        color: LCSTheme.amberGold
                    )
                }
                .buttonStyle(.plain)

                // Full DSR card
                Button {
                    withAnimation {
                        viewModel.startDSR()
                        assessmentMode = .fullDSR
                    }
                } label: {
                    SpatialAssessmentCard(
                        icon: "doc.text.magnifyingglass",
                        title: "Full Assessment",
                        duration: "10-15 minutes",
                        description: "Answer 35 questions for a comprehensive Dimensional Style Report.",
                        color: LCSTheme.crystalBlue
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(40)
    }

    // MARK: - Spatial Quick Profile

    private var spatialQuickProfile: some View {
        VStack(spacing: 24) {
            HStack {
                Button {
                    withAnimation { assessmentMode = .chooser }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }

                Spacer()

                Text("Quick Profile")
                    .font(.title.weight(.bold))
                    .foregroundColor(.white)

                Spacer()

                Button("Generate Profile") {
                    let profile = viewModel.generateQuickProfile()
                    generatedProfile = profile
                    showResults = true
                }
                .buttonStyle(.borderedProminent)
                .tint(LCSTheme.goldAccent)
            }

            // Spatial slider grid (2 columns)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(CognitiveDimension.allCases) { dim in
                    SpatialDimensionSlider(
                        dimension: dim,
                        score: Binding(
                            get: { viewModel.quickProfileItems[dim.rawValue].score },
                            set: { viewModel.updateQuickProfileScore(dimension: dim, score: $0) }
                        )
                    )
                }
            }

            Spacer()
        }
        .padding(32)
    }

    // MARK: - Spatial Full Assessment

    private var spatialFullAssessment: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    withAnimation { assessmentMode = .chooser }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }

                Spacer()

                // Dimension progress dots
                HStack(spacing: 8) {
                    ForEach(CognitiveDimension.allCases) { dim in
                        let questions = DSRQuestionBank.questions(for: dim)
                        let answered = questions.filter { viewModel.dsrAnswers[$0.id] != nil }.count
                        let complete = answered == questions.count
                        let isCurrent = viewModel.currentDSRDimension == dim

                        Circle()
                            .fill(complete ? dim.color : (isCurrent ? dim.color.opacity(0.5) : Color.white.opacity(0.15)))
                            .frame(width: isCurrent ? 12 : 8, height: isCurrent ? 12 : 8)
                    }
                }

                Spacer()

                if viewModel.isDSRComplete {
                    Button("See Results") {
                        let profile = viewModel.completeDSR()
                        generatedProfile = profile
                        showResults = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(LCSTheme.goldAccent)
                } else {
                    Text("\(Int(viewModel.dsrProgress * 100))%")
                        .font(.headline.monospacedDigit())
                        .foregroundColor(LCSTheme.goldAccent)
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)

            // Question card
            if let question = viewModel.currentDSRQuestion {
                VStack(spacing: 24) {
                    Spacer()

                    // Dimension context
                    HStack(spacing: 8) {
                        Image(systemName: question.dimension.icon)
                            .font(.title2)
                            .foregroundColor(question.dimension.color)
                        Text(question.dimension.name)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(question.dimension.color)
                    }

                    // Question text
                    Text(question.text)
                        .font(.title2.weight(.medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 600)

                    // Spatial Likert scale
                    SpatialLikertScale(
                        selectedValue: Binding(
                            get: { viewModel.dsrAnswers[question.id] },
                            set: { val in
                                if let v = val {
                                    viewModel.answerDSRQuestion(questionId: question.id, answer: v)
                                }
                            }
                        ),
                        color: question.dimension.color
                    )

                    Spacer()

                    // Navigation
                    HStack(spacing: 32) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.previousQuestion()
                            }
                        } label: {
                            Label("Previous", systemImage: "chevron.left")
                        }
                        .disabled(viewModel.currentQuestionIndex == 0)

                        Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.dsrQuestions.count)")
                            .font(.subheadline.monospacedDigit())
                            .foregroundColor(.white.opacity(0.5))

                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.nextQuestion()
                            }
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                        }
                        .disabled(viewModel.currentQuestionIndex >= viewModel.dsrQuestions.count - 1)
                    }
                    .padding(.bottom, 16)
                }
                .id(viewModel.currentQuestionIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }
}

// MARK: - Spatial Assessment Card

struct SpatialAssessmentCard: View {
    let icon: String
    let title: String
    let duration: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)

            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            Text(duration)
                .font(.subheadline.weight(.medium))
                .foregroundColor(color)

            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(width: 300, height: 280)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .hoverEffect(.lift)
    }
}

// MARK: - Spatial Dimension Slider

struct SpatialDimensionSlider: View {
    let dimension: CognitiveDimension
    @Binding var score: Double

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: dimension.icon)
                    .foregroundColor(dimension.color)
                Text(dimension.shortName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(ScoreFormatter.formatted(score))
                    .font(.system(.title3, design: .monospaced).weight(.bold))
                    .foregroundColor(dimension.color)
            }

            HStack(spacing: 8) {
                Text(dimension.lowPole)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 80, alignment: .trailing)

                Slider(value: $score, in: 1...10, step: 0.5)
                    .tint(dimension.color)

                Text(dimension.highPole)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 100, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Spatial Likert Scale

struct SpatialLikertScale: View {
    @Binding var selectedValue: Int?
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text("Strongly\nDisagree")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .frame(width: 60)

            ForEach(1...7, id: \.self) { value in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        selectedValue = value
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(selectedValue == value ? color : Color.white.opacity(0.06))
                            .frame(width: 52, height: 52)

                        Circle()
                            .stroke(
                                selectedValue == value ? color : Color.white.opacity(0.2),
                                lineWidth: selectedValue == value ? 3 : 1
                            )
                            .frame(width: 52, height: 52)

                        if selectedValue == value {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(value)")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .buttonStyle(.plain)
                .hoverEffect(.lift)
            }

            Text("Strongly\nAgree")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
    }
}
