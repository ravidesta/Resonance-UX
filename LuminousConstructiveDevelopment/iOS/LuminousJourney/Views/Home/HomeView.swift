// MARK: - Home View — The Luminous Landing
// "Design for the exhale." First thing the user sees.

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        TabView(selection: $appState.currentTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppState.AppTab.home)

            LearnView()
                .tabItem { Label("Learn", systemImage: "book") }
                .tag(AppState.AppTab.learn)

            AudiobookView()
                .tabItem { Label("Listen", systemImage: "headphones") }
                .tag(AppState.AppTab.listen)

            PracticeLibraryView()
                .tabItem { Label("Practice", systemImage: "figure.mind.and.body") }
                .tag(AppState.AppTab.practice)

            JournalView()
                .tabItem { Label("Journal", systemImage: "pencil.line") }
                .tag(AppState.AppTab.journal)

            GuideView()
                .tabItem { Label("Guide", systemImage: "bubble.left.and.text.bubble.right") }
                .tag(AppState.AppTab.guide)

            CommunityView()
                .tabItem { Label("Community", systemImage: "person.3") }
                .tag(AppState.AppTab.community)
        }
        .tint(theme.accent)
    }
}

struct HomeView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appState: AppState
    @State private var breathScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // MARK: - Header with breathing blob
                    ZStack {
                        // Organic breathing blob (Resonance-UX signature)
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [theme.goldPrimary.opacity(0.15), theme.forestBase.opacity(0.05)],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(breathScale)
                            .blur(radius: 40)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                                    breathScale = 1.15
                                }
                            }

                        VStack(spacing: 8) {
                            Text("Luminous Journey")
                                .font(.custom("Cormorant Garamond", size: 36))
                                .fontWeight(.light)
                                .foregroundColor(theme.text)

                            if let season = appState.user?.currentSeason {
                                Text("Season of \(season.rawValue)")
                                    .font(.custom("Manrope", size: 14))
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                    }
                    .padding(.top, 24)

                    // MARK: - Somatic Check-In Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "waveform")
                                    .foregroundColor(theme.accent)
                                Text("Somatic Check-In")
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                            }

                            Text(somaticPrompt)
                                .font(.custom("Cormorant Garamond", size: 22))
                                .foregroundColor(theme.text)
                                .lineSpacing(4)

                            Button(action: { appState.currentTab = .journal }) {
                                Text("Reflect")
                                    .font(.custom("Manrope", size: 14).weight(.medium))
                                    .foregroundColor(theme.cream)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(theme.forestBase)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    // MARK: - Continue Reading / Listening
                    if appState.user?.readingPosition != nil || appState.user?.audioPosition != nil {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Continue", systemImage: "bookmark")
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)

                                if appState.user?.readingPosition != nil {
                                    ContinueReadingRow()
                                }
                                if appState.user?.audioPosition != nil {
                                    ContinueListeningRow()
                                }
                            }
                        }
                    }

                    // MARK: - Today's Practice
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Today's Practice", systemImage: "figure.mind.and.body")
                                .font(.custom("Manrope", size: 13).weight(.semibold))
                                .foregroundColor(theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(0.5)

                            RecommendedPracticeCard()
                        }
                    }

                    // MARK: - Guide Invitation
                    GlassCard {
                        HStack(spacing: 16) {
                            Image(systemName: "bubble.left.and.text.bubble.right")
                                .font(.system(size: 28))
                                .foregroundColor(theme.accent)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Talk with your Guide")
                                    .font(.custom("Cormorant Garamond", size: 20))
                                    .foregroundColor(theme.text)
                                Text("Explore what's alive in you right now")
                                    .font(.custom("Manrope", size: 14))
                                    .foregroundColor(theme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(theme.textMuted)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { appState.currentTab = .guide }
                    }

                    // MARK: - Developmental Landscape (mini spiral visualization)
                    if let order = appState.user?.primaryOrder {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Your Landscape", systemImage: "scope")
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)

                                DevelopmentalSpiralMini(currentOrder: order)
                            }
                        }
                    }

                    // MARK: - Resonance Ecosystem Connections
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Resonance Ecosystem", systemImage: "link")
                                .font(.custom("Manrope", size: 13).weight(.semibold))
                                .foregroundColor(theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(0.5)

                            EcosystemConnectionsRow()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(theme.background)
            .navigationBarHidden(true)
        }
    }

    private var somaticPrompt: String {
        guard let season = appState.user?.currentSeason else {
            return "Take a breath. Place your attention on your body. What do you notice right now?"
        }
        return season.bodyPrompt
    }
}

// MARK: - Glass Card (Resonance-UX signature component)

struct GlassCard<Content: View>: View {
    @EnvironmentObject var theme: ThemeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.isDeepRest
                        ? Color(hex: "122E21").opacity(0.6)
                        : Color.white.opacity(0.72))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.goldPrimary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
    }
}

// MARK: - Subviews (Stubs for full implementation)

struct ContinueReadingRow: View {
    @EnvironmentObject var theme: ThemeManager
    var body: some View {
        HStack {
            Image(systemName: "book")
                .foregroundColor(theme.forestBase)
            VStack(alignment: .leading) {
                Text("Chapter 2: Subject-Object Dynamics")
                    .font(.custom("Manrope", size: 15).weight(.medium))
                    .foregroundColor(theme.text)
                Text("42% complete")
                    .font(.custom("Manrope", size: 13))
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(theme.textMuted)
        }
    }
}

struct ContinueListeningRow: View {
    @EnvironmentObject var theme: ThemeManager
    var body: some View {
        HStack {
            Image(systemName: "headphones")
                .foregroundColor(theme.forestBase)
            VStack(alignment: .leading) {
                Text("Ch. 1: Theoretical Foundations")
                    .font(.custom("Manrope", size: 15).weight(.medium))
                    .foregroundColor(theme.text)
                Text("1h 23m remaining")
                    .font(.custom("Manrope", size: 13))
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
            Image(systemName: "play.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(theme.accent)
        }
    }
}

struct RecommendedPracticeCard: View {
    @EnvironmentObject var theme: ThemeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gentle Breath Release")
                .font(.custom("Cormorant Garamond", size: 20))
                .foregroundColor(theme.text)
            Text("5 minutes · Breathwork · Season of Compression")
                .font(.custom("Manrope", size: 13))
                .foregroundColor(theme.textSecondary)
            Text("A slow breathing pattern to soften the compression the body is holding.")
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(2)
        }
    }
}

struct DevelopmentalSpiralMini: View {
    let currentOrder: DevelopmentalOrder
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ForEach(DevelopmentalOrder.allCases) { order in
                VStack(spacing: 4) {
                    Circle()
                        .fill(order == currentOrder
                            ? (theme.orderColors[order] ?? theme.accent)
                            : theme.textMuted.opacity(0.3))
                        .frame(width: order == currentOrder ? 24 : 16,
                               height: order == currentOrder ? 24 : 16)
                        .overlay(
                            Circle()
                                .stroke(theme.goldPrimary.opacity(order == currentOrder ? 0.5 : 0), lineWidth: 2)
                        )

                    if order == currentOrder {
                        Text(order.name.components(separatedBy: " ").first ?? "")
                            .font(.custom("Manrope", size: 10))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct EcosystemConnectionsRow: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var ecosystem: ResonanceEcosystemBridge

    var body: some View {
        HStack(spacing: 16) {
            EcosystemChip(name: "Daily Flow", icon: "clock", connected: ecosystem.isDailyFlowConnected)
            EcosystemChip(name: "Resonance", icon: "message", connected: ecosystem.isResonanceCommsConnected)
            EcosystemChip(name: "Writer", icon: "pencil", connected: ecosystem.isWriterConnected)
            EcosystemChip(name: "Provider", icon: "stethoscope", connected: ecosystem.isProviderConnected)
        }
    }
}

struct EcosystemChip: View {
    let name: String
    let icon: String
    let connected: Bool
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(connected ? theme.accent : theme.textMuted)
            Text(name)
                .font(.custom("Manrope", size: 10))
                .foregroundColor(connected ? theme.textSecondary : theme.textMuted)
            Circle()
                .fill(connected ? theme.goldPrimary : theme.textMuted.opacity(0.3))
                .frame(width: 6, height: 6)
        }
    }
}

// MARK: - Placeholder Views (implemented in their own files)

struct LearnView: View { var body: some View { Text("Learn") } }
struct PracticeLibraryView: View { var body: some View { Text("Practice") } }
struct CommunityView: View { var body: some View { Text("Community") } }
