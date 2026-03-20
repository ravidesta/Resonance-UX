// LibraryView.swift
// Luminous Cosmic Architecture™ — macOS Library
// Book chapter browser with reading view

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedChapter: LibraryChapter?
    @State private var searchText: String = ""
    @State private var selectedCategory: ChapterCategory = .all

    var body: some View {
        HSplitView {
            // Chapter browser
            chapterBrowser
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)

            // Reading view
            if let chapter = selectedChapter {
                readingView(chapter)
                    .frame(minWidth: 450)
                    .transition(.opacity)
            } else {
                emptyReading
                    .frame(minWidth: 450)
            }
        }
    }

    // MARK: - Chapter Browser

    private var chapterBrowser: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
                Text("Library")
                    .font(ResonanceMacTheme.Typography.title)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )

                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                    TextField("Search chapters...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(ResonanceMacTheme.Typography.body)
                }
                .padding(ResonanceMacTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.sm)
                        .fill(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.forestLight.opacity(0.3)
                                : ResonanceMacTheme.Colors.creamWarm
                        )
                )

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ResonanceMacTheme.Spacing.xs) {
                        ForEach(ChapterCategory.allCases) { category in
                            categoryPill(category)
                        }
                    }
                }
            }
            .padding(ResonanceMacTheme.Spacing.md)

            Divider()
                .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

            // Chapter list
            ScrollView {
                LazyVStack(spacing: ResonanceMacTheme.Spacing.xs) {
                    ForEach(filteredChapters) { chapter in
                        chapterRow(chapter)
                    }
                }
                .padding(.vertical, ResonanceMacTheme.Spacing.sm)
            }
        }
        .background(
            appState.isNightMode
                ? ResonanceMacTheme.Colors.nightBackground.opacity(0.3)
                : ResonanceMacTheme.Colors.creamWarm.opacity(0.5)
        )
    }

    private func categoryPill(_ category: ChapterCategory) -> some View {
        Button(action: {
            withAnimation(ResonanceMacTheme.Animation.quick) {
                selectedCategory = category
            }
        }) {
            Text(category.rawValue)
                .font(ResonanceMacTheme.Typography.caption)
                .foregroundStyle(
                    selectedCategory == category
                        ? ResonanceMacTheme.Colors.cream
                        : ResonanceMacTheme.Colors.mutedGreen
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(
                            selectedCategory == category
                                ? ResonanceMacTheme.Colors.gold
                                : ResonanceMacTheme.Colors.gold.opacity(0.08)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func chapterRow(_ chapter: LibraryChapter) -> some View {
        Button(action: {
            withAnimation(ResonanceMacTheme.Animation.quick) {
                selectedChapter = chapter
            }
        }) {
            HStack(spacing: ResonanceMacTheme.Spacing.md) {
                // Chapter number
                ZStack {
                    RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.sm)
                        .fill(
                            LinearGradient(
                                colors: [ResonanceMacTheme.Colors.forestMid, ResonanceMacTheme.Colors.forestDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 48)

                    Text("\(chapter.number)")
                        .font(ResonanceMacTheme.Typography.title3)
                        .foregroundStyle(ResonanceMacTheme.Colors.gold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(chapter.title)
                        .font(ResonanceMacTheme.Typography.headline)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )
                        .lineLimit(1)

                    Text(chapter.subtitle)
                        .font(ResonanceMacTheme.Typography.caption)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                        .lineLimit(1)

                    HStack(spacing: ResonanceMacTheme.Spacing.xs) {
                        Text(chapter.category.rawValue)
                            .font(ResonanceMacTheme.Typography.caption2)
                            .foregroundStyle(ResonanceMacTheme.Colors.gold)

                        Text("\u{2022}")
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                            .font(.system(size: 6))

                        Text("\(chapter.readingTimeMinutes) min read")
                            .font(ResonanceMacTheme.Typography.caption2)
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                    }
                }

                Spacer()

                if chapter.isRead {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                }
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.sm)
                    .fill(
                        selectedChapter?.id == chapter.id
                            ? ResonanceMacTheme.Colors.gold.opacity(0.08)
                            : Color.clear
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, ResonanceMacTheme.Spacing.xs)
    }

    // MARK: - Reading View

    private func readingView(_ chapter: LibraryChapter) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.xl) {
                // Chapter header
                VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
                    HStack {
                        Text("Chapter \(chapter.number)")
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundStyle(ResonanceMacTheme.Colors.gold)
                            .tracking(2)

                        Spacer()

                        Text("\(chapter.readingTimeMinutes) min read")
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                    }

                    Text(chapter.title)
                        .font(ResonanceMacTheme.Typography.largeTitle)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )

                    Text(chapter.subtitle)
                        .font(ResonanceMacTheme.Typography.callout)
                        .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                        .italic()
                }

                Divider()
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, ResonanceMacTheme.Colors.gold.opacity(0.3), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Body content
                Text(chapter.body)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.creamWarm
                            : ResonanceMacTheme.Colors.forestMid
                    )
                    .lineSpacing(10)
                    .textSelection(.enabled)

                // Key concepts
                if !chapter.keyConcepts.isEmpty {
                    VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
                        Text("Key Concepts")
                            .font(ResonanceMacTheme.Typography.headline)
                            .foregroundStyle(
                                appState.isNightMode
                                    ? ResonanceMacTheme.Colors.cream
                                    : ResonanceMacTheme.Colors.forestDeep
                            )

                        ForEach(chapter.keyConcepts, id: \.self) { concept in
                            HStack(alignment: .top, spacing: ResonanceMacTheme.Spacing.sm) {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 10))
                                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                                    .padding(.top, 3)

                                Text(concept)
                                    .font(ResonanceMacTheme.Typography.body)
                                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                            }
                        }
                    }
                    .padding(ResonanceMacTheme.Spacing.lg)
                    .glassmorphism(isNightMode: appState.isNightMode)
                }
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.xxl)
            .padding(.vertical, ResonanceMacTheme.Spacing.xl)
            .frame(maxWidth: 700, alignment: .leading)
        }
    }

    // MARK: - Empty State

    private var emptyReading: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.md) {
            Image(systemName: "books.vertical")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight.opacity(0.5))

            Text("Select a chapter to begin reading")
                .font(ResonanceMacTheme.Typography.body)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
        }
    }

    // MARK: - Filtering

    private var filteredChapters: [LibraryChapter] {
        var chapters = LibraryChapter.samples
        if selectedCategory != .all {
            chapters = chapters.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            chapters = chapters.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        return chapters
    }
}

// MARK: - Models

enum ChapterCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case foundations = "Foundations"
    case planets = "Planets"
    case houses = "Houses"
    case aspects = "Aspects"
    case integration = "Integration"

    var id: String { rawValue }
}

struct LibraryChapter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let subtitle: String
    let category: ChapterCategory
    let readingTimeMinutes: Int
    let isRead: Bool
    let body: String
    let keyConcepts: [String]

    static var samples: [LibraryChapter] {
        [
            LibraryChapter(
                number: 1,
                title: "The Cosmic Mirror",
                subtitle: "Understanding your natal chart as a map of consciousness",
                category: .foundations,
                readingTimeMinutes: 12,
                isRead: true,
                body: "Your natal chart is not a prediction of who you will become. It is a mirror reflecting the patterns of consciousness you arrived with \u{2014} the raw materials of your becoming.\n\nImagine the sky at the exact moment of your first breath: every planet suspended in its particular position, every angle between them creating a web of relationships. This celestial snapshot is your birth chart, and it speaks the language of potential rather than fate.\n\nThe ancient astrologers understood something that modern psychology is only beginning to articulate: we are not blank slates. We arrive with tendencies, gifts, challenges, and deep patterns that shape how we encounter the world. The natal chart maps these patterns with extraordinary precision.\n\nBut here is the crucial insight that separates developmental astrology from fortune-telling: the chart shows the territory of your consciousness, not the journey you must take through it. Two people with identical charts will live vastly different lives, because the chart reveals possibilities, not certainties.\n\nThis is the foundation of Luminous Cosmic Architecture \u{2014} the understanding that your chart is an invitation to self-knowledge, not a sentence to be served.",
                keyConcepts: [
                    "The natal chart is a mirror of consciousness, not a prediction",
                    "Celestial patterns correspond to psychological patterns",
                    "The chart maps potential, not destiny",
                    "Self-knowledge is the purpose of chart interpretation",
                ]
            ),
            LibraryChapter(
                number: 2,
                title: "The Luminaries",
                subtitle: "Sun and Moon as the poles of identity",
                category: .planets,
                readingTimeMinutes: 15,
                isRead: true,
                body: "The Sun and Moon form the central axis of your chart \u{2014} the two poles between which your identity oscillates.\n\nThe Sun represents your conscious identity: who you are becoming. It is the principle of individuation, the drive to express your unique essence in the world. When you say \"I am,\" you speak from your Sun.\n\nThe Moon represents your emotional body: who you already are at the deepest level. It is the repository of memory, instinct, and unconscious pattern. When you feel \"at home\" somewhere, your Moon is activated.\n\nThe relationship between these two luminaries \u{2014} their signs, houses, and the aspect between them \u{2014} describes the fundamental dialogue within your psyche. Are your conscious aims aligned with your emotional needs? Or do they pull in different directions, creating a productive tension that drives growth?\n\nNeither luminary is more important than the other. The Sun without the Moon is all ambition and no soul. The Moon without the Sun is all feeling and no direction. Your developmental work is to honor both \u{2014} to build a life that satisfies your need for meaning (Sun) and belonging (Moon).",
                keyConcepts: [
                    "Sun represents conscious identity and individuation",
                    "Moon represents emotional body and instinctual patterns",
                    "Their relationship describes your central psychological dialogue",
                    "Developmental growth requires honoring both luminaries",
                ]
            ),
            LibraryChapter(
                number: 3,
                title: "The Inner Planets",
                subtitle: "Mercury, Venus, and Mars as personal expression",
                category: .planets,
                readingTimeMinutes: 14,
                isRead: false,
                body: "If the Sun and Moon are the poles of identity, Mercury, Venus, and Mars are the instruments through which that identity engages the world.\n\nMercury governs perception and communication \u{2014} how you take in information and how you share it. Your Mercury sign reveals not just how you think, but what you notice. A Mercury in Scorpio perceives undercurrents; a Mercury in Sagittarius perceives patterns and meaning.\n\nVenus governs attraction and values \u{2014} what you find beautiful, what you draw toward yourself, how you create harmony. Far from being merely about romance, Venus describes your aesthetic sense, your relationship to pleasure, and your deepest values.\n\nMars governs desire and action \u{2014} how you pursue what you want, how you assert boundaries, how you channel aggression into purpose. Mars is the engine of your chart, providing the fuel for all other planetary functions.\n\nTogether, these three planets form the toolkit of personal expression. Understanding them is understanding how you naturally engage with life.",
                keyConcepts: [
                    "Mercury shapes perception and communication style",
                    "Venus defines values, aesthetics, and what you attract",
                    "Mars drives desire, assertion, and purposeful action",
                    "These three form your toolkit for engaging with life",
                ]
            ),
            LibraryChapter(
                number: 4,
                title: "The Angular Houses",
                subtitle: "Identity, home, relationship, and vocation",
                category: .houses,
                readingTimeMinutes: 16,
                isRead: false,
                body: "The angular houses \u{2014} the 1st, 4th, 7th, and 10th \u{2014} form the cross upon which your life is built. They represent the four cardinal directions of experience: who you are, where you come from, who you meet, and what you contribute.\n\nThe 1st House is the house of self \u{2014} your rising sign, your personal style, the mask you show the world. It describes not who you are essentially (that is the Sun) but how you approach life, the lens through which all experience is filtered.\n\nThe 4th House is the house of foundations \u{2014} your roots, your private self, your emotional base. Here we find the patterns inherited from family, the sense of belonging that sustains or challenges you.\n\nThe 7th House is the house of the other \u{2014} partnerships, projections, and the qualities you seek in relationship. What you find here often represents what you have not yet integrated in yourself.\n\nThe 10th House is the house of calling \u{2014} your public role, your contribution, the legacy you build. It represents not just career but the way you meet the world's need with your deepest gifts.",
                keyConcepts: [
                    "1st House: Self-presentation and approach to life",
                    "4th House: Roots, foundations, and private self",
                    "7th House: Partnership and projection of unlived qualities",
                    "10th House: Vocation, calling, and public contribution",
                ]
            ),
            LibraryChapter(
                number: 5,
                title: "The Language of Aspects",
                subtitle: "How planetary relationships shape experience",
                category: .aspects,
                readingTimeMinutes: 18,
                isRead: false,
                body: "Aspects are the angles between planets, and they describe the relationships within your psyche. Just as people in relationship create something beyond either individual, planets in aspect create emergent psychological dynamics.\n\nThe conjunction (0 degrees) is fusion \u{2014} two planetary principles merged into a single expression. A Sun-Moon conjunction means your conscious and unconscious aims are aligned, for better or worse. There is power in this unity, but also the risk of blind spots.\n\nThe opposition (180 degrees) is awareness through contrast. Planets in opposition create a seesaw dynamic, pulling you between two valid but seemingly contradictory needs. The gift of the opposition is perspective \u{2014} the ability to see from multiple vantage points.\n\nThe square (90 degrees) is creative friction. This is the aspect of growth through challenge. Squares create tension that demands resolution, and in that demand lies the energy for transformation.\n\nThe trine (120 degrees) is natural flow. Planets in trine support each other effortlessly, creating areas of ease and talent. The challenge of the trine is complacency \u{2014} gifts so natural they go undeveloped.\n\nThe sextile (60 degrees) is opportunity. Less dramatic than the trine, the sextile represents potential that requires conscious effort to activate. These are the doors that open when you knock.",
                keyConcepts: [
                    "Conjunction: fusion of planetary principles",
                    "Opposition: awareness through contrast and polarity",
                    "Square: creative friction that drives transformation",
                    "Trine: natural flow and ease that may need conscious development",
                    "Sextile: latent opportunity activated through effort",
                ]
            ),
        ]
    }
}
