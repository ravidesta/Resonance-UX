// WatchTaskView.swift
// Resonance — Design for the Exhale
//
// Quick task management on Apple Watch — complete tasks with a tap.

import SwiftUI

#if os(watchOS)
struct WatchTaskView: View {
    let theme: ResonanceTheme
    @State private var tasks = TaskItem.sampleTasks

    var activeTasks: [TaskItem] { tasks.filter { !$0.isCompleted } }
    var completedCount: Int { tasks.filter(\.isCompleted).count }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 6) {
                // Summary
                HStack {
                    Text("\(activeTasks.count) active")
                        .font(ResonanceFont.watchCaption)
                        .foregroundStyle(theme.textMuted)
                    Spacer()
                    Text("\(completedCount) done")
                        .font(ResonanceFont.watchCaption)
                        .foregroundStyle(theme.goldPrimary)
                }
                .padding(.horizontal, 4)

                ForEach(activeTasks) { task in
                    WatchTaskRow(task: task, theme: theme) {
                        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                            withAnimation(.spring(response: 0.3)) {
                                tasks[index].isCompleted = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .background(theme.bgBase)
        .navigationTitle("Focus")
    }
}

struct WatchTaskRow: View {
    let task: TaskItem
    let theme: ResonanceTheme
    let onComplete: () -> Void

    var body: some View {
        Button(action: onComplete) {
            HStack(spacing: 8) {
                // Energy indicator
                Image(systemName: task.energy.icon)
                    .font(.system(size: 10))
                    .foregroundStyle(task.energy.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(ResonanceFont.watchBody)
                        .foregroundStyle(theme.textMain)
                        .lineLimit(2)

                    Text(task.domain.uppercased())
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1)
                        .foregroundStyle(theme.textLight)
                }

                Spacer()
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(theme.bgSurface.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }
}
#endif
