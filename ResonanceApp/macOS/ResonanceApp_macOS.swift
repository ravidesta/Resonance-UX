// ResonanceApp_macOS.swift
// Resonance — Design for the Exhale
//
// macOS entry point with native window chrome, menu bar, and keyboard shortcuts.

import SwiftUI

#if os(macOS)
@main
struct ResonanceApp_macOS: App {
    @State private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup("Resonance") {
            ContentView(themeManager: themeManager)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1200, height: 800)
        .commands {
            // Custom menu commands
            CommandGroup(after: .newItem) {
                Button("New Writing") {
                    NotificationCenter.default.post(name: .resonanceNewDocument, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }

            CommandMenu("View") {
                Button("Toggle Deep Rest") {
                    themeManager.toggle()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])

                Divider()

                Button("Focus Mode") {
                    NotificationCenter.default.post(name: .resonanceFocusMode, object: nil)
                }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
            }

            CommandMenu("Flow") {
                ForEach(ResonanceTab.allCases) { tab in
                    Button(tab.rawValue) {
                        NotificationCenter.default.post(
                            name: .resonanceNavigate,
                            object: tab.rawValue
                        )
                    }
                }
            }
        }

        #if os(macOS)
        // Menu bar extra — quick phase glance
        MenuBarExtra("Resonance", systemImage: "leaf.fill") {
            MenuBarView(themeManager: themeManager)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}

// MARK: - Menu Bar View

struct MenuBarView: View {
    let themeManager: ThemeManager
    private let currentPhase = DailyPhase.current()

    var theme: ResonanceTheme { themeManager.currentTheme }

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.spacingM) {
            // Current phase
            HStack(spacing: 10) {
                Image(systemName: currentPhase.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(currentPhase.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentPhase.rawValue)
                        .font(ResonanceFont.headlineMedium)
                        .foregroundStyle(theme.textMain)

                    Text(currentPhase.description)
                        .font(ResonanceFont.caption)
                        .foregroundStyle(theme.textMuted)
                }
            }

            Divider()

            // Quick tasks
            Text("NEXT UP")
                .font(ResonanceFont.labelSmall)
                .tracking(1.5)
                .foregroundStyle(theme.textLight)

            ForEach(PhaseEvent.sampleEvents.prefix(3)) { event in
                HStack(spacing: 8) {
                    Circle()
                        .fill(event.isCompleted ? theme.goldPrimary : theme.borderLight)
                        .frame(width: 6, height: 6)

                    Text(event.title)
                        .font(ResonanceFont.bodySmall)
                        .foregroundStyle(theme.textMain)
                        .lineLimit(1)

                    Spacer()

                    Text(event.time)
                        .font(ResonanceFont.caption)
                        .foregroundStyle(theme.textLight)
                }
            }

            Divider()

            DeepRestToggle(themeManager: themeManager)
        }
        .padding(ResonanceTheme.spacingM)
        .frame(width: 280)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let resonanceNewDocument = Notification.Name("resonanceNewDocument")
    static let resonanceFocusMode = Notification.Name("resonanceFocusMode")
    static let resonanceNavigate = Notification.Name("resonanceNavigate")
}
#endif
