// LearnView.swift
// Luminous Attachment — Resonance UX
// eBook reader with chapter sidebar, glossary, audiobook controls, bookmarks, sharing

import SwiftUI

struct LearnView: View {
    @Environment(UserProfile.self) private var userProfile
    @Environment(AudiobookPlayer.self) private var audiobookPlayer
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedChapter: Chapter?
    @State private var showGlossary = false
    @State private var showAudioControls = false
    @State private var showSharePassage = false
    @State private var selectedPassage = ""
    @State private var searchText = ""
    @State private var fontSize: CGFloat = 17
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    private var chapters: [Chapter] { EBookContent.chapters }
    private var glossary: [GlossaryTerm] { EBookContent.glossary }

    private var filteredChapters: [Chapter] {
        if searchText.isEmpty { return chapters }
        return chapters.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // MARK: - Sidebar
            chapterSidebar
        } detail: {
            // MARK: - Detail
            if let chapter = selectedChapter {
                chapterDetailView(chapter)
            } else {
                welcomeView
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showGlossary) {
            glossarySheet
        }
        .sheet(isPresented: $showSharePassage) {
            ActivityViewControllerRepresentable(
                activityItems: [
                    "\"\(selectedPassage)\"\n\nFrom \"Luminous Attachment\" by Resonance UX"
                ]
            )
            .presentationDetents([.medium])
        }
    }

    // MARK: - Chapter Sidebar

    private var chapterSidebar: some View {
        List(filteredChapters, selection: $selectedChapter) { chapter in
            NavigationLink(value: chapter) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                userProfile.completedChapters.contains(chapter.id)
                                    ? ResonanceColors.goldPrimary.opacity(0.2)
                                    : ResonanceColors.surfaceSecondary(for: colorScheme)
                            )
                            .frame(width: 40, height: 40)

                        if userProfile.completedChapters.contains(chapter.id) {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(ResonanceColors.goldPrimary)
                        } else {
                            Text("\(chapter.id)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ResonanceColors.text(for: colorScheme))
                            .lineLimit(1)

                        Text(chapter.subtitle)
                            .font(.caption)
                            .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                            .lineLimit(2)

                        HStack(spacing: 8) {
                            Label("\(chapter.estimatedReadingMinutes)m read", systemImage: "book")
                            Label("\(chapter.audioDurationMinutes)m listen", systemImage: "headphones")
                        }
                        .font(.caption2)
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Chapters")
        .searchable(text: $searchText, prompt: "Search chapters...")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showGlossary = true
                } label: {
                    Image(systemName: "text.book.closed")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Welcome View

    private var welcomeView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundStyle(ResonanceColors.goldPrimary.opacity(0.5))

            Text("Luminous Attachment")
                .font(.title.weight(.bold))
                .foregroundStyle(ResonanceColors.text(for: colorScheme))

            Text("Your guide to understanding and healing\nattachment patterns")
                .font(.subheadline)
                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                .multilineTextAlignment(.center)

            Text("Select a chapter to begin reading")
                .font(.caption)
                .foregroundStyle(ResonanceColors.goldPrimary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(ResonanceColors.background(for: colorScheme))
    }

    // MARK: - Chapter Detail

    private func chapterDetailView(_ chapter: Chapter) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Chapter header
                VStack(alignment: .leading, spacing: 8) {
                    Text(chapter.chapterLabel.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                        .tracking(2)

                    Text(chapter.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(ResonanceColors.text(for: colorScheme))

                    Text(chapter.subtitle)
                        .font(.title3)
                        .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))

                    Divider()
                        .overlay(ResonanceColors.goldPrimary.opacity(0.3))
                        .padding(.top, 8)
                }

                // Audiobook quick play
                Button {
                    audiobookPlayer.playChapter(chapter.id)
                    showAudioControls = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: audiobookPlayer.isPlaying && audiobookPlayer.currentChapterIndex == chapter.id - 1
                              ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundStyle(ResonanceColors.goldPrimary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Listen to this chapter")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(ResonanceColors.text(for: colorScheme))
                            Text("\(chapter.audioDurationMinutes) minutes")
                                .font(.caption)
                                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                        }

                        Spacer()

                        Image(systemName: "headphones")
                            .foregroundStyle(ResonanceColors.goldPrimary.opacity(0.5))
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ResonanceColors.goldPrimary.opacity(0.15), lineWidth: 0.5)
                            }
                    }
                }
                .buttonStyle(.plain)

                // Chapter content paragraphs
                let paragraphs = chapter.content.components(separatedBy: "\n\n")
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                    let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        Text(trimmed)
                            .font(.system(size: fontSize, weight: .regular, design: .serif))
                            .foregroundStyle(ResonanceColors.text(for: colorScheme))
                            .lineSpacing(8)
                            .textSelection(.enabled)
                            .contextMenu {
                                Button {
                                    selectedPassage = trimmed
                                    showSharePassage = true
                                } label: {
                                    Label("Share Passage", systemImage: "square.and.arrow.up")
                                }

                                Button {
                                    let highlight = Highlight(chapterId: chapter.id, text: trimmed)
                                    userProfile.highlights.append(highlight)
                                } label: {
                                    Label("Highlight", systemImage: "highlighter")
                                }

                                Button {
                                    let bookmark = Bookmark(chapterId: chapter.id, position: index)
                                    userProfile.bookmarks.append(bookmark)
                                } label: {
                                    Label("Bookmark", systemImage: "bookmark")
                                }
                            }
                    }
                }

                // Reflection prompts
                if !chapter.reflectionPrompts.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                            .overlay(ResonanceColors.goldPrimary.opacity(0.3))

                        Label("Reflection Prompts", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(ResonanceColors.goldPrimary)

                        ForEach(chapter.reflectionPrompts, id: \.self) { prompt in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundStyle(ResonanceColors.goldPrimary)
                                    .padding(.top, 6)

                                Text(prompt)
                                    .font(.subheadline)
                                    .foregroundStyle(ResonanceColors.text(for: colorScheme))
                                    .lineSpacing(4)
                                    .italic()
                            }
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(ResonanceColors.goldPrimary.opacity(0.05))
                    }
                }

                // Key terms
                if !chapter.keyTerms.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Key Terms", systemImage: "text.book.closed")
                            .font(.headline)
                            .foregroundStyle(ResonanceColors.goldPrimary)

                        FlowLayout(spacing: 8) {
                            ForEach(chapter.keyTerms, id: \.self) { term in
                                Button {
                                    showGlossary = true
                                } label: {
                                    Text(term)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(ResonanceColors.goldPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background {
                                            Capsule()
                                                .fill(ResonanceColors.goldPrimary.opacity(0.1))
                                                .overlay {
                                                    Capsule()
                                                        .stroke(ResonanceColors.goldPrimary.opacity(0.2), lineWidth: 0.5)
                                                }
                                        }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                // Mark as complete
                Button {
                    withAnimation {
                        if userProfile.completedChapters.contains(chapter.id) {
                            userProfile.completedChapters.remove(chapter.id)
                        } else {
                            userProfile.completedChapters.insert(chapter.id)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: userProfile.completedChapters.contains(chapter.id)
                              ? "checkmark.circle.fill" : "circle")
                        Text(userProfile.completedChapters.contains(chapter.id)
                             ? "Completed" : "Mark as Complete")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ResonanceColors.goldPrimary.opacity(
                                userProfile.completedChapters.contains(chapter.id) ? 0.15 : 0.08
                            ))
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .background(ResonanceColors.background(for: colorScheme))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    // Font size controls
                    Section("Text Size") {
                        Button { fontSize = max(14, fontSize - 1) } label: {
                            Label("Smaller", systemImage: "textformat.size.smaller")
                        }
                        Button { fontSize = min(24, fontSize + 1) } label: {
                            Label("Larger", systemImage: "textformat.size.larger")
                        }
                    }

                    Section {
                        Button {
                            let bookmark = Bookmark(chapterId: chapter.id, position: 0)
                            userProfile.bookmarks.append(bookmark)
                        } label: {
                            Label("Add Bookmark", systemImage: "bookmark")
                        }

                        Button {
                            showGlossary = true
                        } label: {
                            Label("Glossary", systemImage: "text.book.closed")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Glossary Sheet

    private var glossarySheet: some View {
        NavigationStack {
            List {
                ForEach(glossary) { term in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(term.term)
                            .font(.headline)
                            .foregroundStyle(ResonanceColors.goldPrimary)

                        Text(term.definition)
                            .font(.subheadline)
                            .foregroundStyle(ResonanceColors.text(for: colorScheme))
                            .lineSpacing(4)

                        if !term.relatedTerms.isEmpty {
                            HStack(spacing: 6) {
                                Text("Related:")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))

                                ForEach(term.relatedTerms, id: \.self) { related in
                                    Text(related)
                                        .font(.caption)
                                        .foregroundStyle(ResonanceColors.goldPrimary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background {
                                            Capsule()
                                                .fill(ResonanceColors.goldPrimary.opacity(0.1))
                                        }
                                }
                            }
                        }

                        if !term.chapterReferences.isEmpty {
                            Text("Chapters: \(term.chapterReferences.map { "\($0)" }.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundStyle(ResonanceColors.textSecondary(for: colorScheme))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Glossary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showGlossary = false }
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
    }
}

// MARK: - Flow Layout (for key terms)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (positions, CGSize(width: maxX, height: y + rowHeight))
    }
}

// MARK: - Chapter Hashable Conformance

extension Chapter: Hashable {
    static func == (lhs: Chapter, rhs: Chapter) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LearnView()
    }
    .environment(UserProfile())
    .environment(AudiobookPlayer())
    .environment(ThemeManager())
}
