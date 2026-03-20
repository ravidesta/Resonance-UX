// LuminousIPadApp.swift
// Luminous Integral Architecture™ — iPadOS Optimized App Entry Point
//
// Multi-column NavigationSplitView with sidebar, content, and detail panes.
// Supports drag-and-drop notes, split view reading+coaching, and Apple Pencil annotations.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - iPad App Entry

@main
struct LuminousIPadApp: App {
    @StateObject private var appState = IPadAppState()

    var body: some Scene {
        WindowGroup {
            IPadRootView()
                .environmentObject(appState)
                .onOpenURL { url in
                    appState.handleDeepLink(url)
                }
        }
    }
}

// MARK: - iPad App State

@MainActor
final class IPadAppState: ObservableObject {
    @Published var selectedSidebarItem: SidebarItem = .read
    @Published var selectedChapter: Chapter?
    @Published var isSplitReadingCoachActive = false
    @Published var showMiniAudioPlayer = false
    @Published var pencilAnnotationMode: PencilMode = .off

    enum SidebarItem: String, CaseIterable, Identifiable {
        case read      = "Read"
        case listen    = "Listen"
        case learn     = "Learn"
        case coach     = "Coach"
        case community = "Community"
        case notes     = "Notes"
        case bookmarks = "Bookmarks"
        case settings  = "Settings"

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
            case .settings:  return "gearshape"
            }
        }

        var sectionHeader: String? {
            switch self {
            case .read, .listen, .learn, .coach, .community: return nil
            case .notes, .bookmarks: return "Library"
            case .settings: return "Preferences"
            }
        }
    }

    enum PencilMode: String, CaseIterable {
        case off         = "Off"
        case highlight   = "Highlight"
        case underline   = "Underline"
        case freeform    = "Draw"

        var icon: String {
            switch self {
            case .off:       return "pencil.slash"
            case .highlight: return "highlighter"
            case .underline: return "underline"
            case .freeform:  return "scribble"
            }
        }
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

// MARK: - iPad Root View

struct IPadRootView: View {
    @EnvironmentObject private var appState: IPadAppState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebarContent
                .navigationTitle("Luminous")
        } content: {
            contentPane
        } detail: {
            detailPane
        }
        .tint(Color.resonanceGoldPrimary)
        .overlay(alignment: .bottom) {
            if appState.showMiniAudioPlayer && appState.selectedSidebarItem != .listen {
                AudiobookPlayerView().miniPlayerBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom))
            }
        }
    }

    // MARK: Sidebar

    private var sidebarContent: some View {
        List(selection: $appState.selectedSidebarItem) {
            Section("Experience") {
                ForEach([IPadAppState.SidebarItem.read, .listen, .learn, .coach, .community]) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                        .accessibilityLabel(item.rawValue)
                }
            }

            Section("Library") {
                ForEach([IPadAppState.SidebarItem.notes, .bookmarks]) { item in
                    Label(item.rawValue, systemImage: item.icon)
                        .tag(item)
                }
            }

            Section {
                Label(IPadAppState.SidebarItem.settings.rawValue, systemImage: IPadAppState.SidebarItem.settings.icon)
                    .tag(IPadAppState.SidebarItem.settings)
            }

            // Split view toggle
            Section("Layout") {
                Toggle(isOn: $appState.isSplitReadingCoachActive) {
                    Label("Read + Coach Split", systemImage: "rectangle.split.2x1")
                }
                .tint(Color.resonanceGoldPrimary)
                .accessibilityLabel("Enable reading and coaching side by side")
            }

            // Apple Pencil mode
            Section("Apple Pencil") {
                ForEach(IPadAppState.PencilMode.allCases, id: \.self) { mode in
                    Button {
                        appState.pencilAnnotationMode = mode
                    } label: {
                        HStack {
                            Label(mode.rawValue, systemImage: mode.icon)
                            Spacer()
                            if appState.pencilAnnotationMode == mode {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.resonanceGoldPrimary)
                            }
                        }
                    }
                    .accessibilityLabel("Pencil mode: \(mode.rawValue)")
                }
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: Content Pane

    @ViewBuilder
    private var contentPane: some View {
        switch appState.selectedSidebarItem {
        case .read:
            chapterListContent
        case .listen:
            audioChapterListContent
        case .learn:
            learnContentList
        case .coach:
            coachSessionList
        case .community:
            communityContentList
        case .notes:
            notesListContent
        case .bookmarks:
            bookmarksListContent
        case .settings:
            settingsContent
        }
    }

    // MARK: Detail Pane

    @ViewBuilder
    private var detailPane: some View {
        if appState.isSplitReadingCoachActive {
            // Split view: reading + coaching side by side
            HStack(spacing: 0) {
                BookReaderView()
                    .frame(maxWidth: .infinity)

                Divider()

                CoachTutorView()
                    .frame(maxWidth: .infinity)
            }
        } else {
            switch appState.selectedSidebarItem {
            case .read:
                BookReaderView()
            case .listen:
                AudiobookPlayerView()
            case .learn:
                LearnDetailView()
            case .coach:
                CoachTutorView()
            case .community:
                EcosystemHubView()
            case .notes:
                NotesDetailView()
            case .bookmarks:
                BookmarksDetailView()
            case .settings:
                SettingsDetailView()
            }
        }
    }

    // MARK: Chapter List Content

    private var chapterListContent: some View {
        List {
            Section {
                HStack {
                    ResonanceProgressRing(progress: 0.35, size: 48, lineWidth: 4)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("35% Complete")
                            .font(ResonanceTypography.sansHeadline())
                        Text("Page 120 of 342")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Chapters") {
                ForEach(sampleChapters) { chapter in
                    NavigationLink(value: chapter) {
                        HStack(spacing: 12) {
                            Image(systemName: chapter.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(chapter.isCompleted ? Color.resonanceGreen500 : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(chapter.title)
                                    .font(ResonanceTypography.sansBody())
                                if let subtitle = chapter.subtitle {
                                    Text(subtitle)
                                        .font(ResonanceTypography.sansCaption2())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .accessibilityLabel("\(chapter.title)\(chapter.isCompleted ? ", completed" : "")")
                }
            }
        }
        .navigationTitle("Chapters")
        // Drag and drop support for notes
        .onDrop(of: [.text], isTargeted: nil) { providers in
            // Handle dropped text as note content
            return true
        }
    }

    private var audioChapterListContent: some View {
        List {
            Section("Audiobook Chapters") {
                ForEach(sampleChapters) { chapter in
                    HStack(spacing: 12) {
                        Image(systemName: chapter.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(chapter.isCompleted ? Color.resonanceGreen500 : .secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chapter.title)
                                .font(ResonanceTypography.sansBody())
                            if let d = chapter.duration {
                                let m = Int(d) / 60
                                Text("\(m) min")
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Audiobook")
    }

    private var learnContentList: some View {
        List {
            Section("Exercises") {
                Label("Quadrant Mapping", systemImage: "square.grid.2x2")
                Label("Reflection Prompts", systemImage: "sparkles")
                Label("Assessment Quizzes", systemImage: "checklist")
            }
            Section("Practices") {
                Label("Spatial Attunement", systemImage: "figure.mind.and.body")
                Label("Body Scan", systemImage: "person.fill")
                Label("Integral Meditation", systemImage: "brain.head.profile")
            }
        }
        .navigationTitle("Learn")
    }

    private var coachSessionList: some View {
        List {
            Section("Active Session") {
                Label("Current Coaching Session", systemImage: "bubble.left.and.bubble.right.fill")
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }
            Section("Past Sessions") {
                ForEach(0..<3) { i in
                    Label("Session \(3 - i)", systemImage: "clock.arrow.circlepath")
                }
            }
        }
        .navigationTitle("Coach")
    }

    private var communityContentList: some View {
        List {
            Section("Your Groups") {
                Label("Integral Beginners Circle", systemImage: "person.3")
                Label("Advanced Practitioners", systemImage: "person.3")
            }
            Section("Community") {
                Label("Feed", systemImage: "text.bubble")
                Label("Practice Circles", systemImage: "figure.mind.and.body")
                Label("Events", systemImage: "calendar")
            }
        }
        .navigationTitle("Community")
    }

    private var notesListContent: some View {
        List {
            Section("Recent Notes") {
                ForEach(0..<5) { i in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Note from Chapter \(i + 1)")
                            .font(ResonanceTypography.sansBody())
                        Text("Sample note content excerpt...")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                    // Enable drag for note reordering
                    .onDrag {
                        NSItemProvider(object: "Note \(i)" as NSString)
                    }
                }
            }
        }
        .navigationTitle("Notes")
    }

    private var bookmarksListContent: some View {
        List {
            Section("Bookmarks") {
                ForEach(0..<3) { i in
                    HStack {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(Color.resonanceGoldPrimary)
                        VStack(alignment: .leading) {
                            Text("Page \((i + 1) * 37)")
                                .font(ResonanceTypography.sansBody())
                            Text("Chapter \(i + 1)")
                                .font(ResonanceTypography.sansCaption2())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
    }

    private var settingsContent: some View {
        List {
            Section("Reading") {
                Label("Typography", systemImage: "textformat.size")
                Label("Theme", systemImage: "circle.lefthalf.filled")
                Label("Reading Mode", systemImage: "book")
            }
            Section("Audio") {
                Label("Playback Speed", systemImage: "gauge.with.dots.needle.33percent")
                Label("Auto-Sleep Timer", systemImage: "moon")
            }
            Section("Account") {
                Label("Profile", systemImage: "person.circle")
                Label("Subscription", systemImage: "creditcard")
            }
        }
        .navigationTitle("Settings")
    }

    // MARK: Helpers

    private var sampleChapters: [Chapter] {
        [
            Chapter(id: "ch0", title: "Foreword", subtitle: "Setting the Stage", pageRange: 1...12, duration: 900, isCompleted: true),
            Chapter(id: "ch1", title: "Chapter 1: The Integral Vision", subtitle: "Seeing the Whole", pageRange: 13...48, duration: 2700, isCompleted: true),
            Chapter(id: "ch2", title: "Chapter 2: Four Quadrants", subtitle: "Maps of Reality", pageRange: 49...96, duration: 3600, isCompleted: false),
            Chapter(id: "ch3", title: "Chapter 3: Levels of Development", subtitle: "The Great Unfolding", pageRange: 97...140, duration: 3200, isCompleted: false),
            Chapter(id: "ch4", title: "Chapter 4: Lines of Intelligence", subtitle: "Multiple Streams", pageRange: 141...182, duration: 2900, isCompleted: false),
        ]
    }
}

// MARK: - Placeholder Detail Views

struct LearnDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                QuadrantMappingCard(title: "Map a current situation using the four quadrants")
                ReflectionQuestionCard(
                    question: "What level of development is most active in your life right now?",
                    prompt: "Consider how you make meaning and relate to complexity."
                )
                SomaticPracticeCard(
                    title: "Spatial Attunement",
                    instruction: "Expand your awareness to hold the full dimensionality of this moment.",
                    durationSeconds: 180
                )
            }
            .padding(24)
        }
        .resonanceBackground()
    }
}

struct NotesDetailView: View {
    var body: some View {
        VStack {
            Text("Select a note to view")
                .font(ResonanceTypography.sansBody())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .resonanceBackground()
    }
}

struct BookmarksDetailView: View {
    var body: some View {
        VStack {
            Text("Select a bookmark to navigate")
                .font(ResonanceTypography.sansBody())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .resonanceBackground()
    }
}

struct SettingsDetailView: View {
    var body: some View {
        VStack {
            Text("Select a setting to configure")
                .font(ResonanceTypography.sansBody())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .resonanceBackground()
    }
}

// MARK: - Preview

#if DEBUG
struct LuminousIPadApp_Previews: PreviewProvider {
    static var previews: some View {
        IPadRootView()
            .environmentObject(IPadAppState())
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
#endif
