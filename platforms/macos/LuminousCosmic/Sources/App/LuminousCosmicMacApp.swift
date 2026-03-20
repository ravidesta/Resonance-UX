// LuminousCosmicMacApp.swift
// Luminous Cosmic Architecture™ — macOS
// A premium astrology developmental map experience

import SwiftUI

@main
struct LuminousCosmicMacApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 960, minHeight: 640)
                .background(ResonanceMacTheme.Colors.background)
                .preferredColorScheme(appState.isNightMode ? .dark : .light)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Cosmic") {
                Button("Refresh Transits") {
                    appState.refreshTransits()
                }
                .keyboardShortcut("r", modifiers: .command)

                Button("Toggle Night Mode") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        appState.isNightMode.toggle()
                    }
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])

                Divider()

                Button("New Reflection") {
                    appState.selectedSection = .reflections
                    appState.isComposingReflection = true
                }
                .keyboardShortcut("j", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(appState)
                .frame(width: 480, height: 520)
        }
    }
}

// MARK: - App State

final class AppState: ObservableObject {
    @Published var selectedSection: SidebarSection = .dashboard
    @Published var isNightMode: Bool = false
    @Published var isComposingReflection: Bool = false
    @Published var currentMoonPhase: MoonPhase = .waxingCrescent
    @Published var dailyInsight: String = "The stars remind you that growth is not linear — it spirals, returning to familiar places with deeper understanding."

    func refreshTransits() {
        // Trigger transit data refresh
    }
}

// MARK: - Navigation Model

enum SidebarSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case birthChart = "Birth Chart"
    case reflections = "Reflections"
    case meditations = "Meditations"
    case library = "Library"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "sparkles"
        case .birthChart: return "circle.circle"
        case .reflections: return "book.closed"
        case .meditations: return "moon.stars"
        case .library: return "books.vertical"
        case .settings: return "gearshape"
        }
    }

    var sectionGroup: SectionGroup {
        switch self {
        case .dashboard: return .main
        case .birthChart, .reflections, .meditations: return .practice
        case .library: return .resources
        case .settings: return .system
        }
    }
}

enum SectionGroup: String, CaseIterable {
    case main = "Overview"
    case practice = "Practice"
    case resources = "Resources"
    case system = "System"
}

enum MoonPhase: String, CaseIterable {
    case newMoon = "New Moon"
    case waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter"
    case waxingGibbous = "Waxing Gibbous"
    case fullMoon = "Full Moon"
    case waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter"
    case waningCrescent = "Waning Crescent"

    var illumination: Double {
        switch self {
        case .newMoon: return 0.0
        case .waxingCrescent: return 0.25
        case .firstQuarter: return 0.50
        case .waxingGibbous: return 0.75
        case .fullMoon: return 1.0
        case .waningGibbous: return 0.75
        case .lastQuarter: return 0.50
        case .waningCrescent: return 0.25
        }
    }

    var emoji: String {
        switch self {
        case .newMoon: return "\u{1F311}"
        case .waxingCrescent: return "\u{1F312}"
        case .firstQuarter: return "\u{1F313}"
        case .waxingGibbous: return "\u{1F314}"
        case .fullMoon: return "\u{1F315}"
        case .waningGibbous: return "\u{1F316}"
        case .lastQuarter: return "\u{1F317}"
        case .waningCrescent: return "\u{1F318}"
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
        } detail: {
            ZStack {
                CosmicBackgroundMac(isNightMode: appState.isNightMode)
                    .ignoresSafeArea()

                detailContent
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    toolbarItems
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private var detailContent: some View {
        switch appState.selectedSection {
        case .dashboard:
            DashboardView()
        case .birthChart:
            NatalChartView()
        case .reflections:
            ReflectionView()
        case .meditations:
            MeditationView()
        case .library:
            LibraryView()
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    private var toolbarItems: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.5)) {
                appState.isNightMode.toggle()
            }
        }) {
            Image(systemName: appState.isNightMode ? "sun.max" : "moon.stars")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ResonanceMacTheme.Colors.gold)
        }
        .help(appState.isNightMode ? "Switch to Day Mode" : "Switch to Night Mode")

        Button(action: { appState.refreshTransits() }) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
        }
        .help("Refresh Transits")
    }
}
