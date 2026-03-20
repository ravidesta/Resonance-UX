// WatchDailyInsightView.swift
// Luminous Cosmic Architecture™ — watchOS Daily Insight
// Single reflection prompt with swipe navigation

import SwiftUI

struct WatchDailyInsightView: View {
    @EnvironmentObject var watchState: WatchState
    @State private var currentIndex: Int = 0
    @State private var sparkle: Bool = false

    private let insights: [DailyInsightItem] = [
        DailyInsightItem(
            prompt: "What hidden truth is surfacing for you today?",
            context: "Scorpio Moon",
            icon: "moon"
        ),
        DailyInsightItem(
            prompt: "Where can you surrender control and trust the current?",
            context: "Pisces Season",
            icon: "water.waves"
        ),
        DailyInsightItem(
            prompt: "What tension is building your capacity for something greater?",
            context: "Mars square Saturn",
            icon: "circle.circle"
        ),
        DailyInsightItem(
            prompt: "How might you expand your sense of what is possible?",
            context: "Venus trine Jupiter",
            icon: "sparkles"
        ),
    ]

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(insights.indices, id: \.self) { index in
                insightPage(insights[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.verticalPage)
        .background(WatchTheme.Colors.background)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                sparkle = true
            }
        }
    }

    private func insightPage(_ item: DailyInsightItem) -> some View {
        VStack(spacing: WatchTheme.Spacing.lg) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(WatchTheme.Colors.surfaceAccent.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .scaleEffect(sparkle ? 1.05 : 0.95)

                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(WatchTheme.Colors.gold)
            }

            // Context
            Text(item.context.uppercased())
                .font(WatchTheme.Typography.caption2)
                .foregroundStyle(WatchTheme.Colors.gold)
                .tracking(1)

            // Prompt
            Text(item.prompt)
                .font(WatchTheme.Typography.body)
                .foregroundStyle(WatchTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, WatchTheme.Spacing.md)

            Spacer()

            // Page indicator
            HStack(spacing: 4) {
                ForEach(insights.indices, id: \.self) { index in
                    Circle()
                        .fill(
                            index == currentIndex
                                ? WatchTheme.Colors.gold
                                : WatchTheme.Colors.textTertiary.opacity(0.4)
                        )
                        .frame(width: 4, height: 4)
                }
            }
        }
        .padding(.vertical, WatchTheme.Spacing.md)
    }
}

struct DailyInsightItem {
    let prompt: String
    let context: String
    let icon: String
}
