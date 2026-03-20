// CognitiveDimension.swift
// Luminous Cognitive Styles™
// Shared model defining all 7 cognitive dimensions and profile structures

import SwiftUI

// MARK: - Cognitive Dimension

enum CognitiveDimension: Int, CaseIterable, Identifiable, Codable {
    case perceptualMode = 0
    case processingRhythm
    case generativeOrientation
    case representationalChannel
    case relationalOrientation
    case somaticIntegration
    case complexityTolerance

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .perceptualMode: return "Perceptual Mode"
        case .processingRhythm: return "Processing Rhythm"
        case .generativeOrientation: return "Generative Orientation"
        case .representationalChannel: return "Representational Channel"
        case .relationalOrientation: return "Relational Orientation"
        case .somaticIntegration: return "Somatic Integration"
        case .complexityTolerance: return "Complexity Tolerance"
        }
    }

    var shortName: String {
        switch self {
        case .perceptualMode: return "Perceptual"
        case .processingRhythm: return "Processing"
        case .generativeOrientation: return "Generative"
        case .representationalChannel: return "Channel"
        case .relationalOrientation: return "Relational"
        case .somaticIntegration: return "Somatic"
        case .complexityTolerance: return "Complexity"
        }
    }

    var abbreviation: String {
        switch self {
        case .perceptualMode: return "PM"
        case .processingRhythm: return "PR"
        case .generativeOrientation: return "GO"
        case .representationalChannel: return "RC"
        case .relationalOrientation: return "RO"
        case .somaticIntegration: return "SI"
        case .complexityTolerance: return "CT"
        }
    }

    var lowPole: String {
        switch self {
        case .perceptualMode: return "Analytic"
        case .processingRhythm: return "Deliberative"
        case .generativeOrientation: return "Convergent"
        case .representationalChannel: return "Verbal-Symbolic"
        case .relationalOrientation: return "Autonomous"
        case .somaticIntegration: return "Cerebral"
        case .complexityTolerance: return "Closure-Seeking"
        }
    }

    var highPole: String {
        switch self {
        case .perceptualMode: return "Holistic"
        case .processingRhythm: return "Spontaneous"
        case .generativeOrientation: return "Divergent"
        case .representationalChannel: return "Imagistic-Spatial"
        case .relationalOrientation: return "Connected"
        case .somaticIntegration: return "Embodied"
        case .complexityTolerance: return "Ambiguity-Embracing"
        }
    }

    var color: Color {
        Color(hex: colorHex)
    }

    var colorHex: String {
        switch self {
        case .perceptualMode: return "#4FC3F7"
        case .processingRhythm: return "#FFB74D"
        case .generativeOrientation: return "#66BB6A"
        case .representationalChannel: return "#AB47BC"
        case .relationalOrientation: return "#EF5350"
        case .somaticIntegration: return "#26A69A"
        case .complexityTolerance: return "#5C6BC0"
        }
    }

    var description: String {
        switch self {
        case .perceptualMode:
            return "How you naturally take in and organize information. Analytic thinkers break things into parts and examine details sequentially. Holistic thinkers grasp patterns and see the big picture first."
        case .processingRhythm:
            return "Your natural pace of cognitive engagement. Deliberative processors prefer careful, step-by-step reasoning. Spontaneous processors trust quick intuitions and rapid pattern recognition."
        case .generativeOrientation:
            return "How you generate ideas and solutions. Convergent thinkers narrow toward the single best answer. Divergent thinkers expand outward, generating many possibilities and novel combinations."
        case .representationalChannel:
            return "Your preferred internal representation system. Verbal-symbolic thinkers work primarily with words, numbers, and abstract symbols. Imagistic-spatial thinkers work with mental images, spatial relationships, and sensory impressions."
        case .relationalOrientation:
            return "How you naturally relate thinking to social context. Autonomous thinkers prefer independent reasoning and may find collaboration distracting. Connected thinkers draw energy from dialogue and co-creation."
        case .somaticIntegration:
            return "The degree to which bodily awareness informs your cognition. Cerebral thinkers operate primarily in abstract mental space. Embodied thinkers integrate physical sensations, movement, and body-based knowing."
        case .complexityTolerance:
            return "Your relationship with ambiguity and uncertainty. Closure-seeking thinkers prefer clear answers and resolved tensions. Ambiguity-embracing thinkers are comfortable holding multiple possibilities open."
        }
    }

    var icon: String {
        switch self {
        case .perceptualMode: return "eye.trianglebadge.exclamationmark"
        case .processingRhythm: return "metronome"
        case .generativeOrientation: return "arrow.triangle.branch"
        case .representationalChannel: return "brain.head.profile"
        case .relationalOrientation: return "person.2"
        case .somaticIntegration: return "figure.mind.and.body"
        case .complexityTolerance: return "square.stack.3d.up"
        }
    }

    func interpretation(for score: Double) -> String {
        let rounded = Int(score.rounded())
        switch self {
        case .perceptualMode:
            if rounded <= 3 { return "You naturally dissect information into components, preferring sequential analysis and logical categorization." }
            if rounded <= 7 { return "You fluidly shift between detail-focused analysis and big-picture pattern recognition depending on context." }
            return "You instinctively grasp whole patterns and relationships, seeing the forest before the trees."

        case .processingRhythm:
            if rounded <= 3 { return "You prefer methodical, step-by-step reasoning, taking time to weigh evidence before reaching conclusions." }
            if rounded <= 7 { return "You can engage both careful deliberation and rapid intuitive leaps, choosing the mode that fits the situation." }
            return "You trust rapid intuitive judgments and thrive in fast-paced environments requiring quick cognitive pivots."

        case .generativeOrientation:
            if rounded <= 3 { return "You excel at narrowing possibilities to find the optimal solution, applying rigorous criteria to evaluate options." }
            if rounded <= 7 { return "You balance between focused solution-finding and expansive brainstorming, adapting your approach to the problem type." }
            return "You naturally generate abundant ideas, making unexpected connections and exploring unconventional possibilities."

        case .representationalChannel:
            if rounded <= 3 { return "Your thinking operates primarily through language, logic, and symbolic systems. Words and numbers are your native medium." }
            if rounded <= 7 { return "You comfortably work with both verbal-symbolic and visual-spatial representations, translating between them as needed." }
            return "You think primarily in images, spatial relationships, and sensory impressions, often finding words inadequate for your ideas."

        case .relationalOrientation:
            if rounded <= 3 { return "You do your deepest thinking independently, finding solitary reflection essential for genuine insight." }
            if rounded <= 7 { return "You value both independent reflection and collaborative dialogue, knowing when each serves you best." }
            return "You think most powerfully in relationship, finding that dialogue and co-creation amplify your cognitive capabilities."

        case .somaticIntegration:
            if rounded <= 3 { return "Your cognitive life unfolds primarily in abstract mental space, with physical sensation playing a minimal role." }
            if rounded <= 7 { return "You integrate both abstract reasoning and body-based awareness, using physical cues as one input among many." }
            return "Your body is a primary instrument of knowing. Physical sensation, movement, and gut feelings are essential cognitive tools."

        case .complexityTolerance:
            if rounded <= 3 { return "You prefer clear resolution and definitive answers, experiencing genuine discomfort with prolonged uncertainty." }
            if rounded <= 7 { return "You can tolerate ambiguity when necessary but also appreciate the satisfaction of clear resolution." }
            return "You thrive in ambiguity, finding that holding multiple possibilities open leads to richer understanding and more creative outcomes."
        }
    }
}

// MARK: - Cognitive Profile

struct CognitiveProfile: Codable, Identifiable {
    let id: UUID
    var scores: [CognitiveDimension: Double]
    var createdAt: Date
    var assessmentType: AssessmentType
    var notes: String

    enum AssessmentType: String, Codable {
        case quickProfile = "Quick Profile"
        case fullDSR = "Full DSR Assessment"
        case dailyCheckIn = "Daily Check-In"
    }

    init(
        id: UUID = UUID(),
        scores: [CognitiveDimension: Double] = [:],
        createdAt: Date = Date(),
        assessmentType: AssessmentType = .quickProfile,
        notes: String = ""
    ) {
        self.id = id
        self.scores = scores
        self.createdAt = createdAt
        self.assessmentType = assessmentType
        self.notes = notes
    }

    // Ordered scores array for chart rendering
    var orderedScores: [(dimension: CognitiveDimension, score: Double)] {
        CognitiveDimension.allCases.map { dim in
            (dimension: dim, score: scores[dim] ?? 5.0)
        }
    }

    func score(for dimension: CognitiveDimension) -> Double {
        scores[dimension] ?? 5.0
    }

    // Home Territory: scores within 1 point of the assessed value
    func homeTerritory(for dimension: CognitiveDimension) -> ClosedRange<Double> {
        let s = score(for: dimension)
        return max(1.0, s - 1.0)...min(10.0, s + 1.0)
    }

    // Adaptive Range: scores within 2.5 points of the assessed value
    func adaptiveRange(for dimension: CognitiveDimension) -> ClosedRange<Double> {
        let s = score(for: dimension)
        return max(1.0, s - 2.5)...min(10.0, s + 2.5)
    }

    // Developmental Edge: areas farthest from center (most extreme scores)
    var developmentalEdges: [CognitiveDimension] {
        let sorted = orderedScores.sorted { abs($0.score - 5.5) > abs($1.score - 5.5) }
        return Array(sorted.prefix(2).map { $0.dimension })
    }

    // Profile type name based on top dimensions
    var profileTypeName: String {
        ProfileTypeNamer.name(for: self)
    }

    var profileSummary: String {
        ProfileTypeNamer.summary(for: self)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
