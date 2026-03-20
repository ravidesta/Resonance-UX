// LuminousApp.swift
// Luminous Integral Architecture™ — iOS (iPhone) App Entry Point
//
// Tab-based navigation with Read, Listen, Learn, Coach, Community tabs.
// Includes deep linking support and onboarding flow.

import SwiftUI

// MARK: - App Entry

@main
struct LuminousApp: App {
    @StateObject private var appState = LuminousAppState()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(appState)
                    .onOpenURL { url in
                        appState.handleDeepLink(url)
                    }
            } else {
                OnboardingView(isComplete: $hasCompletedOnboarding)
            }
        }
    }
}

// MARK: - App State

@MainActor
final class LuminousAppState: ObservableObject {
    @Published var selectedTab: AppTab = .read
    @Published var deepLinkChapterId: String?
    @Published var deepLinkPage: Int?
    @Published var showMiniAudioPlayer = false

    enum AppTab: String, CaseIterable {
        case read     = "Read"
        case listen   = "Listen"
        case learn    = "Learn"
        case coach    = "Coach"
        case community = "Community"

        var icon: String {
            switch self {
            case .read:      return "book.fill"
            case .listen:    return "headphones"
            case .learn:     return "graduationcap.fill"
            case .coach:     return "sparkles"
            case .community: return "person.3.fill"
            }
        }
    }

    /// Handle deep links: luminouslia://read/chapter/ch2?page=55
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "luminouslia" else { return }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch url.host {
        case "read":
            selectedTab = .read
            if pathComponents.count >= 2, pathComponents[0] == "chapter" {
                deepLinkChapterId = pathComponents[1]
            }
            if let pageStr = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "page" })?.value,
               let page = Int(pageStr) {
                deepLinkPage = page
            }
        case "listen":
            selectedTab = .listen
        case "learn":
            selectedTab = .learn
        case "coach":
            selectedTab = .coach
        case "community":
            selectedTab = .community
        default:
            break
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject private var appState: LuminousAppState

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                // Read Tab
                NavigationStack {
                    BookReaderView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
                .tag(LuminousAppState.AppTab.read)
                .tabItem {
                    Label(LuminousAppState.AppTab.read.rawValue,
                          systemImage: LuminousAppState.AppTab.read.icon)
                }

                // Listen Tab
                NavigationStack {
                    AudiobookPlayerView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
                .tag(LuminousAppState.AppTab.listen)
                .tabItem {
                    Label(LuminousAppState.AppTab.listen.rawValue,
                          systemImage: LuminousAppState.AppTab.listen.icon)
                }

                // Learn Tab
                NavigationStack {
                    LearnTabView()
                }
                .tag(LuminousAppState.AppTab.learn)
                .tabItem {
                    Label(LuminousAppState.AppTab.learn.rawValue,
                          systemImage: LuminousAppState.AppTab.learn.icon)
                }

                // Coach Tab
                NavigationStack {
                    CoachTutorView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
                .tag(LuminousAppState.AppTab.coach)
                .tabItem {
                    Label(LuminousAppState.AppTab.coach.rawValue,
                          systemImage: LuminousAppState.AppTab.coach.icon)
                }

                // Community Tab
                NavigationStack {
                    EcosystemHubView()
                        .navigationTitle("")
                        .navigationBarHidden(true)
                }
                .tag(LuminousAppState.AppTab.community)
                .tabItem {
                    Label(LuminousAppState.AppTab.community.rawValue,
                          systemImage: LuminousAppState.AppTab.community.icon)
                }
            }
            .tint(Color.resonanceGoldPrimary)

            // Mini audio player overlay
            if appState.showMiniAudioPlayer && appState.selectedTab != .listen {
                AudiobookPlayerView().miniPlayerBar
                    .padding(.horizontal, 8)
                    .padding(.bottom, 50) // Above tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture {
                        appState.selectedTab = .listen
                    }
            }
        }
    }
}

// MARK: - Learn Tab View

struct LearnTabView: View {
    var body: some View {
        ZStack {
            Color.resonanceBgBaseDark
                .ignoresSafeArea()
            OrganicBlobView()
                .ignoresSafeArea()
                .opacity(0.4)

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learn")
                            .font(ResonanceTypography.serifDisplay())
                            .foregroundStyle(.white)
                        Text("Interactive exercises and assessments")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                    ResonanceDivider()
                        .padding(.horizontal, 20)

                    // Exercises
                    VStack(alignment: .leading, spacing: 12) {
                        Text("INTERACTIVE EXERCISES")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                            .tracking(2)
                            .padding(.horizontal, 20)

                        QuadrantMappingCard(title: "Map a current life situation across all four quadrants")
                            .padding(.horizontal, 20)

                        ReflectionQuestionCard(
                            question: "What developmental stage do you most identify with right now?",
                            prompt: "Consider how you make meaning, relate to others, and understand the world."
                        )
                        .padding(.horizontal, 20)
                    }

                    // Somatic practices
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SOMATIC PRACTICES")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                            .tracking(2)
                            .padding(.horizontal, 20)

                        SomaticPracticeCard(
                            title: "3-Minute Spatial Attunement",
                            instruction: "Let your awareness expand to fill the space around you. Notice the quality of the space above, below, in front, behind, and to each side.",
                            durationSeconds: 180
                        )
                        .padding(.horizontal, 20)

                        SomaticPracticeCard(
                            title: "Body Scan Integration",
                            instruction: "Slowly scan from the crown of your head to the soles of your feet. Notice any areas of tension, warmth, or aliveness. Simply observe without changing anything.",
                            durationSeconds: 300
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Learn")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isComplete: Bool
    @State private var currentPage = 0

    private let pages: [(title: String, subtitle: String, icon: String)] = [
        ("Welcome to Luminous", "An integral approach to reading, learning, and growing.", "sparkles"),
        ("Read with Depth", "Interactive ebook with exercises, highlights, and somatic practices woven throughout.", "book.fill"),
        ("Listen Anywhere", "Full audiobook with follow-along text sync and flexible playback controls.", "headphones"),
        ("Learn with a Coach", "AI-guided coaching that meets you where you are on your developmental journey.", "person.fill.questionmark"),
        ("Join the Community", "Connect with fellow practitioners in study groups and practice circles.", "person.3.fill"),
    ]

    var body: some View {
        ZStack {
            Color.resonanceBgBaseDark
                .ignoresSafeArea()
            OrganicBlobView()
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(Color.resonanceGreen700.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .breathingAnimation(duration: 5)

                    Image(systemName: pages[currentPage].icon)
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Color.resonanceGoldPrimary)
                }
                .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text(pages[currentPage].title)
                        .font(ResonanceTypography.serifTitle())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(pages[currentPage].subtitle)
                        .font(ResonanceTypography.sansBody())
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.resonanceGoldPrimary : .white.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .accessibilityLabel("Page \(currentPage + 1) of \(pages.count)")

                // Action button
                if currentPage < pages.count - 1 {
                    Button("Continue") {
                        withAnimation(.easeInOut) {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.resonancePrimary)
                } else {
                    Button("Begin Your Journey") {
                        withAnimation {
                            isComplete = true
                        }
                    }
                    .buttonStyle(.resonancePrimary)
                }

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        withAnimation {
                            isComplete = true
                        }
                    }
                    .buttonStyle(.resonanceGhost)
                }

                Spacer()
                    .frame(height: 20)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LuminousApp_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(LuminousAppState())

        OnboardingView(isComplete: .constant(false))
            .previewDisplayName("Onboarding")
    }
}
#endif
