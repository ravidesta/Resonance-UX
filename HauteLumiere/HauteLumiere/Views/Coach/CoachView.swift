// CoachView.swift
// Haute Lumière — Coach Chat & Voice Interface

import SwiftUI

struct CoachView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @State private var messageText: String = ""
    @State private var isVoiceMode: Bool = false
    @State private var showCoachProfile: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var coach: CoachPersona { appState.selectedCoach }

    var body: some View {
        NavigationStack {
            ZStack {
                if appState.isNightMode {
                    ForestNightBackground(theme: appState.nightModeTheme)
                } else {
                    Color.hlCream.ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    // Header
                    coachHeader

                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: HLSpacing.md) {
                                // Welcome message if empty
                                if coachEngine.messages.isEmpty {
                                    welcomeMessage
                                }

                                ForEach(coachEngine.messages) { message in
                                    ChatBubble(message: message, coach: coach, isNightMode: appState.isNightMode)
                                        .id(message.id)
                                }

                                // Typing indicator
                                if coachEngine.isProcessing {
                                    typingIndicator
                                }
                            }
                            .padding(.horizontal, HLSpacing.md)
                            .padding(.vertical, HLSpacing.md)
                        }
                        .onChange(of: coachEngine.messages.count) { _ in
                            if let lastMessage = coachEngine.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    // Suggestions
                    if coachEngine.messages.isEmpty || coachEngine.messages.count < 3 {
                        suggestionsRow
                    }

                    // Input
                    if isVoiceMode {
                        voiceInputView
                    } else {
                        textInputView
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Coach Header
    private var coachHeader: some View {
        HStack(spacing: HLSpacing.md) {
            // Coach avatar
            Button(action: { showCoachProfile = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: coach.avatarSymbol)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(coach.displayName)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Available now")
                        .font(HLTypography.caption)
                        .foregroundColor(.hlSuccess)
                }
            }

            Spacer()

            // Voice/Text toggle
            Button(action: { withAnimation { isVoiceMode.toggle() } }) {
                Image(systemName: isVoiceMode ? "text.bubble.fill" : "mic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(appState.isNightMode ? .hlGold : .hlGreen700)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(appState.isNightMode ? Color.white.opacity(0.08) : .hlGreen50)
                    )
            }

            // Schedule session
            Button(action: {}) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 18))
                    .foregroundColor(appState.isNightMode ? .hlGold : .hlGreen700)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(appState.isNightMode ? Color.white.opacity(0.08) : .hlGreen50)
                    )
            }
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.sm)
        .background(
            Rectangle()
                .fill(appState.isNightMode ? Color.hlNightDeep.opacity(0.95) : .hlSurface.opacity(0.95))
                .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        )
    }

    // MARK: - Welcome
    private var welcomeMessage: some View {
        VStack(spacing: HLSpacing.lg) {
            Spacer(minLength: HLSpacing.xxl)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: coach.avatarSymbol)
                    .foregroundColor(.white)
                    .font(.system(size: 32))
            }

            VStack(spacing: HLSpacing.sm) {
                Text("Hello, \(appState.userName.isEmpty ? "there" : appState.userName)")
                    .font(HLTypography.serifMedium(28))
                    .foregroundColor(appState.isNightMode ? .hlGoldLight : .hlTextPrimary)

                Text("I'm \(coach.displayName), your \(coach.title.lowercased()). I'm here whenever you need me — to talk, to practice, or simply to listen.")
                    .font(HLTypography.body)
                    .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HLSpacing.lg)
            }

            Spacer(minLength: HLSpacing.lg)
        }
    }

    // MARK: - Suggestions
    private var suggestionsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HLSpacing.sm) {
                SuggestionChip(text: "How am I doing?") {
                    coachEngine.sendMessage("How am I doing with my practice?")
                }
                SuggestionChip(text: "Set a weekly goal") {
                    coachEngine.sendMessage("I want to set a weekly goal")
                }
                SuggestionChip(text: "I need to breathe") {
                    coachEngine.sendMessage("I need to breathe — I'm feeling stressed")
                }
                SuggestionChip(text: "Recommend a session") {
                    coachEngine.sendMessage("Can you recommend a session for me right now?")
                }
                SuggestionChip(text: "Weekly check-in") {
                    let checkIn = coachEngine.generateWeeklyCheckIn()
                    coachEngine.messages.append(checkIn)
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
        }
    }

    // MARK: - Text Input
    private var textInputView: some View {
        HStack(spacing: HLSpacing.sm) {
            TextField("Message \(coach.displayName)...", text: $messageText)
                .font(HLTypography.body)
                .foregroundColor(appState.isNightMode ? .hlNightText : .hlTextPrimary)
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: HLRadius.pill)
                        .fill(appState.isNightMode ? Color.white.opacity(0.08) : .hlGreen50)
                )
                .focused($isTextFieldFocused)

            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.isEmpty ? .hlTextTertiary : .hlGold)
            }
            .disabled(messageText.isEmpty)
        }
        .padding(.horizontal, HLSpacing.md)
        .padding(.vertical, HLSpacing.sm)
        .background(
            Rectangle()
                .fill(appState.isNightMode ? Color.hlNightDeep : .hlSurface)
        )
    }

    // MARK: - Voice Input
    private var voiceInputView: some View {
        VStack(spacing: HLSpacing.md) {
            Text(coachEngine.isListening ? "Listening..." : "Tap to speak")
                .font(HLTypography.label)
                .foregroundColor(appState.isNightMode ? .hlNightTextMuted : .hlTextSecondary)

            Button(action: {
                coachEngine.isListening.toggle()
            }) {
                ZStack {
                    Circle()
                        .fill(coachEngine.isListening ? Color.hlGold : (appState.isNightMode ? Color.white.opacity(0.1) : .hlGreen50))
                        .frame(width: 64, height: 64)

                    if coachEngine.isListening {
                        // Pulsing animation
                        Circle()
                            .stroke(Color.hlGold.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                            .scaleEffect(coachEngine.isListening ? 1.2 : 1.0)
                            .opacity(coachEngine.isListening ? 0 : 1)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: coachEngine.isListening)
                    }

                    Image(systemName: coachEngine.isListening ? "waveform" : "mic.fill")
                        .font(.system(size: 24))
                        .foregroundColor(coachEngine.isListening ? .hlGreen900 : .hlGold)
                }
            }
        }
        .padding(.vertical, HLSpacing.md)
        .frame(maxWidth: .infinity)
        .background(
            Rectangle()
                .fill(appState.isNightMode ? Color.hlNightDeep : .hlSurface)
        )
    }

    // MARK: - Typing Indicator
    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: HLSpacing.sm) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 28, height: 28)
                Image(systemName: coach.avatarSymbol)
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.hlTextTertiary)
                        .frame(width: 6, height: 6)
                        .opacity(0.4)
                }
            }
            .padding(.horizontal, HLSpacing.md)
            .padding(.vertical, HLSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(appState.isNightMode ? Color.white.opacity(0.06) : .hlGreen50)
            )

            Spacer()
        }
    }

    // MARK: - Actions
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        coachEngine.sendMessage(messageText)
        messageText = ""
        isTextFieldFocused = false
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: CoachMessage
    let coach: CoachPersona
    let isNightMode: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: HLSpacing.sm) {
            if message.isFromCoach {
                // Coach avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                    Image(systemName: coach.avatarSymbol)
                        .foregroundColor(.white)
                        .font(.system(size: 12))
                }
            } else {
                Spacer()
            }

            VStack(alignment: message.isFromCoach ? .leading : .trailing, spacing: 4) {
                // Special message types
                if message.type == .suggestion || message.type == .breathingPrompt || message.type == .yogaNidraInvite {
                    actionButton(for: message)
                }

                Text(message.content)
                    .font(HLTypography.body)
                    .foregroundColor(message.isFromCoach
                        ? (isNightMode ? .hlNightText : .hlTextPrimary)
                        : .white)
                    .padding(.horizontal, HLSpacing.md)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: HLRadius.lg)
                            .fill(message.isFromCoach
                                ? (isNightMode ? Color.white.opacity(0.06) : .hlGreen50)
                                : Color.hlGreen700)
                    )

                Text(timeString(message.timestamp))
                    .font(HLTypography.caption)
                    .foregroundColor(.hlTextTertiary)
            }
            .frame(maxWidth: 280, alignment: message.isFromCoach ? .leading : .trailing)

            if !message.isFromCoach {
                // No avatar for user
            } else {
                Spacer()
            }
        }
    }

    @ViewBuilder
    private func actionButton(for message: CoachMessage) -> some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                Image(systemName: actionIcon(message.type))
                    .font(.system(size: 12))
                Text(actionLabel(message.type))
                    .font(HLTypography.caption)
            }
            .foregroundColor(.hlGold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(Color.hlGold.opacity(0.12))
            )
        }
    }

    private func actionIcon(_ type: CoachMessage.MessageType) -> String {
        switch type {
        case .breathingPrompt: return "wind"
        case .yogaNidraInvite: return "moon.stars.fill"
        case .suggestion: return "sparkles"
        default: return "arrow.right"
        }
    }

    private func actionLabel(_ type: CoachMessage.MessageType) -> String {
        switch type {
        case .breathingPrompt: return "Start Breathing"
        case .yogaNidraInvite: return "Begin Yoga Nidra"
        case .suggestion: return "Try This"
        default: return "Explore"
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Suggestion Chip
struct SuggestionChip: View {
    let text: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(HLTypography.bodySmall)
                .foregroundColor(.hlGreen700)
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(Color.hlGreen200, lineWidth: 1)
                )
        }
    }
}
