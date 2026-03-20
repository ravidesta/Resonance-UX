// AssessmentViewModel.swift
// Luminous Cognitive Styles™
// Observable state management for assessments and profile data

import SwiftUI
import Combine

@MainActor
class AssessmentViewModel: ObservableObject {

    // MARK: - Published State

    @Published var quickProfileItems: [QuickProfileItem]
    @Published var dsrAnswers: [Int: Int] = [:]   // questionId -> answer (1-7)
    @Published var currentQuestionIndex: Int = 0
    @Published var currentProfile: CognitiveProfile?
    @Published var profileHistory: [CognitiveProfile] = []
    @Published var isAssessmentInProgress: Bool = false
    @Published var bookProgress: [Int: Double] = [:]  // chapterId -> progress
    @Published var isDarkMode: Bool = true
    @Published var dailyCheckInScores: [CognitiveDimension: Double] = [:]

    // MARK: - Computed

    var dsrQuestions: [AssessmentQuestion] { DSRQuestionBank.questions }

    var dsrProgress: Double {
        guard !dsrQuestions.isEmpty else { return 0 }
        return Double(dsrAnswers.count) / Double(dsrQuestions.count)
    }

    var currentDSRQuestion: AssessmentQuestion? {
        guard currentQuestionIndex >= 0 && currentQuestionIndex < dsrQuestions.count else { return nil }
        return dsrQuestions[currentQuestionIndex]
    }

    var currentDSRDimension: CognitiveDimension? {
        currentDSRQuestion?.dimension
    }

    var currentDSRSectionIndex: Int {
        guard let dim = currentDSRDimension else { return 0 }
        return dim.rawValue
    }

    var isDSRComplete: Bool {
        dsrAnswers.count == dsrQuestions.count
    }

    var hasExistingProfile: Bool {
        currentProfile != nil
    }

    var totalBookProgress: Double {
        let chapters = BookChapter.chapters
        guard !chapters.isEmpty else { return 0 }
        let total = chapters.reduce(0.0) { $0 + (bookProgress[$1.id] ?? 0) }
        return total / Double(chapters.count)
    }

    // MARK: - Init

    init() {
        self.quickProfileItems = CognitiveDimension.allCases.map { QuickProfileItem(dimension: $0) }
        loadFromStorage()
    }

    // MARK: - Quick Profile

    func updateQuickProfileScore(dimension: CognitiveDimension, score: Double) {
        if let index = quickProfileItems.firstIndex(where: { $0.dimension == dimension }) {
            quickProfileItems[index].score = score
        }
    }

    func generateQuickProfile() -> CognitiveProfile {
        var scores: [CognitiveDimension: Double] = [:]
        for item in quickProfileItems {
            scores[item.dimension] = item.score
        }
        let profile = CognitiveProfile(
            scores: scores,
            assessmentType: .quickProfile
        )
        self.currentProfile = profile
        self.profileHistory.insert(profile, at: 0)
        saveToStorage()
        return profile
    }

    func resetQuickProfile() {
        quickProfileItems = CognitiveDimension.allCases.map { QuickProfileItem(dimension: $0) }
    }

    // MARK: - DSR Assessment

    func startDSR() {
        dsrAnswers = [:]
        currentQuestionIndex = 0
        isAssessmentInProgress = true
    }

    func answerDSRQuestion(questionId: Int, answer: Int) {
        dsrAnswers[questionId] = answer
    }

    func nextQuestion() {
        if currentQuestionIndex < dsrQuestions.count - 1 {
            currentQuestionIndex += 1
        }
    }

    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }

    func goToQuestion(_ index: Int) {
        guard index >= 0 && index < dsrQuestions.count else { return }
        currentQuestionIndex = index
    }

    func completeDSR() -> CognitiveProfile {
        let scores = DSRScorer.score(answers: dsrAnswers)
        let profile = CognitiveProfile(
            scores: scores,
            assessmentType: .fullDSR
        )
        self.currentProfile = profile
        self.profileHistory.insert(profile, at: 0)
        self.isAssessmentInProgress = false
        saveToStorage()
        return profile
    }

    func saveDSRProgress() {
        saveToStorage()
    }

    // MARK: - Daily Check-In

    func completeDailyCheckIn() -> CognitiveProfile {
        let profile = CognitiveProfile(
            scores: dailyCheckInScores,
            assessmentType: .dailyCheckIn
        )
        self.profileHistory.insert(profile, at: 0)
        self.dailyCheckInScores = [:]
        saveToStorage()
        return profile
    }

    func updateDailyScore(dimension: CognitiveDimension, score: Double) {
        dailyCheckInScores[dimension] = score
    }

    // MARK: - Book Progress

    func updateBookProgress(chapterId: Int, progress: Double) {
        bookProgress[chapterId] = min(1.0, max(0.0, progress))
        saveToStorage()
    }

    // MARK: - Profile Management

    func deleteProfile(_ profile: CognitiveProfile) {
        profileHistory.removeAll { $0.id == profile.id }
        if currentProfile?.id == profile.id {
            currentProfile = profileHistory.first
        }
        saveToStorage()
    }

    func setCurrentProfile(_ profile: CognitiveProfile) {
        currentProfile = profile
        saveToStorage()
    }

    // MARK: - Persistence

    private let profileKey = "lcs_current_profile"
    private let historyKey = "lcs_profile_history"
    private let dsrKey = "lcs_dsr_progress"
    private let dsrIndexKey = "lcs_dsr_index"
    private let bookKey = "lcs_book_progress"

    func saveToStorage() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(currentProfile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
        if let data = try? encoder.encode(profileHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
        if let data = try? encoder.encode(dsrAnswers) {
            UserDefaults.standard.set(data, forKey: dsrKey)
        }
        UserDefaults.standard.set(currentQuestionIndex, forKey: dsrIndexKey)
        if let data = try? encoder.encode(bookProgress) {
            UserDefaults.standard.set(data, forKey: bookKey)
        }
    }

    func loadFromStorage() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? decoder.decode(CognitiveProfile.self, from: data) {
            self.currentProfile = profile
        }
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let history = try? decoder.decode([CognitiveProfile].self, from: data) {
            self.profileHistory = history
        }
        if let data = UserDefaults.standard.data(forKey: dsrKey),
           let answers = try? decoder.decode([Int: Int].self, from: data) {
            self.dsrAnswers = answers
            if !answers.isEmpty { isAssessmentInProgress = true }
        }
        self.currentQuestionIndex = UserDefaults.standard.integer(forKey: dsrIndexKey)
        if let data = UserDefaults.standard.data(forKey: bookKey),
           let progress = try? decoder.decode([Int: Double].self, from: data) {
            self.bookProgress = progress
        }
    }

    func clearAllData() {
        currentProfile = nil
        profileHistory = []
        dsrAnswers = [:]
        currentQuestionIndex = 0
        isAssessmentInProgress = false
        bookProgress = [:]
        dailyCheckInScores = [:]
        resetQuickProfile()
        let keys = [profileKey, historyKey, dsrKey, dsrIndexKey, bookKey]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }
}
