// SpatialDailyFlowView.swift
// Resonance — Design for the Exhale
//
// Spatial daily flow for Vision Pro — floating phase panels with depth.

import SwiftUI

#if os(visionOS)
struct SpatialDailyFlowView: View {
    let theme: ResonanceTheme
    @State private var viewModel = DailyFlowViewModel()
    @State private var expandedPhase: DailyPhase?

    var body: some View {
        HStack(spacing: ResonanceTheme.spacingM) {
            // Phase cards as spatial panels
            ForEach(DailyPhase.allCases) { phase in
                SpatialPhasePanel(
                    phase: phase,
                    events: viewModel.events(for: phase),
                    isCurrent: phase == viewModel.currentPhase,
                    isExpanded: expandedPhase == phase,
                    theme: theme
                ) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        expandedPhase = expandedPhase == phase ? nil : phase
                    }
                }
            }
        }
        .padding(ResonanceTheme.spacingXL)
    }
}

struct SpatialPhasePanel: View {
    let phase: DailyPhase
    let events: [PhaseEvent]
    let isCurrent: Bool
    let isExpanded: Bool
    let theme: ResonanceTheme
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.spacingM) {
            // Phase header
            HStack(spacing: 10) {
                Image(systemName: phase.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(phase.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(phase.rawValue)
                        .font(ResonanceFont.headlineLarge)
                        .foregroundStyle(theme.textMain)

                    Text(phase.timeRange)
                        .font(ResonanceFont.caption)
                        .foregroundStyle(theme.textLight)
                }
            }

            if isCurrent {
                Text(phase.description)
                    .font(ResonanceFont.intention)
                    .italic()
                    .foregroundStyle(theme.textMuted)
            }

            if isExpanded {
                Divider()
                    .foregroundStyle(theme.borderLight.opacity(0.3))

                ForEach(events) { event in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(event.isCompleted ? theme.goldPrimary : theme.borderLight)
                            .frame(width: 7, height: 7)

                        Text(event.title)
                            .font(ResonanceFont.bodyMedium)
                            .foregroundStyle(theme.textMain)

                        Spacer()

                        Text(event.time)
                            .font(ResonanceFont.caption)
                            .foregroundStyle(theme.textLight)
                    }
                }
            }
        }
        .padding(ResonanceTheme.spacingL)
        .frame(width: isExpanded ? 300 : 200)
        .glassPanel(
            theme: theme,
            cornerRadius: ResonanceTheme.cornerLarge,
            raised: isCurrent
        )
        .hoverEffect(.lift)
        .offset(z: isCurrent ? 20 : 0)
        .onTapGesture(perform: onTap)
    }
}
#endif
