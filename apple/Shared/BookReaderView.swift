// BookReaderView.swift
// Luminous Integral Architecture™ — Interactive Ebook Reader
//
// Full-featured ebook reader with highlights, annotations, inline exercises,
// somatic practice cards, and adaptive reading themes.

import SwiftUI

// MARK: - Book Reader View Model

@MainActor
final class BookReaderViewModel: ObservableObject {
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 342
    @Published var currentChapterIndex: Int = 0
    @Published var readingMode: ReadingMode = .pageTurning
    @Published var readingTheme: ReadingTheme = .day
    @Published var fontSize: CGFloat = 18
    @Published var lineSpacing: CGFloat = 8
    @Published var fontChoice: FontChoice = .serif
    @Published var highlights: [Highlight] = []
    @Published var bookmarks: [Bookmark] = []
    @Published var isChapterSidebarVisible = false
    @Published var isSettingsPanelVisible = false
    @Published var selectedHighlightColor: Color = .highlightYellow

    enum ReadingMode: String, CaseIterable {
        case pageTurning = "Pages"
        case scrolling = "Scroll"
    }

    enum FontChoice: String, CaseIterable {
        case serif = "Serif"
        case sans = "Sans-Serif"
        case system = "System"

        func font(size: CGFloat) -> Font {
            switch self {
            case .serif:  return ResonanceTypography.serifBody(size: size)
            case .sans:   return ResonanceTypography.sansBody(size: size)
            case .system: return .system(size: size)
            }
        }
    }

    let chapters: [Chapter] = [
        Chapter(id: "ch0", title: "Foreword", subtitle: "Setting the Stage", pageRange: 1...12, duration: 900, isCompleted: true),
        Chapter(id: "ch1", title: "Chapter 1: The Integral Vision", subtitle: "Seeing the Whole", pageRange: 13...48, duration: 2700, isCompleted: true),
        Chapter(id: "ch2", title: "Chapter 2: Four Quadrants", subtitle: "Maps of Reality", pageRange: 49...96, duration: 3600, isCompleted: false),
        Chapter(id: "ch3", title: "Chapter 3: Levels of Development", subtitle: "The Great Unfolding", pageRange: 97...140, duration: 3200, isCompleted: false),
        Chapter(id: "ch4", title: "Chapter 4: Lines of Intelligence", subtitle: "Multiple Streams", pageRange: 141...182, duration: 2900, isCompleted: false),
        Chapter(id: "ch5", title: "Chapter 5: States of Consciousness", subtitle: "Windows on the Kosmos", pageRange: 183...224, duration: 3100, isCompleted: false),
        Chapter(id: "ch6", title: "Chapter 6: Types and Styles", subtitle: "Horizontal Differences", pageRange: 225...268, duration: 3000, isCompleted: false),
        Chapter(id: "ch7", title: "Chapter 7: Spatial Attunement", subtitle: "Embodied Practice", pageRange: 269...306, duration: 2800, isCompleted: false),
        Chapter(id: "ch8", title: "Chapter 8: Integral Life Practice", subtitle: "Bringing It All Together", pageRange: 307...342, duration: 3400, isCompleted: false),
    ]

    var currentChapter: Chapter {
        chapters[currentChapterIndex]
    }

    var readingProgress: Double {
        Double(currentPage) / Double(totalPages)
    }

    func goToChapter(_ index: Int) {
        guard index >= 0, index < chapters.count else { return }
        currentChapterIndex = index
        currentPage = chapters[index].pageRange.lowerBound
    }

    func nextPage() {
        if currentPage < totalPages {
            currentPage += 1
            updateChapterFromPage()
        }
    }

    func previousPage() {
        if currentPage > 1 {
            currentPage -= 1
            updateChapterFromPage()
        }
    }

    func addHighlight(_ text: String, note: String? = nil) {
        let h = Highlight(
            text: text,
            color: selectedHighlightColor,
            note: note,
            chapterId: currentChapter.id,
            page: currentPage
        )
        highlights.append(h)
    }

    func toggleBookmark() {
        if let idx = bookmarks.firstIndex(where: { $0.page == currentPage }) {
            bookmarks.remove(at: idx)
        } else {
            let b = Bookmark(
                page: currentPage,
                chapterId: currentChapter.id,
                label: "Page \(currentPage)"
            )
            bookmarks.append(b)
        }
    }

    var isCurrentPageBookmarked: Bool {
        bookmarks.contains { $0.page == currentPage }
    }

    private func updateChapterFromPage() {
        if let idx = chapters.firstIndex(where: { $0.pageRange.contains(currentPage) }) {
            currentChapterIndex = idx
        }
    }
}

// MARK: - Book Reader View

struct BookReaderView: View {
    @StateObject private var viewModel = BookReaderViewModel()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        ZStack {
            // Theme background
            viewModel.readingTheme.background
                .ignoresSafeArea()

            #if !os(watchOS)
            mainReaderLayout
            #else
            watchReaderLayout
            #endif
        }
        .environment(\.readingTheme, viewModel.readingTheme)
        .environment(\.readingFontSize, viewModel.fontSize)
        .animation(.easeInOut(duration: 0.3), value: viewModel.readingTheme)
    }

    // MARK: Main Layout (iOS / iPadOS / macOS / visionOS)

    #if !os(watchOS)
    private var mainReaderLayout: some View {
        ZStack {
            if viewModel.readingMode == .scrolling {
                scrollingReader
            } else {
                pageTurningReader
            }

            // Overlays
            VStack(spacing: 0) {
                topBar
                Spacer()
                bottomBar
            }

            // Chapter sidebar
            if viewModel.isChapterSidebarVisible {
                chapterSidebar
            }

            // Settings panel
            if viewModel.isSettingsPanelVisible {
                settingsPanel
            }
        }
    }
    #endif

    // MARK: Watch Layout

    #if os(watchOS)
    private var watchReaderLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.currentChapter.title)
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(viewModel.readingTheme.secondaryForeground)

                Text(samplePageContent)
                    .font(viewModel.fontChoice.font(size: 14))
                    .foregroundStyle(viewModel.readingTheme.foreground)
                    .lineSpacing(4)

                HStack {
                    Button(action: viewModel.previousPage) {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text("\(viewModel.currentPage)/\(viewModel.totalPages)")
                        .font(ResonanceTypography.sansCaption2())
                    Spacer()
                    Button(action: viewModel.nextPage) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.top, 8)
            }
            .padding(8)
        }
    }
    #endif

    // MARK: Scrolling Reader

    #if !os(watchOS)
    private var scrollingReader: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(viewModel.chapters) { chapter in
                    chapterContent(chapter)
                }
            }
            .padding(.horizontal, readerHorizontalPadding)
            .padding(.vertical, 80)
        }
    }

    private func chapterContent(_ chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chapter header
            VStack(alignment: .leading, spacing: 4) {
                if let subtitle = chapter.subtitle {
                    Text(subtitle.uppercased())
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(Color.resonanceGoldPrimary)
                        .tracking(2)
                }
                Text(chapter.title)
                    .font(ResonanceTypography.serifDisplay(size: 28))
                    .foregroundStyle(viewModel.readingTheme.foreground)
            }
            .padding(.top, 32)
            .accessibilityAddTraits(.isHeader)

            ResonanceDivider()

            // Body text
            Text(samplePageContent)
                .font(viewModel.fontChoice.font(size: viewModel.fontSize))
                .foregroundStyle(viewModel.readingTheme.foreground)
                .lineSpacing(viewModel.lineSpacing)
                .textSelection(.enabled)
                .accessibilityLabel("Chapter text content")

            // Inline interactive exercise (for certain chapters)
            if chapter.id == "ch2" {
                QuadrantMappingCard(title: "Map your current experience across all four quadrants")
            }

            if chapter.id == "ch7" {
                SomaticPracticeCard(
                    title: "Spatial Attunement Practice",
                    instruction: "Settle into stillness. Notice the space around you — above, below, to the sides. Let your awareness expand to hold the full dimensionality of this moment.",
                    durationSeconds: 180
                )
            }

            if chapter.id == "ch5" {
                ReflectionQuestionCard(
                    question: "What state of consciousness are you experiencing right now?",
                    prompt: "Notice without judgment: are you in a waking, dreaming, or subtler state? What qualities does this moment hold?"
                )
            }
        }
    }
    #endif

    // MARK: Page-Turning Reader

    #if !os(watchOS)
    private var pageTurningReader: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(1...viewModel.totalPages, id: \.self) { page in
                pageView(for: page)
                    .tag(page)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
        #endif
        .accessibilityLabel("Book page \(viewModel.currentPage) of \(viewModel.totalPages)")
    }

    private func pageView(for page: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 60)

            Text(samplePageContent)
                .font(viewModel.fontChoice.font(size: viewModel.fontSize))
                .foregroundStyle(viewModel.readingTheme.foreground)
                .lineSpacing(viewModel.lineSpacing)
                .textSelection(.enabled)
                .padding(.horizontal, readerHorizontalPadding)

            Spacer()

            // Page number
            HStack {
                Spacer()
                Text("\(page)")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                Spacer()
            }
            .padding(.bottom, 60)
        }
    }
    #endif

    // MARK: Top Bar

    #if !os(watchOS)
    private var topBar: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.35)) {
                    viewModel.isChapterSidebarVisible.toggle()
                }
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 18, weight: .medium))
            }
            .accessibilityLabel("Chapter list")

            Spacer()

            Text(viewModel.currentChapter.title)
                .font(ResonanceTypography.sansCaption())
                .lineLimit(1)

            Spacer()

            Button(action: viewModel.toggleBookmark) {
                Image(systemName: viewModel.isCurrentPageBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(viewModel.isCurrentPageBookmarked ? Color.resonanceGoldPrimary : viewModel.readingTheme.foreground)
            }
            .accessibilityLabel(viewModel.isCurrentPageBookmarked ? "Remove bookmark" : "Add bookmark")

            Button {
                withAnimation(.spring(response: 0.35)) {
                    viewModel.isSettingsPanelVisible.toggle()
                }
            } label: {
                Image(systemName: "textformat.size")
                    .font(.system(size: 18, weight: .medium))
            }
            .accessibilityLabel("Reading settings")
        }
        .foregroundStyle(viewModel.readingTheme.foreground)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(viewModel.readingTheme.background.opacity(0.95))
    }
    #endif

    // MARK: Bottom Bar

    #if !os(watchOS)
    private var bottomBar: some View {
        VStack(spacing: 8) {
            ResonanceProgressBar(progress: viewModel.readingProgress, height: 3)
                .padding(.horizontal, 20)

            HStack {
                Text("Page \(viewModel.currentPage) of \(viewModel.totalPages)")
                    .font(ResonanceTypography.sansCaption2())
                Spacer()
                Text("\(Int(viewModel.readingProgress * 100))% complete")
                    .font(ResonanceTypography.sansCaption2())
            }
            .foregroundStyle(viewModel.readingTheme.secondaryForeground)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(viewModel.readingTheme.background.opacity(0.95))
    }
    #endif

    // MARK: Chapter Sidebar

    #if !os(watchOS)
    private var chapterSidebar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Chapters")
                        .font(ResonanceTypography.sansTitle())
                        .foregroundStyle(viewModel.readingTheme.foreground)
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            viewModel.isChapterSidebarVisible = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                    }
                    .accessibilityLabel("Close chapter list")
                }
                .padding(20)

                ResonanceDivider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(viewModel.chapters.enumerated()), id: \.element.id) { index, chapter in
                            Button {
                                viewModel.goToChapter(index)
                                withAnimation(.spring(response: 0.35)) {
                                    viewModel.isChapterSidebarVisible = false
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: chapter.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(chapter.isCompleted ? Color.resonanceGreen500 : viewModel.readingTheme.secondaryForeground)
                                        .font(.system(size: 16))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(chapter.title)
                                            .font(ResonanceTypography.sansBody(size: 15))
                                            .foregroundStyle(viewModel.readingTheme.foreground)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                        if let subtitle = chapter.subtitle {
                                            Text(subtitle)
                                                .font(ResonanceTypography.sansCaption2())
                                                .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                                        }
                                    }

                                    Spacer()

                                    if index == viewModel.currentChapterIndex {
                                        Circle()
                                            .fill(Color.resonanceGoldPrimary)
                                            .frame(width: 8, height: 8)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(
                                    index == viewModel.currentChapterIndex
                                        ? Color.resonanceGoldPrimary.opacity(0.08)
                                        : Color.clear
                                )
                            }
                            .accessibilityLabel("\(chapter.title)\(chapter.isCompleted ? ", completed" : "")")
                        }
                    }
                }

                // Bookmarks section
                if !viewModel.bookmarks.isEmpty {
                    ResonanceDivider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bookmarks")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 20)

                        ForEach(viewModel.bookmarks) { bookmark in
                            Button {
                                viewModel.currentPage = bookmark.page
                                withAnimation { viewModel.isChapterSidebarVisible = false }
                            } label: {
                                HStack {
                                    Image(systemName: "bookmark.fill")
                                        .foregroundStyle(Color.resonanceGoldPrimary)
                                        .font(.system(size: 12))
                                    Text(bookmark.label)
                                        .font(ResonanceTypography.sansCaption())
                                        .foregroundStyle(viewModel.readingTheme.foreground)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .frame(width: 320)
            .background(viewModel.readingTheme.background)

            // Dismiss area
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.isChapterSidebarVisible = false
                    }
                }
                .accessibilityHidden(true)
        }
        .transition(.move(edge: .leading))
    }
    #endif

    // MARK: Settings Panel

    #if !os(watchOS)
    private var settingsPanel: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                // Drag indicator
                Capsule()
                    .fill(Color.resonanceDivider)
                    .frame(width: 40, height: 4)

                // Theme selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                        .textCase(.uppercase)

                    HStack(spacing: 12) {
                        ForEach(ReadingTheme.allCases) { theme in
                            Button {
                                viewModel.readingTheme = theme
                            } label: {
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(theme.background)
                                        .overlay(Circle().strokeBorder(theme.foreground.opacity(0.3), lineWidth: 1))
                                        .frame(width: 36, height: 36)
                                    Text(theme.displayName)
                                        .font(ResonanceTypography.sansCaption2())
                                        .foregroundStyle(viewModel.readingTheme.foreground)
                                }
                            }
                            .accessibilityLabel("\(theme.displayName) theme")
                        }
                    }
                }

                ResonanceDivider()

                // Font size
                VStack(alignment: .leading, spacing: 8) {
                    Text("Font Size")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                        .textCase(.uppercase)

                    HStack {
                        Button { viewModel.fontSize = max(12, viewModel.fontSize - 1) } label: {
                            Image(systemName: "textformat.size.smaller")
                        }
                        .accessibilityLabel("Decrease font size")

                        Slider(value: $viewModel.fontSize, in: 12...32, step: 1)
                            .tint(Color.resonanceGoldPrimary)
                            .accessibilityLabel("Font size: \(Int(viewModel.fontSize))")

                        Button { viewModel.fontSize = min(32, viewModel.fontSize + 1) } label: {
                            Image(systemName: "textformat.size.larger")
                        }
                        .accessibilityLabel("Increase font size")
                    }
                    .foregroundStyle(viewModel.readingTheme.foreground)
                }

                // Font choice
                VStack(alignment: .leading, spacing: 8) {
                    Text("Font")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                        .textCase(.uppercase)

                    Picker("Font", selection: $viewModel.fontChoice) {
                        ForEach(BookReaderViewModel.FontChoice.allCases, id: \.self) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Font selection")
                }

                // Line spacing
                VStack(alignment: .leading, spacing: 8) {
                    Text("Line Spacing")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                        .textCase(.uppercase)

                    Slider(value: $viewModel.lineSpacing, in: 2...16, step: 1)
                        .tint(Color.resonanceGoldPrimary)
                        .accessibilityLabel("Line spacing: \(Int(viewModel.lineSpacing))")
                }

                // Reading mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reading Mode")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                        .textCase(.uppercase)

                    Picker("Mode", selection: $viewModel.readingMode) {
                        ForEach(BookReaderViewModel.ReadingMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Highlight color selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Highlight Color")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(viewModel.readingTheme.secondaryForeground)
                        .textCase(.uppercase)

                    HStack(spacing: 16) {
                        ForEach([(Color.highlightYellow, "Yellow"),
                                 (.highlightGreen, "Green"),
                                 (.highlightBlue, "Blue"),
                                 (.highlightPink, "Pink")], id: \.1) { color, name in
                            Button {
                                viewModel.selectedHighlightColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.resonanceGoldPrimary, lineWidth: viewModel.selectedHighlightColor == color ? 2 : 0)
                                    )
                            }
                            .accessibilityLabel("\(name) highlight")
                        }
                    }
                }

                Button("Close") {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.isSettingsPanelVisible = false
                    }
                }
                .buttonStyle(.resonanceSecondary)
            }
            .padding(24)
            .glassPanel(cornerRadius: 24, padding: 0)
            .padding(.horizontal, 16)
        }
        .background(
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.isSettingsPanelVisible = false
                    }
                }
        )
        .transition(.move(edge: .bottom))
    }
    #endif

    // MARK: Helpers

    private var readerHorizontalPadding: CGFloat {
        #if os(macOS)
        return 120
        #elseif os(visionOS)
        return 100
        #else
        if sizeClass == .regular { return 80 }
        return 24
        #endif
    }

    private var samplePageContent: String {
        """
        The integral approach begins with the recognition that every perspective holds a partial truth. \
        No single view — scientific, spiritual, psychological, or cultural — captures the fullness of reality. \
        Yet each reveals something essential that the others miss.

        When we bring these perspectives together — not by reducing them to a single framework, but by \
        honoring the unique contribution of each — something remarkable happens. We begin to see patterns \
        that connect. We discover that the interior of an individual (thoughts, feelings, values) is \
        intimately related to the exterior (brain states, behaviors, measurable phenomena). Similarly, \
        individual development unfolds within cultural contexts and systemic structures.

        This is not merely an intellectual exercise. It is an invitation to hold complexity with grace, \
        to find the through-line of development that connects your personal growth to the evolution of \
        consciousness itself. As you read, let the words settle not just in your mind, but in your body. \
        Notice what resonates. Notice what challenges. Both are doorways.
        """
    }
}

// MARK: - Preview

#if DEBUG
struct BookReaderView_Previews: PreviewProvider {
    static var previews: some View {
        BookReaderView()
    }
}
#endif
