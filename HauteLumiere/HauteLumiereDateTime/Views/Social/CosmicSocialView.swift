// CosmicSocialView.swift
// Haute Lumière Date & Time — Social Circle & Referral System
//
// Invite 5 friends in your first month.
// If they sign up, BOTH of you get a complimentary
// Year-Ahead Relationship PDF for your connection.
// Social media sharing, cosmic compatibility,
// and a beautiful referral experience.

import SwiftUI

struct CosmicSocialView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var inviteEmail = ""
    @State private var showInviteSent = false
    @State private var showShareSheet = false

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")
    private let bg = Color(hex: "050505")

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Invite header
                        inviteHeader

                        // Invite form
                        inviteForm

                        // Active invites
                        activeInvites

                        // Social sharing section
                        socialSharingSection

                        // Cosmic compatibility
                        compatibilitySection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your Circle")
                        .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                        .foregroundColor(ivory)
                }
            }
        }
    }

    // MARK: - Invite Header
    private var inviteHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(gold.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "gift.fill")
                    .font(.system(size: 32, weight: .ultraLight))
                    .foregroundColor(gold)
            }

            Text("Invite Friends, Get Gifts")
                .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                .foregroundColor(ivory)

            Text("Invite up to 5 friends this month.\nWhen they join, you BOTH receive a complimentary\nYear-Ahead Relationship Reading.")
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            // Invites remaining
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(i < cosmicEngine.invitesRemaining ? gold : gold.opacity(0.15))
                        .frame(width: 12, height: 12)
                }
                Text("\(cosmicEngine.invitesRemaining) invites remaining")
                    .font(.custom("Avenir Next", size: 12))
                    .foregroundColor(muted)
            }
        }
    }

    // MARK: - Invite Form
    private var inviteForm: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundColor(gold.opacity(0.6))
                TextField("Friend's email address", text: $inviteEmail)
                    .font(.custom("Avenir Next", size: 14))
                    .foregroundColor(ivory)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(gold.opacity(0.15), lineWidth: 0.5))

            Button(action: sendInvite) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Send Cosmic Invitation")
                        .font(.custom("Avenir Next", size: 14).weight(.medium))
                }
                .foregroundColor(bg)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(gold)
                .clipShape(RoundedRectangle(cornerRadius: 100))
            }
            .disabled(inviteEmail.isEmpty || cosmicEngine.invitesRemaining <= 0)
            .opacity(inviteEmail.isEmpty || cosmicEngine.invitesRemaining <= 0 ? 0.5 : 1.0)

            if showInviteSent {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(gold)
                    Text("Invitation sent! When they join, you'll both receive your relationship reading.")
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(gold)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Active Invites
    private var activeInvites: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !cosmicEngine.friendInvites.isEmpty {
                Text("Your Invitations")
                    .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                    .foregroundColor(ivory)

                ForEach(cosmicEngine.friendInvites) { invite in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(invite.status == .accepted ? gold.opacity(0.15) : Color.white.opacity(0.04))
                                .frame(width: 40, height: 40)
                            Image(systemName: invite.status == .accepted ? "checkmark" : "clock")
                                .foregroundColor(invite.status == .accepted ? gold : muted)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(invite.inviteeEmail)
                                .font(.custom("Avenir Next", size: 13))
                                .foregroundColor(ivory)
                            Text(invite.status == .accepted ? "Joined! Relationship reading unlocked 🎁" : "Pending")
                                .font(.custom("Avenir Next", size: 11))
                                .foregroundColor(invite.status == .accepted ? gold : muted)
                        }

                        Spacer()

                        if invite.status == .accepted && !invite.rewardClaimed {
                            Text("View")
                                .font(.custom("Avenir Next", size: 11).weight(.semibold))
                                .foregroundColor(bg)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(gold)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.02)))
                }
            }
        }
    }

    // MARK: - Social Sharing
    private var socialSharingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share Your Cosmic Identity")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            Text("Beautiful cards crafted from your chart — shareable on Instagram, Pinterest, and Facebook.")
                .font(.custom("Avenir Next", size: 12))
                .foregroundColor(muted)

            // Shareable card preview
            if let profile = cosmicEngine.profile {
                VStack(spacing: 12) {
                    Text(profile.astrology.sunSign.symbol)
                        .font(.system(size: 36))

                    Text("\(profile.astrology.sunSign.displayName) Sun · \(profile.astrology.moonSign.displayName) Moon · \(profile.astrology.risingSign.displayName) Rising")
                        .font(.custom("Cormorant Garamond", size: 16).weight(.medium))
                        .foregroundColor(ivory)

                    Text("Life Path \(profile.numerology.lifePathNumber) · \(profile.ayurveda.primaryDosha.rawValue) · \(profile.fiveElements.dominantElement.rawValue) Element")
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(muted)

                    HStack(spacing: 4) {
                        Image(systemName: "light.max")
                            .font(.system(size: 8, weight: .ultraLight))
                        Text("Haute Lumière Date & Time")
                            .font(.custom("Cormorant Garamond", size: 10))
                    }
                    .foregroundColor(gold.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.2), lineWidth: 1))
            }

            // Platform buttons
            HStack(spacing: 10) {
                socialButton("Instagram", icon: "camera.circle.fill")
                socialButton("Pinterest", icon: "pin.circle.fill")
                socialButton("Facebook", icon: "person.2.circle.fill")
            }
        }
    }

    // MARK: - Compatibility Section
    private var compatibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cosmic Compatibility")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            Text("When a friend joins, we automatically generate your compatibility reading across all five traditions. Sun sign synastry, numerological harmony, dosha compatibility, elemental balance, and enneagram dynamics.")
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(muted)
                .lineSpacing(3)

            VStack(spacing: 8) {
                compatibilityRow("Astrological Synastry", "How your charts interact")
                compatibilityRow("Numerological Harmony", "Your combined vibration")
                compatibilityRow("Dosha Compatibility", "Constitutional harmony")
                compatibilityRow("Elemental Balance", "What you bring to each other")
                compatibilityRow("Enneagram Dynamics", "Growth patterns together")
            }
        }
    }

    // MARK: - Helpers

    private func socialButton(_ name: String, icon: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(name)
                    .font(.custom("Avenir Next", size: 10))
            }
            .foregroundColor(muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.03)))
        }
    }

    private func compatibilityRow(_ title: String, _ detail: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "heart.circle.fill")
                .foregroundColor(gold.opacity(0.5))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.custom("Avenir Next", size: 13).weight(.semibold)).foregroundColor(ivory)
                Text(detail).font(.custom("Avenir Next", size: 11)).foregroundColor(muted)
            }
            Spacer()
        }
    }

    private func sendInvite() {
        let success = cosmicEngine.sendInvite(to: inviteEmail)
        if success {
            showInviteSent = true
            inviteEmail = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                showInviteSent = false
            }
        }
    }
}
