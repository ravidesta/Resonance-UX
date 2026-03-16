// MainAppView.swift
// Resonance UX GitHub Backup — Main Navigation
// macOS / iPadOS / iOS / visionOS unified entry point

import SwiftUI

struct MainAppView: View {
    @StateObject var viewModel = BackupViewModel()

    var body: some View {
        #if os(macOS)
        macOSLayout
        #elseif os(visionOS)
        visionOSLayout
        #else
        iOSLayout
        #endif
    }

    // MARK: - macOS Layout

    #if os(macOS)
    var macOSLayout: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .environmentObject(viewModel)
        .frame(minWidth: 1100, minHeight: 700)
    }
    #endif

    // MARK: - visionOS Layout

    #if os(visionOS)
    var visionOSLayout: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .environmentObject(viewModel)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            HStack(spacing: 24) {
                ForEach(BackupViewModel.NavigationDestination.allCases, id: \.self) { dest in
                    Button(action: { viewModel.selectedNavigation = dest }) {
                        VStack(spacing: 4) {
                            Image(systemName: dest.icon)
                                .font(.system(size: 20))
                            Text(dest.rawValue)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(
                            viewModel.selectedNavigation == dest
                                ? ResonanceColors.goldPrimary
                                : .white.opacity(0.6)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .glassBackgroundEffect()
        }
    }
    #endif

    // MARK: - iOS / iPadOS Layout

    var iOSLayout: some View {
        TabView(selection: $viewModel.selectedNavigation) {
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "square.grid.2x2")
                }
                .tag(BackupViewModel.NavigationDestination.gallery)

            MarketplaceView()
                .tabItem {
                    Label("Marketplace", systemImage: "storefront")
                }
                .tag(BackupViewModel.NavigationDestination.marketplace)

            systemCalendarView
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(BackupViewModel.NavigationDestination.calendar)

            CommandLineView()
                .tabItem {
                    Label("Terminal", systemImage: "terminal")
                }
                .tag(BackupViewModel.NavigationDestination.terminal)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(BackupViewModel.NavigationDestination.settings)
        }
        .environmentObject(viewModel)
    }

    // MARK: - Sidebar

    var sidebar: some View {
        List(selection: $viewModel.selectedNavigation) {
            Section {
                ForEach(BackupViewModel.NavigationDestination.allCases, id: \.self) { dest in
                    Label(dest.rawValue, systemImage: dest.icon)
                        .tag(dest)
                }
            } header: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RESONANCE")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.goldPrimary)
                        .tracking(3)
                    Text("BACKUP")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .tracking(2)
                }
                .padding(.bottom, 8)
            }

            Section("Portfolios") {
                ForEach(viewModel.portfolios) { portfolio in
                    HStack(spacing: 8) {
                        IndicatorLight(status: portfolio.backupStatus, size: 5)
                        Text(portfolio.logoEmoji)
                            .font(.system(size: 14))
                        Text(portfolio.repositoryName)
                            .font(ResonanceTypography.captionSystem)
                            .lineLimit(1)
                    }
                }
            }

            Section("Quick Actions") {
                Button(action: { Task { await viewModel.backupAll() } }) {
                    Label("Backup All", systemImage: "arrow.up.doc")
                }
                Button(action: { viewModel.selectedNavigation = .terminal }) {
                    Label("Open Terminal", systemImage: "terminal")
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Resonance")
    }

    // MARK: - Detail View

    @ViewBuilder
    var detailView: some View {
        switch viewModel.selectedNavigation {
        case .gallery:
            GalleryView()
        case .marketplace:
            MarketplaceView()
        case .calendar:
            systemCalendarView
        case .terminal:
            CommandLineView()
        case .settings:
            SettingsView()
        }
    }

    // MARK: - System Calendar (All portfolios)

    var systemCalendarView: some View {
        ZStack {
            BioluminescentBackground(portfolioColor: ResonanceColors.signalTeal)

            VStack(spacing: ResonanceSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SYSTEM CALENDAR")
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(ResonanceColors.goldPrimary)
                            .tracking(3)
                        Text("Ledger & Bitstamp Log")
                            .font(ResonanceTypography.headingSystem)
                    }
                    Spacer()
                }
                .padding(.horizontal, ResonanceSpacing.md)

                // All changelog entries across portfolios
                ScrollView {
                    LazyVStack(spacing: ResonanceSpacing.sm) {
                        ForEach(allChangelogs) { entry in
                            HStack(spacing: ResonanceSpacing.sm) {
                                // Date column
                                VStack(alignment: .trailing, spacing: 0) {
                                    Text(entry.entry.date.formatted(.dateTime.month(.abbreviated).day()))
                                        .font(ResonanceTypography.captionSystem)
                                    Text(entry.entry.date.formatted(.dateTime.hour().minute()))
                                        .font(ResonanceTypography.monoFont)
                                        .foregroundColor(ResonanceColors.textLight)
                                }
                                .frame(width: 60)

                                // Indicator
                                ChromaticOrb(
                                    color: ResonanceColors.accentFor(index: entry.portfolioIndex),
                                    size: 6, pulse: false
                                )

                                // Content
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(entry.portfolioName.uppercased())
                                            .font(ResonanceTypography.callsignFont)
                                            .foregroundColor(ResonanceColors.accentFor(index: entry.portfolioIndex))
                                            .tracking(0.5)
                                        Text("• \(entry.entry.action.rawValue)")
                                            .font(ResonanceTypography.captionSystem)
                                            .foregroundColor(ResonanceColors.textMuted)
                                    }
                                    Text(entry.entry.description)
                                        .font(ResonanceTypography.bodySystem)
                                        .lineLimit(1)

                                    if let hash = entry.entry.bitstampHash {
                                        HStack(spacing: 4) {
                                            Image(systemName: "checkmark.seal")
                                                .font(.system(size: 8))
                                            Text(hash.prefix(20).description)
                                                .font(ResonanceTypography.monoFont)
                                        }
                                        .foregroundColor(ResonanceColors.goldPrimary)
                                    }
                                }

                                Spacer()
                            }
                            .padding(ResonanceSpacing.sm)
                            .glassPanel()
                        }
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .padding(.top, ResonanceSpacing.md)
        }
    }

    struct CalendarEntry: Identifiable {
        let id = UUID()
        let portfolioName: String
        let portfolioIndex: Int
        let entry: ChangeLogEntry
    }

    var allChangelogs: [CalendarEntry] {
        viewModel.portfolios.enumerated().flatMap { (index, portfolio) in
            portfolio.changelog.map { entry in
                CalendarEntry(portfolioName: portfolio.repositoryName, portfolioIndex: index, entry: entry)
            }
        }
        .sorted { $0.entry.date > $1.entry.date }
    }
}

// MARK: - App Entry Point

@main
struct ResonanceBackupApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .windowStyle(.titleBar)
        .defaultSize(width: 1200, height: 800)
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(BackupViewModel())
        }
        #endif
    }
}
