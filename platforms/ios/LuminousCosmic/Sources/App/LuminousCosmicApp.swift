// LuminousCosmicApp.swift
// Luminous Cosmic Architecture™
// Main App Entry with TabView Navigation

import SwiftUI

// MARK: - App Entry Point

@main
struct LuminousCosmicApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding: Bool

    init() {
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        _showOnboarding = State(initialValue: !completed)

        // Configure global appearance
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showOnboarding {
                    OnboardingView(isOnboarding: $showOnboarding)
                        .environment(\.resonanceTheme, ResonanceTheme(isDark: isDarkMode))
                        .transition(.opacity)
                } else {
                    MainTabView(isDarkMode: $isDarkMode)
                        .environment(\.resonanceTheme, ResonanceTheme(isDark: isDarkMode))
                        .transition(.opacity)
                }
            }
            .animation(ResonanceAnimation.slowReveal, value: showOnboarding)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onChange(of: showOnboarding) { _, newValue in
                if !newValue {
                    hasCompletedOnboarding = true
                }
            }
        }
    }

    private func configureAppearance() {
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor(ResonanceColors.creamWarm.opacity(0.95))
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Binding var isDarkMode: Bool
    @Environment(\.resonanceTheme) var theme
    @State private var selectedTab: AppTab = .home
    @State private var tabBarVisible = true

    enum AppTab: String, CaseIterable {
        case home = "Home"
        case chart = "Chart"
        case reflect = "Reflect"
        case meditate = "Meditate"
        case library = "Library"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .home: return "sparkle"
            case .chart: return "circle.hexagongrid"
            case .reflect: return "pencil.line"
            case .meditate: return "figure.mind.and.body"
            case .library: return "book.closed"
            case .settings: return "gearshape"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "sparkle"
            case .chart: return "circle.hexagongrid.fill"
            case .reflect: return "pencil.line"
            case .meditate: return "figure.mind.and.body"
            case .library: return "book.closed.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                case .chart:
                    NatalChartView(chart: ChartCalculator.sampleChart())
                case .reflect:
                    DailyReflectionView()
                case .meditate:
                    MeditationView()
                case .library:
                    ChapterLibraryView()
                case .settings:
                    SettingsView(isDarkMode: $isDarkMode)
                }
            }

            // Custom Tab Bar
            if tabBarVisible {
                customTabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabBarButton(tab: tab)
            }
        }
        .padding(.horizontal, ResonanceSpacing.xs)
        .padding(.top, ResonanceSpacing.sm)
        .padding(.bottom, ResonanceSpacing.xl) // Safe area padding
        .background(
            ZStack {
                // Frosted glass background
                Rectangle()
                    .fill(.ultraThinMaterial)

                Rectangle()
                    .fill(theme.glassFill.opacity(0.6))

                // Top border
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.glassStroke,
                                    theme.glassStroke.opacity(0.05)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 0.5)
                    Spacer()
                }
            }
        )
        .shadow(color: ResonanceColors.shadowDark, radius: 8, y: -2)
    }

    private func tabBarButton(tab: AppTab) -> some View {
        Button {
            withAnimation(ResonanceAnimation.springBouncy) {
                selectedTab = tab
            }
            ResonanceHaptics.selection()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == tab ? theme.accent : theme.textTertiary)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? theme.accent : theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    MainTabView(isDarkMode: .constant(false))
        .environment(\.resonanceTheme, ResonanceTheme(isDark: false))
}

#Preview("Dark Mode") {
    MainTabView(isDarkMode: .constant(true))
        .environment(\.resonanceTheme, ResonanceTheme(isDark: true))
}

#Preview("Onboarding") {
    OnboardingView(isOnboarding: .constant(true))
        .environment(\.resonanceTheme, ResonanceTheme(isDark: true))
}
