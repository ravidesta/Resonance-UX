// HauteLumiereApp.swift
// Haute Lumière — Premium Wellness & Coaching
// iOS · watchOS · visionOS · macOS
//
// A status symbol disguised as a wellness app.
// Three swappable font pairings. Three color palettes.
// Dark luxurious diary. Branded social studio.
// Profound questions, not affirmations. Vetted quotes on your watch.
// Living Systems Theory embedded invisibly.
// Secret Agent for Team Life Force running behind every interaction.

import SwiftUI

@main
struct HauteLumiereApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var coachEngine = CoachEngine()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var audioEngine = AudioEngine()
    @StateObject private var habitTracker = HabitTracker()
    @StateObject private var questionEngine = ProfoundQuestionEngine()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("prefersDarkMode") private var prefersDarkMode = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(coachEngine)
                    .environmentObject(subscriptionManager)
                    .environmentObject(audioEngine)
                    .environmentObject(habitTracker)
                    .environmentObject(questionEngine)
                    .preferredColorScheme(prefersDarkMode ? .dark : nil)
                    .onAppear {
                        // Sync font pairing to typography system
                        HLTypography.currentPairing = appState.selectedFontPairing
                    }
            } else {
                OnboardingFlowView()
                    .environmentObject(appState)
                    .environmentObject(coachEngine)
                    .environmentObject(subscriptionManager)
            }
        }
    }
}
