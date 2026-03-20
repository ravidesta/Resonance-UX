// ResonanceMacApp.swift
// Resonance UX — macOS Native App
//
// A multi-window macOS experience with sidebar navigation,
// 3-pane writer layout, provider dashboard, and menu bar
// presence indicator. Designed for extended deep work sessions.

import SwiftUI

// MARK: - macOS App Entry Point

@main
struct ResonanceMacApp: App {
    @AppStorage("deepRestMode") private var deepRestMode = false
    @StateObject private var appState = MacAppState()

    var body: some Scene {
        // Main application window
        WindowGroup("Resonance") {
            MacContentView()
                .environment(\.isDeepRestMode, deepRestMode)
                .environmentObject(appState)
                .frame(minWidth: 1000, minHeight: 700)
                .onAppear { configureWindowAppearance() }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            resonanceCommands
        }

        // Dedicated Writer window
        WindowGroup("Writing Sanctuary", id: "writer") {
            MacWriterView()
                .environment(\.isDeepRestMode, deepRestMode)
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))

        // Menu bar status
        MenuBarExtra {
            MenuBarContent(appState: appState, deepRestMode: $deepRestMode)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: appState.menuBarIcon)
                Text(String(format: "%.1f", appState.currentFrequency))
            }
        }
        .menuBarExtraStyle(.window)

        // Settings
        Settings {
            MacSettingsView(deepRestMode: $deepRestMode)
                .environmentObject(appState)
        }
    }

    // MARK: - Commands (Keyboard Shortcuts)

    @CommandsBuilder
    private var resonanceCommands: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Writing") {
                appState.createNewDocument()
            }
            .keyboardShortcut("n", modifiers: [.command])

            Button("New Task") {
                appState.showNewTaskSheet = true
            }
            .keyboardShortcut("t", modifiers: [.command])

            Divider()

            Button("Toggle Focus Mode") {
                withAnimation(ResonanceTheme.Animation.calm) {
                    appState.isInFocusMode.toggle()
                }
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])

            Button("Toggle Deep Rest") {
                deepRestMode.toggle()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
        }

        CommandGroup(after: .sidebar) {
            Button("Show Daily Flow") {
                appState.selectedSection = .flow
            }
            .keyboardShortcut("1", modifiers: .command)

            Button("Show Writer") {
                appState.selectedSection = .writer
            }
            .keyboardShortcut("2", modifiers: .command)

            Button("Show Inner Circle") {
                appState.selectedSection = .innerCircle
            }
            .keyboardShortcut("3", modifiers: .command)

            Button("Show Provider Dashboard") {
                appState.selectedSection = .provider
            }
            .keyboardShortcut("4", modifiers: .command)

            Button("Show Wellness") {
                appState.selectedSection = .wellness
            }
            .keyboardShortcut("5", modifiers: .command)
        }

        CommandMenu("Resonance") {
            Button("Luminize Selection") {
                appState.triggerLuminize = true
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])

            Button("RSD Lightning Protocol") {
                appState.showRSDProtocol = true
            }
            .keyboardShortcut("r", modifiers: [.command, .shift, .option])

            Divider()

            Picker("Intentional Status", selection: $appState.intentionalStatus) {
                ForEach(MacIntentionalStatus.allCases) { status in
                    Text(status.rawValue).tag(status)
                }
            }
        }
    }

    private func configureWindowAppearance() {
        // Native macOS appearance tuning
    }
}

// MARK: - Mac App State

class MacAppState: ObservableObject {
    @Published var selectedSection: AppSection = .flow
    @Published var intentionalStatus: MacIntentionalStatus = .openConnect
    @Published var isInFocusMode: Bool = false
    @Published var currentFrequency: Double = 7.2
    @Published var showNewTaskSheet: Bool = false
    @Published var showRSDProtocol: Bool = false
    @Published var triggerLuminize: Bool = false
    @Published var documents: [MacDocument] = MacDocument.samples
    @Published var selectedDocumentId: UUID?

    var menuBarIcon: String {
        switch intentionalStatus {
        case .deepWork:    return "eye.slash"
        case .recharging:  return "moon.zzz"
        case .openConnect: return "hand.wave"
        case .inFlow:      return "wind"
        case .offline:     return "leaf"
        }
    }

    func createNewDocument() {
        let doc = MacDocument(title: "Untitled", content: "", createdAt: Date(), updatedAt: Date())
        documents.insert(doc, at: 0)
        selectedDocumentId = doc.id
    }
}

enum AppSection: String, CaseIterable, Identifiable {
    case flow        = "Daily Flow"
    case writer      = "Writer"
    case innerCircle = "Inner Circle"
    case provider    = "Provider"
    case wellness    = "Wellness"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .flow:        return "circle.hexagongrid"
        case .writer:      return "pencil.and.outline"
        case .innerCircle: return "envelope.open"
        case .provider:    return "stethoscope"
        case .wellness:    return "heart.circle"
        }
    }
}

enum MacIntentionalStatus: String, CaseIterable, Identifiable {
    case deepWork    = "Deep work"
    case recharging  = "Recharging"
    case openConnect = "Open to connect"
    case inFlow      = "In flow"
    case offline     = "Offline"

    var id: String { rawValue }
}

// MARK: - Mac Document

struct MacDocument: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool = false
    var tags: [String] = []

    var wordCount: Int { content.split(separator: " ").count }
    var readingTime: Int { max(1, wordCount / 238) }
}

// MARK: - Main Content View

struct MacContentView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: MacAppState

    var body: some View {
        NavigationSplitView {
            sidebarView
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } detail: {
            detailView
        }
        .background(isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base)
    }

    // MARK: - Sidebar

    private var sidebarView: some View {
        List(selection: $appState.selectedSection) {
            Section("Navigate") {
                ForEach(AppSection.allCases) { section in
                    Label(section.rawValue, systemImage: section.icon)
                        .tag(section)
                }
            }

            Section("Status") {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: 0xC5A059))
                        .frame(width: 8, height: 8)
                    Text(appState.intentionalStatus.rawValue)
                        .font(ResonanceTheme.Typography.bodySmall)
                }

                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.caption)
                    Text("Frequency: \(String(format: "%.1f", appState.currentFrequency))")
                        .font(ResonanceTheme.Typography.bodySmall)
                }
            }

            if appState.selectedSection == .writer {
                Section("Library") {
                    ForEach(appState.documents) { doc in
                        Button {
                            appState.selectedDocumentId = doc.id
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(doc.title.isEmpty ? "Untitled" : doc.title)
                                    .font(ResonanceTheme.Typography.bodySmall)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                Text("\(doc.wordCount) words")
                                    .font(ResonanceTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Detail

    @ViewBuilder
    private var detailView: some View {
        switch appState.selectedSection {
        case .flow:
            MacDailyFlowView()
        case .writer:
            MacWriterView()
        case .innerCircle:
            MacInnerCircleView()
        case .provider:
            ProviderDashboardView()
        case .wellness:
            MacWellnessView()
        }
    }
}

// MARK: - Mac Daily Flow View

struct MacDailyFlowView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xl) {
                Text("Daily Rhythms")
                    .font(ResonanceTheme.Typography.displayLarge)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                Text("Energy-aware task management aligned with your circadian rhythm.")
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)

                // Phase cards in a horizontal grid on macOS
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: ResonanceTheme.Spacing.md) {
                    ForEach(DailyPhaseKind.allCases) { phase in
                        MacPhaseCard(phase: phase, isDeepRest: isDeepRest)
                    }
                }
            }
            .padding(ResonanceTheme.Spacing.xl)
        }
    }
}

struct MacPhaseCard: View {
    let phase: DailyPhaseKind
    let isDeepRest: Bool

    var body: some View {
        VStack(spacing: ResonanceTheme.Spacing.md) {
            Image(systemName: phase.icon)
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(phase.color)

            Text(phase.label)
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

            Text(phase.timeRange)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)

            Text(phase.intention)
                .font(ResonanceTheme.Typography.bodySmall)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(ResonanceTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .fill((isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface))
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                        .stroke(phase.color.opacity(0.15))
                )
        )
    }
}

// MARK: - Mac Writer View (3-Pane)

struct MacWriterView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: MacAppState

    @State private var editorContent: String = ""
    @State private var editorTitle: String = ""

    private var selectedDocument: MacDocument? {
        appState.documents.first { $0.id == appState.selectedDocumentId }
    }

    var body: some View {
        HSplitView {
            // Left: Library
            if !appState.isInFocusMode {
                writerLibrary
                    .frame(minWidth: 200, idealWidth: 240, maxWidth: 300)
            }

            // Center: Editor
            writerEditor
                .frame(minWidth: 400)

            // Right: Preview (optional)
            if !appState.isInFocusMode, let doc = selectedDocument, !doc.content.isEmpty {
                writerPreview(doc)
                    .frame(minWidth: 250, idealWidth: 300, maxWidth: 400)
            }
        }
        .onAppear {
            if let doc = selectedDocument {
                editorTitle = doc.title
                editorContent = doc.content
            }
        }
        .onChange(of: appState.selectedDocumentId) { _ in
            if let doc = selectedDocument {
                editorTitle = doc.title
                editorContent = doc.content
            }
        }
    }

    private var writerLibrary: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Library")
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
                Spacer()
                Button {
                    appState.createNewDocument()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(ResonanceTheme.Light.gold)
                }
                .buttonStyle(.plain)
            }
            .padding(ResonanceTheme.Spacing.md)

            Divider()

            List(appState.documents, selection: $appState.selectedDocumentId) { doc in
                VStack(alignment: .leading, spacing: 4) {
                    Text(doc.title.isEmpty ? "Untitled" : doc.title)
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    HStack(spacing: ResonanceTheme.Spacing.sm) {
                        Text(doc.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        Text("\(doc.wordCount) words")
                    }
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(.secondary)
                }
                .tag(doc.id)
            }
            .listStyle(.inset)
        }
    }

    private var writerEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !appState.isInFocusMode {
                // Title
                TextField("Untitled", text: $editorTitle)
                    .font(ResonanceTheme.Typography.displayLarge)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, ResonanceTheme.Spacing.xl)
                    .padding(.top, ResonanceTheme.Spacing.xl)
                    .onChange(of: editorTitle) { newVal in
                        updateDocument()
                    }
            }

            TextEditor(text: $editorContent)
                .font(appState.isInFocusMode
                    ? ResonanceTheme.Typography.serif(22, weight: .regular)
                    : ResonanceTheme.Typography.serif(18, weight: .regular))
                .lineSpacing(appState.isInFocusMode ? 14 : 8)
                .padding(.horizontal, appState.isInFocusMode ? ResonanceTheme.Spacing.xxxl : ResonanceTheme.Spacing.xl)
                .padding(.top, ResonanceTheme.Spacing.md)
                .scrollContentBackground(.hidden)
                .onChange(of: editorContent) { _ in
                    updateDocument()
                }

            // Stats bar
            if !appState.isInFocusMode {
                Divider()
                HStack(spacing: ResonanceTheme.Spacing.lg) {
                    Text("\(editorContent.split(separator: " ").count) words")
                    Text("\(max(1, editorContent.split(separator: " ").count / 238)) min read")
                    Spacer()
                    if appState.triggerLuminize {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                    Button("Luminize") {
                        appState.triggerLuminize = true
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(ResonanceTheme.Light.gold)
                }
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, ResonanceTheme.Spacing.xl)
                .padding(.vertical, ResonanceTheme.Spacing.sm)
            }
        }
    }

    private func writerPreview(_ doc: MacDocument) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
                Text("Preview")
                    .font(ResonanceTheme.Typography.overline)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
                    .tracking(1.2)

                Text(editorTitle.isEmpty ? "Untitled" : editorTitle)
                    .font(ResonanceTheme.Typography.displayMedium)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                Text(editorContent)
                    .font(ResonanceTheme.Typography.serif(16, weight: .regular))
                    .lineSpacing(8)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
            }
            .padding(ResonanceTheme.Spacing.xl)
        }
    }

    private func updateDocument() {
        guard let id = appState.selectedDocumentId,
              let index = appState.documents.firstIndex(where: { $0.id == id }) else { return }
        appState.documents[index].title = editorTitle
        appState.documents[index].content = editorContent
        appState.documents[index].updatedAt = Date()
    }
}

// MARK: - Mac Inner Circle (Placeholder)

struct MacInnerCircleView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest

    var body: some View {
        VStack {
            Text("Inner Circle")
                .font(ResonanceTheme.Typography.displayLarge)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
            Text("Intentional communication, coming to macOS.")
                .font(ResonanceTheme.Typography.bodyLarge)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Mac Wellness (Placeholder)

struct MacWellnessView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest

    var body: some View {
        VStack {
            Text("Wellness Holarchy")
                .font(ResonanceTheme.Typography.displayLarge)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
            Text("Patient-centered care, adapted for desktop workflows.")
                .font(ResonanceTheme.Typography.bodyLarge)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Menu Bar Content

struct MenuBarContent: View {
    @ObservedObject var appState: MacAppState
    @Binding var deepRestMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                Text("Resonance")
                    .font(ResonanceTheme.Typography.headlineMed)
                Spacer()
                Text(String(format: "%.1f", appState.currentFrequency))
                    .font(ResonanceTheme.Typography.headlineLarge)
                    .foregroundColor(ResonanceTheme.Light.gold)
            }

            Divider()

            Text("Intentional Status")
                .font(ResonanceTheme.Typography.overline)
                .foregroundColor(.secondary)
                .tracking(1.0)

            ForEach(MacIntentionalStatus.allCases) { status in
                Button {
                    appState.intentionalStatus = status
                } label: {
                    HStack {
                        Text(status.rawValue)
                            .font(ResonanceTheme.Typography.bodyMedium)
                        Spacer()
                        if appState.intentionalStatus == status {
                            Image(systemName: "checkmark")
                                .foregroundColor(ResonanceTheme.Light.gold)
                        }
                    }
                }
                .buttonStyle(.plain)
            }

            Divider()

            Toggle("Deep Rest Mode", isOn: $deepRestMode)
                .font(ResonanceTheme.Typography.bodyMedium)

            Toggle("Focus Mode", isOn: $appState.isInFocusMode)
                .font(ResonanceTheme.Typography.bodyMedium)

            Divider()

            Button("Quit Resonance") {
                NSApplication.shared.terminate(nil)
            }
            .font(ResonanceTheme.Typography.bodyMedium)
        }
        .padding(ResonanceTheme.Spacing.md)
        .frame(width: 260)
    }
}

// MARK: - Settings

struct MacSettingsView: View {
    @Binding var deepRestMode: Bool
    @EnvironmentObject private var appState: MacAppState

    var body: some View {
        TabView {
            Form {
                Section("Appearance") {
                    Toggle("Deep Rest (Dark) Mode", isOn: $deepRestMode)
                    Picker("Default Section", selection: $appState.selectedSection) {
                        ForEach(AppSection.allCases) { section in
                            Text(section.rawValue).tag(section)
                        }
                    }
                }

                Section("Writer") {
                    Toggle("Focus Mode on Launch", isOn: .constant(false))
                    Toggle("Auto-save every 30 seconds", isOn: .constant(true))
                }

                Section("Notifications") {
                    Toggle("Calm notifications only", isOn: .constant(true))
                    Toggle("Batch during Deep Work", isOn: .constant(true))
                }
            }
            .tabItem { Label("General", systemImage: "gear") }
            .frame(width: 450, height: 300)
        }
    }
}

// MARK: - Sample Data

extension MacDocument {
    static let samples: [MacDocument] = [
        MacDocument(title: "On Digital Calm", content: "The screen glows softly in the pre-dawn light. There is no urgency here — no red badges, no notification counts, no algorithmic anxiety. Just a clean surface waiting for thought.", createdAt: Date(), updatedAt: Date(), isFavorite: true, tags: ["Philosophy"]),
        MacDocument(title: "Nervous System as Interface", content: "What if we designed technology the way a skilled therapist holds space? Not pushing, not pulling — simply creating conditions for the nervous system to find its own regulation.", createdAt: Date(), updatedAt: Date(), tags: ["Design"]),
        MacDocument(title: "Retreat Notes", content: "Day one. The group arrived in varying states of depletion.", createdAt: Date(), updatedAt: Date()),
    ]
}
