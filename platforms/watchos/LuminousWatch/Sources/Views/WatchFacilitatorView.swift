// WatchFacilitatorView.swift
// Luminous Cosmic Architecture™ — watchOS Facilitator
//
// Compact cosmic guide for Apple Watch with quick voice input,
// brief text responses, pre-set questions, and haptic feedback.

import SwiftUI
import WatchKit

// MARK: - Data Models

struct WatchGuideMessage: Identifiable {
    let id: String
    let role: WatchMessageRole
    let content: String
    let timestamp: Date

    enum WatchMessageRole { case user, guide }
}

struct WatchQuickQuestion: Identifiable {
    let id = UUID()
    let label: String
    let prompt: String
    let icon: String
}

// MARK: - View Model

@MainActor
final class WatchFacilitatorViewModel: ObservableObject {
    @Published var messages: [WatchGuideMessage] = []
    @Published var isGuideTyping = false
    @Published var showQuickQuestions = true

    let quickQuestions: [WatchQuickQuestion] = [
        .init(label: "Today's insight", prompt: "What should I focus on today based on the cosmic energies?", icon: "\u{2728}"),
        .init(label: "Moon energy", prompt: "What is the Moon's energy like right now and how does it affect me?", icon: "\u{263D}"),
        .init(label: "Quick guidance", prompt: "I need a brief moment of guidance. What does the cosmos suggest?", icon: "\u{2609}"),
    ]

    private let guideResponses = [
        "Today invites reflection. The lunar energy is quietly supportive \u2014 trust what feels right without overthinking.",
        "The Moon encourages gentleness now. Honor your emotional rhythms and give yourself space to simply be.",
        "A moment of stillness can reveal more than hours of searching. Breathe, and notice what arises.",
        "The current cosmic climate favors authenticity. Express what is true for you, even in small ways.",
        "Trust the timing. What feels slow is often the universe aligning things with greater precision than you can see.",
    ]

    func sendQuickQuestion(_ question: WatchQuickQuestion) {
        showQuickQuestions = false

        let userMsg = WatchGuideMessage(
            id: UUID().uuidString,
            role: .user,
            content: question.label,
            timestamp: Date()
        )
        withAnimation(.easeOut(duration: 0.3)) {
            messages.append(userMsg)
        }

        // Haptic feedback
        WKInterfaceDevice.current().play(.click)

        isGuideTyping = true
        Task {
            try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 1.0...2.0) * 1_000_000_000))

            let response = guideResponses.randomElement() ?? guideResponses[0]
            let guideMsg = WatchGuideMessage(
                id: UUID().uuidString,
                role: .guide,
                content: response,
                timestamp: Date()
            )

            withAnimation(.easeOut(duration: 0.3)) {
                isGuideTyping = false
                messages.append(guideMsg)
            }

            // Success haptic
            WKInterfaceDevice.current().play(.success)
        }
    }

    func sendVoiceInput(_ text: String) {
        showQuickQuestions = false

        let userMsg = WatchGuideMessage(
            id: UUID().uuidString,
            role: .user,
            content: text,
            timestamp: Date()
        )
        withAnimation(.easeOut(duration: 0.3)) {
            messages.append(userMsg)
        }

        WKInterfaceDevice.current().play(.click)

        isGuideTyping = true
        Task {
            try? await Task.sleep(nanoseconds: UInt64(Double.random(in: 1.0...2.0) * 1_000_000_000))

            let response = guideResponses.randomElement() ?? guideResponses[0]
            let guideMsg = WatchGuideMessage(
                id: UUID().uuidString,
                role: .guide,
                content: response,
                timestamp: Date()
            )

            withAnimation(.easeOut(duration: 0.3)) {
                isGuideTyping = false
                messages.append(guideMsg)
            }

            WKInterfaceDevice.current().play(.success)
        }
    }

    func resetConversation() {
        withAnimation {
            messages.removeAll()
            showQuickQuestions = true
        }
        WKInterfaceDevice.current().play(.click)
    }
}

// MARK: - Main View

struct WatchFacilitatorView: View {
    @StateObject private var vm = WatchFacilitatorViewModel()
    @State private var showDictation = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: WatchTheme.Spacing.md) {
                    // Header
                    WatchGuideHeader()

                    if vm.showQuickQuestions {
                        // Quick questions
                        quickQuestionsView
                    }

                    // Messages
                    ForEach(vm.messages) { message in
                        WatchMessageRow(message: message)
                            .id(message.id)
                    }

                    if vm.isGuideTyping {
                        WatchTypingRow()
                            .id("typing")
                    }

                    // Action buttons when in conversation
                    if !vm.messages.isEmpty && !vm.isGuideTyping {
                        actionButtons
                    }
                }
                .padding(.horizontal, WatchTheme.Spacing.sm)
            }
            .onChange(of: vm.messages.count) { _ in
                if let lastId = vm.messages.last?.id {
                    withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                }
            }
        }
        .navigationTitle("Guide")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Quick Questions

    private var quickQuestionsView: some View {
        VStack(spacing: WatchTheme.Spacing.md) {
            Text("Ask your Guide")
                .font(WatchTheme.Typography.caption)
                .foregroundColor(WatchTheme.Colors.textSecondary)

            ForEach(vm.quickQuestions) { question in
                Button {
                    vm.sendQuickQuestion(question)
                } label: {
                    HStack(spacing: WatchTheme.Spacing.md) {
                        Text(question.icon)
                            .font(.system(size: 16))

                        Text(question.label)
                            .font(WatchTheme.Typography.body)
                            .foregroundColor(WatchTheme.Colors.textPrimary)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, WatchTheme.Spacing.lg)
                    .padding(.vertical, WatchTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                            .fill(WatchTheme.Colors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                                    .strokeBorder(
                                        WatchTheme.Colors.gold.opacity(0.15),
                                        lineWidth: 0.5
                                    )
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            // Voice input button
            Button {
                presentDictation()
            } label: {
                HStack(spacing: WatchTheme.Spacing.md) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 14))
                        .foregroundColor(WatchTheme.Colors.gold)

                    Text("Tap to speak")
                        .font(WatchTheme.Typography.body)
                        .foregroundColor(WatchTheme.Colors.gold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, WatchTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                        .fill(WatchTheme.Colors.gold.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                                .strokeBorder(
                                    WatchTheme.Colors.gold.opacity(0.3),
                                    lineWidth: 0.5
                                )
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        VStack(spacing: WatchTheme.Spacing.sm) {
            Button {
                presentDictation()
            } label: {
                Label("Ask more", systemImage: "mic.fill")
                    .font(WatchTheme.Typography.caption)
                    .foregroundColor(WatchTheme.Colors.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, WatchTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: WatchTheme.Radius.sm)
                            .fill(WatchTheme.Colors.gold.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)

            Button {
                vm.resetConversation()
            } label: {
                Text("New session")
                    .font(WatchTheme.Typography.caption2)
                    .foregroundColor(WatchTheme.Colors.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, WatchTheme.Spacing.sm)
    }

    // MARK: Dictation

    private func presentDictation() {
        // In production, use WKExtension's dictation API
        // Simulating with hardcoded text for the design prototype
        vm.sendVoiceInput("What do the stars say about today?")
    }
}

// MARK: - Watch Guide Header

struct WatchGuideHeader: View {
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: CGFloat = 0.3

    var body: some View {
        VStack(spacing: WatchTheme.Spacing.sm) {
            ZStack {
                // Glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                WatchTheme.Colors.gold.opacity(glowOpacity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .scaleEffect(pulseScale)

                // Symbol
                Image(systemName: "sparkle")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(WatchTheme.Colors.gold)
            }

            Text("Cosmic Guide")
                .font(WatchTheme.Typography.title)
                .foregroundColor(WatchTheme.Colors.textPrimary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
                glowOpacity = 0.5
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cosmic Guide")
    }
}

// MARK: - Watch Message Row

struct WatchMessageRow: View {
    let message: WatchGuideMessage

    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: WatchTheme.Spacing.xs) {
            Text(message.content)
                .font(
                    message.role == .guide
                        ? WatchTheme.Typography.body
                        : WatchTheme.Typography.caption
                )
                .foregroundColor(
                    message.role == .guide
                        ? WatchTheme.Colors.textPrimary
                        : WatchTheme.Colors.gold
                )
                .lineSpacing(2)
                .padding(.horizontal, WatchTheme.Spacing.lg)
                .padding(.vertical, WatchTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                        .fill(
                            message.role == .user
                                ? WatchTheme.Colors.gold.opacity(0.12)
                                : WatchTheme.Colors.surfaceElevated
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                        .strokeBorder(
                            message.role == .user
                                ? WatchTheme.Colors.gold.opacity(0.25)
                                : WatchTheme.Colors.gold.opacity(0.08),
                            lineWidth: 0.5
                        )
                )
                .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        }
    }
}

// MARK: - Watch Typing Row

struct WatchTypingRow: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(WatchTheme.Colors.gold.opacity(0.6))
                    .frame(width: 5, height: 5)
                    .scaleEffect(0.5 + 0.5 * sin(phase * .pi + Double(i) * 0.4))
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.15),
                        value: phase
                    )
            }
        }
        .padding(.horizontal, WatchTheme.Spacing.lg)
        .padding(.vertical, WatchTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: WatchTheme.Radius.md)
                .fill(WatchTheme.Colors.surfaceElevated)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { phase = 1.0 }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WatchFacilitatorView()
    }
}
