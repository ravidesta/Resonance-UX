// WatchDailyFlowView.swift
// Resonance — Design for the Exhale
//
// Compact daily flow timeline for Apple Watch.

import SwiftUI

#if os(watchOS)
struct WatchDailyFlowView: View {
    let theme: ResonanceTheme
    private let currentPhase = DailyPhase.current()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(DailyPhase.allCases) { phase in
                    WatchPhaseRow(
                        phase: phase,
                        isCurrent: phase == currentPhase,
                        events: PhaseEvent.sampleEvents.filter { $0.phase == phase },
                        theme: theme
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .background(theme.bgBase)
        .navigationTitle("Flow")
    }
}

struct WatchPhaseRow: View {
    let phase: DailyPhase
    let isCurrent: Bool
    let events: [PhaseEvent]
    let theme: ResonanceTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Phase header
            HStack(spacing: 6) {
                Image(systemName: phase.icon)
                    .font(.system(size: 12))
                    .foregroundStyle(isCurrent ? phase.accentColor : theme.textLight)

                Text(phase.rawValue)
                    .font(ResonanceFont.watchBody)
                    .fontWeight(isCurrent ? .semibold : .regular)
                    .foregroundStyle(isCurrent ? theme.textMain : theme.textMuted)

                Spacer()

                Text(phase.timeRange)
                    .font(ResonanceFont.watchCaption)
                    .foregroundStyle(theme.textLight)
            }

            // Events
            ForEach(events) { event in
                HStack(spacing: 6) {
                    Circle()
                        .fill(event.isCompleted ? theme.goldPrimary : theme.borderLight)
                        .frame(width: 5, height: 5)

                    Text(event.title)
                        .font(ResonanceFont.watchCaption)
                        .foregroundStyle(event.isCompleted ? theme.textLight : theme.textMain)
                        .lineLimit(1)
                        .strikethrough(event.isCompleted)
                }
                .padding(.leading, 18)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent ? phase.accentColor.opacity(0.08) : theme.bgSurface.opacity(0.4))
                .overlay {
                    if isCurrent {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(phase.accentColor.opacity(0.3), lineWidth: 0.5)
                    }
                }
        }
    }
}
#endif
