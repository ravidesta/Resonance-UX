// ChapterLibraryView.swift
// Luminous Cosmic Architecture™
// Book Chapters Browser

import SwiftUI

// MARK: - Chapter Library View

struct ChapterLibraryView: View {
    @Environment(\.resonanceTheme) var theme
    @State private var selectedChapter: BookChapter?
    @State private var searchText = ""
    @State private var appear = false

    private let chapters = ChapterLibraryData.chapters

    var filteredChapters: [BookChapter] {
        if searchText.isEmpty { return chapters }
        return chapters.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.subtitle.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackgroundMinimal()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: ResonanceSpacing.lg) {
                        headerSection

                        // Search
                        searchBar

                        // Chapter Cards
                        LazyVStack(spacing: ResonanceSpacing.md) {
                            ForEach(Array(filteredChapters.enumerated()), id: \.element.id) { index, chapter in
                                ChapterCard(chapter: chapter, index: index)
                                    .onTapGesture {
                                        selectedChapter = chapter
                                        ResonanceHaptics.light()
                                    }
                                    .opacity(appear ? 1 : 0)
                                    .offset(y: appear ? 0 : 20)
                                    .animation(
                                        ResonanceAnimation.springSmooth.delay(Double(index) * 0.08),
                                        value: appear
                                    )
                            }
                        }

                        Spacer(minLength: ResonanceSpacing.xxxl)
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedChapter) { chapter in
                ChapterDetailView(chapter: chapter)
            }
            .onAppear {
                withAnimation {
                    appear = true
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            Text("Chapter Library")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)

            Text("Explore the luminous cosmic architecture of your developmental map")
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResonanceSpacing.xxl)
        .padding(.horizontal, ResonanceSpacing.xs)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: ResonanceSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.textTertiary)

            TextField("Search chapters...", text: $searchText)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textPrimary)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.textTertiary)
                }
            }
        }
        .padding(ResonanceSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ResonanceRadius.md)
                .fill(theme.surface.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: ResonanceRadius.md)
                .strokeBorder(theme.border, lineWidth: 0.5)
        )
    }
}

// MARK: - Chapter Card

struct ChapterCard: View {
    let chapter: BookChapter
    let index: Int
    @Environment(\.resonanceTheme) var theme
    @State private var isPressed = false

    private var accentColor: Color {
        let colors: [Color] = [
            ResonanceColors.goldPrimary,
            ResonanceColors.water,
            ResonanceColors.earth,
            ResonanceColors.air,
            ResonanceColors.fire,
            ResonanceColors.goldDark
        ]
        return colors[index % colors.count]
    }

    var body: some View {
        HStack(spacing: ResonanceSpacing.md) {
            // Chapter number
            ZStack {
                RoundedRectangle(cornerRadius: ResonanceRadius.sm)
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 56, height: 56)

                VStack(spacing: 0) {
                    Text("CH")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                    Text("\(chapter.number)")
                        .font(.system(size: 22, weight: .light, design: .serif))
                }
                .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
                Text(chapter.title)
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)
                    .lineLimit(1)

                Text(chapter.subtitle)
                    .font(ResonanceTypography.bodySmall)
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)

                Text(chapter.description)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
                    .lineLimit(2)
                    .lineSpacing(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.textTertiary)
        }
        .padding(ResonanceSpacing.md)
        .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(ResonanceAnimation.springBouncy) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Chapter \(chapter.number): \(chapter.title). \(chapter.subtitle)")
        .accessibilityHint("Tap to read")
    }
}

// MARK: - Chapter Detail View

struct ChapterDetailView: View {
    let chapter: BookChapter
    @Environment(\.resonanceTheme) var theme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            CosmicBackgroundMinimal()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(theme.textSecondary)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(theme.surface.opacity(0.5)))
                            }

                            Spacer()
                        }

                        Text("Chapter \(chapter.number)")
                            .font(ResonanceTypography.overline)
                            .foregroundColor(theme.accent)
                            .textCase(.uppercase)
                            .tracking(2)

                        Text(chapter.title)
                            .font(ResonanceTypography.displayMedium)
                            .foregroundColor(theme.textPrimary)

                        Text(chapter.subtitle)
                            .font(ResonanceTypography.bodyLarge)
                            .foregroundColor(theme.textSecondary)
                            .italic()
                    }
                    .padding(.top, ResonanceSpacing.md)

                    Divider().background(theme.border)

                    // Sections
                    ForEach(chapter.content) { section in
                        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                            Text(section.title)
                                .font(ResonanceTypography.headlineLarge)
                                .foregroundColor(theme.textPrimary)

                            Text(section.body)
                                .font(ResonanceTypography.bodyMedium)
                                .foregroundColor(theme.textSecondary)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer(minLength: ResonanceSpacing.xxxl)
                }
                .padding(.horizontal, ResonanceSpacing.lg)
            }
        }
    }
}

// MARK: - Chapter Data

struct ChapterLibraryData {
    static let chapters: [BookChapter] = [
        BookChapter(
            number: 1,
            title: "The Cosmic Blueprint",
            subtitle: "Understanding Your Birth Chart",
            description: "An introduction to the natal chart as a developmental map of consciousness",
            iconName: "sparkles",
            content: [
                ChapterSection(
                    title: "Your Map of Becoming",
                    body: "The birth chart is not a fixed destiny but a living map of your developmental potential. Like a seed that contains the blueprint for a mighty tree, your natal chart holds the pattern of who you are becoming. Each planet, sign, and house represents a dimension of your consciousness waiting to unfold.\n\nThe luminous cosmic architecture of your chart reveals not what will happen to you, but what wants to happen through you. It is an invitation to participate consciously in your own evolution."
                ),
                ChapterSection(
                    title: "Reading the Language of the Stars",
                    body: "Astrology is a symbolic language that describes the relationship between cosmic patterns and human experience. The zodiac signs represent twelve fundamental modes of being. The planets embody different drives and functions of the psyche. The houses map these energies onto specific areas of life.\n\nLearning to read your chart is like learning to read a new language -- one that speaks directly to your soul's intention for this lifetime."
                ),
                ChapterSection(
                    title: "The Developmental Perspective",
                    body: "Traditional astrology often focuses on prediction and personality description. The developmental approach goes deeper, viewing each chart placement as a growth edge -- an area where consciousness is evolving. Challenging aspects become opportunities for integration. Difficult placements become invitations for mastery.\n\nThis perspective transforms the birth chart from a static portrait into a dynamic developmental curriculum."
                )
            ]
        ),
        BookChapter(
            number: 2,
            title: "The Luminaries",
            subtitle: "Sun, Moon, and the Dance of Light",
            description: "Exploring your core identity and emotional nature through the great lights",
            iconName: "sun.and.horizon",
            content: [
                ChapterSection(
                    title: "The Sun: Your Conscious Purpose",
                    body: "The Sun in your chart represents your conscious identity -- who you are becoming. It is the hero's journey of your life, the central theme around which all other planetary stories orbit. Your Sun sign describes not who you are, but who you are growing into.\n\nThe house placement of your Sun reveals the arena of life where this growth is most active and visible."
                ),
                ChapterSection(
                    title: "The Moon: Your Emotional Foundation",
                    body: "While the Sun reaches toward the future, the Moon connects you to the past -- to your emotional roots, instinctive responses, and deepest needs for security. The Moon sign reveals how you process feelings and what you need to feel nourished and safe.\n\nHonoring your Moon is essential for sustainable growth. Without emotional grounding, the Sun's aspirations become hollow."
                ),
                ChapterSection(
                    title: "The Dance of Day and Night",
                    body: "The relationship between your Sun and Moon -- their signs, houses, and aspect to each other -- reveals one of the most fundamental dynamics in your chart. When Sun and Moon work in harmony, there is an integrated flow between desire and need, ambition and comfort. When they challenge each other, there is a productive tension that drives growth through the reconciliation of opposites."
                )
            ]
        ),
        BookChapter(
            number: 3,
            title: "The Personal Planets",
            subtitle: "Mercury, Venus, and Mars",
            description: "How you think, love, and act in the world",
            iconName: "person.3",
            content: [
                ChapterSection(
                    title: "Mercury: The Messenger",
                    body: "Mercury shapes how you perceive, process, and communicate information. Your Mercury sign and house reveal your learning style, communication preferences, and the way your mind naturally organizes reality.\n\nDeveloping Mercury means becoming more conscious of your thought patterns and learning to use the mind as a tool for understanding rather than being used by it."
                ),
                ChapterSection(
                    title: "Venus: The Heart's Desire",
                    body: "Venus governs your relationship to beauty, love, pleasure, and values. Your Venus placement reveals what you find attractive, how you express affection, and what you truly value.\n\nThe developmental work of Venus is learning to receive as well as give, to honor your aesthetic sensibilities, and to create relationships that reflect your deepest values."
                ),
                ChapterSection(
                    title: "Mars: The Sacred Warrior",
                    body: "Mars represents your drive, assertiveness, and capacity for action. Where Venus receives, Mars initiates. Your Mars sign and house show how you assert yourself, pursue goals, and handle conflict.\n\nMature Mars energy is neither aggressive nor passive -- it is the focused courage to act in alignment with your truth."
                )
            ]
        ),
        BookChapter(
            number: 4,
            title: "The Social Planets",
            subtitle: "Jupiter and Saturn as Teachers",
            description: "Growth, expansion, and the structures that support your evolution",
            iconName: "building.columns",
            content: [
                ChapterSection(
                    title: "Jupiter: The Great Benefic",
                    body: "Jupiter expands whatever it touches. It represents faith, meaning, and the quest for understanding. Your Jupiter placement reveals where life naturally opens doors for you, where growth comes easily, and where you find your greatest sense of meaning."
                ),
                ChapterSection(
                    title: "Saturn: The Wise Teacher",
                    body: "Saturn represents structure, responsibility, and the wisdom that comes through experience. Rather than limiting you, Saturn shows where you are building enduring foundations. Your Saturn placement reveals your greatest areas of mastery -- but only through committed effort and time."
                )
            ]
        ),
        BookChapter(
            number: 5,
            title: "The Outer Planets",
            subtitle: "Uranus, Neptune, and Pluto",
            description: "Transpersonal forces of awakening, dissolution, and transformation",
            iconName: "wand.and.stars",
            content: [
                ChapterSection(
                    title: "Beyond the Personal",
                    body: "The outer planets operate on a transpersonal level. They represent forces larger than the individual ego -- collective patterns of evolution that move through us. When outer planets aspect your personal planets, they catalyze profound transformation."
                ),
                ChapterSection(
                    title: "Uranus: The Awakener",
                    body: "Uranus shatters outdated structures to make room for authentic expression. It represents sudden insight, liberation, and the courage to be truly yourself. Uranus transits feel like lightning strikes -- disruptive but illuminating."
                )
            ]
        ),
        BookChapter(
            number: 6,
            title: "The Houses",
            subtitle: "Twelve Domains of Experience",
            description: "Understanding the areas of life where your chart energies manifest",
            iconName: "square.grid.3x4",
            content: [
                ChapterSection(
                    title: "The Stage of Life",
                    body: "If the planets are actors and the signs are their costumes and styles, the houses are the stages on which they perform. The twelve houses divide your life into twelve distinct arenas of experience, from identity (1st house) to the collective unconscious (12th house)."
                ),
                ChapterSection(
                    title: "Angular, Succedent, Cadent",
                    body: "The angular houses (1, 4, 7, 10) represent cardinal areas of life -- identity, home, relationships, and career. Planets here are prominently expressed. Succedent houses (2, 5, 8, 11) consolidate and stabilize. Cadent houses (3, 6, 9, 12) distribute and refine."
                )
            ]
        ),
        BookChapter(
            number: 7,
            title: "Aspects and Dialogue",
            subtitle: "How Your Planets Communicate",
            description: "The geometric conversations between chart energies",
            iconName: "triangle",
            content: [
                ChapterSection(
                    title: "The Language of Geometry",
                    body: "Aspects are the angular relationships between planets. They reveal how different parts of your psyche communicate with each other. Harmonious aspects (trines, sextiles) represent natural flow and talent. Challenging aspects (squares, oppositions) represent creative tension and growth edges."
                ),
                ChapterSection(
                    title: "Working with Tension",
                    body: "The most dynamic charts often contain significant squares and oppositions. These are not problems to be solved but creative tensions to be worked with. Every square contains the seed of enormous creative power. Every opposition invites the development of a larger perspective that can hold both sides."
                )
            ]
        ),
        BookChapter(
            number: 8,
            title: "Transits and Timing",
            subtitle: "The Cosmic Weather Report",
            description: "How current planetary movements activate your natal chart",
            iconName: "clock.arrow.2.circlepath",
            content: [
                ChapterSection(
                    title: "Life's Rhythm",
                    body: "Transits are the current positions of the planets as they interact with your birth chart. They represent the timing mechanism of your developmental process -- when certain themes become activated and growth opportunities arise."
                ),
                ChapterSection(
                    title: "Major Life Transits",
                    body: "Certain transits mark universal developmental milestones: the Saturn Return at 29, the Uranus Opposition at 42, the Chiron Return at 50. Understanding these cycles helps you cooperate with life's natural rhythm of growth and transformation."
                )
            ]
        )
    ]
}
