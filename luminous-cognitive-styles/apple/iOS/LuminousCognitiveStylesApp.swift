// LuminousCognitiveStylesApp.swift
// Luminous Cognitive Styles™ — iOS
// Main app entry point with tab-based navigation

import SwiftUI

@main
struct LuminousCognitiveStylesApp: App {
    @StateObject private var viewModel = AssessmentViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home = "Home"
        case assess = "Assess"
        case book = "Book"
        case coaching = "Coaching"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home: return "sparkles"
            case .assess: return "brain.head.profile"
            case .book: return "book.fill"
            case .coaching: return "message.fill"
            case .profile: return "person.crop.circle"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)

            AssessmentHubView()
                .tabItem {
                    Label(Tab.assess.rawValue, systemImage: Tab.assess.icon)
                }
                .tag(Tab.assess)

            BookReaderView()
                .tabItem {
                    Label(Tab.book.rawValue, systemImage: Tab.book.icon)
                }
                .tag(Tab.book)

            CoachingView()
                .tabItem {
                    Label(Tab.coaching.rawValue, systemImage: Tab.coaching.icon)
                }
                .tag(Tab.coaching)

            ProfileView()
                .tabItem {
                    Label(Tab.profile.rawValue, systemImage: Tab.profile.icon)
                }
                .tag(Tab.profile)
        }
        .tint(LCSTheme.goldAccent)
    }
}

// MARK: - Assessment Hub (routes to Quick or Full)

struct AssessmentHubView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var showQuickProfile = false
    @State private var showFullAssessment = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LCSTheme.Spacing.xl) {
                    Spacer(minLength: LCSTheme.Spacing.lg)

                    Text("Discover Your\nCognitive Style")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(LCSTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text("Choose your assessment path")
                        .font(.subheadline)
                        .foregroundColor(LCSTheme.textSecondary)

                    // Quick Profile Card
                    Button { showQuickProfile = true } label: {
                        AssessmentOptionCard(
                            title: "Quick Profile",
                            subtitle: "2 minutes",
                            description: "Rate yourself on each dimension using intuitive sliders. Great for a first exploration.",
                            icon: "bolt.fill",
                            color: LCSTheme.amberGold
                        )
                    }

                    // Full DSR Card
                    Button { showFullAssessment = true } label: {
                        AssessmentOptionCard(
                            title: "Full DSR Assessment",
                            subtitle: "10-15 minutes",
                            description: "Answer 35 research-based questions for a comprehensive Dimensional Style Report.",
                            icon: "doc.text.magnifyingglass",
                            color: LCSTheme.crystalBlue
                        )
                    }

                    // Resume if in progress
                    if viewModel.isAssessmentInProgress && !viewModel.dsrAnswers.isEmpty {
                        Button { showFullAssessment = true } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .foregroundColor(LCSTheme.emerald)
                                Text("Resume Assessment (\(Int(viewModel.dsrProgress * 100))% complete)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(LCSTheme.textPrimary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                                    .stroke(LCSTheme.emerald.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }

                    Spacer(minLength: LCSTheme.Spacing.xxl)
                }
                .padding(.horizontal)
            }
            .background(LCSTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showQuickProfile) {
                NavigationStack {
                    QuickProfileView()
                }
                .environmentObject(viewModel)
            }
            .fullScreenCover(isPresented: $showFullAssessment) {
                NavigationStack {
                    FullAssessmentView()
                }
                .environmentObject(viewModel)
            }
        }
    }
}

struct AssessmentOptionCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(LCSTheme.textPrimary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(color)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(LCSTheme.textTertiary)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
        .lcsCard()
        .padding(.horizontal, 4)
    }
}
