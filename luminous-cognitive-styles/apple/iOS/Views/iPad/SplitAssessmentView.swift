// SplitAssessmentView.swift
// Luminous Cognitive Styles™ — iPad
// Master-detail layout: dimension overview on left, questions on right

import SwiftUI

struct SplitAssessmentView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDimension: CognitiveDimension = .perceptualMode
    @State private var showResults = false
    @State private var generatedProfile: CognitiveProfile?

    var body: some View {
        NavigationSplitView {
            // Sidebar: Dimension list
            List(CognitiveDimension.allCases, selection: $selectedDimension) { dim in
                DimensionSidebarRow(
                    dimension: dim,
                    answeredCount: answeredCount(for: dim),
                    totalCount: DSRQuestionBank.questions(for: dim).count,
                    isSelected: selectedDimension == dim
                )
                .tag(dim)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: LCSTheme.Radius.sm)
                        .fill(selectedDimension == dim ? dim.color.opacity(0.15) : Color.clear)
                )
            }
            .listStyle(.sidebar)
            .navigationTitle("Dimensions")
            .scrollContentBackground(.hidden)
            .background(LCSTheme.deepNavy)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") { dismiss() }
                }
                ToolbarItem(placement: .bottomBar) {
                    VStack(spacing: 4) {
                        ProgressView(value: viewModel.dsrProgress)
                            .tint(LCSTheme.goldAccent)
                        Text("\(Int(viewModel.dsrProgress * 100))% Complete")
                            .font(.caption2)
                            .foregroundColor(LCSTheme.textTertiary)
                    }
                }
            }
        } detail: {
            // Detail: Questions for selected dimension
            dimensionDetail
        }
        .navigationSplitViewStyle(.balanced)
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
                            }
                        }
                }
            }
        }
    }

    // MARK: - Dimension Detail

    private var dimensionDetail: some View {
        ScrollView {
            VStack(spacing: LCSTheme.Spacing.xl) {
                // Dimension header
                VStack(spacing: LCSTheme.Spacing.md) {
                    Image(systemName: selectedDimension.icon)
                        .font(.system(size: 36))
                        .foregroundColor(selectedDimension.color)

                    Text(selectedDimension.name)
                        .font(.title2.weight(.bold))
                        .foregroundColor(LCSTheme.textPrimary)

                    Text("\(selectedDimension.lowPole) ↔ \(selectedDimension.highPole)")
                        .font(.subheadline)
                        .foregroundColor(selectedDimension.color)

                    Text(selectedDimension.description)
                        .font(.subheadline)
                        .foregroundColor(LCSTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, LCSTheme.Spacing.xl)

                // Questions for this dimension
                let questions = DSRQuestionBank.questions(for: selectedDimension)
                VStack(spacing: LCSTheme.Spacing.lg) {
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
                            HStack(alignment: .top) {
                                Text("Q\(index + 1)")
                                    .font(.caption.weight(.bold).monospacedDigit())
                                    .foregroundColor(selectedDimension.color)
                                    .frame(width: 30)

                                Text(question.text)
                                    .font(.body)
                                    .foregroundColor(LCSTheme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            LikertScaleView(
                                labels: [],
                                selectedValue: Binding(
                                    get: { viewModel.dsrAnswers[question.id] },
                                    set: { val in
                                        if let v = val {
                                            viewModel.answerDSRQuestion(questionId: question.id, answer: v)
                                        }
                                    }
                                ),
                                accentColor: selectedDimension.color
                            )
                            .padding(.leading, 30)
                        }
                        .lcsCard()
                    }
                }
                .padding(.horizontal, LCSTheme.Spacing.xl)

                // Complete button
                if viewModel.isDSRComplete {
                    Button {
                        let profile = viewModel.completeDSR()
                        generatedProfile = profile
                        showResults = true
                    } label: {
                        Label("See Your Results", systemImage: "sparkles")
                    }
                    .buttonStyle(LCSTheme.PrimaryButtonStyle())
                    .padding(.vertical, LCSTheme.Spacing.xl)
                }

                Spacer(minLength: LCSTheme.Spacing.xxl)
            }
        }
        .background(LCSTheme.backgroundGradient.ignoresSafeArea())
    }

    private func answeredCount(for dimension: CognitiveDimension) -> Int {
        DSRQuestionBank.questions(for: dimension)
            .filter { viewModel.dsrAnswers[$0.id] != nil }
            .count
    }
}

// MARK: - Sidebar Row

struct DimensionSidebarRow: View {
    let dimension: CognitiveDimension
    let answeredCount: Int
    let totalCount: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: LCSTheme.Spacing.sm) {
            Image(systemName: dimension.icon)
                .font(.system(size: 16))
                .foregroundColor(dimension.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(dimension.shortName)
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? dimension.color : LCSTheme.textPrimary)

                Text("\(dimension.lowPole) ↔ \(dimension.highPole)")
                    .font(.system(size: 9))
                    .foregroundColor(LCSTheme.textTertiary)
            }

            Spacer()

            // Completion indicator
            if answeredCount == totalCount {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(LCSTheme.emerald)
                    .font(.caption)
            } else {
                Text("\(answeredCount)/\(totalCount)")
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundColor(LCSTheme.textTertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
