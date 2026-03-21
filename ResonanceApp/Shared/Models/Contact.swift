// Contact.swift
// Resonance — Design for the Exhale

import SwiftUI

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let intention: String
    let lastMessage: String?
    let hasUnread: Bool
    let avatarGradient: [Color]

    static let sampleContacts: [Contact] = [
        Contact(
            name: "Elena Voss",
            initials: "EV",
            intention: "Deep work phase",
            lastMessage: "The draft looks beautiful",
            hasUnread: true,
            avatarGradient: [Color(hex: "D1E0D7"), Color(hex: "C5A059")]
        ),
        Contact(
            name: "Marcus Chen",
            initials: "MC",
            intention: "Open to connect",
            lastMessage: "Let's sync this afternoon",
            hasUnread: false,
            avatarGradient: [Color(hex: "E8F0EA"), Color(hex: "1B402E")]
        ),
        Contact(
            name: "Aria Delacroix",
            initials: "AD",
            intention: "Recharging",
            lastMessage: nil,
            hasUnread: false,
            avatarGradient: [Color(hex: "E6D0A1"), Color(hex: "9A7A3A")]
        ),
        Contact(
            name: "James Okafor",
            initials: "JO",
            intention: "In transit",
            lastMessage: "Sent you the recording",
            hasUnread: true,
            avatarGradient: [Color(hex: "D1E0D7"), Color(hex: "5C7065")]
        ),
        Contact(
            name: "Sophie Laurent",
            initials: "SL",
            intention: "Morning ritual",
            lastMessage: "Thank you for the space",
            hasUnread: false,
            avatarGradient: [Color(hex: "E8F0EA"), Color(hex: "C5A059")]
        ),
    ]
}

// MARK: - Message

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isFromMe: Bool
    let timestamp: String
    let isAudio: Bool

    static let sampleConversation: [Message] = [
        Message(content: "I've been reflecting on the proposal", isFromMe: false, timestamp: "10:15 AM", isAudio: false),
        Message(content: "The section on intentional design really resonates", isFromMe: false, timestamp: "10:16 AM", isAudio: false),
        Message(content: "Thank you — I spent a lot of quiet time with it", isFromMe: true, timestamp: "10:22 AM", isAudio: false),
        Message(content: "Voice note about the typography choices", isFromMe: false, timestamp: "10:30 AM", isAudio: true),
        Message(content: "The draft looks beautiful. Let's discuss over tea.", isFromMe: false, timestamp: "10:45 AM", isAudio: false),
        Message(content: "I'd love that. This afternoon?", isFromMe: true, timestamp: "11:02 AM", isAudio: false),
    ]
}
