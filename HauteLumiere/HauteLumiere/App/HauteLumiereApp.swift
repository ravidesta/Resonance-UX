// HauteLumiereApp.swift
// Haute Lumière — Premium Wellness & Coaching
// iOS · watchOS · visionOS · macOS

import SwiftUI

@main
struct HauteLumiereApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var coachEngine = CoachEngine()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var audioEngine = AudioEngine()
    @StateObject private var habitTracker = HabitTracker()
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
                    .preferredColorScheme(prefersDarkMode ? .dark : nil)
            } else {
                OnboardingFlowView()
                    .environmentObject(appState)
                    .environmentObject(coachEngine)
                    .environmentObject(subscriptionManager)
            }
        }
    }
}
