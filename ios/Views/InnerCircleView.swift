// InnerCircleView.swift
// Resonance UX — Inner Circle
//
// Intentional communication. No urgency, no anxiety.
// Async-first messaging with voice, presence awareness,
// and deep respect for each person's rhythm.

import SwiftUI

// MARK: - Intentional Status

enum IntentionalStatus: String, CaseIterable, Identifiable, Codable {
    case deepWork     = "Deep work phase"
    case recharging   = "Recharging"
    case openConnect  = "Open to connect"
    case inFlow       = "In flow"
    case offline      = "Offline — resting"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .deepWork:    return "eye.slash"
        case .recharging:  return "moon.zzz"
        case .openConnect: return "hand.wave"
        case .inFlow:      return "wind"
        case .offline:     return "leaf"
        }
    }

    var color: Color {
        switch self {
        case .deepWork:    return Color(hex: 0x0A1C14)
        case .recharging:  return Color(hex: 0x5C7065)
        case .openConnect: return Color(hex: 0xC5A059)
        case .inFlow:      return Color(hex: 0x122E21)
        case .offline:     return Color(hex: 0x5C7065).opacity(0.5)
        }
    }

    var canInterrupt: Bool {
        switch self {
        case .openConnect: return true
        case .inFlow:      return true
        default:           return false
        }
    }
}

// MARK: - Contact

struct CircleContact: Identifiable {
    let id = UUID()
    var name: String
    var initials: String
    var status: IntentionalStatus
    var lastMessage: String
    var lastMessageTime: Date
    var hasUnread: Bool = false
    var isInnerCircle: Bool = true
    var avatarGradient: [Color] = [Color(hex: 0x122E21), Color(hex: 0xC5A059)]
}

// MARK: - Message

struct CircleMessage: Identifiable {
    let id = UUID()
    var text: String?
    var isVoice: Bool = false
    var voiceDurationSeconds: Int = 0
    var isFromMe: Bool
    var timestamp: Date
    var isRead: Bool = true
}

// MARK: - Inner Circle View

struct InnerCircleView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest
    @EnvironmentObject private var appState: ResonanceAppState

    @State private var contacts = CircleContact.samples
    @State private var selectedContact: CircleContact?
    @State private var showStatusPicker = false
    @State private var myStatus: IntentionalStatus = .openConnect
    @State private var searchText = ""

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

    var body: some View {
        NavigationStack {
            ZStack {
                baseColor.ignoresSafeArea()

                if let contact = selectedContact {
                    ChatView(
                        contact: contact,
                        isDeepRest: isDeepRest,
                        onBack: { selectedContact = nil }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                } else {
                    contactListView
                        .transition(.opacity)
                }
            }
            .navigationTitle(selectedContact == nil ? "Inner Circle" : "")
            .navigationBarTitleDisplayMode(selectedContact == nil ? .large : .inline)
            .toolbar {
                if selectedContact == nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        statusButton
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Video call quick action
                        } label: {
                            Image(systemName: "video")
                                .foregroundColor(ResonanceTheme.Light.gold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showStatusPicker) {
                StatusPickerSheet(selectedStatus: $myStatus)
            }
        }
    }

    // MARK: - Status Button

    private var statusButton: some View {
        Button {
            showStatusPicker = true
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(myStatus.color)
                    .frame(width: 8, height: 8)

                Text(myStatus.rawValue)
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(mutedColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(surfaceColor)
                    .overlay(Capsule().stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle))
            )
        }
    }

    // MARK: - Contact List

    private var contactListView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Search
                HStack(spacing: ResonanceTheme.Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(mutedColor)
                    TextField("Search your circle", text: $searchText)
                        .font(ResonanceTheme.Typography.bodyMedium)
                }
                .padding(ResonanceTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .fill(surfaceColor)
                )
                .padding(.horizontal, ResonanceTheme.Spacing.md)
                .padding(.bottom, ResonanceTheme.Spacing.md)

                // Inner Circle section
                SectionHeader(title: "Inner Circle", icon: "heart.circle")
                    .padding(.horizontal, ResonanceTheme.Spacing.md)

                ForEach(filteredContacts.filter(\.isInnerCircle)) { contact in
                    ContactRow(contact: contact, isDeepRest: isDeepRest) {
                        withAnimation(ResonanceTheme.Animation.gentle) {
                            selectedContact = contact
                        }
                    }
                }

                // Extended Circle section
                SectionHeader(title: "Extended Circle", icon: "circle.hexagongrid")
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                    .padding(.top, ResonanceTheme.Spacing.md)

                ForEach(filteredContacts.filter { !$0.isInnerCircle }) { contact in
                    ContactRow(contact: contact, isDeepRest: isDeepRest) {
                        withAnimation(ResonanceTheme.Animation.gentle) {
                            selectedContact = contact
                        }
                    }
                }
            }
            .padding(.bottom, ResonanceTheme.Spacing.xxxl)
        }
    }

    private var filteredContacts: [CircleContact] {
        if searchText.isEmpty { return contacts }
        return contacts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.status.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    @Environment(\.isDeepRestMode) private var isDeepRest

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title.uppercased())
                .font(ResonanceTheme.Typography.overline)
                .tracking(1.5)
        }
        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: CircleContact
    let isDeepRest: Bool
    let onTap: () -> Void

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }
    private var mutedColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: ResonanceTheme.Spacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: contact.avatarGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Text(contact.initials)
                        .font(ResonanceTheme.Typography.sans(16, weight: .semibold))
                        .foregroundColor(.white)

                    // Status dot
                    Circle()
                        .fill(contact.status.color)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle().stroke(isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base, lineWidth: 2)
                        )
                        .offset(x: 17, y: 17)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(contact.name)
                            .font(ResonanceTheme.Typography.bodyLarge)
                            .fontWeight(.medium)
                            .foregroundColor(textColor)

                        Spacer()

                        Text(contact.lastMessageTime.formatted(date: .omitted, time: .shortened))
                            .font(ResonanceTheme.Typography.caption)
                            .foregroundColor(mutedColor)
                    }

                    IntentionalStatusBadge(status: contact.status, compact: true)

                    Text(contact.lastMessage)
                        .font(ResonanceTheme.Typography.bodySmall)
                        .foregroundColor(mutedColor)
                        .lineLimit(1)
                }

                if contact.hasUnread {
                    Circle()
                        .fill(ResonanceTheme.Light.gold)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, ResonanceTheme.Spacing.md)
            .padding(.vertical, ResonanceTheme.Spacing.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chat View

struct ChatView: View {
    let contact: CircleContact
    let isDeepRest: Bool
    let onBack: () -> Void

    @State private var messages = CircleMessage.sampleConversation
    @State private var newMessageText = ""
    @State private var isRecordingVoice = false
    @State private var showVideoCall = false
    @State private var voiceRecordingTime: TimeInterval = 0

    private var textColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900
    }
    private var mutedColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted
    }
    private var surfaceColor: Color {
        isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface
    }

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            Divider().opacity(0.3)

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: ResonanceTheme.Spacing.md) {
                        // Non-intrusive delivery notice
                        if !contact.status.canInterrupt {
                            HStack(spacing: 6) {
                                Image(systemName: contact.status.icon)
                                    .font(.caption2)
                                Text("\(contact.name) is \(contact.status.rawValue.lowercased()). Messages will be delivered gently.")
                                    .font(ResonanceTheme.Typography.caption)
                            }
                            .foregroundColor(mutedColor)
                            .padding(ResonanceTheme.Spacing.sm)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.sm)
                                    .fill(contact.status.color.opacity(0.06))
                            )
                            .padding(.horizontal, ResonanceTheme.Spacing.xl)
                        }

                        ForEach(messages) { message in
                            MessageBubble(message: message, isDeepRest: isDeepRest)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                    .padding(.vertical, ResonanceTheme.Spacing.md)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider().opacity(0.3)
            messageComposer
        }
        .fullScreenCover(isPresented: $showVideoCall) {
            VideoCallView(contact: contact, isDeepRest: isDeepRest, onEnd: { showVideoCall = false })
        }
    }

    // MARK: - Chat Header

    private var chatHeader: some View {
        HStack(spacing: ResonanceTheme.Spacing.md) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(textColor)
            }

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: contact.avatarGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                Text(contact.initials)
                    .font(ResonanceTheme.Typography.sans(13, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(ResonanceTheme.Typography.headlineMed)
                    .foregroundColor(textColor)
                IntentionalStatusBadge(status: contact.status, compact: true)
            }

            Spacer()

            Button { showVideoCall = true } label: {
                Image(systemName: "video")
                    .font(.title3)
                    .foregroundColor(ResonanceTheme.Light.gold)
            }
        }
        .padding(.horizontal, ResonanceTheme.Spacing.md)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
    }

    // MARK: - Message Composer

    private var messageComposer: some View {
        HStack(spacing: ResonanceTheme.Spacing.sm) {
            // Voice message button
            Button {
                withAnimation(ResonanceTheme.Animation.gentle) {
                    isRecordingVoice.toggle()
                }
            } label: {
                Image(systemName: isRecordingVoice ? "stop.circle.fill" : "mic")
                    .font(.title3)
                    .foregroundColor(isRecordingVoice ? .red : mutedColor)
            }

            if isRecordingVoice {
                VoiceRecordingIndicator(elapsed: $voiceRecordingTime)
                    .transition(.scale.combined(with: .opacity))
            } else {
                TextField("Send a calm message...", text: $newMessageText)
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .padding(.horizontal, ResonanceTheme.Spacing.md)
                    .padding(.vertical, ResonanceTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                            .fill(surfaceColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                                    .stroke(isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle)
                            )
                    )
            }

            // Send
            if !newMessageText.isEmpty {
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(ResonanceTheme.Light.gold)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, ResonanceTheme.Spacing.md)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
        .animation(ResonanceTheme.Animation.gentle, value: newMessageText.isEmpty)
        .animation(ResonanceTheme.Animation.gentle, value: isRecordingVoice)
    }

    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        let message = CircleMessage(text: newMessageText, isFromMe: true, timestamp: Date())
        withAnimation(ResonanceTheme.Animation.gentle) {
            messages.append(message)
        }
        newMessageText = ""
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: CircleMessage
    let isDeepRest: Bool

    var body: some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 60) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                if message.isVoice {
                    voiceBubble
                } else if let text = message.text {
                    Text(text)
                        .font(ResonanceTheme.Typography.bodyMedium)
                        .foregroundColor(message.isFromMe ? .white : (isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900))
                        .padding(.horizontal, ResonanceTheme.Spacing.md)
                        .padding(.vertical, ResonanceTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                                .fill(message.isFromMe
                                    ? ResonanceTheme.Light.green800
                                    : (isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface))
                        )
                }

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
            }

            if !message.isFromMe { Spacer(minLength: 60) }
        }
    }

    private var voiceBubble: some View {
        HStack(spacing: ResonanceTheme.Spacing.sm) {
            Image(systemName: "play.fill")
                .font(.caption)

            WaveformView(barCount: 24, isAnimating: false)
                .frame(height: 28)
                .frame(maxWidth: 150)

            Text("\(message.voiceDurationSeconds)s")
                .font(ResonanceTheme.Typography.caption)
        }
        .foregroundColor(message.isFromMe ? .white : (isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900))
        .padding(.horizontal, ResonanceTheme.Spacing.md)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .fill(message.isFromMe
                    ? ResonanceTheme.Light.green800
                    : (isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface))
        )
    }
}

// MARK: - Voice Recording Indicator

struct VoiceRecordingIndicator: View {
    @Binding var elapsed: TimeInterval
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: ResonanceTheme.Spacing.sm) {
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .scaleEffect(pulseScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        pulseScale = 1.3
                    }
                }

            WaveformView(barCount: 32, isAnimating: true)
                .frame(height: 28)
                .frame(maxWidth: .infinity)

            Text(String(format: "%0.0fs", elapsed))
                .font(ResonanceTheme.Typography.caption)
                .monospacedDigit()
        }
        .padding(.horizontal, ResonanceTheme.Spacing.md)
        .padding(.vertical, ResonanceTheme.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: ResonanceTheme.Radius.lg)
                .fill(Color.red.opacity(0.08))
        )
    }
}

// MARK: - Video Call View

struct VideoCallView: View {
    let contact: CircleContact
    let isDeepRest: Bool
    let onEnd: () -> Void

    @State private var isMuted = false
    @State private var cameraOff = false
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // Background
            Color(hex: 0x05100B).ignoresSafeArea()

            // Simulated remote video
            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: contact.avatarGradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Text(contact.initials)
                        .font(ResonanceTheme.Typography.serif(48, weight: .light))
                        .foregroundColor(.white)
                }
                Text(contact.name)
                    .font(ResonanceTheme.Typography.headlineLarge)
                    .foregroundColor(.white)
                Text(formatDuration(elapsed))
                    .font(ResonanceTheme.Typography.bodyMedium)
                    .foregroundColor(.white.opacity(0.6))
                    .monospacedDigit()
                Spacer()
            }

            // Self preview (picture-in-picture)
            VStack {
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: ResonanceTheme.Radius.md)
                        .fill(Color(hex: 0x122E21))
                        .frame(width: 120, height: 160)
                        .overlay(
                            cameraOff
                            ? AnyView(Image(systemName: "video.slash").foregroundColor(.white.opacity(0.4)))
                            : AnyView(Text("You").font(ResonanceTheme.Typography.caption).foregroundColor(.white.opacity(0.5)))
                        )
                        .padding()
                }
                Spacer()
            }

            // Controls
            VStack {
                Spacer()

                HStack(spacing: ResonanceTheme.Spacing.xl) {
                    CallButton(icon: isMuted ? "mic.slash.fill" : "mic.fill", label: "Mute") {
                        isMuted.toggle()
                    }
                    CallButton(icon: cameraOff ? "video.slash.fill" : "video.fill", label: "Camera") {
                        cameraOff.toggle()
                    }
                    CallButton(icon: "phone.down.fill", label: "End", color: .red) {
                        timer?.invalidate()
                        onEnd()
                    }
                }
                .padding(.bottom, ResonanceTheme.Spacing.xxl)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsed += 1
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Call Button

struct CallButton: View {
    let icon: String
    let label: String
    var color: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Circle()
                    .fill(color == .red ? color : color.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color == .red ? .white : color)
                    )
                Text(label)
                    .font(ResonanceTheme.Typography.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Status Picker

struct StatusPickerSheet: View {
    @Binding var selectedStatus: IntentionalStatus
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(IntentionalStatus.allCases) { status in
                    Button {
                        selectedStatus = status
                        dismiss()
                    } label: {
                        HStack(spacing: ResonanceTheme.Spacing.md) {
                            Image(systemName: status.icon)
                                .foregroundColor(status.color)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(status.rawValue)
                                    .font(ResonanceTheme.Typography.bodyLarge)
                                Text(status.canInterrupt ? "Others may reach out" : "Messages held until you return")
                                    .font(ResonanceTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if status == selectedStatus {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ResonanceTheme.Light.gold)
                            }
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("Your Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ResonanceTheme.Light.gold)
                }
            }
        }
    }
}

// MARK: - Sample Data

extension CircleContact {
    static let samples: [CircleContact] = [
        CircleContact(name: "Maya Chen", initials: "MC", status: .openConnect,
                      lastMessage: "That breathwork session was transformative",
                      lastMessageTime: Calendar.current.date(byAdding: .minute, value: -22, to: Date())!,
                      hasUnread: true,
                      avatarGradient: [Color(hex: 0xC5A059), Color(hex: 0x122E21)]),
        CircleContact(name: "James Oliver", initials: "JO", status: .deepWork,
                      lastMessage: "I'll review the protocol later today",
                      lastMessageTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                      avatarGradient: [Color(hex: 0x0A1C14), Color(hex: 0x5C7065)]),
        CircleContact(name: "Sophia Reyes", initials: "SR", status: .recharging,
                      lastMessage: "Voice message (0:42)",
                      lastMessageTime: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
                      avatarGradient: [Color(hex: 0x122E21), Color(hex: 0xC5A059)]),
        CircleContact(name: "Eli Nakamura", initials: "EN", status: .inFlow,
                      lastMessage: "The canvas piece is nearly done",
                      lastMessageTime: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
                      avatarGradient: [Color(hex: 0x5C7065), Color(hex: 0x0A1C14)]),
        CircleContact(name: "Dr. Amara Osei", initials: "AO", status: .openConnect,
                      lastMessage: "Patient outcomes looking positive this quarter",
                      lastMessageTime: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                      isInnerCircle: false,
                      avatarGradient: [Color(hex: 0x0A1C14), Color(hex: 0xC5A059)]),
        CircleContact(name: "River Patel", initials: "RP", status: .offline,
                      lastMessage: "See you at the retreat next week",
                      lastMessageTime: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                      isInnerCircle: false,
                      avatarGradient: [Color(hex: 0x122E21), Color(hex: 0x5C7065)]),
    ]
}

extension CircleMessage {
    static let sampleConversation: [CircleMessage] = [
        CircleMessage(text: "Have you tried the new descent phase meditation?", isFromMe: false,
                      timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date())!),
        CircleMessage(text: "Not yet — I've been deep in writing all morning. The flow was really strong today.", isFromMe: true,
                      timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!),
        CircleMessage(text: nil, isVoice: true, voiceDurationSeconds: 42, isFromMe: false,
                      timestamp: Calendar.current.date(byAdding: .minute, value: -90, to: Date())!),
        CircleMessage(text: "That breathwork session was transformative. I felt the nervous system shift around minute 6.", isFromMe: false,
                      timestamp: Calendar.current.date(byAdding: .minute, value: -22, to: Date())!),
        CircleMessage(text: "Beautiful. I'll try it during my rest phase tonight.", isFromMe: true,
                      timestamp: Calendar.current.date(byAdding: .minute, value: -18, to: Date())!),
    ]
}
