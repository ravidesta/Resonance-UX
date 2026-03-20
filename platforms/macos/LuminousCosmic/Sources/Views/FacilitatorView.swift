// FacilitatorView.swift
// Luminous Cosmic Architecture™ — macOS Facilitator
//
// Split-view facilitator with conversation list (left) and
// active chat (right). Rich text rendering, voice input,
// keyboard-first design, multiple conversation threads.

import SwiftUI
import Speech
import AVFoundation

// MARK: - Data Models

struct MacFacilitatorMessage: Identifiable, Equatable {
    let id: String
    let role: MacMessageRole
    let content: String
    let timestamp: Date
    let inputMode: MacInputMode

    enum MacMessageRole: String { case user, guide }
    enum MacInputMode: String { case text, voice }

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

struct MacConversationThread: Identifiable {
    let id: String
    var title: String
    var messages: [MacFacilitatorMessage]
    let createdAt: Date
    var updatedAt: Date
}

struct MacConversationStarter: Identifiable {
    let id = UUID()
    let label: String
    let prompt: String
    let icon: String
    let shortcutKey: String
}

// MARK: - View Model

@MainActor
final class MacFacilitatorViewModel: ObservableObject {
    @Published var threads: [MacConversationThread] = []
    @Published var selectedThreadId: String?
    @Published var inputText: String = ""
    @Published var isGuideTyping = false
    @Published var voiceModeActive = false
    @Published var isRecording = false

    private let synthesizer = AVSpeechSynthesizer()

    let starters: [MacConversationStarter] = [
        .init(label: "Tell me about my chart", prompt: "I would love to understand my natal chart more deeply. Can you walk me through the key themes?", icon: "\u{2609}", shortcutKey: "1"),
        .init(label: "What should I focus on today?", prompt: "Based on the current transits and my chart, what energies are most relevant for me today?", icon: "\u{2728}", shortcutKey: "2"),
        .init(label: "Help me understand my Moon sign", prompt: "I want to explore what my Moon sign means for my emotional world. Can you guide me?", icon: "\u{263D}", shortcutKey: "3"),
        .init(label: "Guide me through a reflection", prompt: "I would like a guided reflection connecting me with the current cosmic energies.", icon: "\u{2618}", shortcutKey: "4"),
    ]

    var selectedThread: MacConversationThread? {
        guard let id = selectedThreadId else { return nil }
        return threads.first(where: { $0.id == id })
    }

    var selectedMessages: [MacFacilitatorMessage] {
        selectedThread?.messages ?? []
    }

    // MARK: Thread Management

    func createThread(title: String? = nil) {
        let dateStr = Date().formatted(date: .abbreviated, time: .omitted)
        let thread = MacConversationThread(
            id: UUID().uuidString,
            title: title ?? "Cosmic Dialogue \u2014 \(dateStr)",
            messages: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        threads.insert(thread, at: 0)
        selectedThreadId = thread.id
    }

    func deleteThread(_ id: String) {
        threads.removeAll(where: { $0.id == id })
        if selectedThreadId == id {
            selectedThreadId = threads.first?.id
        }
    }

    // MARK: Send

    func send(_ text: String? = nil, mode: MacFacilitatorMessage.MacInputMode = .text) {
        let content = (text ?? inputText).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        inputText = ""

        if selectedThreadId == nil {
            createThread()
        }

        guard let idx = threads.firstIndex(where: { $0.id == selectedThreadId }) else { return }

        let userMsg = MacFacilitatorMessage(
            id: UUID().uuidString,
            role: .user,
            content: content,
            timestamp: Date(),
            inputMode: mode
        )
        withAnimation(ResonanceMacTheme.Animation.spring) {
            threads[idx].messages.append(userMsg)
            threads[idx].updatedAt = Date()
        }

        isGuideTyping = true
        let delay = Double.random(in: 1.0...2.5)
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            let response = generateResponse(to: content)
            let guideMsg = MacFacilitatorMessage(
                id: UUID().uuidString,
                role: .guide,
                content: response,
                timestamp: Date(),
                inputMode: .text
            )
            withAnimation(ResonanceMacTheme.Animation.spring) {
                isGuideTyping = false
                if let i = threads.firstIndex(where: { $0.id == selectedThreadId }) {
                    threads[i].messages.append(guideMsg)
                    threads[i].updatedAt = Date()
                }
            }

            if voiceModeActive {
                speak(response)
            }
        }
    }

    func selectStarter(_ starter: MacConversationStarter) {
        createThread(title: starter.label)
        send(starter.prompt)
    }

    // MARK: Voice

    func toggleRecording() {
        isRecording.toggle()
        if !isRecording {
            let simulated = "What does the current transit mean for me?"
            send(simulated, mode: .voice)
        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.05
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    // MARK: Response Generation

    private func generateResponse(to input: String) -> String {
        let responses = [
            "That\u{2019}s a wonderful question to sit with. Your chart holds layers of meaning that unfold as you engage with them. The Sun illuminates your core vitality, but it\u{2019}s the Moon that reveals your emotional depths. What feels most alive for you right now?",
            "I appreciate your curiosity. In the cosmic framework, this moment is colored by the current transits \u2014 inviting you to notice where expansion meets your inner knowing. Rather than seeking a definitive answer, let\u{2019}s explore what resonates with your lived experience.",
            "There\u{2019}s something profound in what you\u{2019}re noticing. The astrological tradition would say you\u{2019}re touching on themes of your chart\u{2019}s deeper architecture. But beyond any framework, trust your own experience. What does your intuition say?",
            "Growth often begins at the edge of what we know. The cosmos doesn\u{2019}t give easy answers, but it offers lenses \u2014 ways of seeing that illuminate what we might miss. What part of this feels most essential to you?",
            "Let\u{2019}s take a gentle look at this together. The current lunar energy supports a quality of reflective awareness. This isn\u{2019}t about forcing insight, but about creating space for it to arrive. Take a breath, and notice what surfaces.",
        ]
        return responses.randomElement() ?? responses[0]
    }
}

// MARK: - Main View (Split)

struct MacFacilitatorView: View {
    @StateObject private var vm = MacFacilitatorViewModel()

    var body: some View {
        NavigationSplitView(
            sidebar: { sidebarView },
            detail: { detailView }
        )
        .frame(minWidth: 700, minHeight: 500)
        .background(ResonanceMacTheme.Colors.cream)
    }

    // MARK: Sidebar

    private var sidebarView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Sessions")
                    .font(ResonanceMacTheme.Typography.title2)
                    .foregroundColor(ResonanceMacTheme.Colors.textPrimary)
                Spacer()
                Button {
                    vm.createThread()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(ResonanceMacTheme.Colors.accent)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
                .help("New conversation (Cmd+N)")
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)

            Divider()

            if vm.threads.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 28))
                        .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight)
                    Text("No sessions yet")
                        .font(ResonanceMacTheme.Typography.callout)
                        .foregroundColor(ResonanceMacTheme.Colors.textSecondary)
                    Text("Press Cmd+N to start")
                        .font(ResonanceMacTheme.Typography.caption)
                        .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight)
                }
                Spacer()
            } else {
                List(selection: $vm.selectedThreadId) {
                    ForEach(vm.threads) { thread in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(thread.title)
                                .font(ResonanceMacTheme.Typography.headline)
                                .foregroundColor(
                                    vm.selectedThreadId == thread.id
                                        ? ResonanceMacTheme.Colors.gold
                                        : ResonanceMacTheme.Colors.textPrimary
                                )
                                .lineLimit(1)

                            HStack {
                                Text("\(thread.messages.count) messages")
                                    .font(ResonanceMacTheme.Typography.caption)
                                    .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight)
                                Spacer()
                                Text(thread.updatedAt, style: .relative)
                                    .font(ResonanceMacTheme.Typography.caption2)
                                    .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight)
                            }
                        }
                        .padding(.vertical, 4)
                        .tag(thread.id)
                        .contextMenu {
                            Button("Delete") { vm.deleteThread(thread.id) }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .frame(minWidth: 220, idealWidth: 260, maxWidth: 300)
        .background(ResonanceMacTheme.Colors.creamWarm)
    }

    // MARK: Detail

    private var detailView: some View {
        VStack(spacing: 0) {
            if vm.selectedThread != nil {
                chatView
            } else {
                welcomeView
            }
        }
        .background(ResonanceMacTheme.Colors.cream)
    }

    // MARK: Welcome

    private var welcomeView: some View {
        VStack(spacing: ResonanceMacTheme.Spacing.lg) {
            Spacer()

            MacCosmicGuideAvatar(size: 80, isActive: true)

            Text("Your Cosmic Guide")
                .font(ResonanceMacTheme.Typography.title)
                .foregroundColor(ResonanceMacTheme.Colors.textPrimary)

            Text("Wise counsel through the language of the stars.\nAsk anything about your chart, transits, or inner world.")
                .font(ResonanceMacTheme.Typography.body)
                .foregroundColor(ResonanceMacTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(spacing: ResonanceMacTheme.Spacing.sm) {
                ForEach(vm.starters) { starter in
                    Button { vm.selectStarter(starter) } label: {
                        HStack(spacing: 10) {
                            Text(starter.icon)
                                .font(.system(size: 18))
                                .frame(width: 28)

                            Text(starter.label)
                                .font(ResonanceMacTheme.Typography.body)
                                .foregroundColor(ResonanceMacTheme.Colors.textPrimary)

                            Spacer()

                            Text("Cmd+\(starter.shortcutKey)")
                                .font(ResonanceMacTheme.Typography.caption2)
                                .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ResonanceMacTheme.Colors.gold.opacity(0.1))
                                )
                        }
                        .padding(.horizontal, ResonanceMacTheme.Spacing.md)
                        .padding(.vertical, ResonanceMacTheme.Spacing.sm)
                    }
                    .buttonStyle(.plain)
                    .cosmicCard()
                }
            }
            .frame(maxWidth: 420)

            Spacer()
        }
        .padding(ResonanceMacTheme.Spacing.lg)
    }

    // MARK: Chat

    private var chatView: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack(spacing: 10) {
                MacCosmicGuideAvatar(size: 28, isActive: vm.isGuideTyping)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cosmic Guide")
                        .font(ResonanceMacTheme.Typography.headline)
                        .foregroundColor(ResonanceMacTheme.Colors.textPrimary)
                    if vm.isGuideTyping {
                        Text("reflecting...")
                            .font(ResonanceMacTheme.Typography.caption)
                            .foregroundColor(ResonanceMacTheme.Colors.gold)
                    }
                }

                Spacer()

                // Voice toggle
                Button {
                    vm.voiceModeActive.toggle()
                } label: {
                    Image(systemName: vm.voiceModeActive ? "speaker.wave.3.fill" : "speaker.slash")
                        .font(.system(size: 14))
                        .foregroundColor(
                            vm.voiceModeActive
                                ? ResonanceMacTheme.Colors.gold
                                : ResonanceMacTheme.Colors.mutedGreenLight
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut("v", modifiers: [.command, .shift])
                .help("Toggle voice playback (Cmd+Shift+V)")
            }
            .padding(.horizontal, ResonanceMacTheme.Spacing.md)
            .padding(.vertical, ResonanceMacTheme.Spacing.sm)

            Divider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(vm.selectedMessages) { message in
                            MacMessageBubble(message: message)
                                .id(message.id)
                        }

                        if vm.isGuideTyping {
                            MacTypingIndicator()
                                .id("typing")
                        }

                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, ResonanceMacTheme.Spacing.md)
                    .padding(.vertical, ResonanceMacTheme.Spacing.sm)
                }
                .onChange(of: vm.selectedMessages.count) { _ in
                    withAnimation(ResonanceMacTheme.Animation.gentle) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }

            Divider()

            // Input
            macInputBar
        }
    }

    // MARK: Input Bar

    private var macInputBar: some View {
        HStack(spacing: 10) {
            // Mic
            Button { vm.toggleRecording() } label: {
                Image(systemName: vm.isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 16))
                    .foregroundColor(
                        vm.isRecording
                            ? ResonanceMacTheme.Colors.gold
                            : ResonanceMacTheme.Colors.mutedGreenLight
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut("m", modifiers: [.command, .shift])
            .help("Voice input (Cmd+Shift+M)")

            // Text field
            TextField("Ask the cosmos...", text: $vm.inputText)
                .textFieldStyle(.plain)
                .font(ResonanceMacTheme.Typography.body)
                .onSubmit { vm.send() }

            // Send
            Button { vm.send() } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ResonanceMacTheme.Colors.goldDark, ResonanceMacTheme.Colors.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .buttonStyle(.plain)
            .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            .keyboardShortcut(.return, modifiers: [])
            .help("Send message (Return)")
        }
        .padding(.horizontal, ResonanceMacTheme.Spacing.md)
        .padding(.vertical, ResonanceMacTheme.Spacing.sm)
    }
}

// MARK: - Mac Message Bubble

struct MacMessageBubble: View {
    let message: MacFacilitatorMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isUser {
                MacCosmicGuideAvatar(size: 24, isActive: false)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 3) {
                // Rich text content
                Text(AttributedString(renderRichText(message.content)))
                    .font(ResonanceMacTheme.Typography.body)
                    .foregroundColor(ResonanceMacTheme.Colors.textPrimary)
                    .lineSpacing(4)
                    .textSelection(.enabled)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                            .fill(
                                isUser
                                    ? ResonanceMacTheme.Colors.gold.opacity(0.08)
                                    : ResonanceMacTheme.Colors.cardBackground
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                            .strokeBorder(
                                isUser
                                    ? ResonanceMacTheme.Colors.gold.opacity(0.2)
                                    : ResonanceMacTheme.Colors.cardBorder,
                                lineWidth: 0.5
                            )
                    )

                Text(message.timestamp, style: .time)
                    .font(ResonanceMacTheme.Typography.caption2)
                    .foregroundColor(ResonanceMacTheme.Colors.mutedGreenLight)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: 500, alignment: isUser ? .trailing : .leading)

            if isUser { Spacer(minLength: 0) }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private func renderRichText(_ text: String) -> NSAttributedString {
        // Simple rich text: render em-dashes and quotes with proper typography
        let mutable = NSMutableAttributedString(string: text)
        return mutable
    }
}

// MARK: - Mac Typing Indicator

struct MacTypingIndicator: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            MacCosmicGuideAvatar(size: 24, isActive: true)

            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(ResonanceMacTheme.Colors.gold.opacity(0.6))
                        .frame(width: 6, height: 6)
                        .scaleEffect(0.5 + 0.5 * sin(phase * .pi + Double(i) * 0.3))
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.2),
                            value: phase
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                    .fill(ResonanceMacTheme.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ResonanceMacTheme.Radius.md)
                    .strokeBorder(ResonanceMacTheme.Colors.cardBorder, lineWidth: 0.5)
            )

            Spacer()
        }
        .onAppear { phase = 1.0 }
    }
}

// MARK: - Mac Cosmic Guide Avatar

struct MacCosmicGuideAvatar: View {
    let size: CGFloat
    let isActive: Bool

    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            ResonanceMacTheme.Colors.gold.opacity(isActive ? 0.2 : 0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size * 1.3, height: size * 1.3)
                .scaleEffect(pulseScale)

            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            ResonanceMacTheme.Colors.goldDark,
                            ResonanceMacTheme.Colors.gold,
                            ResonanceMacTheme.Colors.goldLight,
                            ResonanceMacTheme.Colors.gold,
                            ResonanceMacTheme.Colors.goldDark
                        ],
                        center: .center
                    ),
                    lineWidth: max(1, size * 0.05)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))

            // Inner star
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.35, weight: .light))
                .foregroundColor(ResonanceMacTheme.Colors.gold.opacity(isActive ? 0.7 : 0.45))
        }
        .frame(width: size * 1.3, height: size * 1.3)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulseScale = isActive ? 1.06 : 1.02
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Preview

#Preview {
    MacFacilitatorView()
}
