// LearnView.swift
// Luminous Attachment — Resonance UX
// eBook reader with NavigationSplitView, chapter sidebar, glossary, audiobook controls, bookmarks, sharing

import SwiftUI

struct LearnView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(UserProfile.self) private var profile

    @State private var selectedChapterId: Int? = 1
    @State private var showGlossary = false
    @State private var showAudioControls = false
    @State private var showBookmarks = false
    @State private var showSharePassage = false
    @State private var selectedPassage: String = ""
    @State private var glossarySearchText: String = ""
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    private var chapters: [Chapter] { EBookContent.chapters }
    private var glossary: [GlossaryTerm] { EBookContent.glossary }

    private var selectedChapter: Chapter? {
        chapters.first { $0.id == selectedChapterId }
    }

    var body: some View {
        let scheme = theme.effectiveScheme
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // MARK: - Sidebar
            chapterSidebar(scheme: scheme)
        } detail: {
            // MARK: - Detail / Reader
            if let chapter = selectedChapter {
                chapterReaderView(chapter: chapter, scheme: scheme)
            } else {
                emptyStateView(scheme: scheme)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showGlossary) {
            glossarySheet(scheme: scheme)
        }
        .sheet(isPresented: $showBookmarks) {
            bookmarksSheet(scheme: scheme)
        }
        .sheet(isPresented: $showSharePassage) {
            ActivityViewController(
                activityItems: [
                    "\"\(selectedPassage)\"\n\n— Luminous Attachment, \(selectedChapter?.title ?? "")\nBy Resonance UX"
                ]
            )
        }
        .sheet(isPresented: $showAudioControls) {
            audioControlsSheet(scheme: scheme)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Chapter Sidebar

    @ViewBuilder
    private func chapterSidebar(scheme: ColorScheme) -> some View {
        List(chapters, selection: $selectedChapterId) { chapter in
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            profile.completedChapters.contains(chapter.id)
                                ? ResonanceColors.goldPrimary
                                : ResonanceColors.surfaceSecondary(for: scheme)
                        )
                        .frame(width: 32, height: 32)
                    if profile.completedChapters.contains(chapter.id) {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(chapter.id)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(chapter.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(ResonanceColors.text(for: scheme))
                        .lineLimit(1)
                    Text(chapter.subtitle)
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                        .lineLimit(1)
                }

                Spacer()

                Text("\(chapter.estimatedReadingMinutes) min")
                    .font(.caption2)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }
            .padding(.vertical, 4)
            .tag(chapter.id)
        }
        .listStyle(.sidebar)
        .navigationTitle("Chapters")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showGlossary = true
                    } label: {
                        Label("Glossary", systemImage: "textformat.abc")
                    }
                    Button {
                        showBookmarks = true
                    } label: {
                        Label("Bookmarks", systemImage: "bookmark")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Chapter Reader

    @ViewBuilder
    private func chapterReaderView(chapter: Chapter, scheme: ColorScheme) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                // Chapter Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(chapter.chapterLabel.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                        .tracking(1.5)
                    Text(chapter.title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(ResonanceColors.text(for: scheme))
                    Text(chapter.subtitle)
                        .font(.title3)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))

                    HStack(spacing: 16) {
                        Label("\(chapter.estimatedReadingMinutes) min read", systemImage: "clock")
                        Label("\(chapter.audioDurationMinutes) min audio", systemImage: "headphones")
                    }
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                    .padding(.top, 4)
                }
                .padding(.top, 20)

                Divider()
                    .overlay(ResonanceColors.goldPrimary.opacity(0.3))

                // Chapter Content
                let paragraphs = chapter.content.components(separatedBy: "\n\n")
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                    let trimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        Text(trimmed)
                            .font(.body.leading(.loose))
                            .foregroundStyle(ResonanceColors.text(for: scheme))
                            .textSelection(.enabled)
                            .contextMenu {
                                Button {
                                    selectedPassage = trimmed
                                    showSharePassage = true
                                } label: {
                                    Label("Share Passage", systemImage: "square.and.arrow.up")
                                }
                                Button {
                                    let highlight = Highlight(
                                        chapterId: chapter.id,
                                        text: String(trimmed.prefix(100))
                                    )
                                    profile.highlights.append(highlight)
                                } label: {
                                    Label("Highlight", systemImage: "highlighter")
                                }
                            }

                        if index < paragraphs.count - 1 && index % 4 == 3 {
                            // Decorative divider every few paragraphs
                            HStack {
                                Spacer()
                                ForEach(0..<3, id: \.self) { _ in
                                    Circle()
                                        .fill(ResonanceColors.goldPrimary.opacity(0.3))
                                        .frame(width: 4, height: 4)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

                // Reflection Prompts
                if !chapter.reflectionPrompts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Divider()
                            .overlay(ResonanceColors.goldPrimary.opacity(0.3))

                        Text("Reflection Prompts")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(ResonanceColors.goldPrimary)

                        ForEach(Array(chapter.reflectionPrompts.enumerated()), id: \.offset) { idx, prompt in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(idx + 1)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(ResonanceColors.goldPrimary)
                                    .frame(width: 20, height: 20)
                                    .background(
                                        Circle()
                                            .fill(ResonanceColors.goldPrimary.opacity(0.15))
                                    )
                                Text(prompt)
                                    .font(.body.italic())
                                    .foregroundStyle(ResonanceColors.text(for: scheme))
                            }
                        }
                    }
                    .padding(.top, 12)
                }

                // Key Terms
                if !chapter.keyTerms.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Terms")
                            .font(.headline)
                            .foregroundStyle(ResonanceColors.goldPrimary)

                        FlowLayout(spacing: 8) {
                            ForEach(chapter.keyTerms, id: \.self) { term in
                                Button {
                                    showGlossary = true
                                    glossarySearchText = term
                                } label: {
                                    Text(term)
                                        .font(.caption.weight(.medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(ResonanceColors.goldPrimary.opacity(0.12))
                                        )
                                        .foregroundStyle(ResonanceColors.goldPrimary)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }

                // Mark Complete
                Button {
                    if profile.completedChapters.contains(chapter.id) {
                        profile.completedChapters.remove(chapter.id)
                    } else {
                        profile.completedChapters.insert(chapter.id)
                    }
                } label: {
                    HStack {
                        Image(systemName: profile.completedChapters.contains(chapter.id) ? "checkmark.circle.fill" : "circle")
                        Text(profile.completedChapters.contains(chapter.id) ? "Completed" : "Mark as Complete")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(
                        profile.completedChapters.contains(chapter.id)
                            ? ResonanceColors.goldPrimary
                            : ResonanceColors.text(for: scheme)
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                profile.completedChapters.contains(chapter.id)
                                    ? ResonanceColors.goldPrimary.opacity(0.15)
                                    : ResonanceColors.surfaceSecondary(for: scheme)
                            )
                    )
                }
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)
        }
        .background(theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    let bookmark = Bookmark(chapterId: chapter.id, position: 0)
                    profile.bookmarks.append(bookmark)
                } label: {
                    Image(systemName: profile.bookmarks.contains(where: { $0.chapterId == chapter.id })
                          ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
                Button {
                    showAudioControls = true
                } label: {
                    Image(systemName: "headphones")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
                Button {
                    selectedPassage = chapter.content.components(separatedBy: "\n\n").first ?? chapter.title
                    showSharePassage = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyStateView(scheme: ColorScheme) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 56))
                .foregroundStyle(ResonanceColors.goldPrimary.opacity(0.4))
            Text("Select a chapter to begin reading")
                .font(.title3)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background(for: scheme).ignoresSafeArea())
    }

    // MARK: - Glossary Sheet

    @ViewBuilder
    private func glossarySheet(scheme: ColorScheme) -> some View {
        NavigationStack {
            let filtered = glossarySearchText.isEmpty
                ? glossary
                : glossary.filter {
                    $0.term.localizedCaseInsensitiveContains(glossarySearchText) ||
                    $0.definition.localizedCaseInsensitiveContains(glossarySearchText)
                }
            List(filtered) { term in
                VStack(alignment: .leading, spacing: 6) {
                    Text(term.term)
                        .font(.headline)
                        .foregroundStyle(ResonanceColors.goldPrimary)
                    Text(term.definition)
                        .font(.body)
                        .foregroundStyle(ResonanceColors.text(for: scheme))
                    if !term.relatedTerms.isEmpty {
                        HStack(spacing: 4) {
                            Text("Related:")
                                .font(.caption)
                                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                            Text(term.relatedTerms.joined(separator: ", "))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(ResonanceColors.goldPrimary)
                        }
                        .padding(.top, 2)
                    }
                    if !term.chapterReferences.isEmpty {
                        Text("Chapters: \(term.chapterReferences.map { String($0) }.joined(separator: ", "))")
                            .font(.caption2)
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                    }
                }
                .padding(.vertical, 4)
            }
            .searchable(text: $glossarySearchText, prompt: "Search terms...")
            .navigationTitle("Glossary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showGlossary = false }
                        .tint(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Bookmarks Sheet

    @ViewBuilder
    private func bookmarksSheet(scheme: ColorScheme) -> some View {
        NavigationStack {
            if profile.bookmarks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.4))
                    Text("No bookmarks yet")
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(profile.bookmarks) { bookmark in
                        Button {
                            selectedChapterId = bookmark.chapterId
                            showBookmarks = false
                        } label: {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(ResonanceColors.goldPrimary)
                                VStack(alignment: .leading) {
                                    if let ch = chapters.first(where: { $0.id == bookmark.chapterId }) {
                                        Text(ch.title)
                                            .font(.subheadline.weight(.medium))
                                    }
                                    Text(bookmark.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        profile.bookmarks.remove(atOffsets: indexSet)
                    }
                }
            }
            NavigationStack {
            }
            .navigationTitle("Bookmarks")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showBookmarks = false }
                        .tint(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Audio Controls Sheet

    @ViewBuilder
    private func audioControlsSheet(scheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            if let chapter = selectedChapter {
                Text("Listen to \(chapter.title)")
                    .font(.headline)
                    .foregroundStyle(ResonanceColors.text(for: scheme))

                // Progress bar
                VStack(spacing: 4) {
                    ProgressView(value: 0.0)
                        .tint(ResonanceColors.goldPrimary)
                    HStack {
                        Text("0:00")
                        Spacer()
                        Text("\(chapter.audioDurationMinutes):00")
                    }
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                }

                // Controls
                HStack(spacing: 32) {
                    Button {
                        // Skip back
                    } label: {
                        Image(systemName: "gobackward.15")
                            .font(.title2)
                            .foregroundStyle(ResonanceColors.text(for: scheme))
                    }

                    Button {
                        // Play/Pause
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(ResonanceColors.goldPrimary)
                    }

                    Button {
                        // Skip forward
                    } label: {
                        Image(systemName: "goforward.30")
                            .font(.title2)
                            .foregroundStyle(ResonanceColors.text(for: scheme))
                    }
                }

                // Speed control
                HStack {
                    Text("Speed")
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                    Spacer()
                    ForEach([0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { speed in
                        Button {
                            // Set speed
                        } label: {
                            Text(speed == 1.0 ? "1x" : String(format: "%.2gx", speed))
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(speed == 1.0
                                              ? ResonanceColors.goldPrimary.opacity(0.2)
                                              : ResonanceColors.surfaceSecondary(for: scheme))
                                )
                                .foregroundStyle(
                                    speed == 1.0
                                        ? ResonanceColors.goldPrimary
                                        : ResonanceColors.textSecondary(for: scheme)
                                )
                        }
                    }
                }
            }
        }
        .padding(24)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return LayoutResult(
            positions: positions,
            size: CGSize(width: maxWidth, height: totalHeight)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LearnView()
    }
    .environment(ThemeManager())
    .environment(UserProfile())
}
