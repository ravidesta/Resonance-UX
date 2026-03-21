// DailyPhase.swift
// Resonance — Design for the Exhale

import SwiftUI

// MARK: - Daily Phase

enum DailyPhase: String, CaseIterable, Identifiable {
    case ascend = "Ascend"
    case zenith = "Zenith"
    case descent = "Descent"
    case rest = "Rest"

    var id: String { rawValue }

    var timeRange: String {
        switch self {
        case .ascend: return "8 – 11am"
        case .zenith: return "11am – 2pm"
        case .descent: return "2 – 5pm"
        case .rest: return "5pm +"
        }
    }

    var description: String {
        switch self {
        case .ascend: return "Rising energy, deep focus"
        case .zenith: return "Peak clarity, bold decisions"
        case .descent: return "Winding down, gentle tasks"
        case .rest: return "Restoration, open space"
        }
    }

    var icon: String {
        switch self {
        case .ascend: return "sunrise.fill"
        case .zenith: return "sun.max.fill"
        case .descent: return "sunset.fill"
        case .rest: return "moon.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .ascend: return Color(hex: "D87050")
        case .zenith: return Color(hex: "C5A059")
        case .descent: return Color(hex: "9A7A3A")
        case .rest: return Color(hex: "5C7065")
        }
    }

    static func current(at date: Date = .now) -> DailyPhase {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 8..<11: return .ascend
        case 11..<14: return .zenith
        case 14..<17: return .descent
        default: return .rest
        }
    }
}

// MARK: - Phase Event

struct PhaseEvent: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let phase: DailyPhase
    let domain: String?
    let isCompleted: Bool

    static let sampleEvents: [PhaseEvent] = [
        PhaseEvent(title: "Morning pages", time: "8:00", phase: .ascend, domain: "Cultivation", isCompleted: true),
        PhaseEvent(title: "Deep work session", time: "9:00", phase: .ascend, domain: "Client Work", isCompleted: false),
        PhaseEvent(title: "Strategy review", time: "11:30", phase: .zenith, domain: "Client Work", isCompleted: false),
        PhaseEvent(title: "Team sync", time: "1:00", phase: .zenith, domain: "Admin", isCompleted: false),
        PhaseEvent(title: "Documentation", time: "2:30", phase: .descent, domain: "Cultivation", isCompleted: false),
        PhaseEvent(title: "Email & correspondence", time: "3:30", phase: .descent, domain: "Admin", isCompleted: false),
        PhaseEvent(title: "Evening walk", time: "5:30", phase: .rest, domain: nil, isCompleted: false),
        PhaseEvent(title: "Reading", time: "7:00", phase: .rest, domain: "Cultivation", isCompleted: false),
    ]
}
