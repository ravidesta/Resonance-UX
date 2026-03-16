// CalendarLedgerView.swift
// Resonance UX GitHub Backup — Calendar Ledger
// Every upload/change logged with notes and bitstamp hash

import SwiftUI

struct CalendarLedgerView: View {
    let portfolio: Portfolio
    @State private var selectedDate: Date = Date()
    @State private var viewMode: LedgerViewMode = .timeline

    enum LedgerViewMode: String, CaseIterable {
        case timeline = "Timeline"
        case calendar = "Calendar"
        case ledger = "Ledger"
    }

    var entriesForSelectedDate: [ChangeLogEntry] {
        portfolio.changelog.filter { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: selectedDate)
        }
    }

    var entriesByMonth: [(String, [ChangeLogEntry])] {
        let grouped = Dictionary(grouping: portfolio.changelog) { entry in
            entry.date.formatted(.dateTime.year().month())
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        VStack(spacing: ResonanceSpacing.md) {
            // View mode picker
            Picker("View", selection: $viewMode) {
                ForEach(LedgerViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, ResonanceSpacing.md)

            switch viewMode {
            case .timeline:
                timelineView
            case .calendar:
                calendarView
            case .ledger:
                ledgerView
            }
        }
    }

    // MARK: - Timeline View

    var timelineView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(portfolio.changelog) { entry in
                    HStack(alignment: .top, spacing: ResonanceSpacing.md) {
                        // Timeline line + dot
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [portfolio.accentColor, ResonanceColors.borderLight],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 2)
                                .frame(height: 20)

                            ChromaticOrb(color: actionColor(entry.action), size: 10, pulse: false)

                            Rectangle()
                                .fill(ResonanceColors.borderLight.opacity(0.5))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                        .frame(width: 24)

                        // Entry card
                        LivingSurface(accentColor: actionColor(entry.action)) {
                            VStack(alignment: .leading, spacing: ResonanceSpacing.xs) {
                                HStack {
                                    Text(entry.action.rawValue.uppercased())
                                        .font(ResonanceTypography.callsignFont)
                                        .foregroundColor(actionColor(entry.action))
                                        .tracking(1)
                                    Spacer()
                                    Text(entry.date.formatted(.dateTime.month().day().hour().minute()))
                                        .font(ResonanceTypography.monoFont)
                                        .foregroundColor(ResonanceColors.textLight)
                                }

                                Text(entry.description)
                                    .font(ResonanceTypography.bodySystem)
                                    .foregroundColor(ResonanceColors.textMain)

                                HStack(spacing: ResonanceSpacing.md) {
                                    if let hash = entry.commitHash {
                                        Label(String(hash.prefix(8)), systemImage: "number")
                                            .font(ResonanceTypography.monoFont)
                                            .foregroundColor(ResonanceColors.textMuted)
                                    }
                                    if entry.filesChanged > 0 {
                                        Label("\(entry.filesChanged) files", systemImage: "doc")
                                    }
                                    if entry.insertions > 0 {
                                        Text("+\(entry.insertions)")
                                            .foregroundColor(ResonanceColors.growthGreen)
                                    }
                                    if entry.deletions > 0 {
                                        Text("-\(entry.deletions)")
                                            .foregroundColor(ResonanceColors.rhythmCoral)
                                    }
                                }
                                .font(ResonanceTypography.captionSystem)

                                if let bitstamp = entry.bitstampHash {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.seal")
                                            .foregroundColor(ResonanceColors.goldPrimary)
                                        Text("Bitstamp: \(bitstamp.prefix(20))...")
                                            .font(ResonanceTypography.monoFont)
                                            .foregroundColor(ResonanceColors.goldPrimary)
                                    }
                                }
                            }
                            .padding(ResonanceSpacing.sm)
                        }
                    }
                    .padding(.horizontal, ResonanceSpacing.md)
                }
            }
            .padding(.bottom, ResonanceSpacing.xl)
        }
    }

    // MARK: - Calendar View

    var calendarView: some View {
        VStack(spacing: ResonanceSpacing.md) {
            // Month header
            HStack {
                Button(action: { adjustMonth(-1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(selectedDate.formatted(.dateTime.year().month()))
                    .font(ResonanceTypography.headingSystem)
                Spacer()
                Button(action: { adjustMonth(1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, ResonanceSpacing.md)

            // Day headers
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, ResonanceSpacing.md)

            // Calendar grid
            let days = calendarDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(days, id: \.self) { date in
                    calendarDayCell(date)
                }
            }
            .padding(.horizontal, ResonanceSpacing.md)

            // Selected day entries
            if !entriesForSelectedDate.isEmpty {
                LivingSurface(accentColor: portfolio.accentColor) {
                    VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        Text(selectedDate.formatted(.dateTime.weekday(.wide).month().day()))
                            .font(ResonanceTypography.subheadingSystem)

                        ForEach(entriesForSelectedDate) { entry in
                            HStack {
                                ChromaticOrb(color: actionColor(entry.action), size: 6, pulse: false)
                                Text(entry.action.rawValue)
                                    .font(ResonanceTypography.captionSystem)
                                    .fontWeight(.medium)
                                Text(entry.description)
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textMuted)
                                    .lineLimit(1)
                                Spacer()
                                Text(entry.date.formatted(.dateTime.hour().minute()))
                                    .font(ResonanceTypography.monoFont)
                                    .foregroundColor(ResonanceColors.textLight)
                            }
                        }
                    }
                    .padding(ResonanceSpacing.md)
                }
                .padding(.horizontal, ResonanceSpacing.md)
            }

            Spacer()
        }
    }

    func calendarDayCell(_ date: Date) -> some View {
        let hasEntries = portfolio.changelog.contains { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)

        return Button(action: { selectedDate = date }) {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(isSelected ? .white : ResonanceColors.textMain)

                if hasEntries {
                    Circle()
                        .fill(portfolio.accentColor)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 36, height: 36)
            .background(
                isSelected
                    ? portfolio.accentColor
                    : isToday
                        ? portfolio.accentColor.opacity(0.1)
                        : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Ledger View (Table)

    var ledgerView: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                Text("DATE").frame(width: 140, alignment: .leading)
                Text("ACTION").frame(width: 100, alignment: .leading)
                Text("DESCRIPTION").frame(maxWidth: .infinity, alignment: .leading)
                Text("COMMIT").frame(width: 80, alignment: .leading)
                Text("BITSTAMP").frame(width: 140, alignment: .leading)
            }
            .font(ResonanceTypography.callsignFont)
            .foregroundColor(ResonanceColors.textMuted)
            .tracking(0.5)
            .padding(.vertical, ResonanceSpacing.sm)
            .padding(.horizontal, ResonanceSpacing.md)
            .background(ResonanceColors.green800.opacity(0.05))

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(portfolio.changelog) { entry in
                        HStack(spacing: 0) {
                            Text(entry.date.formatted(.dateTime.year().month().day().hour().minute()))
                                .frame(width: 140, alignment: .leading)

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(actionColor(entry.action))
                                    .frame(width: 6, height: 6)
                                Text(entry.action.rawValue)
                            }
                            .frame(width: 100, alignment: .leading)

                            Text(entry.description)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(entry.commitHash?.prefix(8).description ?? "—")
                                .frame(width: 80, alignment: .leading)

                            Text(entry.bitstampHash?.prefix(16).description ?? "—")
                                .foregroundColor(ResonanceColors.goldPrimary)
                                .frame(width: 140, alignment: .leading)
                        }
                        .font(ResonanceTypography.monoFont)
                        .padding(.vertical, 6)
                        .padding(.horizontal, ResonanceSpacing.md)

                        Divider().opacity(0.15)
                    }
                }
            }
        }
        .glassPanel()
        .padding(ResonanceSpacing.md)
    }

    // MARK: - Helpers

    func actionColor(_ action: ChangeLogEntry.ChangeAction) -> Color {
        switch action {
        case .upload: return ResonanceColors.growthGreen
        case .sync: return ResonanceColors.signalTeal
        case .backup: return ResonanceColors.strategicBlue
        case .restore: return ResonanceColors.warmthAmber
        case .propertyChange: return ResonanceColors.creativeMagenta
        case .secretAdded: return ResonanceColors.goldPrimary
        case .collaboratorInvited: return ResonanceColors.signalTeal
        case .fileAttached: return ResonanceColors.strategicBlue
        case .noteUpdated: return ResonanceColors.textMuted
        }
    }

    func adjustMonth(_ delta: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: delta, to: selectedDate) {
            selectedDate = newDate
        }
    }

    func calendarDays() -> [Date] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1

        var days: [Date] = []
        for offset in (-firstWeekday)..<(42 - firstWeekday) {
            if let date = calendar.date(byAdding: .day, value: offset, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
}
