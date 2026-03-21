// DiaryView.swift
// Haute Lumière — Personal Diary
//
// Video · Audio · Text diary with a dark, luxurious aesthetic.
// Black base, dark lace accents, gold details, warm cream text.
// Every entry generates a profound question worth sharing.

import SwiftUI
import AVFoundation

struct DiaryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @StateObject private var questionEngine = ProfoundQuestionEngine()

    @State private var entries: [DiaryEntry] = DiaryEntry.sampleEntries
    @State private var showingNewEntry = false
    @State private var selectedEntry: DiaryEntry?

    private var palette: HLColorPalette { appState.selectedColorPalette }

    var body: some View {
        ZStack {
            DarkLaceBackground(palette: palette)

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Header
                    diaryHeader

                    // Today's Profound Question (if exists)
                    if let question = questionEngine.currentQuestion {
                        profoundQuestionCard(question)
                    }

                    // New Entry Button
                    newEntryButton

                    // Entry Timeline
                    LazyVStack(spacing: HLSpacing.md) {
                        ForEach(entries.sorted(by: { $0.createdAt > $1.createdAt })) { entry in
                            DiaryEntryCard(entry: entry, palette: palette)
                                .onTapGesture { selectedEntry = entry }
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.top, HLSpacing.md)
            }
        }
        .sheet(isPresented: $showingNewEntry) {
            NewDiaryEntryView(
                entries: $entries,
                questionEngine: questionEngine,
                appState: appState
            )
        }
        .sheet(item: $selectedEntry) { entry in
            DiaryEntryDetailView(entry: entry, palette: palette)
        }
    }

    // MARK: - Header
    private var diaryHeader: some View {
        VStack(spacing: HLSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Diary")
                        .font(HLTypography.serifMedium(28))
                        .foregroundColor(palette.textPrimary)

                    Text("\(entries.count) entries · \(streakText)")
                        .font(HLTypography.caption)
                        .foregroundColor(palette.textSecondary)
                }
                Spacer()

                // Selfie/video indicator
                ZStack {
                    Circle()
                        .fill(palette.accentPrimary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(palette.accentPrimary)
                }
            }
        }
    }

    // MARK: - Profound Question Card
    private func profoundQuestionCard(_ question: ProfoundQuestion) -> some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: "quote.opening")
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundColor(palette.accentPrimary.opacity(0.6))

            Text(question.text)
                .font(HLTypography.serifItalic(18))
                .foregroundColor(palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if let attribution = question.attribution {
                Text("— \(attribution)")
                    .font(HLTypography.caption)
                    .foregroundColor(palette.textSecondary)
            }

            // Share to studio button
            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12))
                    Text("Share to Studio")
                        .font(HLTypography.label)
                }
                .foregroundColor(palette.accentPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(palette.accentPrimary.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .hlDiaryCard(palette: palette)
    }

    // MARK: - New Entry Button
    private var newEntryButton: some View {
        Button(action: { showingNewEntry = true }) {
            HStack(spacing: HLSpacing.md) {
                // Type indicators
                HStack(spacing: 12) {
                    entryTypeIcon("text.alignleft", label: "Write")
                    entryTypeIcon("mic.fill", label: "Record")
                    entryTypeIcon("video.fill", label: "Video")
                    entryTypeIcon("camera.fill", label: "Selfie")
                }

                Spacer()

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(palette.accentPrimary)
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(palette.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: HLRadius.lg)
                            .stroke(palette.accentPrimary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    )
            )
        }
    }

    private func entryTypeIcon(_ icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(palette.accentLight)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(palette.textSecondary)
        }
    }

    private var streakText: String {
        let count = entries.filter {
            Calendar.current.isDate($0.createdAt, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
        return "\(count) this week"
    }
}

// MARK: - Diary Entry Card
struct DiaryEntryCard: View {
    let entry: DiaryEntry
    let palette: HLColorPalette

    var body: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            // Date + Mood
            HStack {
                Text(entry.createdAt, style: .date)
                    .font(HLTypography.caption)
                    .foregroundColor(palette.textSecondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: entry.mood.icon)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: entry.mood.accentColor))
                    Text(entry.mood.rawValue)
                        .font(HLTypography.caption)
                        .foregroundColor(palette.textSecondary)
                }
            }

            // Media type indicators
            HStack(spacing: 8) {
                if !entry.textContent.isEmpty {
                    mediaBadge("text.alignleft", "Text")
                }
                if entry.audioFileURL != nil {
                    mediaBadge("waveform", "Audio")
                }
                if entry.videoFileURL != nil {
                    mediaBadge("video.fill", "Video")
                }
                if entry.selfieImageData != nil {
                    mediaBadge("camera.fill", "Selfie")
                }
            }

            // Text preview
            if !entry.textContent.isEmpty {
                Text(entry.textContent)
                    .font(HLTypography.body)
                    .foregroundColor(palette.textPrimary.opacity(0.8))
                    .lineLimit(3)
                    .lineSpacing(2)
            }

            // Profound question (if generated)
            if let question = entry.profoundQuestion {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(palette.accentPrimary.opacity(0.4))
                        .frame(width: 2)

                    Text(question.text)
                        .font(HLTypography.serifItalic(13))
                        .foregroundColor(palette.accentLight.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(.top, 4)
            }
        }
        .hlDiaryCard(palette: palette)
    }

    private func mediaBadge(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 9))
        }
        .foregroundColor(palette.accentPrimary.opacity(0.7))
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(palette.accentPrimary.opacity(0.08))
        .clipShape(Capsule())
    }
}

// MARK: - New Diary Entry View
struct NewDiaryEntryView: View {
    @Binding var entries: [DiaryEntry]
    @ObservedObject var questionEngine: ProfoundQuestionEngine
    var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var textContent = ""
    @State private var selectedMood: DiaryEntry.DiaryMood = .contemplative
    @State private var isRecordingAudio = false
    @State private var isRecordingVideo = false
    @State private var generatedQuestion: ProfoundQuestion?

    private var palette: HLColorPalette { appState.selectedColorPalette }

    var body: some View {
        NavigationStack {
            ZStack {
                DarkLaceBackground(palette: palette)

                ScrollView {
                    VStack(spacing: HLSpacing.lg) {
                        // Mood selector
                        moodSelector

                        // Text editor
                        textEditor

                        // Media buttons
                        mediaButtons

                        // Generated question preview
                        if let question = generatedQuestion {
                            questionPreview(question)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(HLSpacing.lg)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(palette.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .foregroundColor(palette.accentPrimary)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("How are you feeling?")
                .font(HLTypography.label)
                .foregroundColor(palette.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(DiaryEntry.DiaryMood.allCases, id: \.self) { mood in
                        Button(action: { selectedMood = mood }) {
                            VStack(spacing: 4) {
                                Image(systemName: mood.icon)
                                    .font(.system(size: 18))
                                Text(mood.rawValue)
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(selectedMood == mood ? palette.accentPrimary : palette.textSecondary)
                            .frame(width: 64, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: HLRadius.md)
                                    .fill(selectedMood == mood ? palette.accentPrimary.opacity(0.12) : palette.cardFill)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: HLRadius.md)
                                    .stroke(selectedMood == mood ? palette.accentPrimary.opacity(0.4) : .clear, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    private var textEditor: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("What's alive in you?")
                .font(HLTypography.serifMedium(18))
                .foregroundColor(palette.textPrimary)

            TextEditor(text: $textContent)
                .font(.custom(HLTypography.currentPairing.sansFamily, size: 15))
                .foregroundColor(palette.textPrimary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 200)
                .padding(HLSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: HLRadius.lg)
                        .fill(palette.cardFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.lg)
                        .stroke(palette.accentPrimary.opacity(0.15), lineWidth: 0.5)
                )
                .onChange(of: textContent) { _, newValue in
                    if newValue.count > 50 {
                        let entry = DiaryEntry(textContent: newValue, mood: selectedMood)
                        generatedQuestion = questionEngine.generateQuestion(
                            from: entry,
                            phase: appState.currentCyclePhase,
                            livingProfile: appState.livingSystemsProfile
                        )
                    }
                }
        }
    }

    private var mediaButtons: some View {
        HStack(spacing: HLSpacing.md) {
            mediaButton(icon: "mic.fill", label: "Voice Note", isActive: isRecordingAudio) {
                isRecordingAudio.toggle()
            }
            mediaButton(icon: "video.fill", label: "Video", isActive: isRecordingVideo) {
                isRecordingVideo.toggle()
            }
            mediaButton(icon: "camera.fill", label: "Selfie", isActive: false) {
                // Camera picker
            }
        }
    }

    private func mediaButton(icon: String, label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isActive ? palette.accentPrimary.opacity(0.2) : palette.cardFill)
                        .frame(width: 48, height: 48)
                    if isActive {
                        Circle()
                            .stroke(palette.accentPrimary, lineWidth: 2)
                            .frame(width: 48, height: 48)
                    }
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isActive ? palette.accentPrimary : palette.textSecondary)
                }
                Text(label)
                    .font(HLTypography.caption)
                    .foregroundColor(palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func questionPreview(_ question: ProfoundQuestion) -> some View {
        VStack(spacing: HLSpacing.sm) {
            Text("Your Question")
                .font(HLTypography.label)
                .foregroundColor(palette.accentPrimary)

            Text(question.text)
                .font(HLTypography.serifItalic(16))
                .foregroundColor(palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .hlDiaryCard(palette: palette)
    }

    private func saveEntry() {
        var entry = DiaryEntry(textContent: textContent, mood: selectedMood)
        entry.profoundQuestion = generatedQuestion
        entries.append(entry)
        dismiss()
    }
}

// MARK: - Diary Entry Detail View
struct DiaryEntryDetailView: View {
    let entry: DiaryEntry
    let palette: HLColorPalette
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DarkLaceBackground(palette: palette)

                ScrollView {
                    VStack(alignment: .leading, spacing: HLSpacing.lg) {
                        // Date & mood header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.createdAt, style: .date)
                                    .font(HLTypography.serifMedium(20))
                                    .foregroundColor(palette.textPrimary)
                                Text(entry.createdAt, style: .time)
                                    .font(HLTypography.caption)
                                    .foregroundColor(palette.textSecondary)
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: entry.mood.icon)
                                    .foregroundColor(Color(hex: entry.mood.accentColor))
                                Text(entry.mood.rawValue)
                                    .foregroundColor(palette.textSecondary)
                            }
                            .font(HLTypography.label)
                        }

                        // Full text
                        Text(entry.textContent)
                            .font(HLTypography.bodyLarge)
                            .foregroundColor(palette.textPrimary.opacity(0.9))
                            .lineSpacing(4)

                        // Profound question
                        if let question = entry.profoundQuestion {
                            VStack(spacing: HLSpacing.md) {
                                Rectangle()
                                    .fill(palette.accentPrimary.opacity(0.2))
                                    .frame(height: 0.5)

                                Text(question.text)
                                    .font(HLTypography.serifItalic(20))
                                    .foregroundColor(palette.accentLight)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)

                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share to Studio")
                                    }
                                    .font(HLTypography.label)
                                    .foregroundColor(palette.accentPrimary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(palette.accentPrimary.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.top, HLSpacing.md)
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(HLSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(palette.textSecondary)
                }
            }
        }
    }
}

// MARK: - Sample Data
extension DiaryEntry {
    static let sampleEntries: [DiaryEntry] = [
        {
            var e = DiaryEntry(textContent: "Woke up early today and sat in silence for twenty minutes before the house stirred. Something about the quality of light at 5:30am — it's like the world is holding its breath. I noticed I wasn't reaching for my phone. That felt like a small victory.", mood: .peaceful)
            e.profoundQuestion = ProfoundQuestion(text: "What would you discover about yourself if you sat still for an hour with no input?", theme: .stillness, attribution: nil)
            return e
        }(),
        {
            var e = DiaryEntry(textContent: "Had a difficult conversation with Sarah today. Realized I've been holding onto a version of our friendship that doesn't exist anymore. Not in a sad way — in a 'making room' way. Growth sometimes means letting the shape of things change.", mood: .contemplative)
            e.profoundQuestion = ProfoundQuestion(text: "What are you still carrying that was never yours to hold?", theme: .loss, attribution: nil)
            return e
        }(),
        {
            var e = DiaryEntry(textContent: "Crushed my presentation today. Felt completely in flow — like the words were choosing themselves. Marcus would call it 'executive presence' but it felt more like finally trusting myself enough to stop rehearsing.", mood: .radiant)
            e.profoundQuestion = ProfoundQuestion(text: "Where in your life have you been asking for permission you don't need?", theme: .power, attribution: nil)
            return e
        }(),
    ]
}
