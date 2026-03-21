// WriterView.swift
// Resonance — Design for the Exhale
//
// Distraction-free writing sanctuary. "Compose quietly..."

import SwiftUI

struct WriterView: View {
    let theme: ResonanceTheme
    @State private var viewModel = WriterViewModel()

    var body: some View {
        Group {
            #if os(macOS) || os(visionOS)
            desktopLayout
            #else
            mobileLayout
            #endif
        }
    }

    // MARK: - Desktop Layout (sidebar + editor)

    private var desktopLayout: some View {
        HStack(spacing: 0) {
            if !viewModel.isFocusMode {
                documentLibrary
                    .frame(width: 280)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            editorPane
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.isFocusMode)
    }

    // MARK: - Mobile Layout

    private var mobileLayout: some View {
        NavigationStack {
            if viewModel.isEditing {
                editorPane
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                viewModel.saveCurrentDocument()
                                viewModel.isEditing = false
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Library")
                                }
                                .font(ResonanceFont.labelMedium)
                                .foregroundStyle(theme.goldPrimary)
                            }
                        }
                    }
                    .transition(.resonanceSlideTrailing)
            } else {
                documentLibrary
                    .transition(.resonanceFade)
            }
        }
        .animation(.easeOut(duration: 0.35), value: viewModel.isEditing)
    }

    // MARK: - Document Library

    private var documentLibrary: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Library header
            VStack(alignment: .leading, spacing: 4) {
                Text("Library")
                    .font(ResonanceFont.displaySmall)
                    .foregroundStyle(theme.textMain)

                Text("\(viewModel.documents.count) writings")
                    .font(ResonanceFont.caption)
                    .foregroundStyle(theme.textLight)
            }
            .padding(ResonanceTheme.spacingM)

            Divider()
                .foregroundStyle(theme.borderLight.opacity(0.3))

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 2) {
                    ForEach(viewModel.documents) { doc in
                        DocumentRow(document: doc, theme: theme, isSelected: viewModel.selectedDocument?.id == doc.id) {
                            viewModel.selectDocument(doc)
                        }
                    }
                }
                .padding(.vertical, ResonanceTheme.spacingS)
            }

            Divider()
                .foregroundStyle(theme.borderLight.opacity(0.3))

            // New document button
            Button {
                viewModel.createNew()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                    Text("New Writing")
                        .font(ResonanceFont.labelMedium)
                }
                .foregroundStyle(theme.goldPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
        .background(theme.bgSurface.opacity(0.5))
    }

    // MARK: - Editor Pane

    private var editorPane: some View {
        ZStack {
            AmbientBackground(theme: theme, showTexture: true)

            VStack(spacing: 0) {
                // Editor toolbar (hidden in focus mode)
                if !viewModel.isFocusMode {
                    editorToolbar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Main editor
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ResonanceTheme.spacingM) {
                        if let doc = viewModel.selectedDocument {
                            Text(doc.title)
                                .font(ResonanceFont.writerTitle)
                                .foregroundStyle(theme.textMain)
                                .padding(.top, ResonanceTheme.spacingXL)
                        }

                        TextEditor(text: $viewModel.editingText)
                            .font(ResonanceFont.writerBody)
                            .foregroundStyle(theme.textMain)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 400)
                            .tint(theme.goldPrimary)
                    }
                    .padding(.horizontal, ResonanceTheme.spacingXL)
                    .frame(maxWidth: 720)
                    .frame(maxWidth: .infinity)
                }

                // Ambient stats bar
                if !viewModel.isFocusMode {
                    ambientStats
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.isFocusMode)
        .onTapGesture(count: 3) {
            viewModel.isFocusMode.toggle()
        }
    }

    private var editorToolbar: some View {
        HStack {
            Spacer()

            #if os(macOS) || os(visionOS)
            Button {
                viewModel.isFocusMode.toggle()
            } label: {
                Image(systemName: viewModel.isFocusMode ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.textLight)
                    .padding(8)
            }
            .buttonStyle(.plain)
            .help("Toggle Focus Mode")
            #endif
        }
        .padding(.horizontal, ResonanceTheme.spacingM)
        .padding(.vertical, 8)
    }

    private var ambientStats: some View {
        HStack(spacing: ResonanceTheme.spacingM) {
            Spacer()

            Label("\(viewModel.currentWordCount) words", systemImage: "text.word.spacing")
                .font(ResonanceFont.caption)
                .foregroundStyle(theme.textLight)

            Label(viewModel.currentReadingTime, systemImage: "clock")
                .font(ResonanceFont.caption)
                .foregroundStyle(theme.textLight)
        }
        .padding(.horizontal, ResonanceTheme.spacingL)
        .padding(.vertical, 10)
        .glassNavBar(theme: theme)
    }
}

// MARK: - Document Row

struct DocumentRow: View {
    let document: WriterDocument
    let theme: ResonanceTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(document.title)
                            .font(ResonanceFont.headlineSmall)
                            .foregroundStyle(isSelected ? theme.goldPrimary : theme.textMain)
                            .lineLimit(1)

                        if document.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(theme.goldPrimary.opacity(0.5))
                        }
                    }

                    HStack(spacing: 8) {
                        Text(document.dateFormatted)
                            .font(ResonanceFont.caption)
                            .foregroundStyle(theme.textLight)

                        Text("·")
                            .foregroundStyle(theme.textLight)

                        Text("\(document.wordCount) words")
                            .font(ResonanceFont.caption)
                            .foregroundStyle(theme.textLight)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, ResonanceTheme.spacingM)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(theme.goldPrimary.opacity(0.08))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
