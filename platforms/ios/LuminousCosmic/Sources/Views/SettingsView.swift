// SettingsView.swift
// Luminous Cosmic Architecture™
// Settings - Day/Night Mode, Profile Management

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Environment(\.resonanceTheme) var theme
    @State private var notificationsEnabled = true
    @State private var dailyReminders = true
    @State private var moonPhaseAlerts = true
    @State private var transitAlerts = false
    @State private var showResetAlert = false
    @State private var selectedAppearance: AppearanceMode = .system

    enum AppearanceMode: String, CaseIterable {
        case light = "Day"
        case dark = "Night"
        case system = "System"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackgroundMinimal()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: ResonanceSpacing.lg) {
                        headerSection

                        // Appearance section
                        appearanceSection

                        // Profile section
                        profileSection

                        // Notifications
                        notificationsSection

                        // About
                        aboutSection

                        // Reset
                        resetSection

                        Spacer(minLength: ResonanceSpacing.xxxl)
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .navigationBarHidden(true)
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    ResonanceHaptics.medium()
                }
            } message: {
                Text("This will erase your birth data, journal entries, and all settings. This action cannot be undone.")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
            Text("Settings")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)

            Text("Customize your cosmic experience")
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResonanceSpacing.xxl)
        .padding(.horizontal, ResonanceSpacing.xs)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Appearance")

            VStack(spacing: 0) {
                // Day/Night Toggle
                HStack {
                    Label("Theme", systemImage: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                        .font(ResonanceTypography.bodyMedium)
                        .foregroundColor(theme.textPrimary)

                    Spacer()

                    // Custom segment control
                    HStack(spacing: 0) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Button {
                                withAnimation(ResonanceAnimation.springSmooth) {
                                    selectedAppearance = mode
                                    switch mode {
                                    case .light: isDarkMode = false
                                    case .dark: isDarkMode = true
                                    case .system: isDarkMode = false // would use system setting
                                    }
                                }
                                ResonanceHaptics.selection()
                            } label: {
                                Text(mode.rawValue)
                                    .font(ResonanceTypography.bodySmall)
                                    .foregroundColor(
                                        selectedAppearance == mode
                                            ? theme.textPrimary
                                            : theme.textTertiary
                                    )
                                    .padding(.horizontal, ResonanceSpacing.sm)
                                    .padding(.vertical, ResonanceSpacing.xs)
                                    .background(
                                        selectedAppearance == mode
                                            ? Capsule().fill(theme.accent.opacity(0.15))
                                            : nil
                                    )
                            }
                        }
                    }
                    .background(
                        Capsule()
                            .fill(theme.surface.opacity(0.5))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(theme.border, lineWidth: 0.5)
                    )
                }
                .padding(ResonanceSpacing.md)

                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)

                // Theme preview
                themePreview
                    .padding(ResonanceSpacing.md)
            }
            .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        }
    }

    private var themePreview: some View {
        HStack(spacing: ResonanceSpacing.md) {
            // Day preview
            VStack(spacing: ResonanceSpacing.xs) {
                RoundedRectangle(cornerRadius: ResonanceRadius.sm)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "FAFAF8"), Color(hex: "F5F4EE")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 60)
                    .overlay(
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: "C5A059"))
                                .frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "5C7065"))
                                .frame(width: 30, height: 3)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceRadius.sm)
                            .strokeBorder(
                                !isDarkMode ? theme.accent : theme.border,
                                lineWidth: !isDarkMode ? 2 : 0.5
                            )
                    )

                Text("Day")
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Day theme preview")

            // Night preview
            VStack(spacing: ResonanceSpacing.xs) {
                RoundedRectangle(cornerRadius: ResonanceRadius.sm)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "05100B"), Color(hex: "0A1C14")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 60)
                    .overlay(
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color(hex: "C5A059"))
                                .frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "8A9C91"))
                                .frame(width: 30, height: 3)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceRadius.sm)
                            .strokeBorder(
                                isDarkMode ? theme.accent : theme.border,
                                lineWidth: isDarkMode ? 2 : 0.5
                            )
                    )

                Text("Night")
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Night theme preview")
        }
    }

    // MARK: - Profile

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Profile")

            VStack(spacing: 0) {
                settingsRow(icon: "person.circle", title: "Name", value: "Cosmic Traveler")
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsRow(icon: "calendar", title: "Birth Date", value: "June 15, 1990")
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsRow(icon: "clock", title: "Birth Time", value: "2:30 PM")
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsRow(icon: "mappin.circle", title: "Birth Place", value: "New York, NY")
            }
            .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Notifications")

            VStack(spacing: 0) {
                settingsToggle(
                    icon: "bell",
                    title: "Push Notifications",
                    isOn: $notificationsEnabled
                )
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsToggle(
                    icon: "sun.max",
                    title: "Daily Reflections",
                    isOn: $dailyReminders
                )
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsToggle(
                    icon: "moon",
                    title: "Moon Phase Alerts",
                    isOn: $moonPhaseAlerts
                )
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsToggle(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Major Transits",
                    isOn: $transitAlerts
                )
            }
            .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("About")

            VStack(spacing: 0) {
                settingsRow(icon: "info.circle", title: "Version", value: "1.0.0")
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsRow(icon: "book.closed", title: "Credits", value: "")
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsRow(icon: "lock.shield", title: "Privacy Policy", value: "")
                Divider().background(theme.border).padding(.horizontal, ResonanceSpacing.md)
                settingsRow(icon: "doc.text", title: "Terms of Use", value: "")
            }
            .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        }
    }

    // MARK: - Reset

    private var resetSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            Button {
                showResetAlert = true
                ResonanceHaptics.medium()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset All Data")
                }
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(ResonanceColors.fire)
                .frame(maxWidth: .infinity)
                .padding(ResonanceSpacing.md)
                .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle, showBorder: true)
            }

            Text("Luminous Cosmic Architecture\nBuilt with the Resonance UX Design System")
                .font(ResonanceTypography.caption)
                .foregroundColor(theme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, ResonanceSpacing.md)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(ResonanceTypography.overline)
            .foregroundColor(theme.accent)
            .textCase(.uppercase)
            .tracking(1.5)
            .padding(.horizontal, ResonanceSpacing.xs)
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textPrimary)

            Spacer()

            if !value.isEmpty {
                Text(value)
                    .font(ResonanceTypography.bodySmall)
                    .foregroundColor(theme.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(theme.textTertiary)
        }
        .padding(ResonanceSpacing.md)
        .contentShape(Rectangle())
    }

    private func settingsToggle(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textPrimary)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(ResonanceColors.goldPrimary)
        }
        .padding(ResonanceSpacing.md)
    }
}
