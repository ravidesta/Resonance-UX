// LuminousMacApp.swift
// Luminous Integral Architecture™ — macOS Native App
//
// Full macOS experience with menu bar, toolbar, multi-window support,
// keyboard shortcuts, Touch Bar references, and immersive reading mode.

import SwiftUI

// MARK: - macOS App Entry

@main
struct LuminousMacApp: App {
    @StateObject private var appState = MacAppState()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        // Main window
        WindowGroup("Luminous Integral Architecture", id: "main") {
            MacMainView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
                .onOpenURL { url in
                    appState.handleDeepLink(url)
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            luminousMenuCommands
        }

        // Immersive reading window
        WindowGroup("Immersive Reader", id: "immersive-reader") {
            ImmersiveReaderWindow()
                .environmentObject(appState)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))

        // Coach window
        WindowGroup("Integral Coach", id: "coach") {
            CoachTutorView()
                .frame(minWidth: 400, minHeight: 500)
        }

        // Audiobook window
        WindowGroup("Audiobook Player", id: "audiobook") {
            AudiobookPlayerView()
                .frame(minWidth: 400, minHeight: 600)
        }

        // Settings
        Settings {
            MacSettingsView()
                .environmentObject(appState)
        }
    }

    // MARK: Menu Commands

    @CommandsBuilder
    private var luminousMenuCommands: some Commands {
        // File menu additions
        CommandGroup(after: .newItem) {
            Button("New Reading Window") {
                openWindow(id: "immersive-reader")
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Button("New Coach Session") {
                openWindow(id: "coach")
            }
            .keyboardShortcut("k", modifiers: [.command, .shift])

            Divider()
        }

        // Reading navigation
        CommandMenu("Reading") {
            Button("Next Page") {
                appState.navigateReading(.nextPage)
            }
            .keyboardShortcut(.rightArrow, modifiers: [])

            Button("Previous Page") {
                appState.navigateReading(.previousPage)
            }
            .keyboardShortcut(.leftArrow, modifiers: [])

            Divider()

            Button("Next Chapter") {
                appState.navigateReading(.nextChapter)
            }
            .keyboardShortcut(.rightArrow, modifiers: [.command])

            Button("Previous Chapter") {
                appState.navigateReading(.previousChapter)
            }
            .keyboardShortcut(.leftArrow, modifiers: [.command])

            Divider()

            Button("Toggle Bookmark") {
                appState.toggleBookmark()
            }
            .keyboardShortcut("d", modifiers: [.command])

            Divider()

            Button("Increase Font Size") {
                appState.adjustFontSize(delta: 1)
            }
            .keyboardShortcut("+", modifiers: [.command])

            Button("Decrease Font Size") {
                appState.adjustFontSize(delta: -1)
            }
            .keyboardShortcut("-", modifiers: [.command])

            Button("Reset Font Size") {
                appState.resetFontSize()
            }
            .keyboardShortcut("0", modifiers: [.command])

            Divider()

            // Reading themes
            Menu("Theme") {
                ForEach(ReadingTheme.allCases) { theme in
                    Button(theme.displayName) {
                        appState.readingTheme = theme
                    }
                }
            }

            Button("Immersive Mode") {
                openWindow(id: "immersive-reader")
            }
            .keyboardShortcut("f", modifiers: [.command, .control])
        }

        // Audiobook controls
        CommandMenu("Audiobook") {
            Button("Play / Pause") {
                appState.toggleAudioPlayback()
            }
            .keyboardShortcut(.space, modifiers: [])

            Button("Skip Forward 30s") {
                appState.skipAudio(seconds: 30)
            }
            .keyboardShortcut(.rightArrow, modifiers: [.command, .shift])

            Button("Skip Back 15s") {
                appState.skipAudio(seconds: -15)
            }
            .keyboardShortcut(.leftArrow, modifiers: [.command, .shift])

            Divider()

            Button("Increase Speed") {
                appState.adjustPlaybackSpeed(faster: true)
            }

            Button("Decrease Speed") {
                appState.adjustPlaybackSpeed(faster: false)
            }

            Divider()

            Button("Open Audiobook Player") {
                openWindow(id: "audiobook")
            }
        }

        // View menu additions
        CommandGroup(after: .sidebar) {
            Button("Toggle Sidebar") {
                appState.isSidebarVisible.toggle()
            }
            .keyboardShortcut("s", modifiers: [.command, .control])
        }
    }
}

// MARK: - Mac App State

@MainActor
final class MacAppState: ObservableObject {
    @Published var selectedSidebarItem: SidebarItem = .read
    @Published var isSidebarVisible = true
    @Published var readingTheme: ReadingTheme = .day
    @Published var fontSize: CGFloat = 18
    @Published var isAudioPlaying = false

    enum SidebarItem: String, CaseIterable, Identifiable {
        case read      = "Read"
        case listen    = "Listen"
        case learn     = "Learn"
        case coach     = "Coach"
        case community = "Community"
        case notes     = "Notes"
        case bookmarks = "Bookmarks"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .read:      return "book.fill"
            case .listen:    return "headphones"
            case .learn:     return "graduationcap.fill"
            case .coach:     return "sparkles"
            case .community: return "person.3.fill"
            case .notes:     return "note.text"
            case .bookmarks: return "bookmark.fill"
            }
        }
    }

    enum ReadingNavigation {
        case nextPage, previousPage, nextChapter, previousChapter
    }

    func navigateReading(_ action: ReadingNavigation) {
        // Sends to active reader via NotificationCenter or binding
        NotificationCenter.default.post(
            name: .readingNavigation,
            object: action
        )
    }

    func toggleBookmark() {
        NotificationCenter.default.post(name: .toggleBookmark, object: nil)
    }

    func adjustFontSize(delta: CGFloat) {
        fontSize = max(12, min(36, fontSize + delta))
    }

    func resetFontSize() {
        fontSize = 18
    }

    func toggleAudioPlayback() {
        isAudioPlaying.toggle()
    }

    func skipAudio(seconds: Double) {
        NotificationCenter.default.post(
            name: .audioSkip,
            object: seconds
        )
    }

    func adjustPlaybackSpeed(faster: Bool) {
        NotificationCenter.default.post(
            name: .audioSpeedChange,
            object: faster
        )
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "luminouslia" else { return }
        switch url.host {
        case "read":      selectedSidebarItem = .read
        case "listen":    selectedSidebarItem = .listen
        case "learn":     selectedSidebarItem = .learn
        case "coach":     selectedSidebarItem = .coach
        case "community": selectedSidebarItem = .community
        default: break
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let readingNavigation = Notification.Name("luminous.readingNavigation")
    static let toggleBookmark = Notification.Name("luminous.toggleBookmark")
    static let audioSkip = Notification.Name("luminous.audioSkip")
    static let audioSpeedChange = Notification.Name("luminous.audioSpeedChange")
}

// MARK: - Mac Main View

struct MacMainView: View {
    @EnvironmentObject private var appState: MacAppState

    var body: some View {
        NavigationSplitView {
            macSidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } detail: {
            macDetailView
        }
        .toolbar {
            macToolbar
        }
    }

    // MARK: Sidebar

    private var macSidebar: some View {
        List(selection: $appState.selectedSidebarItem) {
            Section("Library") {
                ForEach([MacAppState.SidebarItem.read, .listen, .learn]) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }

            Section("Tools") {
                ForEach([MacAppState.SidebarItem.coach, .community]) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }

            Section("Collection") {
                ForEach([MacAppState.SidebarItem.notes, .bookmarks]) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: Detail View

    @ViewBuilder
    private var macDetailView: some View {
        switch appState.selectedSidebarItem {
        case .read:
            BookReaderView()
                .environment(\.readingFontSize, appState.fontSize)
                .environment(\.readingTheme, appState.readingTheme)
        case .listen:
            AudiobookPlayerView()
        case .learn:
            MacLearnView()
        case .coach:
            CoachTutorView()
        case .community:
            EcosystemHubView()
        case .notes:
            MacNotesView()
        case .bookmarks:
            MacBookmarksView()
        }
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var macToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            // Reading theme picker
            Menu {
                ForEach(ReadingTheme.allCases) { theme in
                    Button {
                        appState.readingTheme = theme
                    } label: {
                        HStack {
                            Text(theme.displayName)
                            if appState.readingTheme == theme {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "circle.lefthalf.filled")
            }
            .help("Reading Theme")

            // Font size controls
            Button {
                appState.adjustFontSize(delta: -1)
            } label: {
                Image(systemName: "textformat.size.smaller")
            }
            .help("Decrease Font Size")

            Button {
                appState.adjustFontSize(delta: 1)
            } label: {
                Image(systemName: "textformat.size.larger")
            }
            .help("Increase Font Size")

            Divider()

            // Audio controls in toolbar
            Button {
                appState.toggleAudioPlayback()
            } label: {
                Image(systemName: appState.isAudioPlaying ? "pause.fill" : "play.fill")
            }
            .help(appState.isAudioPlaying ? "Pause" : "Play")
        }

        // Touch Bar items (legacy macOS support)
        #if os(macOS)
        ToolbarItem(placement: .automatic) {
            // Touch Bar: reading progress
            ResonanceProgressBar(progress: 0.35, height: 4)
                .frame(width: 120)
        }
        #endif
    }
}

// MARK: - Immersive Reader Window

struct ImmersiveReaderWindow: View {
    @EnvironmentObject private var appState: MacAppState
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        ZStack {
            appState.readingTheme.background
                .ignoresSafeArea()

            PaperTextureOverlay()
                .ignoresSafeArea()

            BookReaderView()
                .environment(\.readingFontSize, appState.fontSize + 2)
                .environment(\.readingTheme, appState.readingTheme)
        }
        .toolbar(.hidden, for: .windowToolbar)
        .onExitCommand {
            // Esc key to exit immersive mode
        }
    }
}

// MARK: - Mac Learn View

struct MacLearnView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interactive Learning")
                        .font(ResonanceTypography.serifDisplay())
                    Text("Exercises, reflections, and somatic practices")
                        .font(ResonanceTypography.sansBody())
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ResonanceDivider()

                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 24) {
                        QuadrantMappingCard(title: "Map your current experience")
                        SomaticPracticeCard(
                            title: "Spatial Attunement",
                            instruction: "Expand awareness to hold the full dimensionality of this moment.",
                            durationSeconds: 180
                        )
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 24) {
                        ReflectionQuestionCard(
                            question: "What perspective do you find most challenging to hold?",
                            prompt: "Consider which quadrant feels least natural to you."
                        )
                        ReflectionQuestionCard(
                            question: "How does your understanding of development shape your daily choices?",
                            prompt: nil
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(40)
        }
        .resonanceBackground()
    }
}

// MARK: - Mac Notes View

struct MacNotesView: View {
    var body: some View {
        VStack {
            Text("Notes & Highlights")
                .font(ResonanceTypography.serifTitle())
                .padding(.top, 40)

            Text("Your annotations, highlights, and reading notes will appear here.")
                .font(ResonanceTypography.sansBody())
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .resonanceBackground()
    }
}

// MARK: - Mac Bookmarks View

struct MacBookmarksView: View {
    var body: some View {
        VStack {
            Text("Bookmarks")
                .font(ResonanceTypography.serifTitle())
                .padding(.top, 40)

            Text("Your saved bookmarks across chapters.")
                .font(ResonanceTypography.sansBody())
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .resonanceBackground()
    }
}

// MARK: - Mac Settings View

struct MacSettingsView: View {
    @EnvironmentObject private var appState: MacAppState

    var body: some View {
        TabView {
            // Reading settings
            Form {
                Section("Typography") {
                    Slider(value: $appState.fontSize, in: 12...36, step: 1) {
                        Text("Font Size: \(Int(appState.fontSize))pt")
                    }

                    Picker("Theme", selection: $appState.readingTheme) {
                        ForEach(ReadingTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                }
            }
            .tabItem {
                Label("Reading", systemImage: "book")
            }
            .frame(width: 450, height: 200)

            // Audio settings
            Form {
                Section("Playback") {
                    Text("Default playback speed")
                    Text("Sleep timer defaults")
                }
            }
            .tabItem {
                Label("Audio", systemImage: "headphones")
            }
            .frame(width: 450, height: 200)

            // Account settings
            Form {
                Section("Account") {
                    Text("Profile settings")
                    Text("Subscription management")
                }
            }
            .tabItem {
                Label("Account", systemImage: "person.circle")
            }
            .frame(width: 450, height: 200)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LuminousMacApp_Previews: PreviewProvider {
    static var previews: some View {
        MacMainView()
            .environmentObject(MacAppState())
            .previewDisplayName("macOS Main")
    }
}
#endif
