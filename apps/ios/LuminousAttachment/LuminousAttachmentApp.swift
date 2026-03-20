// LuminousAttachmentApp.swift
// Luminous Attachment — Resonance UX
// Main app entry point with custom Resonance-themed tab navigation

import SwiftUI

// MARK: - Theme Manager

@Observable
final class ThemeManager {
    var colorScheme: ColorScheme? = nil
    var accentHue: Double = 0.12

    var effectiveScheme: ColorScheme {
        colorScheme ?? .dark
    }

    var bgLight: Color { Color(hex: "FAFAF8") }
    var bgDark: Color { Color(hex: "05100B") }

    func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? bgDark : bgLight
    }
}

// MARK: - App Entry

@main
struct LuminousAttachmentApp: App {
    @State private var theme = ThemeManager()
    @State private var selectedTab: AppTab = .home
    @State private var userProfile = UserProfile()
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                // Background
                theme.background(for: theme.effectiveScheme)
                    .ignoresSafeArea()

                // Tab Content
                TabContentView(
                    selectedTab: $selectedTab,
                    userProfile: userProfile,
                    theme: theme
                )
                .padding(.bottom, 80)

                // Custom Tab Bar
                ResonanceTabBar(
                    selectedTab: $selectedTab,
                    theme: theme
                )
            }
            .preferredColorScheme(theme.colorScheme)
            .environment(theme)
            .environment(userProfile)
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
    let theme: ThemeManager

    var body: some View {
        ZStack {
            switch selectedTab {
            case .home:
                NavigationStack {
                    HomeView()
                }
                .transition(.opacity)
            case .learn:
                NavigationStack {
                    LearnView()
                }
                .transition(.opacity)
            case .journal:
                NavigationStack {
                    JournalView()
                }
                .transition(.opacity)
            case .coach:
                NavigationStack {
                    CoachView()
                }
                .transition(.opacity)
            case .library:
                NavigationStack {
                    LibraryPlaceholderView()
                }
                .transition(.opacity)
            case .share:
                NavigationStack {
                    SocialShareView()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

// MARK: - Library Placeholder

struct LibraryPlaceholderView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(UserProfile.self) private var profile

    var body: some View {
        let scheme = theme.effectiveScheme
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                    Text("Your Library")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(ResonanceColors.text(for: scheme))
                    Text("Bookmarks, highlights, and saved content")
                        .font(.subheadline)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                }
                .padding(.top, 40)

                // Bookmarks Section
                if !profile.bookmarks.isEmpty {
                    SectionCard(title: "Bookmarks", icon: "bookmark.fill", scheme: scheme) {
                        ForEach(profile.bookmarks) { bookmark in
                            HStack {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(ResonanceColors.goldPrimary)
                                VStack(alignment: .leading) {
                                    Text("Chapter \(bookmark.chapterId)")
                                        .font(.headline)
                                        .foregroundStyle(ResonanceColors.text(for: scheme))
                                    if let note = bookmark.note {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                                    }
                                }
                                Spacer()
                                Text(bookmark.date, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Highlights Section
                if !profile.highlights.isEmpty {
                    SectionCard(title: "Highlights", icon: "highlighter", scheme: scheme) {
                        ForEach(profile.highlights) { highlight in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\"\(highlight.text)\"")
                                    .font(.body)
                                    .italic()
                                    .foregroundStyle(ResonanceColors.text(for: scheme))
                                Text("Chapter \(highlight.chapterId)")
                                    .font(.caption)
                                    .foregroundStyle(ResonanceColors.goldPrimary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // Empty State
                if profile.bookmarks.isEmpty && profile.highlights.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "text.book.closed")
                            .font(.system(size: 64))
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.4))
                        Text("Your library is waiting")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                        Text("Bookmark passages and highlight text as you read to build your personal collection of wisdom.")
                            .font(.subheadline)
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }

                // Stats Card
                SectionCard(title: "Reading Stats", icon: "chart.bar.fill", scheme: scheme) {
                    HStack(spacing: 20) {
                        StatPill(value: "\(profile.completedChapters.count)", label: "Chapters", scheme: scheme)
                        StatPill(value: "\(profile.bookmarks.count)", label: "Bookmarks", scheme: scheme)
                        StatPill(value: "\(profile.highlights.count)", label: "Highlights", scheme: scheme)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(theme.background(for: scheme).ignoresSafeArea())
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let scheme: ColorScheme
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(ResonanceColors.goldPrimary)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ResonanceColors.surface(for: scheme))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
    }
}

struct StatPill: View {
    let value: String
    let label: String
    let scheme: ColorScheme

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(ResonanceColors.goldPrimary)
            Text(label)
                .font(.caption)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Custom Tab Bar

struct ResonanceTabBar: View {
    @Binding var selectedTab: AppTab
    let theme: ThemeManager

    var body: some View {
        let scheme = theme.effectiveScheme
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    scheme: scheme
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 2)
        .background(
            ZStack {
                // Frosted glass background
                Rectangle()
                    .fill(.ultraThinMaterial)
                // Subtle gold top border
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
                        .frame(height: 1)
                    Spacer()
                }
            }
            .ignoresSafeArea()
        )
    }
}

struct TabBarButton: View {
    let tab: AppTab
    let isSelected: Bool
    let scheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(ResonanceColors.goldPrimary.opacity(0.15))
                            .frame(width: 40, height: 40)
                    }
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected
                                ? ResonanceColors.goldPrimary
                                : ResonanceColors.textSecondary(for: scheme)
                        )
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 40)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected
                            ? ResonanceColors.goldPrimary
                            : ResonanceColors.textSecondary(for: scheme)
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
    }
}

// MARK: - Preview

#Preview {
    LuminousAttachmentApp.main()
}
