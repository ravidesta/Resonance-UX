// WellnessHolarchyView.swift
// Resonance UX — Wellness Holarchy
//
// A healthcare/wellness platform organized as a holarchy — nested
// wholes where providers and patients participate in a living system
// of care. Biomarker tracking, AI psychological translation,
// protocol deployment, and RSD crisis regulation.

import SwiftUI

// MARK: - Biomarker

struct Biomarker: Identifiable {
    let id = UUID()
    var name: String
    var value: Double
    var unit: String
    var normalRange: ClosedRange<Double>
    var trend: Trend
    var lastUpdated: Date

    enum Trend: String {
        case rising, falling, stable
        var icon: String {
            switch self {
            case .rising:  return "arrow.up.right"
            case .falling: return "arrow.down.right"
            case .stable:  return "arrow.right"
            }
        }
        var color: Color {
            switch self {
            case .rising:  return Color(hex: 0xC5A059)
            case .falling: return Color(hex: 0x5C7065)
            case .stable:  return Color(hex: 0x0A1C14)
            }
        }
    }

    var isAnomaly: Bool {
        !normalRange.contains(value)
    }

    var statusColor: Color {
        isAnomaly ? Color(hex: 0xC5A059) : Color(hex: 0x0A1C14).opacity(0.4)
    }
}

// MARK: - Care Protocol

struct CareProtocol: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var category: Category
    var isActive: Bool = false
    var adherencePercent: Double = 0
    var durationDays: Int = 30

    enum Category: String, CaseIterable {
        case nervous  = "Nervous System"
        case hormonal = "Hormonal"
        case sleep    = "Sleep"
        case movement = "Movement"
        case crisis   = "Crisis"

        var icon: String {
            switch self {
            case .nervous:  return "brain.head.profile"
            case .hormonal: return "waveform.path.ecg"
            case .sleep:    return "moon.zzz"
            case .movement: return "figure.walk"
            case .crisis:   return "bolt.heart"
            }
        }

        var color: Color {
            switch self {
            case .nervous:  return Color(hex: 0x0A1C14)
            case .hormonal: return Color(hex: 0xC5A059)
            case .sleep:    return Color(hex: 0x122E21)
            case .movement: return Color(hex: 0x5C7065)
            case .crisis:   return .red.opacity(0.8)
            }
        }
    }
}

// MARK: - Patient

struct WellnessPatient: Identifiable {
    let id = UUID()
    var name: String
    var initials: String
    var frequency: Double  // overall wellness frequency 0-10
    var biomarkers: [Biomarker]
    var activeProtocols: [CareProtocol]
    var lastEncounter: Date
    var rsdRiskLevel: RSDRisk
    var notes: String

    enum RSDRisk: String {
        case low, moderate, elevated
        var color: Color {
            switch self {
            case .low:      return Color(hex: 0x0A1C14).opacity(0.4)
            case .moderate: return Color(hex: 0xC5A059)
            case .elevated: return .red.opacity(0.7)
            }
        }
    }
}

// MARK: - Triage Item

struct TriageItem: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var priority: Priority
    var patient: String

    enum Priority: String {
        case urgent, attention, routine
        var color: Color {
            switch self {
            case .urgent:    return .red.opacity(0.8)
            case .attention: return Color(hex: 0xC5A059)
            case .routine:   return Color(hex: 0x5C7065)
            }
        }
        var icon: String {
            switch self {
            case .urgent:    return "exclamationmark.triangle"
            case .attention: return "bell"
            case .routine:   return "circle"
            }
        }
    }
}

// MARK: - Wellness Holarchy View

struct WellnessHolarchyView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: ResonanceAppState

    @State private var viewMode: ViewMode = .provider
    @State private var selectedPatient: WellnessPatient?
    @State private var triageItems = TriageItem.samples
    @State private var patients = WellnessPatient.samples
    @State private var showRSDProtocol = false

    enum ViewMode: String, CaseIterable {
        case provider = "Provider"
        case patient  = "Patient"
    }

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
                        viewModePicker

                        if viewMode == .provider {
                            providerView
                        } else {
                            patientMobileView
                        }
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                    .padding(.bottom, ResonanceTheme.Spacing.xxxl)
                }
            }
            .navigationTitle(viewMode == .provider ? "Morning Triage" : "My Wellness")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewMode == .patient {
                        Button {
                            showRSDProtocol = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.heart")
                                Text("RSD")
                                    .font(ResonanceTheme.Typography.caption)
                            }
                            .foregroundColor(.red.opacity(0.8))
                            .padding(.horizontal, ResonanceTheme.Spacing.sm)
                            .padding(.vertical, ResonanceTheme.Spacing.xs)
                            .background(
                                Capsule().fill(.red.opacity(0.08))
                            )
                        }
                    }
                }
            }
            .sheet(item: $selectedPatient) { patient in
                PatientEncounterSheet(patient: patient, isDeepRest: isDeepRest)
            }
            .sheet(isPresented: $showRSDProtocol) {
                RSDLightningView()
            }
        }
    }

    // MARK: - View Mode Picker

    private var viewModePicker: some View {
        Picker("View", selection: $viewMode) {
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Provider View

    private var providerView: some View {
        VStack(spacing: ResonanceTheme.Spacing.xl) {
            morningTriageSection
            dailyRosterSection
            asyncCareSection
        }
    }

    // MARK: Morning Triage

    private var morningTriageSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Morning Triage")
                        .font(ResonanceTheme.Typography.headlineLarge)
                        .foregroundColor(textColor)

                    Text("\(triageItems.count) items require attention")
                        .font(ResonanceTheme.Typography.bodySmall)
                        .foregroundColor(mutedColor)
                }
                Spacer()
                triageSummaryBadges
            }

            ForEach(triageItems) { item in
                TriageCard(item: item, isDeepRest: isDeepRest)
            }
        }
    }

    private var triageSummaryBadges: some View {
        HStack(spacing: ResonanceTheme.Spacing.xs) {
            let urgent = triageItems.filter { $0.priority == .urgent }.count
            let attention = triageItems.filter { $0.priority == .attention }.count

            if urgent > 0 {
                Badge(count: urgent, color: .red.opacity(0.8))
            }
            if attention > 0 {
                Badge(count: attention, color: Color(hex: 0xC5A059))
            }
        }
    }

    // MARK: Daily Roster

    private var dailyRosterSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Daily Roster")
                .font(ResonanceTheme.Typography.headlineLarge)
                .foregroundColor(textColor)

            ForEach(patients) { patient in
                PatientRosterCard(patient: patient, isDeepRest: isDeepRest) {
                    selectedPatient = patient
                }
            }
        }
    }

    // MARK: Async Care

    private var asyncCareSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                Text("Async Care")
                    .font(ResonanceTheme.Typography.headlineLarge)
                    .foregroundColor(textColor)

                Spacer()

                Image(systemName: "lock.shield")
                    .font(.caption)
                    .foregroundColor(mutedColor)
                Text("End-to-end encrypted")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor)
            }

            GlassMorphismCard(isDeepRest: isDeepRest) {
                VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
                    HStack {
                        Image(systemName: "envelope.badge")
                            .foregroundColor(ResonanceTheme.Light.gold)
                        Text("3 patient messages awaiting response")
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(textColor)
                    }

                    ForEach(["Sarah M. — Question about cortisol protocol",
                             "James O. — Breathing exercise feedback",
                             "Eli N. — Sleep data anomaly noted"], id: \.self) { msg in
                        HStack(spacing: ResonanceTheme.Spacing.sm) {
                            Circle()
                                .fill(ResonanceTheme.Light.gold)
                                .frame(width: 6, height: 6)
                            Text(msg)
                                .font(ResonanceTheme.Typography.bodySmall)
                                .foregroundColor(mutedColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Patient Mobile View

    private var patientMobileView: some View {
        VStack(spacing: ResonanceTheme.Spacing.xl) {
            // Frequency display
            frequencyDisplay

            // Biomarkers
            biomarkerSection

            // Active protocols
            protocolSection

            // Next appointment
            nextAppointmentCard
        }
    }

    private var frequencyDisplay: some View {
        GlassMorphismCard(isDeepRest: isDeepRest) {
            VStack(spacing: ResonanceTheme.Spacing.md) {
                Text("YOUR FREQUENCY")
                    .font(ResonanceTheme.Typography.overline)
                    .foregroundColor(mutedColor)
                    .tracking(1.5)

                Text(String(format: "%.1f", appState.currentFrequency))
                    .font(ResonanceTheme.Typography.serif(72, weight: .light))
                    .foregroundColor(ResonanceTheme.Light.gold)

                // Frequency visualization
                HStack(spacing: 2) {
                    ForEach(0..<20, id: \.self) { i in
                        let height = frequencyBarHeight(index: i, frequency: appState.currentFrequency)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(ResonanceTheme.Light.gold.opacity(Double(i) / 20.0 < appState.currentFrequency / 10.0 ? 0.8 : 0.15))
                            .frame(width: 4, height: height)
                    }
                }
                .frame(height: 40)

                Text("Trending upward over the past 7 days")
                    .font(ResonanceTheme.Typography.bodySmall)
                    .foregroundColor(mutedColor)
            }
        }
    }

    private func frequencyBarHeight(index: Int, frequency: Double) -> CGFloat {
        let normalized = sin(Double(index) * 0.5 + frequency) * 0.5 + 0.5
        return CGFloat(8 + normalized * 32)
    }

    private var biomarkerSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Biomarkers")
                .font(ResonanceTheme.Typography.headlineLarge)
                .foregroundColor(textColor)

            let sampleBiomarkers = Biomarker.samples
            ForEach(sampleBiomarkers) { marker in
                BiomarkerCard(marker: marker, isDeepRest: isDeepRest)
            }
        }
    }

    private var protocolSection: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            Text("Active Protocols")
                .font(ResonanceTheme.Typography.headlineLarge)
                .foregroundColor(textColor)

            ForEach(CareProtocol.samples.filter(\.isActive)) { proto in
                ProtocolCard(protocol: proto, isDeepRest: isDeepRest)
            }
        }
    }

    private var nextAppointmentCard: some View {
        GlassMorphismCard(isDeepRest: isDeepRest) {
            HStack {
                VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xs) {
                    Text("NEXT ENCOUNTER")
                        .font(ResonanceTheme.Typography.overline)
                        .foregroundColor(mutedColor)
                        .tracking(1.2)

                    Text("Dr. Amara Osei")
                        .font(ResonanceTheme.Typography.headlineMed)
                        .foregroundColor(textColor)

                    Text("Thursday at 2:00 PM")
                        .font(ResonanceTheme.Typography.bodySmall)
                        .foregroundColor(mutedColor)
                }
                Spacer()
                Image(systemName: "video")
                    .font(.title2)
                    .foregroundColor(ResonanceTheme.Light.gold)
            }
        }
    }
}

// MARK: - Triage Card

struct TriageCard: View {
    let item: TriageItem
    let isDeepRest: Bool

    var body: some View {
        HStack(spacing: ResonanceTheme.Spacing.md) {
            Image(systemName: item.priority.icon)
                .font(.body)
                .foregroundColor(item.priority.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                HStack(spacing: ResonanceTheme.Spacing.sm) {
                    Text(item.patient)
                        .font(ResonanceTheme.Typography.caption)
                        .fontWeight(.medium)
                    Text(item.subtitle)
                        .font(ResonanceTheme.Typography.caption)
                }
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }

            Spacer()

            Circle()
                .fill(item.priority.color)
                .frame(width: 8, height: 8)
        }
        .padding(ResonanceTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .stroke(item.priority.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Badge

struct Badge: View {
    let count: Int
    let color: Color

    var body: some View {
        Text("\(count)")
            .font(ResonanceTheme.Typography.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 22, height: 22)
            .background(Circle().fill(color))
    }
}

// MARK: - Patient Roster Card

struct PatientRosterCard: View {
    let patient: WellnessPatient
    let isDeepRest: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ResonanceTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x122E21))
                        .frame(width: 44, height: 44)
                    Text(patient.initials)
                        .font(ResonanceTheme.Typography.sans(14, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(patient.name)
                        .font(ResonanceTheme.Typography.bodyLarge)
                        .fontWeight(.medium)
                        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                    HStack(spacing: ResonanceTheme.Spacing.sm) {
                        Text("Freq: \(String(format: "%.1f", patient.frequency))")
                            .font(ResonanceTheme.Typography.caption)
                        if patient.biomarkers.contains(where: \.isAnomaly) {
                            Label("Anomaly", systemImage: "exclamationmark.circle")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(Color(hex: 0xC5A059))
                        }
                    }
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
                }

                Spacer()

                Circle()
                    .fill(patient.rsdRiskLevel.color)
                    .frame(width: 10, height: 10)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }
            .padding(ResonanceTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                    .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                            .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Biomarker Card

struct BiomarkerCard: View {
    let marker: Biomarker
    let isDeepRest: Bool

    var body: some View {
        HStack(spacing: ResonanceTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(marker.name)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                Text("Normal: \(String(format: "%.1f", marker.normalRange.lowerBound))–\(String(format: "%.1f", marker.normalRange.upperBound)) \(marker.unit)")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }

            Spacer()

            HStack(spacing: 4) {
                Text(String(format: "%.1f", marker.value))
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(marker.isAnomaly ? Color(hex: 0xC5A059) : (isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900))

                Text(marker.unit)
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }

            Image(systemName: marker.trend.icon)
                .font(.caption)
                .foregroundColor(marker.trend.color)
        }
        .padding(ResonanceTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .stroke(marker.isAnomaly ? marker.statusColor.opacity(0.3) : (isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle))
                )
        )
    }
}

// MARK: - Protocol Card

struct ProtocolCard: View {
    let `protocol`: CareProtocol
    let isDeepRest: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            HStack {
                Image(systemName: `protocol`.category.icon)
                    .foregroundColor(`protocol`.category.color)
                Text(`protocol`.name)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .fontWeight(.medium)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
                Spacer()
                Text("\(Int(`protocol`.adherencePercent))%")
                    .font(ResonanceTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(ResonanceTheme.Light.gold)
            }

            Text(`protocol`.description)
                .font(ResonanceTheme.Typography.bodySmall)
                .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(`protocol`.category.color.opacity(0.1))
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(`protocol`.category.color)
                        .frame(width: geo.size.width * `protocol`.adherencePercent / 100, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(ResonanceTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                )
        )
    }
}

// MARK: - Patient Encounter Sheet

struct PatientEncounterSheet: View {
    let patient: WellnessPatient
    let isDeepRest: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var aiTranslation: String = ""
    @State private var isTranslating = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ResonanceTheme.Spacing.xl) {
                    // Patient header
                    VStack(spacing: ResonanceTheme.Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: 0x122E21))
                                .frame(width: 72, height: 72)
                            Text(patient.initials)
                                .font(ResonanceTheme.Typography.serif(28, weight: .light))
                                .foregroundColor(.white)
                        }
                        Text(patient.name)
                            .font(ResonanceTheme.Typography.headlineLarge)
                        Text("Frequency: \(String(format: "%.1f", patient.frequency))")
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(.secondary)
                    }

                    // Biomarkers
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("Biomarkers")
                            .font(ResonanceTheme.Typography.headlineMed)

                        ForEach(patient.biomarkers) { marker in
                            BiomarkerCard(marker: marker, isDeepRest: isDeepRest)
                        }
                    }

                    // AI Psychological Translation
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        HStack {
                            Text("AI Translation")
                                .font(ResonanceTheme.Typography.headlineMed)
                            Spacer()
                            Button {
                                generateTranslation()
                            } label: {
                                Label("Generate", systemImage: "sparkles")
                                    .font(ResonanceTheme.Typography.caption)
                                    .foregroundColor(ResonanceTheme.Light.gold)
                            }
                        }

                        if isTranslating {
                            HStack {
                                ProgressView().tint(ResonanceTheme.Light.gold)
                                Text("Analyzing biomarker patterns...")
                                    .font(ResonanceTheme.Typography.bodySmall)
                                    .foregroundColor(.secondary)
                            }
                            .padding(ResonanceTheme.Spacing.md)
                        } else if !aiTranslation.isEmpty {
                            Text(aiTranslation)
                                .font(ResonanceTheme.Typography.serif(16, weight: .regular))
                                .lineSpacing(6)
                                .padding(ResonanceTheme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                                        .fill(ResonanceTheme.Light.gold.opacity(0.05))
                                )
                        }
                    }

                    // Protocols
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("Active Protocols")
                            .font(ResonanceTheme.Typography.headlineMed)

                        ForEach(patient.activeProtocols) { proto in
                            ProtocolCard(protocol: proto, isDeepRest: isDeepRest)
                        }
                    }

                    // Notes
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("Clinical Notes")
                            .font(ResonanceTheme.Typography.headlineMed)
                        Text(patient.notes)
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(ResonanceTheme.Spacing.md)
            }
            .navigationTitle("Patient Encounter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ResonanceTheme.Light.gold)
                }
            }
        }
    }

    private func generateTranslation() {
        isTranslating = true
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let anomalies = patient.biomarkers.filter(\.isAnomaly)
            if anomalies.isEmpty {
                aiTranslation = "All biomarkers within normal range. The patient's nervous system appears well-regulated. Current protocols are supporting physiological stability. Consider maintaining current approach with gentle progression."
            } else {
                let names = anomalies.map(\.name).joined(separator: " and ")
                aiTranslation = "Elevated \(names) suggest the nervous system may be operating in a heightened sympathetic state. This pattern is often associated with chronic stress accumulation or insufficient recovery time between demands. The body is communicating a need for expanded parasympathetic activation — consider increasing breathwork frequency and evaluating environmental stressors. The RSD protocol may be beneficial if emotional dysregulation is present."
            }
            isTranslating = false
        }
    }
}

// MARK: - RSD Lightning Protocol

struct RSDLightningView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var breatheScale: CGFloat = 1.0
    @State private var breathLabel = "Breathe in..."

    private let steps = [
        ("Orient", "Look around. Name 5 things you can see.", "eye"),
        ("Ground", "Press your feet into the floor. Feel gravity holding you.", "arrow.down"),
        ("Breathe", "4 counts in. 7 counts hold. 8 counts out.", "wind"),
        ("Contain", "Place one hand on your chest. The storm is outside, not inside.", "hand.raised"),
        ("Return", "You are here. You are safe. This moment is manageable.", "checkmark.circle"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0x05100B).ignoresSafeArea()

                VStack(spacing: ResonanceTheme.Spacing.xl) {
                    // Progress
                    HStack(spacing: 4) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i <= currentStep ? ResonanceTheme.Light.gold : ResonanceTheme.Light.gold.opacity(0.2))
                                .frame(height: 3)
                        }
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.xl)

                    Spacer()

                    // Current step
                    let step = steps[currentStep]

                    Image(systemName: step.2)
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(ResonanceTheme.Light.gold)
                        .scaleEffect(currentStep == 2 ? breatheScale : 1.0)

                    Text(step.0)
                        .font(ResonanceTheme.Typography.displayLarge)
                        .foregroundColor(.white)

                    Text(step.1)
                        .font(ResonanceTheme.Typography.serif(20, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ResonanceTheme.Spacing.xl)

                    if currentStep == 2 {
                        Text(breathLabel)
                            .font(ResonanceTheme.Typography.bodyMedium)
                            .foregroundColor(ResonanceTheme.Light.gold.opacity(0.6))
                    }

                    Spacer()

                    // Navigation
                    HStack(spacing: ResonanceTheme.Spacing.xl) {
                        if currentStep > 0 {
                            Button {
                                withAnimation(ResonanceTheme.Animation.calm) {
                                    currentStep -= 1
                                }
                            } label: {
                                Text("Back")
                                    .font(ResonanceTheme.Typography.bodyMedium)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        Spacer()

                        Button {
                            if currentStep < steps.count - 1 {
                                withAnimation(ResonanceTheme.Animation.calm) {
                                    currentStep += 1
                                }
                            } else {
                                dismiss()
                            }
                        } label: {
                            Text(currentStep < steps.count - 1 ? "Next" : "I'm regulated")
                                .font(ResonanceTheme.Typography.sans(16, weight: .semibold))
                                .foregroundColor(Color(hex: 0x05100B))
                                .padding(.horizontal, ResonanceTheme.Spacing.lg)
                                .padding(.vertical, ResonanceTheme.Spacing.md)
                                .background(
                                    Capsule().fill(ResonanceTheme.Light.gold)
                                )
                        }
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.xl)
                    .padding(.bottom, ResonanceTheme.Spacing.xl)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                    breatheScale = 1.3
                }
            }
        }
    }
}

// MARK: - Sample Data

extension TriageItem {
    static let samples: [TriageItem] = [
        TriageItem(title: "Cortisol spike detected", subtitle: "3x above baseline at 2 AM", priority: .urgent, patient: "Sarah M."),
        TriageItem(title: "Missed breathwork — 3 consecutive days", subtitle: "Protocol adherence dropping", priority: .attention, patient: "James O."),
        TriageItem(title: "HRV improvement noted", subtitle: "+15% over 7 days", priority: .routine, patient: "Eli N."),
        TriageItem(title: "DHEA-S below range", subtitle: "Follow-up labs recommended", priority: .attention, patient: "River P."),
    ]
}

extension Biomarker {
    static let samples: [Biomarker] = [
        Biomarker(name: "Cortisol", value: 22.4, unit: "mcg/dL", normalRange: 6.0...18.4, trend: .rising,
                  lastUpdated: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!),
        Biomarker(name: "DHEA-S", value: 180, unit: "mcg/dL", normalRange: 200...400, trend: .falling,
                  lastUpdated: Calendar.current.date(byAdding: .day, value: -2, to: Date())!),
        Biomarker(name: "HRV (RMSSD)", value: 42.0, unit: "ms", normalRange: 30...100, trend: .rising,
                  lastUpdated: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!),
        Biomarker(name: "Melatonin (evening)", value: 58.0, unit: "pg/mL", normalRange: 40...120, trend: .stable,
                  lastUpdated: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
    ]
}

extension CareProtocol {
    static let samples: [CareProtocol] = [
        CareProtocol(name: "Vagal Tone Reset", description: "Daily breathwork + cold exposure to restore parasympathetic dominance", category: .nervous, isActive: true, adherencePercent: 82),
        CareProtocol(name: "Cortisol Curve Correction", description: "Timed light exposure, adaptogen support, and evening wind-down ritual", category: .hormonal, isActive: true, adherencePercent: 68),
        CareProtocol(name: "Sleep Architecture Rebuild", description: "Progressive sleep hygiene with biometric feedback", category: .sleep, isActive: true, adherencePercent: 91),
        CareProtocol(name: "RSD Lightning Protocol", description: "Emergency nervous system regulation for rejection sensitivity episodes", category: .crisis, isActive: false, adherencePercent: 0),
    ]
}

extension WellnessPatient {
    static let samples: [WellnessPatient] = [
        WellnessPatient(name: "Sarah Mitchell", initials: "SM", frequency: 6.8, biomarkers: Biomarker.samples, activeProtocols: Array(CareProtocol.samples.prefix(2)), lastEncounter: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, rsdRiskLevel: .moderate, notes: "Responding well to vagal tone protocol. Cortisol remains elevated — stress at work ongoing. Consider adding RSD lightning if emotional regulation worsens."),
        WellnessPatient(name: "James Oliver", initials: "JO", frequency: 7.4, biomarkers: [Biomarker.samples[2], Biomarker.samples[3]], activeProtocols: [CareProtocol.samples[2]], lastEncounter: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, rsdRiskLevel: .low, notes: "Excellent progress on sleep protocol. HRV trending upward consistently."),
        WellnessPatient(name: "Eli Nakamura", initials: "EN", frequency: 5.2, biomarkers: Biomarker.samples, activeProtocols: CareProtocol.samples.filter(\.isActive), lastEncounter: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, rsdRiskLevel: .elevated, notes: "Multiple biomarker anomalies. Nervous system in chronic sympathetic dominance. RSD episodes increasing in frequency. Comprehensive protocol approach needed."),
    ]
}
