// DailyFlowViewModel.swift
// Resonance — Design for the Exhale

import SwiftUI

@MainActor @Observable
final class DailyFlowViewModel {
    var events: [PhaseEvent] = PhaseEvent.sampleEvents
    var currentPhase: DailyPhase = .current()
    var selectedPhase: DailyPhase?

    var spaciousnessPercent: Int {
        // Calculate unstructured time as percentage of day
        let totalSlots = 10 // Available hour slots 8am-6pm
        let busySlots = events.count
        return max(0, Int((Double(totalSlots - busySlots) / Double(totalSlots)) * 100))
    }

    func events(for phase: DailyPhase) -> [PhaseEvent] {
        events.filter { $0.phase == phase }
    }

    func toggleComplete(_ event: PhaseEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = PhaseEvent(
                title: event.title,
                time: event.time,
                phase: event.phase,
                domain: event.domain,
                isCompleted: !event.isCompleted
            )
        }
    }
}
