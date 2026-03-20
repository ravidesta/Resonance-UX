// ProviderDashboardView.swift
// Resonance UX — macOS Provider Dashboard
//
// A full-width 3-column Patient Encounter Holarchy optimized
// for desktop: MRI/imaging viewer, biomarker center panel,
// AI psychological translation, admin engine, and immersive
// retreat management.

import SwiftUI

// MARK: - Provider Dashboard View

struct ProviderDashboardView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: MacAppState

    @State private var selectedTab: ProviderTab = .triage
    @State private var selectedPatient: DashboardPatient?
    @State private var triageItems = DashboardTriageItem.samples
    @State private var patients = DashboardPatient.samples
    @State private var showAdminEngine = false

    enum ProviderTab: String, CaseIterable, Identifiable {
        case triage    = "Morning Triage"
        case encounter = "Encounter"
        case admin     = "Admin Engine"
        case retreats  = "Immersives"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .triage:    return "sunrise"
            case .encounter: return "stethoscope"
            case .admin:     return "gearshape.2"
            case .retreats:  return "leaf.circle"
            }
        }
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

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            dashboardToolbar

            Divider()

            // Content area
            switch selectedTab {
            case .triage:
                triageView
            case .encounter:
                encounterView
            case .admin:
                adminEngineView
            case .retreats:
                retreatsView
            }
        }
        .background(isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base)
    }

    // MARK: - Dashboard Toolbar

    private var dashboardToolbar: some View {
        HStack(spacing: ResonanceTheme.Spacing.lg) {
            Text("Provider Dashboard")
                .font(ResonanceTheme.Typography.headlineLarge)
                .foregroundColor(textColor)

            Spacer()

            // Tab selector
            HStack(spacing: 2) {
                ForEach(ProviderTab.allCases) { tab in
                    Button {
                        withAnimation(ResonanceTheme.Animation.gentle) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.caption)
                            Text(tab.rawValue)
                                .font(ResonanceTheme.Typography.bodySmall)
                        }
                        .padding(.horizontal, ResonanceTheme.Spacing.md)
                        .padding(.vertical, ResonanceTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.sm)
                                .fill(selectedTab == tab
                                    ? ResonanceTheme.Light.gold.opacity(0.12)
                                    : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(selectedTab == tab ? ResonanceTheme.Light.gold : mutedColor)
                }
            }

            Spacer()

            // Quick stats
            HStack(spacing: ResonanceTheme.Spacing.md) {
                ToolbarStat(label: "Patients today", value: "\(patients.count)")
                ToolbarStat(label: "Urgent", value: "\(triageItems.filter { $0.priority == .urgent }.count)")
                ToolbarStat(label: "Messages", value: "3")
            }
        }
        .padding(.horizontal, ResonanceTheme.Spacing.xl)
        .padding(.vertical, ResonanceTheme.Spacing.md)
        .background(surfaceColor.opacity(0.6))
    }

    // MARK: - Triage View (Multi-Column Morning Triage)

    private var triageView: some View {
        HSplitView {
            // Left: Triage queue
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Triage Queue")
                        .font(ResonanceTheme.Typography.headlineMed)
                        .foregroundColor(textColor)
                    Spacer()
                    Text("\(triageItems.count) items")
                        .font(ResonanceTheme.Typography.caption)
                        .foregroundColor(mutedColor)
                }
                .padding(ResonanceTheme.Spacing.md)

                Divider()

                List(triageItems) { item in
                    DashboardTriageRow(item: item, isDeepRest: isDeepRest) {
                        if let patient = patients.first(where: { $0.name == item.patientName }) {
                            selectedPatient = patient
                            selectedTab = .encounter
                        }
                    }
                }
                .listStyle(.inset)
            }
            .frame(minWidth: 320, idealWidth: 380)

            // Right: Daily roster
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Daily Roster")
                        .font(ResonanceTheme.Typography.headlineMed)
                        .foregroundColor(textColor)
                    Spacer()
                }
                .padding(ResonanceTheme.Spacing.md)

                Divider()

                List(patients) { patient in
                    RosterRow(patient: patient, isDeepRest: isDeepRest) {
                        selectedPatient = patient
                        selectedTab = .encounter
                    }
                }
                .listStyle(.inset)
            }
        }
    }

    // MARK: - Encounter View (3-Column Patient Encounter Holarchy)

    private var encounterView: some View {
        Group {
            if let patient = selectedPatient {
                HSplitView {
                    // Left: Imaging / MRI Viewer
                    imagingPanel(patient)
                        .frame(minWidth: 250, idealWidth: 300)

                    // Center: Biomarkers
                    biomarkerPanel(patient)
                        .frame(minWidth: 350, idealWidth: 400)

                    // Right: AI Translation + Protocols
                    aiTranslationPanel(patient)
                        .frame(minWidth: 280, idealWidth: 320)
                }
            } else {
                VStack(spacing: ResonanceTheme.Spacing.md) {
                    Image(systemName: "person.crop.rectangle.stack")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(mutedColor.opacity(0.4))
                    Text("Select a patient from the roster")
                        .font(ResonanceTheme.Typography.bodyLarge)
                        .foregroundColor(mutedColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: Imaging Panel

    private func imagingPanel(_ patient: DashboardPatient) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(ResonanceTheme.Light.gold)
                Text("Imaging")
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(textColor)
            }
            .padding(ResonanceTheme.Spacing.md)

            Divider()

            ScrollView {
                VStack(spacing: ResonanceTheme.Spacing.md) {
                    // MRI viewer placeholder
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .fill(surfaceColor)
                        .frame(height: 250)
                        .overlay(
                            VStack(spacing: ResonanceTheme.Spacing.sm) {
                                Image(systemName: "brain")
                                    .font(.system(size: 40, weight: .ultraLight))
                                    .foregroundColor(mutedColor.opacity(0.3))
                                Text("MRI Viewer")
                                    .font(ResonanceTheme.Typography.bodySmall)
                                    .foregroundColor(mutedColor)
                                Text("No imaging data loaded")
                                    .font(ResonanceTheme.Typography.caption)
                                    .foregroundColor(mutedColor.opacity(0.6))
                            }
                        )

                    // Study list
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("STUDIES")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        ForEach(["Brain MRI — 2026-02-15", "fMRI Resting State — 2026-01-10", "DTI Tractography — 2025-12-08"], id: \.self) { study in
                            HStack {
                                Image(systemName: "doc.richtext")
                                    .font(.caption)
                                    .foregroundColor(mutedColor)
                                Text(study)
                                    .font(ResonanceTheme.Typography.bodySmall)
                                    .foregroundColor(textColor)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(ResonanceTheme.Spacing.md)
            }
        }
    }

    // MARK: Biomarker Panel

    private func biomarkerPanel(_ patient: DashboardPatient) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(ResonanceTheme.Light.gold)
                Text("Biomarker Center")
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(textColor)

                Spacer()

                Text("Freq: \(String(format: "%.1f", patient.frequency))")
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(ResonanceTheme.Light.gold)
            }
            .padding(ResonanceTheme.Spacing.md)

            Divider()

            ScrollView {
                VStack(spacing: ResonanceTheme.Spacing.md) {
                    // Biomarker grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: ResonanceTheme.Spacing.md) {
                        ForEach(patient.biomarkers) { marker in
                            DashboardBiomarkerCard(marker: marker, isDeepRest: isDeepRest)
                        }
                    }

                    Divider()

                    // Trend chart placeholder
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("CORTISOL TREND — 30 DAYS")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        // Simple chart representation
                        HStack(alignment: .bottom, spacing: 3) {
                            ForEach(0..<30, id: \.self) { day in
                                let height = trendHeight(day: day, baseline: patient.biomarkers.first?.value ?? 15)
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(height > 18.4 ? Color(hex: 0xC5A059) : Color(hex: 0x0A1C14).opacity(0.3))
                                    .frame(height: height)
                            }
                        }
                        .frame(height: 80)
                    }

                    // Protocols
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("ACTIVE PROTOCOLS")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        ForEach(patient.protocols) { proto in
                            DashboardProtocolRow(protocol: proto, isDeepRest: isDeepRest)
                        }
                    }
                }
                .padding(ResonanceTheme.Spacing.md)
            }
        }
    }

    // MARK: AI Translation Panel

    private func aiTranslationPanel(_ patient: DashboardPatient) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(ResonanceTheme.Light.gold)
                Text("AI Translation")
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(textColor)
            }
            .padding(ResonanceTheme.Spacing.md)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.lg) {
                    // Psychological translation
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("PSYCHOLOGICAL TRANSLATION")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        Text(generateTranslation(for: patient))
                            .font(ResonanceTheme.Typography.serif(15, weight: .regular))
                            .lineSpacing(6)
                            .foregroundColor(textColor)
                            .padding(ResonanceTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                                    .fill(ResonanceTheme.Light.gold.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                                            .stroke(ResonanceTheme.Light.gold.opacity(0.1))
                                    )
                            )
                    }

                    // Suggested actions
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("SUGGESTED ACTIONS")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        ForEach(suggestedActions(for: patient), id: \.self) { action in
                            HStack(alignment: .top, spacing: ResonanceTheme.Spacing.sm) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.caption)
                                    .foregroundColor(ResonanceTheme.Light.gold)
                                    .padding(.top, 2)

                                Text(action)
                                    .font(ResonanceTheme.Typography.bodySmall)
                                    .foregroundColor(textColor)
                            }
                        }
                    }

                    // Deploy protocol
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("DEPLOY PROTOCOL")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        ForEach(["Vagal Tone Reset", "Cortisol Curve Correction", "RSD Lightning"], id: \.self) { name in
                            Button {
                                // Deploy protocol
                            } label: {
                                HStack {
                                    Text(name)
                                        .font(ResonanceTheme.Typography.bodySmall)
                                    Spacer()
                                    Image(systemName: "paperplane")
                                        .font(.caption)
                                }
                                .foregroundColor(textColor)
                                .padding(ResonanceTheme.Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.sm)
                                        .fill(surfaceColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.sm)
                                                .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Clinical notes
                    VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
                        Text("CLINICAL NOTES")
                            .font(ResonanceTheme.Typography.overline)
                            .foregroundColor(mutedColor)
                            .tracking(1.2)

                        Text(patient.notes)
                            .font(ResonanceTheme.Typography.bodySmall)
                            .foregroundColor(mutedColor)
                    }
                }
                .padding(ResonanceTheme.Spacing.md)
            }
        }
    }

    // MARK: - Admin Engine

    private var adminEngineView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xl) {
                // Revenue & Utilization
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: ResonanceTheme.Spacing.md) {
                    AdminMetricCard(title: "Retainer Clients", value: "12", subtitle: "Active", icon: "person.3")
                    AdminMetricCard(title: "Utilization", value: "78%", subtitle: "+3% this month", icon: "chart.bar")
                    AdminMetricCard(title: "Revenue (MTD)", value: "$34.2k", subtitle: "On track", icon: "dollarsign.circle")
                    AdminMetricCard(title: "Open Slots", value: "8", subtitle: "This week", icon: "calendar.badge.plus")
                }

                Divider()

                // Retainer tracking
                VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
                    Text("Retainer Tracking")
                        .font(ResonanceTheme.Typography.headlineLarge)
                        .foregroundColor(textColor)

                    ForEach(patients) { patient in
                        HStack {
                            Text(patient.name)
                                .font(ResonanceTheme.Typography.bodyMedium)
                                .foregroundColor(textColor)
                                .frame(width: 160, alignment: .leading)

                            // Utilization bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(mutedColor.opacity(0.1))
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(ResonanceTheme.Light.gold)
                                        .frame(width: geo.size.width * patient.retainerUtilization)
                                }
                            }
                            .frame(height: 6)

                            Text("\(Int(patient.retainerUtilization * 100))%")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor)
                                .frame(width: 40, alignment: .trailing)

                            Text("\(patient.sessionsUsed)/\(patient.sessionsAllotted)")
                                .font(ResonanceTheme.Typography.caption)
                                .foregroundColor(mutedColor)
                                .frame(width: 50, alignment: .trailing)
                        }
                    }
                }
            }
            .padding(ResonanceTheme.Spacing.xl)
        }
    }

    // MARK: - Retreats / Immersives

    private var retreatsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.xl) {
                Text("Immersive Retreats")
                    .font(ResonanceTheme.Typography.displayMedium)
                    .foregroundColor(textColor)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: ResonanceTheme.Spacing.lg) {
                    ForEach(RetreatInfo.samples) { retreat in
                        RetreatCard(retreat: retreat, isDeepRest: isDeepRest)
                    }
                }
            }
            .padding(ResonanceTheme.Spacing.xl)
        }
    }

    // MARK: - Helpers

    private func trendHeight(day: Int, baseline: Double) -> CGFloat {
        let noise = sin(Double(day) * 0.7) * 5 + cos(Double(day) * 0.3) * 3
        let value = baseline + noise
        return CGFloat(max(4, min(80, value * 3)))
    }

    private func generateTranslation(for patient: DashboardPatient) -> String {
        let anomalyCount = patient.biomarkers.filter(\.isAnomaly).count
        if anomalyCount == 0 {
            return "Biomarkers are within expected ranges. The nervous system appears well-regulated. Consider maintaining the current protocol trajectory with gradual progression toward wellness goals."
        } else {
            return "Pattern analysis indicates heightened sympathetic nervous system activity. Elevated cortisol combined with declining DHEA-S suggests chronic stress accumulation. The body is signaling a need for expanded parasympathetic activation. Consider increasing breathwork frequency and evaluating environmental stressors. If emotional dysregulation is present, the RSD Lightning Protocol may provide immediate relief."
        }
    }

    private func suggestedActions(for patient: DashboardPatient) -> [String] {
        var actions: [String] = []
        if patient.biomarkers.contains(where: { $0.name == "Cortisol" && $0.isAnomaly }) {
            actions.append("Order follow-up cortisol panel (AM draw)")
            actions.append("Evaluate current stress management practices")
        }
        if patient.biomarkers.contains(where: { $0.name == "DHEA-S" && $0.isAnomaly }) {
            actions.append("Consider adaptogen support (ashwagandha protocol)")
        }
        actions.append("Schedule 15-minute check-in within 72 hours")
        actions.append("Review breathwork adherence data")
        return actions
    }
}

// MARK: - Supporting Views

struct ToolbarStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(ResonanceTheme.Typography.headlineMed)
                .foregroundColor(ResonanceTheme.Light.gold)
            Text(label)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DashboardTriageRow: View {
    let item: DashboardTriageItem
    let isDeepRest: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ResonanceTheme.Spacing.sm) {
                Image(systemName: item.priority.icon)
                    .foregroundColor(item.priority.color)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)
                    HStack {
                        Text(item.patientName)
                            .fontWeight(.medium)
                        Text(item.detail)
                    }
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(.secondary)
                }

                Spacer()

                Circle()
                    .fill(item.priority.color)
                    .frame(width: 6, height: 6)
            }
        }
        .buttonStyle(.plain)
    }
}

struct RosterRow: View {
    let patient: DashboardPatient
    let isDeepRest: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ResonanceTheme.Spacing.sm) {
                Circle()
                    .fill(Color(hex: 0x122E21))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(patient.initials)
                            .font(ResonanceTheme.Typography.sans(11, weight: .semibold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(patient.name)
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .fontWeight(.medium)
                    Text("Freq: \(String(format: "%.1f", patient.frequency))")
                        .font(ResonanceTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if patient.biomarkers.contains(where: \.isAnomaly) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(Color(hex: 0xC5A059))
                }

                Circle()
                    .fill(patient.rsdRisk.color)
                    .frame(width: 8, height: 8)
            }
        }
        .buttonStyle(.plain)
    }
}

struct DashboardBiomarkerCard: View {
    let marker: DashboardBiomarker
    let isDeepRest: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            HStack {
                Text(marker.name)
                    .font(ResonanceTheme.Typography.bodySmall)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: marker.trend.icon)
                    .font(.caption)
                    .foregroundColor(marker.trend.color)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", marker.value))
                    .font(ResonanceTheme.Typography.headlineLarge)
                    .foregroundColor(marker.isAnomaly ? Color(hex: 0xC5A059) : (isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900))
                Text(marker.unit)
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }

            Text("Range: \(String(format: "%.0f", marker.normalLow))–\(String(format: "%.0f", marker.normalHigh))")
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding(ResonanceTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .stroke(marker.isAnomaly ? Color(hex: 0xC5A059).opacity(0.3) : (isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle))
                )
        )
    }
}

struct DashboardProtocolRow: View {
    let `protocol`: DashboardProtocol
    let isDeepRest: Bool

    var body: some View {
        HStack {
            Image(systemName: `protocol`.icon)
                .foregroundColor(`protocol`.categoryColor)
                .frame(width: 20)

            Text(`protocol`.name)
                .font(ResonanceTheme.Typography.bodySmall)

            Spacer()

            Text("\(Int(`protocol`.adherence))%")
                .font(ResonanceTheme.Typography.caption)
                .fontWeight(.bold)
                .foregroundColor(ResonanceTheme.Light.gold)
        }
        .padding(.vertical, 4)
    }
}

struct AdminMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(ResonanceTheme.Light.gold)

            Text(value)
                .font(ResonanceTheme.Typography.displayMedium)

            Text(title)
                .font(ResonanceTheme.Typography.bodySmall)
                .fontWeight(.medium)

            Text(subtitle)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding(ResonanceTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .fill(.ultraThinMaterial)
        )
    }
}

struct RetreatCard: View {
    let retreat: RetreatInfo
    let isDeepRest: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                Image(systemName: "leaf.circle")
                    .font(.title2)
                    .foregroundColor(ResonanceTheme.Light.gold)
                Spacer()
                Text("\(retreat.participants)/\(retreat.maxParticipants)")
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }

            Text(retreat.name)
                .font(ResonanceTheme.Typography.headlineMed)

            Text(retreat.location)
                .font(ResonanceTheme.Typography.bodySmall)
                .foregroundColor(.secondary)

            Text(retreat.dateRange)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(.secondary)

            Text(retreat.description)
                .font(ResonanceTheme.Typography.bodySmall)
                .foregroundColor(.secondary)
                .lineLimit(3)

            // Fill bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ResonanceTheme.Light.gold.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ResonanceTheme.Light.gold)
                        .frame(width: geo.size.width * Double(retreat.participants) / Double(retreat.maxParticipants))
                }
            }
            .frame(height: 4)
        }
        .padding(ResonanceTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .fill(isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                        .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                )
        )
    }
}

// MARK: - Dashboard Models

struct DashboardTriageItem: Identifiable {
    let id = UUID()
    var title: String
    var detail: String
    var priority: Priority
    var patientName: String

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
            case .urgent:    return "exclamationmark.triangle.fill"
            case .attention: return "bell.fill"
            case .routine:   return "circle"
            }
        }
    }

    static let samples: [DashboardTriageItem] = [
        .init(title: "Cortisol spike — 3x baseline", detail: "2 AM reading", priority: .urgent, patientName: "Sarah Mitchell"),
        .init(title: "Missed breathwork 3 days", detail: "Protocol adherence dropping", priority: .attention, patientName: "James Oliver"),
        .init(title: "DHEA-S below range", detail: "Labs from yesterday", priority: .attention, patientName: "Eli Nakamura"),
        .init(title: "HRV improvement +15%", detail: "7-day trend", priority: .routine, patientName: "River Patel"),
    ]
}

struct DashboardBiomarker: Identifiable {
    let id = UUID()
    var name: String
    var value: Double
    var unit: String
    var normalLow: Double
    var normalHigh: Double
    var trend: Trend

    var isAnomaly: Bool { value < normalLow || value > normalHigh }

    enum Trend: String {
        case rising, falling, stable
        var icon: String {
            switch self { case .rising: return "arrow.up.right"; case .falling: return "arrow.down.right"; case .stable: return "arrow.right" }
        }
        var color: Color {
            switch self { case .rising: return Color(hex: 0xC5A059); case .falling: return Color(hex: 0x5C7065); case .stable: return Color(hex: 0x0A1C14) }
        }
    }
}

struct DashboardProtocol: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var categoryColor: Color
    var adherence: Double
}

struct DashboardPatient: Identifiable {
    let id = UUID()
    var name: String
    var initials: String
    var frequency: Double
    var biomarkers: [DashboardBiomarker]
    var protocols: [DashboardProtocol]
    var rsdRisk: RSDRisk
    var notes: String
    var retainerUtilization: Double
    var sessionsUsed: Int
    var sessionsAllotted: Int

    enum RSDRisk: String {
        case low, moderate, elevated
        var color: Color {
            switch self { case .low: return Color(hex: 0x0A1C14).opacity(0.4); case .moderate: return Color(hex: 0xC5A059); case .elevated: return .red.opacity(0.7) }
        }
    }

    static let samples: [DashboardPatient] = [
        DashboardPatient(
            name: "Sarah Mitchell", initials: "SM", frequency: 6.8,
            biomarkers: [
                .init(name: "Cortisol", value: 22.4, unit: "mcg/dL", normalLow: 6, normalHigh: 18.4, trend: .rising),
                .init(name: "DHEA-S", value: 180, unit: "mcg/dL", normalLow: 200, normalHigh: 400, trend: .falling),
                .init(name: "HRV", value: 42, unit: "ms", normalLow: 30, normalHigh: 100, trend: .rising),
                .init(name: "Melatonin", value: 58, unit: "pg/mL", normalLow: 40, normalHigh: 120, trend: .stable),
            ],
            protocols: [
                .init(name: "Vagal Tone Reset", icon: "brain.head.profile", categoryColor: Color(hex: 0x0A1C14), adherence: 82),
                .init(name: "Cortisol Correction", icon: "waveform.path.ecg", categoryColor: Color(hex: 0xC5A059), adherence: 68),
            ],
            rsdRisk: .moderate, notes: "Cortisol remains elevated. Responding well to vagal tone protocol.",
            retainerUtilization: 0.72, sessionsUsed: 8, sessionsAllotted: 12
        ),
        DashboardPatient(
            name: "James Oliver", initials: "JO", frequency: 7.4,
            biomarkers: [
                .init(name: "HRV", value: 55, unit: "ms", normalLow: 30, normalHigh: 100, trend: .rising),
                .init(name: "Melatonin", value: 72, unit: "pg/mL", normalLow: 40, normalHigh: 120, trend: .stable),
            ],
            protocols: [
                .init(name: "Sleep Architecture", icon: "moon.zzz", categoryColor: Color(hex: 0x122E21), adherence: 91),
            ],
            rsdRisk: .low, notes: "Excellent progress on sleep protocol.",
            retainerUtilization: 0.58, sessionsUsed: 7, sessionsAllotted: 12
        ),
        DashboardPatient(
            name: "Eli Nakamura", initials: "EN", frequency: 5.2,
            biomarkers: [
                .init(name: "Cortisol", value: 24.1, unit: "mcg/dL", normalLow: 6, normalHigh: 18.4, trend: .rising),
                .init(name: "DHEA-S", value: 155, unit: "mcg/dL", normalLow: 200, normalHigh: 400, trend: .falling),
                .init(name: "HRV", value: 28, unit: "ms", normalLow: 30, normalHigh: 100, trend: .falling),
                .init(name: "Melatonin", value: 35, unit: "pg/mL", normalLow: 40, normalHigh: 120, trend: .falling),
            ],
            protocols: [
                .init(name: "Vagal Tone Reset", icon: "brain.head.profile", categoryColor: Color(hex: 0x0A1C14), adherence: 45),
                .init(name: "Cortisol Correction", icon: "waveform.path.ecg", categoryColor: Color(hex: 0xC5A059), adherence: 52),
                .init(name: "Sleep Architecture", icon: "moon.zzz", categoryColor: Color(hex: 0x122E21), adherence: 61),
            ],
            rsdRisk: .elevated, notes: "Multiple biomarker anomalies. Comprehensive protocol needed.",
            retainerUtilization: 0.92, sessionsUsed: 11, sessionsAllotted: 12
        ),
    ]
}

struct RetreatInfo: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var dateRange: String
    var participants: Int
    var maxParticipants: Int
    var description: String

    static let samples: [RetreatInfo] = [
        RetreatInfo(name: "Nervous System Reset", location: "Big Sur, CA", dateRange: "Apr 12–16, 2026", participants: 14, maxParticipants: 20, description: "A 5-day immersive combining breathwork, cold exposure, and guided nervous system regulation. Designed for practitioners experiencing chronic sympathetic dominance."),
        RetreatInfo(name: "Creative Depth Retreat", location: "Tulum, MX", dateRange: "May 3–7, 2026", participants: 8, maxParticipants: 12, description: "Writing and creative expression in a calm environment. Morning breathwork, afternoon deep writing blocks, evening group sharing."),
        RetreatInfo(name: "Provider Cohort Training", location: "Sedona, AZ", dateRange: "Jun 14–18, 2026", participants: 18, maxParticipants: 24, description: "Advanced training in biometric-informed wellness protocols. Hands-on practice with AI translation tools and patient encounter holarchy."),
    ]
}
