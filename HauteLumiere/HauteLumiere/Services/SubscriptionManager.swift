// SubscriptionManager.swift
// Haute Lumière — Subscription & In-App Purchase Management

import SwiftUI
import StoreKit
import Combine

/// Manages subscription tiers, paywall logic, and StoreKit integration
final class SubscriptionManager: ObservableObject {
    // MARK: - Published State
    @Published var currentTier: SubscriptionTier = .meditation
    @Published var isSubscribed: Bool = false
    @Published var hasCoachingAddon: Bool = false
    @Published var trialDaysRemaining: Int = 7
    @Published var isInTrial: Bool = true
    @Published var showPaywall: Bool = false

    // MARK: - Product IDs
    static let productIDs: Set<String> = [
        "com.hautelumiere.essential.monthly",    // $50/mo
        "com.hautelumiere.premium.monthly",      // $99/mo
        "com.hautelumiere.coaching.monthly",     // $99/mo add-on
        "com.hautelumiere.unlimited.annual",     // $999/yr
    ]

    // MARK: - Access Control
    func hasAccess(to feature: Feature) -> Bool {
        if isInTrial { return true } // Full access during trial
        switch feature {
        case .basicMeditation, .basicBreathing, .basicYogaNidra, .natureSounds, .habitTracker, .nightMode, .dailyCoachCheckin:
            return isSubscribed
        case .fullYogaNidraLibrary, .advancedBreathing, .generativeVisualizations, .fullSoundscapeLibrary, .binauralBeats, .weeklyReports, .bespokeArticles, .appleWatch, .visionPro:
            return currentTier == .premium || currentTier == .coaching || currentTier == .unlimited
        case .liveCoaching, .executiveCoaching, .priorityAccess:
            return currentTier == .coaching || currentTier == .unlimited
        case .unlimitedCoaching, .exclusiveContent, .annualReview:
            return currentTier == .unlimited
        }
    }

    enum Feature {
        // Essential ($50/mo)
        case basicMeditation, basicBreathing, basicYogaNidra, natureSounds
        case habitTracker, nightMode, dailyCoachCheckin
        // Premium ($99/mo)
        case fullYogaNidraLibrary, advancedBreathing, generativeVisualizations
        case fullSoundscapeLibrary, binauralBeats, weeklyReports
        case bespokeArticles, appleWatch, visionPro
        // Coaching (+$99/mo)
        case liveCoaching, executiveCoaching, priorityAccess
        // Unlimited ($999/yr)
        case unlimitedCoaching, exclusiveContent, annualReview
    }

    // MARK: - StoreKit
    func purchase(tier: SubscriptionTier) async {
        // In production: StoreKit 2 purchase flow
        currentTier = tier
        isSubscribed = true
        isInTrial = false
        showPaywall = false
    }

    func restorePurchases() async {
        // In production: StoreKit 2 restore
    }

    // MARK: - Trial
    func startTrial() {
        isInTrial = true
        trialDaysRemaining = 7
    }

    func checkTrialStatus() {
        if trialDaysRemaining <= 0 {
            isInTrial = false
            if !isSubscribed {
                showPaywall = true
            }
        }
    }
}
