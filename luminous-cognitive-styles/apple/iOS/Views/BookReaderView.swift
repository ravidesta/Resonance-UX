// BookReaderView.swift
// Luminous Cognitive Styles™ — iOS
// Chapter list and reading view with progress tracking and bookmarks

import SwiftUI

struct BookReaderView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedChapter: BookChapter?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LCSTheme.Spacing.md) {
                    // Book header
                    bookHeader

                    // Overall progress
                    overallProgressView

                    // Chapter list
                    VStack(spacing: LCSTheme.Spacing.sm) {
                        ForEach(BookChapter.chapters) { chapter in
                            ChapterRowView(
                                chapter: chapter,
                                progress: viewModel.bookProgress[chapter.id] ?? 0
                            )
                            .onTapGesture {
                                selectedChapter = chapter
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: LCSTheme.Spacing.xxl)
                }
            }
            .background(LCSTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("The Book")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $selectedChapter) { chapter in
                NavigationStack {
                    ChapterReadingView(chapter: chapter)
                        .environmentObject(viewModel)
                }
            }
        }
    }

    private var bookHeader: some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundStyle(LCSTheme.goldGradient)
                .shadow(color: LCSTheme.goldAccent.opacity(0.3), radius: 8)

            Text("Luminous Cognitive Styles")
                .font(.title2.weight(.bold))
                .foregroundColor(LCSTheme.textPrimary)

            Text("A Guide to Understanding Your Mind")
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)

            Text("9 Chapters")
                .font(.caption)
                .foregroundColor(LCSTheme.textTertiary)
        }
        .padding(.top, LCSTheme.Spacing.xl)
        .padding(.bottom, LCSTheme.Spacing.md)
    }

    private var overallProgressView: some View {
        VStack(spacing: LCSTheme.Spacing.sm) {
            HStack {
                Text("Reading Progress")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(LCSTheme.textSecondary)
                Spacer()
                Text("\(Int(viewModel.totalBookProgress * 100))%")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundColor(LCSTheme.goldAccent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LCSTheme.goldGradient)
                        .frame(width: geo.size.width * CGFloat(viewModel.totalBookProgress))
                }
            }
            .frame(height: 6)
        }
        .lcsCard()
        .padding(.horizontal)
    }
}

// MARK: - Chapter Row

struct ChapterRowView: View {
    let chapter: BookChapter
    let progress: Double

    var body: some View {
        HStack(spacing: LCSTheme.Spacing.md) {
            // Chapter number
            ZStack {
                Circle()
                    .fill(progress >= 1.0 ? LCSTheme.emerald.opacity(0.2) : Color.white.opacity(0.06))
                    .frame(width: 40, height: 40)

                if progress >= 1.0 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(LCSTheme.emerald)
                } else {
                    Text("\(chapter.id)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(LCSTheme.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(LCSTheme.textPrimary)

                Text(chapter.subtitle)
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)

                if progress > 0 && progress < 1.0 {
                    ProgressView(value: progress)
                        .tint(LCSTheme.goldAccent)
                        .scaleEffect(y: 0.6)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(chapter.estimatedMinutes) min")
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(LCSTheme.textTertiary)
            }
        }
        .padding(LCSTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                .fill(LCSTheme.darkSurface.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }
}

// MARK: - Chapter Reading View

struct ChapterReadingView: View {
    let chapter: BookChapter
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 1
    @State private var isBookmarked = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LCSTheme.Spacing.xl) {
                // Chapter header
                VStack(alignment: .leading, spacing: LCSTheme.Spacing.sm) {
                    Text("Chapter \(chapter.id)")
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .tracking(2)
                        .foregroundColor(LCSTheme.goldAccent)

                    Text(chapter.title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundColor(LCSTheme.textPrimary)

                    Text(chapter.subtitle)
                        .font(.title3)
                        .foregroundColor(LCSTheme.textSecondary)

                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.vertical, LCSTheme.Spacing.sm)
                }

                // Chapter content
                Text(chapter.content)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(LCSTheme.textPrimary.opacity(0.9))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                contentHeight = max(1, geo.size.height)
                            }
                            return Color.clear
                        }
                    )

                // End of chapter
                VStack(spacing: LCSTheme.Spacing.md) {
                    Divider()
                        .background(Color.white.opacity(0.1))

                    if chapter.id < BookChapter.chapters.count {
                        Button {
                            viewModel.updateBookProgress(chapterId: chapter.id, progress: 1.0)
                            dismiss()
                        } label: {
                            HStack {
                                Text("Next: \(BookChapter.chapters[chapter.id].title)")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .buttonStyle(LCSTheme.PrimaryButtonStyle())
                    } else {
                        Text("You have completed the book.")
                            .font(.headline)
                            .foregroundColor(LCSTheme.goldAccent)
                    }
                }
                .padding(.vertical, LCSTheme.Spacing.xl)

                Spacer(minLength: 100)
            }
            .padding(.horizontal, LCSTheme.Spacing.lg)
            .padding(.top, LCSTheme.Spacing.lg)
            .background(
                GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        let offset = -proxy.frame(in: .named("scroll")).origin.y
                        let maxOffset = max(1, contentHeight - 300)
                        let progress = min(1.0, max(0, Double(offset / maxOffset)))
                        viewModel.updateBookProgress(chapterId: chapter.id, progress: progress)
                    }
                    return Color.clear
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .background(LCSTheme.deepNavy.ignoresSafeArea())
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
                    .foregroundColor(LCSTheme.textSecondary)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isBookmarked.toggle()
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? LCSTheme.goldAccent : LCSTheme.textSecondary)
                }
            }
        }
    }
}
