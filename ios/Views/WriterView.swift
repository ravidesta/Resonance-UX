// WriterView.swift
// Resonance UX — Writing Sanctuary
//
// A distraction-free writing environment that honors the creative
// process. Focus mode dissolves all UI. Luminize Prose offers
// AI-powered refinement without disrupting flow.

import SwiftUI

// MARK: - Document Model

struct WriterDocument: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var wordCount: Int { content.split(separator: " ").count }
    var readingTimeMinutes: Int { max(1, wordCount / 238) }
    var isFavorite: Bool = false
    var tags: [String] = []
}

// MARK: - Writer View

struct WriterView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: ResonanceAppState

    @State private var documents = WriterDocument.samples
    @State private var selectedDocument: WriterDocument?
    @State private var isInFocusMode = false
    @State private var showLibrary = true
    @State private var showLuminize = false
    @State private var luminizeResult: String = ""
    @State private var isLuminizing = false

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }
    private var mutedColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted
    }
    private var surfaceColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface
    }
    private var baseColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base
    }

    var body: some View {
        NavigationStack {
            ZStack {
                baseColor.ignoresSafeArea()

                if let _ = selectedDocument {
                    editorView
                        .transition(.opacity)
                } else {
                    libraryView
                        .transition(.opacity)
                }

                // Floating stats bar
                if selectedDocument != nil && !isInFocusMode {
                    VStack {
                        Spacer()
                        floatingStatsBar
                    }
                }
            }
            .navigationTitle(selectedDocument == nil ? "Writing Sanctuary" : "")
            .navigationBarTitleDisplayMode(selectedDocument == nil ? .large : .inline)
            .toolbar {
                if selectedDocument != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation(ResonanceTheme.Animation.calm) {
                                saveCurrentDocument()
                                selectedDocument = nil
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Library")
                            }
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(ResonanceTheme.Light.gold)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: ResonanceTheme.Spacing.md) {
                            focusModeButton
                            luminizeButton
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            createNewDocument()
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(ResonanceTheme.Light.gold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showLuminize) {
                LuminizeSheet(
                    originalText: selectedDocument?.content ?? "",
                    result: $luminizeResult,
                    isProcessing: $isLuminizing,
                    onApply: { refined in
                        selectedDocument?.content = refined
                    }
                )
            }
        }
    }

    // MARK: - Library View

    private var libraryView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: ResonanceTheme.Spacing.lg) {
                // Stats header
                libraryStats

                // Favorites
                if documents.contains(where: \.isFavorite) {
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        sectionLabel("Favorites")
                        ForEach(documents.filter(\.isFavorite)) { doc in
                            DocumentCard(document: doc, isDeepRest: isDeepRest) {
                                withAnimation(ResonanceTheme.Animation.calm) {
                                    selectedDocument = doc
                                }
                            }
                        }
                    }
                }

                // All documents
                VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                    sectionLabel("All Writings")
                    ForEach(documents.sorted(by: { $0.updatedAt > $1.updatedAt })) { doc in
                        DocumentCard(document: doc, isDeepRest: isDeepRest) {
                            withAnimation(ResonanceTheme.Animation.calm) {
                                selectedDocument = doc
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, ResonanceTheme.Spacing.md)
            .padding(.bottom, ResonanceTheme.Spacing.xxxl)
        }
    }

    private var libraryStats: some View {
        HStack(spacing: ResonanceTheme.Spacing.lg) {
            StatPill(label: "Writings", value: "\(documents.count)", icon: "doc.text")
            StatPill(label: "Words", value: formattedTotalWords, icon: "text.word.spacing")
            StatPill(label: "This week", value: "\(documentsThisWeek)", icon: "calendar")
        }
        .padding(.vertical, ResonanceTheme.Spacing.sm)
    }

    private var formattedTotalWords: String {
        let total = documents.reduce(0) { $0 + $1.wordCount }
        if total > 1000 {
            return String(format: "%.1fk", Double(total) / 1000)
        }
        return "\(total)"
    }

    private var documentsThisWeek: Int {
        let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        return documents.filter { $0.updatedAt > weekAgo }.count
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(ResonanceTheme.Typography.overline)
            .foregroundColor(mutedColor)
            .tracking(1.5)
    }

    // MARK: - Editor View

    private var editorView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.lg) {
                // Title field
                if !isInFocusMode {
                    TextField("Untitled", text: Binding(
                        get: { selectedDocument?.title ?? "" },
                        set: { selectedDocument?.title = $0 }
                    ))
                    .font(ResonanceTheme.Typography.displayLarge)
                    .foregroundColor(textColor)
                    .textFieldStyle(.plain)
                    .padding(.top, ResonanceTheme.Spacing.xl)

                    // Metadata
                    HStack(spacing: ResonanceTheme.Spacing.md) {
                        if let doc = selectedDocument {
                            Text(doc.updatedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor)

                            Text("--")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor.opacity(0.4))

                            Text("\(doc.wordCount) words")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor)

                            Text("--")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor.opacity(0.4))

                            Text("\(doc.readingTimeMinutes) min read")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor)
                        }
                    }

                    Divider()
                        .padding(.vertical, ResonanceTheme.Spacing.sm)
                }

                // Content editor
                TextEditor(text: Binding(
                    get: { selectedDocument?.content ?? "" },
                    set: { selectedDocument?.content = $0 }
                ))
                .font(isInFocusMode
                    ? ResonanceTheme.Typography.serif(22, weight: .regular)
                    : ResonanceTheme.Typography.serif(19, weight: .regular))
                .foregroundColor(textColor)
                .scrollContentBackground(.hidden)
                .lineSpacing(isInFocusMode ? 12 : 8)
                .frame(minHeight: isInFocusMode ? UIScreen.main.bounds.height * 0.85 : 400)
                .padding(.top, isInFocusMode ? ResonanceTheme.Spacing.xxxl : 0)
            }
            .padding(.horizontal, isInFocusMode ? ResonanceTheme.Spacing.xl : ResonanceTheme.Spacing.md)
            .padding(.bottom, 100)
        }
        .animation(ResonanceTheme.Animation.calm, value: isInFocusMode)
    }

    // MARK: - Focus Mode Button

    private var focusModeButton: some View {
        Button {
            withAnimation(ResonanceTheme.Animation.calm) {
                isInFocusMode.toggle()
            }
        } label: {
            Image(systemName: isInFocusMode ? "eye.fill" : "eye.slash")
                .font(.body)
                .foregroundColor(isInFocusMode ? ResonanceTheme.Light.gold : mutedColor)
        }
    }

    // MARK: - Luminize Button

    private var luminizeButton: some View {
        Button {
            showLuminize = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption)
                Text("Luminize")
                    .font(ResonanceTheme.Typography.caption)
            }
            .foregroundColor(ResonanceTheme.Light.gold)
            .padding(.horizontal, ResonanceTheme.Spacing.sm)
            .padding(.vertical, ResonanceTheme.Spacing.xs)
            .background(
                Capsule()
                    .fill(ResonanceTheme.Light.gold.opacity(0.1))
            )
        }
    }

    // MARK: - Floating Stats Bar

    private var floatingStatsBar: some View {
        HStack(spacing: ResonanceTheme.Spacing.lg) {
            if let doc = selectedDocument {
                Label("\(doc.wordCount) words", systemImage: "text.word.spacing")
                    .font(ResonanceTheme.Typography.caption)
                Label("\(doc.readingTimeMinutes) min read", systemImage: "clock")
                    .font(ResonanceTheme.Typography.caption)
                Spacer()
                Label(doc.updatedAt.formatted(date: .omitted, time: .shortened), systemImage: "arrow.clockwise")
                    .font(ResonanceTheme.Typography.caption)
            }
        }
        .foregroundColor(mutedColor)
        .padding(.horizontal, ResonanceTheme.Spacing.lg)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
        )
        .padding(.horizontal, ResonanceTheme.Spacing.md)
        .padding(.bottom, ResonanceTheme.Spacing.md)
    }

    // MARK: - Helpers

    private func createNewDocument() {
        let doc = WriterDocument(
            title: "",
            content: "",
            createdAt: Date(),
            updatedAt: Date()
        )
        documents.insert(doc, at: 0)
        withAnimation(ResonanceTheme.Animation.calm) {
            selectedDocument = doc
        }
    }

    private func saveCurrentDocument() {
        guard let doc = selectedDocument,
              let index = documents.firstIndex(where: { $0.id == doc.id }) else { return }
        documents[index] = doc
        documents[index].updatedAt = Date()
    }
}

// MARK: - Document Card

struct DocumentCard: View {
    let document: WriterDocument
    let isDeepRest: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }
    private var mutedColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                HStack {
                    Text(document.title.isEmpty ? "Untitled" : document.title)
                        .font(ResonanceTheme.Typography.headlineMed)
                        .foregroundColor(textColor)

                    Spacer()

                    if document.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(ResonanceTheme.Light.gold)
                    }
                }

                if !document.content.isEmpty {
                    Text(document.content)
                        .font(ResonanceTheme.Typography.bodySmall)
                        .foregroundColor(mutedColor)
                        .lineLimit(2)
                }

                HStack(spacing: ResonanceTheme.Spacing.md) {
                    Text(document.updatedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(ResonanceTheme.Typography.caption)
                    Text("\(document.wordCount) words")
                        .font(ResonanceTheme.Typography.caption)
                    Text("\(document.readingTimeMinutes) min read")
                        .font(ResonanceTheme.Typography.caption)
                }
                .foregroundColor(mutedColor.opacity(0.7))

                if !document.tags.isEmpty {
                    HStack(spacing: ResonanceTheme.Spacing.xs) {
                        ForEach(document.tags, id: \.self) { tag in
                            Text(tag)
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                                )
                        }
                    }
                }
            }
            .padding(ResonanceTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                    .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                            .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                    )
                    .shadow(color: .black.opacity(isDeepRest ? 0.2 : 0.03), radius: 6, y: 2)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(ResonanceTheme.Animation.gentle) { isPressed = pressing }
        }, perform: {})
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let label: String
    let value: String
    let icon: String
    @Environment(\.isDeepRestMode) private var isDeepRest

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            Text(value)
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
            Text(label)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Luminize Sheet

struct LuminizeSheet: View {
    let originalText: String
    @Binding var result: String
    @Binding var isProcessing: Bool
    let onApply: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: LuminizeMode = .clarity
    @State private var previewText: String = ""

    enum LuminizeMode: String, CaseIterable, Identifiable {
        case clarity   = "Clarity"
        case rhythm    = "Rhythm"
        case depth     = "Depth"
        case simplify  = "Simplify"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .clarity:  return "Sharpen ideas while preserving voice"
            case .rhythm:   return "Improve sentence flow and cadence"
            case .depth:    return "Enrich meaning and imagery"
            case .simplify: return "Reduce complexity, increase clarity"
            }
        }

        var icon: String {
            switch self {
            case .clarity:  return "sparkle"
            case .rhythm:   return "waveform"
            case .depth:    return "arrow.down.to.line"
            case .simplify: return "minus.diamond"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: ResonanceTheme.Spacing.lg) {
                // Mode selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ResonanceTheme.Spacing.sm) {
                        ForEach(LuminizeMode.allCases) { mode in
                            Button {
                                selectedMode = mode
                                simulateLuminize()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: mode.icon)
                                        .font(.title3)
                                    Text(mode.rawValue)
                                        .font(ResonanceTheme.Typography.bodySmall)
                                        .fontWeight(.medium)
                                    Text(mode.description)
                                        .font(ResonanceTheme.Typography.caption)
                                        .opacity(0.6)
                                }
                                .padding(ResonanceTheme.Spacing.md)
                                .frame(width: 140)
                                .background(
                                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                                        .fill(selectedMode == mode
                                            ? ResonanceTheme.Light.gold.opacity(0.1)
                                            : Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                                                .stroke(selectedMode == mode
                                                    ? ResonanceTheme.Light.gold.opacity(0.3)
                                                    : Color.clear)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                }

                Divider()

                // Preview
                if isProcessing {
                    VStack(spacing: ResonanceTheme.Spacing.md) {
                        ProgressView()
                            .tint(ResonanceTheme.Light.gold)
                        Text("Luminizing prose...")
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !previewText.isEmpty {
                    ScrollView {
                        Text(previewText)
                            .font(ResonanceTheme.Typography.serif(18, weight: .regular))
                            .lineSpacing(8)
                            .padding(ResonanceTheme.Spacing.md)
                    }
                } else {
                    VStack(spacing: ResonanceTheme.Spacing.md) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundColor(ResonanceTheme.Light.gold.opacity(0.4))
                        Text("Select a mode to luminize your prose")
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Apply button
                if !previewText.isEmpty && !isProcessing {
                    Button {
                        onApply(previewText)
                        dismiss()
                    } label: {
                        Text("Apply Refinement")
                            .font(ResonanceTheme.Typography.sans(16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ResonanceTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                                    .fill(ResonanceTheme.Light.gold)
                            )
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                }
            }
            .padding(.vertical, ResonanceTheme.Spacing.md)
            .navigationTitle("Luminize Prose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func simulateLuminize() {
        isProcessing = true
        previewText = ""

        // Simulate AI processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            previewText = applySimulatedRefinement(to: originalText, mode: selectedMode)
            isProcessing = false
        }
    }

    private func applySimulatedRefinement(to text: String, mode: LuminizeMode) -> String {
        // In production this calls LuminizeService; here we return the
        // original with a mode-appropriate header comment.
        if text.isEmpty { return "Begin writing to see luminized results." }
        let prefix: String
        switch mode {
        case .clarity:  prefix = "[Clarity pass] "
        case .rhythm:   prefix = "[Rhythm pass] "
        case .depth:    prefix = "[Depth pass] "
        case .simplify: prefix = "[Simplified] "
        }
        return prefix + text
    }
}

// MARK: - Sample Data

extension WriterDocument {
    static let samples: [WriterDocument] = [
        WriterDocument(
            title: "On Digital Calm",
            content: "The screen glows softly in the pre-dawn light. There is no urgency here — no red badges, no notification counts, no algorithmic anxiety. Just a clean surface waiting for thought.\n\nThis is what technology could always have been: a quiet companion to the creative mind, amplifying intention rather than fragmenting attention. The Resonance philosophy begins with a simple premise — that every interaction with a digital surface is an opportunity for either depletion or renewal.\n\nWe chose renewal.",
            createdAt: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
            isFavorite: true,
            tags: ["Philosophy", "Resonance"]
        ),
        WriterDocument(
            title: "Nervous System as Interface",
            content: "What if we designed technology the way a skilled therapist holds space? Not pushing, not pulling — simply creating conditions for the nervous system to find its own regulation.\n\nThe ascend phase in the morning is not about productivity. It is about honoring the body's natural cortisol awakening response, offering tasks that match rising energy rather than demanding maximum output from the first moment.",
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            isFavorite: true,
            tags: ["Wellness", "Design"]
        ),
        WriterDocument(
            title: "The Inner Circle Protocol",
            content: "Connection is not about availability. The most meaningful relationships thrive not on constant access but on intentional presence. When Maya sends a voice message during my deep work phase, the message waits — not because she is unimportant, but because my full attention, given later, honors her more than a distracted reply given now.",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            tags: ["Connection"]
        ),
        WriterDocument(
            title: "Retreat Notes — March",
            content: "Day one. The group arrived in varying states of depletion. By the second breathwork session, something shifted — you could feel the collective nervous system begin to synchronize. The biometrics confirmed what we already sensed: HRV coherence across the group rose from 42% to 78% by end of day.",
            createdAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            updatedAt: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            tags: ["Retreat", "Biometrics"]
        ),
    ]
}
