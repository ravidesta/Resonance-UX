// CoachTutorView.swift
// Luminous Integral Architecture™ — AI Coach & Tutor Interface
//
// Text/voice coaching chat with glass morphism bubbles, waveform visualization,
// assessment cards, learning path progress, somatic guidance, and session history.

import SwiftUI

// MARK: - Models

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date
    let type: MessageType

    enum MessageRole: String {
        case user, coach, system
    }

    enum MessageType {
        case text
        case voiceNote(duration: TimeInterval)
        case assessmentCard(AssessmentCard)
        case somaticPractice(title: String, duration: Int)
        case learningInsight
    }

    init(id: String = UUID().uuidString, role: MessageRole, content: String,
         timestamp: Date = .now, type: MessageType = .text) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.type = type
    }

    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
}

struct AssessmentCard: Equatable {
    let question: String
    let options: [String]
    var selectedIndex: Int?

    static func == (lhs: AssessmentCard, rhs: AssessmentCard) -> Bool {
        lhs.question == rhs.question && lhs.selectedIndex == rhs.selectedIndex
    }
}

struct LearningPathStage: Identifiable {
    let id: String
    let title: String
    let description: String
    let progress: Double
    let isActive: Bool
    let isCompleted: Bool
}

struct CoachSession: Identifiable {
    let id: String
    let title: String
    let date: Date
    let messageCount: Int
    let summary: String
}

// MARK: - Coach View Model

@MainActor
final class CoachTutorViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isCoachTyping = false
    @Published var interactionMode: InteractionMode = .text
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var waveformSamples: [CGFloat] = []
    @Published var showSessionHistory = false
    @Published var showLearningPath = false
    @Published var isSomaticModeActive = false

    enum InteractionMode: String, CaseIterable {
        case text = "Text"
        case voice = "Voice"
    }

    let learningPath: [LearningPathStage] = [
        LearningPathStage(id: "lp1", title: "Foundations", description: "Integral framework basics", progress: 1.0, isActive: false, isCompleted: true),
        LearningPathStage(id: "lp2", title: "Four Quadrants", description: "Mapping reality perspectives", progress: 0.65, isActive: true, isCompleted: false),
        LearningPathStage(id: "lp3", title: "Developmental Levels", description: "Stages of growth", progress: 0.0, isActive: false, isCompleted: false),
        LearningPathStage(id: "lp4", title: "States & Types", description: "Consciousness and personality", progress: 0.0, isActive: false, isCompleted: false),
        LearningPathStage(id: "lp5", title: "Integral Life Practice", description: "Embodied application", progress: 0.0, isActive: false, isCompleted: false),
    ]

    let sessionHistory: [CoachSession] = [
        CoachSession(id: "s1", title: "Introduction to the Integral Framework", date: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now, messageCount: 12, summary: "Explored the basics of AQAL and why an integral perspective matters."),
        CoachSession(id: "s2", title: "Mapping My Experience", date: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, messageCount: 8, summary: "Applied the four quadrants to a current life challenge."),
        CoachSession(id: "s3", title: "Somatic Attunement Practice", date: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now, messageCount: 5, summary: "Guided breathing and spatial awareness exercise."),
    ]

    init() {
        loadInitialMessages()
    }

    private func loadInitialMessages() {
        messages = [
            ChatMessage(role: .system, content: "Session started"),
            ChatMessage(role: .coach, content: "Welcome back. I noticed you recently completed the chapter on the Four Quadrants. How are you finding the practice of seeing situations from all four perspectives?"),
        ]
    }

    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = ChatMessage(role: .user, content: inputText)
        messages.append(userMessage)
        inputText = ""
        simulateCoachResponse()
    }

    func sendVoiceMessage() {
        let msg = ChatMessage(
            role: .user,
            content: "Voice message",
            type: .voiceNote(duration: recordingDuration)
        )
        messages.append(msg)
        isRecording = false
        recordingDuration = 0
        waveformSamples = []
        simulateCoachResponse()
    }

    func startRecording() {
        isRecording = true
        recordingDuration = 0
        waveformSamples = Array(repeating: 0.1, count: 50)

        // Simulate waveform animation
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self, self.isRecording else {
                    timer.invalidate()
                    return
                }
                self.recordingDuration += 0.1
                let sample = CGFloat.random(in: 0.1...0.9)
                self.waveformSamples.append(sample)
                if self.waveformSamples.count > 50 {
                    self.waveformSamples.removeFirst()
                }
            }
        }
    }

    func cancelRecording() {
        isRecording = false
        recordingDuration = 0
        waveformSamples = []
    }

    private func simulateCoachResponse() {
        isCoachTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            self.isCoachTyping = false
            let responses = [
                "That is a profound observation. When you notice yourself shifting between quadrants, you are already practicing integral awareness. What do you sense in your body as you hold multiple perspectives simultaneously?",
                "I appreciate you sharing that. Let us explore this further. The interior-individual perspective — your felt sense right now — what quality does it have?",
                "This is exactly the kind of insight that emerges when we slow down and attend to all four dimensions. Would you like to try a brief somatic practice to deepen this awareness?",
            ]
            let response = ChatMessage(role: .coach, content: responses.randomElement() ?? responses[0])
            self.messages.append(response)
        }
    }

    func triggerHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        #endif
    }

    var overallProgress: Double {
        let total = learningPath.map(\.progress).reduce(0, +)
        return total / Double(learningPath.count)
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Coach Tutor View

struct CoachTutorView: View {
    @StateObject private var viewModel = CoachTutorViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background
            Color.resonanceBgBaseDark
                .ignoresSafeArea()
            OrganicBlobView()
                .ignoresSafeArea()
                .opacity(0.5)

            #if os(watchOS)
            watchCoachLayout
            #else
            fullCoachLayout
            #endif
        }
    }

    // MARK: Full Layout

    #if !os(watchOS)
    private var fullCoachLayout: some View {
        VStack(spacing: 0) {
            // Header
            coachHeader

            ResonanceDivider()

            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }

                        if viewModel.isCoachTyping {
                            typingIndicator
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Somatic mode overlay
            if viewModel.isSomaticModeActive {
                somaticModePanel
            }

            ResonanceDivider()

            // Input area
            inputArea
        }
        .sheet(isPresented: $viewModel.showSessionHistory) {
            sessionHistorySheet
        }
        .sheet(isPresented: $viewModel.showLearningPath) {
            learningPathSheet
        }
    }
    #endif

    // MARK: Watch Layout

    #if os(watchOS)
    private var watchCoachLayout: some View {
        VStack(spacing: 8) {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.messages.suffix(3)) { message in
                        watchMessageBubble(message)
                    }
                }
            }

            HStack {
                Button(action: viewModel.startRecording) {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(Color.resonanceGoldPrimary)
                }
                .accessibilityLabel("Record voice message")

                Button("Quick reply") {
                    viewModel.inputText = "Tell me more about this."
                    viewModel.sendMessage()
                }
                .font(ResonanceTypography.sansCaption2())
            }
        }
        .padding(4)
    }

    private func watchMessageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.role == .user { Spacer() }
            Text(message.content)
                .font(ResonanceTypography.sansCaption2())
                .foregroundStyle(message.role == .user ? .white : Color.resonanceGreen100)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(message.role == .user
                              ? Color.resonanceGoldDark.opacity(0.6)
                              : Color.resonanceGreen800.opacity(0.6))
                )
                .lineLimit(4)
            if message.role == .coach { Spacer() }
        }
    }
    #endif

    // MARK: Coach Header

    #if !os(watchOS)
    private var coachHeader: some View {
        HStack(spacing: 12) {
            // Coach avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.resonanceGreen700, Color.resonanceGreen900],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Integral Coach")
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)
                Text("Luminous AI Guide")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Mode toggle
            Picker("Mode", selection: $viewModel.interactionMode) {
                ForEach(CoachTutorViewModel.InteractionMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 140)

            Menu {
                Button { viewModel.showLearningPath = true } label: {
                    Label("Learning Path", systemImage: "map")
                }
                Button { viewModel.showSessionHistory = true } label: {
                    Label("Session History", systemImage: "clock.arrow.circlepath")
                }
                Button {
                    viewModel.isSomaticModeActive.toggle()
                } label: {
                    Label(
                        viewModel.isSomaticModeActive ? "Exit Somatic Mode" : "Somatic Practice",
                        systemImage: "figure.mind.and.body"
                    )
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .accessibilityLabel("Coach options")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    #endif

    // MARK: Message Bubble

    #if !os(watchOS)
    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .user { Spacer(minLength: 60) }

            if message.role == .coach {
                Circle()
                    .fill(Color.resonanceGreen700)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.resonanceGoldPrimary)
                    )
                    .accessibilityHidden(true)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                switch message.type {
                case .text:
                    textBubbleContent(message)
                case .voiceNote(let duration):
                    voiceNoteBubble(message, duration: duration)
                case .assessmentCard(let card):
                    assessmentBubble(card)
                case .somaticPractice(let title, let duration):
                    SomaticPracticeCard(title: title, instruction: message.content, durationSeconds: duration)
                case .learningInsight:
                    insightBubble(message)
                }

                Text(message.timestamp, style: .time)
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.3))
            }

            if message.role == .coach { Spacer(minLength: 60) }
        }
        .accessibilityElement(children: .combine)
    }

    private func textBubbleContent(_ message: ChatMessage) -> some View {
        Text(message.content)
            .font(ResonanceTypography.sansBody(size: 15))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                bubbleBackground(for: message.role)
            )
            .textSelection(.enabled)
    }

    @ViewBuilder
    private func bubbleBackground(for role: ChatMessage.MessageRole) -> some View {
        if role == .user {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.resonanceGoldDark.opacity(0.4))
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.resonanceGoldPrimary.opacity(0.2), lineWidth: 0.5)
                )
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.resonanceGreen800.opacity(0.4))
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.resonanceGreen600.opacity(0.2), lineWidth: 0.5)
                )
        }
    }

    private func voiceNoteBubble(_ message: ChatMessage, duration: TimeInterval) -> some View {
        HStack(spacing: 10) {
            Button {} label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }
            .accessibilityLabel("Play voice message")

            // Waveform bars
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.resonanceGoldPrimary.opacity(0.6))
                        .frame(width: 3, height: CGFloat.random(in: 4...20))
                }
            }
            .frame(height: 24)

            Text(viewModel.formatTime(duration))
                .font(ResonanceTypography.sansCaption2())
                .foregroundStyle(.white.opacity(0.5))
                .monospacedDigit()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(bubbleBackground(for: message.role))
    }

    private func assessmentBubble(_ card: AssessmentCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Assessment")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .textCase(.uppercase)
            }

            Text(card.question)
                .font(ResonanceTypography.sansBody())
                .foregroundStyle(.white)

            VStack(spacing: 8) {
                ForEach(Array(card.options.enumerated()), id: \.offset) { index, option in
                    Button {} label: {
                        HStack {
                            Image(systemName: card.selectedIndex == index ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(card.selectedIndex == index ? Color.resonanceGoldPrimary : .white.opacity(0.4))
                            Text(option)
                                .font(ResonanceTypography.sansBody(size: 14))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel(option)
                }
            }
        }
        .padding(16)
        .glassPanel(cornerRadius: 18, padding: 0)
    }

    private func insightBubble(_ message: ChatMessage) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(Color.resonanceGoldPrimary)
            Text(message.content)
                .font(ResonanceTypography.serifBodyItalic(size: 15))
                .foregroundStyle(Color.resonanceGoldLight)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.resonanceGoldDark.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.resonanceGoldPrimary.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    #endif

    // MARK: Typing Indicator

    #if !os(watchOS)
    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(Color.resonanceGreen700)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.resonanceGoldPrimary)
                )

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.5))
                        .frame(width: 7, height: 7)
                        .offset(y: i == 1 ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                            value: viewModel.isCoachTyping
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.resonanceGreen800.opacity(0.4))
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )

            Spacer()
        }
        .accessibilityLabel("Coach is typing")
    }
    #endif

    // MARK: Input Area

    #if !os(watchOS)
    private var inputArea: some View {
        VStack(spacing: 8) {
            if viewModel.interactionMode == .voice && viewModel.isRecording {
                // Voice recording UI
                VStack(spacing: 12) {
                    // Waveform
                    HStack(spacing: 2) {
                        ForEach(Array(viewModel.waveformSamples.enumerated()), id: \.offset) { _, sample in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.resonanceGoldPrimary)
                                .frame(width: 3, height: max(4, sample * 40))
                        }
                    }
                    .frame(height: 44)
                    .animation(.easeOut(duration: 0.1), value: viewModel.waveformSamples.count)

                    Text(viewModel.formatTime(viewModel.recordingDuration))
                        .font(ResonanceTypography.sansBody())
                        .foregroundStyle(.white)
                        .monospacedDigit()

                    HStack(spacing: 24) {
                        Button("Cancel") {
                            viewModel.cancelRecording()
                        }
                        .foregroundStyle(.red)

                        Button {
                            viewModel.sendVoiceMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.resonanceGoldPrimary)
                        }
                        .accessibilityLabel("Send voice message")
                    }
                }
                .padding(16)
            } else if viewModel.interactionMode == .voice {
                // Voice mode idle
                Button {
                    viewModel.startRecording()
                    viewModel.triggerHaptic()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.resonanceGoldPrimary)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.resonanceGoldPrimary.opacity(0.3), radius: 12)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.resonanceGreen900)
                    }
                }
                .padding(16)
                .accessibilityLabel("Start recording")
            } else {
                // Text input
                HStack(spacing: 12) {
                    TextField("Ask your coach...", text: $viewModel.inputText, axis: .vertical)
                        .font(ResonanceTypography.sansBody(size: 15))
                        .foregroundStyle(.white)
                        .lineLimit(1...5)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.resonanceGreen800.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                                )
                        )
                        .accessibilityLabel("Message input")

                    Button(action: viewModel.sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? .white.opacity(0.2)
                                    : Color.resonanceGoldPrimary
                            )
                    }
                    .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Send message")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
    #endif

    // MARK: Somatic Mode Panel

    #if !os(watchOS)
    private var somaticModePanel: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "figure.mind.and.body")
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Somatic Practice Mode")
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    viewModel.isSomaticModeActive = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .accessibilityLabel("Exit somatic mode")
            }

            Text("The coach will guide you through embodied practices with haptic feedback cues. Place your device where you can feel its vibrations.")
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white.opacity(0.6))

            SomaticPracticeCard(
                title: "Spatial Attunement",
                instruction: "Close your eyes. Feel the weight of your body. Notice the space above you, below you, to each side. Let your awareness expand outward, holding all dimensions simultaneously.",
                durationSeconds: 120
            )
        }
        .padding(16)
        .glassPanel(cornerRadius: 16, padding: 0)
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    #endif

    // MARK: Session History Sheet

    #if !os(watchOS)
    private var sessionHistorySheet: some View {
        NavigationStack {
            List {
                ForEach(viewModel.sessionHistory) { session in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.title)
                            .font(ResonanceTypography.sansHeadline())
                        Text(session.summary)
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        HStack {
                            Text(session.date, style: .date)
                            Spacer()
                            Text("\(session.messageCount) messages")
                        }
                        .font(ResonanceTypography.sansCaption2())
                        .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(session.title), \(session.messageCount) messages")
                }
            }
            .navigationTitle("Session History")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { viewModel.showSessionHistory = false }
                }
            }
        }
    }
    #endif

    // MARK: Learning Path Sheet

    #if !os(watchOS)
    private var learningPathSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Overall progress
                    VStack(spacing: 8) {
                        ResonanceProgressRing(progress: viewModel.overallProgress, size: 80, lineWidth: 6)
                        Text("\(Int(viewModel.overallProgress * 100))% Complete")
                            .font(ResonanceTypography.sansHeadline())
                        Text("Your Integral Development Journey")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)

                    ResonanceDivider()

                    // Stages
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.learningPath.enumerated()), id: \.element.id) { index, stage in
                            HStack(spacing: 16) {
                                // Stage indicator
                                VStack(spacing: 0) {
                                    if index > 0 {
                                        Rectangle()
                                            .fill(stage.isCompleted || stage.isActive ? Color.resonanceGoldPrimary : Color.resonanceDivider)
                                            .frame(width: 2, height: 20)
                                    }

                                    ZStack {
                                        Circle()
                                            .fill(
                                                stage.isCompleted ? Color.resonanceGreen500 :
                                                stage.isActive ? Color.resonanceGoldPrimary :
                                                Color.resonanceDivider
                                            )
                                            .frame(width: 28, height: 28)

                                        if stage.isCompleted {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white)
                                        } else {
                                            Text("\(index + 1)")
                                                .font(ResonanceTypography.sansCaption2())
                                                .foregroundStyle(stage.isActive ? Color.resonanceGreen900 : .secondary)
                                        }
                                    }

                                    if index < viewModel.learningPath.count - 1 {
                                        Rectangle()
                                            .fill(stage.isCompleted ? Color.resonanceGoldPrimary : Color.resonanceDivider)
                                            .frame(width: 2, height: 20)
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stage.title)
                                        .font(ResonanceTypography.sansHeadline())
                                        .foregroundStyle(stage.isActive ? .primary : .secondary)
                                    Text(stage.description)
                                        .font(ResonanceTypography.sansCaption())
                                        .foregroundStyle(.secondary)

                                    if stage.isActive {
                                        ResonanceProgressBar(progress: stage.progress, height: 3)
                                            .padding(.top, 4)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(stage.title), \(stage.isCompleted ? "completed" : stage.isActive ? "\(Int(stage.progress * 100)) percent" : "not started")")
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Learning Path")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { viewModel.showLearningPath = false }
                }
            }
        }
    }
    #endif
}

// MARK: - Preview

#if DEBUG
struct CoachTutorView_Previews: PreviewProvider {
    static var previews: some View {
        CoachTutorView()
            .preferredColorScheme(.dark)
    }
}
#endif
