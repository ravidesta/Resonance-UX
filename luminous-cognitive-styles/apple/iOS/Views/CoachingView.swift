// CoachingView.swift
// Luminous Cognitive Styles™ — iOS
// Coaching plans, chat interface, session booking

import SwiftUI

struct CoachingView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedPlan: CoachingPlan?
    @State private var showChat = false
    @State private var messageText = ""
    @State private var chatMessages: [ChatMessage] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: LCSTheme.Spacing.xl) {
                    // Header
                    coachingHeader

                    // Plans
                    VStack(spacing: LCSTheme.Spacing.md) {
                        Text("Choose Your Path")
                            .font(.headline)
                            .foregroundColor(LCSTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(CoachingPlan.allPlans) { plan in
                            CoachingPlanCard(
                                plan: plan,
                                isSelected: selectedPlan?.id == plan.id
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPlan = plan
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Feature comparison
                    featureComparison

                    // Quick coaching chat
                    VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
                        Text("AI Cognitive Coach")
                            .font(.headline)
                            .foregroundColor(LCSTheme.textPrimary)

                        Text("Get instant insights about your cognitive style.")
                            .font(.subheadline)
                            .foregroundColor(LCSTheme.textSecondary)

                        Button { showChat = true } label: {
                            Label("Start a Conversation", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(LCSTheme.SecondaryButtonStyle())
                    }
                    .lcsCard()
                    .padding(.horizontal)

                    // Session booking
                    sessionBookingSection

                    Spacer(minLength: 100)
                }
            }
            .background(LCSTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Coaching")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showChat) {
                NavigationStack {
                    CoachingChatView(messages: $chatMessages)
                        .environmentObject(viewModel)
                }
            }
        }
    }

    // MARK: - Header

    private var coachingHeader: some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 44))
                .foregroundStyle(LCSTheme.goldGradient)

            Text("Personalized Coaching")
                .font(.title2.weight(.bold))
                .foregroundColor(LCSTheme.textPrimary)

            Text("Develop your cognitive range with expert guidance")
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, LCSTheme.Spacing.xl)
    }

    // MARK: - Feature Comparison

    private var featureComparison: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            Text("Plan Comparison")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)

            let features = [
                ("AI Coaching Chat", true, true),
                ("Weekly Exercises", true, true),
                ("Dimension Deep Dives", true, true),
                ("Progress Tracking", true, true),
                ("Live Video Sessions", false, true),
                ("Personal Coach Match", false, true),
                ("Custom Development Plan", false, true),
                ("Priority Support", false, true),
            ]

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Feature")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(LCSTheme.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Text")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(LCSTheme.amberGold)
                        .frame(width: 50)
                    Text("Tutor")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(LCSTheme.violet)
                        .frame(width: 50)
                }
                .padding(.vertical, LCSTheme.Spacing.sm)

                Divider().background(Color.white.opacity(0.1))

                ForEach(features, id: \.0) { feature in
                    HStack {
                        Text(feature.0)
                            .font(.caption)
                            .foregroundColor(LCSTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: feature.1 ? "checkmark.circle.fill" : "minus.circle")
                            .font(.caption)
                            .foregroundColor(feature.1 ? LCSTheme.emerald : LCSTheme.textTertiary)
                            .frame(width: 50)

                        Image(systemName: feature.2 ? "checkmark.circle.fill" : "minus.circle")
                            .font(.caption)
                            .foregroundColor(feature.2 ? LCSTheme.emerald : LCSTheme.textTertiary)
                            .frame(width: 50)
                    }
                    .padding(.vertical, LCSTheme.Spacing.xs)

                    if feature.0 != features.last?.0 {
                        Divider().background(Color.white.opacity(0.05))
                    }
                }
            }
        }
        .lcsCard()
        .padding(.horizontal)
    }

    // MARK: - Session Booking

    private var sessionBookingSection: some View {
        VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
            Text("Book a Session")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)

            VStack(spacing: LCSTheme.Spacing.sm) {
                SessionTimeSlot(time: "Mon, 10:00 AM", available: true)
                SessionTimeSlot(time: "Wed, 2:00 PM", available: true)
                SessionTimeSlot(time: "Fri, 11:00 AM", available: false)
                SessionTimeSlot(time: "Sat, 9:00 AM", available: true)
            }
        }
        .lcsCard()
        .padding(.horizontal)
    }
}

// MARK: - Coaching Plan Model

struct CoachingPlan: Identifiable {
    let id: String
    let name: String
    let price: String
    let period: String
    let description: String
    let icon: String
    let color: Color
    let highlights: [String]

    static let allPlans: [CoachingPlan] = [
        CoachingPlan(
            id: "text",
            name: "Text Coaching",
            price: "$9.99",
            period: "/month",
            description: "AI-powered coaching with personalized exercises and insights delivered via text.",
            icon: "text.bubble.fill",
            color: LCSTheme.amberGold,
            highlights: [
                "Unlimited AI coaching chat",
                "Weekly personalized exercises",
                "Dimension-specific deep dives",
                "Progress tracking dashboard",
            ]
        ),
        CoachingPlan(
            id: "tutor",
            name: "Personal Tutor",
            price: "$19.99",
            period: "/week",
            description: "One-on-one sessions with a certified cognitive styles coach plus all text features.",
            icon: "person.crop.circle.fill",
            color: LCSTheme.violet,
            highlights: [
                "Everything in Text Coaching",
                "Weekly 30-min live video session",
                "Matched with a personal coach",
                "Custom development roadmap",
            ]
        ),
    ]
}

// MARK: - Coaching Plan Card

struct CoachingPlanCard: View {
    let plan: CoachingPlan
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
                HStack {
                    Image(systemName: plan.icon)
                        .font(.title2)
                        .foregroundColor(plan.color)

                    VStack(alignment: .leading) {
                        Text(plan.name)
                            .font(.headline)
                            .foregroundColor(LCSTheme.textPrimary)
                        Text(plan.description)
                            .font(.caption)
                            .foregroundColor(LCSTheme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()
                }

                // Price
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(plan.price)
                        .font(.title.weight(.bold))
                        .foregroundColor(plan.color)
                    Text(plan.period)
                        .font(.caption)
                        .foregroundColor(LCSTheme.textTertiary)
                }

                // Highlights
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(plan.highlights, id: \.self) { highlight in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(plan.color.opacity(0.8))
                            Text(highlight)
                                .font(.caption)
                                .foregroundColor(LCSTheme.textSecondary)
                        }
                    }
                }

                // Subscribe button
                Text("Subscribe")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isSelected ? LCSTheme.deepNavy : plan.color)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LCSTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: LCSTheme.Radius.pill)
                            .fill(isSelected ? plan.color : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: LCSTheme.Radius.pill)
                                    .stroke(plan.color, lineWidth: 1.5)
                            )
                    )
            }
            .padding(LCSTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: LCSTheme.Radius.lg)
                    .fill(LCSTheme.darkSurface.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: LCSTheme.Radius.lg)
                            .stroke(isSelected ? plan.color.opacity(0.5) : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Session Time Slot

struct SessionTimeSlot: View {
    let time: String
    let available: Bool

    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.caption)
                .foregroundColor(available ? LCSTheme.emerald : LCSTheme.textTertiary)

            Text(time)
                .font(.subheadline)
                .foregroundColor(available ? LCSTheme.textPrimary : LCSTheme.textTertiary)

            Spacer()

            if available {
                Button("Book") { }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(LCSTheme.deepNavy)
                    .padding(.horizontal, LCSTheme.Spacing.md)
                    .padding(.vertical, LCSTheme.Spacing.xs)
                    .background(Capsule().fill(LCSTheme.goldAccent))
            } else {
                Text("Full")
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
            }
        }
        .padding(.vertical, LCSTheme.Spacing.xs)
    }
}

// MARK: - Chat Models & View

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date = Date()
}

struct CoachingChatView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var messages: [ChatMessage]
    @State private var inputText = ""
    @State private var isTyping = false

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: LCSTheme.Spacing.md) {
                        if messages.isEmpty {
                            welcomeMessage
                        }

                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        if isTyping {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation {
                            scrollProxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: LCSTheme.Spacing.sm) {
                TextField("Ask about your cognitive style...", text: $inputText)
                    .textFieldStyle(.plain)
                    .padding(LCSTheme.Spacing.sm)
                    .padding(.horizontal, LCSTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: LCSTheme.Radius.pill)
                            .fill(Color.white.opacity(0.08))
                    )
                    .foregroundColor(LCSTheme.textPrimary)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(inputText.isEmpty ? LCSTheme.textTertiary : LCSTheme.goldAccent)
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
            .background(LCSTheme.darkSurface)
        }
        .background(LCSTheme.deepNavy.ignoresSafeArea())
        .navigationTitle("AI Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
                    .foregroundColor(LCSTheme.goldAccent)
            }
        }
    }

    private var welcomeMessage: some View {
        VStack(spacing: LCSTheme.Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(LCSTheme.goldAccent)

            Text("Welcome to Cognitive Coaching")
                .font(.headline)
                .foregroundColor(LCSTheme.textPrimary)

            Text("Ask me anything about your cognitive style, how to develop specific dimensions, or strategies for working with others.")
                .font(.subheadline)
                .foregroundColor(LCSTheme.textSecondary)
                .multilineTextAlignment(.center)

            if viewModel.hasExistingProfile {
                Text("I can see your profile. Try asking: \"What are my strengths?\" or \"How can I develop my weakest dimension?\"")
                    .font(.caption)
                    .foregroundColor(LCSTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, LCSTheme.Spacing.xxl)
        .padding(.horizontal)
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        messages.append(ChatMessage(text: text, isUser: true))
        isTyping = true

        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            let response = generateCoachingResponse(for: text)
            messages.append(ChatMessage(text: response, isUser: false))
        }
    }

    private func generateCoachingResponse(for input: String) -> String {
        let lowered = input.lowercased()
        if let profile = viewModel.currentProfile {
            if lowered.contains("strength") {
                let edges = profile.developmentalEdges
                if let first = edges.first {
                    let score = profile.score(for: first)
                    let pole = score > 5.5 ? first.highPole : first.lowPole
                    return "Your strongest orientation is in \(first.name), where you lean toward the \(pole) end with a score of \(ScoreFormatter.formatted(score)). This means \(first.interpretation(for: score)) This is a real strength — lean into it while also exploring the other pole for growth."
                }
            }
            if lowered.contains("weak") || lowered.contains("develop") || lowered.contains("grow") {
                return ProfileTypeNamer.coachingSuggestion(for: profile)
                    + " Try spending 10 minutes each day deliberately practicing this mode of thinking."
            }
            if lowered.contains("profile") || lowered.contains("summary") {
                return "You are \(profile.profileTypeName). \(profile.profileSummary) Would you like to explore any specific dimension in more depth?"
            }
        }

        if lowered.contains("dimension") || lowered.contains("what are") {
            return "The Luminous Cognitive Styles framework has 7 dimensions: Perceptual Mode, Processing Rhythm, Generative Orientation, Representational Channel, Relational Orientation, Somatic Integration, and Complexity Tolerance. Each is a spectrum, not a binary. Would you like to explore any particular one?"
        }

        return "That's a great question. The key insight from the Luminous Cognitive Styles framework is that every cognitive style has genuine strengths. The goal isn't to change who you are, but to understand your home territory and strategically expand your adaptive range. Would you like specific exercises for any particular dimension?"
    }
}

// MARK: - Chat Bubble

struct ChatBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.subheadline)
                    .foregroundColor(message.isUser ? LCSTheme.deepNavy : LCSTheme.textPrimary)
                    .padding(.horizontal, LCSTheme.Spacing.md)
                    .padding(.vertical, LCSTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isUser ? LCSTheme.goldAccent : LCSTheme.midSurface)
                    )

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundColor(LCSTheme.textTertiary)
            }

            if !message.isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var dotIndex = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(LCSTheme.textTertiary)
                    .frame(width: 6, height: 6)
                    .opacity(dotIndex == i ? 1.0 : 0.3)
            }
        }
        .padding(.horizontal, LCSTheme.Spacing.md)
        .padding(.vertical, LCSTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LCSTheme.midSurface)
        )
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                dotIndex = (dotIndex + 1) % 3
            }
        }
    }
}
