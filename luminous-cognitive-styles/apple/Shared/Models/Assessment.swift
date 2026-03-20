// Assessment.swift
// Luminous Cognitive Styles™
// Assessment questions and scoring logic

import Foundation

// MARK: - Assessment Question

struct AssessmentQuestion: Identifiable, Codable {
    let id: Int
    let dimension: CognitiveDimension
    let text: String
    let reversed: Bool

    var answer: Int? = nil

    func scoredValue(rawAnswer: Int) -> Double {
        // rawAnswer is 1-7 Likert scale
        // Reversed items: flip the score
        let value = reversed ? (8 - rawAnswer) : rawAnswer
        // Map 1-7 to 1-10 scale
        return 1.0 + (Double(value - 1) / 6.0) * 9.0
    }
}

// MARK: - Quick Profile Item

struct QuickProfileItem: Identifiable {
    let id: Int
    let dimension: CognitiveDimension
    var score: Double

    init(dimension: CognitiveDimension, score: Double = 5.0) {
        self.id = dimension.rawValue
        self.dimension = dimension
        self.score = score
    }
}

// MARK: - DSR Questions (Dimensional Style Report)
// 35 questions: 5 per dimension

struct DSRQuestionBank {
    static let questions: [AssessmentQuestion] = [
        // Perceptual Mode (Analytic ↔ Holistic)
        AssessmentQuestion(id: 1, dimension: .perceptualMode, text: "When encountering a new problem, I prefer to break it into smaller parts before attempting a solution.", reversed: true),
        AssessmentQuestion(id: 2, dimension: .perceptualMode, text: "I often notice the overall pattern or gestalt of a situation before I attend to specific details.", reversed: false),
        AssessmentQuestion(id: 3, dimension: .perceptualMode, text: "I naturally organize information into categories and hierarchies.", reversed: true),
        AssessmentQuestion(id: 4, dimension: .perceptualMode, text: "When reading, I tend to grasp the main theme before focusing on supporting evidence.", reversed: false),
        AssessmentQuestion(id: 5, dimension: .perceptualMode, text: "I prefer step-by-step instructions over general guidelines.", reversed: true),

        // Processing Rhythm (Deliberative ↔ Spontaneous)
        AssessmentQuestion(id: 6, dimension: .processingRhythm, text: "I like to carefully consider all options before making a decision.", reversed: true),
        AssessmentQuestion(id: 7, dimension: .processingRhythm, text: "My best ideas come to me in sudden flashes of insight rather than through careful reasoning.", reversed: false),
        AssessmentQuestion(id: 8, dimension: .processingRhythm, text: "I prefer to have a clear plan before starting a project.", reversed: true),
        AssessmentQuestion(id: 9, dimension: .processingRhythm, text: "I trust my gut reactions and first impressions.", reversed: false),
        AssessmentQuestion(id: 10, dimension: .processingRhythm, text: "I enjoy thinking on my feet and responding to situations as they unfold.", reversed: false),

        // Generative Orientation (Convergent ↔ Divergent)
        AssessmentQuestion(id: 11, dimension: .generativeOrientation, text: "When brainstorming, I prefer to quickly narrow down to the most promising idea.", reversed: true),
        AssessmentQuestion(id: 12, dimension: .generativeOrientation, text: "I enjoy generating many possible solutions even if most won't be used.", reversed: false),
        AssessmentQuestion(id: 13, dimension: .generativeOrientation, text: "I find it satisfying to identify the single best answer to a question.", reversed: true),
        AssessmentQuestion(id: 14, dimension: .generativeOrientation, text: "I often make unexpected connections between seemingly unrelated ideas.", reversed: false),
        AssessmentQuestion(id: 15, dimension: .generativeOrientation, text: "I am energized by exploring tangential ideas even when working toward a specific goal.", reversed: false),

        // Representational Channel (Verbal-Symbolic ↔ Imagistic-Spatial)
        AssessmentQuestion(id: 16, dimension: .representationalChannel, text: "I think most clearly in words and verbal propositions.", reversed: true),
        AssessmentQuestion(id: 17, dimension: .representationalChannel, text: "When solving problems, I often create mental images or spatial models.", reversed: false),
        AssessmentQuestion(id: 18, dimension: .representationalChannel, text: "I prefer reading text over looking at diagrams or charts.", reversed: true),
        AssessmentQuestion(id: 19, dimension: .representationalChannel, text: "I can easily rotate objects in my mind and think about spatial relationships.", reversed: false),
        AssessmentQuestion(id: 20, dimension: .representationalChannel, text: "My internal experience is rich with visual imagery, colors, and spatial sensations.", reversed: false),

        // Relational Orientation (Autonomous ↔ Connected)
        AssessmentQuestion(id: 21, dimension: .relationalOrientation, text: "I do my best thinking alone, without input from others.", reversed: true),
        AssessmentQuestion(id: 22, dimension: .relationalOrientation, text: "Discussing ideas with others helps me clarify and develop my thinking.", reversed: false),
        AssessmentQuestion(id: 23, dimension: .relationalOrientation, text: "I prefer to work through problems independently before sharing my conclusions.", reversed: true),
        AssessmentQuestion(id: 24, dimension: .relationalOrientation, text: "I find that collaborative brainstorming produces better ideas than solo thinking.", reversed: false),
        AssessmentQuestion(id: 25, dimension: .relationalOrientation, text: "I feel more creative and engaged when working with a team.", reversed: false),

        // Somatic Integration (Cerebral ↔ Embodied)
        AssessmentQuestion(id: 26, dimension: .somaticIntegration, text: "I can think effectively regardless of my physical state or environment.", reversed: true),
        AssessmentQuestion(id: 27, dimension: .somaticIntegration, text: "Physical movement helps me think more clearly.", reversed: false),
        AssessmentQuestion(id: 28, dimension: .somaticIntegration, text: "I rarely notice physical sensations when I'm deep in thought.", reversed: true),
        AssessmentQuestion(id: 29, dimension: .somaticIntegration, text: "I often know something through a bodily feeling before I can articulate it in words.", reversed: false),
        AssessmentQuestion(id: 30, dimension: .somaticIntegration, text: "My physical environment and bodily comfort significantly affect the quality of my thinking.", reversed: false),

        // Complexity Tolerance (Closure-Seeking ↔ Ambiguity-Embracing)
        AssessmentQuestion(id: 31, dimension: .complexityTolerance, text: "I feel uncomfortable when a question doesn't have a clear answer.", reversed: true),
        AssessmentQuestion(id: 32, dimension: .complexityTolerance, text: "I enjoy sitting with paradoxes and contradictions rather than rushing to resolve them.", reversed: false),
        AssessmentQuestion(id: 33, dimension: .complexityTolerance, text: "I prefer projects with clear goals and defined endpoints.", reversed: true),
        AssessmentQuestion(id: 34, dimension: .complexityTolerance, text: "I find open-ended explorations more engaging than structured tasks.", reversed: false),
        AssessmentQuestion(id: 35, dimension: .complexityTolerance, text: "I am comfortable holding multiple contradictory ideas in mind simultaneously.", reversed: false),
    ]

    static func questions(for dimension: CognitiveDimension) -> [AssessmentQuestion] {
        questions.filter { $0.dimension == dimension }
    }

    static var dimensionGroups: [(dimension: CognitiveDimension, questions: [AssessmentQuestion])] {
        CognitiveDimension.allCases.map { dim in
            (dimension: dim, questions: questions(for: dim))
        }
    }
}

// MARK: - Scoring

struct DSRScorer {
    static func score(answers: [Int: Int]) -> [CognitiveDimension: Double] {
        var dimensionScores: [CognitiveDimension: [Double]] = [:]

        for question in DSRQuestionBank.questions {
            guard let rawAnswer = answers[question.id] else { continue }
            let scored = question.scoredValue(rawAnswer: rawAnswer)
            dimensionScores[question.dimension, default: []].append(scored)
        }

        var result: [CognitiveDimension: Double] = [:]
        for (dimension, scores) in dimensionScores {
            guard !scores.isEmpty else { continue }
            let average = scores.reduce(0, +) / Double(scores.count)
            result[dimension] = min(10.0, max(1.0, average))
        }

        return result
    }
}

// MARK: - Daily Check-In Questions

struct DailyCheckInBank {
    static let questions: [(dimension: CognitiveDimension, text: String)] = [
        (.perceptualMode, "Today I've been noticing details vs. big-picture patterns"),
        (.processingRhythm, "Today I've been thinking carefully vs. going with my gut"),
        (.generativeOrientation, "Today I've been narrowing down vs. exploring widely"),
        (.representationalChannel, "Today I've been thinking in words vs. images"),
        (.relationalOrientation, "Today I've been working alone vs. collaborating"),
        (.somaticIntegration, "Today I've been in my head vs. in my body"),
        (.complexityTolerance, "Today I've been seeking clarity vs. embracing complexity"),
    ]
}
