// HauteLumiereDateTimeApp.swift
// Haute Lumière Date & Time — Companion Cosmic Intelligence App
//
// A separate app that talks to the main Haute Lumière coaching app.
// Provides: Astrology, Numerology, Ayurveda, Five Elements, Enneagram
// Daily 5-page illustrated briefings, auspicious times, bespoke readings,
// monthly collectible book-sized reports, social sharing, friend referrals.
// Your meditations are synchronized with your stars, numbers, and doshas.

import SwiftUI

@main
struct HauteLumiereDateTimeApp: App {
    @StateObject private var cosmicEngine = CosmicEngine()
    @AppStorage("hasEnteredBirthData") private var hasEnteredBirthData = false

    var body: some Scene {
        WindowGroup {
            if hasEnteredBirthData {
                DateTimeMainView()
                    .environmentObject(cosmicEngine)
            } else {
                BirthDataEntryView()
                    .environmentObject(cosmicEngine)
            }
        }
    }
}
