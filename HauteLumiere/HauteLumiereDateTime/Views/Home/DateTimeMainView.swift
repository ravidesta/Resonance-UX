// DateTimeMainView.swift
// Haute Lumière Date & Time — Main Navigation Hub
//
// The daily command center for cosmic intelligence.
// Opens to today's 5-page illustrated briefing.

import SwiftUI

struct DateTimeMainView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var selectedTab: DateTimeTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyBriefingView()
                .tag(DateTimeTab.today)
                .tabItem {
                    Image(systemName: "sun.and.horizon.fill")
                    Text("Today")
                }

            CosmicCalendarView()
                .tag(DateTimeTab.calendar)
                .tabItem {
                    Image(systemName: "calendar.badge.clock")
                    Text("Calendar")
                }

            NatalChartView()
                .tag(DateTimeTab.chart)
                .tabItem {
                    Image(systemName: "star.circle.fill")
                    Text("Your Chart")
                }

            CosmicTeachingsView()
                .tag(DateTimeTab.learn)
                .tabItem {
                    Image(systemName: "book.circle.fill")
                    Text("Learn")
                }

            CosmicSocialView()
                .tag(DateTimeTab.social)
                .tabItem {
                    Image(systemName: "person.2.circle.fill")
                    Text("Circle")
                }
        }
        .tint(Color(hex: "D4AF37"))
        .onAppear {
            cosmicEngine.todaysForecast = cosmicEngine.generateDailyForecast()
        }
    }
}

enum DateTimeTab: Int {
    case today, calendar, chart, learn, social
}

// MARK: - Birth Data Entry View
struct BirthDataEntryView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @AppStorage("hasEnteredBirthData") private var hasEnteredBirthData = false

    @State private var fullName = ""
    @State private var birthDate = Date()
    @State private var birthTime = Date()
    @State private var hasBirthTime = false
    @State private var birthCity = ""
    @State private var birthCountry = ""
    @State private var isGenerating = false

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "light.max")
                            .font(.system(size: 32, weight: .ultraLight))
                            .foregroundColor(Color(hex: "D4AF37"))

                        Text("Haute Lumière")
                            .font(.custom("Cormorant Garamond", size: 16).weight(.light))
                            .foregroundColor(Color(hex: "D4AF37").opacity(0.7))

                        Text("Date & Time")
                            .font(.custom("Cormorant Garamond", size: 36).weight(.medium))
                            .foregroundColor(Color(hex: "FAFAF5"))

                        Text("Enter your birth details to unlock\nyour complete cosmic profile")
                            .font(.custom("Avenir Next", size: 14))
                            .foregroundColor(Color(hex: "8A8A85"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    // Form
                    VStack(spacing: 20) {
                        luxuryField("Full Name", text: $fullName, icon: "person")
                        luxuryDatePicker("Date of Birth", selection: $birthDate)

                        Toggle(isOn: $hasBirthTime) {
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .foregroundColor(Color(hex: "D4AF37"))
                                Text("I know my birth time")
                                    .font(.custom("Avenir Next", size: 14))
                                    .foregroundColor(Color(hex: "FAFAF5"))
                            }
                        }
                        .tint(Color(hex: "D4AF37"))

                        if hasBirthTime {
                            DatePicker("Birth Time", selection: $birthTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(height: 120)
                                .colorScheme(.dark)
                        }

                        luxuryField("Birth City", text: $birthCity, icon: "mappin")
                        luxuryField("Birth Country", text: $birthCountry, icon: "globe")
                    }
                    .padding(.horizontal, 24)

                    // Generate button
                    Button(action: generateProfile) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .tint(Color(hex: "050505"))
                            }
                            Text(isGenerating ? "Mapping Your Cosmos..." : "Reveal Your Cosmic Blueprint")
                                .font(.custom("Avenir Next", size: 16).weight(.medium))
                        }
                        .foregroundColor(Color(hex: "050505"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "D4AF37"))
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    }
                    .padding(.horizontal, 24)
                    .disabled(fullName.isEmpty)

                    // Tradition icons
                    HStack(spacing: 24) {
                        ForEach(CosmicTradition.allCases, id: \.self) { tradition in
                            VStack(spacing: 4) {
                                Image(systemName: tradition.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "D4AF37").opacity(0.5))
                                Text(tradition.rawValue.components(separatedBy: " ").first ?? "")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color(hex: "8A8A85"))
                            }
                        }
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 60)
                }
            }
        }
    }

    private func luxuryField(_ placeholder: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "D4AF37").opacity(0.6))
                .frame(width: 20)
            TextField(placeholder, text: text)
                .font(.custom("Avenir Next", size: 15))
                .foregroundColor(Color(hex: "FAFAF5"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "D4AF37").opacity(0.15), lineWidth: 0.5)
        )
    }

    private func luxuryDatePicker(_ label: String, selection: Binding<Date>) -> some View {
        DatePicker(label, selection: selection, displayedComponents: .date)
            .datePickerStyle(.compact)
            .font(.custom("Avenir Next", size: 15))
            .foregroundColor(Color(hex: "FAFAF5"))
            .tint(Color(hex: "D4AF37"))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "D4AF37").opacity(0.15), lineWidth: 0.5)
            )
            .colorScheme(.dark)
    }

    private func generateProfile() {
        isGenerating = true
        var data = BirthData(name: fullName, dateOfBirth: birthDate, city: birthCity, country: birthCountry)
        if hasBirthTime { data.timeOfBirth = birthTime }

        cosmicEngine.generateProfile(from: data)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isGenerating = false
            hasEnteredBirthData = true
        }
    }
}
