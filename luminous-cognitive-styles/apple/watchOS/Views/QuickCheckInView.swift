// QuickCheckInView.swift
// Luminous Cognitive Styles™ — watchOS
// Simplified daily check-in with Digital Crown scoring

import SwiftUI

struct QuickCheckInView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var currentIndex = 0
    @State private var scores: [CognitiveDimension: Double] = [:]
    @State private var currentScore: Double = 5.0
    @State private var showComplete = false

    private let questions = DailyCheckInBank.questions

    var body: some View {
        if showComplete {
            checkInCompleteView
        } else {
            checkInQuestionView
        }
    }

    // MARK: - Question View

    private var checkInQuestionView: some View {
        VStack(spacing: 8) {
            // Progress dots
            HStack(spacing: 4) {
                ForEach(0..<questions.count, id: \.self) { i in
                    Circle()
                        .fill(i < currentIndex ? questions[i].dimension.color : (i == currentIndex ? questions[i].dimension.color.opacity(0.6) : Color.white.opacity(0.15)))
                        .frame(width: i == currentIndex ? 7 : 5, height: i == currentIndex ? 7 : 5)
                }
            }

            Spacer()

            let question = questions[currentIndex]

            // Dimension badge
            HStack(spacing: 4) {
                Circle()
                    .fill(question.dimension.color)
                    .frame(width: 6, height: 6)
                Text(question.dimension.abbreviation)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(question.dimension.color)
            }

            // Question
            Text(question.text)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 4)

            // Score display
            Text(String(format: "%.0f", currentScore))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(question.dimension.color)
                .focusable()
                .digitalCrownRotation(
                    $currentScore,
                    from: 1.0,
                    through: 10.0,
                    by: 1.0,
                    sensitivity: .medium,
                    isContinuous: false,
                    isHapticFeedbackEnabled: true
                )

            // Pole labels
            HStack {
                Text(question.dimension.lowPole)
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text(question.dimension.highPole)
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.5))
            }

            // Mini bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(question.dimension.color)
                        .frame(width: geo.size.width * CGFloat((currentScore - 1.0) / 9.0))
                }
            }
            .frame(height: 4)

            Spacer()

            // Next button
            Button {
                scores[question.dimension] = currentScore
                viewModel.updateDailyScore(dimension: question.dimension, score: currentScore)

                if currentIndex < questions.count - 1 {
                    withAnimation {
                        currentIndex += 1
                        currentScore = 5.0
                    }
                } else {
                    withAnimation {
                        let _ = viewModel.completeDailyCheckIn()
                        showComplete = true
                    }
                }
            } label: {
                Text(currentIndex < questions.count - 1 ? "Next" : "Done")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .tint(questions[currentIndex].dimension.color)
        }
        .padding(.horizontal, 4)
        .containerBackground(LCSTheme.deepNavy.gradient, for: .navigation)
        .navigationTitle("Check In")
    }

    // MARK: - Complete View

    private var checkInCompleteView: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(LCSTheme.emerald)

            Text("Check-In\nComplete")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Mini summary
            VStack(spacing: 4) {
                ForEach(CognitiveDimension.allCases) { dim in
                    if let score = scores[dim] {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(dim.color)
                                .frame(width: 4, height: 4)
                            Text(dim.abbreviation)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(dim.color)
                            Spacer()
                            Text(String(format: "%.0f", score))
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            Text("Saved to your history")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .containerBackground(LCSTheme.deepNavy.gradient, for: .navigation)
    }
}
