// DailyFlowView.swift
// Resonance — Design for the Exhale
//
// The Daily Flow view — rhythm phases with timeline visualization.

import SwiftUI

struct DailyFlowView: View {
    let theme: ResonanceTheme
    @State private var viewModel = DailyFlowViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: ResonanceTheme.spacingL) {
                // Header
                headerSection
                    .fadeIn()

                // Spaciousness
                SpacousnessGauge(percent: viewModel.spaciousnessPercent, theme: theme)
                    .fadeIn(delay: 0.1)

                // Phase Timeline
                phaseTimeline
                    .fadeIn(delay: 0.2)
            }
            .padding(ResonanceTheme.spacingM)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Flow")
                .font(ResonanceFont.displaySmall)
                .foregroundStyle(theme.textMain)

            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.currentPhase.accentColor)
                    .frame(width: 6, height: 6)

                Text("Currently in \(viewModel.currentPhase.rawValue)")
                    .font(ResonanceFont.intention)
                    .italic()
                    .foregroundStyle(theme.textMuted)
            }
        }
    }

    private var phaseTimeline: some View {
        VStack(spacing: 0) {
            ForEach(DailyPhase.allCases) { phase in
                PhaseTimelineRow(
                    phase: phase,
                    events: viewModel.events(for: phase),
                    isCurrent: phase == viewModel.currentPhase,
                    theme: theme,
                    onToggle: viewModel.toggleComplete
                )
            }
        }
    }
}

// MARK: - Phase Timeline Row

struct PhaseTimelineRow: View {
    let phase: DailyPhase
    let events: [PhaseEvent]
    let isCurrent: Bool
    let theme: ResonanceTheme
    let onToggle: (PhaseEvent) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: ResonanceTheme.spacingM) {
            // Timeline column
            VStack(spacing: 0) {
                // Node
                ZStack {
                    if isCurrent {
                        Circle()
                            .fill(phase.accentColor.opacity(0.2))
                            .frame(width: 32, height: 32)

                        Circle()
                            .fill(phase.accentColor.opacity(0.15))
                            .frame(width: 24, height: 24)
                            .breathe(intensity: 0.1, duration: 3)
                    }

                    Circle()
                        .fill(isCurrent ? phase.accentColor : theme.borderLight)
                        .frame(width: 10, height: 10)
                }
                .frame(width: 32, height: 32)

                // Line
                if phase != .rest {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [phase.accentColor.opacity(0.3), theme.borderLight.opacity(0.2)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                }
            }

            // Content column
            VStack(alignment: .leading, spacing: ResonanceTheme.spacingS) {
                // Phase header
                HStack(spacing: 8) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(isCurrent ? phase.accentColor : theme.textLight)

                    Text(phase.rawValue)
                        .font(ResonanceFont.headlineSmall)
                        .foregroundStyle(isCurrent ? theme.textMain : theme.textMuted)

                    Spacer()

                    Text(phase.timeRange)
                        .font(ResonanceFont.caption)
                        .foregroundStyle(theme.textLight)
                }

                if isCurrent {
                    Text(phase.description)
                        .font(ResonanceFont.intention)
                        .italic()
                        .foregroundStyle(theme.textMuted)
                }

                // Events
                ForEach(events) { event in
                    PhaseEventCard(event: event, theme: theme, onToggle: { onToggle(event) })
                }

                Spacer()
                    .frame(height: ResonanceTheme.spacingM)
            }
        }
    }
}

// MARK: - Phase Event Card

struct PhaseEventCard: View {
    let event: PhaseEvent
    let theme: ResonanceTheme
    let onToggle: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(
                            event.isCompleted ? theme.goldPrimary : theme.borderLight,
                            lineWidth: 1.5
                        )
                        .frame(width: 18, height: 18)

                    if event.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(theme.goldPrimary)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(ResonanceFont.bodyMedium)
                    .foregroundStyle(event.isCompleted ? theme.textLight : theme.textMain)
                    .strikethrough(event.isCompleted, color: theme.textLight)

                if let domain = event.domain {
                    DomainTag(name: domain, theme: theme)
                }
            }

            Spacer()

            Text(event.time)
                .font(ResonanceFont.caption)
                .foregroundStyle(theme.textLight)
        }
        .padding(12)
        .glassCard(theme: theme, isHovered: isHovered)
        .opacity(event.isCompleted ? 0.6 : 1.0)
        #if os(macOS) || os(visionOS)
        .onHover { isHovered = $0 }
        #endif
    }
}
