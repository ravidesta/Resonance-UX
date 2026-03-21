// MainTabView.swift
// Haute Lumière — Main Navigation

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var audioEngine: AudioEngine

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tag(AppState.MainTab.home)

                PracticeLibraryView()
                    .tag(AppState.MainTab.practice)

                CoachView()
                    .tag(AppState.MainTab.coach)

                JourneyView()
                    .tag(AppState.MainTab.journey)

                ProfileView()
                    .tag(AppState.MainTab.profile)
            }

            // Custom Tab Bar
            VStack(spacing: 0) {
                // Mini Player
                if audioEngine.showMiniPlayer {
                    MiniPlayerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Tab Bar
                HauteLumiereTabBar(selectedTab: $appState.selectedTab)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct HauteLumiereTabBar: View {
    @Binding var selectedTab: AppState.MainTab
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppState.MainTab.allCases, id: \.self) { tab in
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab } }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(tab))
                            .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? tabAccentColor : .hlTextTertiary)

                        Text(tabName(tab))
                            .font(HLTypography.tabLabel)
                            .foregroundColor(selectedTab == tab ? tabAccentColor : .hlTextTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, HLSpacing.sm)
        .padding(.bottom, 2)
        .background(
            Rectangle()
                .fill(appState.isNightMode ? Color.hlNightDeep : .hlSurface)
                .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
        )
    }

    private var tabAccentColor: Color {
        appState.isNightMode ? .hlGold : .hlGreen700
    }

    private func tabIcon(_ tab: AppState.MainTab) -> String {
        switch tab {
        case .home: return selectedTab == tab ? "house.fill" : "house"
        case .practice: return selectedTab == tab ? "leaf.fill" : "leaf"
        case .coach: return selectedTab == tab ? "message.fill" : "message"
        case .journey: return selectedTab == tab ? "chart.line.uptrend.xyaxis" : "chart.line.uptrend.xyaxis"
        case .profile: return selectedTab == tab ? "person.fill" : "person"
        }
    }

    private func tabName(_ tab: AppState.MainTab) -> String {
        switch tab {
        case .home: return "Home"
        case .practice: return "Practice"
        case .coach: return "Coach"
        case .journey: return "Journey"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Mini Player
struct MiniPlayerView: View {
    @EnvironmentObject var audioEngine: AudioEngine
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            // Session type icon
            ZStack {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(LinearGradient(colors: [.hlGreen700, .hlGreen600], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 40, height: 40)
                Image(systemName: audioEngine.currentSessionType?.icon ?? "waveform")
                    .foregroundColor(.hlGoldLight)
                    .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(audioEngine.currentSessionTitle)
                    .font(HLTypography.label)
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                    .lineLimit(1)

                Text(audioEngine.remainingFormatted + " remaining")
                    .font(HLTypography.caption)
                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextTertiary)
            }

            Spacer()

            // Play/Pause
            Button(action: {
                if audioEngine.isPlaying { audioEngine.pause() }
                else { audioEngine.resume() }
            }) {
                Image(systemName: audioEngine.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18))
                    .foregroundColor(appState.isNightMode ? .hlGold : .hlGreen700)
            }

            // Close
            Button(action: { audioEngine.stop() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.hlTextTertiary)
            }
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.sm)
        .background(
            Rectangle()
                .fill(appState.isNightMode ? Color.hlNightForest : .hlSurface)
        )

        // Progress bar
        GeometryReader { geo in
            Rectangle()
                .fill(Color.hlGold)
                .frame(width: geo.size.width * audioEngine.progress, height: 2)
        }
        .frame(height: 2)
    }
}
