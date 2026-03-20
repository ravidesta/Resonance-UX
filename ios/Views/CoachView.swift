// CoachView.swift
// Resonance UX — AI Coach
//
// A calm, mentorship-style interface for personalized guidance.
// Not a chatbot — a spacious conversation with an attentive presence.
// Phase-aware, biomarker-informed, and always gentle.

import SwiftUI

// MARK: - Coach Models

struct CoachMessage: Identifiable, Equatable {
    let id: UUID
    var text: String
    var isFromCoach: Bool
    var timestamp: Date
    var category: CoachMessageCategory
    var breathworkAttachment: BreathworkInvitation?
    var insightAttachment: EnergyInsight?

    init(
        id: UUID = UUID(),
        text: String,
        isFromCoach: Bool = true,
        timestamp: Date = Date(),
        category: CoachMessageCategory = .reflection,
        breathworkAttachment: BreathworkInvitation? = nil,
        insightAttachment: EnergyInsight? = nil
    ) {
        self.id = id
        self.text = text
        self.isFromCoach = isFromCoach
        self.timestamp = timestamp
        self.category = category
        self.breathworkAttachment = breathworkAttachment
        self.insightAttachment = insightAttachment
    }
}

enum CoachMessageCategory: String, Codable {
    case reflection   = "reflection"
    case breathwork   = "breathwork"
    case insight      = "insight"
    case nudge        = "nudge"
    case affirmation  = "affirmation"
    case question     = "question"

    var icon: String {
        switch self {
        case .reflection:  return "text.quote"
        case .breathwork:  return "wind"
        case .insight:     return "chart.line.uptrend.xyaxis"
        case .nudge:       return "hand.wave"
        case .affirmation: return "heart"
        case .question:    return "questionmark.circle"
        }
    }
}

struct BreathworkInvitation: Equatable {
    var technique: BreathworkTechnique
    var durationSeconds: Int
    var reason: String
}

struct EnergyInsight: Equatable {
    var title: String
    var description: String
    var trend: BiomarkerTrend
    var dataPoints: [Double]
    var recommendation: String
}

// MARK: - Coach View

struct CoachView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @Environment(\.currentPhase) private var currentPhase
    @EnvironmentObject private var appState: ResonanceAppState

    @State private var messages: [CoachMessage] = CoachMessage.initialConversation
    @State private var inputText = ""
    @State private var isCoachTyping = false
    @State private var showBreathworkOverlay = false
    @State private var selectedBreathwork: BreathworkInvitation?
    @State private var breathPhase: CGFloat = 0

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
    private var glassFill: Color {
        isDeepRest
            ? Color.white.opacity(0.04)
            : Color.white.opacity(0.7)
    }
    private var glassBorder: Color {
        isDeepRest
            ? Color.white.opacity(0.08)
            : Color.white.opacity(0.3)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                baseColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Phase status bar
                    phaseStatusBar

                    // Conversation scroll
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: ResonanceTheme.Spacing.lg) {
                                ForEach(messages) { message in
                                    CoachMessageBubble(
                                        message: message,
                                        textColor: textColor,
                                        mutedColor: mutedColor,
                                        glassFill: glassFill,
                                        glassBorder: glassBorder,
                                        isDeepRest: isDeepRest,
                                        onBreathworkTap: { invitation in
                                            selectedBreathwork = invitation
                                            showBreathworkOverlay = true
                                        }
                                    )
                                    .id(message.id)
                                }

                                if isCoachTyping {
                                    coachTypingIndicator
                                        .id("typing")
                                }
                            }
                            .padding(.horizontal, ResonanceTheme.Spacing.lg)
                            .padding(.vertical, ResonanceTheme.Spacing.md)
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation(ResonanceTheme.Animation.gentle) {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }

                    // Input area
                    coachInputArea
                }
            }
            .navigationTitle("Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            requestInsight()
                        } label: {
                            Label("Energy Insights", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        Button {
                            requestBreathwork()
                        } label: {
                            Label("Breathwork Session", systemImage: "wind")
                        }
                        Button {
                            requestReflectionPrompt()
                        } label: {
                            Label("Reflection Prompt", systemImage: "text.quote")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(ResonanceTheme.Light.gold)
                    }
                }
            }
            .overlay {
                if showBreathworkOverlay, let breathwork = selectedBreathwork {
                    BreathworkOverlay(
                        invitation: breathwork,
                        isDeepRest: isDeepRest,
                        onDismiss: { showBreathworkOverlay = false }
                    )
                    .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Phase Status Bar

    private var phaseStatusBar: some View {
        HStack(spacing: ResonanceTheme.Spacing.sm) {
            Image(systemName: currentPhase.icon)
                .font(.system(size: 12, weight: .light))
                .foregroundColor(currentPhase.color)

            Text(currentPhase.label)
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(mutedColor)

            Spacer()

            Text("Frequency: \(String(format: "%.1f", appState.currentFrequency))")
                .font(ResonanceTheme.Typography.caption)
                .foregroundColor(ResonanceTheme.Light.gold.opacity(0.7))
        }
        .padding(.horizontal, ResonanceTheme.Spacing.lg)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
        .background(surfaceColor.opacity(0.5))
    }

    // MARK: - Typing Indicator

    private var coachTypingIndicator: some View {
        HStack(alignment: .bottom, spacing: ResonanceTheme.Spacing.sm) {
            CoachAvatar(size: 28, color: ResonanceTheme.Light.gold)

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(mutedColor.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .scaleEffect(breathPhase > 0 ? 1.0 : 0.5)
                        .animation(
                            ResonanceTheme.Animation.breathe.delay(Double(i) * 0.2),
                            value: breathPhase
                        )
                }
            }
            .padding(.horizontal, ResonanceTheme.Spacing.md)
            .padding(.vertical, ResonanceTheme.Spacing.sm)
            .background(glassFill)
            .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                    .stroke(glassBorder, lineWidth: 1)
            )
            .onAppear { breathPhase = 1 }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Input Area

    private var coachInputArea: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.3)

            HStack(spacing: ResonanceTheme.Spacing.md) {
                TextField("Share what's on your mind...", text: $inputText, axis: .vertical)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(textColor)
                    .lineLimit(1...4)
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                    .padding(.vertical, ResonanceTheme.Spacing.sm)
                    .background(textColor.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(inputText.isEmpty ? mutedColor.opacity(0.3) : ResonanceTheme.Light.gold)
                }
                .disabled(inputText.isEmpty)
            }
            .padding(.horizontal, ResonanceTheme.Spacing.lg)
            .padding(.vertical, ResonanceTheme.Spacing.md)
            .background(surfaceColor.opacity(0.9))
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = CoachMessage(text: inputText, isFromCoach: false, category: .question)
        withAnimation(ResonanceTheme.Animation.gentle) {
            messages.append(userMessage)
        }
        inputText = ""

        // Simulate coach response
        isCoachTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isCoachTyping = false
            let response = generateCoachResponse()
            withAnimation(ResonanceTheme.Animation.gentle) {
                messages.append(response)
            }
        }
    }

    private func requestInsight() {
        let insight = EnergyInsight(
            title: "Energy Pattern This Week",
            description: "Your energy tends to peak between 9 and 11 AM, with a natural dip around 2 PM. Your HRV has been gradually improving.",
            trend: .rising,
            dataPoints: [0.4, 0.55, 0.7, 0.85, 0.6, 0.45, 0.5, 0.65, 0.8, 0.75],
            recommendation: "Consider scheduling your most meaningful work during morning ascend."
        )
        let message = CoachMessage(
            text: "Here's what I've noticed about your energy patterns this week.",
            category: .insight,
            insightAttachment: insight
        )
        withAnimation(ResonanceTheme.Animation.gentle) {
            messages.append(message)
        }
    }

    private func requestBreathwork() {
        let invitation = BreathworkInvitation(
            technique: phaseBreathwork,
            durationSeconds: 300,
            reason: breathworkReason
        )
        let message = CoachMessage(
            text: breathworkReason,
            category: .breathwork,
            breathworkAttachment: invitation
        )
        withAnimation(ResonanceTheme.Animation.gentle) {
            messages.append(message)
        }
    }

    private func requestReflectionPrompt() {
        let prompts: [String] = [
            "What is one thing you accomplished today that you haven't acknowledged yet?",
            "If your body could speak right now, what would it ask for?",
            "What conversation from this week is still echoing in your mind?",
            "Where in your day did you feel most aligned with your purpose?",
        ]
        let message = CoachMessage(text: prompts.randomElement()!, category: .reflection)
        withAnimation(ResonanceTheme.Animation.gentle) {
            messages.append(message)
        }
    }

    private func generateCoachResponse() -> CoachMessage {
        let responses: [String] = [
            "That's a thoughtful observation. What would it feel like to sit with that a little longer, without needing to resolve it?",
            "I notice you're reflecting on something important. There's no rush to find the answer — sometimes the question itself is the gift.",
            "Your body has been signaling that it's well-resourced today. Perhaps this is a good moment to lean into whatever feels meaningful.",
            "Thank you for sharing that. It sounds like you're becoming more attuned to your own rhythms.",
        ]
        return CoachMessage(text: responses.randomElement()!, category: .reflection)
    }

    private var phaseBreathwork: BreathworkTechnique {
        switch currentPhase {
        case .ascend:  return .coherence
        case .zenith:  return .boxBreathing
        case .descent: return .fourSevenEight
        case .rest:    return .resonant
        }
    }

    private var breathworkReason: String {
        switch currentPhase {
        case .ascend:
            return "A coherence breathing session can help calibrate your nervous system for the day ahead."
        case .zenith:
            return "Box breathing can sharpen focus during your peak phase without adding tension."
        case .descent:
            return "4-7-8 breathing supports the body's natural transition into evening calm."
        case .rest:
            return "Resonant breathing at your personal frequency can deepen rest and recovery."
        }
    }
}

// MARK: - Coach Message Bubble

struct CoachMessageBubble: View {
    let message: CoachMessage
    let textColor: Color
    let mutedColor: Color
    let glassFill: Color
    let glassBorder: Color
    let isDeepRest: Bool
    var onBreathworkTap: ((BreathworkInvitation) -> Void)?

    @State private var appear = false

    var body: some View {
        HStack(alignment: .bottom, spacing: ResonanceTheme.Spacing.sm) {
            if message.isFromCoach {
                CoachAvatar(size: 28, color: ResonanceTheme.Light.gold)
            } else {
                Spacer(minLength: 48)
            }

            VStack(alignment: message.isFromCoach ? .leading : .trailing, spacing: ResonanceTheme.Spacing.sm) {
                // Message text
                Text(message.text)
                    .font(message.isFromCoach
                        ? ResonanceTheme.Typography.bodyLarge
                        : ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(textColor.opacity(0.9))
                    .lineSpacing(message.isFromCoach ? 5 : 3)
                    .padding(.horizontal, ResonanceTheme.Spacing.lg)
                    .padding(.vertical, ResonanceTheme.Spacing.md)
                    .background(
                        Group {
                            if message.isFromCoach {
                                // Glass morphism card
                                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.xl)
                                    .fill(glassFill)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.xl)
                                            .stroke(glassBorder, lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
                            } else {
                                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.xl)
                                    .fill(ResonanceTheme.Light.gold.opacity(isDeepRest ? 0.12 : 0.08))
                            }
                        }
                    )

                // Breathwork attachment
                if let breathwork = message.breathworkAttachment {
                    BreathworkCard(
                        invitation: breathwork,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        onTap: { onBreathworkTap?(breathwork) }
                    )
                }

                // Insight attachment
                if let insight = message.insightAttachment {
                    InsightCard(
                        insight: insight,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        isDeepRest: isDeepRest
                    )
                }

                // Timestamp
                Text(timeString(message.timestamp))
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor.opacity(0.5))
            }

            if !message.isFromCoach {
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 48)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isFromCoach ? .leading : .trailing)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 12)
        .onAppear {
            withAnimation(ResonanceTheme.Animation.gentle) {
                appear = true
            }
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Coach Avatar

struct CoachAvatar: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size, height: size)
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.4, weight: .light))
                .foregroundColor(color)
        }
    }
}

// MARK: - Breathwork Card

struct BreathworkCard: View {
    let invitation: BreathworkInvitation
    let textColor: Color
    let mutedColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ResonanceTheme.Spacing.md) {
                Image(systemName: "wind")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(ResonanceTheme.Light.gold)

                VStack(alignment: .leading, spacing: 2) {
                    Text(invitation.technique.displayName)
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .foregroundColor(textColor)
                        .fontWeight(.medium)
                    Text("\(invitation.durationSeconds / 60) minutes")
                        .font(ResonanceTheme.Typography.caption)
                        .foregroundColor(mutedColor)
                }

                Spacer()

                Text("Begin")
                    .font(ResonanceTheme.Typography.bodySmall)
                    .foregroundColor(ResonanceTheme.Light.gold)
                    .fontWeight(.semibold)
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                    .padding(.vertical, ResonanceTheme.Spacing.xs)
                    .background(ResonanceTheme.Light.gold.opacity(0.1))
                    .clipShape(Capsule())
            }
            .padding(ResonanceTheme.Spacing.md)
            .background(ResonanceTheme.Light.gold.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                    .stroke(ResonanceTheme.Light.gold.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let insight: EnergyInsight
    let textColor: Color
    let mutedColor: Color
    let isDeepRest: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: ResonanceTheme.Spacing.md) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(ResonanceTheme.Light.gold)
                Text(insight.title)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(textColor)
                    .fontWeight(.medium)
            }

            // Mini sparkline
            HStack(spacing: 2) {
                ForEach(Array(insight.dataPoints.enumerated()), id: \.offset) { _, value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ResonanceTheme.Light.gold.opacity(value * 0.8 + 0.2))
                        .frame(width: 8, height: CGFloat(value * 32 + 4))
                }
            }
            .frame(height: 36, alignment: .bottom)

            Text(insight.description)
                .font(ResonanceTheme.Typography.bodySmall)
                .foregroundColor(mutedColor)
                .lineSpacing(3)

            if !insight.recommendation.isEmpty {
                Text(insight.recommendation)
                    .font(ResonanceTheme.Typography.bodySmall)
                    .foregroundColor(textColor.opacity(0.7))
                    .italic()
                    .padding(.top, ResonanceTheme.Spacing.xs)
            }
        }
        .padding(ResonanceTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .fill(isDeepRest ? Color.white.opacity(0.04) : Color.white.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                        .stroke(isDeepRest ? Color.white.opacity(0.08) : Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Breathwork Overlay

struct BreathworkOverlay: View {
    let invitation: BreathworkInvitation
    let isDeepRest: Bool
    let onDismiss: () -> Void

    @State private var breathScale: CGFloat = 0.6
    @State private var breathLabel = "Inhale"
    @State private var elapsed: Int = 0

    var body: some View {
        ZStack {
            (isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base)
                .opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: ResonanceTheme.Spacing.xxl) {
                Spacer()

                Text(breathLabel)
                    .font(ResonanceTheme.Typography.displayMedium)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                ZStack {
                    Circle()
                        .fill(ResonanceTheme.Light.gold.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .scaleEffect(breathScale)

                    Circle()
                        .stroke(ResonanceTheme.Light.gold.opacity(0.3), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .scaleEffect(breathScale)

                    Circle()
                        .fill(ResonanceTheme.Light.gold.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .scaleEffect(breathScale * 0.8)
                }
                .onAppear {
                    startBreathCycle()
                }

                Text(invitation.technique.displayName)
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)

                Text(timeRemaining)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(ResonanceTheme.Light.gold.opacity(0.6))

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Text("End Session")
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
                        .padding(.horizontal, ResonanceTheme.Spacing.xl)
                        .padding(.vertical, ResonanceTheme.Spacing.md)
                        .background(
                            Capsule()
                                .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle, lineWidth: 1)
                        )
                }
                .padding(.bottom, ResonanceTheme.Spacing.xxl)
            }
        }
    }

    private var timeRemaining: String {
        let remaining = max(0, invitation.durationSeconds - elapsed)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startBreathCycle() {
        // Simple breath animation cycle
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breathScale = 1.0
        }

        // Cycle labels
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { timer in
            if elapsed >= invitation.durationSeconds {
                timer.invalidate()
                onDismiss()
                return
            }
            breathLabel = breathLabel == "Inhale" ? "Exhale" : "Inhale"
        }

        // Track elapsed time
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            elapsed += 1
            if elapsed >= invitation.durationSeconds {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Sample Data

extension CoachMessage {
    static let initialConversation: [CoachMessage] = [
        CoachMessage(
            text: "Welcome back. I've been noticing some interesting patterns in your energy this week.",
            category: .affirmation
        ),
        CoachMessage(
            text: "Your nervous system regulation has been steadily improving — your HRV is up 8% from last week. The breathwork sessions seem to be contributing.",
            category: .insight,
            insightAttachment: EnergyInsight(
                title: "Weekly HRV Trend",
                description: "Your heart rate variability has been on a gentle upward trajectory, suggesting improved nervous system flexibility.",
                trend: .rising,
                dataPoints: [0.45, 0.48, 0.52, 0.5, 0.58, 0.62, 0.6],
                recommendation: "Continuing your morning coherence practice would support this momentum."
            )
        ),
        CoachMessage(
            text: "Is there anything particular you'd like to explore today? Or would you prefer a moment of stillness first?",
            category: .question
        ),
    ]
}
