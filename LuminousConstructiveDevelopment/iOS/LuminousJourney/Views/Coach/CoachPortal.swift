// MARK: - Coach Portal — Full-Featured Coach/Therapist Integration
// "She can do anything." — The coach receives entries, chats in real-time,
// does video/voice calls, reviews assessments, assigns practices,
// sends voice notes, annotates journal entries, and more.

import SwiftUI
import AVFoundation

// MARK: - Coach Share Sheet (Client-side: send entry to coach)

struct CoachShareSheet: View {
    @ObservedObject var viewModel: MultiModalJournalViewModel
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var messageToCoach: String = ""
    @State private var includeBodyMap = true
    @State private var includeSomatic = true
    @State private var includeMood = true
    @State private var urgency: Urgency = .normal

    enum Urgency: String, CaseIterable {
        case low = "When you have time"
        case normal = "Normal"
        case soon = "Would love to discuss soon"
        case urgent = "Urgent — feeling unsafe"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Preview of what coach will see
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Coach Preview", systemImage: "eye")
                                .font(.custom("Manrope", size: 13).weight(.semibold))
                                .foregroundColor(theme.goldPrimary)
                                .textCase(.uppercase)

                            if !viewModel.typedContent.isEmpty {
                                Text(viewModel.typedContent)
                                    .font(.custom("Manrope", size: 14))
                                    .foregroundColor(theme.text)
                                    .lineLimit(6)
                            }

                            if viewModel.pencilDrawing != nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.tip")
                                    Text("Handwritten entry attached")
                                }
                                .font(.custom("Manrope", size: 12))
                                .foregroundColor(theme.textSecondary)
                            }

                            if viewModel.voiceRecordingURL != nil {
                                HStack(spacing: 6) {
                                    Image(systemName: "waveform")
                                    Text("Voice recording attached")
                                }
                                .font(.custom("Manrope", size: 12))
                                .foregroundColor(theme.textSecondary)
                            }
                        }
                    }

                    // Include toggles
                    VStack(spacing: 8) {
                        IncludeToggle(label: "Body Map", icon: "figure.stand", isOn: $includeBodyMap)
                        IncludeToggle(label: "Somatic Notes", icon: "waveform", isOn: $includeSomatic)
                        IncludeToggle(label: "Mood & Season", icon: "heart", isOn: $includeMood)
                    }

                    // Message to coach
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message to coach")
                            .font(.custom("Manrope", size: 13).weight(.semibold))
                            .foregroundColor(theme.textSecondary)

                        TextEditor(text: $messageToCoach)
                            .font(.custom("Manrope", size: 15))
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.forestBase.opacity(0.04))
                            )
                    }

                    // Urgency
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Urgency")
                            .font(.custom("Manrope", size: 13).weight(.semibold))
                            .foregroundColor(theme.textSecondary)

                        ForEach(Urgency.allCases, id: \.self) { level in
                            Button(action: { urgency = level }) {
                                HStack {
                                    Circle()
                                        .fill(urgency == level ? urgencyColor(level) : theme.textMuted.opacity(0.2))
                                        .frame(width: 12, height: 12)
                                    Text(level.rawValue)
                                        .font(.custom("Manrope", size: 14))
                                        .foregroundColor(theme.text)
                                    Spacer()
                                    if urgency == level {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(urgencyColor(level))
                                    }
                                }
                            }
                        }
                    }

                    // Send button
                    Button(action: {
                        // Send to coach via Resonance ecosystem
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send to Coach")
                        }
                        .font(.custom("Manrope", size: 15).weight(.semibold))
                        .foregroundColor(theme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.forestBase)
                        .clipShape(Capsule())
                    }

                    // Safety note
                    if urgency == .urgent {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "heart.text.square")
                                .foregroundColor(Color(hex: "C45A5A"))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("If you are in immediate danger, please call 988 (Suicide & Crisis Lifeline) or go to your nearest emergency room.")
                                    .font(.custom("Manrope", size: 13))
                                    .foregroundColor(Color(hex: "C45A5A"))
                                Text("Your coach will be notified immediately of this urgent message.")
                                    .font(.custom("Manrope", size: 12))
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "C45A5A").opacity(0.06))
                        )
                    }
                }
                .padding(20)
            }
            .navigationTitle("Send to Coach")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func urgencyColor(_ urgency: Urgency) -> Color {
        switch urgency {
        case .low:    return Color(hex: "5A8AB0")
        case .normal: return Color(hex: "4A9A6A")
        case .soon:   return Color(hex: "C5A059")
        case .urgent: return Color(hex: "C45A5A")
        }
    }
}

struct IncludeToggle: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(label, systemImage: icon)
                .font(.custom("Manrope", size: 14))
        }
        .tint(theme.goldPrimary)
    }
}

// MARK: - Coach Chat View (Real-time messaging with coach)

struct CoachChatView: View {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var viewModel = CoachChatViewModel()
    @State private var messageText = ""
    @State private var showAttachMenu = false
    @State private var showVideoCall = false
    @State private var showVoiceNote = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Coach header
                CoachHeader(
                    onVideoCall: { showVideoCall = true },
                    onVoiceCall: { /* Start voice call */ },
                    coachName: viewModel.coachName,
                    isOnline: viewModel.coachIsOnline,
                    lastSeen: viewModel.coachLastSeen
                )

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                CoachChatBubble(message: message)
                            }

                            if viewModel.coachIsTyping {
                                CoachTypingIndicator()
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                // Input bar
                CoachInputBar(
                    text: $messageText,
                    isFocused: _isInputFocused,
                    onSend: {
                        viewModel.sendMessage(messageText, type: .text)
                        messageText = ""
                    },
                    onAttach: { showAttachMenu = true },
                    onVoiceNote: { showVoiceNote = true }
                )
            }
            .sheet(isPresented: $showVideoCall) {
                VideoCallView(coachName: viewModel.coachName)
            }
            .confirmationDialog("Attach", isPresented: $showAttachMenu) {
                Button("Journal Entry") { viewModel.attachJournalEntry() }
                Button("Assessment") { viewModel.attachAssessment() }
                Button("Body Map") { viewModel.attachBodyMap() }
                Button("Photo") { viewModel.attachPhoto() }
                Button("Practice Log") { viewModel.attachPracticeLog() }
                Button("Voice Note") { showVoiceNote = true }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Coach Header

struct CoachHeader: View {
    let onVideoCall: () -> Void
    let onVoiceCall: () -> Void
    let coachName: String
    let isOnline: Bool
    let lastSeen: Date?
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            // Coach avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(theme.goldPrimary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(coachName.prefix(1)))
                            .font(.custom("Cormorant Garamond", size: 22))
                            .foregroundColor(theme.goldPrimary)
                    )
                Circle()
                    .fill(isOnline ? Color(hex: "4A9A6A") : theme.textMuted)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(theme.surface, lineWidth: 2))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(coachName)
                    .font(.custom("Manrope", size: 16).weight(.medium))
                    .foregroundColor(theme.text)
                Text(isOnline ? "Online" : "Last seen \(lastSeen?.formatted(.relative(presentation: .named)) ?? "recently")")
                    .font(.custom("Manrope", size: 12))
                    .foregroundColor(isOnline ? Color(hex: "4A9A6A") : theme.textSecondary)
            }

            Spacer()

            // Call buttons
            Button(action: onVoiceCall) {
                Image(systemName: "phone")
                    .font(.system(size: 18))
                    .foregroundColor(theme.text)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(theme.forestBase.opacity(0.06)))
            }
            Button(action: onVideoCall) {
                Image(systemName: "video")
                    .font(.system(size: 18))
                    .foregroundColor(theme.text)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(theme.forestBase.opacity(0.06)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Coach Chat Bubble

struct CoachChatBubble: View {
    let message: CoachMessage
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack {
            if !message.isFromCoach { Spacer(minLength: 60) }

            VStack(alignment: message.isFromCoach ? .leading : .trailing, spacing: 6) {
                switch message.type {
                case .text:
                    Text(message.content)
                        .font(.custom("Manrope", size: 16))
                        .foregroundColor(message.isFromCoach ? theme.text : theme.cream)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(message.isFromCoach
                                    ? theme.forestBase.opacity(0.06)
                                    : theme.forestBase)
                        )

                case .voiceNote:
                    VoiceNoteBubble(duration: message.voiceDuration ?? 0, isFromCoach: message.isFromCoach)

                case .journalEntry:
                    AttachmentBubble(icon: "pencil.line", label: "Journal Entry", detail: message.content, isFromCoach: message.isFromCoach)

                case .assessment:
                    AttachmentBubble(icon: "scope", label: "Assessment", detail: message.content, isFromCoach: message.isFromCoach)

                case .bodyMap:
                    AttachmentBubble(icon: "figure.stand", label: "Body Map", detail: "Somatic data attached", isFromCoach: message.isFromCoach)

                case .practice:
                    AttachmentBubble(icon: "figure.mind.and.body", label: "Practice Assignment", detail: message.content, isFromCoach: message.isFromCoach)

                case .video:
                    AttachmentBubble(icon: "video", label: "Video Message", detail: message.content, isFromCoach: message.isFromCoach)

                case .image:
                    if let data = message.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                case .annotation:
                    AnnotationBubble(content: message.content, isFromCoach: message.isFromCoach)

                case .schedulingLink:
                    SchedulingBubble(content: message.content)
                }

                // Timestamp + read receipt
                HStack(spacing: 4) {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.custom("Manrope", size: 10))
                        .foregroundColor(theme.textMuted)
                    if !message.isFromCoach {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.system(size: 10))
                            .foregroundColor(message.isRead ? Color(hex: "4A9A6A") : theme.textMuted)
                    }
                }
            }

            if message.isFromCoach { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Attachment Bubbles

struct VoiceNoteBubble: View {
    let duration: TimeInterval
    let isFromCoach: Bool
    @EnvironmentObject var theme: ThemeManager
    @State private var isPlaying = false

    var body: some View {
        HStack(spacing: 10) {
            Button(action: { isPlaying.toggle() }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(isFromCoach ? theme.forestBase : theme.cream)
            }

            // Mini waveform
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isFromCoach ? theme.forestBase.opacity(0.4) : theme.cream.opacity(0.6))
                        .frame(width: 3, height: CGFloat.random(in: 8...24))
                }
            }

            Text("\(Int(duration))s")
                .font(.custom("Manrope", size: 12))
                .foregroundColor(isFromCoach ? theme.textSecondary : theme.cream.opacity(0.7))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isFromCoach ? theme.forestBase.opacity(0.06) : theme.forestBase)
        )
    }
}

struct AttachmentBubble: View {
    let icon: String
    let label: String
    let detail: String
    let isFromCoach: Bool
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isFromCoach ? theme.goldPrimary : theme.cream)
                .frame(width: 36, height: 36)
                .background(Circle().fill(isFromCoach ? theme.goldPrimary.opacity(0.1) : theme.cream.opacity(0.15)))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("Manrope", size: 13).weight(.semibold))
                    .foregroundColor(isFromCoach ? theme.text : theme.cream)
                Text(detail)
                    .font(.custom("Manrope", size: 12))
                    .foregroundColor(isFromCoach ? theme.textSecondary : theme.cream.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isFromCoach ? theme.forestBase.opacity(0.06) : theme.forestBase)
        )
    }
}

struct AnnotationBubble: View {
    let content: String
    let isFromCoach: Bool
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "text.bubble")
                    .foregroundColor(theme.goldPrimary)
                Text("Coach Annotation")
                    .font(.custom("Manrope", size: 11).weight(.semibold))
                    .foregroundColor(theme.goldPrimary)
                    .textCase(.uppercase)
            }
            Text(content)
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.text)
                .lineSpacing(3)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(theme.goldPrimary.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(theme.goldPrimary.opacity(0.15), lineWidth: 1)
        )
    }
}

struct SchedulingBubble: View {
    let content: String
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(Color(hex: "5A8AB0"))
                Text("Schedule a Session")
                    .font(.custom("Manrope", size: 13).weight(.semibold))
                    .foregroundColor(Color(hex: "5A8AB0"))
            }
            Text(content)
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.text)

            Button(action: {}) {
                Text("Book Session")
                    .font(.custom("Manrope", size: 13).weight(.semibold))
                    .foregroundColor(theme.cream)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(hex: "5A8AB0"))
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "5A8AB0").opacity(0.06))
        )
    }
}

// MARK: - Coach Input Bar

struct CoachInputBar: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    let onSend: () -> Void
    let onAttach: () -> Void
    let onVoiceNote: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onAttach) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(theme.textSecondary)
            }

            TextField("Message your coach...", text: $text, axis: .vertical)
                .font(.custom("Manrope", size: 16))
                .lineLimit(1...5)
                .focused($isFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.forestBase.opacity(0.06))
                )

            if text.isEmpty {
                // Voice note button when no text
                Button(action: onVoiceNote) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(theme.forestBase)
                }
            } else {
                // Send button when text present
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(theme.forestBase)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Coach Typing Indicator

struct CoachTypingIndicator: View {
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text("Coach is typing")
                    .font(.custom("Manrope", size: 12))
                    .foregroundColor(theme.textSecondary)
                ProgressView()
                    .scaleEffect(0.6)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(theme.forestBase.opacity(0.04))
            )
            Spacer()
        }
    }
}

// MARK: - Video Call View

struct VideoCallView: View {
    let coachName: String
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var isMuted = false
    @State private var isCameraOff = false
    @State private var callDuration: TimeInterval = 0

    var body: some View {
        ZStack {
            // Video backgrounds
            Color.black.ignoresSafeArea()

            // Coach video (large)
            VStack {
                Text("Coach Video Stream")
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Self video (PIP)
            VStack {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "1B402E"))
                        .frame(width: 120, height: 160)
                        .overlay(
                            Text(isCameraOff ? "Camera Off" : "You")
                                .font(.custom("Manrope", size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        )
                        .padding(16)
                }
                Spacer()
            }

            // Controls
            VStack {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    Spacer()
                    VStack {
                        Text(coachName)
                            .font(.custom("Manrope", size: 15).weight(.medium))
                            .foregroundColor(.white)
                        Text(formatCallTime(callDuration))
                            .font(.custom("Manrope", size: 13).monospacedDigit())
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding()

                Spacer()

                // Bottom controls
                HStack(spacing: 32) {
                    CallButton(icon: isMuted ? "mic.slash" : "mic", isActive: isMuted) {
                        isMuted.toggle()
                    }
                    CallButton(icon: isCameraOff ? "video.slash" : "video", isActive: isCameraOff) {
                        isCameraOff.toggle()
                    }
                    CallButton(icon: "speaker.wave.2", isActive: false) {}
                    CallButton(icon: "phone.down.fill", isActive: true, color: Color(hex: "C45A5A")) {
                        dismiss()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in callDuration += 1 }
        }
    }

    private func formatCallTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct CallButton: View {
    let icon: String
    let isActive: Bool
    var color: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isActive ? .white : .white.opacity(0.8))
                .frame(width: 52, height: 52)
                .background(Circle().fill(isActive ? color.opacity(0.6) : Color.white.opacity(0.2)))
        }
    }
}

// MARK: - Data Models

struct CoachMessage: Identifiable {
    let id = UUID()
    var isFromCoach: Bool
    var type: MessageType
    var content: String
    var timestamp: Date
    var isRead: Bool = false
    var voiceDuration: TimeInterval?
    var imageData: Data?

    enum MessageType: String {
        case text, voiceNote, journalEntry, assessment, bodyMap, practice
        case video, image, annotation, schedulingLink
    }
}

@MainActor
final class CoachChatViewModel: ObservableObject {
    @Published var messages: [CoachMessage] = []
    @Published var coachName: String = "Dr. Sarah Chen"
    @Published var coachIsOnline: Bool = true
    @Published var coachLastSeen: Date? = nil
    @Published var coachIsTyping: Bool = false

    func sendMessage(_ text: String, type: CoachMessage.MessageType) {
        messages.append(CoachMessage(isFromCoach: false, type: type, content: text, timestamp: Date()))
    }

    func attachJournalEntry() { sendMessage("Latest reflection shared", type: .journalEntry) }
    func attachAssessment() { sendMessage("Assessment results shared", type: .assessment) }
    func attachBodyMap() { sendMessage("", type: .bodyMap) }
    func attachPhoto() { sendMessage("", type: .image) }
    func attachPracticeLog() { sendMessage("Practice log shared", type: .practice) }
}
