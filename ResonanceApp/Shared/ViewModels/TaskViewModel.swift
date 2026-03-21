// TaskViewModel.swift
// Resonance — Design for the Exhale

import SwiftUI

@Observable
final class TaskViewModel {
    var tasks: [TaskItem] = TaskItem.sampleTasks
    var selectedEnergy: EnergyLevel?
    var domains: [Domain] = Domain.sampleDomains
    var showCreateSheet = false

    var activeTasks: [TaskItem] {
        let filtered = tasks.filter { !$0.isCompleted }
        if let energy = selectedEnergy {
            return filtered.filter { $0.energy == energy }
        }
        return filtered
    }

    var completedTasks: [TaskItem] {
        tasks.filter { $0.isCompleted }
    }

    var groupedByEnergy: [(EnergyLevel, [TaskItem])] {
        EnergyLevel.allCases.compactMap { energy in
            let items = activeTasks.filter { $0.energy == energy }
            return items.isEmpty ? nil : (energy, items)
        }
    }

    func toggleComplete(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func addTask(title: String, domain: String, energy: EnergyLevel) {
        let task = TaskItem(
            title: title,
            domain: domain,
            energy: energy,
            isCompleted: false
        )
        tasks.insert(task, at: 0)
    }
}
