// MARK: - Glossary Journal — Living Reference of LCD Terms
// Searchable, cross-referenced, with bookmarks and personal annotations.
// Each term links to book sections, practices, and related terms.
// "The vocabulary of your becoming."

import SwiftUI

// MARK: - Glossary Data

struct GlossaryTerm: Identifiable, Codable {
    let id: UUID
    let term: String
    let definition: String
    let category: Category
    let relatedTerms: [String]
    let bookReferences: [BookReference]
    let practiceReferences: [String]    // Practice IDs
    let example: String?
    let quote: String?
    var userNote: String?               // Personal annotation
    var isBookmarked: Bool

    enum Category: String, Codable, CaseIterable {
        case core               = "Core Concepts"
        case developmentalOrder = "Developmental Orders"
        case somaticSeason      = "Somatic Seasons"
        case practice           = "Practices"
        case pitfall            = "Common Pitfalls"
        case relational         = "Relational Dynamics"
        case clinical           = "Clinical/Professional"
        case luminous           = "Luminous Innovations"
    }

    struct BookReference: Codable {
        let chapter: Int
        let section: String
    }
}

// MARK: - Glossary View

struct GlossaryView: View {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var viewModel = GlossaryViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: GlossaryTerm.Category?
    @State private var selectedTerm: GlossaryTerm?
    @State private var showBookmarksOnly = false

    var filteredTerms: [GlossaryTerm] {
        viewModel.terms.filter { term in
            let matchesSearch = searchText.isEmpty ||
                term.term.localizedCaseInsensitiveContains(searchText) ||
                term.definition.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || term.category == selectedCategory
            let matchesBookmark = !showBookmarksOnly || term.isBookmarked
            return matchesSearch && matchesCategory && matchesBookmark
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.textMuted)
                        TextField("Search terms...", text: $searchText)
                            .font(.custom("Manrope", size: 15))
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(theme.textMuted)
                            }
                        }
                        Button(action: { showBookmarksOnly.toggle() }) {
                            Image(systemName: showBookmarksOnly ? "bookmark.fill" : "bookmark")
                                .foregroundColor(showBookmarksOnly ? theme.goldPrimary : theme.textMuted)
                        }
                    }
                    .padding(12)
                    .background(theme.forestBase.opacity(0.04))

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryChip(label: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            ForEach(GlossaryTerm.Category.allCases, id: \.self) { category in
                                CategoryChip(
                                    label: category.rawValue,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = selectedCategory == category ? nil : category
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }

                    // Terms list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Section headers by letter
                            let grouped = Dictionary(grouping: filteredTerms) { String($0.term.prefix(1)).uppercased() }
                            let sortedKeys = grouped.keys.sorted()

                            ForEach(sortedKeys, id: \.self) { letter in
                                Section {
                                    ForEach(grouped[letter] ?? []) { term in
                                        GlossaryTermCard(
                                            term: term,
                                            onTap: { selectedTerm = term },
                                            onBookmark: { viewModel.toggleBookmark(term) }
                                        )
                                    }
                                } header: {
                                    HStack {
                                        Text(letter)
                                            .font(.custom("Cormorant Garamond", size: 24))
                                            .foregroundColor(theme.goldPrimary)
                                        Spacer()
                                    }
                                    .padding(.top, 16)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Glossary")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedTerm) { term in
                GlossaryTermDetailView(term: term, allTerms: viewModel.terms)
            }
        }
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.custom("Manrope", size: 12).weight(.medium))
                .foregroundColor(isSelected ? theme.cream : theme.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? theme.forestBase : theme.forestBase.opacity(0.06))
                )
        }
    }
}

// MARK: - Glossary Term Card

struct GlossaryTermCard: View {
    let term: GlossaryTerm
    let onTap: () -> Void
    let onBookmark: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Category color indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(colorForCategory(term.category))
                    .frame(width: 4, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(term.term)
                            .font(.custom("Manrope", size: 16).weight(.medium))
                            .foregroundColor(theme.text)
                        Spacer()
                        Text(term.category.rawValue)
                            .font(.custom("Manrope", size: 10))
                            .foregroundColor(theme.textMuted)
                    }
                    Text(term.definition)
                        .font(.custom("Manrope", size: 13))
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(2)
                        .lineSpacing(2)

                    // User note indicator
                    if let note = term.userNote, !note.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "note.text")
                                .font(.system(size: 10))
                            Text("Your note attached")
                                .font(.custom("Manrope", size: 10))
                        }
                        .foregroundColor(theme.goldPrimary)
                    }
                }

                // Bookmark
                Button(action: onBookmark) {
                    Image(systemName: term.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(term.isBookmarked ? theme.goldPrimary : theme.textMuted)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.surface.opacity(0.72))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.goldPrimary.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private func colorForCategory(_ category: GlossaryTerm.Category) -> Color {
        switch category {
        case .core:               return Color(hex: "C5A059")
        case .developmentalOrder: return Color(hex: "4A9A6A")
        case .somaticSeason:      return Color(hex: "8B6BB0")
        case .practice:           return Color(hex: "5A8AB0")
        case .pitfall:            return Color(hex: "B07A5A")
        case .relational:         return Color(hex: "E8A87C")
        case .clinical:           return Color(hex: "D4956B")
        case .luminous:           return Color(hex: "C5A059")
        }
    }
}

// MARK: - Glossary Term Detail

struct GlossaryTermDetailView: View {
    let term: GlossaryTerm
    let allTerms: [GlossaryTerm]
    @EnvironmentObject var theme: ThemeManager
    @State private var userNote: String
    @State private var showShareSheet = false

    init(term: GlossaryTerm, allTerms: [GlossaryTerm]) {
        self.term = term
        self.allTerms = allTerms
        self._userNote = State(initialValue: term.userNote ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Term header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(term.term)
                            .font(.custom("Cormorant Garamond", size: 32))
                            .foregroundColor(theme.text)

                        Text(term.category.rawValue)
                            .font(.custom("Manrope", size: 12).weight(.semibold))
                            .foregroundColor(theme.goldPrimary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }

                    // Definition
                    Text(term.definition)
                        .font(.custom("Manrope", size: 17))
                        .foregroundColor(theme.text)
                        .lineSpacing(6)

                    // Quote
                    if let quote = term.quote {
                        Text(quote)
                            .font(.custom("Cormorant Garamond", size: 18).italic())
                            .foregroundColor(theme.textSecondary)
                            .lineSpacing(4)
                            .padding(.leading, 16)
                            .overlay(alignment: .leading) {
                                Rectangle()
                                    .fill(theme.goldPrimary.opacity(0.3))
                                    .frame(width: 3)
                            }
                    }

                    // Example
                    if let example = term.example {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Example")
                                .font(.custom("Manrope", size: 12).weight(.semibold))
                                .foregroundColor(theme.textSecondary)
                                .textCase(.uppercase)
                            Text(example)
                                .font(.custom("Manrope", size: 15))
                                .foregroundColor(theme.text)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.forestBase.opacity(0.04))
                        )
                    }

                    // Related terms
                    if !term.relatedTerms.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Related Terms")
                                .font(.custom("Manrope", size: 12).weight(.semibold))
                                .foregroundColor(theme.textSecondary)
                                .textCase(.uppercase)

                            FlowLayout(spacing: 8) {
                                ForEach(term.relatedTerms, id: \.self) { related in
                                    Button(action: { /* Navigate to related term */ }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.turn.right.up")
                                                .font(.system(size: 10))
                                            Text(related)
                                                .font(.custom("Manrope", size: 13))
                                        }
                                        .foregroundColor(theme.forestBase)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .stroke(theme.forestBase.opacity(0.15), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // Book references
                    if !term.bookReferences.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("In the Book")
                                .font(.custom("Manrope", size: 12).weight(.semibold))
                                .foregroundColor(theme.textSecondary)
                                .textCase(.uppercase)

                            ForEach(Array(term.bookReferences.enumerated()), id: \.offset) { _, ref in
                                Button(action: { /* Navigate to book position */ }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "book")
                                            .foregroundColor(theme.goldPrimary)
                                        Text("Chapter \(ref.chapter): \(ref.section)")
                                            .font(.custom("Manrope", size: 14))
                                            .foregroundColor(theme.text)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(theme.textMuted)
                                    }
                                }
                            }
                        }
                    }

                    // Personal note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Note")
                            .font(.custom("Manrope", size: 12).weight(.semibold))
                            .foregroundColor(theme.goldPrimary)
                            .textCase(.uppercase)

                        TextEditor(text: $userNote)
                            .font(.custom("Manrope", size: 15))
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.goldPrimary.opacity(0.04))
                            )
                            .overlay(
                                Group {
                                    if userNote.isEmpty {
                                        Text("Add your own understanding of this term...")
                                            .font(.custom("Manrope", size: 15))
                                            .foregroundColor(theme.textMuted)
                                            .padding(16)
                                            .allowsHitTesting(false)
                                    }
                                }, alignment: .topLeading
                            )
                    }
                }
                .padding(20)
            }
            .background(theme.background)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button(action: { /* Toggle bookmark */ }) {
                            Image(systemName: term.isBookmarked ? "bookmark.fill" : "bookmark")
                                .foregroundColor(term.isBookmarked ? theme.goldPrimary : theme.text)
                        }
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareCardPreview(text: "\(term.term) — \(term.definition)")
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

// MARK: - View Model

@MainActor
final class GlossaryViewModel: ObservableObject {
    @Published var terms: [GlossaryTerm] = GlossaryData.allTerms

    func toggleBookmark(_ term: GlossaryTerm) {
        if let index = terms.firstIndex(where: { $0.id == term.id }) {
            terms[index].isBookmarked.toggle()
        }
    }
}

// MARK: - Built-in Glossary Data

enum GlossaryData {
    static let allTerms: [GlossaryTerm] = [
        GlossaryTerm(id: UUID(), term: "Subject", definition: "That which has us — the aspects of our experience we are so embedded in that we cannot see them as objects of reflection. Subject is the water the fish doesn't know it's swimming in.", category: .core, relatedTerms: ["Object", "Subject-Object Shift", "Meaning-Making"], bookReferences: [.init(chapter: 1, section: "The Architecture of Meaning-Making"), .init(chapter: 2, section: "A Precise Definition")], practiceReferences: [], example: "If anger has you (subject), you ARE your anger. If you have anger (object), you can notice, name, and choose how to respond to it.", quote: "We do not see the world as it is. We see the world as we are.", userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Object", definition: "That which we have — the aspects of our experience we can observe, reflect on, examine, and potentially choose differently about. What was once subject can become object through development.", category: .core, relatedTerms: ["Subject", "Subject-Object Shift", "Objectification"], bookReferences: [.init(chapter: 2, section: "The Felt Sense of Object")], practiceReferences: [], example: "When you can say 'I notice I'm feeling defensive' rather than simply being defensive, your defensiveness has become object.", quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Subject-Object Shift", definition: "The fundamental movement of development: what was once subject (invisible, embedded, automatic) becomes object (visible, examinable, chooseable). This is the most intimate transformation a human being can undergo.", category: .core, relatedTerms: ["Subject", "Object", "Developmental Order", "Growing Edge"], bookReferences: [.init(chapter: 2, section: "The Invisible Architecture")], practiceReferences: [], example: nil, quote: "Every subject-object shift is a small death and a small birth — the old self releasing, the new self forming.", userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Somatic Season", definition: "The body's felt sense of where it is in a developmental transition. Five seasons: Compression, Trembling, Emptiness, Emergence, Integration. These are not linear — they can cycle and overlap.", category: .somaticSeason, relatedTerms: ["Compression", "Trembling", "Emptiness", "Emergence", "Integration"], bookReferences: [.init(chapter: 3, section: "The Somatic Seasons of Development")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Compression", definition: "The first somatic season. Increasing tension as the old structure strains against life demands it cannot accommodate. The body tightens, constricts, holds.", category: .somaticSeason, relatedTerms: ["Somatic Season", "Trembling", "Optimal Frustration"], bookReferences: [.init(chapter: 3, section: "The Somatic Seasons of Development")], practiceReferences: [], example: "A leader who has always deferred to authority begins to feel a growing constriction every time they swallow their own perspective in a meeting.", quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Optimal Frustration", definition: "The Goldilocks zone of developmental demand — enough challenge to provoke growth, but not so much that it overwhelms the system. Too little frustration = stagnation. Too much = collapse or regression.", category: .core, relatedTerms: ["Holding Environment", "Growing Edge", "Compression"], bookReferences: [.init(chapter: 3, section: "Optimal Frustration")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Holding Environment", definition: "A relational context that provides enough safety for a person to tolerate the anxiety of developmental movement. Not a bubble — a container strong enough to hold the trembling.", category: .relational, relatedTerms: ["Optimal Frustration", "Developmental Relationship"], bookReferences: [.init(chapter: 3, section: "Holding Environments")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Developmental Vanity", definition: "The subtle temptation to use developmental frameworks as a way to feel superior to others. A pitfall where the framework itself becomes a tool of the very ego it claims to transcend.", category: .pitfall, relatedTerms: ["Subject-Object Shift", "Self-Authoring Mind"], bookReferences: [.init(chapter: 2, section: "Developmental Vanity")], practiceReferences: [], example: "Thinking 'I'm at the fourth order and they're clearly still at the third' is itself a third-order move — deriving identity from a framework.", quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Cognitive Bypassing", definition: "Using intellectual understanding of development as a substitute for the lived, embodied, relational work of actually developing. Knowing about subject-object dynamics without experiencing the shift.", category: .pitfall, relatedTerms: ["Developmental Vanity", "Somatic Season", "Premature Objectification"], bookReferences: [.init(chapter: 2, section: "Cognitive Bypassing")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Self-Authoring Mind", definition: "The fourth order of consciousness. Capacity to generate one's own values, beliefs, and identity independent of external validation. Internal authority guides decisions.", category: .developmentalOrder, relatedTerms: ["Socialized Mind", "Self-Transforming Mind", "Developmental Order"], bookReferences: [.init(chapter: 3, section: "The Self-Authoring Mind (Fourth Order)")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Self-Transforming Mind", definition: "The fifth order of consciousness. Capacity to hold multiple frameworks simultaneously, see the limits of any single identity, and rest in paradox. Not superiority — deepening wholeness.", category: .developmentalOrder, relatedTerms: ["Self-Authoring Mind", "Developmental Order", "Paradox"], bookReferences: [.init(chapter: 3, section: "The Self-Transforming Mind (Fifth Order)")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Luminous Invitation", definition: "A practice invitation within the LCD text that offers an experiential doorway into the concept being discussed. Not an exercise to complete — an invitation to inhabit.", category: .luminous, relatedTerms: ["Subject Scan", "Relational Mirror", "Somatic Witness Practice"], bookReferences: [], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Subject Scan", definition: "A Luminous practice of identifying what currently has you — scanning for the invisible assumptions, feelings, and patterns that feel like 'just the way things are' rather than perspectives.", category: .practice, relatedTerms: ["Subject", "Object", "Subject-Object Shift"], bookReferences: [.init(chapter: 2, section: "The Subject Scan")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Somatic Witness Practice", definition: "A practice of turning non-judgmental attention to the body's sensations — noticing without changing, witnessing without interpreting. The body often knows what the mind has not yet articulated.", category: .practice, relatedTerms: ["Somatic Season", "Body Map", "Nervous System"], bookReferences: [.init(chapter: 2, section: "The Somatic Witness Practice")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Growing Edge", definition: "The boundary between what is currently subject and what is beginning to become object. The place of maximum developmental aliveness — and maximum vulnerability.", category: .core, relatedTerms: ["Subject-Object Shift", "Optimal Frustration", "Trembling"], bookReferences: [.init(chapter: 2, section: "The In-Between")], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),

        GlossaryTerm(id: UUID(), term: "Resonance", definition: "The felt sense of mutual recognition — when two meaning-making systems touch and something new becomes possible. Not agreement, not merger. A vibration that arises between.", category: .luminous, relatedTerms: ["Holding Environment", "Relational Mirror"], bookReferences: [], practiceReferences: [], example: nil, quote: nil, userNote: nil, isBookmarked: false),
    ]
}
