// MARK: - Audiobook Player — Listen to LCD with the body
// "Let the words arrive through the ears. Let the body receive them."

import SwiftUI

struct AudiobookView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var player: AudiobookPlayerManager
    @State private var showChapterList = false
    @State private var showSleepTimer = false
    @State private var showSpeedPicker = false
    @State private var showShareSheet = false
    @State private var breathScale: CGFloat = 1.0

    // Sample chapter data
    private let chapters = [
        ("Chapter 1", "Theoretical Foundations — The Deep Roots", "2h 15m"),
        ("Chapter 2", "Subject-Object Dynamics — The Intimate Theater", "1h 48m"),
        ("Chapter 3", "The Evolution of Meaning — How Consciousness Grows", "2h 03m"),
        ("Chapter 4", "Practical Applications", "1h 35m"),
        ("Chapter 5", "Challenges and Critiques", "1h 12m"),
        ("Chapter 6", "Future Directions", "58m"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Cover art with breathing animation
                            ZStack {
                                // Ambient glow
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [theme.goldPrimary.opacity(0.12), Color.clear],
                                            center: .center,
                                            startRadius: 40,
                                            endRadius: 160
                                        )
                                    )
                                    .frame(width: 320, height: 320)
                                    .scaleEffect(breathScale)
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                                            breathScale = 1.08
                                        }
                                    }

                                // Cover
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [theme.forestDeep, theme.forestBase],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 240, height: 240)
                                    .overlay(
                                        VStack(spacing: 12) {
                                            Text("Luminous\nConstructive\nDevelopment™")
                                                .font(.custom("Cormorant Garamond", size: 24))
                                                .fontWeight(.light)
                                                .foregroundColor(theme.cream)
                                                .multilineTextAlignment(.center)
                                                .lineSpacing(4)

                                            Rectangle()
                                                .fill(theme.goldPrimary.opacity(0.4))
                                                .frame(width: 40, height: 1)

                                            Text("Subject-Object and\nthe Evolution of Meaning")
                                                .font(.custom("Manrope", size: 12))
                                                .foregroundColor(theme.cream.opacity(0.7))
                                                .multilineTextAlignment(.center)
                                        }
                                    )
                                    .shadow(color: theme.forestDeepest.opacity(0.4), radius: 24, y: 12)
                            }
                            .padding(.top, 24)

                            // Title & narrator
                            VStack(spacing: 6) {
                                Text("Luminous Constructive Development™")
                                    .font(.custom("Cormorant Garamond", size: 24))
                                    .foregroundColor(theme.text)
                                    .multilineTextAlignment(.center)
                                Text("Narrated with presence and warmth")
                                    .font(.custom("Manrope", size: 14))
                                    .foregroundColor(theme.textSecondary)
                            }

                            // Current chapter info
                            VStack(spacing: 4) {
                                Text(chapters[player.currentChapter].0)
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(theme.goldPrimary)
                                    .textCase(.uppercase)
                                    .tracking(0.5)
                                Text(chapters[player.currentChapter].1)
                                    .font(.custom("Cormorant Garamond", size: 20))
                                    .foregroundColor(theme.text)
                            }

                            // Progress bar
                            VStack(spacing: 8) {
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(theme.forestBase.opacity(0.12))
                                            .frame(height: 4)

                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(theme.goldPrimary)
                                            .frame(width: geo.size.width * progressFraction, height: 4)
                                    }
                                }
                                .frame(height: 4)

                                HStack {
                                    Text(formatTime(player.currentTime))
                                        .font(.custom("Manrope", size: 12))
                                        .foregroundColor(theme.textSecondary)
                                    Spacer()
                                    Text("-\(formatTime(player.duration - player.currentTime))")
                                        .font(.custom("Manrope", size: 12))
                                        .foregroundColor(theme.textSecondary)
                                }
                            }
                            .padding(.horizontal, 32)

                            // Transport controls
                            HStack(spacing: 40) {
                                Button(action: { player.skipBackward() }) {
                                    VStack(spacing: 2) {
                                        Image(systemName: "gobackward.15")
                                            .font(.system(size: 28))
                                        Text("15")
                                            .font(.custom("Manrope", size: 10))
                                    }
                                    .foregroundColor(theme.text)
                                }

                                Button(action: {
                                    player.isPlaying ? player.pause() : player.play()
                                }) {
                                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(theme.forestBase)
                                }

                                Button(action: { player.skipForward() }) {
                                    VStack(spacing: 2) {
                                        Image(systemName: "goforward.30")
                                            .font(.system(size: 28))
                                        Text("30")
                                            .font(.custom("Manrope", size: 10))
                                    }
                                    .foregroundColor(theme.text)
                                }
                            }

                            // Secondary controls
                            HStack(spacing: 32) {
                                Button(action: { showSpeedPicker = true }) {
                                    VStack(spacing: 4) {
                                        Text("\(String(format: "%.1f", player.playbackSpeed))×")
                                            .font(.custom("Manrope", size: 14).weight(.medium))
                                        Text("Speed")
                                            .font(.custom("Manrope", size: 11))
                                    }
                                    .foregroundColor(theme.textSecondary)
                                }

                                Button(action: { showSleepTimer = true }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "moon")
                                            .font(.system(size: 18))
                                        Text("Sleep")
                                            .font(.custom("Manrope", size: 11))
                                    }
                                    .foregroundColor(theme.textSecondary)
                                }

                                Button(action: { showChapterList = true }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "list.bullet")
                                            .font(.system(size: 18))
                                        Text("Chapters")
                                            .font(.custom("Manrope", size: 11))
                                    }
                                    .foregroundColor(theme.textSecondary)
                                }

                                Button(action: { /* Switch to eBook at this position */ }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "book")
                                            .font(.system(size: 18))
                                        Text("Read")
                                            .font(.custom("Manrope", size: 11))
                                    }
                                    .foregroundColor(theme.accent)
                                }

                                Button(action: { showShareSheet = true }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 18))
                                        Text("Share")
                                            .font(.custom("Manrope", size: 11))
                                    }
                                    .foregroundColor(theme.textSecondary)
                                }
                            }

                            // Sleep timer indicator
                            if let remaining = player.sleepTimerRemaining {
                                HStack(spacing: 6) {
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 12))
                                    Text("Sleep in \(Int(remaining / 60)) min")
                                        .font(.custom("Manrope", size: 13))
                                }
                                .foregroundColor(theme.goldPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(theme.goldPrimary.opacity(0.1)))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .sheet(isPresented: $showChapterList) {
                ChapterListView(chapters: chapters, currentChapter: player.currentChapter) { index in
                    player.currentChapter = index
                    player.currentTime = 0
                }
            }
            .sheet(isPresented: $showSleepTimer) {
                SleepTimerView(onSelect: { minutes in
                    player.setSleepTimer(minutes: minutes)
                })
                .presentationDetents([.height(300)])
            }
            .sheet(isPresented: $showShareSheet) {
                ShareCardPreview(text: "Currently listening to \"\(chapters[player.currentChapter].1)\" — the subject-object question is alive in every moment.")
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var progressFraction: Double {
        guard player.duration > 0 else { return 0 }
        return player.currentTime / player.duration
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Chapter List

struct ChapterListView: View {
    let chapters: [(String, String, String)]
    let currentChapter: Int
    let onSelect: (Int) -> Void
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(chapters.enumerated()), id: \.offset) { index, chapter in
                    Button(action: {
                        onSelect(index)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chapter.0)
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(index == currentChapter ? theme.goldPrimary : theme.textSecondary)
                                Text(chapter.1)
                                    .font(.custom("Manrope", size: 15))
                                    .foregroundColor(theme.text)
                            }
                            Spacer()
                            Text(chapter.2)
                                .font(.custom("Manrope", size: 13))
                                .foregroundColor(theme.textSecondary)

                            if index == currentChapter {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(theme.goldPrimary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chapters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sleep Timer

struct SleepTimerView: View {
    let onSelect: (Int) -> Void
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss

    let options = [5, 10, 15, 20, 30, 45, 60]

    var body: some View {
        VStack(spacing: 16) {
            Text("Sleep Timer")
                .font(.custom("Cormorant Garamond", size: 24))
                .foregroundColor(theme.text)
            Text("Rest is part of the developmental journey")
                .font(.custom("Manrope", size: 13))
                .foregroundColor(theme.textSecondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 12) {
                ForEach(options, id: \.self) { minutes in
                    Button(action: {
                        onSelect(minutes)
                        dismiss()
                    }) {
                        Text("\(minutes)m")
                            .font(.custom("Manrope", size: 16).weight(.medium))
                            .foregroundColor(theme.text)
                            .frame(width: 70, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(theme.forestBase.opacity(0.06))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}
