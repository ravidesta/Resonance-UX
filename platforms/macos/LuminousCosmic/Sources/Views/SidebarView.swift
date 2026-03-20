// SidebarView.swift
// Luminous Cosmic Architecture™ — macOS Sidebar
// Forest-themed navigation with gold accents

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List(selection: $appState.selectedSection) {
            ForEach(SectionGroup.allCases, id: \.self) { group in
                let sections = SidebarSection.allCases.filter { $0.sectionGroup == group }
                if !sections.isEmpty {
                    Section {
                        ForEach(sections) { section in
                            sidebarRow(section)
                                .tag(section)
                        }
                    } header: {
                        Text(group.rawValue.uppercased())
                            .font(ResonanceMacTheme.Typography.caption2)
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                            .tracking(1.2)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
        .safeAreaInset(edge: .top) {
            sidebarHeader
        }
        .safeAreaInset(edge: .bottom) {
            sidebarFooter
        }
    }

    // MARK: - Sidebar Header

    private var sidebarHeader: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.xs) {
            HStack(spacing: ResonanceMacTheme.Spacing.sm) {
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))

                Text("Luminous Cosmic")
                    .font(ResonanceMacTheme.Typography.title3)
                    .foregroundStyle(ResonanceMacTheme.Colors.cream)
            }
            .padding(.top, ResonanceMacTheme.Spacing.md)

            Text("Architecture\u{2122}")
                .font(ResonanceMacTheme.Typography.caption)
                .foregroundStyle(ResonanceMacTheme.Colors.goldLight.opacity(0.6))
                .tracking(3)

            Divider()
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, ResonanceMacTheme.Colors.gold.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.top, ResonanceMacTheme.Spacing.sm)
        }
        .padding(.horizontal, ResonanceMacTheme.Spacing.md)
    }

    // MARK: - Sidebar Row

    private func sidebarRow(_ section: SidebarSection) -> some View {
        Label {
            Text(section.rawValue)
                .font(ResonanceMacTheme.Typography.body)
        } icon: {
            Image(systemName: section.icon)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    appState.selectedSection == section
                        ? ResonanceMacTheme.Colors.gold
                        : ResonanceMacTheme.Colors.mutedGreenLight
                )
        }
    }

    // MARK: - Sidebar Footer

    private var sidebarFooter: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.sm) {
            Divider()
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, ResonanceMacTheme.Colors.gold.opacity(0.2), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            HStack(spacing: ResonanceMacTheme.Spacing.sm) {
                moonPhaseIndicator

                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentMoonPhase.rawValue)
                        .font(ResonanceMacTheme.Typography.caption)
                        .foregroundStyle(ResonanceMacTheme.Colors.cream)

                    Text("Pisces Season")
                        .font(ResonanceMacTheme.Typography.caption2)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                }

                Spacer()
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.bottom, ResonanceMacTheme.Spacing.sm)
        }
    }

    private var moonPhaseIndicator: some View {
        ZStack {
            Circle()
                .fill(ResonanceMacTheme.Colors.forestLight)
                .frame(width: 28, height: 28)

            Text(appState.currentMoonPhase.emoji)
                .font(.system(size: 16))
        }
    }
}
