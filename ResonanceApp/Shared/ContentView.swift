// ContentView.swift
// Resonance — Design for the Exhale
//
// Main content view with adaptive navigation for all platforms.

import SwiftUI

// MARK: - Navigation Tab

enum ResonanceTab: String, CaseIterable, Identifiable {
    case flow = "Flow"
    case focus = "Focus"
    case writer = "Writer"
    case circle = "Circle"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .flow: return "leaf.fill"
        case .focus: return "circle.grid.2x2"
        case .writer: return "text.cursor"
        case .circle: return "person.2.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .flow: return "Daily rhythms"
        case .focus: return "Intentional tasks"
        case .writer: return "Quiet composition"
        case .circle: return "Inner connections"
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @State var themeManager = ThemeManager()
    @State private var selectedTab: ResonanceTab = .flow

    var theme: ResonanceTheme { themeManager.currentTheme }

    var body: some View {
        #if os(macOS)
        macOSLayout
        #elseif os(visionOS)
        visionOSLayout
        #else
        iOSLayout
        #endif
    }

    // MARK: - iOS / iPadOS Layout

    #if os(iOS)
    private var iOSLayout: some View {
        ZStack {
            AmbientBackground(theme: theme)

            TabView(selection: $selectedTab) {
                ForEach(ResonanceTab.allCases) { tab in
                    tabContent(for: tab)
                        .tabItem {
                            Label(tab.rawValue, systemImage: tab.icon)
                        }
                        .tag(tab)
                }
            }
            .tint(theme.goldPrimary)

            // Deep Rest toggle overlay
            VStack {
                HStack {
                    Spacer()
                    DeepRestToggle(themeManager: themeManager)
                        .padding(.trailing, ResonanceTheme.spacingM)
                }
                Spacer()
            }
            .padding(.top, 8)
        }
        .environment(\.resonanceTheme, theme)
    }
    #endif

    // MARK: - macOS Layout

    #if os(macOS)
    private var macOSLayout: some View {
        NavigationSplitView {
            macOSSidebar
        } detail: {
            ZStack {
                AmbientBackground(theme: theme)
                tabContent(for: selectedTab)
            }
        }
        .environment(\.resonanceTheme, theme)
        .frame(minWidth: 900, minHeight: 600)
    }

    private var macOSSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App title
            VStack(alignment: .leading, spacing: 2) {
                Text("Resonance")
                    .font(ResonanceFont.headlineLarge)
                    .foregroundStyle(theme.textMain)

                Text("Design for the exhale")
                    .font(ResonanceFont.caption)
                    .foregroundStyle(theme.textLight)
            }
            .padding(ResonanceTheme.spacingM)

            Divider()

            // Navigation items
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 2) {
                    ForEach(ResonanceTab.allCases) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 14))
                                    .frame(width: 20)
                                    .foregroundStyle(
                                        selectedTab == tab ? theme.goldPrimary : theme.textMuted
                                    )

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(tab.rawValue)
                                        .font(ResonanceFont.labelLarge)
                                        .foregroundStyle(
                                            selectedTab == tab ? theme.textMain : theme.textMuted
                                        )

                                    Text(tab.subtitle)
                                        .font(ResonanceFont.caption)
                                        .foregroundStyle(theme.textLight)
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(theme.goldPrimary.opacity(0.08))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(ResonanceTheme.spacingS)
            }

            Spacer()

            Divider()

            // Deep Rest toggle at bottom
            DeepRestToggle(themeManager: themeManager)
                .padding(ResonanceTheme.spacingM)
        }
        .background(theme.bgSurface.opacity(0.5))
        .frame(minWidth: 220)
    }
    #endif

    // MARK: - visionOS Layout

    #if os(visionOS)
    private var visionOSLayout: some View {
        NavigationSplitView {
            visionOSSidebar
        } detail: {
            ZStack {
                AmbientBackground(theme: theme)
                tabContent(for: selectedTab)
            }
        }
        .environment(\.resonanceTheme, theme)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            visionOSOrnament
        }
    }

    private var visionOSSidebar: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.spacingS) {
            Text("Resonance")
                .font(ResonanceFont.headlineLarge)
                .foregroundStyle(theme.textMain)
                .padding(.bottom, ResonanceTheme.spacingS)

            ForEach(ResonanceTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Label(tab.rawValue, systemImage: tab.icon)
                        .font(ResonanceFont.bodyLarge)
                        .foregroundStyle(selectedTab == tab ? theme.goldPrimary : theme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(ResonanceTheme.spacingM)
    }

    private var visionOSOrnament: some View {
        HStack(spacing: ResonanceTheme.spacingM) {
            ForEach(ResonanceTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.rawValue)
                            .font(ResonanceFont.caption)
                    }
                    .foregroundStyle(selectedTab == tab ? theme.goldPrimary : theme.textMuted)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }

            Divider()
                .frame(height: 30)

            DeepRestToggle(themeManager: themeManager)
        }
        .padding(.horizontal, ResonanceTheme.spacingM)
        .padding(.vertical, ResonanceTheme.spacingS)
        .glassBackground()
    }
    #endif

    // MARK: - Tab Content

    @ViewBuilder
    func tabContent(for tab: ResonanceTab) -> some View {
        switch tab {
        case .flow:
            DailyFlowView(theme: theme)
        case .focus:
            FocusView(theme: theme)
        case .writer:
            WriterView(theme: theme)
        case .circle:
            InnerCircleView(theme: theme)
        }
    }
}
