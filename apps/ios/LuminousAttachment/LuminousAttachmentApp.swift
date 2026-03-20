// LuminousAttachmentApp.swift
// Luminous Attachment — Resonance UX
// Main application entry point with custom tab bar and theme management

import SwiftUI

// MARK: - Theme Manager

@Observable
final class ThemeManager {
    var colorScheme: ColorScheme? = nil
    var useSystemAppearance: Bool = true
    var accentHue: Double = 0.12 // gold hue

    var effectiveColorScheme: ColorScheme? {
        useSystemAppearance ? nil : colorScheme
    }

    // Resonance palette shortcuts
    static let green900 = Color(hex: "0A1C14")
    static let green800 = Color(hex: "122E21")
    static let goldPrimary = Color(hex: "C5A059")
    static let goldLight = Color(hex: "E6D0A1")
    static let bgLight = Color(hex: "FAFAF8")
    static let bgDark = Color(hex: "05100B")
}

// MARK: - App Entry

@main
struct LuminousAttachmentApp: App {
    @State private var theme = ThemeManager()
    @State private var selectedTab: AppTab = .home
    @State private var userProfile = UserProfile()
    @State private var audiobookPlayer = AudiobookPlayer()

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                // Main content
                TabContentView(
                    selectedTab: $selectedTab,
                    userProfile: userProfile,
                    audiobookPlayer: audiobookPlayer,
                    theme: theme
                )

                // Custom tab bar
                ResonanceTabBar(
                    selectedTab: $selectedTab,
                    theme: theme
                )
            }
            .environment(theme)
            .environment(userProfile)
            .environment(audiobookPlayer)
            .preferredColorScheme(theme.effectiveColorScheme)
            .onAppear {
                userProfile.updateStreak()
            }
        }
    }
}

// MARK: - Tab Content Router

struct TabContentView: View {
    @Binding var selectedTab: AppTab
    let userProfile: UserProfile
    let audiobookPlayer: AudiobookPlayer
    let theme: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Full-screen background
            backgroundColor.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    NavigationStack {
                        HomeView()
                    }
                case .learn:
                    NavigationStack {
                        LearnView()
                    }
                case .journal:
                    NavigationStack {
                        JournalView()
                    }
                case .coach:
                    NavigationStack {
                        CoachView()
                    }
                case .library:
                    NavigationStack {
                        LibraryView()
                    }
                case .share:
                    NavigationStack {
                        SocialShareView()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80) // Space for custom tab bar
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? ThemeManager.bgDark : ThemeManager.bgLight
    }
}

// MARK: - Library Placeholder (combines Learn + EBook)

struct LibraryView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Library")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(ResonanceColors.text(for: colorScheme))

                    Text("Everything you need for your healing journey")
                        .font(.subheadline)
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Bookmarks section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Bookmarks", systemImage: "bookmark.fill")
                        .font(.headline)
                        .foregroundStyle(ResonanceColors.goldPrimary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<4) { i in
                                BookmarkCardView(chapterNumber: i + 1)
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Highlights section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Highlights", systemImage: "highlighter")
                        .font(.headline)
                        .foregroundStyle(ResonanceColors.goldPrimary)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        HighlightRow(text: "Your attachment style is not your destiny.", chapter: 1)
                        HighlightRow(text: "The body remembers what the mind forgets.", chapter: 3)
                        HighlightRow(text: "Repair is the heartbeat of secure love.", chapter: 9)
                    }
                    .padding(.horizontal)
                }

                // Reading stats
                VStack(spacing: 16) {
                    Text("Reading Progress")
                        .font(.headline)
                        .foregroundStyle(ResonanceColors.text(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 20) {
                        StatBadge(value: "3", label: "Chapters\nRead", icon: "book.closed.fill")
                        StatBadge(value: "12", label: "Bookmarks\nSaved", icon: "bookmark.fill")
                        StatBadge(value: "28", label: "Highlights\nMade", icon: "highlighter")
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ResonanceColors.surface(for: colorScheme))
                        .shadow(color: .black.opacity(0.05), radius: 10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BookmarkCardView: View {
    let chapterNumber: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "bookmark.fill")
                .font(.title2)
                .foregroundStyle(ResonanceColors.goldPrimary)

            Text("Chapter \(chapterNumber)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ResonanceColors.text(for: colorScheme))

            Text("Page \(chapterNumber * 12 + 3)")
                .font(.caption2)
                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
        }
        .padding()
        .frame(width: 120, height: 120)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(ResonanceColors.surface(for: colorScheme))
                .shadow(color: .black.opacity(0.05), radius: 8)
        }
    }
}

struct HighlightRow: View {
    let text: String
    let chapter: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(ResonanceColors.goldPrimary)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(text)\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(ResonanceColors.text(for: colorScheme))

                Text("Chapter \(chapter)")
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
            }

            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(ResonanceColors.surface(for: colorScheme))
        }
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(ResonanceColors.goldPrimary)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(ResonanceColors.text(for: colorScheme))

            Text(label)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Custom Tab Bar

struct ResonanceTabBar: View {
    @Binding var selectedTab: AppTab
    let theme: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    private let tabs = AppTab.allCases

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background {
            ZStack {
                // Blur background
                Rectangle()
                    .fill(.ultraThinMaterial)

                // Subtle top border
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ResonanceColors.goldPrimary.opacity(0.3),
                                    ResonanceColors.goldPrimary.opacity(0.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 0.5)
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func tabButton(for tab: AppTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(ResonanceColors.goldPrimary.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? ResonanceColors.goldPrimary
                                : ResonanceColors.textSecondary(for: colorScheme)
                        )
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 40)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected
                            ? ResonanceColors.goldPrimary
                            : ResonanceColors.textSecondary(for: colorScheme)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
    }
}

// MARK: - Previews

#Preview("App") {
    let theme = ThemeManager()
    let user = UserProfile()
    let player = AudiobookPlayer()

    ZStack(alignment: .bottom) {
        TabContentView(
            selectedTab: .constant(.home),
            userProfile: user,
            audiobookPlayer: player,
            theme: theme
        )
        ResonanceTabBar(selectedTab: .constant(.home), theme: theme)
    }
    .environment(theme)
    .environment(user)
    .environment(player)
}
