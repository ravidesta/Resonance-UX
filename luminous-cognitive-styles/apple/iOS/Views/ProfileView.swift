// ProfileView.swift
// Luminous Cognitive Styles™ — iOS
// User profile, assessment history, settings

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var showClearAlert = false
    @State private var selectedHistoryProfile: CognitiveProfile?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LCSTheme.Spacing.xl) {
                    // Profile header
                    profileHeader

                    // Current Profile Summary
                    if let profile = viewModel.currentProfile {
                        currentProfileSection(profile)
                    }

                    // Assessment History
                    assessmentHistorySection

                    // Settings
                    settingsSection

                    // Clear data
                    Button(role: .destructive) {
                        showClearAlert = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                            .font(.subheadline)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .padding(.top, LCSTheme.Spacing.lg)

                    // Version
                    Text("Luminous Cognitive Styles v1.0.0")
                        .font(.caption2)
                        .foregroundColor(LCSTheme.textTertiary)
                        .padding(.bottom, LCSTheme.Spacing.xxl)

                    Spacer(minLength: 100)
                }
            }
            .background(LCSTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Clear All Data?", isPresented: $showClearAlert) {
                Button("Clear", role: .destructive) {
                    viewModel.clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all profiles, assessment data, and reading progress. This action cannot be undone.")
            }
            .sheet(item: $selectedHistoryProfile) { profile in
                NavigationStack {
                    CognitiveSignatureView(profile: profile)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { selectedHistoryProfile = nil }
                                    .foregroundColor(LCSTheme.goldAccent)
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button {
                                    viewModel.setCurrentProfile(profile)
                                    selectedHistoryProfile = nil
                                } label: {
                                    Text("Set as Current")
                                        .font(.caption)
                                        .foregroundColor(LCSTheme.goldAccent)
                                }
                            }
                        }
                }
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: LCSTheme.dimensionColors,
                            center: .center
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 8)

                Circle()
                    .fill(LCSTheme.darkSurface)
                    .frame(width: 72, height: 72)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32))
                    .foregroundStyle(LCSTheme.goldGradient)
            }

            if let profile = viewModel.currentProfile {
                Text(profile.profileTypeName)
                    .font(.title3.weight(.bold))
                    .foregroundColor(LCSTheme.textPrimary)
            } else {
                Text("No Profile Yet")
                    .font(.title3.weight(.bold))
                    .foregroundColor(LCSTheme.textSecondary)
            }

            HStack(spacing: LCSTheme.Spacing.xl) {
                StatView(value: "\(viewModel.profileHistory.count)", label: "Profiles")
                StatView(value: "\(Int(viewModel.totalBookProgress * 100))%", label: "Book Read")
                StatView(value: streakCount, label: "Day Streak")
            }
        }
        .padding(.top, LCSTheme.Spacing.xl)
    }

    private var streakCount: String {
        let checkIns = viewModel.profileHistory.filter { $0.assessmentType == .dailyCheckIn }
        return "\(min(checkIns.count, 7))"
    }

    // MARK: - Current Profile

    private func currentProfileSection(_ profile: CognitiveProfile) -> some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            HStack {
                Text("Current Profile")
                    .font(.headline)
                    .foregroundColor(LCSTheme.textPrimary)
                Spacer()
                Text(profile.assessmentType.rawValue)
                    .font(.caption)
                    .foregroundColor(LCSTheme.goldAccent)
            }

            CompactRadarChartView(profile: profile, size: 120)
                .frame(maxWidth: .infinity)

            ForEach(CognitiveDimension.allCases) { dim in
                CompactDimensionScoreView(dimension: dim, score: profile.score(for: dim))
            }

            Text("Assessed \(profile.createdAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundColor(LCSTheme.textTertiary)
        }
        .lcsCard()
        .padding(.horizontal)
    }

    // MARK: - Assessment History

    private var assessmentHistorySection: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            HStack {
                Text("Assessment History")
                    .font(.headline)
                    .foregroundColor(LCSTheme.textPrimary)
                Spacer()
                Text("\(viewModel.profileHistory.count) total")
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
            }

            if viewModel.profileHistory.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: LCSTheme.Spacing.sm) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.title)
                            .foregroundColor(LCSTheme.textTertiary)
                        Text("No assessments yet")
                            .font(.subheadline)
                            .foregroundColor(LCSTheme.textTertiary)
                    }
                    .padding(.vertical, LCSTheme.Spacing.xl)
                    Spacer()
                }
            } else {
                ForEach(viewModel.profileHistory.prefix(10)) { profile in
                    Button {
                        selectedHistoryProfile = profile
                    } label: {
                        HistoryRow(profile: profile, isCurrent: profile.id == viewModel.currentProfile?.id)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteProfile(profile)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .lcsCard()
        .padding(.horizontal)
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)

            SettingsRow(icon: "bell", title: "Notifications", subtitle: "Daily reminders & insights") {
                Toggle("", isOn: .constant(true))
                    .tint(LCSTheme.goldAccent)
            }

            SettingsRow(icon: "lock.shield", title: "Privacy", subtitle: "Data stays on your device") {
                Image(systemName: "chevron.right")
                    .foregroundColor(LCSTheme.textTertiary)
            }

            SettingsRow(icon: "questionmark.circle", title: "Help & FAQ", subtitle: "Learn about cognitive styles") {
                Image(systemName: "chevron.right")
                    .foregroundColor(LCSTheme.textTertiary)
            }

            SettingsRow(icon: "star", title: "Rate the App", subtitle: "Share your experience") {
                Image(systemName: "chevron.right")
                    .foregroundColor(LCSTheme.textTertiary)
            }
        }
        .lcsCard()
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct StatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
                .foregroundColor(LCSTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundColor(LCSTheme.textTertiary)
        }
    }
}

struct HistoryRow: View {
    let profile: CognitiveProfile
    let isCurrent: Bool

    var body: some View {
        HStack(spacing: LCSTheme.Spacing.md) {
            CompactRadarChartView(profile: profile, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(profile.profileTypeName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(LCSTheme.textPrimary)

                    if isCurrent {
                        Text("CURRENT")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(LCSTheme.deepNavy)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(LCSTheme.goldAccent))
                    }
                }

                Text("\(profile.assessmentType.rawValue) · \(profile.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(LCSTheme.textTertiary)
        }
        .padding(.vertical, LCSTheme.Spacing.xs)
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: LCSTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(LCSTheme.goldAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(LCSTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
            }

            Spacer()

            trailing()
        }
        .padding(.vertical, LCSTheme.Spacing.xs)
    }
}
