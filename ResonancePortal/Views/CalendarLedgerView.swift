import SwiftUI

struct CalendarLedgerView: View {
    let repos: [Repository]
    let events: [BackupEvent]

    private var today: Date { Date() }
    private var calendar: Calendar { Calendar.current }

    private var monthName: String {
        today.formatted(.dateTime.month(.wide).year())
    }

    private var firstDayOfMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: today)
        let firstDay = calendar.date(from: components)!
        return calendar.component(.weekday, from: firstDay) - 1
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: today)!.count
    }

    private var todayDay: Int {
        calendar.component(.day, from: today)
    }

    private var eventsByDay: [Int: [BackupEvent]] {
        var result: [Int: [BackupEvent]] = [:]
        for event in events {
            let day = calendar.component(.day, from: event.date)
            result[day, default: []].append(event)
        }
        return result
    }

    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(monthName)
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                    Text("System Ledger")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ResonanceTheme.gold)
                }
                Spacer()
            }

            // Calendar Grid
            GlassPanel {
                VStack(spacing: 4) {
                    // Day headers
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(dayNames, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 10, weight: .regular, design: .monospaced))
                                .tracking(1)
                                .foregroundColor(.white.opacity(0.25))
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }

                    // Day cells
                    LazyVGrid(columns: columns, spacing: 4) {
                        // Empty cells before first day
                        ForEach(0..<firstDayOfMonth, id: \.self) { _ in
                            Color.clear
                                .aspectRatio(1, contentMode: .fill)
                        }

                        // Day cells
                        ForEach(1...daysInMonth, id: \.self) { day in
                            let isToday = day == todayDay
                            let hasEvent = eventsByDay[day] != nil

                            VStack(spacing: 2) {
                                Text("\(day)")
                                    .font(.system(size: 12))
                                    .foregroundColor(
                                        isToday ? ResonanceTheme.gold :
                                        hasEvent ? .white.opacity(0.7) :
                                        .white.opacity(0.4)
                                    )

                                if hasEvent {
                                    Circle()
                                        .fill(ResonanceTheme.growthGreen)
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                            .background(
                                hasEvent ? ResonanceTheme.growthGreen.opacity(0.08) : Color.clear
                            )
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isToday ? ResonanceTheme.gold : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(20)
            }

            // Event Log
            DetailSection(icon: "list.bullet", title: "Event Log") {
                VStack(spacing: 8) {
                    ForEach(events.prefix(15)) { event in
                        HStack(alignment: .top, spacing: 12) {
                            Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                                .frame(width: 80, alignment: .leading)

                            Text(event.description)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(event.hash)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(ResonanceTheme.gold.opacity(0.6))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.02))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}
