// FacilitatorView.swift
// Luminous Cosmic Architecture™
// AI Facilitator — Cosmic Teacher / Coach / Guide (iOS)
//
// A glassmorphic chat interface with voice and text input,
// a luminous cosmic guide avatar, conversation starters,
// typing indicators, and session history.

import SwiftUI
import Speech
import AVFoundation

// MARK: - Data Models

struct FacilitatorMessage: Identifiable, Equatable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date
    let inputMode: InputMode

    enum MessageRole: String { case user, guide }
    enum InputMode: String { case text, voice }

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

struct ConversationThread: Identifiable {
    let id: String
    var title: String
    var messages: [FacilitatorMessage]
    let createdAt: Date
    var updatedAt: Date
}

struct ConversationStarter: Identifiable {
    let id = UUID()
    let label: String
    let prompt: String
    let icon: String
}

// MARK: - View Model

@MainActor
final class FacilitatorViewModel: ObservableObject {
    @Published var messages: [FacilitatorMessage] = []
    @Published var threads: [ConversationThread] = []
    @Published var inputText: String = ""
    @Published var isRecording = false
    @Published var isGuideTyping = false
    @Published var isGuideSpeaking = false
    @Published var showHistory = false
    @Published var voiceModeActive = false
    @Published var recordingLevel: CGFloat = 0.0

    private var activeThreadId: String?
    private let synthesizer = AVSpeechSynthesizer()

    let starters: [ConversationStarter] = [
        .init(label: "Tell me about my chart", prompt: "I would love to understand my natal chart more deeply. Can you walk me through the key themes?", icon: "\u{2609}"),
        .init(label: "What should I focus on today?", prompt: "Based on the current transits and my chart, what energies are most relevant for me today?", icon: "\u{2728}"),
        .init(label: "Help me understand my Moon sign", prompt: "I want to explore what my Moon sign means for my emotional world. Can you guide me?", icon: "\u{263D}"),
        .init(label: "Guide me through a reflection", prompt: "I would like a guided reflection connecting me with the current cosmic energies.", icon: "\u{2618}"),
    ]

    // MARK: Send

    func send(_ text: String? = nil, mode: FacilitatorMessage.InputMode = .text) {
        let content = text ?? inputText
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        inputText = ""

        let userMsg = FacilitatorMessage(
            id: UUID().uuidString,
            role: .user,
            content: content,
            timestamp: Date(),
            inputMode: mode
        )
        withAnimation(ResonanceAnimation.springSmooth) {
            messages.append(userMsg)
        }
        ResonanceHaptics.light()

        // Simulate guide response
        isGuideTyping = true
        let delay = Double.random(in: 1.0...2.5)
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            let response = generateGuideResponse(to: content)
            let guideMsg = FacilitatorMessage(
                id: UUID().uuidString,
                role: .guide,
                content: response,
                timestamp: Date(),
                inputMode: .text
            )
            withAnimation(ResonanceAnimation.springSmooth) {
                isGuideTyping = false
                messages.append(guideMsg)
            }
            ResonanceHaptics.soft()

            if voiceModeActive {
                speakResponse(response)
            }
        }
    }

    func selectStarter(_ starter: ConversationStarter) {
        send(starter.prompt)
    }

    // MARK: Voice

    func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            ResonanceHaptics.medium()
            // In production, integrate SFSpeechRecognizer here
            // Simulate recording with animation
            simulateRecordingLevels()
        } else {
            ResonanceHaptics.light()
            // Simulate recognized speech
            let simulatedText = "What does the current transit mean for me?"
            send(simulatedText, mode: .voice)
        }
    }

    func speakResponse(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.05
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        isGuideSpeaking = true
        synthesizer.speak(utterance)
        // In production, use AVSpeechSynthesizerDelegate to track completion
        Task {
            try? await Task.sleep(nanoseconds: UInt64(Double(text.count) / 15.0 * 1_000_000_000))
            isGuideSpeaking = false
        }
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isGuideSpeaking = false
    }

    // MARK: Helpers

    private func generateGuideResponse(to input: String) -> String {
        let responses = [
            "That\u{2019}s a wonderful question to sit with. Your chart holds layers of meaning that unfold as you engage with them. The Sun illuminates your core vitality, but it\u{2019}s the Moon that reveals your emotional depths. What feels most alive for you right now?",
            "I appreciate your curiosity. In the cosmic framework, this moment is colored by the current transits \u2014 inviting you to notice where expansion meets your inner knowing. Rather than seeking a definitive answer, let\u{2019}s explore what resonates with your lived experience.",
            "There\u{2019}s something profound in what you\u{2019}re noticing. The astrological tradition would say you\u{2019}re touching on themes of your chart\u{2019}s deeper architecture. But beyond any framework, trust your own experience. What does your intuition say?",
            "Growth often begins at the edge of what we know. The cosmos doesn\u{2019}t give easy answers, but it offers lenses \u2014 ways of seeing that illuminate what we might miss. What part of this feels most essential to you?",
            "Let\u{2019}s take a gentle look at this together. The current lunar energy supports a quality of reflective awareness. This isn\u{2019}t about forcing insight, but about creating space for it to arrive. Take a breath, and notice what surfaces.",
        ]
        return responses.randomElement() ?? responses[0]
    }

    private func simulateRecordingLevels() {
        Task {
            while isRecording {
                try? await Task.sleep(nanoseconds: 100_000_000)
                withAnimation(.easeInOut(duration: 0.1)) {
                    recordingLevel = CGFloat.random(in: 0.2...1.0)
                }
            }
            recordingLevel = 0
        }
    }
}

// MARK: - Main View

struct FacilitatorView: View {
    @StateObject private var vm = FacilitatorViewModel()
    @Environment(\.resonanceTheme) var theme
    @Namespace private var scrollAnchor

    var body: some View {
        ZStack {
            // Background
            theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                Divider().opacity(0.2)

                if vm.messages.isEmpty {
                    welcomeContent
                } else {
                    chatContent
                }

                inputBar
            }
        }
        .sheet(isPresented: $vm.showHistory) {
            sessionHistorySheet
        }
    }

    // MARK: Header

    private var headerBar: some View {
        HStack(spacing: ResonanceSpacing.sm) {
            Button { vm.showHistory = true } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(theme.accent)
            }
            .accessibilityLabel("Session history")

            Spacer()

            // Guide avatar in header
            CosmicGuideAvatar(size: 32, isActive: vm.isGuideTyping || vm.isGuideSpeaking)

            Text("Cosmic Guide")
                .font(ResonanceTypography.headlineMedium)
                .foregroundColor(theme.textPrimary)

            Spacer()

            // Voice mode toggle
            Button {
                vm.voiceModeActive.toggle()
                ResonanceHaptics.selection()
            } label: {
                Image(systemName: vm.voiceModeActive ? "speaker.wave.3.fill" : "speaker.slash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(vm.voiceModeActive ? theme.accent : theme.textSecondary)
            }
            .accessibilityLabel(vm.voiceModeActive ? "Disable voice playback" : "Enable voice playback")
        }
        .padding(.horizontal, ResonanceSpacing.md)
        .padding(.vertical, ResonanceSpacing.sm)
    }

    // MARK: Welcome

    private var welcomeContent: some View {
        ScrollView {
            VStack(spacing: ResonanceSpacing.xl) {
                Spacer(minLength: ResonanceSpacing.xxl)

                CosmicGuideAvatar(size: 96, isActive: true)

                VStack(spacing: ResonanceSpacing.xs) {
                    Text("Your Cosmic Guide")
                        .font(ResonanceTypography.headlineLarge)
                        .foregroundColor(theme.textPrimary)

                    Text("Wise counsel through the language of the stars.\nAsk anything about your chart, transits, or inner world.")
                        .font(ResonanceTypography.bodyMedium)
                        .foregroundColor(theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, ResonanceSpacing.lg)

                // Conversation starters
                VStack(spacing: ResonanceSpacing.sm) {
                    ForEach(vm.starters) { starter in
                        Button { vm.selectStarter(starter) } label: {
                            HStack(spacing: ResonanceSpacing.sm) {
                                Text(starter.icon)
                                    .font(.system(size: 20))
                                    .frame(width: 32)

                                Text(starter.label)
                                    .font(ResonanceTypography.sansMedium(15))
                                    .foregroundColor(theme.textPrimary)

                                Spacer()

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(theme.accent)
                            }
                            .padding(.horizontal, ResonanceSpacing.md)
                            .padding(.vertical, ResonanceSpacing.sm)
                        }
                        .glassCard(cornerRadius: ResonanceRadius.md, intensity: .subtle)
                    }
                }
                .padding(.horizontal, ResonanceSpacing.md)

                Spacer(minLength: ResonanceSpacing.xxl)
            }
        }
    }

    // MARK: Chat

    private var chatContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: ResonanceSpacing.sm) {
                    ForEach(vm.messages) { message in
                        MessageBubble(message: message, theme: theme)
                            .id(message.id)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    if vm.isGuideTyping {
                        TypingIndicator(theme: theme)
                            .id("typing")
                            .transition(.opacity.combined(with: .scale))
                    }

                    // Scroll anchor
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, ResonanceSpacing.md)
                .padding(.vertical, ResonanceSpacing.sm)
            }
            .onChange(of: vm.messages.count) { _ in
                withAnimation(ResonanceAnimation.springSmooth) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: vm.isGuideTyping) { _ in
                withAnimation(ResonanceAnimation.springSmooth) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }

    // MARK: Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.2)

            HStack(spacing: ResonanceSpacing.sm) {
                // Mic button
                Button { vm.toggleRecording() } label: {
                    ZStack {
                        Circle()
                            .fill(vm.isRecording
                                ? ResonanceColors.goldPrimary.opacity(0.2)
                                : theme.glassFill)
                            .frame(width: 40, height: 40)

                        if vm.isRecording {
                            // Ripple animation
                            ForEach(0..<3) { i in
                                Circle()
                                    .stroke(ResonanceColors.goldPrimary.opacity(0.3 - Double(i) * 0.1), lineWidth: 1.5)
                                    .frame(width: 40 + CGFloat(i) * 12 * vm.recordingLevel,
                                           height: 40 + CGFloat(i) * 12 * vm.recordingLevel)
                                    .animation(
                                        .easeInOut(duration: 0.6).delay(Double(i) * 0.15),
                                        value: vm.recordingLevel
                                    )
                            }
                        }

                        Image(systemName: vm.isRecording ? "mic.fill" : "mic")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(vm.isRecording ? ResonanceColors.goldPrimary : theme.textSecondary)
                    }
                }
                .accessibilityLabel(vm.isRecording ? "Stop recording" : "Start voice input")

                // Text field
                HStack {
                    TextField("Ask the cosmos...", text: $vm.inputText, axis: .vertical)
                        .font(ResonanceTypography.sansBody(15))
                        .foregroundColor(theme.textPrimary)
                        .lineLimit(1...4)
                        .submitLabel(.send)
                        .onSubmit { vm.send() }

                    if !vm.inputText.isEmpty {
                        Button { vm.send() } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ResonanceColors.goldDark, ResonanceColors.goldPrimary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .transition(.scale.combined(with: .opacity))
                        .accessibilityLabel("Send message")
                    }
                }
                .padding(.horizontal, ResonanceSpacing.md)
                .padding(.vertical, ResonanceSpacing.xs)
                .glassCard(cornerRadius: ResonanceRadius.pill, intensity: .subtle, showBorder: true)
            }
            .padding(.horizontal, ResonanceSpacing.md)
            .padding(.vertical, ResonanceSpacing.sm)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: Session History Sheet

    private var sessionHistorySheet: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()

                if vm.threads.isEmpty {
                    VStack(spacing: ResonanceSpacing.md) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(theme.textTertiary)
                        Text("No past sessions yet")
                            .font(ResonanceTypography.bodyMedium)
                            .foregroundColor(theme.textSecondary)
                        Text("Start a conversation with your Cosmic Guide")
                            .font(ResonanceTypography.bodySmall)
                            .foregroundColor(theme.textTertiary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: ResonanceSpacing.sm) {
                            ForEach(vm.threads) { thread in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(thread.title)
                                            .font(ResonanceTypography.sansMedium(15))
                                            .foregroundColor(theme.textPrimary)
                                        Text("\(thread.messages.count) messages")
                                            .font(ResonanceTypography.bodySmall)
                                            .foregroundColor(theme.textTertiary)
                                    }
                                    Spacer()
                                    Text(thread.updatedAt, style: .relative)
                                        .font(ResonanceTypography.caption)
                                        .foregroundColor(theme.textTertiary)
                                }
                                .padding(ResonanceSpacing.md)
                                .glassCard(cornerRadius: ResonanceRadius.md, intensity: .subtle)
                            }
                        }
                        .padding(ResonanceSpacing.md)
                    }
                }
            }
            .navigationTitle("Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { vm.showHistory = false }
                        .foregroundColor(theme.accent)
                }
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: FacilitatorMessage
    let theme: ResonanceTheme

    var body: some View {
        HStack(alignment: .top, spacing: ResonanceSpacing.xs) {
            if message.role == .guide {
                CosmicGuideAvatar(size: 28, isActive: false)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(ResonanceTypography.sansBody(15))
                    .foregroundColor(
                        message.role == .user
                            ? (theme.isDark ? ResonanceColors.creamPrimary : ResonanceColors.forestDeep)
                            : theme.textPrimary
                    )
                    .lineSpacing(4)
                    .padding(.horizontal, ResonanceSpacing.md)
                    .padding(.vertical, ResonanceSpacing.sm)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                                .fill(.ultraThinMaterial)

                            RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                                .fill(
                                    message.role == .user
                                        ? ResonanceColors.goldPrimary.opacity(theme.isDark ? 0.15 : 0.1)
                                        : ResonanceColors.forestMid.opacity(theme.isDark ? 0.3 : 0.08)
                                )
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                            .strokeBorder(
                                message.role == .user
                                    ? ResonanceColors.goldPrimary.opacity(0.2)
                                    : theme.glassStroke,
                                lineWidth: 0.5
                            )
                    )

                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(ResonanceTypography.caption)
                    .foregroundColor(theme.textTertiary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.78,
                   alignment: message.role == .user ? .trailing : .leading)

            if message.role == .user {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity,
               alignment: message.role == .user ? .trailing : .leading)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    let theme: ResonanceTheme
    @State private var phase = 0.0

    var body: some View {
        HStack(alignment: .top, spacing: ResonanceSpacing.xs) {
            CosmicGuideAvatar(size: 28, isActive: true)

            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(ResonanceColors.goldPrimary.opacity(0.6))
                        .frame(width: 7, height: 7)
                        .scaleEffect(dotScale(for: i))
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, ResonanceSpacing.md)
            .padding(.vertical, ResonanceSpacing.sm + 4)
            .background(
                RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                            .fill(ResonanceColors.forestMid.opacity(theme.isDark ? 0.3 : 0.08))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceRadius.lg)
                    .strokeBorder(theme.glassStroke, lineWidth: 0.5)
            )

            Spacer()
        }
        .onAppear { phase = 1.0 }
    }

    private func dotScale(for index: Int) -> CGFloat {
        let offset = Double(index) * 0.3
        return 0.5 + 0.5 * sin(phase * .pi + offset)
    }
}

// MARK: - Cosmic Guide Avatar

struct CosmicGuideAvatar: View {
    let size: CGFloat
    let isActive: Bool

    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var innerGlow: CGFloat = 0.3

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ResonanceColors.goldPrimary.opacity(isActive ? 0.25 : 0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)
                .scaleEffect(pulseScale)

            // Ring
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            ResonanceColors.goldDark,
                            ResonanceColors.goldPrimary,
                            ResonanceColors.goldLight,
                            ResonanceColors.goldPrimary,
                            ResonanceColors.goldDark
                        ],
                        center: .center
                    ),
                    lineWidth: size * 0.05
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))

            // Inner cosmic symbol
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let radius = min(canvasSize.width, canvasSize.height) * 0.28

                // Draw a luminous cosmic star pattern
                let points = 8
                var path = Path()
                for i in 0..<points {
                    let angle = (CGFloat(i) / CGFloat(points)) * 2 * .pi - .pi / 2
                    let r = i % 2 == 0 ? radius : radius * 0.45
                    let point = CGPoint(
                        x: center.x + cos(angle) * r,
                        y: center.y + sin(angle) * r
                    )
                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()

                context.fill(path, with: .color(Color(hex: "C5A059").opacity(Double(innerGlow + 0.4))))
            }
            .frame(width: size * 0.7, height: size * 0.7)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseScale = isActive ? 1.08 : 1.03
                innerGlow = isActive ? 0.6 : 0.35
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview {
    FacilitatorView()
        .environment(\.resonanceTheme, ResonanceTheme(isDark: false))
}
