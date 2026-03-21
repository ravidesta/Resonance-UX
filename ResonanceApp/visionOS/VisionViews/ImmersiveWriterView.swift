// ImmersiveWriterView.swift
// Resonance — Design for the Exhale
//
// Spatial writing experience for Vision Pro — floating glass panels
// with ambient organic elements surrounding the writer.

import SwiftUI

#if os(visionOS)
struct SpatialWriterView: View {
    let theme: ResonanceTheme
    @State private var viewModel = WriterViewModel()
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isImmersive = false

    var body: some View {
        HStack(spacing: 0) {
            // Library panel (glass)
            if !viewModel.isFocusMode {
                spatialLibrary
                    .frame(width: 300)
                    .glassPanel(theme: theme)
                    .padding(ResonanceTheme.spacingM)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // Editor panel
            spatialEditor
                .glassPanel(theme: theme, raised: true)
                .padding(ResonanceTheme.spacingM)
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.isFocusMode)
        .ornament(attachmentAnchor: .scene(.top)) {
            writerOrnament
        }
    }

    private var spatialLibrary: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.spacingM) {
            Text("Library")
                .font(ResonanceFont.headlineLarge)
                .foregroundStyle(theme.textMain)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.documents) { doc in
                        Button {
                            viewModel.selectDocument(doc)
                        } label: {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(doc.title)
                                    .font(ResonanceFont.headlineSmall)
                                    .foregroundStyle(
                                        viewModel.selectedDocument?.id == doc.id
                                            ? theme.goldPrimary
                                            : theme.textMain
                                    )
                                HStack {
                                    Text(doc.dateFormatted)
                                    Text("·")
                                    Text("\(doc.wordCount) words")
                                }
                                .font(ResonanceFont.caption)
                                .foregroundStyle(theme.textLight)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(ResonanceTheme.spacingM)
    }

    private var spatialEditor: some View {
        VStack(spacing: 0) {
            if let doc = viewModel.selectedDocument {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ResonanceTheme.spacingM) {
                        Text(doc.title)
                            .font(ResonanceFont.writerTitle)
                            .foregroundStyle(theme.textMain)
                            .padding(.top, ResonanceTheme.spacingXL)

                        TextEditor(text: $viewModel.editingText)
                            .font(ResonanceFont.writerBody)
                            .foregroundStyle(theme.textMain)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 500)
                            .tint(theme.goldPrimary)
                    }
                    .padding(.horizontal, ResonanceTheme.spacingXL)
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
                }
            } else {
                VStack(spacing: ResonanceTheme.spacingM) {
                    Spacer()
                    Image(systemName: "text.cursor")
                        .font(.system(size: 40, weight: .ultraLight))
                        .foregroundStyle(theme.textLight)
                    Text("Select a writing or begin anew")
                        .font(ResonanceFont.intention)
                        .italic()
                        .foregroundStyle(theme.textMuted)
                    Spacer()
                }
            }
        }
    }

    private var writerOrnament: some View {
        HStack(spacing: ResonanceTheme.spacingM) {
            // Word count
            Label("\(viewModel.currentWordCount) words", systemImage: "text.word.spacing")
                .font(ResonanceFont.labelSmall)
                .foregroundStyle(theme.textLight)

            Divider().frame(height: 16)

            // Reading time
            Label(viewModel.currentReadingTime, systemImage: "clock")
                .font(ResonanceFont.labelSmall)
                .foregroundStyle(theme.textLight)

            Divider().frame(height: 16)

            // Focus mode
            Button {
                viewModel.isFocusMode.toggle()
            } label: {
                Image(systemName: viewModel.isFocusMode
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right"
                )
                .font(.system(size: 14))
                .foregroundStyle(theme.textLight)
            }
            .buttonStyle(.plain)

            Divider().frame(height: 16)

            // Immersive toggle
            Button {
                Task {
                    if isImmersive {
                        await dismissImmersiveSpace()
                    } else {
                        await openImmersiveSpace(id: "immersive-writer")
                    }
                    isImmersive.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isImmersive ? "xmark.circle" : "sparkles")
                        .font(.system(size: 12))
                    Text(isImmersive ? "Exit Immersive" : "Immerse")
                        .font(ResonanceFont.labelSmall)
                }
                .foregroundStyle(theme.goldPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, ResonanceTheme.spacingM)
        .padding(.vertical, 8)
        .glassBackground()
    }
}
#endif
