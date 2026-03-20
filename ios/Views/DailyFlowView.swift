// DailyFlowView.swift
// Resonance UX — Daily Rhythms
//
// Energy-aware task management organized around the body's natural
// circadian phases: Ascend, Zenith, Descent, Rest.

import SwiftUI

// MARK: - Energy Level

enum EnergyLevel: String, CaseIterable, Identifiable, Codable {
    case highDeep       = "High / Deep"
    case balancedFlow   = "Balanced / Flow"
    case lowAdmin       = "Low / Admin"
    case restorative    = "Restorative"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .highDeep:     return "bolt.fill"
        case .balancedFlow: return "wind"
        case .lowAdmin:     return "tray.full"
        case .restorative:  return "leaf"
        }
    }

    var color: Color {
        switch self {
        case .highDeep:     return Color(hex: 0x0A1C14)
        case .balancedFlow: return Color(hex: 0xC5A059)
        case .lowAdmin:     return Color(hex: 0x5C7065)
        case .restorative:  return Color(hex: 0x122E21)
        }
    }

    var suggestedPhases: [DailyPhaseKind] {
        switch self {
        case .highDeep:     return [.zenith, .ascend]
        case .balancedFlow: return [.ascend, .descent]
        case .lowAdmin:     return [.descent]
        case .restorative:  return [.rest, .descent]
        }
    }
}

// MARK: - Flow Task

struct FlowTask: Identifiable {
    let id = UUID()
    var title: String
    var energyLevel: EnergyLevel
    var domain: String
    var isCompleted: Bool = false
    var collaborators: [String] = []
    var scheduledTime: Date?
    var estimatedMinutes: Int = 30
}

// MARK: - Flow Event

struct FlowEvent: Identifiable {
    let id = UUID()
    var title: String
    var startTime: Date
    var durationMinutes: Int
    var energyLevel: EnergyLevel
    var isFlexible: Bool = true
}

// MARK: - Daily Flow View

struct DailyFlowView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: ResonanceAppState

    @State private var activePhase: DailyPhaseKind = .ascend
    @State private var spaciousnessHours: Double = 4.0
    @State private var tasks: [FlowTask] = FlowTask.sampleTasks
    @State private var events: [FlowEvent] = FlowEvent.sampleEvents
    @State private var showAddTask = false
    @State private var selectedEnergyFilter: EnergyLevel? = nil
    @State private var breatheScale: CGFloat = 1.0
    @State private var phaseProgress: CGFloat = 0.45

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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ResonanceTheme.Spacing.xl) {
                    headerSection
                    phaseSelector
                    spaciousnessCard
                    timelineSection
                    taskSection
                }
                .padding(.horizontal, ResonanceTheme.Spacing.md)
                .padding(.bottom, ResonanceTheme.Spacing.xxxl)
            }
            .background(baseColor.ignoresSafeArea())
            .navigationTitle("Daily Rhythms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.title3)
                            .foregroundColor(ResonanceTheme.Light.gold)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskSheet(tasks: $tasks)
            }
        }
        .onAppear {
            computeActivePhase()
            withAnimation(ResonanceTheme.Animation.breathe) {
                breatheScale = 1.06
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            Text(greetingText)
                .font(ResonanceTheme.Typography.displayLarge)
                .foregroundColor(textColor)

            Text(activePhase.intention)
                .font(ResonanceTheme.Typography.bodyLarge)
                .foregroundColor(mutedColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, ResonanceTheme.Spacing.md)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Rest well"
        }
    }

    // MARK: - Phase Selector

    private var phaseSelector: some View {
        VStack(spacing: ResonanceTheme.Spacing.md) {
            HStack(spacing: ResonanceTheme.Spacing.sm) {
                ForEach(DailyPhaseKind.allCases) { phase in
                    PhaseButton(
                        phase: phase,
                        isActive: activePhase == phase,
                        progress: activePhase == phase ? phaseProgress : 0
                    ) {
                        withAnimation(ResonanceTheme.Animation.gentle) {
                            activePhase = phase
                        }
                    }
                }
            }

            // Phase time indicator
            HStack {
                Image(systemName: activePhase.icon)
                    .font(.caption)
                Text(activePhase.timeRange)
                    .font(ResonanceTheme.Typography.caption)
            }
            .foregroundColor(mutedColor)
        }
    }

    // MARK: - Spaciousness Card

    private var spaciousnessCard: some View {
        GlassMorphismCard(isDeepRest: isDeepRest) {
            VStack(spacing: ResonanceTheme.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xs) {
                        Text("Spaciousness")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text("\(String(format: "%.1f", spaciousnessHours)) hours of spaciousness today")
                            .font(ResonanceTheme.Typography.headlineMed)
                            .foregroundColor(textColor)
                    }

                    Spacer()

                    SpaciousnessGauge(value: spaciousnessHours, maxValue: 8.0)
                        .frame(width: 56, height: 56)
                }

                // Spaciousness breakdown
                HStack(spacing: ResonanceTheme.Spacing.lg) {
                    SpaceStat(label: "Unscheduled", value: "2.5h", icon: "circle.dashed")
                    SpaceStat(label: "Buffer time", value: "1.0h", icon: "arrow.left.and.right")
                    SpaceStat(label: "Transitions", value: "0.5h", icon: "arrow.triangle.branch")
                }
                .foregroundColor(mutedColor)
            }
        }
        .scaleEffect(breatheScale)
    }

    // MARK: - Timeline

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Timeline")
                .font(ResonanceTheme.Typography.headlineLarge)
                .foregroundColor(textColor)

            ForEach(eventsForPhase) { event in
                TimelineEventRow(event: event, isDeepRest: isDeepRest)
            }

            if eventsForPhase.isEmpty {
                VStack(spacing: ResonanceTheme.Spacing.sm) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(mutedColor.opacity(0.5))
                    Text("This phase is clear — enjoy the spaciousness")
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .foregroundColor(mutedColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, ResonanceTheme.Spacing.xl)
            }
        }
    }

    private var eventsForPhase: [FlowEvent] {
        events.filter { event in
            let hour = Calendar.current.component(.hour, from: event.startTime)
            switch activePhase {
            case .ascend:  return (5..<12).contains(hour)
            case .zenith:  return (12..<15).contains(hour)
            case .descent: return (15..<20).contains(hour)
            case .rest:    return hour >= 20 || hour < 5
            }
        }
    }

    // MARK: - Tasks

    private var taskSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                Text("Energy Tasks")
                    .font(ResonanceTheme.Typography.headlineLarge)
                    .foregroundColor(textColor)

                Spacer()

                energyFilterMenu
            }

            ForEach(filteredTasks.indices, id: \.self) { index in
                let task = filteredTasks[index]
                EnergyTaskCard(
                    task: task,
                    isDeepRest: isDeepRest,
                    onToggle: {
                        if let realIndex = tasks.firstIndex(where: { $0.id == task.id }) {
                            withAnimation(ResonanceTheme.Animation.gentle) {
                                tasks[realIndex].isCompleted.toggle()
                            }
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }

    private var filteredTasks: [FlowTask] {
        if let filter = selectedEnergyFilter {
            return tasks.filter { $0.energyLevel == filter }
        }
        // Show tasks appropriate for the current phase
        return tasks.sorted { a, b in
            let aMatch = a.energyLevel.suggestedPhases.contains(activePhase)
            let bMatch = b.energyLevel.suggestedPhases.contains(activePhase)
            if aMatch && !bMatch { return true }
            if !aMatch && bMatch { return false }
            return !a.isCompleted && b.isCompleted
        }
    }

    private var energyFilterMenu: some View {
        Menu {
            Button("All Energies") {
                selectedEnergyFilter = nil
            }
            Divider()
            ForEach(EnergyLevel.allCases) { level in
                Button {
                    selectedEnergyFilter = level
                } label: {
                    Label(level.rawValue, systemImage: level.icon)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: selectedEnergyFilter?.icon ?? "line.3.horizontal.decrease")
                    .font(.caption)
                Text(selectedEnergyFilter?.rawValue ?? "Filter")
                    .font(ResonanceTheme.Typography.caption)
            }
            .foregroundColor(mutedColor)
            .padding(.horizontal, ResonanceTheme.Spacing.sm)
            .padding(.vertical, ResonanceTheme.Spacing.xs)
            .background(
                Capsule()
                    .fill(surfaceColor)
                    .overlay(Capsule().stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle))
            )
        }
    }

    // MARK: - Helpers

    private func computeActivePhase() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  activePhase = .ascend
        case 12..<15: activePhase = .zenith
        case 15..<20: activePhase = .descent
        default:      activePhase = .rest
        }
    }
}

// MARK: - Phase Button

struct PhaseButton: View {
    let phase: DailyPhaseKind
    let isActive: Bool
    let progress: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .stroke(phase.color.opacity(0.2), lineWidth: 2)
                        .frame(width: 44, height: 44)

                    if isActive {
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(phase.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(.degrees(-90))
                    }

                    Image(systemName: phase.icon)
                        .font(.system(size: 18, weight: isActive ? .medium : .light))
                        .foregroundColor(isActive ? phase.color : phase.color.opacity(0.4))
                }

                Text(phase.label)
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(isActive ? phase.color : phase.color.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(ResonanceTheme.Animation.gentle, value: isActive)
    }
}

// MARK: - Spaciousness Stat

struct SpaceStat: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(ResonanceTheme.Typography.bodySmall)
                .fontWeight(.medium)
            Text(label)
                .font(ResonanceTheme.Typography.caption)
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Timeline Event Row

struct TimelineEventRow: View {
    let event: FlowEvent
    let isDeepRest: Bool

    @State private var isExpanded = false

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }

    var body: some View {
        HStack(alignment: .top, spacing: ResonanceTheme.Spacing.md) {
            // Time column
            VStack(alignment: .trailing, spacing: 2) {
                Text(event.startTime.formatted(date: .omitted, time: .shortened))
                    .font(ResonanceTheme.Typography.bodySmall)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)

                Text("\(event.durationMinutes)m")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }
            .frame(width: 56, alignment: .trailing)

            // Connector
            VStack(spacing: 0) {
                Circle()
                    .fill(event.energyLevel.color)
                    .frame(width: 10, height: 10)

                Rectangle()
                    .fill(event.energyLevel.color.opacity(0.2))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }

            // Content
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xs) {
                Text(event.title)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(textColor)

                HStack(spacing: ResonanceTheme.Spacing.sm) {
                    EnergyLevelIndicator(level: event.energyLevel, compact: true)

                    if event.isFlexible {
                        Label("Flexible", systemImage: "arrow.left.and.right")
                            .font(ResonanceTheme.Typography.caption)
                            .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
                    }
                }
            }
            .padding(.vertical, ResonanceTheme.Spacing.sm)
            .padding(.horizontal, ResonanceTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                    .fill((isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                            .stroke(event.energyLevel.color.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Energy Task Card

struct EnergyTaskCard: View {
    let task: FlowTask
    let isDeepRest: Bool
    let onToggle: () -> Void

    @State private var isPressed = false

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }

    var body: some View {
        HStack(spacing: ResonanceTheme.Spacing.md) {
            // Completion toggle
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .stroke(task.energyLevel.color.opacity(task.isCompleted ? 0.3 : 0.6), lineWidth: 1.5)
                        .frame(width: 26, height: 26)

                    if task.isCompleted {
                        Circle()
                            .fill(task.energyLevel.color.opacity(0.2))
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(task.energyLevel.color)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(textColor.opacity(task.isCompleted ? 0.4 : 1.0))
                    .strikethrough(task.isCompleted, color: textColor.opacity(0.3))

                HStack(spacing: ResonanceTheme.Spacing.sm) {
                    EnergyLevelIndicator(level: task.energyLevel, compact: true)

                    Text(task.domain)
                        .font(ResonanceTheme.Typography.caption)
                        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)

                    if !task.collaborators.isEmpty {
                        HStack(spacing: -6) {
                            ForEach(task.collaborators.prefix(3), id: \.self) { name in
                                Circle()
                                    .fill(ResonanceTheme.Light.gold.opacity(0.3))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Text(String(name.prefix(1)))
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(textColor)
                                    )
                            }
                        }
                    }
                }
            }

            Spacer()

            if let time = task.scheduledTime {
                Text(time.formatted(date: .omitted, time: .shortened))
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }
        }
        .padding(ResonanceTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                .fill((isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface))
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .strokeBorder(
                            isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle,
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(isDeepRest ? 0.2 : 0.04), radius: 8, y: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(ResonanceTheme.Animation.gentle) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Add Task Sheet

struct AddTaskSheet: View {
    @Binding var tasks: [FlowTask]
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var energy: EnergyLevel = .balancedFlow
    @State private var domain = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What needs your attention?", text: $title)
                        .font(ResonanceTheme.Typography.bodyLarge)
                }

                Section("Energy Level") {
                    Picker("Energy", selection: $energy) {
                        ForEach(EnergyLevel.allCases) { level in
                            Label(level.rawValue, systemImage: level.icon)
                                .tag(level)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Domain") {
                    TextField("e.g., Creative, Admin, Wellness", text: $domain)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = FlowTask(
                            title: title,
                            energyLevel: energy,
                            domain: domain.isEmpty ? "General" : domain
                        )
                        tasks.append(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(ResonanceTheme.Light.gold)
                }
            }
        }
    }
}

// MARK: - Sample Data

extension FlowTask {
    static let sampleTasks: [FlowTask] = [
        FlowTask(title: "Deep write — essay on digital calm", energyLevel: .highDeep, domain: "Creative", collaborators: ["Maya"]),
        FlowTask(title: "Review patient protocols", energyLevel: .highDeep, domain: "Wellness"),
        FlowTask(title: "Respond to Inner Circle messages", energyLevel: .balancedFlow, domain: "Connection"),
        FlowTask(title: "Journal — morning reflection", energyLevel: .balancedFlow, domain: "Personal"),
        FlowTask(title: "Update billing summaries", energyLevel: .lowAdmin, domain: "Admin"),
        FlowTask(title: "Organize reference library", energyLevel: .lowAdmin, domain: "Admin"),
        FlowTask(title: "Evening breathwork session", energyLevel: .restorative, domain: "Wellness"),
        FlowTask(title: "Gentle walk — no devices", energyLevel: .restorative, domain: "Wellness"),
    ]
}

extension FlowEvent {
    static var sampleEvents: [FlowEvent] {
        let cal = Calendar.current
        let today = Date()

        func time(_ hour: Int, _ minute: Int = 0) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }

        return [
            FlowEvent(title: "Morning breathwork", startTime: time(6, 30), durationMinutes: 20, energyLevel: .restorative),
            FlowEvent(title: "Deep writing block", startTime: time(9, 0), durationMinutes: 90, energyLevel: .highDeep, isFlexible: false),
            FlowEvent(title: "Patient session — Sarah", startTime: time(13, 0), durationMinutes: 50, energyLevel: .highDeep, isFlexible: false),
            FlowEvent(title: "Team sync", startTime: time(15, 0), durationMinutes: 30, energyLevel: .balancedFlow),
            FlowEvent(title: "Admin catch-up", startTime: time(16, 0), durationMinutes: 45, energyLevel: .lowAdmin),
            FlowEvent(title: "Evening wind-down", startTime: time(20, 0), durationMinutes: 30, energyLevel: .restorative),
        ]
    }
}
