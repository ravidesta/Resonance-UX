// MARK: - Developmental Assessment View
// "These are snapshots, not verdicts."
// Maps meaning-making across six life domains.

import SwiftUI

struct AssessmentView: View {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var viewModel = AssessmentViewModel()
    @State private var currentStep: AssessmentStep = .intro

    enum AssessmentStep {
        case intro, domains, somatic, review, complete
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                switch currentStep {
                case .intro:
                    introView
                case .domains:
                    domainAssessmentView
                case .somatic:
                    somaticSeasonView
                case .review:
                    reviewView
                case .complete:
                    completeView
                }
            }
        }
    }

    // MARK: - Intro

    private var introView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)

                Text("Developmental\nAssessment")
                    .font(.custom("Cormorant Garamond", size: 36))
                    .fontWeight(.light)
                    .foregroundColor(theme.text)
                    .multilineTextAlignment(.center)

                VStack(spacing: 16) {
                    SafetyCard(text: """
                    This assessment maps your meaning-making landscape across six life domains. \
                    It is a tool for understanding, not ranking. Every stage has its own dignity.
                    """)

                    Text("You will reflect on how you currently make meaning in:")
                        .font(.custom("Manrope", size: 15))
                        .foregroundColor(theme.textSecondary)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(LifeDomain.allCases, id: \.self) { domain in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(colorForDomain(domain))
                                    .frame(width: 10, height: 10)
                                Text(domain.rawValue)
                                    .font(.custom("Manrope", size: 15))
                                    .foregroundColor(theme.text)
                            }
                        }
                    }
                    .padding(.horizontal, 40)

                    Text("Take your time. There are no right answers.")
                        .font(.custom("Cormorant Garamond", size: 18).italic())
                        .foregroundColor(theme.textSecondary)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)

                Button(action: { withAnimation { currentStep = .domains } }) {
                    Text("Begin")
                        .font(.custom("Manrope", size: 15).weight(.semibold))
                        .foregroundColor(theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.forestBase)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Domain Assessment

    private var domainAssessmentView: some View {
        TabView(selection: $viewModel.currentDomainIndex) {
            ForEach(Array(LifeDomain.allCases.enumerated()), id: \.offset) { index, domain in
                DomainAssessmentCard(
                    domain: domain,
                    onComplete: { assessment in
                        viewModel.saveDomainAssessment(assessment)
                        if index < LifeDomain.allCases.count - 1 {
                            withAnimation { viewModel.currentDomainIndex = index + 1 }
                        } else {
                            withAnimation { currentStep = .somatic }
                        }
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
    }

    // MARK: - Somatic Season

    private var somaticSeasonView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("Somatic Season")
                    .font(.custom("Cormorant Garamond", size: 32))
                    .foregroundColor(theme.text)

                Text("Place one hand on the area of your body that feels most alive right now. Breathe into that place. Ask it: What season are we in?")
                    .font(.custom("Cormorant Garamond", size: 18))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                VStack(spacing: 16) {
                    ForEach(SomaticSeason.allCases, id: \.self) { season in
                        Button(action: {
                            viewModel.selectedSeason = season
                        }) {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(viewModel.selectedSeason == season
                                        ? (theme.seasonColors[season] ?? theme.accent)
                                        : theme.textMuted.opacity(0.2))
                                    .frame(width: 32, height: 32)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(season.rawValue)
                                        .font(.custom("Manrope", size: 16).weight(.medium))
                                        .foregroundColor(theme.text)
                                    Text(season.description)
                                        .font(.custom("Manrope", size: 13))
                                        .foregroundColor(theme.textSecondary)
                                        .lineLimit(2)
                                }

                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.selectedSeason == season
                                        ? (theme.seasonColors[season] ?? theme.accent).opacity(0.06)
                                        : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.selectedSeason == season
                                        ? (theme.seasonColors[season] ?? theme.accent).opacity(0.2)
                                        : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                Button(action: { withAnimation { currentStep = .review } }) {
                    Text("Continue")
                        .font(.custom("Manrope", size: 15).weight(.semibold))
                        .foregroundColor(theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.forestBase)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .disabled(viewModel.selectedSeason == nil)
            }
            .padding(.vertical, 32)
        }
    }

    // MARK: - Review

    private var reviewView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Your Landscape")
                    .font(.custom("Cormorant Garamond", size: 32))
                    .foregroundColor(theme.text)

                Text("Remember: these are snapshots of how you are currently making meaning — not measures of your worth.")
                    .font(.custom("Manrope", size: 14))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Domain results
                ForEach(viewModel.domainAssessments) { assessment in
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(colorForDomain(assessment.domain))
                                    .frame(width: 10, height: 10)
                                Text(assessment.domain.rawValue)
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)
                                Spacer()
                            }

                            Text(assessment.primaryOrder.name)
                                .font(.custom("Cormorant Garamond", size: 22))
                                .foregroundColor(theme.text)

                            if let edge = assessment.growingEdge {
                                Text("Growing edge: \(edge)")
                                    .font(.custom("Manrope", size: 13))
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                    }
                }

                // Season
                if let season = viewModel.selectedSeason {
                    GlassCard {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(theme.seasonColors[season] ?? theme.accent)
                                .frame(width: 24, height: 24)
                            VStack(alignment: .leading) {
                                Text("Somatic Season")
                                    .font(.custom("Manrope", size: 12))
                                    .foregroundColor(theme.textSecondary)
                                Text(season.rawValue)
                                    .font(.custom("Cormorant Garamond", size: 20))
                                    .foregroundColor(theme.text)
                            }
                        }
                    }
                }

                // Reflection
                TextEditor(text: $viewModel.overallReflection)
                    .font(.custom("Manrope", size: 15))
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.forestBase.opacity(0.04))
                    )
                    .overlay(
                        Group {
                            if viewModel.overallReflection.isEmpty {
                                Text("Any overall reflections on your landscape?")
                                    .font(.custom("Manrope", size: 15))
                                    .foregroundColor(theme.textMuted)
                                    .padding(16)
                                    .allowsHitTesting(false)
                            }
                        }, alignment: .topLeading
                    )

                // Share + complete
                HStack(spacing: 12) {
                    Button(action: { /* Share with provider */ }) {
                        Label("Share with Provider", systemImage: "stethoscope")
                            .font(.custom("Manrope", size: 14).weight(.medium))
                            .foregroundColor(theme.forestBase)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule().stroke(theme.forestBase, lineWidth: 1.5)
                            )
                    }

                    Button(action: { withAnimation { currentStep = .complete } }) {
                        Text("Complete")
                            .font(.custom("Manrope", size: 14).weight(.semibold))
                            .foregroundColor(theme.cream)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(theme.forestBase)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Complete

    private var completeView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(theme.goldPrimary)

            Text("Assessment Complete")
                .font(.custom("Cormorant Garamond", size: 32))
                .foregroundColor(theme.text)

            Text("Your Guide now has context for more meaningful conversations. Your landscape is a living map — it will evolve as you do.")
                .font(.custom("Manrope", size: 15))
                .foregroundColor(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func colorForDomain(_ domain: LifeDomain) -> Color {
        switch domain {
        case .personal:     return Color(hex: "4A9A6A")
        case .professional: return Color(hex: "5A8AB0")
        case .relational:   return Color(hex: "C5A059")
        case .emotional:    return Color(hex: "8B6BB0")
        case .spiritual:    return Color(hex: "B07A5A")
        case .somatic:      return Color(hex: "E8A87C")
        }
    }
}

// MARK: - Safety Card

struct SafetyCard: View {
    let text: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "heart.text.square")
                .foregroundColor(theme.goldPrimary)
            Text(text)
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.goldPrimary.opacity(0.04))
        )
    }
}

// MARK: - Domain Assessment Card

struct DomainAssessmentCard: View {
    let domain: LifeDomain
    let onComplete: (DevelopmentalAssessment.DomainAssessment) -> Void
    @EnvironmentObject var theme: ThemeManager

    @State private var selectedOrder: DevelopmentalOrder = .socialized
    @State private var subjectTerritory: String = ""
    @State private var objectTerritory: String = ""
    @State private var growingEdge: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(domain.rawValue)
                    .font(.custom("Cormorant Garamond", size: 28))
                    .foregroundColor(theme.text)

                Text(promptForDomain(domain))
                    .font(.custom("Manrope", size: 15))
                    .foregroundColor(theme.textSecondary)
                    .lineSpacing(4)

                // Order selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Which description resonates most?")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(theme.textSecondary)

                    ForEach(DevelopmentalOrder.allCases) { order in
                        Button(action: { selectedOrder = order }) {
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(selectedOrder == order
                                        ? (theme.orderColors[order] ?? theme.accent)
                                        : theme.textMuted.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                    .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(order.name)
                                        .font(.custom("Manrope", size: 15).weight(.medium))
                                        .foregroundColor(theme.text)
                                    Text(order.description)
                                        .font(.custom("Manrope", size: 13))
                                        .foregroundColor(theme.textSecondary)
                                        .lineLimit(3)
                                }
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedOrder == order
                                        ? (theme.orderColors[order] ?? theme.accent).opacity(0.06)
                                        : Color.clear)
                            )
                        }
                    }
                }

                // Subject territory
                VStack(alignment: .leading, spacing: 6) {
                    Text("What has you in this domain?")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(theme.textSecondary)
                    Text("What feels like 'just the way things are' rather than a perspective?")
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(theme.textMuted)
                    TextField("", text: $subjectTerritory, axis: .vertical)
                        .lineLimit(3...5)
                        .textFieldStyle(.roundedBorder)
                }

                // Growing edge
                VStack(alignment: .leading, spacing: 6) {
                    Text("Where is your growing edge?")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(theme.textSecondary)
                    TextField("", text: $growingEdge, axis: .vertical)
                        .lineLimit(2...3)
                        .textFieldStyle(.roundedBorder)
                }

                Button(action: {
                    let assessment = DevelopmentalAssessment.DomainAssessment(
                        id: UUID(), domain: domain,
                        primaryOrder: selectedOrder,
                        subjectTerritory: subjectTerritory.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                        objectTerritory: objectTerritory.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                        growingEdge: growingEdge.isEmpty ? nil : growingEdge,
                        confidence: 0.5
                    )
                    onComplete(assessment)
                }) {
                    Text("Next Domain")
                        .font(.custom("Manrope", size: 15).weight(.semibold))
                        .foregroundColor(theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.forestBase)
                        .clipShape(Capsule())
                }
            }
            .padding(24)
        }
    }

    private func promptForDomain(_ domain: LifeDomain) -> String {
        switch domain {
        case .personal:     return "How do you make sense of who you are? What defines your identity right now?"
        case .professional: return "How do you organize your work life? What values guide your professional decisions?"
        case .relational:   return "How do you make meaning in close relationships? What feels non-negotiable?"
        case .emotional:    return "How do you relate to your emotional life? Do emotions have you, or do you have them?"
        case .spiritual:    return "How do you make sense of meaning, purpose, and what lies beyond the personal?"
        case .somatic:      return "How do you relate to your body? What patterns of tension, ease, or numbness do you notice?"
        }
    }
}

// MARK: - View Model

@MainActor
final class AssessmentViewModel: ObservableObject {
    @Published var currentDomainIndex: Int = 0
    @Published var domainAssessments: [DevelopmentalAssessment.DomainAssessment] = []
    @Published var selectedSeason: SomaticSeason?
    @Published var overallReflection: String = ""

    func saveDomainAssessment(_ assessment: DevelopmentalAssessment.DomainAssessment) {
        domainAssessments.append(assessment)
    }
}
