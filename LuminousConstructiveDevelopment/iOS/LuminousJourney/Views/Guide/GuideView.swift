// MARK: - Luminous Guide™ View — AI Tutor, Coach & Developmental Companion
// "Like a trusted mentor who has all the time in the world."
// Warm. Unhurried. Somatically aware. Never ranking.

import SwiftUI

struct GuideView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var guideService: GuideServiceManager
    @State private var messageText: String = ""
    @State private var showSessionPicker: Bool = true
    @State private var selectedSessionType: GuideSession.SessionType = .exploration
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                if showSessionPicker {
                    sessionPickerView
                } else {
                    conversationView
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Session Type Picker

    private var sessionPickerView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Breathing orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [theme.goldPrimary.opacity(0.2), theme.forestBase.opacity(0.05)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 30)

                VStack(spacing: 8) {
                    Text("Your Guide")
                        .font(.custom("Cormorant Garamond", size: 36))
                        .fontWeight(.light)
                        .foregroundColor(theme.text)
                    Text("A compassionate companion for your developmental journey")
                        .font(.custom("Manrope", size: 14))
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    Text("How would you like to explore?")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    ForEach(sessionTypes, id: \.0) { type, title, subtitle, icon in
                        SessionTypeCard(
                            title: title,
                            subtitle: subtitle,
                            icon: icon,
                            onTap: {
                                selectedSessionType = type
                                showSessionPicker = false
                                Task { await guideService.startSession(type: type) }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Conversation View

    private var conversationView: some View {
        VStack(spacing: 0) {
            // Session header
            HStack {
                Button(action: { showSessionPicker = true }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(theme.text)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("Luminous Guide")
                        .font(.custom("Manrope", size: 15).weight(.medium))
                        .foregroundColor(theme.text)
                    Text(selectedSessionType.rawValue)
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(theme.textSecondary)
                }

                Spacer()

                // Somatic check-in shortcut
                Button(action: { insertSomaticCheckIn() }) {
                    Image(systemName: "waveform")
                        .foregroundColor(theme.accent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Welcome message
                        GuideMessageBubble(
                            content: welcomeMessage(for: selectedSessionType),
                            isGuide: true,
                            somaticPrompt: "Before we begin, take a breath. Notice what's present in your body right now."
                        )

                        if let session = guideService.currentSession {
                            ForEach(session.messages.filter { $0.role != .system }) { message in
                                GuideMessageBubble(
                                    content: message.content,
                                    isGuide: message.role == .guide,
                                    somaticPrompt: message.somaticPrompt
                                )
                            }
                        }

                        if guideService.isTyping {
                            GuideTypingIndicator()
                        }
                    }
                    .padding(20)
                }
            }

            // Input bar
            HStack(spacing: 12) {
                TextField("Share what's alive in you...", text: $messageText, axis: .vertical)
                    .font(.custom("Manrope", size: 16))
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(theme.forestBase.opacity(0.06))
                    )

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? theme.textMuted : theme.forestBase)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = messageText
        messageText = ""
        Task {
            _ = await guideService.send(text)
        }
    }

    private func insertSomaticCheckIn() {
        messageText = "I'd like a somatic check-in right now."
        sendMessage()
    }

    // MARK: - Data

    private var sessionTypes: [(GuideSession.SessionType, String, String, String)] {
        [
            (.exploration, "Open Exploration", "Explore your meaning-making landscape with curiosity", "sparkles"),
            (.somaticGuidance, "Somatic Guidance", "Let the body's wisdom guide the conversation", "waveform"),
            (.reflectionSupport, "Reflection Support", "Deepen your journaling with a compassionate mirror", "pencil.line"),
            (.bookDiscussion, "Book Discussion", "Discuss what you're reading in the LCD text", "book"),
            (.assessmentDebrief, "Assessment Debrief", "Understand your developmental landscape with nuance", "scope"),
            (.practiceGuidance, "Practice Guidance", "Be guided through a somatic or reflective practice", "figure.mind.and.body"),
            (.crisisSupport, "Gentle Holding", "When things feel overwhelming. Safety first.", "heart.text.square"),
        ]
    }

    private func welcomeMessage(for type: GuideSession.SessionType) -> String {
        switch type {
        case .exploration:
            return "Welcome. I'm here to explore alongside you — wherever your curiosity leads. There's no agenda, no right answer. Just an open space.\n\nWhat's alive in you right now? What are you noticing?"
        case .somaticGuidance:
            return "Let's slow down together.\n\nBefore we begin with words, I'd like to invite you to close your eyes for a moment. Take three slow breaths. And then, simply notice: what is your body telling you right now?"
        case .reflectionSupport:
            return "I'm here to support your reflection — not to direct it. Think of me as a mirror that occasionally asks a clarifying question.\n\nWhat are you sitting with today?"
        case .bookDiscussion:
            return "I'd love to explore the text with you. What you're reading in Luminous Constructive Development™ — what's resonating? What's provoking? What's confusing?\n\nAll of those responses are worth examining."
        case .assessmentDebrief:
            return "Let's look at your developmental landscape together — with nuance and compassion. Remember: these are snapshots, not verdicts. Every domain may show different patterns.\n\nWhat stood out to you in your assessment?"
        case .practiceGuidance:
            return "I'd like to guide you through a practice. First — are you somewhere quiet where you can be with yourself for a few minutes?\n\nAnd: what does your body need right now? Grounding? Release? Spaciousness?"
        case .crisisSupport:
            return "I'm here. You're not alone.\n\nBefore anything else — are you safe right now? Take your time.\n\nWhatever you're experiencing, it's okay to feel it. I'm not going anywhere."
        }
    }
}

// MARK: - Message Bubble

struct GuideMessageBubble: View {
    let content: String
    let isGuide: Bool
    var somaticPrompt: String?
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack {
            if !isGuide { Spacer(minLength: 60) }

            VStack(alignment: isGuide ? .leading : .trailing, spacing: 8) {
                Text(content)
                    .font(.custom("Manrope", size: 16))
                    .foregroundColor(isGuide ? theme.text : theme.cream)
                    .lineSpacing(4)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isGuide
                                ? theme.forestBase.opacity(0.06)
                                : theme.forestBase)
                    )

                // Somatic prompt indicator
                if let somatic = somaticPrompt {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "8B6BB0"))
                        Text(somatic)
                            .font(.custom("Manrope", size: 12))
                            .foregroundColor(Color(hex: "8B6BB0"))
                    }
                    .padding(.horizontal, 4)
                }
            }

            if isGuide { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Typing Indicator

struct GuideTypingIndicator: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var dotScale: [CGFloat] = [0.6, 0.6, 0.6]

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(theme.textSecondary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotScale[index])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.forestBase.opacity(0.06))
            )
            .onAppear {
                for i in 0..<3 {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2)) {
                        dotScale[i] = 1.0
                    }
                }
            }

            Spacer()
        }
    }
}

// MARK: - Session Type Card

struct SessionTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let onTap: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(theme.accent)
                    .frame(width: 44, height: 44)
                    .background(theme.goldPrimary.opacity(0.08))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Manrope", size: 16).weight(.medium))
                        .foregroundColor(theme.text)
                    Text(subtitle)
                        .font(.custom("Manrope", size: 13))
                        .foregroundColor(theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(theme.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.goldPrimary.opacity(0.08), lineWidth: 1)
            )
        }
    }
}
