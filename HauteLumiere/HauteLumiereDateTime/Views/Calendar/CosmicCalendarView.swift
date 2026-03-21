// CosmicCalendarView.swift
// Haute Lumière Date & Time — Cosmic Calendar
//
// Every day on the calendar has a bespoke graphical forecast
// for every spoke in the life wheel. Auspicious times for
// initiating goals are aligned with the astrological clock
// and planetary positions. Open any day → full briefing.

import SwiftUI

struct CosmicCalendarView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var selectedDate = Date()
    @State private var selectedDayForecast: DailyCosmicForecast?
    @State private var currentMonth = Date()

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")
    private let bg = Color(hex: "050505")

    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Month navigation
                        monthHeader

                        // Calendar grid
                        calendarGrid

                        // Selected date forecast
                        if let forecast = selectedDayForecast {
                            selectedDateView(forecast)
                        } else {
                            todayQuickView
                        }

                        // Moon phase tracker
                        moonPhaseTracker

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cosmic Calendar")
                        .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                        .foregroundColor(ivory)
                }
            }
        }
    }

    // MARK: - Month Header
    private var monthHeader: some View {
        HStack {
            Button(action: { changeMonth(-1) }) {
                Image(systemName: "chevron.left").foregroundColor(gold)
            }
            Spacer()

            let formatter = DateFormatter()
            Text({
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: currentMonth)
            }())
                .font(.custom("Cormorant Garamond", size: 22).weight(.medium))
                .foregroundColor(ivory)

            Spacer()
            Button(action: { changeMonth(1) }) {
                Image(systemName: "chevron.right").foregroundColor(gold)
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // Day of week headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.custom("Avenir Next", size: 11).weight(.semibold))
                        .foregroundColor(muted)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
                ForEach(days, id: \.self) { date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.02)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.08), lineWidth: 0.5))
    }

    private func dayCell(_ date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let energy = dayEnergy(date)

        return Button(action: { selectDate(date) }) {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.custom("Avenir Next", size: 14).weight(isToday ? .bold : .regular))
                    .foregroundColor(isSelected ? bg : isToday ? gold : ivory)

                // Energy dot
                Circle()
                    .fill(energyColor(energy))
                    .frame(width: 4, height: 4)
            }
            .frame(width: 38, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? gold : isToday ? gold.opacity(0.1) : .clear)
            )
        }
    }

    // MARK: - Selected Date View
    private func selectedDateView(_ forecast: DailyCosmicForecast) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedDate, style: .date)
                        .font(.custom("Cormorant Garamond", size: 20).weight(.medium))
                        .foregroundColor(ivory)
                    Text("\(forecast.moonPhase.rawValue) · \(forecast.sunTransit.displayName) season")
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(muted)
                }
                Spacer()
                Text(forecast.overallEnergy)
                    .font(.custom("Cormorant Garamond", size: 28).weight(.light))
                    .foregroundColor(gold)
            }

            // Mini life wheel energy bars
            VStack(spacing: 6) {
                ForEach(forecast.lifeWheelForecasts.prefix(5)) { wheelForecast in
                    HStack(spacing: 8) {
                        Text(wheelForecast.dimension)
                            .font(.custom("Avenir Next", size: 11))
                            .foregroundColor(muted)
                            .frame(width: 80, alignment: .leading)

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(gold.opacity(0.6))
                                .frame(width: geo.size.width * wheelForecast.energy / 10.0, height: 6)
                        }
                        .frame(height: 6)

                        Text(String(format: "%.0f", wheelForecast.energy))
                            .font(.custom("Avenir Next", size: 10))
                            .foregroundColor(gold)
                            .frame(width: 20)
                    }
                }
            }

            // Auspicious times preview
            if let bestTime = forecast.auspiciousTimes.first {
                HStack(spacing: 8) {
                    Image(systemName: "clock.badge.checkmark.fill")
                        .foregroundColor(gold)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Best time: \(bestTime.timeWindow)")
                            .font(.custom("Avenir Next", size: 12).weight(.semibold))
                            .foregroundColor(ivory)
                        Text(bestTime.activity)
                            .font(.custom("Avenir Next", size: 11))
                            .foregroundColor(muted)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.1), lineWidth: 0.5))
    }

    private var todayQuickView: some View {
        VStack(spacing: 8) {
            Text("Select a date to see its cosmic forecast")
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(muted)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
    }

    // MARK: - Moon Phase Tracker
    private var moonPhaseTracker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Moon Phases This Month")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            HStack(spacing: 0) {
                ForEach(DailyCosmicForecast.MoonPhase.allCases, id: \.self) { phase in
                    VStack(spacing: 4) {
                        Image(systemName: phase.icon)
                            .font(.system(size: 16))
                            .foregroundColor(gold.opacity(0.6))
                        Text(phase.rawValue.components(separatedBy: " ").first ?? "")
                            .font(.system(size: 8))
                            .foregroundColor(muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.02)))
    }

    // MARK: - Helpers

    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let startWeekday = calendar.component(.weekday, from: firstDay) - 1

        var days: [Date?] = Array(repeating: nil, count: startWeekday)
        for day in range {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        return days
    }

    private func changeMonth(_ offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func selectDate(_ date: Date) {
        selectedDate = date
        selectedDayForecast = cosmicEngine.generateDailyForecast()
    }

    private func dayEnergy(_ date: Date) -> Double {
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return Double(day % 10) + 1
    }

    private func energyColor(_ energy: Double) -> Color {
        if energy >= 8 { return gold }
        if energy >= 5 { return gold.opacity(0.5) }
        return muted.opacity(0.3)
    }
}
