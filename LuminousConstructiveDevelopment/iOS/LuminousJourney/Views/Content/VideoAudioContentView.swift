// MARK: - Video & Audio Content System
// Guided practice videos, narrated meditations, somatic movement sequences,
// coach-recorded content, and ambient soundscapes.

import SwiftUI
import AVKit

// MARK: - Content Library

struct ContentLibraryView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedCategory: ContentCategory = .all
    @State private var selectedContent: MediaContent?

    enum ContentCategory: String, CaseIterable {
        case all = "All"
        case guidedPractice = "Guided Practice"
        case somaticMovement = "Somatic Movement"
        case meditation = "Meditation"
        case lecture = "Lecture"
        case ambient = "Ambient"
        case coachContent = "From Coach"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Featured content
                        FeaturedContentCard()

                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ContentCategory.allCases, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        Text(category.rawValue)
                                            .font(.custom("Manrope", size: 13).weight(.medium))
                                            .foregroundColor(selectedCategory == category ? theme.cream : theme.text)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 7)
                                            .background(
                                                Capsule()
                                                    .fill(selectedCategory == category ? theme.forestBase : theme.forestBase.opacity(0.06))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Content grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                        ], spacing: 16) {
                            ForEach(sampleContent) { content in
                                ContentCard(content: content) {
                                    selectedContent = content
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Content")
            .sheet(item: $selectedContent) { content in
                ContentPlayerView(content: content)
            }
        }
    }
}

// MARK: - Featured Content Card

struct FeaturedContentCard: View {
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0A1C14"), Color(hex: "1B402E")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    // Organic blob
                    Circle()
                        .fill(Color(hex: "C5A059").opacity(0.1))
                        .frame(width: 200)
                        .blur(radius: 40)
                        .offset(x: 80, y: -30)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                    Text("FEATURED")
                        .font(.custom("Manrope", size: 10).weight(.semibold))
                        .tracking(0.5)
                }
                .foregroundColor(Color(hex: "C5A059"))

                Text("Introduction to\nSomatic Seasons")
                    .font(.custom("Cormorant Garamond", size: 28))
                    .fontWeight(.light)
                    .foregroundColor(Color(hex: "FAFAF8"))

                HStack(spacing: 12) {
                    Label("12 min", systemImage: "play.circle")
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(Color(hex: "C8D4CC"))
                    Label("Guided Practice", systemImage: "figure.mind.and.body")
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(Color(hex: "C8D4CC"))
                }
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Content Card

struct ContentCard: View {
    let content: MediaContent
    let onTap: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: thumbnailColors(content.type),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)

                    // Play button overlay
                    Image(systemName: content.type == .audio ? "waveform.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.9))

                    // Duration badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(content.formattedDuration)
                                .font(.custom("Manrope", size: 10).weight(.medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.black.opacity(0.5)))
                                .padding(8)
                        }
                    }
                }

                Text(content.title)
                    .font(.custom("Manrope", size: 14).weight(.medium))
                    .foregroundColor(theme.text)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: iconForType(content.type))
                        .font(.system(size: 10))
                    Text(content.category)
                        .font(.custom("Manrope", size: 11))
                }
                .foregroundColor(theme.textSecondary)
            }
        }
    }

    private func thumbnailColors(_ type: MediaContent.ContentType) -> [Color] {
        switch type {
        case .video:    return [Color(hex: "1B402E"), Color(hex: "2A5A42")]
        case .audio:    return [Color(hex: "8B6BB0"), Color(hex: "5A8AB0")]
        case .ambient:  return [Color(hex: "0A1C14"), Color(hex: "122E21")]
        }
    }

    private func iconForType(_ type: MediaContent.ContentType) -> String {
        switch type {
        case .video:   return "video"
        case .audio:   return "waveform"
        case .ambient: return "leaf"
        }
    }
}

// MARK: - Content Player

struct ContentPlayerView: View {
    let content: MediaContent
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Video/Audio player area
                        if content.type == .video {
                            // Video player placeholder
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.black)
                                    .aspectRatio(16/9, contentMode: .fit)

                                Button(action: { isPlaying.toggle() }) {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 56))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                        } else {
                            // Audio visualization
                            ZStack {
                                // Ambient background
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "0A1C14"), Color(hex: "1B402E")],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 280)

                                VStack(spacing: 16) {
                                    // Breathing orb
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [Color(hex: "C5A059").opacity(0.3), Color.clear],
                                                center: .center,
                                                startRadius: 10,
                                                endRadius: 60
                                            )
                                        )
                                        .frame(width: 120, height: 120)

                                    // Waveform
                                    HStack(spacing: 3) {
                                        ForEach(0..<40, id: \.self) { i in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color(hex: "C5A059").opacity(isPlaying ? 0.8 : 0.3))
                                                .frame(width: 3, height: isPlaying ? CGFloat.random(in: 8...40) : 8)
                                                .animation(.easeInOut(duration: 0.15), value: isPlaying)
                                        }
                                    }
                                }
                            }
                        }

                        // Transport controls
                        VStack(spacing: 12) {
                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(theme.forestBase.opacity(0.12))
                                        .frame(height: 4)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(theme.goldPrimary)
                                        .frame(width: geo.size.width * (currentTime / content.duration), height: 4)
                                }
                            }
                            .frame(height: 4)

                            HStack {
                                Text(formatTime(currentTime))
                                    .font(.custom("Manrope", size: 12).monospacedDigit())
                                    .foregroundColor(theme.textSecondary)
                                Spacer()
                                Text("-" + formatTime(content.duration - currentTime))
                                    .font(.custom("Manrope", size: 12).monospacedDigit())
                                    .foregroundColor(theme.textSecondary)
                            }

                            HStack(spacing: 36) {
                                Button(action: { currentTime = max(0, currentTime - 15) }) {
                                    Image(systemName: "gobackward.15")
                                        .font(.system(size: 24))
                                        .foregroundColor(theme.text)
                                }
                                Button(action: { isPlaying.toggle() }) {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 52))
                                        .foregroundColor(theme.forestBase)
                                }
                                Button(action: { currentTime = min(content.duration, currentTime + 30) }) {
                                    Image(systemName: "goforward.30")
                                        .font(.system(size: 24))
                                        .foregroundColor(theme.text)
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Content info
                        VStack(alignment: .leading, spacing: 12) {
                            Text(content.title)
                                .font(.custom("Cormorant Garamond", size: 28))
                                .foregroundColor(theme.text)

                            HStack(spacing: 12) {
                                Label(content.formattedDuration, systemImage: "clock")
                                Label(content.category, systemImage: iconForCategory(content.category))
                                if let season = content.season {
                                    Label(season, systemImage: "leaf")
                                }
                            }
                            .font(.custom("Manrope", size: 13))
                            .foregroundColor(theme.textSecondary)

                            Text(content.description)
                                .font(.custom("Manrope", size: 15))
                                .foregroundColor(theme.text)
                                .lineSpacing(4)

                            // Instructions (for guided practices)
                            if !content.instructions.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Instructions")
                                        .font(.custom("Manrope", size: 13).weight(.semibold))
                                        .foregroundColor(theme.goldPrimary)
                                        .textCase(.uppercase)

                                    ForEach(Array(content.instructions.enumerated()), id: \.offset) { index, instruction in
                                        HStack(alignment: .top, spacing: 10) {
                                            Text("\(index + 1)")
                                                .font(.custom("Cormorant Garamond", size: 18))
                                                .foregroundColor(theme.goldPrimary)
                                                .frame(width: 24)
                                            Text(instruction)
                                                .font(.custom("Manrope", size: 14))
                                                .foregroundColor(theme.text)
                                                .lineSpacing(3)
                                        }
                                    }
                                }
                            }

                            // Related content
                            if !content.relatedContentIds.isEmpty {
                                Text("Related")
                                    .font(.custom("Manrope", size: 13).weight(.semibold))
                                    .foregroundColor(theme.textSecondary)
                                    .textCase(.uppercase)
                                    .padding(.top, 8)

                                // Show related content cards
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button(action: { showShareSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button(action: { /* Bookmark */ }) {
                            Image(systemName: "bookmark")
                        }
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareCardPreview(text: "Practicing: \(content.title) — \(content.description.prefix(100))...")
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%d:%02d", m, s)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Guided Practice":   return "figure.mind.and.body"
        case "Somatic Movement":  return "figure.walk"
        case "Meditation":        return "brain"
        case "Lecture":           return "person.wave.2"
        case "Ambient":           return "leaf"
        default:                  return "play"
        }
    }
}

// MARK: - Media Content Model

struct MediaContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let type: ContentType
    let duration: TimeInterval
    let season: String?
    let instructions: [String]
    let relatedContentIds: [UUID]

    enum ContentType { case video, audio, ambient }

    var formattedDuration: String {
        let m = Int(duration) / 60
        return "\(m) min"
    }
}

// MARK: - Sample Content

let sampleContent: [MediaContent] = [
    MediaContent(title: "Introduction to Somatic Seasons", description: "A guided exploration of the five somatic seasons of development. Learn to locate yourself in the body's developmental landscape.", category: "Guided Practice", type: .video, duration: 720, season: nil, instructions: ["Find a comfortable position", "Close your eyes", "Scan from feet to crown"], relatedContentIds: []),
    MediaContent(title: "Gentle Breath Release", description: "A 4-7-8 breathing pattern to soften compression.", category: "Guided Practice", type: .audio, duration: 300, season: "Compression", instructions: ["Inhale for 4 counts", "Hold for 7 counts", "Exhale for 8 counts"], relatedContentIds: []),
    MediaContent(title: "Body Listening Meditation", description: "Tuning into new patterns forming in the body during emergence.", category: "Meditation", type: .audio, duration: 480, season: "Emergence", instructions: ["Lie down supported", "Scan slowly", "Ask: What are you becoming?"], relatedContentIds: []),
    MediaContent(title: "Grounding Movement Sequence", description: "A gentle movement practice for the trembling season.", category: "Somatic Movement", type: .video, duration: 600, season: "Trembling", instructions: [], relatedContentIds: []),
    MediaContent(title: "Subject-Object Dynamics Lecture", description: "A deep dive into the intimate theater of meaning-making.", category: "Lecture", type: .video, duration: 2400, season: nil, instructions: [], relatedContentIds: []),
    MediaContent(title: "Forest Night Soundscape", description: "Ambient sounds for contemplative journaling and deep rest.", category: "Ambient", type: .ambient, duration: 3600, season: nil, instructions: [], relatedContentIds: []),
    MediaContent(title: "Open Awareness Sit", description: "Resting in formlessness without needing to fill the space.", category: "Meditation", type: .audio, duration: 600, season: "Emptiness", instructions: ["Sit comfortably", "Let attention be wide", "Rest in not-knowing"], relatedContentIds: []),
    MediaContent(title: "Gratitude Body Scan", description: "Thanking the body for the journey it has carried you through.", category: "Guided Practice", type: .audio, duration: 360, season: "Integration", instructions: ["Three deep breaths", "Move from feet to crown", "Offer acknowledgment at each station"], relatedContentIds: []),
]
