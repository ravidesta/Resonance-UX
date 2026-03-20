// FullAssessmentView.swift
// Luminous Cognitive Styles™ — iOS
// 35-question DSR assessment with swipe navigation and progress tracking

import SwiftUI

struct FullAssessmentView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showResults = false
    @State private var generatedProfile: CognitiveProfile?
    @State private var showExitAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Top progress
            assessmentProgress

            // Question area
            if let question = viewModel.currentDSRQuestion {
                questionView(question)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(viewModel.currentQuestionIndex)
            }

            // Navigation bar
            navigationBar
        }
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("DSR Assessment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Exit") { showExitAlert = true }
                    .foregroundColor(LCSTheme.textSecondary)
            }
        }
        .alert("Exit Assessment?", isPresented: $showExitAlert) {
            Button("Save & Exit") {
                viewModel.saveDSRProgress()
                dismiss()
            }
            Button("Discard", role: .destructive) { dismiss() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your progress will be saved and you can resume later.")
        }
        .onAppear {
            if viewModel.dsrAnswers.isEmpty {
                viewModel.startDSR()
            }
        }
        .fullScreenCover(isPresented: $showResults) {
            NavigationStack {
                if let profile = generatedProfile {
                    CognitiveSignatureView(profile: profile)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    showResults = false
                                    dismiss()
                                }
                                .foregroundColor(LCSTheme.goldAccent)
                            }
                        }
                }
            }
        }
    }

    // MARK: - Progress Header

    private var assessmentProgress: some View {
        VStack(spacing: LCSTheme.Spacing.sm) {
            // Overall progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.08))

                    RoundedRectangle(cornerRadius: 3)
                        .fill(LCSTheme.goldGradient)
                        .frame(width: geo.size.width * CGFloat(viewModel.dsrProgress))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.dsrProgress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal)

            // Section indicators
            HStack(spacing: LCSTheme.Spacing.xs) {
                ForEach(CognitiveDimension.allCases) { dim in
                    let dimQuestions = DSRQuestionBank.questions(for: dim)
                    let answered = dimQuestions.filter { viewModel.dsrAnswers[$0.id] != nil }.count
                    let isActive = viewModel.currentDSRDimension == dim

                    VStack(spacing: 2) {
                        Circle()
                            .fill(answered == dimQuestions.count ? dim.color : (isActive ? dim.color.opacity(0.5) : Color.white.opacity(0.15)))
                            .frame(width: isActive ? 10 : 7, height: isActive ? 10 : 7)
                            .animation(.spring(response: 0.3), value: isActive)

                        if isActive {
                            Text(dim.abbreviation)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(dim.color)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        // Jump to first question of this dimension
                        if let firstQ = dimQuestions.first,
                           let idx = DSRQuestionBank.questions.firstIndex(where: { $0.id == firstQ.id }) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.goToQuestion(idx)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Question count
            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.dsrQuestions.count)")
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundColor(LCSTheme.textTertiary)
                Spacer()
                Text("\(Int(viewModel.dsrProgress * 100))% complete")
                    .font(.caption.weight(.medium).monospacedDigit())
                    .foregroundColor(LCSTheme.goldAccent)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, LCSTheme.Spacing.sm)
    }

    // MARK: - Question View

    private func questionView(_ question: AssessmentQuestion) -> some View {
        VStack(spacing: LCSTheme.Spacing.xl) {
            Spacer()

            // Dimension badge
            HStack(spacing: LCSTheme.Spacing.sm) {
                Image(systemName: question.dimension.icon)
                    .font(.system(size: 14))
                    .foregroundColor(question.dimension.color)
                Text(question.dimension.name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(question.dimension.color)
            }
            .padding(.horizontal, LCSTheme.Spacing.md)
            .padding(.vertical, LCSTheme.Spacing.sm)
            .background(
                Capsule()
                    .fill(question.dimension.color.opacity(0.12))
            )

            // Question text
            Text(question.text)
                .font(.title3.weight(.medium))
                .foregroundColor(LCSTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LCSTheme.Spacing.xl)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            // Likert scale
            LikertScaleView(
                labels: [],
                selectedValue: Binding(
                    get: { viewModel.dsrAnswers[question.id] },
                    set: { newValue in
                        if let val = newValue {
                            viewModel.answerDSRQuestion(questionId: question.id, answer: val)
                        }
                    }
                ),
                accentColor: question.dimension.color
            )
            .padding(.horizontal)

            Spacer()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { gesture in
                    if gesture.translation.width < -50 {
                        withAnimation(.easeInOut(duration: 0.3)) { viewModel.nextQuestion() }
                    } else if gesture.translation.width > 50 {
                        withAnimation(.easeInOut(duration: 0.3)) { viewModel.previousQuestion() }
                    }
                }
        )
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack(spacing: LCSTheme.Spacing.lg) {
            // Previous
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { viewModel.previousQuestion() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(viewModel.currentQuestionIndex > 0 ? LCSTheme.textPrimary : LCSTheme.textTertiary)
            }
            .disabled(viewModel.currentQuestionIndex == 0)

            Spacer()

            // Complete button (if all answered)
            if viewModel.isDSRComplete {
                Button {
                    let profile = viewModel.completeDSR()
                    generatedProfile = profile
                    showResults = true
                } label: {
                    Label("See Results", systemImage: "sparkles")
                }
                .buttonStyle(LCSTheme.PrimaryButtonStyle())
            } else {
                // Skip indicator
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { viewModel.nextQuestion() }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.dsrAnswers[viewModel.currentDSRQuestion?.id ?? 0] != nil ? "Next" : "Skip")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundColor(LCSTheme.textSecondary)
                }
            }

            Spacer()

            // Next
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { viewModel.nextQuestion() }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(viewModel.currentQuestionIndex < viewModel.dsrQuestions.count - 1 ? LCSTheme.textPrimary : LCSTheme.textTertiary)
            }
            .disabled(viewModel.currentQuestionIndex >= viewModel.dsrQuestions.count - 1)
        }
        .padding(.horizontal, LCSTheme.Spacing.xl)
        .padding(.vertical, LCSTheme.Spacing.md)
        .background(LCSTheme.darkSurface.opacity(0.9))
    }
}
