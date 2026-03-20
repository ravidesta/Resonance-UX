// JournalView.swift
// Luminous Attachment — Resonance UX
// Three-mode journaling: Typed, Voice, Pencil with mood graph and past entries

import SwiftUI
import PencilKit
import AVFoundation
import Charts

struct JournalView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(UserProfile.self) private var profile

    @State private var selectedMode: JournalMode = .typed
    @State private var entryTitle: String = ""
    @State private var entryText: String = ""
    @State private var selectedMood: MoodLevel? = nil
    @State private var tags: [String] = []
    @State private var newTag: String = ""
    @State private var currentPrompt: JournalPrompt = JournalPrompt.promptOfTheDay()
    @State private var entries: [JournalEntry] = []
    @State private var showPastEntries = false
    @State private var showMoodGraph = false
    @State private var showSendToCoach = false
    @State private var showShareExcerpt = false
    @State private var shareText: String = ""

    // Voice recording state
    @State private var audioRecorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var recordingURL: URL?
    @State private var waveformSamples: [CGFloat] = Array(repeating: 0.1, count: 40)
    @State private var recordingTimer: Timer?

    // PencilKit state
    @State private var canvasDrawing = PKDrawing()

    var body: some View {
        let scheme = theme.effectiveScheme
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection(scheme: scheme)
                promptCard(scheme: scheme)
                modePicker(scheme: scheme)
                currentModeContent(scheme: scheme)
                moodSelector(scheme: scheme)
                tagsSection(scheme: scheme)
                actionButtons(scheme: scheme)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showMoodGraph = true
                } label: {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
                Button {
                    showPastEntries = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
        .sheet(isPresented: $showPastEntries) {
            pastEntriesSheet(scheme: scheme)
        }
        .sheet(isPresented: $showMoodGraph) {
            moodGraphSheet(scheme: scheme)
        }
        .sheet(isPresented: $showShareExcerpt) {
            ActivityViewController(activityItems: [shareText])
        }
    }

    // MARK: - Header

    @ViewBuilder
    private func headerSection(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                .font(.subheadline)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            Text("Reflect & Release")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(ResonanceColors.text(for: scheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - Prompt Card

    @ViewBuilder
    private func promptCard(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "sparkle")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("Today's Prompt")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .textCase(.uppercase)
                    .tracking(1)
                Spacer()
                Button {
                    currentPrompt = JournalPrompt.dailyPrompts.randomElement() ?? currentPrompt
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
            Text(currentPrompt.text)
                .font(.body.weight(.medium).leading(.loose))
                .foregroundStyle(ResonanceColors.text(for: scheme))
                .fixedSize(horizontal: false, vertical: true)

            Text(currentPrompt.category)
                .font(.caption2.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(ResonanceColors.goldPrimary.opacity(0.12)))
                .foregroundStyle(ResonanceColors.goldPrimary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ResonanceColors.goldPrimary.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Mode Picker

    @ViewBuilder
    private func modePicker(scheme: ColorScheme) -> some View {
        HStack(spacing: 4) {
            ForEach(JournalMode.allCases, id: \.rawValue) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        Text(mode.rawValue)
                            .font(.caption.weight(.medium))
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedMode == mode
                                  ? ResonanceColors.goldPrimary
                                  : Color.clear)
                    )
                    .foregroundStyle(selectedMode == mode
                                    ? ResonanceColors.green900
                                    : ResonanceColors.textSecondary(for: scheme))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ResonanceColors.surfaceSecondary(for: scheme))
        )
    }

    // MARK: - Mode Content

    @ViewBuilder
    private func currentModeContent(scheme: ColorScheme) -> some View {
        switch selectedMode {
        case .typed:
            typedJournalView(scheme: scheme)
        case .voice:
            voiceJournalView(scheme: scheme)
        case .pencil:
            pencilJournalView(scheme: scheme)
        }
    }

    // MARK: Typed Journal

    @ViewBuilder
    private func typedJournalView(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Entry title...", text: $entryTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(ResonanceColors.text(for: scheme))
                .padding(.horizontal, 4)

            TextEditor(text: $entryText)
                .font(.body.leading(.loose))
                .foregroundStyle(ResonanceColors.text(for: scheme))
                .scrollContentBackground(.hidden)
                .frame(minHeight: 220)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ResonanceColors.surface(for: scheme))
                )
                .overlay(alignment: .topLeading) {
                    if entryText.isEmpty {
                        Text("Begin writing your reflection here...\n\nLet your thoughts flow without judgment. This space is yours.")
                            .font(.body)
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.5))
                            .padding(16)
                            .allowsHitTesting(false)
                    }
                }

            // Word count
            HStack {
                Spacer()
                Text("\(entryText.split(separator: " ").count) words")
                    .font(.caption2)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }
        }
    }

    // MARK: Voice Journal

    @ViewBuilder
    private func voiceJournalView(scheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            // Waveform visualization
            HStack(spacing: 2) {
                ForEach(Array(waveformSamples.enumerated()), id: \.offset) { index, sample in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            isRecording
                                ? ResonanceColors.goldPrimary
                                : ResonanceColors.textSecondary(for: scheme).opacity(0.3)
                        )
                        .frame(width: 4, height: max(4, sample * 60))
                        .animation(
                            .easeInOut(duration: 0.1).delay(Double(index) * 0.01),
                            value: sample
                        )
                }
            }
            .frame(height: 70)
            .padding(.horizontal)

            // Duration
            Text(formatDuration(recordingDuration))
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundStyle(
                    isRecording
                        ? ResonanceColors.goldPrimary
                        : ResonanceColors.text(for: scheme)
                )

            // Recording status
            if isRecording {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .opacity(recordingDuration.truncatingRemainder(dividingBy: 1.0) > 0.5 ? 1 : 0.3)
                    Text("Recording")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.red)
                }
            }

            // Controls
            HStack(spacing: 40) {
                // Discard
                Button {
                    stopRecording()
                    recordingDuration = 0
                    waveformSamples = Array(repeating: 0.1, count: 40)
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(ResonanceColors.surfaceSecondary(for: scheme))
                        )
                }
                .opacity(recordingDuration > 0 ? 1 : 0.3)
                .disabled(recordingDuration == 0)

                // Record button
                Button {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                isRecording
                                    ? .red.opacity(0.15)
                                    : ResonanceColors.goldPrimary.opacity(0.15)
                            )
                            .frame(width: 80, height: 80)
                        Circle()
                            .fill(isRecording ? .red : ResonanceColors.goldPrimary)
                            .frame(width: 64, height: 64)
                        if isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white)
                                .frame(width: 22, height: 22)
                        } else {
                            Circle()
                                .fill(.white)
                                .frame(width: 28, height: 28)
                        }
                    }
                }

                // Save
                Button {
                    saveVoiceEntry()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(ResonanceColors.goldPrimary)
                        )
                }
                .opacity(recordingDuration > 0 && !isRecording ? 1 : 0.3)
                .disabled(recordingDuration == 0 || isRecording)
            }

            // Voice note text
            TextField("Add a note about this recording...", text: $entryText, axis: .vertical)
                .lineLimit(2...4)
                .font(.body)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ResonanceColors.surface(for: scheme))
                )
        }
        .padding(.vertical, 20)
    }

    // MARK: Pencil Journal

    @ViewBuilder
    private func pencilJournalView(scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            Text("Draw or write with Apple Pencil")
                .font(.caption)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))

            PencilCanvasView(drawing: $canvasDrawing)
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ResonanceColors.goldPrimary.opacity(0.2), lineWidth: 1)
                )

            HStack {
                Button {
                    canvasDrawing = PKDrawing()
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                }
                Spacer()
                Text("PencilKit enabled")
                    .font(.caption2)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.5))
            }

            TextField("Caption your drawing...", text: $entryText, axis: .vertical)
                .lineLimit(2...3)
                .font(.body)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ResonanceColors.surface(for: scheme))
                )
        }
    }

    // MARK: - Mood Selector

    @ViewBuilder
    private func moodSelector(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How does this entry make you feel?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(ResonanceColors.text(for: scheme))
            HStack(spacing: 0) {
                ForEach(MoodLevel.allCases) { mood in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedMood = selectedMood == mood ? nil : mood
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    selectedMood == mood ? mood.color : ResonanceColors.textSecondary(for: scheme).opacity(0.5)
                                )
                                .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                            Text(mood.name)
                                .font(.caption2)
                                .foregroundStyle(
                                    selectedMood == mood ? mood.color : ResonanceColors.textSecondary(for: scheme).opacity(0.5)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(ResonanceColors.surface(for: scheme))
        )
    }

    // MARK: - Tags

    @ViewBuilder
    private func tagsSection(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(ResonanceColors.text(for: scheme))

            // Existing tags
            if !tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(.caption.weight(.medium))
                            Button {
                                tags.removeAll { $0 == tag }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption2)
                            }
                        }
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

            // Add tag
            HStack(spacing: 8) {
                TextField("Add tag...", text: $newTag)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ResonanceColors.surfaceSecondary(for: scheme))
                    )
                    .onSubmit {
                        addTag()
                    }
                Button {
                    addTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }

            // Suggested tags
            HStack(spacing: 6) {
                Text("Suggested:")
                    .font(.caption2)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                ForEach(["attachment", "growth", "safe", "anxious", "healing"], id: \.self) { tag in
                    Button {
                        if !tags.contains(tag) {
                            tags.append(tag)
                        }
                    } label: {
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .strokeBorder(ResonanceColors.textSecondary(for: scheme).opacity(0.3), lineWidth: 1)
                            )
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private func actionButtons(scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            // Save Entry
            Button {
                saveEntry()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Entry")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(ResonanceColors.green900)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [ResonanceColors.goldPrimary, ResonanceColors.goldLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)

            // Secondary actions
            HStack(spacing: 12) {
                Button {
                    showSendToCoach = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "paperplane")
                        Text("Send to Coach")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ResonanceColors.goldPrimary.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                .alert("Send to Coach", isPresented: $showSendToCoach) {
                    Button("Send") {
                        // Mark entry as shared with coach
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Share this journal entry with your attachment coach for personalized guidance?")
                }

                Button {
                    shareText = "\"\(entryText.prefix(200))...\"\n\n— From my journal in Luminous Attachment"
                    showShareExcerpt = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Excerpt")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(ResonanceColors.goldPrimary.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Past Entries Sheet

    @ViewBuilder
    private func pastEntriesSheet(scheme: ColorScheme) -> some View {
        NavigationStack {
            if entries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.4))
                    Text("No entries yet")
                        .font(.title3)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                    Text("Your reflections will appear here as you journal.")
                        .font(.subheadline)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(entries) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: entry.mode.icon)
                                .font(.caption)
                                .foregroundStyle(ResonanceColors.goldPrimary)
                            Text(entry.title.isEmpty ? "Untitled" : entry.title)
                                .font(.headline)
                                .foregroundStyle(ResonanceColors.text(for: scheme))
                            Spacer()
                            if let mood = entry.mood {
                                Image(systemName: mood.icon)
                                    .foregroundStyle(mood.color)
                            }
                        }
                        Text(entry.textContent.prefix(120) + (entry.textContent.count > 120 ? "..." : ""))
                            .font(.subheadline)
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                            .lineLimit(2)
                        HStack {
                            Text(entry.date, style: .date)
                                .font(.caption2)
                                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                            Spacer()
                            if !entry.tags.isEmpty {
                                Text(entry.tags.joined(separator: ", "))
                                    .font(.caption2)
                                    .foregroundStyle(ResonanceColors.goldPrimary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            NavigationStack {
            }
            .navigationTitle("Past Entries")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showPastEntries = false }
                        .tint(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Mood Graph Sheet

    @ViewBuilder
    private func moodGraphSheet(scheme: ColorScheme) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                if profile.moodHistory.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 40))
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.4))
                        Text("No mood data yet")
                            .font(.title3)
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                        Text("Check in with your mood daily to see your patterns over time.")
                            .font(.subheadline)
                            .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Chart {
                        ForEach(profile.moodHistory) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Mood", entry.level.rawValue)
                            )
                            .foregroundStyle(ResonanceColors.goldPrimary)
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Date", entry.date),
                                y: .value("Mood", entry.level.rawValue)
                            )
                            .foregroundStyle(entry.level.color)
                            .symbolSize(40)

                            AreaMark(
                                x: .value("Date", entry.date),
                                y: .value("Mood", entry.level.rawValue)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        ResonanceColors.goldPrimary.opacity(0.3),
                                        ResonanceColors.goldPrimary.opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .chartYScale(domain: 1...5)
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                            AxisValueLabel {
                                if let intValue = value.as(Int.self),
                                   let mood = MoodLevel(rawValue: intValue) {
                                    Image(systemName: mood.icon)
                                        .font(.caption2)
                                        .foregroundStyle(mood.color)
                                }
                            }
                        }
                    }
                    .frame(height: 250)
                    .padding(.horizontal)

                    // Summary
                    if let average = averageMood {
                        VStack(spacing: 8) {
                            Text("Your average mood")
                                .font(.caption)
                                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                            HStack(spacing: 8) {
                                Image(systemName: average.icon)
                                    .font(.title2)
                                    .foregroundStyle(average.color)
                                Text(average.name)
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(ResonanceColors.text(for: scheme))
                            }
                            Text(average.description)
                                .font(.subheadline)
                                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Mood Insights")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showMoodGraph = false }
                        .tint(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Helpers

    private var averageMood: MoodLevel? {
        guard !profile.moodHistory.isEmpty else { return nil }
        let sum = profile.moodHistory.reduce(0) { $0 + $1.level.rawValue }
        let avg = Double(sum) / Double(profile.moodHistory.count)
        return MoodLevel(rawValue: Int(avg.rounded())) ?? .leaf
    }

    private func addTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        newTag = ""
    }

    private func saveEntry() {
        var pencilData: Data? = nil
        if selectedMode == .pencil {
            pencilData = canvasDrawing.dataRepresentation()
        }
        let entry = JournalEntry(
            title: entryTitle,
            textContent: entryText,
            voiceRecordingURL: recordingURL,
            pencilDrawingData: pencilData,
            mood: selectedMood,
            tags: tags,
            prompt: currentPrompt.text,
            isFavorite: false,
            isSharedWithCoach: false,
            mode: selectedMode
        )
        entries.insert(entry, at: 0)
        profile.totalJournalEntries += 1

        // Reset
        entryTitle = ""
        entryText = ""
        selectedMood = nil
        tags = []
        canvasDrawing = PKDrawing()
        recordingURL = nil
        recordingDuration = 0
    }

    private func saveVoiceEntry() {
        saveEntry()
    }

    // MARK: - Recording

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            return
        }

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = documentsPath.appendingPathComponent("journal_\(UUID().uuidString).m4a")
        recordingURL = audioFileName

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            recordingDuration = 0

            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                recordingDuration += 0.05
                audioRecorder?.updateMeters()
                let power = audioRecorder?.averagePower(forChannel: 0) ?? -160
                let normalizedPower = max(0, (power + 50) / 50)
                waveformSamples.removeFirst()
                waveformSamples.append(CGFloat(normalizedPower))
            }
        } catch {
            isRecording = false
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let centiseconds = Int((duration.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }
}

// MARK: - PencilKit Canvas

struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = UIColor(Color(hex: "FAFAF8"))
        canvas.isOpaque = false

        // Configure tool picker
        let toolPicker = PKToolPicker()
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()

        // Set default tool
        let ink = PKInkingTool(.pen, color: UIColor(Color(hex: "1B402E")), width: 3)
        canvas.tool = ink

        // Store tool picker reference
        context.coordinator.toolPicker = toolPicker

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var toolPicker: PKToolPicker?

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        JournalView()
    }
    .environment(ThemeManager())
    .environment(UserProfile())
}
