// PracticeLibraryView.swift
// Haute Lumière — Practice Library Hub

import SwiftUI

struct PracticeLibraryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: PracticeCategory = .all
    @State private var searchText: String = ""

    enum PracticeCategory: String, CaseIterable {
        case all = "All"
        case yogaNidra = "Yoga Nidra"
        case breathing = "Breathing"
        case meditation = "Meditation"
        case soundscapes = "Soundscapes"
        case selfInquiry = "Self-Inquiry"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if appState.isNightMode {
                    ForestNightBackground(theme: appState.nightModeTheme)
                } else {
                    Color.hlCream.ignoresSafeArea()
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: HLSpacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: HLSpacing.sm) {
                            Text("Practice")
                                .font(HLTypography.screenTitle)
                                .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)
                            Text("Your complete wellness library")
                                .font(HLTypography.body)
                                .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HLSpacing.lg)

                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: HLSpacing.sm) {
                                ForEach(PracticeCategory.allCases, id: \.self) { cat in
                                    Button(action: { selectedCategory = cat }) {
                                        Text(cat.rawValue)
                                            .font(HLTypography.label)
                                            .foregroundColor(selectedCategory == cat
                                                ? (appState.isNightMode ? .hlGreen900 : .hlSurface)
                                                : (appState.isNightMode ? .hlNightText : .hlTextSecondary))
                                            .padding(.horizontal, HLSpacing.md)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule().fill(selectedCategory == cat ? Color.hlGold : Color.hlGreen100.opacity(appState.isNightMode ? 0.1 : 1))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, HLSpacing.lg)
                        }

                        // Category Sections
                        if selectedCategory == .all || selectedCategory == .yogaNidra {
                            practiceSection(
                                title: "Yoga Nidra",
                                icon: "moon.stars.fill",
                                count: "120+ sessions",
                                destination: YogaNidraLibraryView()
                            )
                        }

                        if selectedCategory == .all || selectedCategory == .breathing {
                            practiceSection(
                                title: "Guided Breathing",
                                icon: "wind",
                                count: "100+ experiences",
                                destination: BreathingLibraryView()
                            )
                        }

                        if selectedCategory == .all || selectedCategory == .meditation {
                            practiceSection(
                                title: "Visualization",
                                icon: "eye.fill",
                                count: "New every time",
                                destination: VisualizationView()
                            )
                        }

                        if selectedCategory == .all || selectedCategory == .soundscapes {
                            practiceSection(
                                title: "Soundscapes",
                                icon: "waveform",
                                count: "100+ sounds",
                                destination: SoundscapeLibraryView()
                            )
                        }

                        if selectedCategory == .all || selectedCategory == .selfInquiry {
                            practiceSection(
                                title: "Self-Inquiry",
                                icon: "sparkle.magnifyingglass",
                                count: "Guided reflection",
                                destination: SelfInquiryView()
                            )
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.top, HLSpacing.md)
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func practiceSection<Destination: View>(
        title: String,
        icon: String,
        count: String,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: HLSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.md)
                        .fill(
                            LinearGradient(colors: [.hlGreen700, .hlGreen600], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(.hlGoldLight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                    Text(count)
                        .font(HLTypography.bodySmall)
                        .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.hlTextTertiary)
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
            )
            .hlShadowSubtle()
        }
        .padding(.horizontal, HLSpacing.lg)
    }
}

// MARK: - Self-Inquiry View
struct SelfInquiryView: View {
    @EnvironmentObject var appState: AppState

    let inquiries = [
        ("Who Am I?", "The fundamental inquiry into your true nature", "person.fill.questionmark"),
        ("What Do I Truly Want?", "Beyond surface desires to core longings", "heart.fill"),
        ("What Am I Grateful For?", "Expanding appreciation and presence", "sparkles"),
        ("What Would I Do If I Weren't Afraid?", "Exploring courage and possibility", "bolt.fill"),
        ("What Is My Deepest Truth?", "Connecting with authentic self-expression", "eye.fill"),
        ("Where Am I Holding On?", "Gentle exploration of release and surrender", "hand.raised.fill"),
    ]

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView {
                VStack(spacing: HLSpacing.md) {
                    ForEach(inquiries, id: \.0) { title, subtitle, icon in
                        HStack(spacing: HLSpacing.md) {
                            Image(systemName: icon)
                                .font(.system(size: 20))
                                .foregroundColor(.hlGold)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(HLTypography.cardTitle)
                                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                                Text(subtitle)
                                    .font(HLTypography.bodySmall)
                                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                            }

                            Spacer()

                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.hlGold)
                        }
                        .padding(HLSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: HLRadius.lg)
                                .fill(appState.isNightMode ? Color.white.opacity(0.05) : .hlSurface)
                        )
                    }
                }
                .padding(HLSpacing.lg)
            }
        }
        .navigationTitle("Self-Inquiry")
    }
}
