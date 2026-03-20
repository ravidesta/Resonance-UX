// ReflectionView.swift
// Luminous Cosmic Architecture™ — macOS Reflections
// Journal interface with rich text feel and cosmic prompts

import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var entries: [ReflectionEntry] = ReflectionEntry.samples
    @State private var selectedEntry: ReflectionEntry?
    @State private var isComposing: Bool = false
    @State private var newEntryText: String = ""
    @State private var newEntryTitle: String = ""
    @State private var searchText: String = ""

    var body: some View {
        HSplitView {
            // Entry list
            entryListPanel
                .frame(minWidth: 260, idealWidth: 300, maxWidth: 360)

            // Editor / reader
            if isComposing {
                composerPanel
                    .frame(minWidth: 400)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else if let entry = selectedEntry {
                readerPanel(entry: entry)
                    .frame(minWidth: 400)
                    .transition(.opacity)
            } else {
                emptyStatePanel
                    .frame(minWidth: 400)
            }
        }
        .onChange(of: appState.isComposingReflection) { _, newValue in
            if newValue {
                withAnimation(ResonanceMacTheme.Animation.spring) {
                    isComposing = true
                    appState.isComposingReflection = false
                }
            }
        }
    }

    // MARK: - Entry List

    private var entryListPanel: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                TextField("Search reflections...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(ResonanceMacTheme.Typography.body)
            }
            .padding(ResonanceMacTheme.Spacing.sm)
            .padding(.horizontal, ResonanceMacTheme.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.sm)
                    .fill(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.forestLight.opacity(0.3)
                            : ResonanceMacTheme.Colors.creamWarm
                    )
            )
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)

            Divider()
                .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

            // Entries
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredEntries) { entry in
                        entryRow(entry)
                    }
                }
                .padding(.vertical, ResonanceMacTheme.Spacing.xs)
            }

            Divider()
                .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

            // Compose button
            Button(action: {
                withAnimation(ResonanceMacTheme.Animation.spring) {
                    isComposing = true
                    newEntryTitle = ""
                    newEntryText = ""
                }
            }) {
                Label("New Reflection", systemImage: "plus.circle")
                    .font(ResonanceMacTheme.Typography.body)
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ResonanceMacTheme.Spacing.sm)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)
        }
        .background(
            appState.isNightMode
                ? ResonanceMacTheme.Colors.nightBackground.opacity(0.3)
                : ResonanceMacTheme.Colors.creamWarm.opacity(0.5)
        )
    }

    private func entryRow(_ entry: ReflectionEntry) -> some View {
        Button(action: {
            withAnimation(ResonanceMacTheme.Animation.quick) {
                selectedEntry = entry
                isComposing = false
            }
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.moonPhase.emoji)
                        .font(.system(size: 12))

                    Text(entry.title)
                        .font(ResonanceMacTheme.Typography.headline)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )
                        .lineLimit(1)

                    Spacer()
                }

                Text(entry.preview)
                    .font(ResonanceMacTheme.Typography.caption)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                    .lineLimit(2)

                Text(entry.formattedDate)
                    .font(ResonanceMacTheme.Typography.caption2)
                    .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.sm)
                    .fill(
                        selectedEntry?.id == entry.id
                            ? ResonanceMacTheme.Colors.gold.opacity(0.1)
                            : Color.clear
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, ResonanceMacTheme.Spacing.xs)
    }

    // MARK: - Composer

    private var composerPanel: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button("Cancel") {
                    withAnimation(ResonanceMacTheme.Animation.spring) {
                        isComposing = false
                    }
                }
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)

                Spacer()

                Text("New Reflection")
                    .font(ResonanceMacTheme.Typography.headline)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.cream
                            : ResonanceMacTheme.Colors.forestDeep
                    )

                Spacer()

                Button("Save") {
                    saveEntry()
                }
                .foregroundStyle(ResonanceMacTheme.Colors.gold)
                .disabled(newEntryText.isEmpty)
            }
            .padding(ResonanceMacTheme.Spacing.md)

            Divider()
                .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

            ScrollView {
                VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.lg) {
                    // Cosmic prompt
                    cosmicPrompt

                    // Title
                    TextField("Title your reflection...", text: $newEntryTitle)
                        .font(ResonanceMacTheme.Typography.title2)
                        .textFieldStyle(.plain)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )

                    // Body
                    TextEditor(text: $newEntryText)
                        .font(ResonanceMacTheme.Typography.body)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.creamWarm
                                : ResonanceMacTheme.Colors.forestMid
                        )
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 300)
                        .lineSpacing(6)
                }
                .padding(ResonanceMacTheme.Spacing.xl)
            }
        }
    }

    private var cosmicPrompt: some View {
        VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                Text("Today's Prompt")
                    .font(ResonanceMacTheme.Typography.caption)
                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
            }

            Text("With the Moon in Scorpio, what hidden truth is surfacing for you? How might you honor this emergence rather than resist it?")
                .font(ResonanceMacTheme.Typography.callout)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)
                .lineSpacing(4)
                .italic()
        }
        .padding(ResonanceMacTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                .fill(ResonanceMacTheme.Colors.gold.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                        .strokeBorder(ResonanceMacTheme.Colors.gold.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Reader

    private func readerPanel(entry: ReflectionEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: ResonanceMacTheme.Spacing.sm) {
                    HStack {
                        Text(entry.moonPhase.emoji)
                        Text(entry.moonPhase.rawValue)
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreen)

                        Spacer()

                        Text(entry.formattedDate)
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)
                    }

                    Text(entry.title)
                        .font(ResonanceMacTheme.Typography.largeTitle)
                        .foregroundStyle(
                            appState.isNightMode
                                ? ResonanceMacTheme.Colors.cream
                                : ResonanceMacTheme.Colors.forestDeep
                        )

                    if !entry.tags.isEmpty {
                        HStack(spacing: ResonanceMacTheme.Spacing.xs) {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(ResonanceMacTheme.Typography.caption2)
                                    .foregroundStyle(ResonanceMacTheme.Colors.gold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(ResonanceMacTheme.Colors.gold.opacity(0.1))
                                    )
                            }
                        }
                    }
                }

                Divider()
                    .overlay(ResonanceMacTheme.Colors.goldLight.opacity(0.2))

                // Body
                Text(entry.body)
                    .font(ResonanceMacTheme.Typography.body)
                    .foregroundStyle(
                        appState.isNightMode
                            ? ResonanceMacTheme.Colors.creamWarm
                            : ResonanceMacTheme.Colors.forestMid
                    )
                    .lineSpacing(8)
                    .textSelection(.enabled)
            }
            .padding(ResonanceMacTheme.Spacing.xl)
        }
    }

    // MARK: - Empty State

    private var emptyStatePanel: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight.opacity(0.5))

            Text("Select a reflection to read")
                .font(ResonanceMacTheme.Typography.body)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight)

            Text("or start a new one")
                .font(ResonanceMacTheme.Typography.caption)
                .foregroundStyle(ResonanceMacTheme.Colors.mutedGreenLight.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private var filteredEntries: [ReflectionEntry] {
        if searchText.isEmpty { return entries }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.body.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func saveEntry() {
        let entry = ReflectionEntry(
            title: newEntryTitle.isEmpty ? "Untitled Reflection" : newEntryTitle,
            body: newEntryText,
            date: Date(),
            moonPhase: appState.currentMoonPhase,
            tags: ["Scorpio Moon", "Pisces Season"]
        )
        entries.insert(entry, at: 0)
        selectedEntry = entry
        withAnimation(ResonanceMacTheme.Animation.spring) {
            isComposing = false
        }
    }
}

// MARK: - Reflection Entry Model

struct ReflectionEntry: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let date: Date
    let moonPhase: MoonPhase
    let tags: [String]

    var preview: String {
        String(body.prefix(120))
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static var samples: [ReflectionEntry] {
        [
            ReflectionEntry(
                title: "The Spiral Returns",
                body: "Today I noticed a pattern I thought I had moved beyond. But sitting with it, I realize this is not regression \u{2014} it is a deeper turn of the spiral. The same theme, but I meet it with more compassion now.\n\nThe Scorpio Moon illuminates what I have been avoiding: the tenderness beneath my resistance. There is something beautiful about being stripped of pretense, about the raw honesty the water signs demand.\n\nI want to remember this feeling. The vulnerability is not weakness. It is the doorway.",
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                moonPhase: .waxingCrescent,
                tags: ["Shadow Work", "Scorpio Moon"]
            ),
            ReflectionEntry(
                title: "Seeds in Dark Soil",
                body: "Pisces season asks me to surrender. Not to give up, but to give over \u{2014} to trust the current of something larger than my plans and timelines.\n\nI planted intentions at the New Moon. Now, in the dark soil of not-knowing, I practice patience. The seeds do not need my anxiety to grow. They need my faith.\n\nWhat if I could hold my dreams as lightly as I hold my breath during meditation? Present to them, but not gripping.",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                moonPhase: .newMoon,
                tags: ["Pisces Season", "New Moon"]
            ),
            ReflectionEntry(
                title: "Fire and Discipline",
                body: "Mars square Saturn today \u{2014} I felt it in my bones. The desire to act, held in tension with the need for structure. Rather than fight the friction, I asked: what is this tension trying to build?\n\nSometimes the resistance is not an obstacle. It is the resistance band that strengthens the muscle. I am building capacity for something larger.",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                moonPhase: .firstQuarter,
                tags: ["Mars-Saturn", "Discipline"]
            ),
        ]
    }
}
