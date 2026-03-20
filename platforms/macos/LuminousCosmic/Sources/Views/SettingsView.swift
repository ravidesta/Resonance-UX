// SettingsView.swift
// Luminous Cosmic Architecture™ — macOS Settings
// Native macOS-style settings with Form layout

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var birthDate: Date = Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15, hour: 14, minute: 30)) ?? Date()
    @State private var birthLocation: String = "Portland, OR"
    @State private var houseSystem: HouseSystem = .placidus
    @State private var zodiacSystem: ZodiacSystem = .tropical
    @State private var showMinorAspects: Bool = false
    @State private var showAsteroids: Bool = false
    @State private var dailyNotifications: Bool = true
    @State private var transitAlerts: Bool = true
    @State private var meditationReminders: Bool = false
    @State private var orbTolerance: Double = 8.0

    var body: some View {
        ScrollView {
            VStack(spacing: ResonanceMacTheme.Spacing.lg) {
                Text("Settings")
                    .font(ResonanceMacTheme.Typography.largeTitle)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Appearance
                settingsSection("Appearance") {
                    VStack(spacing: ResonanceMacTheme.Spacing.md) {
                        HStack {
                            Label("Night Mode", systemImage: "moon.stars")
                                .font(ResonanceMacTheme.Typography.body)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { appState.isNightMode },
                                set: { newValue in
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        appState.isNightMode = newValue
                                    }
                                }
                            ))
                            .toggleStyle(.switch)
                            .tint(ResonanceMacTheme.Colors.gold)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        HStack {
                            Text("Theme preview")
                                .font(ResonanceMacTheme.Typography.caption)
                                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                            Spacer()
                            themePreview
                        }
                    }
                }

                // Birth Data
                settingsSection("Birth Data") {
                    VStack(spacing: ResonanceMacTheme.Spacing.md) {
                        settingsRow("Date & Time") {
                            DatePicker("", selection: $birthDate)
                                .labelsHidden()
                                .datePickerStyle(.field)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        settingsRow("Location") {
                            TextField("City, State", text: $birthLocation)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 200)
                        }
                    }
                }

                // Chart Preferences
                settingsSection("Chart Preferences") {
                    VStack(spacing: ResonanceMacTheme.Spacing.md) {
                        settingsRow("House System") {
                            Picker("", selection: $houseSystem) {
                                ForEach(HouseSystem.allCases) { system in
                                    Text(system.rawValue).tag(system)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 160)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        settingsRow("Zodiac") {
                            Picker("", selection: $zodiacSystem) {
                                ForEach(ZodiacSystem.allCases) { system in
                                    Text(system.rawValue).tag(system)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        settingsRow("Orb Tolerance") {
                            HStack(spacing: ResonanceMacTheme.Spacing.sm) {
                                Slider(value: $orbTolerance, in: 1...15, step: 0.5)
                                    .tint(ResonanceMacTheme.Colors.gold)
                                    .frame(width: 140)
                                Text("\(orbTolerance, specifier: "%.1f")\u{00B0}")
                                    .font(ResonanceMacTheme.Typography.data)
                                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                                    .frame(width: 36)
                            }
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        HStack {
                            Label("Show Minor Aspects", systemImage: "line.diagonal")
                                .font(ResonanceMacTheme.Typography.body)
                            Spacer()
                            Toggle("", isOn: $showMinorAspects)
                                .toggleStyle(.switch)
                                .tint(ResonanceMacTheme.Colors.gold)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        HStack {
                            Label("Show Asteroids", systemImage: "circle.dotted")
                                .font(ResonanceMacTheme.Typography.body)
                            Spacer()
                            Toggle("", isOn: $showAsteroids)
                                .toggleStyle(.switch)
                                .tint(ResonanceMacTheme.Colors.gold)
                        }
                    }
                }

                // Notifications
                settingsSection("Notifications") {
                    VStack(spacing: ResonanceMacTheme.Spacing.md) {
                        HStack {
                            Label("Daily Insights", systemImage: "sparkles")
                                .font(ResonanceMacTheme.Typography.body)
                            Spacer()
                            Toggle("", isOn: $dailyNotifications)
                                .toggleStyle(.switch)
                                .tint(ResonanceMacTheme.Colors.gold)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        HStack {
                            Label("Transit Alerts", systemImage: "arrow.triangle.2.circlepath")
                                .font(ResonanceMacTheme.Typography.body)
                            Spacer()
                            Toggle("", isOn: $transitAlerts)
                                .toggleStyle(.switch)
                                .tint(ResonanceMacTheme.Colors.gold)
                        }

                        Divider().overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.15))

                        HStack {
                            Label("Meditation Reminders", systemImage: "moon")
                                .font(ResonanceMacTheme.Typography.body)
                            Spacer()
                            Toggle("", isOn: $meditationReminders)
                                .toggleStyle(.switch)
                                .tint(ResonanceMacTheme.Colors.gold)
                        }
                    }
                }

                // About
                settingsSection("About") {
                    VStack(spacing: ResonanceMacTheme.Spacing.sm) {
                        HStack {
                            Text("Luminous Cosmic Architecture\u{2122}")
                                .font(ResonanceMacTheme.Typography.headline)
                                .foregroundStyle(
                                    appState.isNightMode
                                        ? ResonanceMacTheme.Colors.cream
                                        : ResonanceMacTheme.Colors.forestDeep
                                )
                            Spacer()
                        }
                        HStack {
                            Text("Version 1.0.0")
                                .font(ResonanceMacTheme.Typography.caption)
                                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                            Spacer()
                        }
                        HStack {
                            Text("Built with the Resonance UX design system")
                                .font(ResonanceMacTheme.Typography.caption)
                                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                            Spacer()
                        }
                    }
                }
            }
            .padding(ResonanceMacTheme.Spacing.xl)
            .frame(maxWidth: 600)
        }
    }

    // MARK: - Components

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
            Text(title.uppercased())
                .font(ResonanceMacTheme.Typography.caption2)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                .tracking(1.2)

            VStack {
                content()
            }
            .padding(ResonanceMacTheme.Spacing.lg)
            .glassmorphism(isNightMode: appState.isNightMode)
        }
    }

    private func settingsRow<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(ResonanceMacTheme.Typography.body)
                .foregroundStyle(
                    appState.isNightMode
                        ? ResonanceMacTheme.Colors.cream
                        : ResonanceMacTheme.Colors.forestDeep
                )
            Spacer()
            content()
        }
    }

    private var themePreview: some View {
        HStack(spacing: 4) {
            ForEach([
                ResonanceMacTheme.Colors.forestDeep,
                ResonanceMacTheme.Colors.forestMid,
                ResonanceMacTheme.Colors.gold,
                ResonanceMacTheme.Colors.goldLight,
                ResonanceMacTheme.Colors.cream,
                ResonanceMacTheme.Colors.mutedGreen,
            ], id: \.self) { color in
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.2), lineWidth: 0.5))
            }
        }
    }
}

// MARK: - Enums

enum HouseSystem: String, CaseIterable, Identifiable {
    case placidus = "Placidus"
    case wholeSign = "Whole Sign"
    case equal = "Equal"
    case koch = "Koch"
    case porphyry = "Porphyry"

    var id: String { rawValue }
}

enum ZodiacSystem: String, CaseIterable, Identifiable {
    case tropical = "Tropical"
    case sidereal = "Sidereal"

    var id: String { rawValue }
}
