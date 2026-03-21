// ArticlesView.swift
// Haute Lumière — Bespoke Articles Module

import SwiftUI

struct ArticlesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @State private var articles: [BespokeArticle] = []
    @State private var selectedArticle: BespokeArticle?

    var body: some View {
        ZStack {
            if appState.isNightMode {
                ForestNightBackground(theme: appState.nightModeTheme)
            } else {
                Color.hlCream.ignoresSafeArea()
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        Text("Curated for You")
                            .font(HLTypography.screenTitle)
                            .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                        Text("Bespoke articles based on your journey with \(appState.selectedCoach.displayName)")
                            .font(HLTypography.body)
                            .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, HLSpacing.lg)

                    // Featured article
                    if let featured = articles.first {
                        FeaturedArticleCard(article: featured, isNightMode: appState.isNightMode) {
                            selectedArticle = featured
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HLSpacing.sm) {
                            ForEach(BespokeArticle.ArticleCategory.allCases, id: \.self) { cat in
                                FilterChip(title: cat.rawValue, isSelected: false) {}
                            }
                        }
                        .padding(.horizontal, HLSpacing.lg)
                    }

                    // Article list
                    LazyVStack(spacing: HLSpacing.md) {
                        ForEach(articles) { article in
                            ArticleRow(article: article, isNightMode: appState.isNightMode) {
                                selectedArticle = article
                            }
                        }
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Articles")
        .onAppear { generateArticles() }
        .sheet(item: $selectedArticle) { article in
            ArticleDetailView(article: article)
        }
    }

    private func generateArticles() {
        let user = UserProfile(firstName: appState.userName, selectedCoach: appState.selectedCoach)
        articles = (0..<8).map { _ in
            coachEngine.generateBespokeArticle(for: user)
        }
    }
}

// MARK: - Featured Article Card
struct FeaturedArticleCard: View {
    let article: BespokeArticle
    let isNightMode: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: HLRadius.xl)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1B402E"), Color(hex: "2A5A42"), Color(hex: "3A7A5A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)

                VStack(alignment: .leading, spacing: HLSpacing.sm) {
                    Text(article.category.rawValue.uppercased())
                        .font(HLTypography.caption)
                        .foregroundColor(.hlGoldLight)
                        .tracking(1.5)

                    Text(article.title)
                        .font(HLTypography.serifMedium(22))
                        .foregroundColor(.white)

                    Text(article.subtitle)
                        .font(HLTypography.bodySmall)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(HLSpacing.lg)
            }
        }
    }
}

// MARK: - Article Row
struct ArticleRow: View {
    let article: BespokeArticle
    let isNightMode: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: HLSpacing.md) {
                RoundedRectangle(cornerRadius: HLRadius.sm)
                    .fill(LinearGradient(colors: [.hlGreen600, .hlGreen400], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: categoryIcon(article.category))
                            .foregroundColor(.white.opacity(0.7))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(article.category.rawValue.uppercased())
                        .font(HLTypography.caption)
                        .foregroundColor(.hlGold)
                        .tracking(1)

                    Text(article.title)
                        .font(HLTypography.cardTitle)
                        .foregroundColor(isNightMode ? .hlNightText : .hlTextPrimary)
                        .lineLimit(1)

                    Text(article.subtitle)
                        .font(HLTypography.bodySmall)
                        .foregroundColor(isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                        .lineLimit(1)
                }

                Spacer()

                if !article.isRead {
                    Circle()
                        .fill(Color.hlGold)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(HLSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.md)
                    .fill(isNightMode ? Color.white.opacity(0.04) : .hlSurface)
            )
        }
    }

    private func categoryIcon(_ category: BespokeArticle.ArticleCategory) -> String {
        switch category {
        case .mindfulness: return "brain.head.profile"
        case .breathwork: return "wind"
        case .yogaNidra: return "moon.stars.fill"
        case .executiveWellness: return "briefcase.fill"
        case .relationships: return "heart.fill"
        case .nutrition: return "leaf.fill"
        case .movement: return "figure.walk"
        case .sleep: return "bed.double.fill"
        case .neuroscience: return "brain"
        case .ancientWisdom: return "books.vertical.fill"
        case .leadership: return "person.3.fill"
        case .creativity: return "paintbrush.fill"
        }
    }
}

// MARK: - Article Detail
struct ArticleDetailView: View {
    let article: BespokeArticle
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAFAF8"), Color(hex: "F4F8F5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HLSpacing.lg) {
                    // Header image placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: HLRadius.xl)
                            .fill(
                                LinearGradient(colors: [Color(hex: "1B402E"), Color(hex: "2A5A42")], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(height: 220)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundColor(.hlGoldLight.opacity(0.5))
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    VStack(alignment: .leading, spacing: HLSpacing.md) {
                        Text(article.category.rawValue.uppercased())
                            .font(HLTypography.caption)
                            .foregroundColor(.hlGold)
                            .tracking(2)

                        Text(article.title)
                            .font(HLTypography.serifMedium(28))
                            .foregroundColor(.hlTextPrimary)

                        Text(article.subtitle)
                            .font(HLTypography.sansLight(16))
                            .foregroundColor(.hlTextSecondary)

                        Divider()
                            .padding(.vertical, HLSpacing.sm)

                        Text(article.body)
                            .font(HLTypography.bodyLarge)
                            .foregroundColor(.hlTextPrimary)
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: HLSpacing.xxl)
                }
                .padding(.top, HLSpacing.md)
            }
        }
    }
}
