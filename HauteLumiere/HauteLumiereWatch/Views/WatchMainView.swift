// WatchMainView.swift
// Haute Lumière — Apple Watch Interface
//
// Features rotating profound quotes (vetted, real, from real people)
// throughout the day. The kind of quotes that make you sound smarter
// the more you use this watch. Rotates every ~6 hours automatically.

import SwiftUI

struct WatchMainView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            WatchDashboardView()
                .tag(0)

            WatchQuoteView()
                .tag(1)

            WatchHabitView()
                .tag(2)

            WatchBreathingView()
                .tag(3)

            WatchCoachView()
                .tag(4)
        }
        .tabViewStyle(.carousel)
    }
}

// MARK: - Dashboard
struct WatchDashboardView: View {
    @State private var completedHabits = 3
    @State private var totalHabits = 6
    @State private var streak = 12

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Logo
                HStack(spacing: 4) {
                    Image(systemName: "light.max")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "C5A059"))
                    Text("Haute Lumière")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(Color(hex: "C5A059"))
                }

                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color(hex: "1B402E"), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: Double(completedHabits) / Double(totalHabits))
                        .stroke(Color(hex: "C5A059"), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text("\(completedHabits)")
                            .font(.system(size: 24, weight: .medium, design: .serif))
                            .foregroundColor(.white)
                        Text("of \(totalHabits)")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }

                // Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "C5A059"))
                    Text("\(streak) day streak")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                // Quick actions
                VStack(spacing: 8) {
                    WatchQuickAction(icon: "wind", title: "Breathe", color: Color(hex: "7BA7C4"))
                    WatchQuickAction(icon: "moon.stars.fill", title: "Sleep Nidra", color: Color(hex: "4A3A7A"))
                    WatchQuickAction(icon: "message.fill", title: "Coach", color: Color(hex: "C5A059"))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Profound Quotes (Rotates Throughout the Day)
/// Real quotes from real people. Vetted. Not affirmations.
/// Rotates automatically — new quote every ~6 hours.
/// Makes you sound smarter the more you wear this watch.
struct WatchQuoteView: View {
    @State private var currentQuoteIndex = 0

    private var dailyQuotes: [(text: String, author: String)] {
        ProfoundQuoteLibrary.dailyQuotes()
    }

    private var currentQuote: (text: String, author: String) {
        ProfoundQuoteLibrary.quoteForNow()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Subtle brand
                Image(systemName: "light.max")
                    .font(.system(size: 8, weight: .ultraLight))
                    .foregroundColor(Color(hex: "C5A059").opacity(0.5))

                // Quote
                Text("\"\(currentQuote.text)\"")
                    .font(.system(size: 13, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 4)

                // Attribution
                Text("— \(currentQuote.author)")
                    .font(.system(size: 10, weight: .light))
                    .foregroundColor(Color(hex: "C5A059").opacity(0.7))

                // Time indicator (dots showing which of 4 daily quotes)
                HStack(spacing: 6) {
                    let hour = Calendar.current.component(.hour, from: Date())
                    let slot = hour / 6
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(index == slot ? Color(hex: "C5A059") : Color.white.opacity(0.15))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.top, 4)

                // Share to companion app
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 10))
                        Text("Share")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(Color(hex: "C5A059"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(hex: "C5A059").opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Watch Complication Quote Provider
/// Provides the current quote for watch face complications.
/// This is the primary status-symbol feature — a gold serif quote
/// on your watch face that changes throughout the day.
struct WatchComplicationQuote {
    static func currentComplicationText() -> String {
        let quote = ProfoundQuoteLibrary.quoteForNow()
        // Truncate for complication if needed
        if quote.text.count > 60 {
            let truncated = String(quote.text.prefix(57)) + "..."
            return "\"\(truncated)\""
        }
        return "\"\(quote.text)\""
    }

    static func currentAuthor() -> String {
        ProfoundQuoteLibrary.quoteForNow().author
    }

    /// Short form for small complications
    static func shortQuote() -> String {
        let quote = ProfoundQuoteLibrary.quoteForNow()
        if quote.text.count > 30 {
            return String(quote.text.prefix(27)) + "..."
        }
        return quote.text
    }
}

// MARK: - Habit View
struct WatchHabitView: View {
    let habits = [
        ("Morning Meditation", "sunrise.fill", true),
        ("Breathing Practice", "wind", true),
        ("Yoga Nidra", "moon.stars.fill", false),
        ("Mindful Movement", "figure.walk", true),
        ("Evening Reflection", "moon.fill", false),
        ("Gratitude Journal", "heart.text.square.fill", false),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Habits")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "C5A059"))

                ForEach(habits, id: \.0) { name, icon, done in
                    HStack(spacing: 8) {
                        Image(systemName: done ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 16))
                            .foregroundColor(done ? Color(hex: "C5A059") : .gray)

                        Text(name)
                            .font(.system(size: 12))
                            .foregroundColor(done ? .gray : .white)
                            .strikethrough(done)

                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Breathing View
struct WatchBreathingView: View {
    @State private var isBreathing = false
    @State private var circleScale: CGFloat = 0.6
    @State private var phase = "Tap to Begin"

    var body: some View {
        VStack(spacing: 12) {
            Text("Breathe")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "C5A059"))

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "C5A059").opacity(0.3), Color(hex: "C5A059").opacity(0.05)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(circleScale)

                Text(phase)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .onTapGesture {
                isBreathing.toggle()
                if isBreathing {
                    phase = "Breathe In"
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        circleScale = 1.0
                    }
                } else {
                    phase = "Tap to Begin"
                    withAnimation(.easeInOut(duration: 0.5)) {
                        circleScale = 0.6
                    }
                }
            }
        }
    }
}

// MARK: - Coach View
struct WatchCoachView: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "7BA7C4"), Color(hex: "A8C5D8")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: "sparkles")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }

            Text("Ava Azure")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Text("\"Keep going — your consistency is building something beautiful.\"")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 12))
                    Text("Talk")
                        .font(.system(size: 12))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color(hex: "C5A059"))
                .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Quick Action
struct WatchQuickAction: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }
}
