// SubscriptionView.swift
// Haute Lumière — Subscription Paywall

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTier: SubscriptionTier = .premium

    var body: some View {
        ZStack {
            // Luxurious dark background
            LinearGradient(
                colors: [Color(hex: "0A1C14"), Color(hex: "122E21"), Color(hex: "0D2118")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.xl) {
                    // Close
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.hlNightTextMuted)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.08)))
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Header
                    VStack(spacing: HLSpacing.md) {
                        Image(systemName: "light.max")
                            .font(.system(size: 40, weight: .ultraLight))
                            .foregroundColor(.hlGold)

                        Text("Haute Lumière")
                            .font(HLTypography.serifLight(20))
                            .foregroundColor(.hlGoldLight)

                        Text("Choose Your Path")
                            .font(HLTypography.serifMedium(32))
                            .foregroundColor(.white)

                        Text("Every journey begins with a single breath")
                            .font(HLTypography.body)
                            .foregroundColor(.hlNightTextMuted)
                    }

                    // Tier cards
                    VStack(spacing: HLSpacing.md) {
                        ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                            SubscriptionTierCard(
                                tier: tier,
                                isSelected: selectedTier == tier,
                                isCurrentPlan: subscriptionManager.currentTier == tier
                            ) {
                                selectedTier = tier
                            }
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Subscribe button
                    Button(action: {
                        Task { await subscriptionManager.purchase(tier: selectedTier) }
                        dismiss()
                    }) {
                        VStack(spacing: 4) {
                            Text("Begin \(selectedTier.rawValue)")
                                .font(HLTypography.sansMedium(16))
                            Text(selectedTier.displayPrice)
                                .font(HLTypography.caption)
                        }
                        .foregroundColor(.hlGreen900)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.hlGold, .hlGoldLight], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    // Restore
                    Button(action: {
                        Task { await subscriptionManager.restorePurchases() }
                    }) {
                        Text("Restore Purchases")
                            .font(HLTypography.bodySmall)
                            .foregroundColor(.hlNightTextMuted)
                    }

                    // Legal
                    VStack(spacing: 4) {
                        Text("Subscription auto-renews. Cancel anytime in Settings.")
                            .font(HLTypography.caption)
                        Text("Terms of Service · Privacy Policy")
                            .font(HLTypography.caption)
                    }
                    .foregroundColor(.hlNightTextMuted.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: HLSpacing.xxl)
                }
            }
        }
    }
}

// MARK: - Tier Card
struct SubscriptionTierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let isCurrentPlan: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: HLSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(tier.rawValue)
                                .font(HLTypography.sansSemibold(16))
                                .foregroundColor(.hlGoldLight)

                            if isCurrentPlan {
                                Text("Current")
                                    .font(HLTypography.caption)
                                    .foregroundColor(.hlGreen900)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.hlGold)
                                    .clipShape(Capsule())
                            }

                            if tier == .unlimited {
                                Text("Best Value")
                                    .font(HLTypography.caption)
                                    .foregroundColor(.hlGreen900)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.hlGold)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(tier.tagline)
                            .font(HLTypography.bodySmall)
                            .foregroundColor(.hlNightTextMuted)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(tier.displayPrice)
                            .font(HLTypography.sansSemibold(16))
                            .foregroundColor(.hlGoldLight)
                    }
                }

                // Features
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tier.features) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: feature.included ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12))
                                .foregroundColor(feature.included ? .hlGold : .hlNightTextMuted.opacity(0.3))

                            Text(feature.name)
                                .font(HLTypography.bodySmall)
                                .foregroundColor(feature.included ? .hlNightText : .hlNightTextMuted.opacity(0.4))
                        }
                    }
                }
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(isSelected ? Color.hlGold.opacity(0.08) : Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(isSelected ? Color.hlGold.opacity(0.6) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
    }
}
