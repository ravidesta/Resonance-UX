// MARK: - eBook Reader View — Sanctuary Reading Experience
// "The blank page is not a void — it is a sanctuary."
// Mirrors Writer module's design philosophy: design for the exhale.

import SwiftUI

struct EBookReaderView: View {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var viewModel = EBookReaderViewModel()
    @State private var showControls: Bool = true
    @State private var showHighlightMenu: Bool = false
    @State private var selectedText: String = ""
    @State private var showShareSheet: Bool = false

    var body: some View {
        ZStack {
            // Background
            theme.background
                .ignoresSafeArea()

            // Paper texture overlay (Resonance-UX signature)
            Rectangle()
                .fill(Color.clear)
                .overlay(PaperTextureOverlay())
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Main reading content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if let chapter = viewModel.currentChapter {
                            // Chapter Header
                            ChapterHeaderView(chapter: chapter)
                                .padding(.top, 60)
                                .padding(.bottom, 40)

                            // Chapter sections
                            ForEach(Array(chapter.sections.enumerated()), id: \.offset) { index, section in
                                SectionView(section: section, onHighlight: { text in
                                    selectedText = text
                                    showHighlightMenu = true
                                }, onShare: { text in
                                    selectedText = text
                                    showShareSheet = true
                                })
                                .id("section-\(index)")
                                .padding(.bottom, 32)
                            }

                            // Chapter reflection questions
                            if let chapter = viewModel.currentChapter {
                                ReflectionQuestionsCard(questions: viewModel.reflectionQuestions(for: chapter))
                                    .padding(.top, 24)
                                    .padding(.bottom, 48)
                            }

                            // Next chapter navigation
                            if viewModel.hasNextChapter {
                                NextChapterButton(onTap: { viewModel.goToNextChapter() })
                                    .padding(.bottom, 80)
                            }
                        }
                    }
                    .padding(.horizontal, readerPadding)
                    .frame(maxWidth: 760) // Respect attention bandwidth (Writer module pattern)
                    .frame(maxWidth: .infinity)
                }
            }

            // Floating controls
            VStack {
                if showControls {
                    ReaderTopBar(
                        chapterTitle: viewModel.currentChapter?.title ?? "",
                        progress: viewModel.progress,
                        onBack: { /* dismiss */ },
                        onSettings: { /* reader settings */ }
                    )
                }

                Spacer()

                if showControls {
                    ReaderBottomBar(
                        wordCount: viewModel.currentChapter?.wordCount ?? 0,
                        readingTime: viewModel.estimatedReadingTime,
                        onBookmark: { viewModel.toggleBookmark() },
                        onShare: { showShareSheet = true },
                        onAudioSwitch: { /* Switch to audiobook at this position */ }
                    )
                }
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls.toggle()
            }
        }
        .sheet(isPresented: $showHighlightMenu) {
            HighlightMenuView(
                text: selectedText,
                onHighlight: { color in
                    viewModel.addHighlight(text: selectedText, color: color)
                },
                onShare: {
                    showShareSheet = true
                },
                onCopyToJournal: {
                    viewModel.copyToJournal(text: selectedText)
                }
            )
            .presentationDetents([.height(280)])
        }
        .sheet(isPresented: $showShareSheet) {
            ShareCardPreview(text: selectedText.isEmpty ? viewModel.currentChapterExcerpt : selectedText)
                .presentationDetents([.medium, .large])
        }
    }

    private var readerPadding: CGFloat {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad ? 80 : 24
        #else
        return 80
        #endif
    }
}

// MARK: - Chapter Header

struct ChapterHeaderView: View {
    let chapter: EBook.EBookChapter
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chapter \(chapter.number)")
                .font(.custom("Manrope", size: 13).weight(.semibold))
                .foregroundColor(theme.goldPrimary)
                .textCase(.uppercase)
                .tracking(1.5)

            Text(chapter.title)
                .font(.custom("Cormorant Garamond", size: 36))
                .fontWeight(.light)
                .foregroundColor(theme.text)
                .lineSpacing(4)

            if let epigraph = chapter.epigraph {
                Text(epigraph)
                    .font(.custom("Cormorant Garamond", size: 18).italic())
                    .foregroundColor(theme.textSecondary)
                    .lineSpacing(6)
                    .padding(.top, 8)
                    .padding(.leading, 20)
            }

            Divider()
                .background(theme.goldPrimary.opacity(0.2))
                .padding(.top, 8)
        }
    }
}

// MARK: - Section View

struct SectionView: View {
    let section: EBook.EBookSection
    let onHighlight: (String) -> Void
    let onShare: (String) -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !section.title.isEmpty {
                Text(section.title)
                    .font(.custom("Cormorant Garamond", size: 24))
                    .foregroundColor(theme.text)
                    .padding(.bottom, 4)
            }

            switch section.type {
            case .caseStudy:
                CaseStudyView(content: section.body)
            case .practice:
                PracticeBlockView(content: section.body)
            case .reflection:
                ReflectionBlockView(content: section.body)
            case .luminousInvitation:
                LuminousInvitationView(content: section.body)
            case .pitfall:
                PitfallBlockView(content: section.body)
            case .safetyNote:
                SafetyNoteView(content: section.body)
            default:
                // Standard prose
                Text(section.body)
                    .font(.custom("Manrope", size: 17))
                    .foregroundColor(theme.text)
                    .lineSpacing(8)
                    .textSelection(.enabled)
            }
        }
    }
}

// MARK: - Special Block Types

struct CaseStudyView: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(theme.accent)
                Text("Case Study")
                    .font(.custom("Manrope", size: 12).weight(.semibold))
                    .foregroundColor(theme.accent)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            Text(content)
                .font(.custom("Manrope", size: 16))
                .foregroundColor(theme.text)
                .lineSpacing(7)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.forestBase.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.goldPrimary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct PracticeBlockView: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Practice", systemImage: "figure.mind.and.body")
                .font(.custom("Manrope", size: 12).weight(.semibold))
                .foregroundColor(Color(hex: "8B6BB0"))
                .textCase(.uppercase)
                .tracking(0.5)
            Text(content)
                .font(.custom("Manrope", size: 16))
                .foregroundColor(theme.text)
                .lineSpacing(7)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "8B6BB0").opacity(0.04))
        )
    }
}

struct ReflectionBlockView: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Reflection", systemImage: "sparkles")
                .font(.custom("Manrope", size: 12).weight(.semibold))
                .foregroundColor(theme.goldPrimary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(content)
                .font(.custom("Cormorant Garamond", size: 20))
                .foregroundColor(theme.text)
                .lineSpacing(6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.goldPrimary.opacity(0.04))
        )
    }
}

struct LuminousInvitationView: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Luminous Invitation", systemImage: "light.max")
                .font(.custom("Manrope", size: 12).weight(.semibold))
                .foregroundColor(theme.goldPrimary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(content)
                .font(.custom("Manrope", size: 16))
                .foregroundColor(theme.text)
                .lineSpacing(7)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [theme.goldPrimary.opacity(0.06), theme.forestBase.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(theme.goldPrimary.opacity(0.15), lineWidth: 1)
        )
    }
}

struct PitfallBlockView: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Common Pitfall", systemImage: "exclamationmark.triangle")
                .font(.custom("Manrope", size: 12).weight(.semibold))
                .foregroundColor(Color(hex: "B07A5A"))
                .textCase(.uppercase)
                .tracking(0.5)
            Text(content)
                .font(.custom("Manrope", size: 16))
                .foregroundColor(theme.text)
                .lineSpacing(7)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "B07A5A").opacity(0.04))
        )
    }
}

struct SafetyNoteView: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Safety Note", systemImage: "heart.text.square")
                .font(.custom("Manrope", size: 12).weight(.semibold))
                .foregroundColor(Color(hex: "C45A5A"))
                .textCase(.uppercase)
                .tracking(0.5)
            Text(content)
                .font(.custom("Manrope", size: 16))
                .foregroundColor(theme.text)
                .lineSpacing(7)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "C45A5A").opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "C45A5A").opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Reader Controls

struct ReaderTopBar: View {
    let chapterTitle: String
    let progress: Double
    let onBack: () -> Void
    let onSettings: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(theme.text)
                }

                Spacer()

                Text(chapterTitle)
                    .font(.custom("Manrope", size: 14))
                    .foregroundColor(theme.textSecondary)
                    .lineLimit(1)

                Spacer()

                Button(action: onSettings) {
                    Image(systemName: "textformat.size")
                        .foregroundColor(theme.text)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            // Progress bar
            GeometryReader { geo in
                Rectangle()
                    .fill(theme.goldPrimary.opacity(0.2))
                    .frame(height: 2)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(theme.goldPrimary)
                            .frame(width: geo.size.width * progress, height: 2)
                    }
            }
            .frame(height: 2)
        }
        .background(.ultraThinMaterial)
    }
}

struct ReaderBottomBar: View {
    let wordCount: Int
    let readingTime: String
    let onBookmark: () -> Void
    let onShare: () -> Void
    let onAudioSwitch: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack {
            Text("\(wordCount) words · \(readingTime)")
                .font(.custom("Manrope", size: 13))
                .foregroundColor(theme.textSecondary)

            Spacer()

            HStack(spacing: 20) {
                Button(action: onBookmark) {
                    Image(systemName: "bookmark")
                        .foregroundColor(theme.text)
                }
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(theme.text)
                }
                // Switch to audiobook at current position
                Button(action: onAudioSwitch) {
                    Image(systemName: "headphones")
                        .foregroundColor(theme.accent)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Highlight Menu

struct HighlightMenuView: View {
    let text: String
    let onHighlight: (EBook.Highlight.HighlightColor) -> Void
    let onShare: () -> Void
    let onCopyToJournal: () -> Void
    @EnvironmentObject var theme: ThemeManager

    let colors: [(EBook.Highlight.HighlightColor, Color, String)] = [
        (.gold, Color(hex: "C5A059"), "Gold"),
        (.forest, Color(hex: "4A9A6A"), "Forest"),
        (.somatic, Color(hex: "8B6BB0"), "Somatic"),
        (.relational, Color(hex: "5A8AB0"), "Relational"),
        (.integration, Color(hex: "B07A5A"), "Integration"),
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Highlight")
                .font(.custom("Manrope", size: 15).weight(.semibold))
                .foregroundColor(theme.text)

            // Color picker
            HStack(spacing: 16) {
                ForEach(colors, id: \.0) { color, swiftColor, name in
                    Button(action: { onHighlight(color) }) {
                        Circle()
                            .fill(swiftColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
            }

            Divider()

            HStack(spacing: 32) {
                Button(action: onShare) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.custom("Manrope", size: 12))
                    }
                    .foregroundColor(theme.text)
                }

                Button(action: onCopyToJournal) {
                    VStack(spacing: 4) {
                        Image(systemName: "pencil.line")
                        Text("Journal")
                            .font(.custom("Manrope", size: 12))
                    }
                    .foregroundColor(theme.text)
                }
            }
        }
        .padding(24)
    }
}

// MARK: - Share Card Preview

struct ShareCardPreview: View {
    let text: String
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedPlatform: SocialPlatform = .instagram
    @State private var selectedStyle: ShareableContent.BackgroundStyle = .forestGold

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Preview card
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: backgroundColors(for: selectedStyle),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            VStack(spacing: 16) {
                                Text("\"\(text)\"")
                                    .font(.custom("Cormorant Garamond", size: 22))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 32)

                                Text("— Luminous Constructive Development™")
                                    .font(.custom("Manrope", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        )
                }
                .frame(maxWidth: 300)
                .shadow(color: .black.opacity(0.15), radius: 16, y: 8)

                // Style selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([ShareableContent.BackgroundStyle.forestGold, .creamSerif, .deepRestGlow, .somaticWave, .spiralPattern], id: \.self) { style in
                            Button(action: { selectedStyle = style }) {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: backgroundColors(for: style),
                                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedStyle == style ? theme.goldPrimary : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Platform buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach([SocialPlatform.instagram, .twitter, .threads, .linkedin, .whatsapp, .imessage], id: \.self) { platform in
                            Button(action: { selectedPlatform = platform }) {
                                Text(platform.rawValue)
                                    .font(.custom("Manrope", size: 13).weight(.medium))
                                    .foregroundColor(selectedPlatform == platform ? theme.cream : theme.text)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(selectedPlatform == platform ? theme.forestBase : theme.forestBase.opacity(0.08))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Share button
                Button(action: { /* Execute share */ }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share to \(selectedPlatform.rawValue)")
                    }
                    .font(.custom("Manrope", size: 15).weight(.semibold))
                    .foregroundColor(theme.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.forestBase)
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func backgroundColors(for style: ShareableContent.BackgroundStyle) -> [Color] {
        switch style {
        case .forestGold:    return [Color(hex: "0A1C14"), Color(hex: "1B402E")]
        case .creamSerif:    return [Color(hex: "F5F0E8"), Color(hex: "E8DFD0")]
        case .deepRestGlow:  return [Color(hex: "050E09"), Color(hex: "122E21")]
        case .somaticWave:   return [Color(hex: "2A1A3A"), Color(hex: "1A2A3A")]
        case .spiralPattern: return [Color(hex: "1B402E"), Color(hex: "C5A059").opacity(0.3)]
        }
    }
}

// MARK: - Paper Texture (Resonance-UX signature)

struct PaperTextureOverlay: View {
    var body: some View {
        // SVG fractal noise at 3.5% opacity — the haptic-digital bridge
        Rectangle()
            .fill(Color.white.opacity(0.035))
            .blendMode(.overlay)
    }
}

// MARK: - Supporting types

struct ReflectionQuestionsCard: View {
    let questions: [String]
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Reflection Questions", systemImage: "sparkles")
                .font(.custom("Manrope", size: 13).weight(.semibold))
                .foregroundColor(theme.goldPrimary)
                .textCase(.uppercase)
                .tracking(0.5)

            ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .font(.custom("Cormorant Garamond", size: 20))
                        .foregroundColor(theme.goldPrimary)
                    Text(question)
                        .font(.custom("Manrope", size: 15))
                        .foregroundColor(theme.text)
                        .lineSpacing(4)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.goldPrimary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.goldPrimary.opacity(0.12), lineWidth: 1)
        )
    }
}

struct NextChapterButton: View {
    let onTap: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Next Chapter")
                        .font(.custom("Manrope", size: 13))
                        .foregroundColor(theme.textSecondary)
                    Text("Subject-Object Dynamics")
                        .font(.custom("Cormorant Garamond", size: 20))
                        .foregroundColor(theme.text)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.accent)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.surface)
            )
        }
    }
}

// MARK: - View Model

@MainActor
final class EBookReaderViewModel: ObservableObject {
    @Published var book: EBook?
    @Published var currentChapter: EBook.EBookChapter?
    @Published var progress: Double = 0.0

    var hasNextChapter: Bool { true }
    var estimatedReadingTime: String { "12 min" }
    var currentChapterExcerpt: String { "" }

    func goToNextChapter() { }
    func toggleBookmark() { }
    func addHighlight(text: String, color: EBook.Highlight.HighlightColor) { }
    func copyToJournal(text: String) { }
    func reflectionQuestions(for chapter: EBook.EBookChapter) -> [String] {
        return [
            "What in this chapter resonated most strongly? Where did you feel it in your body?",
            "Can you identify something you were once subject to but can now hold as object?",
            "What provoked resistance or discomfort? That response is worth examining.",
        ]
    }
}
