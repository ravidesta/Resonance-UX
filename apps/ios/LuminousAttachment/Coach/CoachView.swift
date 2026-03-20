// CoachView.swift
// Luminous Attachment — Resonance UX
// Chat interface with coach avatar, typing indicator, quick replies, voice memos

import SwiftUI
import AVFoundation

struct CoachView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(UserProfile.self) private var profile

    @State private var messages: [CoachMessage] = CoachView.initialMessages
    @State private var inputText: String = ""
    @State private var isCoachTyping = false
    @State private var showVoiceMemo = false
    @State private var scrollProxy: ScrollViewProxy?

    // Voice memo state
    @State private var isRecordingMemo = false
    @State private var memoRecorder: AVAudioRecorder?
    @State private var memoDuration: TimeInterval = 0
    @State private var memoTimer: Timer?
    @State private var memoURL: URL?

    var body: some View {
        let scheme = theme.effectiveScheme
        VStack(spacing: 0) {
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        // Coach header
                        coachHeader(scheme: scheme)
                            .padding(.top, 12)

                        // Messages
                        ForEach(messages) { message in
                            messageBubble(message: message, scheme: scheme)
                                .id(message.id)
                        }

                        // Typing indicator
                        if isCoachTyping {
                            typingIndicator(scheme: scheme)
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .onAppear { scrollProxy = proxy }
                .onChange(of: messages.count) {
                    withAnimation {
                        proxy.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // Quick Replies
            if let lastCoachMessage = messages.last(where: { $0.sender == .coach }),
               let quickReplies = lastCoachMessage.quickReplies,
               !quickReplies.isEmpty,
               messages.last?.sender == .coach {
                quickRepliesBar(replies: quickReplies, scheme: scheme)
            }

            // Input Bar
            inputBar(scheme: scheme)
        }
        .background(theme.background(for: theme.effectiveScheme).ignoresSafeArea())
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        messages = CoachView.initialMessages
                    } label: {
                        Label("New Session", systemImage: "plus.bubble")
                    }
                    Button {
                        // Export conversation
                    } label: {
                        Label("Export Chat", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }
        }
        .sheet(isPresented: $showVoiceMemo) {
            voiceMemoSheet(scheme: theme.effectiveScheme)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Coach Header

    @ViewBuilder
    private func coachHeader(scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ResonanceColors.goldPrimary.opacity(0.3),
                                ResonanceColors.green800.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }

            VStack(spacing: 4) {
                Text("Luminous Coach")
                    .font(.headline)
                    .foregroundStyle(ResonanceColors.text(for: scheme))
                Text("Your attachment healing companion")
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }

            Divider()
                .overlay(ResonanceColors.goldPrimary.opacity(0.2))
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Message Bubble

    @ViewBuilder
    private func messageBubble(message: CoachMessage, scheme: ColorScheme) -> some View {
        let isUser = message.sender == .user
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 48) }

            if !isUser {
                // Coach avatar
                ZStack {
                    Circle()
                        .fill(ResonanceColors.goldPrimary.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Message content based on type
                Group {
                    switch message.type {
                    case .text:
                        textBubbleContent(message: message, isUser: isUser, scheme: scheme)
                    case .voiceMemo:
                        voiceMemoBubble(message: message, isUser: isUser, scheme: scheme)
                    case .exerciseCard:
                        exerciseCardBubble(message: message, scheme: scheme)
                    case .meditationCard:
                        meditationCardBubble(message: message, scheme: scheme)
                    case .insightCard:
                        insightCardBubble(message: message, scheme: scheme)
                    case .journalReference:
                        journalReferenceBubble(message: message, scheme: scheme)
                    case .quickReplies:
                        textBubbleContent(message: message, isUser: isUser, scheme: scheme)
                    }
                }

                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme).opacity(0.6))
            }

            if !isUser { Spacer(minLength: 48) }
        }
    }

    @ViewBuilder
    private func textBubbleContent(message: CoachMessage, isUser: Bool, scheme: ColorScheme) -> some View {
        Text(message.text)
            .font(.body)
            .foregroundStyle(isUser ? .white : ResonanceColors.text(for: scheme))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isUser
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [ResonanceColors.goldPrimary, ResonanceColors.goldDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(ResonanceColors.surface(for: scheme))
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: isUser ? 16 : 4,
                    bottomTrailingRadius: isUser ? 4 : 16,
                    topTrailingRadius: 16
                )
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private func voiceMemoBubble(message: CoachMessage, isUser: Bool, scheme: ColorScheme) -> some View {
        HStack(spacing: 10) {
            Button {
                // Play voice memo
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isUser ? .white : ResonanceColors.goldPrimary)
            }
            // Waveform placeholder
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isUser ? .white.opacity(0.7) : ResonanceColors.goldPrimary.opacity(0.5))
                        .frame(width: 2.5, height: CGFloat.random(in: 4...20))
                }
            }
            Text("0:12")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(isUser ? .white.opacity(0.7) : ResonanceColors.textSecondary(for: scheme))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            isUser
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: [ResonanceColors.goldPrimary, ResonanceColors.goldDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : AnyShapeStyle(ResonanceColors.surface(for: scheme))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private func exerciseCardBubble(message: CoachMessage, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.mind.and.body")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("Exercise")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            Text(message.exerciseTitle ?? "Guided Exercise")
                .font(.headline)
                .foregroundStyle(ResonanceColors.text(for: scheme))
            Text(message.exerciseDescription ?? message.text)
                .font(.subheadline)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            if let duration = message.exerciseDurationMinutes {
                HStack {
                    Image(systemName: "clock")
                    Text("\(duration) minutes")
                }
                .font(.caption)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }
            Button {
                // Start exercise
            } label: {
                Text("Begin Exercise")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.green900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ResonanceColors.goldPrimary)
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ResonanceColors.surface(for: scheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ResonanceColors.goldPrimary.opacity(0.2), lineWidth: 1)
                )
        )
        .frame(maxWidth: 280)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private func meditationCardBubble(message: CoachMessage, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wind")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("Meditation")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            Text(message.meditationTitle ?? "Guided Meditation")
                .font(.headline)
                .foregroundStyle(ResonanceColors.text(for: scheme))
            Text(message.text)
                .font(.subheadline)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            if let duration = message.meditationDurationMinutes {
                Label("\(duration) minutes", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }
            Button {
                // Start meditation
            } label: {
                Text("Start Meditation")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.green900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ResonanceColors.goldPrimary)
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ResonanceColors.surface(for: scheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ResonanceColors.goldPrimary.opacity(0.2), lineWidth: 1)
                )
        )
        .frame(maxWidth: 280)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private func insightCardBubble(message: CoachMessage, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("Insight")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            Text(message.text)
                .font(.body.italic().leading(.loose))
                .foregroundStyle(ResonanceColors.text(for: scheme))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            ResonanceColors.goldPrimary.opacity(0.08),
                            ResonanceColors.surface(for: scheme)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ResonanceColors.goldPrimary.opacity(0.25), lineWidth: 1)
                )
        )
        .frame(maxWidth: 280)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    @ViewBuilder
    private func journalReferenceBubble(message: CoachMessage, scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundStyle(ResonanceColors.goldPrimary)
                Text("Journal Reference")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }
            Text(message.text)
                .font(.body)
                .foregroundStyle(ResonanceColors.text(for: scheme))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ResonanceColors.surface(for: scheme))
        )
        .frame(maxWidth: 280)
    }

    // MARK: - Typing Indicator

    @ViewBuilder
    private func typingIndicator(scheme: ColorScheme) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(ResonanceColors.goldPrimary.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: "leaf.fill")
                    .font(.caption)
                    .foregroundStyle(ResonanceColors.goldPrimary)
            }

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(ResonanceColors.textSecondary(for: scheme))
                        .frame(width: 7, height: 7)
                        .offset(y: typingDotOffset(index: index))
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                            value: isCoachTyping
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ResonanceColors.surface(for: scheme))
            )

            Spacer()
        }
    }

    private func typingDotOffset(index: Int) -> CGFloat {
        isCoachTyping ? -4 : 0
    }

    // MARK: - Quick Replies

    @ViewBuilder
    private func quickRepliesBar(replies: [String], scheme: ColorScheme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(replies, id: \.self) { reply in
                    Button {
                        sendMessage(reply)
                    } label: {
                        Text(reply)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(ResonanceColors.goldPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(ResonanceColors.goldPrimary.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(ResonanceColors.goldPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
    }

    // MARK: - Input Bar

    @ViewBuilder
    private func inputBar(scheme: ColorScheme) -> some View {
        HStack(spacing: 10) {
            // Voice memo button
            Button {
                showVoiceMemo = true
            } label: {
                Image(systemName: "mic.fill")
                    .font(.body)
                    .foregroundStyle(ResonanceColors.goldPrimary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(ResonanceColors.goldPrimary.opacity(0.1))
                    )
            }

            // Text input
            HStack(spacing: 8) {
                TextField("Message your coach...", text: $inputText, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .onSubmit {
                        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            sendMessage(inputText)
                        }
                    }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ResonanceColors.surface(for: scheme))
            )

            // Send button
            Button {
                sendMessage(inputText)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? ResonanceColors.textSecondary(for: scheme).opacity(0.3)
                            : ResonanceColors.goldPrimary
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Divider()
                        .overlay(ResonanceColors.goldPrimary.opacity(0.1))
                }
        )
    }

    // MARK: - Voice Memo Sheet

    @ViewBuilder
    private func voiceMemoSheet(scheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            Text("Voice Memo")
                .font(.headline)
                .foregroundStyle(ResonanceColors.text(for: scheme))

            Text(formatDuration(memoDuration))
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundStyle(isRecordingMemo ? .red : ResonanceColors.text(for: scheme))

            HStack(spacing: 40) {
                Button {
                    stopMemoRecording()
                    memoDuration = 0
                    showVoiceMemo = false
                } label: {
                    Text("Cancel")
                        .font(.body)
                        .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                }

                Button {
                    if isRecordingMemo {
                        stopMemoRecording()
                    } else {
                        startMemoRecording()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isRecordingMemo ? .red.opacity(0.15) : ResonanceColors.goldPrimary.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Circle()
                            .fill(isRecordingMemo ? .red : ResonanceColors.goldPrimary)
                            .frame(width: 50, height: 50)
                        if isRecordingMemo {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.white)
                                .frame(width: 18, height: 18)
                        } else {
                            Image(systemName: "mic.fill")
                                .foregroundStyle(.white)
                        }
                    }
                }

                Button {
                    stopMemoRecording()
                    sendVoiceMemo()
                    showVoiceMemo = false
                } label: {
                    Text("Send")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(ResonanceColors.goldPrimary)
                }
                .opacity(memoDuration > 0 && !isRecordingMemo ? 1 : 0.3)
                .disabled(memoDuration == 0 || isRecordingMemo)
            }
        }
        .padding(24)
    }

    // MARK: - Actions

    private func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = CoachMessage(sender: .user, text: trimmed)
        messages.append(userMessage)
        inputText = ""

        // Simulate coach typing
        isCoachTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isCoachTyping = false
            let response = generateCoachResponse(to: trimmed)
            messages.append(response)
            profile.totalCoachSessions += 1
        }
    }

    private func sendVoiceMemo() {
        let message = CoachMessage(
            sender: .user,
            type: .voiceMemo,
            text: "Voice memo",
            voiceURL: memoURL
        )
        messages.append(message)
        memoDuration = 0

        isCoachTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isCoachTyping = false
            let response = CoachMessage(
                sender: .coach,
                text: "Thank you for sharing that voice note. I can hear the emotion in your words. Let me reflect on what you shared — it takes courage to voice our inner experiences aloud. What feeling was strongest as you were speaking?",
                quickReplies: ["Vulnerability", "Relief", "Uncertainty", "Hope"]
            )
            messages.append(response)
        }
    }

    private func generateCoachResponse(to userText: String) -> CoachMessage {
        let lowered = userText.lowercased()

        if lowered.contains("anxious") || lowered.contains("worry") || lowered.contains("scared") {
            return CoachMessage(
                sender: .coach,
                type: .quickReplies,
                text: "I hear you, and those anxious feelings are valid. Anxiety in relationships often stems from early experiences where our needs for closeness were not consistently met. Your nervous system learned to stay vigilant. The beautiful thing is that awareness is the first step toward rewiring these patterns. Would you like to try a grounding exercise right now, or would you prefer to explore what triggered this feeling?",
                quickReplies: ["Try a grounding exercise", "Explore the trigger", "Tell me about anxious attachment", "I just need to be heard"]
            )
        }

        if lowered.contains("avoidant") || lowered.contains("distance") || lowered.contains("space") {
            return CoachMessage(
                sender: .coach,
                type: .quickReplies,
                text: "Needing space is not a flaw — it is often a learned response that once protected you. Avoidant patterns develop when closeness felt unsafe. Your independence is a strength, and we can work on expanding your comfort with vulnerability at your own pace. What does 'too close' feel like for you?",
                quickReplies: ["It feels suffocating", "I lose myself", "I am not sure", "Help me understand my pattern"]
            )
        }

        if lowered.contains("exercise") || lowered.contains("practice") || lowered.contains("try") {
            return CoachMessage(
                sender: .coach,
                type: .exerciseCard,
                text: "This exercise helps you build awareness of your attachment responses in real-time.",
                exerciseTitle: "Body Scan for Attachment Triggers",
                exerciseDescription: "Close your eyes and bring to mind a recent moment of connection or disconnection. Notice where in your body you feel it. Is there tension? Warmth? Numbness? Simply observe without judgment for five minutes.",
                exerciseDurationMinutes: 5,
                quickReplies: nil
            )
        }

        if lowered.contains("meditat") || lowered.contains("calm") || lowered.contains("breath") {
            return CoachMessage(
                sender: .coach,
                type: .meditationCard,
                text: "This meditation is designed to activate your vagus nerve and create a felt sense of safety in your body.",
                meditationTitle: "Safe Harbor Meditation",
                meditationDurationMinutes: 10,
                quickReplies: nil
            )
        }

        if lowered.contains("insight") || lowered.contains("learn") || lowered.contains("teach") {
            return CoachMessage(
                sender: .coach,
                type: .insightCard,
                text: "Every attachment pattern you carry was once a brilliant adaptation. Your psyche found the best possible way to stay connected to your caregivers given what was available. Now, as an adult, you have the power to choose new patterns — not because the old ones were wrong, but because you deserve connections that truly nourish you.",
                quickReplies: nil
            )
        }

        // Default thoughtful responses
        let responses = [
            CoachMessage(
                sender: .coach,
                type: .quickReplies,
                text: "Thank you for sharing that with me. It sounds like you are doing important inner work. Attachment healing is not about becoming a different person — it is about becoming more fully yourself, with the freedom to connect authentically. What would it feel like to trust that you are enough, exactly as you are right now?",
                quickReplies: ["That feels scary", "I want to believe it", "Tell me more", "Let me journal about this"]
            ),
            CoachMessage(
                sender: .coach,
                type: .quickReplies,
                text: "I appreciate you being open with me. What you are describing touches on one of the core aspects of attachment work: learning to hold space for both your need for connection and your need for autonomy. Neither need is wrong. Both deserve to be honored. How has this been showing up in your relationships lately?",
                quickReplies: ["In my romantic relationship", "With my family", "With friends", "With myself"]
            ),
            CoachMessage(
                sender: .coach,
                type: .quickReplies,
                text: "You are showing real self-awareness here. The fact that you can notice and name these patterns means your prefrontal cortex is coming online in moments that used to be purely reactive. That is genuine neurological change happening in real time. What would you like to explore next?",
                quickReplies: ["A breathing exercise", "More about my pattern", "Journal prompt", "Read about this"]
            ),
        ]

        let dayIndex = Calendar.current.ordinality(of: .second, in: .day, for: Date()) ?? 0
        return responses[dayIndex % responses.count]
    }

    // MARK: - Recording Helpers

    private func startMemoRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch { return }

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("coach_memo_\(UUID().uuidString).m4a")
        memoURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            memoRecorder = try AVAudioRecorder(url: url, settings: settings)
            memoRecorder?.record()
            isRecordingMemo = true
            memoDuration = 0
            memoTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                memoDuration += 0.1
            }
        } catch {
            isRecordingMemo = false
        }
    }

    private func stopMemoRecording() {
        memoRecorder?.stop()
        isRecordingMemo = false
        memoTimer?.invalidate()
        memoTimer = nil
    }

    private func formatDuration(_ d: TimeInterval) -> String {
        let m = Int(d) / 60
        let s = Int(d) % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: - Initial Messages

    static let initialMessages: [CoachMessage] = [
        CoachMessage(
            sender: .coach,
            text: "Welcome to your safe space. I am your Luminous attachment coach, here to support your journey toward secure, fulfilling connections. Everything you share here is held with compassion and without judgment."
        ),
        CoachMessage(
            sender: .coach,
            type: .insightCard,
            text: "Remember: Your attachment style is not who you are — it is what you learned. And what was learned can be gently, lovingly unlearned."
        ),
        CoachMessage(
            sender: .coach,
            type: .quickReplies,
            text: "What brings you here today? I am ready to listen.",
            quickReplies: [
                "I feel anxious in relationships",
                "I tend to push people away",
                "I want to understand my patterns",
                "I need a calming exercise"
            ]
        ),
    ]
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CoachView()
    }
    .environment(ThemeManager())
    .environment(UserProfile())
}
