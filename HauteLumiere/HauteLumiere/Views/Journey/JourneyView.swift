// JourneyView.swift
// Haute Lumière — Journey Tab
//
// The Journey tab is the user's personal universe:
// Diary, Social Studio, Weekly Reports, Habit Tracking,
// Style Preferences, and a hidden depth indicator.

import SwiftUI

struct JourneyView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @EnvironmentObject var habitTracker: HabitTracker

    @State private var selectedSection: JourneySection = .diary

    private var palette: HLColorPalette { appState.selectedColorPalette }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                if appState.isNightMode {
                    ForestNightBackground(theme: appState.nightModeTheme)
                } else {
                    DarkLaceBackground(palette: palette)
                }

                VStack(spacing: 0) {
                    // Section Picker
                    sectionPicker
                        .padding(.horizontal, HLSpacing.lg)
                        .padding(.top, HLSpacing.sm)

                    // Content
                    TabView(selection: $selectedSection) {
                        DiaryView()
                            .tag(JourneySection.diary)

                        SocialStudioView()
                            .tag(JourneySection.studio)

                        WeeklyReportView()
                            .tag(JourneySection.reports)

                        HabitTrackerView()
                            .tag(JourneySection.habits)

                        StylePreferencesView()
                            .tag(JourneySection.style)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Your Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "light.max")
                            .font(.system(size: 12, weight: .ultraLight))
                            .foregroundColor(palette.accentPrimary)
                        Text("Your Journey")
                            .font(HLTypography.serifMedium(18))
                            .foregroundColor(palette.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Section Picker
    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(JourneySection.allCases, id: \.self) { section in
                    Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedSection = section } }) {
                        HStack(spacing: 6) {
                            Image(systemName: section.icon)
                                .font(.system(size: 12))
                            Text(section.rawValue)
                                .font(HLTypography.label)
                        }
                        .foregroundColor(selectedSection == section ? palette.bgDeep : palette.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedSection == section ? palette.accentPrimary : palette.cardFill)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Journey Sections
enum JourneySection: String, CaseIterable {
    case diary = "Diary"
    case studio = "Studio"
    case reports = "Reports"
    case habits = "Habits"
    case style = "Style"

    var icon: String {
        switch self {
        case .diary: return "book.closed.fill"
        case .studio: return "camera.aperture"
        case .reports: return "chart.bar.fill"
        case .habits: return "checkmark.circle"
        case .style: return "paintpalette.fill"
        }
    }
}

// MARK: - Style Preferences View (Font Pairing + Color Palette Swap)
struct StylePreferencesView: View {
    @EnvironmentObject var appState: AppState
    private var palette: HLColorPalette { appState.selectedColorPalette }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: HLSpacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Aesthetic")
                        .font(HLTypography.serifMedium(28))
                        .foregroundColor(palette.textPrimary)
                    Text("Choose the look that feels like you")
                        .font(HLTypography.caption)
                        .foregroundColor(palette.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Font Pairings
                fontPairingsSection

                // Color Palettes
                colorPalettesSection

                // Preview
                stylePreview

                Spacer(minLength: 120)
            }
            .padding(.horizontal, HLSpacing.lg)
            .padding(.top, HLSpacing.md)
        }
    }

    // MARK: - Font Pairings
    private var fontPairingsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Typography")
                .font(HLTypography.label)
                .foregroundColor(palette.accentPrimary)

            ForEach(HLFontPairing.allCases) { pairing in
                Button(action: { appState.selectedFontPairing = pairing }) {
                    HStack(spacing: HLSpacing.md) {
                        // Sample text
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pairing.rawValue)
                                .font(.custom(pairing.serifFamily, size: 18).weight(.medium))
                                .foregroundColor(palette.textPrimary)
                            Text(pairing.description)
                                .font(.custom(pairing.sansFamily, size: 12))
                                .foregroundColor(palette.textSecondary)
                            Text("Aa Bb Cc — \(pairing.serifFamily) + \(pairing.sansFamily)")
                                .font(.custom(pairing.sansFamily, size: 10))
                                .foregroundColor(palette.textSecondary.opacity(0.6))
                        }

                        Spacer()

                        // Selection indicator
                        ZStack {
                            Circle()
                                .stroke(palette.accentPrimary.opacity(0.3), lineWidth: 1)
                                .frame(width: 22, height: 22)
                            if appState.selectedFontPairing == pairing {
                                Circle()
                                    .fill(palette.accentPrimary)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                    .padding(HLSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: HLRadius.lg)
                            .fill(appState.selectedFontPairing == pairing ? palette.accentPrimary.opacity(0.06) : palette.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: HLRadius.lg)
                            .stroke(appState.selectedFontPairing == pairing ? palette.accentPrimary.opacity(0.3) : .clear, lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Color Palettes
    private var colorPalettesSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Color Palette")
                .font(HLTypography.label)
                .foregroundColor(palette.accentPrimary)

            ForEach(HLColorPalette.allCases) { colorPalette in
                Button(action: { appState.selectedColorPalette = colorPalette }) {
                    HStack(spacing: HLSpacing.md) {
                        // Color swatches
                        HStack(spacing: 4) {
                            Circle().fill(colorPalette.bgDeep).frame(width: 24, height: 24)
                            Circle().fill(colorPalette.accentPrimary).frame(width: 24, height: 24)
                            Circle().fill(colorPalette.accentLight).frame(width: 24, height: 24)
                            Circle().fill(colorPalette.textPrimary).frame(width: 24, height: 24)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(colorPalette.rawValue)
                                .font(HLTypography.cardTitle)
                                .foregroundColor(palette.textPrimary)
                            Text(colorPalette.description)
                                .font(HLTypography.caption)
                                .foregroundColor(palette.textSecondary)
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .stroke(palette.accentPrimary.opacity(0.3), lineWidth: 1)
                                .frame(width: 22, height: 22)
                            if appState.selectedColorPalette == colorPalette {
                                Circle()
                                    .fill(palette.accentPrimary)
                                    .frame(width: 14, height: 14)
                            }
                        }
                    }
                    .padding(HLSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: HLRadius.lg)
                            .fill(appState.selectedColorPalette == colorPalette ? palette.accentPrimary.opacity(0.06) : palette.cardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: HLRadius.lg)
                            .stroke(appState.selectedColorPalette == colorPalette ? palette.accentPrimary.opacity(0.3) : .clear, lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Style Preview
    private var stylePreview: some View {
        VStack(spacing: HLSpacing.md) {
            Text("Preview")
                .font(HLTypography.label)
                .foregroundColor(palette.accentPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: HLSpacing.md) {
                Text("Your Sanctuary Awaits")
                    .font(HLTypography.serifMedium(24))
                    .foregroundColor(palette.textPrimary)

                Text("This is how your app will look with your chosen typography and color palette. Every screen, every card, every moment of your journey.")
                    .font(HLTypography.body)
                    .foregroundColor(palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                HStack(spacing: HLSpacing.sm) {
                    Text("Begin")
                        .font(HLTypography.sansMedium(14))
                        .foregroundColor(palette.bgDeep)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(palette.accentPrimary)
                        .clipShape(Capsule())

                    Text("Explore")
                        .font(HLTypography.sansMedium(14))
                        .foregroundColor(palette.accentPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(palette.accentPrimary.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(palette.accentPrimary.opacity(0.3), lineWidth: 1))
                }
            }
            .hlDiaryCard(palette: palette)
        }
    }
}
