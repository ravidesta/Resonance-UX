// AudiobookPlayerView.swift
// Luminous Integral Architecture™ — Audiobook Player
//
// Full audiobook player with now-playing, chapter navigation, sleep timer,
// text-sync highlighting, playback speed control, and mini player bar.

import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif

// MARK: - Audiobook Player View Model

@MainActor
final class AudiobookPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 347
    @Published var duration: TimeInterval = 3600
    @Published var currentChapterIndex: Int = 1
    @Published var playbackSpeed: PlaybackSpeed = .normal
    @Published var sleepTimerMinutes: Int? = nil
    @Published var sleepTimerRemaining: TimeInterval? = nil
    @Published var isFollowAlongMode = false
    @Published var isSleepTimerPickerVisible = false
    @Published var isChapterListVisible = false
    @Published var isSpeedPickerVisible = false
    @Published var showMiniPlayer = false

    // Simulated synced text highlighting
    @Published var highlightedWordIndex: Int = 0

    enum PlaybackSpeed: Double, CaseIterable {
        case half = 0.5
        case threequarter = 0.75
        case normal = 1.0
        case oneAndQuarter = 1.25
        case oneAndHalf = 1.5
        case double = 2.0
        case twoAndHalf = 2.5
        case triple = 3.0

        var displayString: String {
            if self == .normal { return "1x" }
            let v = rawValue
            if v == floor(v) { return "\(Int(v))x" }
            return "\(v)x"
        }
    }

    let chapters: [Chapter] = [
        Chapter(id: "ach1", title: "Foreword", subtitle: "Setting the Stage", pageRange: 1...12, duration: 900, isCompleted: true),
        Chapter(id: "ach2", title: "Chapter 1: The Integral Vision", subtitle: "Seeing the Whole", pageRange: 13...48, duration: 2700, isCompleted: false),
        Chapter(id: "ach3", title: "Chapter 2: Four Quadrants", subtitle: "Maps of Reality", pageRange: 49...96, duration: 3600, isCompleted: false),
        Chapter(id: "ach4", title: "Chapter 3: Levels of Development", subtitle: "The Great Unfolding", pageRange: 97...140, duration: 3200, isCompleted: false),
        Chapter(id: "ach5", title: "Chapter 4: Lines of Intelligence", subtitle: "Multiple Streams", pageRange: 141...182, duration: 2900, isCompleted: false),
        Chapter(id: "ach6", title: "Chapter 5: States of Consciousness", pageRange: 183...224, duration: 3100, isCompleted: false),
        Chapter(id: "ach7", title: "Chapter 6: Spatial Attunement", subtitle: "Embodied Practice", pageRange: 269...306, duration: 2800, isCompleted: false),
        Chapter(id: "ach8", title: "Chapter 7: Integral Life Practice", subtitle: "Bringing It All Together", pageRange: 307...342, duration: 3400, isCompleted: false),
    ]

    var currentChapter: Chapter {
        chapters[currentChapterIndex]
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var totalDuration: TimeInterval {
        chapters.compactMap(\.duration).reduce(0, +)
    }

    var overallProgress: Double {
        let completed = chapters.prefix(currentChapterIndex).compactMap(\.duration).reduce(0, +) + currentTime
        return completed / totalDuration
    }

    func togglePlayback() {
        isPlaying.toggle()
    }

    func skipForward(_ seconds: TimeInterval = 15) {
        currentTime = min(currentTime + seconds, duration)
    }

    func skipBackward(_ seconds: TimeInterval = 15) {
        currentTime = max(currentTime - seconds, 0)
    }

    func nextChapter() {
        if currentChapterIndex < chapters.count - 1 {
            currentChapterIndex += 1
            currentTime = 0
            duration = chapters[currentChapterIndex].duration ?? 3600
        }
    }

    func previousChapter() {
        if currentTime > 5 {
            currentTime = 0
        } else if currentChapterIndex > 0 {
            currentChapterIndex -= 1
            currentTime = 0
            duration = chapters[currentChapterIndex].duration ?? 3600
        }
    }

    func setSleepTimer(_ minutes: Int?) {
        sleepTimerMinutes = minutes
        sleepTimerRemaining = minutes.map { TimeInterval($0 * 60) }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = (Int(time) % 3600) / 60
        let s = Int(time) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    func formatDuration(_ time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = (Int(time) % 3600) / 60
        if h > 0 {
            return "\(h)h \(m)m"
        }
        return "\(m) min"
    }
}

// MARK: - Audiobook Player View (Now Playing)

struct AudiobookPlayerView: View {
    @StateObject private var viewModel = AudiobookPlayerViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Organic blob background
            Color.resonanceBgBaseDark
                .ignoresSafeArea()
            OrganicBlobView()
                .ignoresSafeArea()

            #if os(watchOS)
            watchPlayerLayout
            #else
            fullPlayerLayout
            #endif
        }
    }

    // MARK: Full Player (iOS / iPadOS / macOS / visionOS)

    #if !os(watchOS)
    private var fullPlayerLayout: some View {
        VStack(spacing: 0) {
            // Top controls
            HStack {
                Button {
                    viewModel.showMiniPlayer = true
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .accessibilityLabel("Minimize player")

                Spacer()

                Text("NOW PLAYING")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(2)

                Spacer()

                Menu {
                    #if !os(macOS)
                    Button("AirPlay") {}
                    #endif
                    Button("Share") {}
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .accessibilityLabel("More options")
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            // Chapter art area
            chapterArtView

            Spacer()

            // Chapter info
            VStack(spacing: 4) {
                Text(viewModel.currentChapter.title)
                    .font(ResonanceTypography.serifTitle())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if let subtitle = viewModel.currentChapter.subtitle {
                    Text(subtitle)
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(.white.opacity(0.6))
                }

                Text("Luminous Integral Architecture")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 24)

            Spacer()
                .frame(height: 24)

            // Follow-along text
            if viewModel.isFollowAlongMode {
                followAlongText
                    .padding(.horizontal, 24)
                    .frame(height: 80)
            }

            // Progress slider
            VStack(spacing: 4) {
                Slider(
                    value: $viewModel.currentTime,
                    in: 0...viewModel.duration
                )
                .tint(Color.resonanceGoldPrimary)
                .accessibilityLabel("Playback position")
                .accessibilityValue(viewModel.formatTime(viewModel.currentTime))

                HStack {
                    Text(viewModel.formatTime(viewModel.currentTime))
                    Spacer()
                    Text("-\(viewModel.formatTime(viewModel.duration - viewModel.currentTime))")
                }
                .font(ResonanceTypography.sansCaption2())
                .foregroundStyle(.white.opacity(0.5))
                .monospacedDigit()
            }
            .padding(.horizontal, 24)

            // Playback controls
            playbackControls
                .padding(.vertical, 20)

            // Bottom controls row
            bottomControlsRow
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .sheet(isPresented: $viewModel.isChapterListVisible) {
            chapterListSheet
        }
        .sheet(isPresented: $viewModel.isSleepTimerPickerVisible) {
            sleepTimerSheet
        }
    }
    #endif

    // MARK: Chapter Art

    #if !os(watchOS)
    private var chapterArtView: some View {
        ZStack {
            // Outer glow
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.resonanceGreen700, Color.resonanceGreen900],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 260, height: 260)
                .shadow(color: Color.resonanceGoldPrimary.opacity(0.2), radius: 30)

            // Inner content
            VStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.system(size: 40, weight: .thin))
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .breathingAnimation(duration: 4)

                Text("LIA")
                    .font(ResonanceTypography.serifDisplay(size: 36))
                    .foregroundStyle(Color.resonanceGoldLight)

                ResonanceDivider()
                    .frame(width: 80)

                Text("Chapter \(viewModel.currentChapterIndex + 1)")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(width: 260, height: 260)
        }
        .accessibilityHidden(true)
    }
    #endif

    // MARK: Follow-Along Text

    #if !os(watchOS)
    private var followAlongText: some View {
        let words = sampleSyncText.split(separator: " ").map(String.init)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text(word)
                        .font(ResonanceTypography.serifBody(size: 16))
                        .foregroundStyle(
                            index <= viewModel.highlightedWordIndex
                                ? Color.resonanceGoldPrimary
                                : .white.opacity(0.4)
                        )
                        .animation(.easeInOut(duration: 0.2), value: viewModel.highlightedWordIndex)
                }
            }
        }
        .accessibilityLabel("Synchronized text display")
    }
    #endif

    // MARK: Playback Controls

    #if !os(watchOS)
    private var playbackControls: some View {
        HStack(spacing: 32) {
            // Previous chapter
            Button(action: viewModel.previousChapter) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .accessibilityLabel("Previous chapter")

            // Skip backward
            Button { viewModel.skipBackward(15) } label: {
                ZStack {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            }
            .accessibilityLabel("Skip back 15 seconds")

            // Play / Pause
            Button(action: viewModel.togglePlayback) {
                ZStack {
                    Circle()
                        .fill(Color.resonanceGoldPrimary)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.resonanceGoldPrimary.opacity(0.4), radius: 12)

                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.resonanceGreen900)
                        .offset(x: viewModel.isPlaying ? 0 : 2)
                }
            }
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

            // Skip forward
            Button { viewModel.skipForward(30) } label: {
                Image(systemName: "goforward.30")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }
            .accessibilityLabel("Skip forward 30 seconds")

            // Next chapter
            Button(action: viewModel.nextChapter) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .accessibilityLabel("Next chapter")
        }
    }
    #endif

    // MARK: Bottom Controls Row

    #if !os(watchOS)
    private var bottomControlsRow: some View {
        HStack {
            // Playback speed
            Button {
                viewModel.isSpeedPickerVisible.toggle()
            } label: {
                Text(viewModel.playbackSpeed.displayString)
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
            }
            .accessibilityLabel("Playback speed: \(viewModel.playbackSpeed.displayString)")
            .popover(isPresented: $viewModel.isSpeedPickerVisible) {
                speedPickerContent
            }

            Spacer()

            // Follow along mode
            Button {
                viewModel.isFollowAlongMode.toggle()
            } label: {
                Image(systemName: viewModel.isFollowAlongMode ? "text.alignleft" : "text.justify.leading")
                    .font(.system(size: 16))
                    .foregroundStyle(viewModel.isFollowAlongMode ? Color.resonanceGoldPrimary : .white.opacity(0.5))
            }
            .accessibilityLabel("Follow along mode: \(viewModel.isFollowAlongMode ? "on" : "off")")

            Spacer()

            // Sleep timer
            Button {
                viewModel.isSleepTimerPickerVisible = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 14))
                    if let remaining = viewModel.sleepTimerRemaining {
                        Text(viewModel.formatTime(remaining))
                            .font(ResonanceTypography.sansCaption2())
                            .monospacedDigit()
                    }
                }
                .foregroundStyle(viewModel.sleepTimerMinutes != nil ? Color.resonanceGoldPrimary : .white.opacity(0.5))
            }
            .accessibilityLabel("Sleep timer")

            Spacer()

            // Chapter list
            Button {
                viewModel.isChapterListVisible = true
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .accessibilityLabel("Chapter list")

            Spacer()

            // AirPlay / output selector
            #if os(iOS)
            Button {} label: {
                Image(systemName: "airplayaudio")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .accessibilityLabel("Audio output selector")
            #endif
        }
    }
    #endif

    // MARK: Speed Picker

    #if !os(watchOS)
    private var speedPickerContent: some View {
        VStack(spacing: 4) {
            ForEach(AudiobookPlayerViewModel.PlaybackSpeed.allCases, id: \.self) { speed in
                Button {
                    viewModel.playbackSpeed = speed
                    viewModel.isSpeedPickerVisible = false
                } label: {
                    HStack {
                        Text(speed.displayString)
                            .font(ResonanceTypography.sansBody())
                        Spacer()
                        if speed == viewModel.playbackSpeed {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.resonanceGoldPrimary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
        .frame(width: 180)
        .padding(.vertical, 8)
    }
    #endif

    // MARK: Chapter List Sheet

    #if !os(watchOS)
    private var chapterListSheet: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.chapters.enumerated()), id: \.element.id) { index, chapter in
                    Button {
                        viewModel.currentChapterIndex = index
                        viewModel.currentTime = 0
                        viewModel.duration = chapter.duration ?? 3600
                        viewModel.isChapterListVisible = false
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: chapter.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(chapter.isCompleted ? Color.resonanceGreen500 : .secondary)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(chapter.title)
                                    .font(ResonanceTypography.sansBody())
                                    .foregroundStyle(.primary)
                                if let d = chapter.duration {
                                    Text(viewModel.formatDuration(d))
                                        .font(ResonanceTypography.sansCaption2())
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if index == viewModel.currentChapterIndex {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundStyle(Color.resonanceGoldPrimary)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .accessibilityLabel("\(chapter.title), \(chapter.duration.map { viewModel.formatDuration($0) } ?? "")")
                }
            }
            .navigationTitle("Chapters")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.isChapterListVisible = false
                    }
                }
            }
        }
    }
    #endif

    // MARK: Sleep Timer Sheet

    #if !os(watchOS)
    private var sleepTimerSheet: some View {
        NavigationStack {
            List {
                ForEach([5, 10, 15, 30, 45, 60, 90], id: \.self) { minutes in
                    Button {
                        viewModel.setSleepTimer(minutes)
                        viewModel.isSleepTimerPickerVisible = false
                    } label: {
                        HStack {
                            Text("\(minutes) minutes")
                                .font(ResonanceTypography.sansBody())
                            Spacer()
                            if viewModel.sleepTimerMinutes == minutes {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.resonanceGoldPrimary)
                            }
                        }
                    }
                }

                Button("End of chapter") {
                    viewModel.isSleepTimerPickerVisible = false
                }

                if viewModel.sleepTimerMinutes != nil {
                    Button("Cancel timer") {
                        viewModel.setSleepTimer(nil)
                        viewModel.isSleepTimerPickerVisible = false
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Sleep Timer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.isSleepTimerPickerVisible = false
                    }
                }
            }
        }
    }
    #endif

    // MARK: Watch Layout

    #if os(watchOS)
    private var watchPlayerLayout: some View {
        VStack(spacing: 8) {
            Text(viewModel.currentChapter.title)
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            ResonanceProgressBar(progress: viewModel.progress, height: 2)

            HStack {
                Text(viewModel.formatTime(viewModel.currentTime))
                Spacer()
                Text(viewModel.formatTime(viewModel.duration))
            }
            .font(ResonanceTypography.sansCaption2())
            .foregroundStyle(.white.opacity(0.5))
            .monospacedDigit()

            HStack(spacing: 20) {
                Button { viewModel.skipBackward(15) } label: {
                    Image(systemName: "gobackward.15")
                }
                .accessibilityLabel("Skip back 15 seconds")

                Button(action: viewModel.togglePlayback) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.resonanceGoldPrimary)
                }
                .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

                Button { viewModel.skipForward(30) } label: {
                    Image(systemName: "goforward.30")
                }
                .accessibilityLabel("Skip forward 30 seconds")
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
    }
    #endif

    // MARK: Mini Player Bar

    var miniPlayerBar: some View {
        HStack(spacing: 12) {
            // Chapter art mini
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.resonanceGreen700, Color.resonanceGreen900],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .overlay(
                    Text("LIA")
                        .font(ResonanceTypography.serifCaption(size: 11))
                        .foregroundStyle(Color.resonanceGoldLight)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentChapter.title)
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text("Luminous Integral Architecture")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: viewModel.togglePlayback) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")

            Button(action: viewModel.nextChapter) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Next chapter")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .glassPanel(cornerRadius: 12, padding: 0)
    }

    // MARK: Helpers

    private var sampleSyncText: String {
        "The integral approach begins with the recognition that every perspective holds a partial truth. No single view captures the fullness of reality. Yet each reveals something essential that the others miss."
    }
}

// MARK: - Preview

#if DEBUG
struct AudiobookPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudiobookPlayerView()
            .preferredColorScheme(.dark)
    }
}
#endif
