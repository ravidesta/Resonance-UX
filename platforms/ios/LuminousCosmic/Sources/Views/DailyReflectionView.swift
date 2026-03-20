// DailyReflectionView.swift
// Luminous Cosmic Architecture™
// Reflection Prompts and Journal

import SwiftUI

// MARK: - Daily Reflection View

struct DailyReflectionView: View {
    @Environment(\.resonanceTheme) var theme
    @StateObject private var viewModel = ReflectionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicBackgroundMinimal()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: ResonanceSpacing.lg) {
                        // Header
                        headerSection

                        // Today's prompt
                        todayPromptCard

                        // Journal entry
                        journalSection

                        // Past entries
                        if !viewModel.pastEntries.isEmpty {
                            pastEntriesSection
                        }

                        // Reflection prompts library
                        promptLibrarySection

                        Spacer(minLength: ResonanceSpacing.xxxl)
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.xxs) {
            Text("Daily Reflection")
                .font(ResonanceTypography.displaySmall)
                .foregroundColor(theme.textPrimary)

            Text(formattedDate)
                .font(ResonanceTypography.caption)
                .foregroundColor(theme.textTertiary)
                .tracking(1)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResonanceSpacing.xxl)
        .padding(.horizontal, ResonanceSpacing.xs)
    }

    // MARK: - Today's Prompt

    private var todayPromptCard: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(theme.accent)
                    .font(.system(size: 18))

                Text("Today's Prompt")
                    .font(ResonanceTypography.overline)
                    .foregroundColor(theme.accent)
                    .textCase(.uppercase)
                    .tracking(1.5)
            }

            Text(viewModel.todayPrompt)
                .font(ResonanceTypography.headlineLarge)
                .foregroundColor(theme.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            if let context = viewModel.transitContext {
                HStack(spacing: ResonanceSpacing.xs) {
                    Circle()
                        .fill(theme.accent.opacity(0.5))
                        .frame(width: 4, height: 4)

                    Text(context)
                        .font(ResonanceTypography.caption)
                        .foregroundColor(theme.textTertiary)
                        .italic()
                }
            }
        }
        .padding(ResonanceSpacing.lg)
        .glassCard(cornerRadius: ResonanceRadius.xl)
    }

    // MARK: - Journal Section

    private var journalSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            HStack {
                Text("Your Reflection")
                    .font(ResonanceTypography.headlineSmall)
                    .foregroundColor(theme.textPrimary)

                Spacer()

                if !viewModel.currentEntry.isEmpty {
                    Text("\(viewModel.currentEntry.count) characters")
                        .font(ResonanceTypography.caption)
                        .foregroundColor(theme.textTertiary)
                }
            }

            ZStack(alignment: .topLeading) {
                // Placeholder
                if viewModel.currentEntry.isEmpty {
                    Text("Begin writing your reflection...")
                        .font(ResonanceTypography.bodyMedium)
                        .foregroundColor(theme.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: $viewModel.currentEntry)
                    .font(ResonanceTypography.bodyMedium)
                    .foregroundColor(theme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .accessibilityLabel("Reflection journal entry")
            }
            .padding(ResonanceSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                    .fill(theme.surface.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                    .strokeBorder(theme.border, lineWidth: 0.5)
            )

            // Save button
            HStack {
                Spacer()

                Button {
                    viewModel.saveEntry()
                    ResonanceHaptics.success()
                } label: {
                    HStack(spacing: ResonanceSpacing.xs) {
                        Image(systemName: "checkmark.circle")
                        Text("Save Reflection")
                    }
                    .goldButton()
                }
                .disabled(viewModel.currentEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(viewModel.currentEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
        }
    }

    // MARK: - Past Entries

    private var pastEntriesSection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            Text("Past Reflections")
                .font(ResonanceTypography.headlineMedium)
                .foregroundColor(theme.textPrimary)
                .padding(.horizontal, ResonanceSpacing.xs)

            ForEach(viewModel.pastEntries) { entry in
                PastEntryCard(entry: entry)
            }
        }
    }

    // MARK: - Prompt Library

    private var promptLibrarySection: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            Text("Prompt Library")
                .font(ResonanceTypography.headlineMedium)
                .foregroundColor(theme.textPrimary)
                .padding(.horizontal, ResonanceSpacing.xs)

            ForEach(viewModel.promptCategories, id: \.category) { group in
                VStack(alignment: .leading, spacing: ResonanceSpacing.xs) {
                    Text(group.category)
                        .font(ResonanceTypography.overline)
                        .foregroundColor(theme.accent)
                        .textCase(.uppercase)
                        .tracking(1)
                        .padding(.horizontal, ResonanceSpacing.xs)

                    ForEach(group.prompts, id: \.self) { prompt in
                        Button {
                            viewModel.selectPrompt(prompt)
                            ResonanceHaptics.light()
                        } label: {
                            HStack {
                                Text(prompt)
                                    .font(ResonanceTypography.bodyMedium)
                                    .foregroundColor(theme.textPrimary)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.textTertiary)
                            }
                            .padding(ResonanceSpacing.md)
                            .glassCard(cornerRadius: ResonanceRadius.md, intensity: .subtle, showBorder: false)
                        }
                    }
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Past Entry Card

struct PastEntryCard: View {
    let entry: JournalEntry
    @Environment(\.resonanceTheme) var theme
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
            HStack {
                Text(formattedDate(entry.date))
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)

                if let moonPhase = entry.moonPhase {
                    Text(moonPhase)
                        .font(.system(size: 12))
                }

                Spacer()

                Button {
                    withAnimation(ResonanceAnimation.springSmooth) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textTertiary)
                }
            }

            Text(entry.prompt)
                .font(ResonanceTypography.bodySmall)
                .foregroundColor(theme.accent)
                .italic()

            Text(entry.response)
                .font(ResonanceTypography.bodyMedium)
                .foregroundColor(theme.textSecondary)
                .lineLimit(isExpanded ? nil : 3)
                .lineSpacing(3)
        }
        .padding(ResonanceSpacing.md)
        .glassCard(cornerRadius: ResonanceRadius.lg, intensity: .subtle)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Reflection ViewModel

class ReflectionViewModel: ObservableObject {
    @Published var todayPrompt: String = ""
    @Published var transitContext: String? = nil
    @Published var currentEntry: String = ""
    @Published var pastEntries: [JournalEntry] = []

    struct PromptGroup {
        let category: String
        let prompts: [String]
    }

    let promptCategories: [PromptGroup] = [
        PromptGroup(category: "Self-Discovery", prompts: [
            "What part of myself am I being called to explore right now?",
            "Where do I feel most aligned with my authentic nature today?",
            "What patterns am I noticing in my emotional responses?",
            "How is my relationship with change evolving?"
        ]),
        PromptGroup(category: "Cosmic Awareness", prompts: [
            "How do I experience the current lunar energy in my daily life?",
            "What themes from my birth chart feel most alive right now?",
            "Where do I notice resistance, and what might it be teaching me?",
            "How can I honor both my Sun and Moon needs today?"
        ]),
        PromptGroup(category: "Integration", prompts: [
            "What wisdom from the past week wants to be integrated?",
            "How can I bring more balance to the elements in my life?",
            "What would it look like to fully trust my developmental path?",
            "Where am I being invited to grow, and how does that feel?"
        ])
    ]

    init() {
        generateTodayPrompt()
        loadSampleEntries()
    }

    func generateTodayPrompt() {
        let dayPrompts = [
            "What cosmic pattern is asking for your attention today? Sit with the question before answering.",
            "Notice where you feel expansion and where you feel contraction today. What do these sensations reveal?",
            "If the current planetary weather were a landscape, what would it look like? Describe the terrain of your inner world.",
            "What truth is trying to emerge through today's experiences? Let it surface without judgment.",
            "How are you being called to grow right now? What old skin are you shedding?",
            "Reflect on the interplay between your conscious desires (Sun) and emotional needs (Moon) today.",
            "What would it feel like to trust your developmental path completely? Write from that place."
        ]

        let day = Calendar.current.component(.day, from: Date())
        todayPrompt = dayPrompts[day % dayPrompts.count]
        transitContext = "Influenced by today's Sun-Moon aspect and current transits"
    }

    func selectPrompt(_ prompt: String) {
        todayPrompt = prompt
        transitContext = nil
    }

    func saveEntry() {
        guard !currentEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let entry = JournalEntry(
            prompt: todayPrompt,
            response: currentEntry,
            transitContext: transitContext,
            moonPhase: "Waxing Crescent"
        )

        pastEntries.insert(entry, at: 0)
        currentEntry = ""
    }

    private func loadSampleEntries() {
        pastEntries = [
            JournalEntry(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                prompt: "Where do I feel most aligned with my authentic nature?",
                response: "Today I noticed a deep sense of alignment when I allowed myself to simply be present without trying to accomplish anything. The lunar energy feels gentle and supportive, like being held by the cosmos. I want to carry this softness with me.",
                moonPhase: "Waxing Crescent"
            ),
            JournalEntry(
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                prompt: "What patterns am I noticing in my emotional responses?",
                response: "I keep coming back to the same feeling of needing to prove myself. My Saturn return themes are clearly still active. But I also notice moments of breakthrough - times when I simply trust my path without needing external validation.",
                moonPhase: "New Moon"
            )
        ]
    }
}
