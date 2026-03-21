// FocusView.swift
// Resonance — Design for the Exhale
//
// Task management organized by energy level.

import SwiftUI

struct FocusView: View {
    let theme: ResonanceTheme
    @State private var viewModel = TaskViewModel()

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: ResonanceTheme.spacingL) {
                // Header
                headerSection
                    .fadeIn()

                // Energy Filters
                energyFilters
                    .fadeIn(delay: 0.1)

                // Tasks grouped by energy
                tasksList
                    .fadeIn(delay: 0.2)

                // Completed section
                if !viewModel.completedTasks.isEmpty {
                    completedSection
                        .fadeIn(delay: 0.3)
                }
            }
            .padding(ResonanceTheme.spacingM)
        }
        .overlay(alignment: .bottomTrailing) {
            createButton
                .padding(ResonanceTheme.spacingL)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Focus")
                .font(ResonanceFont.displaySmall)
                .foregroundStyle(theme.textMain)

            Text("Tasks aligned to your energy")
                .font(ResonanceFont.intention)
                .italic()
                .foregroundStyle(theme.textMuted)
        }
    }

    private var energyFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All filter
                EnergyFilterChip(
                    label: "All",
                    icon: "circle.grid.2x2",
                    color: theme.goldPrimary,
                    isSelected: viewModel.selectedEnergy == nil,
                    theme: theme
                ) {
                    withAnimation(ResonanceAnimation.spring) {
                        viewModel.selectedEnergy = nil
                    }
                }

                ForEach(EnergyLevel.allCases) { energy in
                    EnergyFilterChip(
                        label: energy.rawValue,
                        icon: energy.icon,
                        color: energy.color,
                        isSelected: viewModel.selectedEnergy == energy,
                        theme: theme
                    ) {
                        withAnimation(ResonanceAnimation.spring) {
                            viewModel.selectedEnergy = energy
                        }
                    }
                }
            }
        }
    }

    private var tasksList: some View {
        LazyVStack(spacing: ResonanceTheme.spacingM) {
            if viewModel.selectedEnergy != nil {
                ForEach(viewModel.activeTasks) { task in
                    TaskCardView(task: task, theme: theme) {
                        withAnimation(ResonanceAnimation.complete) {
                            viewModel.toggleComplete(task)
                        }
                    }
                }
            } else {
                ForEach(viewModel.groupedByEnergy, id: \.0) { energy, tasks in
                    VStack(alignment: .leading, spacing: ResonanceTheme.spacingS) {
                        // Energy group header
                        HStack(spacing: 6) {
                            Image(systemName: energy.icon)
                                .font(.system(size: 12))
                                .foregroundStyle(energy.color)
                            Text(energy.rawValue.uppercased())
                                .font(ResonanceFont.labelSmall)
                                .tracking(1.5)
                                .foregroundStyle(energy.color)
                        }
                        .padding(.leading, 4)

                        ForEach(tasks) { task in
                            TaskCardView(task: task, theme: theme) {
                                withAnimation(ResonanceAnimation.complete) {
                                    viewModel.toggleComplete(task)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.spacingS) {
            HStack {
                Text("Completed")
                    .font(ResonanceFont.labelMedium)
                    .foregroundStyle(theme.textLight)

                Spacer()

                Text("\(viewModel.completedTasks.count)")
                    .font(ResonanceFont.labelSmall)
                    .foregroundStyle(theme.textLight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(theme.borderLight.opacity(0.3)))
            }

            Rectangle()
                .fill(theme.borderLight.opacity(0.3))
                .frame(height: 0.5)

            ForEach(viewModel.completedTasks) { task in
                TaskCardView(task: task, theme: theme) {
                    withAnimation(ResonanceAnimation.complete) {
                        viewModel.toggleComplete(task)
                    }
                }
                .opacity(0.5)
            }
        }
    }

    private var createButton: some View {
        Button {
            viewModel.showCreateSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .light))
                .foregroundStyle(theme.goldPrimary)
                .frame(width: 52, height: 52)
                .background {
                    Circle()
                        .fill(theme.bgSurface)
                        .shadow(color: theme.goldPrimary.opacity(0.15), radius: 12, y: 4)
                }
                .overlay {
                    Circle()
                        .stroke(theme.goldPrimary.opacity(0.2), lineWidth: 0.5)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Energy Filter Chip

struct EnergyFilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let theme: ResonanceTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(label)
                    .font(ResonanceFont.labelSmall)
            }
            .foregroundStyle(isSelected ? .white : theme.textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                Capsule()
                    .fill(isSelected ? color : theme.bgSurface.opacity(0.6))
            }
            .overlay {
                Capsule()
                    .stroke(isSelected ? color.opacity(0.5) : theme.borderLight.opacity(0.3), lineWidth: 0.5)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

// MARK: - Task Card View

struct TaskCardView: View {
    let task: TaskItem
    let theme: ResonanceTheme
    let onToggle: () -> Void
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(
                            task.isCompleted ? theme.goldPrimary : theme.borderLight,
                            lineWidth: 1.5
                        )
                        .frame(width: 20, height: 20)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(theme.goldPrimary)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(isHovered ? 1.1 : 1.0)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(ResonanceFont.bodyMedium)
                    .foregroundStyle(task.isCompleted ? theme.textLight : theme.textMain)
                    .strikethrough(task.isCompleted, color: theme.textLight)

                HStack(spacing: 6) {
                    DomainTag(name: task.domain, theme: theme)

                    if let collaborator = task.collaborator {
                        Text("with \(collaborator)")
                            .font(ResonanceFont.caption)
                            .foregroundStyle(theme.textLight)
                    }
                }
            }

            Spacer()

            // Energy indicator
            Image(systemName: task.energy.icon)
                .font(.system(size: 12))
                .foregroundStyle(task.energy.color.opacity(0.6))

            if let due = task.dueDescription {
                Text(due)
                    .font(ResonanceFont.caption)
                    .foregroundStyle(theme.textLight)
            }
        }
        .padding(12)
        .glassCard(theme: theme, isHovered: isHovered)
        #if os(macOS) || os(visionOS)
        .onHover { isHovered = $0 }
        #endif
    }
}
