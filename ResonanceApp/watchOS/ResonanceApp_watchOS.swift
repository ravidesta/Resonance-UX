// ResonanceApp_watchOS.swift
// Resonance — Design for the Exhale
//
// Apple Watch entry point — glanceable daily flow, quick tasks, breathing.

import SwiftUI

#if os(watchOS)
@main
struct ResonanceApp_watchOS: App {
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}

// MARK: - Watch Content View

struct WatchContentView: View {
    @State private var themeManager = ThemeManager()

    var theme: ResonanceTheme { themeManager.currentTheme }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    // Current phase card
                    WatchPhaseCard(theme: theme)

                    // Quick actions
                    NavigationLink {
                        WatchDailyFlowView(theme: theme)
                    } label: {
                        WatchActionRow(icon: "leaf.fill", title: "Daily Flow", theme: theme)
                    }

                    NavigationLink {
                        WatchTaskView(theme: theme)
                    } label: {
                        WatchActionRow(icon: "circle.grid.2x2", title: "Focus", theme: theme)
                    }

                    NavigationLink {
                        WatchBreathingView(theme: theme)
                    } label: {
                        WatchActionRow(icon: "wind", title: "Breathe", theme: theme)
                    }

                    // Deep Rest toggle
                    Button {
                        themeManager.toggle()
                    } label: {
                        HStack {
                            Image(systemName: themeManager.isDeepRest ? "moon.fill" : "sun.max.fill")
                                .foregroundStyle(theme.goldPrimary)
                            Text(themeManager.isDeepRest ? "Deep Rest" : "Daylight")
                                .font(ResonanceFont.watchBody)
                                .foregroundStyle(theme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
            }
            .background(theme.bgBase)
            .navigationTitle {
                Text("Resonance")
                    .font(ResonanceFont.watchTitle)
                    .foregroundStyle(theme.textMain)
            }
        }
    }
}

// MARK: - Watch Phase Card

struct WatchPhaseCard: View {
    let theme: ResonanceTheme
    private let currentPhase = DailyPhase.current()

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: currentPhase.icon)
                .font(.system(size: 24))
                .foregroundStyle(currentPhase.accentColor)

            Text(currentPhase.rawValue)
                .font(ResonanceFont.watchTitle)
                .foregroundStyle(theme.textMain)

            Text(currentPhase.timeRange)
                .font(ResonanceFont.watchCaption)
                .foregroundStyle(theme.textLight)

            Text(currentPhase.description)
                .font(ResonanceFont.watchCaption)
                .foregroundStyle(theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(theme.bgSurface.opacity(0.6))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(currentPhase.accentColor.opacity(0.2), lineWidth: 0.5)
                }
        }
    }
}

// MARK: - Watch Action Row

struct WatchActionRow: View {
    let icon: String
    let title: String
    let theme: ResonanceTheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(theme.goldPrimary)
                .frame(width: 28, height: 28)
                .background {
                    Circle()
                        .fill(theme.goldPrimary.opacity(0.12))
                }

            Text(title)
                .font(ResonanceFont.watchBody)
                .foregroundStyle(theme.textMain)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .light))
                .foregroundStyle(theme.textLight)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.bgSurface.opacity(0.5))
        }
    }
}
#endif
