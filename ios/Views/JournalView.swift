// JournalView.swift
// Resonance UX — Daily Journal & Reflection
//
// A spacious, intentional journaling experience that adapts to the
// current flow phase. Mood and energy tracking use organic visual
// indicators rather than clinical scales. The AI coach offers gentle
// suggestions — never prescriptive, always spacious.

import SwiftUI

// MARK: - Journal Models

struct JournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var reflectionText: String
    var gratitudeEntries: [String]
    var moodValue: Double          // 0.0 – 1.0 organic scale
    var energyValue: Double        // 0.0 – 1.0
    var phase: DailyPhaseKind
    var tags: [String]
    var biomarkerSnapshot: BiomarkerSnapshot?
    var isDeepRestEntry: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        reflectionText: String = "",
        gratitudeEntries: [String] = [],
        moodValue: Double = 0.5,
        energyValue: Double = 0.5,
        phase: DailyPhaseKind = .ascend,
        tags: [String] = [],
        biomarkerSnapshot: BiomarkerSnapshot? = nil,
        isDeepRestEntry: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.reflectionText = reflectionText
        self.gratitudeEntries = gratitudeEntries
        self.moodValue = moodValue
        self.energyValue = energyValue
        self.phase = phase
        self.tags = tags
        self.biomarkerSnapshot = biomarkerSnapshot
        self.isDeepRestEntry = isDeepRestEntry
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct BiomarkerSnapshot: Codable, Hashable {
    var hrvValue: Double?
    var sleepQuality: Double?
    var stressLevel: Double?
    var restingHeartRate: Int?
}

struct CoachSuggestion: Identifiable {
    let id = UUID()
    var text: String
    var category: SuggestionCategory
    var isExpanded: Bool = false

    enum SuggestionCategory: String {
        case breathwork  = "Breathwork"
        case reflection  = "Reflection"
        case movement    = "Movement"
        case rest        = "Rest"
        case gratitude   = "Gratitude"
        case connection  = "Connection"

        var icon: String {
            switch self {
            case .breathwork:  return "wind"
            case .reflection:  return "text.quote"
            case .movement:    return "figure.walk"
            case .rest:        return "moon.stars"
            case .gratitude:   return "heart"
            case .connection:  return "person.2"
            }
        }
    }
}

// MARK: - Journal View

struct JournalView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @Environment(\.currentPhase) private var currentPhase
    @EnvironmentObject private var appState: ResonanceAppState

    @State private var entries: [JournalEntry] = JournalEntry.samples
    @State private var selectedEntry: JournalEntry?
    @State private var isComposing = false
    @State private var showCalendarHeatMap = false
    @State private var showCoachPanel = false
    @State private var newReflectionText = ""
    @State private var newGratitudeItems: [String] = ["", "", ""]
    @State private var moodValue: Double = 0.5
    @State private var energyValue: Double = 0.5
    @State private var breatheAnimation = false
    @State private var coachSuggestions: [CoachSuggestion] = CoachSuggestion.samplesForPhase(.ascend)

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

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: ResonanceTheme.Spacing.xl) {
                        // Phase-aware greeting
                        phaseGreetingSection

                        // Mood & energy organic indicators
                        moodEnergySection

                        // Daily reflection prompt
                        reflectionPromptSection

                        // Gratitude entries
                        gratitudeSection

                        // Biomarker integration
                        biomarkerWellnessCard

                        // AI coach suggestions panel
                        if showCoachPanel {
                            coachSuggestionsPanel
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }

                        // Calendar heat map
                        if showCalendarHeatMap {
                            calendarHeatMapSection
                                .transition(.opacity)
                        }

                        // Recent entries
                        recentEntriesSection

                        Spacer(minLength: ResonanceTheme.Spacing.xxxl)
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.lg)
                    .padding(.top, ResonanceTheme.Spacing.md)
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(ResonanceTheme.Animation.gentle) {
                            showCalendarHeatMap.toggle()
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(ResonanceTheme.Light.gold)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: ResonanceTheme.Spacing.sm) {
                        Button {
                            withAnimation(ResonanceTheme.Animation.gentle) {
                                showCoachPanel.toggle()
                            }
                        } label: {
                            Image(systemName: "sparkles")
                                .foregroundColor(ResonanceTheme.Light.gold)
                        }
                        Button {
                            isComposing = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(ResonanceTheme.Light.gold)
                        }
                    }
                }
            }
            .sheet(isPresented: $isComposing) {
                JournalComposeSheet(
                    reflectionText: $newReflectionText,
                    gratitudeItems: $newGratitudeItems,
                    moodValue: $moodValue,
                    energyValue: $energyValue,
                    phase: currentPhase,
                    isDeepRest: isDeepRest,
                    onSave: saveNewEntry
                )
            }
            .onChange(of: currentPhase) { newPhase in
                withAnimation(ResonanceTheme.Animation.calm) {
                    coachSuggestions = CoachSuggestion.samplesForPhase(newPhase)
                }
            }
        }
    }

    // MARK: - Phase Greeting

    private var phaseGreetingSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            HStack {
                Image(systemName: currentPhase.icon)
                    .font(.system(size: 20, weight: .ultraLight))
                    .foregroundColor(currentPhase.color)
                    .scaleEffect(breatheAnimation ? 1.1 : 1.0)
                    .onAppear {
                        withAnimation(ResonanceTheme.Animation.breathe) {
                            breatheAnimation = true
                        }
                    }

                Text(phaseGreeting)
                    .font(ResonanceTheme.Typography.displayMedium)
                    .foregroundColor(textColor)
            }

            Text(reflectionPromptForPhase)
                .font(ResonanceTheme.Typography.bodyLarge)
                .foregroundColor(mutedColor)
                .lineSpacing(4)
        }
        .padding(.top, ResonanceTheme.Spacing.md)
    }

    private var phaseGreeting: String {
        switch currentPhase {
        case .ascend:  return "Good morning"
        case .zenith:  return "Midday pause"
        case .descent: return "Evening reflection"
        case .rest:    return "Quiet hours"
        }
    }

    private var reflectionPromptForPhase: String {
        switch currentPhase {
        case .ascend:
            return "What intention would you like to carry into this day?"
        case .zenith:
            return "Pause for a moment. How has your energy been flowing?"
        case .descent:
            return "What are you grateful for today? What will you release?"
        case .rest:
            return "Let the day settle. What wisdom did it carry?"
        }
    }

    // MARK: - Mood & Energy Indicators

    private var moodEnergySection: some View {
        HStack(spacing: ResonanceTheme.Spacing.lg) {
            OrganicIndicator(
                label: "Mood",
                value: moodValue,
                color: moodColor(moodValue),
                icon: moodIcon(moodValue)
            )
            OrganicIndicator(
                label: "Energy",
                value: energyValue,
                color: energyColor(energyValue),
                icon: energyIcon(energyValue)
            )
        }
        .padding(.vertical, ResonanceTheme.Spacing.sm)
    }

    private func moodColor(_ value: Double) -> Color {
        if value < 0.3 { return Color(hex: 0x5C7065) }
        if value < 0.6 { return Color(hex: 0xC5A059) }
        return Color(hex: 0x2D5A3F)
    }

    private func moodIcon(_ value: Double) -> String {
        if value < 0.3 { return "cloud" }
        if value < 0.6 { return "cloud.sun" }
        return "sun.max"
    }

    private func energyColor(_ value: Double) -> Color {
        if value < 0.3 { return Color(hex: 0x5C7065) }
        if value < 0.6 { return Color(hex: 0xC5A059) }
        return Color(hex: 0x0A1C14)
    }

    private func energyIcon(_ value: Double) -> String {
        if value < 0.3 { return "leaf" }
        if value < 0.6 { return "wind" }
        return "bolt.fill"
    }

    // MARK: - Reflection Prompt

    private var reflectionPromptSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Today's Reflection")
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(textColor)

            if let entry = todayEntry {
                Text(entry.reflectionText)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(textColor.opacity(0.85))
                    .lineSpacing(6)
                    .padding(ResonanceTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(surfaceColor)
                    .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                            .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle, lineWidth: 1)
                    )
            } else {
                Button {
                    isComposing = true
                } label: {
                    HStack {
                        Image(systemName: "pencil.line")
                            .foregroundColor(ResonanceTheme.Light.gold)
                        Text("Begin today's reflection...")
                            .font(ResonanceTheme.Typography.bodyLarge)
                            .foregroundColor(mutedColor)
                    }
                    .padding(ResonanceTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(surfaceColor.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                            .foregroundColor(mutedColor.opacity(0.3))
                    )
                }
            }
        }
    }

    // MARK: - Gratitude Section

    private var gratitudeSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Gratitude")
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(textColor)

            if let entry = todayEntry, !entry.gratitudeEntries.isEmpty {
                ForEach(Array(entry.gratitudeEntries.enumerated()), id: \.offset) { index, item in
                    GratitudeRow(text: item, index: index, textColor: textColor, goldColor: ResonanceTheme.Light.gold)
                }
            } else {
                ForEach(0..<3, id: \.self) { index in
                    GratitudeRow(
                        text: nil,
                        index: index,
                        textColor: textColor,
                        goldColor: ResonanceTheme.Light.gold
                    )
                    .onTapGesture { isComposing = true }
                }
            }
        }
    }

    // MARK: - Biomarker Wellness Card

    private var biomarkerWellnessCard: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Wellness Snapshot")
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(textColor)

            HStack(spacing: ResonanceTheme.Spacing.md) {
                WellnessMetricBubble(
                    label: "HRV",
                    value: "62ms",
                    trend: .rising,
                    color: Color(hex: 0x2D5A3F)
                )
                WellnessMetricBubble(
                    label: "Sleep",
                    value: "7.4h",
                    trend: .stable,
                    color: Color(hex: 0x122E21)
                )
                WellnessMetricBubble(
                    label: "Stress",
                    value: "Low",
                    trend: .falling,
                    color: Color(hex: 0xC5A059)
                )
            }
            .padding(ResonanceTheme.Spacing.lg)
            .background(surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                    .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle, lineWidth: 1)
            )
        }
    }

    // MARK: - AI Coach Suggestions Panel

    private var coachSuggestionsPanel: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(ResonanceTheme.Light.gold)
                Text("Gentle Suggestions")
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(textColor)
                Spacer()
                Text("for \(currentPhase.label)")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor)
            }

            ForEach(coachSuggestions) { suggestion in
                CoachSuggestionCard(
                    suggestion: suggestion,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    surfaceColor: surfaceColor,
                    isDeepRest: isDeepRest
                )
            }

            Text("These are invitations, not instructions. Follow what resonates.")
                .font(ResonanceTheme.Typography.bodySmall)
                .foregroundColor(mutedColor.opacity(0.7))
                .italic()
                .padding(.top, ResonanceTheme.Spacing.xs)
        }
        .padding(ResonanceTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.xl)
                .fill(surfaceColor.opacity(isDeepRest ? 0.5 : 0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.xl)
                        .stroke(ResonanceTheme.Light.gold.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Calendar Heat Map

    private var calendarHeatMapSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Consistency")
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(textColor)

            CalendarHeatMap(
                entries: entries,
                textColor: textColor,
                mutedColor: mutedColor,
                accentColor: ResonanceTheme.Light.gold
            )
            .padding(ResonanceTheme.Spacing.md)
            .background(surfaceColor)
            .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))
        }
    }

    // MARK: - Recent Entries

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Recent Entries")
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(textColor)

            ForEach(entries.prefix(5)) { entry in
                JournalEntryRow(
                    entry: entry,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    surfaceColor: surfaceColor,
                    isDeepRest: isDeepRest
                )
                .onTapGesture {
                    selectedEntry = entry
                }
            }
        }
    }

    // MARK: - Helpers

    private var todayEntry: JournalEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }

    private func saveNewEntry() {
        let entry = JournalEntry(
            reflectionText: newReflectionText,
            gratitudeEntries: newGratitudeItems.filter { !$0.isEmpty },
            moodValue: moodValue,
            energyValue: energyValue,
            phase: currentPhase,
            isDeepRestEntry: isDeepRest
        )
        withAnimation(ResonanceTheme.Animation.gentle) {
            entries.insert(entry, at: 0)
        }
        newReflectionText = ""
        newGratitudeItems = ["", "", ""]
        isComposing = false
    }
}

// MARK: - Organic Indicator

struct OrganicIndicator: View {
    let label: String
    let value: Double
    let color: Color
    let icon: String

    @State private var appear = false

    var body: some View {
        VStack(spacing: ResonanceTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 64, height: 64)
                    .scaleEffect(appear ? 1.0 : 0.7)

                Circle()
                    .trim(from: 0, to: appear ? value : 0)
                    .stroke(color.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 58, height: 58)
                    .rotationEffect(.degrees(-90))

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(color)
            }
            .onAppear {
                withAnimation(ResonanceTheme.Animation.calm) {
                    appear = true
                }
            }

            Text(label)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(color.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Gratitude Row

struct GratitudeRow: View {
    let text: String?
    let index: Int
    let textColor: Color
    let goldColor: Color

    @State private var appear = false

    var body: some View {
        HStack(spacing: ResonanceTheme.Spacing.md) {
            Image(systemName: "heart.fill")
                .font(.system(size: 10))
                .foregroundColor(goldColor.opacity(appear ? 0.8 : 0.2))

            if let text = text {
                Text(text)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(textColor.opacity(0.85))
            } else {
                Text("Tap to add gratitude...")
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(textColor.opacity(0.3))
                    .italic()
            }

            Spacer()
        }
        .padding(.vertical, ResonanceTheme.Spacing.xs)
        .onAppear {
            withAnimation(ResonanceTheme.Animation.gentle.delay(Double(index) * 0.15)) {
                appear = true
            }
        }
    }
}

// MARK: - Wellness Metric Bubble

struct WellnessMetricBubble: View {
    let label: String
    let value: String
    let trend: BiomarkerTrend
    let color: Color

    var body: some View {
        VStack(spacing: ResonanceTheme.Spacing.xs) {
            Text(value)
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(color)

            HStack(spacing: 2) {
                Image(systemName: trendIcon)
                    .font(.system(size: 8))
                Text(label)
                    .font(ResonanceTheme.Typography.caption)
            }
            .foregroundColor(color.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private var trendIcon: String {
        switch trend {
        case .rising:  return "arrow.up.right"
        case .falling: return "arrow.down.right"
        case .stable:  return "arrow.right"
        }
    }
}

// MARK: - Coach Suggestion Card

struct CoachSuggestionCard: View {
    let suggestion: CoachSuggestion
    let textColor: Color
    let mutedColor: Color
    let surfaceColor: Color
    let isDeepRest: Bool

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            Button {
                withAnimation(ResonanceTheme.Animation.gentle) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: suggestion.category.icon)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(ResonanceTheme.Light.gold)
                        .frame(width: 24)

                    Text(suggestion.category.rawValue)
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .foregroundColor(textColor)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(mutedColor)
                }
            }

            if isExpanded {
                Text(suggestion.text)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(mutedColor)
                    .lineSpacing(4)
                    .padding(.leading, 36)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, ResonanceTheme.Spacing.xs)
    }
}

// MARK: - Calendar Heat Map

struct CalendarHeatMap: View {
    let entries: [JournalEntry]
    let textColor: Color
    let mutedColor: Color
    let accentColor: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            // Day headers
            HStack(spacing: 4) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(ResonanceTheme.Typography.caption)
                        .foregroundColor(mutedColor)
                        .frame(maxWidth: .infinity)
                }
            }

            // Heat map grid — last 28 days
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<28, id: \.self) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -(27 - dayOffset), to: Date())!
                    let hasEntry = entries.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }

                    RoundedRectangle(cornerRadius: 3)
                        .fill(hasEntry ? accentColor.opacity(intensityForDate(date)) : textColor.opacity(0.05))
                        .frame(height: 24)
                }
            }

            // Legend
            HStack(spacing: ResonanceTheme.Spacing.sm) {
                Text("Less")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor)
                ForEach([0.1, 0.3, 0.6, 1.0], id: \.self) { opacity in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(accentColor.opacity(opacity))
                        .frame(width: 12, height: 12)
                }
                Text("More")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor)
            }
            .padding(.top, ResonanceTheme.Spacing.xs)
        }
    }

    private func intensityForDate(_ date: Date) -> Double {
        let matching = entries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        if matching.isEmpty { return 0 }
        let totalContent = matching.reduce(0) { $0 + $1.reflectionText.count + $1.gratitudeEntries.count * 20 }
        return min(1.0, Double(totalContent) / 300.0 + 0.2)
    }
}

// MARK: - Journal Entry Row

struct JournalEntryRow: View {
    let entry: JournalEntry
    let textColor: Color
    let mutedColor: Color
    let surfaceColor: Color
    let isDeepRest: Bool

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            HStack {
                Image(systemName: entry.phase.icon)
                    .font(.system(size: 12))
                    .foregroundColor(entry.phase.color)

                Text(dateFormatter.string(from: entry.date))
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor)

                Spacer()

                if !entry.gratitudeEntries.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                        Text("\(entry.gratitudeEntries.count)")
                            .font(ResonanceTheme.Typography.caption)
                    }
                    .foregroundColor(ResonanceTheme.Light.gold.opacity(0.6))
                }
            }

            if !entry.reflectionText.isEmpty {
                Text(entry.reflectionText)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(textColor.opacity(0.8))
                    .lineLimit(2)
                    .lineSpacing(3)
            }
        }
        .padding(ResonanceTheme.Spacing.md)
        .background(surfaceColor)
        .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Journal Compose Sheet

struct JournalComposeSheet: View {
    @Binding var reflectionText: String
    @Binding var gratitudeItems: [String]
    @Binding var moodValue: Double
    @Binding var energyValue: Double
    let phase: DailyPhaseKind
    let isDeepRest: Bool
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }
    private var baseColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base
    }

    var body: some View {
        NavigationStack {
            ZStack {
                baseColor.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xl) {
                        // Mood slider
                        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                            Text("How are you feeling?")
                                .font(ResonanceTheme.Typography.headlineMed)
                                .foregroundColor(textColor)
                            Slider(value: $moodValue, in: 0...1)
                                .tint(ResonanceTheme.Light.gold)
                            HStack {
                                Text("Quiet")
                                Spacer()
                                Text("Radiant")
                            }
                            .font(ResonanceTheme.Typography.caption)
                            .foregroundColor(textColor.opacity(0.5))
                        }

                        // Energy slider
                        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                            Text("Energy level")
                                .font(ResonanceTheme.Typography.headlineMed)
                                .foregroundColor(textColor)
                            Slider(value: $energyValue, in: 0...1)
                                .tint(phase.color)
                            HStack {
                                Text("Resting")
                                Spacer()
                                Text("Vibrant")
                            }
                            .font(ResonanceTheme.Typography.caption)
                            .foregroundColor(textColor.opacity(0.5))
                        }

                        // Reflection
                        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                            Text("Reflection")
                                .font(ResonanceTheme.Typography.headlineMed)
                                .foregroundColor(textColor)
                            TextEditor(text: $reflectionText)
                                .font(.custom(ResonanceTheme.Typography.serifFamily, size: 18))
                                .foregroundColor(textColor)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 120)
                                .padding(ResonanceTheme.Spacing.sm)
                                .background(textColor.opacity(0.03))
                                .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md))
                        }

                        // Gratitude
                        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                            Text("Gratitude")
                                .font(ResonanceTheme.Typography.headlineMed)
                                .foregroundColor(textColor)
                            ForEach(0..<gratitudeItems.count, id: \.self) { i in
                                HStack {
                                    Image(systemName: "heart")
                                        .font(.system(size: 12))
                                        .foregroundColor(ResonanceTheme.Light.gold)
                                    TextField("Something you're grateful for...", text: $gratitudeItems[i])
                                        .font(ResonanceTheme.Typography.bodyMedium)
                                        .foregroundColor(textColor)
                                }
                            }
                        }
                    }
                    .padding(ResonanceTheme.Spacing.lg)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(textColor.opacity(0.6))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .foregroundColor(ResonanceTheme.Light.gold)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Organic Blob (shared)

struct OrganicBlobView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let radius = min(size.width, size.height) / 3
                var path = Path()
                let points = 64
                for i in 0..<points {
                    let angle = (Double(i) / Double(points)) * .pi * 2
                    let noise = sin(angle * 3 + phase) * 0.15 + cos(angle * 2 - phase * 0.7) * 0.1
                    let r = radius * (1 + noise)
                    let x = center.x + cos(angle) * r
                    let y = center.y + sin(angle) * r
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
                path.closeSubpath()
                context.fill(path, with: .color(ResonanceTheme.Light.gold.opacity(0.08)))
                context.stroke(path, with: .color(ResonanceTheme.Light.gold.opacity(0.15)), lineWidth: 1)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

// MARK: - Sample Data

extension JournalEntry {
    static let samples: [JournalEntry] = [
        JournalEntry(
            date: Date(),
            reflectionText: "The morning light came in softer today. I noticed a quality of stillness before the first task arrived — a spaciousness I want to honor more often.",
            gratitudeEntries: ["The quiet before dawn", "A good conversation with Elena", "The garden coming alive"],
            moodValue: 0.72,
            energyValue: 0.65,
            phase: .ascend
        ),
        JournalEntry(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            reflectionText: "Descended gracefully today. Let go of the unfinished without guilt. Tomorrow will have its own rhythm.",
            gratitudeEntries: ["Deep focus during zenith", "Warm tea in the afternoon"],
            moodValue: 0.6,
            energyValue: 0.45,
            phase: .descent
        ),
        JournalEntry(
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            reflectionText: "Rest phase brought unexpected clarity. Sometimes the best insights arrive when we stop seeking them.",
            gratitudeEntries: ["Sleep that actually restored", "A letter from an old friend", "The sound of rain"],
            moodValue: 0.8,
            energyValue: 0.55,
            phase: .rest
        ),
    ]
}

extension CoachSuggestion {
    static func samplesForPhase(_ phase: DailyPhaseKind) -> [CoachSuggestion] {
        switch phase {
        case .ascend:
            return [
                CoachSuggestion(text: "Your HRV has been rising over the past three days. This morning's energy may be especially available for deep, creative work.", category: .reflection),
                CoachSuggestion(text: "A 5-minute box breathing session could set a calm foundation for the day ahead.", category: .breathwork),
                CoachSuggestion(text: "Consider a brief walk — even 10 minutes of movement in the morning can amplify focus later.", category: .movement),
            ]
        case .zenith:
            return [
                CoachSuggestion(text: "You're in your peak phase. Protect this depth — the world can wait a little longer.", category: .reflection),
                CoachSuggestion(text: "If tension is building, try three slow exhales, longer than the inhales.", category: .breathwork),
                CoachSuggestion(text: "Your sleep quality was above average last night. Your body is well-resourced today.", category: .rest),
            ]
        case .descent:
            return [
                CoachSuggestion(text: "The day is winding down. What would feel complete? What can you gently set aside?", category: .reflection),
                CoachSuggestion(text: "Name three things from today that you're grateful for — even small ones.", category: .gratitude),
                CoachSuggestion(text: "Your stress markers have been low today. A short call with someone in your inner circle might feel nourishing.", category: .connection),
            ]
        case .rest:
            return [
                CoachSuggestion(text: "The rest phase is for restoration, not productivity. Let the mind wander without direction.", category: .rest),
                CoachSuggestion(text: "A slow, gentle breathing pattern — in for 4, out for 8 — can ease the transition to sleep.", category: .breathwork),
                CoachSuggestion(text: "If thoughts from the day arise, simply note them here. They'll be waiting for morning.", category: .reflection),
            ]
        }
    }
}
