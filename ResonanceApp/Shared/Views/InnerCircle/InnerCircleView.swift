// InnerCircleView.swift
// Resonance — Design for the Exhale
//
// Inner Circle — intentional communication. Presence over productivity.

import SwiftUI

struct InnerCircleView: View {
    let theme: ResonanceTheme
    @State private var selectedContact: Contact?
    @State private var showConversation = false

    var body: some View {
        Group {
            if showConversation, let contact = selectedContact {
                ConversationView(
                    contact: contact,
                    theme: theme,
                    onBack: {
                        withAnimation(.easeOut(duration: 0.35)) {
                            showConversation = false
                        }
                    }
                )
                .transition(.resonanceSlideTrailing)
            } else {
                contactsList
                    .transition(.resonanceFade)
            }
        }
        .animation(.easeOut(duration: 0.35), value: showConversation)
    }

    private var contactsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: ResonanceTheme.spacingL) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inner Circle")
                        .font(ResonanceFont.displaySmall)
                        .foregroundStyle(theme.textMain)

                    Text("Those who matter most")
                        .font(ResonanceFont.intention)
                        .italic()
                        .foregroundStyle(theme.textMuted)
                }
                .fadeIn()

                // Contacts
                LazyVStack(spacing: ResonanceTheme.spacingS) {
                    ForEach(Array(Contact.sampleContacts.enumerated()), id: \.element.id) { index, contact in
                        ContactCardView(contact: contact, theme: theme) {
                            selectedContact = contact
                            withAnimation(.easeOut(duration: 0.35)) {
                                showConversation = true
                            }
                        }
                        .fadeIn(delay: Double(index) * 0.08)
                    }
                }
            }
            .padding(ResonanceTheme.spacingM)
        }
    }
}

// MARK: - Contact Card

struct ContactCardView: View {
    let contact: Contact
    let theme: ResonanceTheme
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
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
                        .font(ResonanceFont.serif(16, weight: .medium))
                        .foregroundStyle(.white)
                }
                .overlay(alignment: .bottomTrailing) {
                    if contact.hasUnread {
                        Circle()
                            .fill(theme.goldPrimary)
                            .frame(width: 10, height: 10)
                            .overlay {
                                Circle()
                                    .stroke(theme.bgSurface, lineWidth: 2)
                            }
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(contact.name)
                        .font(ResonanceFont.headlineSmall)
                        .foregroundStyle(theme.textMain)

                    Text(contact.intention)
                        .font(ResonanceFont.intention)
                        .italic()
                        .foregroundStyle(theme.goldPrimary.opacity(0.7))

                    if let message = contact.lastMessage {
                        Text(message)
                            .font(ResonanceFont.bodySmall)
                            .foregroundStyle(theme.textLight)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(theme.textLight.opacity(isHovered ? 0.6 : 0.3))
            }
            .padding(14)
            .glassCard(theme: theme, isHovered: isHovered)
        }
        .buttonStyle(.plain)
        #if os(macOS) || os(visionOS)
        .onHover { isHovered = $0 }
        #endif
    }
}

// MARK: - Conversation View

struct ConversationView: View {
    let contact: Contact
    let theme: ResonanceTheme
    let onBack: () -> Void
    @State private var newMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            // Conversation header
            conversationHeader

            Divider()
                .foregroundStyle(theme.borderLight.opacity(0.3))

            // Messages
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: ResonanceTheme.spacingS) {
                    ForEach(Message.sampleConversation) { message in
                        MessageBubble(message: message, theme: theme)
                    }
                }
                .padding(ResonanceTheme.spacingM)
            }

            // Composer
            composer
        }
    }

    private var conversationHeader: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14))
                    .foregroundStyle(theme.goldPrimary)
            }
            .buttonStyle(.plain)

            // Contact info
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
                    .font(ResonanceFont.serif(13, weight: .medium))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(contact.name)
                    .font(ResonanceFont.headlineSmall)
                    .foregroundStyle(theme.textMain)

                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.goldPrimary)
                        .frame(width: 5, height: 5)
                    Text("Present")
                        .font(ResonanceFont.caption)
                        .foregroundStyle(theme.goldPrimary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, ResonanceTheme.spacingM)
        .padding(.vertical, 12)
        .glassNavBar(theme: theme)
    }

    private var composer: some View {
        HStack(spacing: 12) {
            TextField("Compose quietly...", text: $newMessage)
                .font(ResonanceFont.bodyMedium)
                .foregroundStyle(theme.textMain)
                .tint(theme.goldPrimary)
                .textFieldStyle(.plain)

            Button {
                // Voice message
            } label: {
                Image(systemName: "mic")
                    .font(.system(size: 16))
                    .foregroundStyle(theme.textLight)
            }
            .buttonStyle(.plain)

            if !newMessage.isEmpty {
                Button {
                    newMessage = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(theme.goldPrimary)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, ResonanceTheme.spacingM)
        .padding(.vertical, 12)
        .glassNavBar(theme: theme)
        .animation(.spring(response: 0.3), value: newMessage.isEmpty)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message
    let theme: ResonanceTheme

    var body: some View {
        HStack {
            if message.isFromMe { Spacer(minLength: 60) }

            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 3) {
                if message.isAudio {
                    audioMessage
                } else {
                    Text(message.content)
                        .font(ResonanceFont.bodyMedium)
                        .foregroundStyle(message.isFromMe ? .white : theme.textMain)
                }

                Text(message.timestamp)
                    .font(ResonanceFont.caption)
                    .foregroundStyle(message.isFromMe ? .white.opacity(0.6) : theme.textLight)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(message.isFromMe ? theme.green700 : theme.bgSurface)
            }
            .overlay {
                if !message.isFromMe {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(theme.borderLight.opacity(0.3), lineWidth: 0.5)
                }
            }

            if !message.isFromMe { Spacer(minLength: 60) }
        }
    }

    private var audioMessage: some View {
        HStack(spacing: 8) {
            Image(systemName: "play.fill")
                .font(.system(size: 12))
                .foregroundStyle(message.isFromMe ? .white : theme.goldPrimary)

            // Audio waveform visualization — calm, gentle lines
            HStack(spacing: 2) {
                ForEach(0..<20, id: \.self) { i in
                    let height = CGFloat.random(in: 4...16)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(message.isFromMe ? .white.opacity(0.5) : theme.goldPrimary.opacity(0.4))
                        .frame(width: 2, height: height)
                }
            }

            Text("0:42")
                .font(ResonanceFont.caption)
                .foregroundStyle(message.isFromMe ? .white.opacity(0.7) : theme.textLight)
        }
    }
}
