// SidebarView.swift
// Luminous Cognitive Styles™ — macOS
// Navigation sidebar with sections and profile summary

import SwiftUI

struct MacSidebarView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Binding var selectedSection: MacSection

    private let groupOrder = ["Overview", "Assessment", "Learn", "Account"]

    var body: some View {
        VStack(spacing: 0) {
            // App header
            VStack(spacing: LCSTheme.Spacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(LCSTheme.goldGradient)

                Text("Luminous")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(LCSTheme.textPrimary)
                Text("Cognitive Styles")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(LCSTheme.textTertiary)
            }
            .padding(.vertical, LCSTheme.Spacing.lg)
            .frame(maxWidth: .infinity)

            Divider().background(Color.white.opacity(0.08))

            // Profile summary
            if let profile = viewModel.currentProfile {
                VStack(spacing: LCSTheme.Spacing.sm) {
                    CompactRadarChartView(profile: profile, size: 60)

                    Text(profile.profileTypeName)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(LCSTheme.textPrimary)

                    Text(profile.assessmentType.rawValue)
                        .font(.system(size: 9))
                        .foregroundColor(LCSTheme.textTertiary)
                }
                .padding(.vertical, LCSTheme.Spacing.md)
                .frame(maxWidth: .infinity)

                Divider().background(Color.white.opacity(0.08))
            }

            // Navigation list
            List(selection: $selectedSection) {
                ForEach(groupOrder, id: \.self) { group in
                    Section(group) {
                        ForEach(MacSection.allCases.filter { $0.group == group }) { section in
                            Label(section.rawValue, systemImage: section.icon)
                                .tag(section)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .background(LCSTheme.deepNavy.opacity(0.95))
        .frame(minWidth: 200, idealWidth: 220)
    }
}
