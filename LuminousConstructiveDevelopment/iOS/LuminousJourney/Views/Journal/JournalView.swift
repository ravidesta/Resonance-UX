// MARK: - Reflection Journal — "The syntax of your mind goes here..."
// Mirrors Writer module's sanctuary aesthetic.
// Every entry type maps to LCD framework practices.

import SwiftUI

struct JournalView: View {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var viewModel = JournalViewModel()
    @State private var showNewEntry = false
    @State private var selectedType: JournalEntry.EntryType = .freeWrite

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Journal")
                                .font(.custom("Cormorant Garamond", size: 36))
                                .fontWeight(.light)
                                .foregroundColor(theme.text)
                            Text("Let it flow. The syntax of your mind goes here...")
                                .font(.custom("Manrope", size: 14))
                                .foregroundColor(theme.textSecondary)
                        }
                        .padding(.top, 16)

                        // Entry type selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(entryTypes, id: \.0) { type, label, icon in
                                    EntryTypeChip(
                                        label: label,
                                        icon: icon,
                                        isSelected: selectedType == type,
                                        onTap: {
                                            selectedType = type
                                            showNewEntry = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Recent entries
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.entries) { entry in
                                JournalEntryCard(entry: entry)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 100)
                }

                // Floating new entry button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showNewEntry = true }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(theme.cream)
                                .frame(width: 56, height: 56)
                                .background(theme.forestBase)
                                .clipShape(Circle())
                                .shadow(color: theme.forestBase.opacity(0.3), radius: 12, y: 6)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                JournalEditorView(entryType: selectedType)
            }
        }
    }

    private var entryTypes: [(JournalEntry.EntryType, String, String)] {
        [
            (.freeWrite, "Free Write", "pencil"),
            (.subjectScan, "Subject Scan", "eye"),
            (.relationalMirror, "Relational Mirror", "person.2"),
            (.somaticWitness, "Somatic Witness", "waveform"),
            (.spiralMapping, "Spiral Map", "scope"),
            (.gratitudeForSelf, "Gratitude", "heart"),
            (.seasonInquiry, "Season Inquiry", "leaf"),
            (.guideDialogue, "Guide Dialogue", "bubble.left.and.text.bubble.right"),
        ]
    }
}

// MARK: - Entry Type Chip

struct EntryTypeChip: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                Text(label)
                    .font(.custom("Manrope", size: 13).weight(.medium))
            }
            .foregroundColor(isSelected ? theme.cream : theme.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? theme.forestBase : theme.forestBase.opacity(0.06))
            )
        }
    }
}

// MARK: - Journal Entry Card

struct JournalEntryCard: View {
    let entry: JournalEntry
    @EnvironmentObject var theme: ThemeManager
    @State private var showShareOptions = false

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(entry.type.rawValue, systemImage: iconForType(entry.type))
                        .font(.custom("Manrope", size: 12).weight(.semibold))
                        .foregroundColor(theme.goldPrimary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Spacer()

                    if let mood = entry.mood {
                        Text(mood.rawValue)
                            .font(.custom("Manrope", size: 12))
                            .foregroundColor(theme.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(theme.forestBase.opacity(0.06)))
                    }

                    // Share button
                    if entry.isShareable {
                        Button(action: { showShareOptions = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                                .foregroundColor(theme.textMuted)
                        }
                    }
                }

                Text(entry.content)
                    .font(.custom("Manrope", size: 15))
                    .foregroundColor(theme.text)
                    .lineSpacing(4)
                    .lineLimit(4)

                if let somatic = entry.somaticNotes, !somatic.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8B6BB0"))
                        Text(somatic)
                            .font(.custom("Manrope", size: 13))
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(2)
                    }
                }

                HStack {
                    Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(theme.textMuted)

                    if let season = entry.season {
                        Text("·")
                            .foregroundColor(theme.textMuted)
                        Text(season.rawValue)
                            .font(.custom("Manrope", size: 12))
                            .foregroundColor(theme.seasonColors[season] ?? theme.textMuted)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareOptions) {
            ShareCardPreview(text: entry.shareExcerpt ?? String(entry.content.prefix(200)))
                .presentationDetents([.medium, .large])
        }
    }

    private func iconForType(_ type: JournalEntry.EntryType) -> String {
        switch type {
        case .freeWrite: return "pencil"
        case .subjectScan: return "eye"
        case .relationalMirror: return "person.2"
        case .somaticWitness: return "waveform"
        case .spiralMapping: return "scope"
        case .gratitudeForSelf: return "heart"
        case .seasonInquiry: return "leaf"
        case .guideDialogue: return "bubble.left.and.text.bubble.right"
        }
    }
}

// MARK: - Journal Editor

struct JournalEditorView: View {
    let entryType: JournalEntry.EntryType
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var content: String = ""
    @State private var somaticNotes: String = ""
    @State private var selectedMood: JournalEntry.Mood?
    @State private var selectedSeason: SomaticSeason?
    @State private var isShareable: Bool = false
    @State private var showGuidePrompt: Bool = false
    @FocusState private var isContentFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Prompt from Guide (if available)
                    if let prompt = promptForType(entryType) {
                        Text(prompt)
                            .font(.custom("Cormorant Garamond", size: 20))
                            .foregroundColor(theme.textSecondary)
                            .lineSpacing(4)
                            .padding(.horizontal, 4)
                    }

                    // Main content editor
                    TextEditor(text: $content)
                        .font(.custom("Manrope", size: 17))
                        .foregroundColor(theme.text)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 200)
                        .focused($isContentFocused)

                    Divider()

                    // Somatic notes
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Somatic Notes", systemImage: "waveform")
                            .font(.custom("Manrope", size: 13).weight(.semibold))
                            .foregroundColor(Color(hex: "8B6BB0"))
                            .textCase(.uppercase)
                            .tracking(0.5)

                        TextField("What do you notice in your body?", text: $somaticNotes, axis: .vertical)
                            .font(.custom("Manrope", size: 15))
                            .lineLimit(3...6)
                    }

                    // Mood selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood")
                            .font(.custom("Manrope", size: 13).weight(.semibold))
                            .foregroundColor(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        FlowLayout(spacing: 8) {
                            ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                                Button(action: { selectedMood = mood }) {
                                    Text(mood.rawValue)
                                        .font(.custom("Manrope", size: 13))
                                        .foregroundColor(selectedMood == mood ? theme.cream : theme.text)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(selectedMood == mood ? theme.forestBase : theme.forestBase.opacity(0.06))
                                        )
                                }
                            }
                        }
                    }

                    // Season selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Somatic Season")
                            .font(.custom("Manrope", size: 13).weight(.semibold))
                            .foregroundColor(theme.textSecondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        HStack(spacing: 10) {
                            ForEach(SomaticSeason.allCases, id: \.self) { season in
                                Button(action: { selectedSeason = season }) {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(selectedSeason == season
                                                ? (theme.seasonColors[season] ?? theme.accent)
                                                : theme.textMuted.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                        Text(season.rawValue)
                                            .font(.custom("Manrope", size: 10))
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                            }
                        }
                    }

                    // Share toggle
                    Toggle(isOn: $isShareable) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(theme.accent)
                            VStack(alignment: .leading) {
                                Text("Make shareable")
                                    .font(.custom("Manrope", size: 15))
                                    .foregroundColor(theme.text)
                                Text("Allow sharing a beautiful excerpt to social media")
                                    .font(.custom("Manrope", size: 12))
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                    }
                    .tint(theme.goldPrimary)
                }
                .padding(20)
            }
            .background(theme.background)
            .navigationTitle(entryType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(theme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save entry
                        dismiss()
                    }
                    .font(.custom("Manrope", size: 15).weight(.semibold))
                    .foregroundColor(theme.goldPrimary)
                    .disabled(content.isEmpty)
                }
            }
            .onAppear { isContentFocused = true }
        }
    }

    private func promptForType(_ type: JournalEntry.EntryType) -> String? {
        switch type {
        case .subjectScan:
            return "What belief, feeling, or pattern are you so embedded in right now that it feels not like something you have, but like something you are?"
        case .relationalMirror:
            return "Think of a relationship with recurring friction. What might you be subject to that you cannot yet see?"
        case .somaticWitness:
            return "Close your eyes. Notice where there is tension. Where is there ease? Where is there numbness? Simply notice."
        case .spiralMapping:
            return "What themes keep returning in your life? How has your relationship to them changed over time?"
        case .gratitudeForSelf:
            return "Choose a meaning-making structure you've outgrown. Write a letter of genuine appreciation to that earlier self."
        case .seasonInquiry:
            return "Place one hand on the area of your body that feels most alive right now. Ask it: What season are we in?"
        case .guideDialogue:
            return "What question is most alive in you right now? Let's explore it together with your Guide."
        case .freeWrite:
            return nil
        }
    }
}

// MARK: - Flow Layout (for mood tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

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
            maxHeight = max(maxHeight, y + rowHeight)
        }

        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}

// MARK: - View Model

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
}
