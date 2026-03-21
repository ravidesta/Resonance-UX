// TaskItem.swift
// Resonance — Design for the Exhale

import SwiftUI

// MARK: - Energy Level

enum EnergyLevel: String, CaseIterable, Identifiable {
    case high = "High"
    case balanced = "Balanced"
    case low = "Low"
    case restorative = "Restorative"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .high: return "sun.max.fill"
        case .balanced: return "leaf.fill"
        case .low: return "moon.fill"
        case .restorative: return "wind"
        }
    }

    var color: Color {
        switch self {
        case .high: return Color(hex: "D87050")
        case .balanced: return Color(hex: "9A7A3A")
        case .low: return Color(hex: "5C7065")
        case .restorative: return Color(hex: "8A9C91")
        }
    }

    var description: String {
        switch self {
        case .high: return "Full presence required"
        case .balanced: return "Steady engagement"
        case .low: return "Gentle attention"
        case .restorative: return "Nurturing & renewal"
        }
    }
}

// MARK: - Task Item

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var domain: String
    var energy: EnergyLevel
    var isCompleted: Bool
    var collaborator: String?
    var dueDescription: String?

    static let sampleTasks: [TaskItem] = [
        TaskItem(title: "Finalize proposal draft", domain: "Client Work", energy: .high, isCompleted: false, collaborator: "Sarah", dueDescription: "Today"),
        TaskItem(title: "Review design system tokens", domain: "Cultivation", energy: .high, isCompleted: false, dueDescription: "This week"),
        TaskItem(title: "Quarterly planning notes", domain: "Admin", energy: .balanced, isCompleted: false, dueDescription: "Tomorrow"),
        TaskItem(title: "Garden bed preparation", domain: "Cultivation", energy: .balanced, isCompleted: true),
        TaskItem(title: "Sort through inbox", domain: "Admin", energy: .low, isCompleted: false),
        TaskItem(title: "Update project timeline", domain: "Client Work", energy: .low, isCompleted: false, collaborator: "James"),
        TaskItem(title: "Guided meditation", domain: "Cultivation", energy: .restorative, isCompleted: false, dueDescription: "Daily"),
        TaskItem(title: "Nature journaling", domain: "Cultivation", energy: .restorative, isCompleted: true),
        TaskItem(title: "Organize bookmarks", domain: "Admin", energy: .low, isCompleted: true),
    ]
}

// MARK: - Domain

struct Domain: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let activeCount: Int

    static let sampleDomains: [Domain] = [
        Domain(name: "Client Work", color: Color(hex: "D87050"), activeCount: 3),
        Domain(name: "Cultivation", color: Color(hex: "C5A059"), activeCount: 4),
        Domain(name: "Admin & Operations", color: Color(hex: "5C7065"), activeCount: 2),
    ]
}
