// CosmicTeachingsView.swift
// Haute Lumière Date & Time — Cross-Tradition Education
//
// Pick any two traditions and learn how they interact.
// The app teaches you anything you want to know —
// especially when the best time to do something is,
// where to move, and bespoke articles + audiobooks
// that tell you about YOU through each tradition.

import SwiftUI

struct CosmicTeachingsView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var selectedTradition1: CosmicTradition = .westernAstrology
    @State private var selectedTradition2: CosmicTradition = .numerology
    @State private var selectedLesson: CosmicLesson?

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")
    private let bg = Color(hex: "050505")

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Learn")
                                .font(.custom("Cormorant Garamond", size: 28).weight(.medium))
                                .foregroundColor(ivory)
                            Text("Choose any two traditions to explore their synthesis")
                                .font(.custom("Avenir Next", size: 13))
                                .foregroundColor(muted)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 12)

                        // Tradition picker (pick 2)
                        traditionComparePicker

                        // Synthesis lessons for selected pair
                        synthesisLessons

                        // Single-tradition deep dives
                        singleTraditionLessons

                        // Bespoke audiobooks
                        audioBookSection

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cosmic Academy")
                        .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                        .foregroundColor(ivory)
                }
            }
        }
    }

    // MARK: - Tradition Compare Picker
    private var traditionComparePicker: some View {
        VStack(spacing: 12) {
            Text("Compare & Synthesize")
                .font(.custom("Avenir Next", size: 12).weight(.semibold))
                .foregroundColor(gold)

            HStack(spacing: 16) {
                // Tradition 1
                traditionPickerColumn(selected: $selectedTradition1, exclude: selectedTradition2)

                // Plus sign
                Image(systemName: "plus")
                    .foregroundColor(gold.opacity(0.5))

                // Tradition 2
                traditionPickerColumn(selected: $selectedTradition2, exclude: selectedTradition1)
            }
        }
    }

    private func traditionPickerColumn(selected: Binding<CosmicTradition>, exclude: CosmicTradition) -> some View {
        VStack(spacing: 6) {
            ForEach(CosmicTradition.allCases.filter { $0 != exclude }, id: \.self) { tradition in
                Button(action: { selected.wrappedValue = tradition }) {
                    HStack(spacing: 8) {
                        Image(systemName: tradition.icon)
                            .font(.system(size: 14))
                        Text(tradition.rawValue.components(separatedBy: " ").first ?? "")
                            .font(.custom("Avenir Next", size: 11))
                    }
                    .foregroundColor(selected.wrappedValue == tradition ? bg : ivory.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selected.wrappedValue == tradition ? gold : Color.white.opacity(0.03))
                    )
                }
            }
        }
    }

    // MARK: - Synthesis Lessons
    private var synthesisLessons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(selectedTradition1.rawValue) × \(selectedTradition2.rawValue)")
                .font(.custom("Cormorant Garamond", size: 20).weight(.medium))
                .foregroundColor(ivory)

            let lessons = lessonsForPair(selectedTradition1, selectedTradition2)
            ForEach(lessons) { lesson in
                lessonCard(lesson)
            }
        }
    }

    // MARK: - Single Tradition Lessons
    private var singleTraditionLessons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deep Dives")
                .font(.custom("Cormorant Garamond", size: 20).weight(.medium))
                .foregroundColor(ivory)

            ForEach(CosmicTradition.allCases, id: \.self) { tradition in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: tradition.icon)
                            .foregroundColor(gold)
                        Text(tradition.rawValue)
                            .font(.custom("Avenir Next", size: 14).weight(.semibold))
                            .foregroundColor(ivory)
                    }

                    Text(tradition.description)
                        .font(.custom("Avenir Next", size: 12))
                        .foregroundColor(muted)

                    HStack(spacing: 8) {
                        miniLessonPill("Foundations")
                        miniLessonPill("Your Chart")
                        miniLessonPill("Advanced")
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.02)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(gold.opacity(0.08), lineWidth: 0.5))
            }
        }
    }

    // MARK: - Audiobook Section
    private var audioBookSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bespoke Audiobooks")
                .font(.custom("Cormorant Garamond", size: 20).weight(.medium))
                .foregroundColor(ivory)

            Text("Books written about you. Narrated for you. Based on your exact cosmic blueprint.")
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(muted)

            VStack(spacing: 8) {
                audioBookCard("Your Astrology Story", duration: "2 hours", description: "Your complete natal chart narrated as a life story — who you are, why you're here, what's ahead.")
                audioBookCard("Your Numbers Decoded", duration: "45 min", description: "Life path, expression, soul urge — your numerological identity explained in plain language.")
                audioBookCard("Your Dosha Journey", duration: "1 hour", description: "Your Ayurvedic constitution, seasonal rhythms, and personalized wellness path.")
                audioBookCard("The Five Elements Within", duration: "50 min", description: "Your elemental balance, organ health, emotional patterns, and Qi Gung practices.")
                audioBookCard("Your Enneagram Decoded", duration: "1.5 hours", description: "Core type, wing, instinctual variant — a deep dive into your personality architecture.")
            }
        }
    }

    // MARK: - Card Components

    private func lessonCard(_ lesson: CosmicLesson) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lesson.title)
                    .font(.custom("Avenir Next", size: 14).weight(.semibold))
                    .foregroundColor(ivory)
                Spacer()
                Text(lesson.duration)
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(muted)
            }
            Text(lesson.description)
                .font(.custom("Avenir Next", size: 12))
                .foregroundColor(ivory.opacity(0.6))
                .lineSpacing(2)

            HStack(spacing: 6) {
                ForEach(lesson.traditions, id: \.self) { tradition in
                    Image(systemName: tradition.icon)
                        .font(.system(size: 10))
                        .foregroundColor(gold.opacity(0.6))
                }
                Spacer()
                if lesson.hasAudio {
                    Image(systemName: "headphones")
                        .font(.system(size: 12))
                        .foregroundColor(gold.opacity(0.5))
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(gold.opacity(0.1), lineWidth: 0.5))
    }

    private func audioBookCard(_ title: String, duration: String, description: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [Color(hex: "1C1C1C"), Color(hex: "0A0A0A")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Image(systemName: "headphones")
                    .foregroundColor(gold)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Avenir Next", size: 13).weight(.semibold))
                    .foregroundColor(ivory)
                Text(duration)
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(gold)
                Text(description)
                    .font(.custom("Avenir Next", size: 11))
                    .foregroundColor(muted)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.02)))
    }

    private func miniLessonPill(_ text: String) -> some View {
        Text(text)
            .font(.custom("Avenir Next", size: 10))
            .foregroundColor(gold.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(gold.opacity(0.08)))
    }

    // MARK: - Lesson Data

    private func lessonsForPair(_ t1: CosmicTradition, _ t2: CosmicTradition) -> [CosmicLesson] {
        [
            CosmicLesson(title: "How \(t1.rawValue) and \(t2.rawValue) See You", description: "Two lenses on your identity — where they agree, where they diverge, and what the synthesis reveals.", traditions: [t1, t2], duration: "12 min", hasAudio: true),
            CosmicLesson(title: "Best Times According to Both", description: "When both traditions agree on auspicious timing — these are your golden windows.", traditions: [t1, t2], duration: "8 min", hasAudio: true),
            CosmicLesson(title: "Your Growth Edge: A Dual Perspective", description: "Where \(t1.rawValue) says to push and \(t2.rawValue) says to rest — and how to navigate the tension.", traditions: [t1, t2], duration: "15 min", hasAudio: true),
            CosmicLesson(title: "Relationship Insights from \(t1.rawValue) + \(t2.rawValue)", description: "What both systems reveal about how you love, connect, and build trust.", traditions: [t1, t2], duration: "10 min", hasAudio: true),
        ]
    }
}

struct CosmicLesson: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let traditions: [CosmicTradition]
    let duration: String
    let hasAudio: Bool
}
