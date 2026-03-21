// Document.swift
// Resonance — Design for the Exhale

import SwiftUI
import Foundation

struct WriterDocument: Identifiable {
    let id = UUID()
    var title: String
    var body: String
    var createdAt: Date
    var wordCount: Int
    var isFavorite: Bool

    var readingTime: String {
        let minutes = max(1, wordCount / 200)
        return "\(minutes) min read"
    }

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }

    static let sampleDocuments: [WriterDocument] = [
        WriterDocument(
            title: "On Spaciousness",
            body: "There is a quality to unoccupied time that we have forgotten how to honor. In the margins between tasks, in the breath between sentences, there exists a spaciousness that is not emptiness but fullness of a different kind.\n\nWe have been conditioned to fill every gap, to optimize every moment, to transform rest into productivity. But what if the gap itself is the gift?\n\nThe Japanese concept of ma — negative space — teaches us that the pause between notes is what gives music its meaning. The white space on a page is what allows the words to breathe.",
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
            wordCount: 847,
            isFavorite: true
        ),
        WriterDocument(
            title: "Morning Pages — March",
            body: "The light comes differently in March. It arrives with a gentleness that February doesn't know, slanting through windows at angles that make everything look like a painting by someone who understood patience.",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            wordCount: 1243,
            isFavorite: false
        ),
        WriterDocument(
            title: "Letter to Future Self",
            body: "Dear one who reads this later — I hope you have learned to sit with the silence without reaching for your phone. I hope the garden grew. I hope you still write by hand sometimes.",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now)!,
            wordCount: 562,
            isFavorite: true
        ),
        WriterDocument(
            title: "Design as Sanctuary",
            body: "If a room can dictate how we breathe, so can a digital space. We must design for the exhale.",
            createdAt: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
            wordCount: 2105,
            isFavorite: false
        ),
        WriterDocument(
            title: "The Rhythm of a Day",
            body: "A day is not a container to be filled but a rhythm to be honored. It ascends, peaks, descends, and rests — like breath, like tides, like the arc of light across a room.",
            createdAt: Calendar.current.date(byAdding: .day, value: -21, to: .now)!,
            wordCount: 934,
            isFavorite: false
        ),
    ]
}
