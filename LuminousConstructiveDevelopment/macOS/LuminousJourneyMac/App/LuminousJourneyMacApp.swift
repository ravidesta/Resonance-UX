// MARK: - Luminous Journey™ macOS App
// Native SwiftUI • Sidebar navigation • Multi-pane reading experience
// Optimized for deep focus work at a desk

import SwiftUI

@main
struct LuminousJourneyMacApp: App {
    @StateObject private var appState = MacAppState()

    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(appState)
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Journal Entry") { appState.showNewJournalEntry = true }
                    .keyboardShortcut("n", modifiers: .command)
                Button("New Guide Session") { appState.selectedSection = .guide }
                    .keyboardShortcut("g", modifiers: [.command, .shift])
            }
            CommandMenu("Reader") {
                Button("Increase Font Size") { appState.readerFontSize += 1 }
                    .keyboardShortcut("+", modifiers: .command)
                Button("Decrease Font Size") { appState.readerFontSize -= 1 }
                    .keyboardShortcut("-", modifiers: .command)
                Divider()
                Toggle("Deep Rest Mode", isOn: $appState.isDeepRest)
                    .keyboardShortcut("d", modifiers: [.command, .shift])
                Divider()
                Button("Switch to Audiobook") { appState.selectedSection = .listen }
                    .keyboardShortcut("l", modifiers: [.command, .shift])
            }
        }

        // Settings window
        Settings {
            MacSettingsView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State

final class MacAppState: ObservableObject {
    @Published var selectedSection: MacSection = .home
    @Published var isDeepRest: Bool = false
    @Published var readerFontSize: CGFloat = 17
    @Published var showNewJournalEntry: Bool = false
    @Published var sidebarWidth: CGFloat = 240

    enum MacSection: String, CaseIterable, Identifiable {
        case home       = "Home"
        case learn      = "Read"
        case listen     = "Listen"
        case practice   = "Practice"
        case journal    = "Journal"
        case guide      = "Guide"
        case community  = "Community"
        case settings   = "Settings"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .home:      return "house"
            case .learn:     return "book"
            case .listen:    return "headphones"
            case .practice:  return "figure.mind.and.body"
            case .journal:   return "pencil.line"
            case .guide:     return "bubble.left.and.text.bubble.right"
            case .community: return "person.3"
            case .settings:  return "gear"
            }
        }
    }
}

// MARK: - Main Content View (3-column layout)

struct MacContentView: View {
    @EnvironmentObject var appState: MacAppState

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar
            MacSidebar()
                .frame(minWidth: 200)
        } content: {
            // Detail view based on selection
            switch appState.selectedSection {
            case .home:
                MacHomeView()
            case .learn:
                MacReaderView()
            case .listen:
                MacAudiobookView()
            case .practice:
                MacPracticeView()
            case .journal:
                MacJournalView()
            case .guide:
                MacGuideView()
            case .community:
                MacCommunityView()
            case .settings:
                MacSettingsView()
            }
        } detail: {
            // Context panel (companion content)
            MacContextPanel()
        }
        .preferredColorScheme(appState.isDeepRest ? .dark : nil)
    }
}

// MARK: - Sidebar

struct MacSidebar: View {
    @EnvironmentObject var appState: MacAppState

    var body: some View {
        List(selection: $appState.selectedSection) {
            Section("Journey") {
                ForEach([MacAppState.MacSection.home, .learn, .listen], id: \.self) { section in
                    Label(section.rawValue, systemImage: section.icon)
                        .tag(section)
                }
            }

            Section("Practice") {
                ForEach([MacAppState.MacSection.practice, .journal, .guide], id: \.self) { section in
                    Label(section.rawValue, systemImage: section.icon)
                        .tag(section)
                }
            }

            Section("Connect") {
                Label(MacAppState.MacSection.community.rawValue,
                      systemImage: MacAppState.MacSection.community.icon)
                    .tag(MacAppState.MacSection.community)
            }

            Section {
                // Current somatic season indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: "4A9A6A"))
                        .frame(width: 10, height: 10)
                    Text("Emergence")
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(.secondary)
                }

                // Audiobook mini player
                if true /* audiobook active */ {
                    HStack(spacing: 8) {
                        Image(systemName: "headphones")
                            .foregroundColor(Color(hex: "C5A059"))
                        VStack(alignment: .leading) {
                            Text("Ch. 2")
                                .font(.custom("Manrope", size: 11))
                                .foregroundColor(.secondary)
                            Text("Subject-Object")
                                .font(.custom("Manrope", size: 12))
                        }
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section {
                // Deep rest toggle
                Toggle(isOn: $appState.isDeepRest) {
                    Label("Deep Rest", systemImage: "moon")
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Luminous")
    }
}

// MARK: - Context Panel (Right sidebar — companion content)

struct MacContextPanel: View {
    @EnvironmentObject var appState: MacAppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch appState.selectedSection {
                case .learn:
                    // Show highlights, bookmarks, and related practices
                    Text("Highlights & Notes")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text("No highlights yet. Select text while reading to highlight.")
                        .font(.custom("Manrope", size: 13))
                        .foregroundColor(.secondary)

                    Divider()

                    Text("Related Practices")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text("Somatic Witness Practice")
                        .font(.custom("Manrope", size: 14))
                    Text("Subject Scan")
                        .font(.custom("Manrope", size: 14))

                case .journal:
                    Text("Somatic Seasons")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    // Season timeline visualization

                case .guide:
                    Text("Guide Context")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text("Your Guide draws on your journal entries, reading progress, and assessment history.")
                        .font(.custom("Manrope", size: 13))
                        .foregroundColor(.secondary)

                default:
                    Text("Resonance Ecosystem")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text("Connected to Daily Flow, Resonance, Writer")
                        .font(.custom("Manrope", size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Placeholder Views

struct MacHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Luminous Journey")
                    .font(.custom("Cormorant Garamond", size: 48))
                    .fontWeight(.light)
                Text("Your developmental companion — reading, listening, practicing, reflecting.")
                    .font(.custom("Manrope", size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(40)
        }
    }
}

struct MacReaderView: View {
    @EnvironmentObject var appState: MacAppState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Chapter 1: Theoretical Foundations")
                    .font(.custom("Cormorant Garamond", size: 36))
                Text("Content renders here at \(Int(appState.readerFontSize))pt with 760px max-width...")
                    .font(.custom("Manrope", size: appState.readerFontSize))
                    .frame(maxWidth: 760)
            }
            .padding(40)
        }
    }
}

struct MacAudiobookView: View { var body: some View { Text("Audiobook Player — macOS") } }
struct MacPracticeView: View { var body: some View { Text("Practice Library — macOS") } }
struct MacJournalView: View { var body: some View { Text("Journal — macOS") } }
struct MacGuideView: View { var body: some View { Text("Guide — macOS") } }
struct MacCommunityView: View { var body: some View { Text("Community — macOS") } }
struct MacSettingsView: View { var body: some View { Text("Settings") } }

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
