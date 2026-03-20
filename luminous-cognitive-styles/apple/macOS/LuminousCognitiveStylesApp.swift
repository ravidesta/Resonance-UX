// LuminousCognitiveStylesApp.swift
// Luminous Cognitive Styles™ — macOS
// macOS app with sidebar navigation and window management

import SwiftUI

@main
struct LuminousCognitiveStylesMacApp: App {
    @StateObject private var viewModel = AssessmentViewModel()

    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
                .frame(minWidth: 900, idealWidth: 1100, minHeight: 600, idealHeight: 750)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1100, height: 750)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu("Assessment") {
                Button("Quick Profile") {
                    NotificationCenter.default.post(name: .navigateToQuickProfile, object: nil)
                }
                .keyboardShortcut("q", modifiers: [.command, .shift])

                Button("Full DSR Assessment") {
                    NotificationCenter.default.post(name: .navigateToFullAssessment, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }

            CommandMenu("View") {
                Button("Dashboard") {
                    NotificationCenter.default.post(name: .navigateToDashboard, object: nil)
                }
                .keyboardShortcut("1", modifiers: .command)

                Button("Assessment") {
                    NotificationCenter.default.post(name: .navigateToAssessment, object: nil)
                }
                .keyboardShortcut("2", modifiers: .command)

                Button("Book") {
                    NotificationCenter.default.post(name: .navigateToBook, object: nil)
                }
                .keyboardShortcut("3", modifiers: .command)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToQuickProfile = Notification.Name("navigateToQuickProfile")
    static let navigateToFullAssessment = Notification.Name("navigateToFullAssessment")
    static let navigateToDashboard = Notification.Name("navigateToDashboard")
    static let navigateToAssessment = Notification.Name("navigateToAssessment")
    static let navigateToBook = Notification.Name("navigateToBook")
}

// MARK: - Main Content View

struct MacContentView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedSection: MacSection = .dashboard
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MacSidebarView(selectedSection: $selectedSection)
                .environmentObject(viewModel)
        } detail: {
            Group {
                switch selectedSection {
                case .dashboard:
                    MacDashboardView()
                case .quickProfile:
                    MacQuickProfileView()
                case .fullAssessment:
                    MacAssessmentView()
                case .book:
                    MacBookView()
                case .coaching:
                    MacCoachingView()
                case .history:
                    MacHistoryView()
                case .settings:
                    MacSettingsView()
                }
            }
            .environmentObject(viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToDashboard)) { _ in selectedSection = .dashboard }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToAssessment)) { _ in selectedSection = .quickProfile }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToBook)) { _ in selectedSection = .book }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToQuickProfile)) { _ in selectedSection = .quickProfile }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToFullAssessment)) { _ in selectedSection = .fullAssessment }
    }
}

// MARK: - Sections

enum MacSection: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case quickProfile = "Quick Profile"
    case fullAssessment = "Full Assessment"
    case book = "Book"
    case coaching = "Coaching"
    case history = "History"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .quickProfile: return "bolt.fill"
        case .fullAssessment: return "doc.text.magnifyingglass"
        case .book: return "book.fill"
        case .coaching: return "message.fill"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gear"
        }
    }

    var group: String {
        switch self {
        case .dashboard: return "Overview"
        case .quickProfile, .fullAssessment: return "Assessment"
        case .book, .coaching: return "Learn"
        case .history, .settings: return "Account"
        }
    }
}
