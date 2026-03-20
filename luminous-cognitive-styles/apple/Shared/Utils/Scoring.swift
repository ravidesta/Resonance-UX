// Scoring.swift
// Luminous Cognitive Styles™
// Profile type naming and interpretation utilities

import Foundation

struct ProfileTypeNamer {

    // Primary archetype based on most extreme dimension
    static func name(for profile: CognitiveProfile) -> String {
        let ordered = profile.orderedScores.sorted { abs($0.score - 5.5) > abs($1.score - 5.5) }
        guard let primary = ordered.first, let secondary = ordered.dropFirst().first else {
            return "The Explorer"
        }
        let p = archetypeWord(for: primary.dimension, score: primary.score)
        let s = archetypeWord(for: secondary.dimension, score: secondary.score)
        return "The \(p) \(s)"
    }

    static func summary(for profile: CognitiveProfile) -> String {
        let edges = profile.developmentalEdges
        guard let first = edges.first else { return "A balanced cognitive profile." }
        let score1 = profile.score(for: first)
        let pole1 = score1 > 5.5 ? first.highPole : first.lowPole

        if let second = edges.dropFirst().first {
            let score2 = profile.score(for: second)
            let pole2 = score2 > 5.5 ? second.highPole : second.lowPole
            return "Your profile is anchored in \(pole1) \(first.shortName) and \(pole2) \(second.shortName), giving you a distinctive approach to thinking and problem-solving."
        }
        return "Your profile is anchored in \(pole1) \(first.shortName), giving you a distinctive cognitive approach."
    }

    private static func archetypeWord(for dimension: CognitiveDimension, score: Double) -> String {
        let isHigh = score > 5.5
        switch dimension {
        case .perceptualMode:
            return isHigh ? "Visionary" : "Precision"
        case .processingRhythm:
            return isHigh ? "Quicksilver" : "Deliberate"
        case .generativeOrientation:
            return isHigh ? "Expansive" : "Focused"
        case .representationalChannel:
            return isHigh ? "Imaginal" : "Articulate"
        case .relationalOrientation:
            return isHigh ? "Collaborative" : "Independent"
        case .somaticIntegration:
            return isHigh ? "Embodied" : "Abstract"
        case .complexityTolerance:
            return isHigh ? "Emergent" : "Resolute"
        }
    }

    // Extended interpretation paragraph for a dimension score
    static func extendedInterpretation(dimension: CognitiveDimension, score: Double) -> String {
        let base = dimension.interpretation(for: score)
        let rounded = Int(score.rounded())
        let strength: String
        if rounded <= 2 || rounded >= 9 {
            strength = "This is a very strong orientation that significantly shapes your cognitive experience."
        } else if rounded <= 3 || rounded >= 8 {
            strength = "This is a clear preference that noticeably influences your approach."
        } else if rounded <= 4 || rounded >= 7 {
            strength = "This is a moderate tendency that you may adapt depending on the situation."
        } else {
            strength = "You sit near the center of this spectrum, suggesting high flexibility on this dimension."
        }
        return "\(base) \(strength)"
    }

    // Returns a coaching suggestion based on dimensional profile
    static func coachingSuggestion(for profile: CognitiveProfile) -> String {
        guard let edge = profile.developmentalEdges.first else {
            return "Your balanced profile suggests exploring any dimension that intrigues you."
        }
        let score = profile.score(for: edge)
        let targetPole = score > 5.5 ? edge.lowPole : edge.highPole
        return "Consider developing your \(targetPole.lowercased()) side on the \(edge.name) dimension. Small experiments outside your comfort zone can significantly expand your adaptive range."
    }
}

// MARK: - Score Formatting

struct ScoreFormatter {
    static func formatted(_ score: Double) -> String {
        String(format: "%.1f", score)
    }

    static func poleLabel(dimension: CognitiveDimension, score: Double) -> String {
        if score <= 3.5 {
            return dimension.lowPole
        } else if score >= 6.5 {
            return dimension.highPole
        } else {
            return "Balanced"
        }
    }

    static func percentPosition(_ score: Double) -> Double {
        (score - 1.0) / 9.0
    }
}
