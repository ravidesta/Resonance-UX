import SwiftUI
import AVFoundation
import MediaPlayer

// MARK: - Audiobook Player for Luminous Attachment

@Observable
class AudiobookPlayer {
    var chapters: [AudioChapter] = AudiobookPlayer.defaultChapters()
    var currentChapterIndex: Int = 0
    var isPlaying: Bool = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0
    var playbackSpeed: Float = 1.0
    var sleepTimerMinutes: Int? = nil
    var sleepTimerRemaining: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var sleepTimer: Timer?

    var currentChapter: AudioChapter {
        guard currentChapterIndex < chapters.count else { return chapters[0] }
        return chapters[currentChapterIndex]
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var currentTimeFormatted: String { formatTime(currentTime) }
    var durationFormatted: String { formatTime(duration) }

    init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    // MARK: - Audio Session

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.allowAirPlay, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    // MARK: - Playback Controls

    func play() {
        isPlaying = true
        audioPlayer?.play()
        audioPlayer?.rate = playbackSpeed
        startProgressTimer()
        updateNowPlayingInfo()
    }

    func pause() {
        isPlaying = false
        audioPlayer?.pause()
        stopProgressTimer()
        updateNowPlayingInfo()
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    func skipForward(_ seconds: TimeInterval = 30) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }

    func skipBackward(_ seconds: TimeInterval = 15) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }

    func seek(to time: TimeInterval) {
        currentTime = time
        audioPlayer?.currentTime = time
        updateNowPlayingInfo()
    }

    func seekToProgress(_ progress: Double) {
        let time = duration * progress
        seek(to: time)
    }

    func nextChapter() {
        guard currentChapterIndex < chapters.count - 1 else { return }
        currentChapterIndex += 1
        loadChapter(at: currentChapterIndex)
        if isPlaying { play() }
    }

    func previousChapter() {
        if currentTime > 5 {
            seek(to: 0)
        } else if currentChapterIndex > 0 {
            currentChapterIndex -= 1
            loadChapter(at: currentChapterIndex)
            if isPlaying { play() }
        }
    }

    func goToChapter(_ index: Int) {
        guard index >= 0 && index < chapters.count else { return }
        currentChapterIndex = index
        loadChapter(at: index)
        play()
    }

    func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        audioPlayer?.rate = speed
        updateNowPlayingInfo()
    }

    // MARK: - Sleep Timer

    func setSleepTimer(minutes: Int?) {
        sleepTimerMinutes = minutes
        sleepTimer?.invalidate()

        guard let minutes = minutes else {
            sleepTimerRemaining = 0
            return
        }

        sleepTimerRemaining = TimeInterval(minutes * 60)
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.sleepTimerRemaining -= 1
            if self.sleepTimerRemaining <= 0 {
                self.pause()
                self.sleepTimer?.invalidate()
                self.sleepTimerMinutes = nil
            }
        }
    }

    var sleepTimerFormatted: String? {
        guard sleepTimerRemaining > 0 else { return nil }
        let mins = Int(sleepTimerRemaining) / 60
        let secs = Int(sleepTimerRemaining) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    // MARK: - Chapter Loading

    private func loadChapter(at index: Int) {
        currentTime = 0
        duration = chapters[index].duration
        // In production, load actual audio file:
        // if let url = Bundle.main.url(forResource: chapters[index].filename, withExtension: "m4a") {
        //     audioPlayer = try? AVAudioPlayer(contentsOf: url)
        //     audioPlayer?.enableRate = true
        //     audioPlayer?.prepareToPlay()
        //     duration = audioPlayer?.duration ?? chapters[index].duration
        // }
    }

    // MARK: - Progress Timer

    private func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            if let player = self.audioPlayer {
                self.currentTime = player.currentTime
            } else {
                self.currentTime += 0.5 * Double(self.playbackSpeed)
                if self.currentTime >= self.duration {
                    self.nextChapter()
                }
            }
        }
    }

    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Now Playing Info Center

    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentChapter.title
        info[MPMediaItemPropertyArtist] = "Luminous Attachment"
        info[MPMediaItemPropertyAlbumTitle] = "Luminous Attachment by Resonance"
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? playbackSpeed : 0
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote Command Center

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextChapter()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousChapter()
            return .success
        }
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.skipForward(30)
            return .success
        }
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.skipBackward(15)
            return .success
        }
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: event.positionTime)
            return .success
        }
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Default Chapters

    static func defaultChapters() -> [AudioChapter] {
        [
            AudioChapter(number: 1, title: "The Roots of Connection", duration: 1122, filename: "ch01"),
            AudioChapter(number: 2, title: "Your Attachment Story", duration: 1260, filename: "ch02"),
            AudioChapter(number: 3, title: "The Anxious Heart", duration: 1380, filename: "ch03"),
            AudioChapter(number: 4, title: "The Distant Shore", duration: 1440, filename: "ch04"),
            AudioChapter(number: 5, title: "The Storm Within", duration: 1200, filename: "ch05"),
            AudioChapter(number: 6, title: "Earned Security", duration: 1320, filename: "ch06"),
            AudioChapter(number: 7, title: "Rewiring Your Response", duration: 1500, filename: "ch07"),
            AudioChapter(number: 8, title: "The Language of Needs", duration: 1260, filename: "ch08"),
            AudioChapter(number: 9, title: "Boundaries as Love", duration: 1140, filename: "ch09"),
            AudioChapter(number: 10, title: "Rupture and Repair", duration: 1380, filename: "ch10"),
            AudioChapter(number: 11, title: "The Luminous Thread", duration: 1440, filename: "ch11"),
            AudioChapter(number: 12, title: "Becoming Home", duration: 1080, filename: "ch12"),
        ]
    }
}

// MARK: - Audio Chapter Model

struct AudioChapter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let duration: TimeInterval
    let filename: String

    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audiobook Player View

struct AudiobookPlayerView: View {
    @State private var player = AudiobookPlayer()
    @State private var showChapters = false
    @State private var showSpeedPicker = false
    @State private var showSleepTimer = false

    private let green900 = Color(red: 10/255, green: 28/255, blue: 20/255)
    private let green800 = Color(red: 18/255, green: 46/255, blue: 33/255)
    private let gold = Color(red: 197/255, green: 160/255, blue: 89/255)
    private let goldLight = Color(red: 230/255, green: 208/255, blue: 161/255)
    private let cream = Color(red: 250/255, green: 250/255, blue: 248/255)

    var body: some View {
        VStack(spacing: 0) {
            // Album Art
            ZStack {
                LinearGradient(colors: [green800, green900], startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .fill(gold.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: -40, y: -30)
                VStack(spacing: 8) {
                    Text("Luminous")
                        .font(.system(.largeTitle, design: .serif))
                        .foregroundColor(cream)
                    Text("Attachment")
                        .font(.system(.title2, design: .serif))
                        .foregroundColor(gold)
                    Text("by Resonance")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(cream.opacity(0.5))
                }
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 32)
            .padding(.top, 16)

            // Chapter Title
            VStack(spacing: 4) {
                Text("Chapter \(player.currentChapter.number)")
                    .font(.system(.caption, design: .default))
                    .foregroundColor(gold)
                Text(player.currentChapter.title)
                    .font(.system(.title3, design: .serif))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)

            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(green800.opacity(0.3)).frame(height: 4)
                        Capsule().fill(gold).frame(width: geo.size.width * player.progress, height: 4)
                    }
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        let progress = max(0, min(1, value.location.x / geo.size.width))
                        player.seekToProgress(progress)
                    })
                }
                .frame(height: 4)
                HStack {
                    Text(player.currentTimeFormatted).font(.system(.caption2, design: .monospaced))
                    Spacer()
                    Text(player.durationFormatted).font(.system(.caption2, design: .monospaced))
                }
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.top, 20)

            // Controls
            HStack(spacing: 32) {
                Button { player.previousChapter() } label: {
                    Image(systemName: "backward.end.fill").font(.title3)
                }
                Button { player.skipBackward() } label: {
                    Image(systemName: "gobackward.15").font(.title2)
                }
                Button { player.togglePlayPause() } label: {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(gold)
                }
                Button { player.skipForward() } label: {
                    Image(systemName: "goforward.30").font(.title2)
                }
                Button { player.nextChapter() } label: {
                    Image(systemName: "forward.end.fill").font(.title3)
                }
            }
            .padding(.top, 24)

            // Speed & Sleep
            HStack(spacing: 24) {
                Button { showSpeedPicker.toggle() } label: {
                    Text("\(player.playbackSpeed, specifier: "%.1f")x")
                        .font(.system(.caption, design: .monospaced))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                Button { showChapters.toggle() } label: {
                    Image(systemName: "list.bullet")
                        .padding(8).background(.ultraThinMaterial, in: Circle())
                }
                Button { showSleepTimer.toggle() } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "moon.zzz")
                        if let remaining = player.sleepTimerFormatted {
                            Text(remaining).font(.system(.caption2, design: .monospaced)).foregroundColor(gold)
                        }
                    }
                    .padding(8).background(.ultraThinMaterial, in: Circle())
                }
            }
            .padding(.top, 20)

            Spacer()
        }
        .sheet(isPresented: $showChapters) {
            NavigationStack {
                List(Array(player.chapters.enumerated()), id: \.element.id) { index, chapter in
                    Button {
                        player.goToChapter(index)
                        showChapters = false
                    } label: {
                        HStack {
                            Text("\(chapter.number)").font(.system(.caption, design: .monospaced)).foregroundColor(gold).frame(width: 28)
                            Text(chapter.title).font(.system(.body, design: .serif))
                            Spacer()
                            Text(chapter.durationFormatted).font(.caption).foregroundColor(.secondary)
                            if index == player.currentChapterIndex {
                                Image(systemName: "speaker.wave.2.fill").foregroundColor(gold).font(.caption)
                            }
                        }
                    }
                }
                .navigationTitle("Chapters")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .confirmationDialog("Playback Speed", isPresented: $showSpeedPicker) {
            ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { speed in
                Button("\(speed, specifier: "%.2g")x") { player.setPlaybackSpeed(Float(speed)) }
            }
        }
        .confirmationDialog("Sleep Timer", isPresented: $showSleepTimer) {
            Button("15 minutes") { player.setSleepTimer(minutes: 15) }
            Button("30 minutes") { player.setSleepTimer(minutes: 30) }
            Button("45 minutes") { player.setSleepTimer(minutes: 45) }
            Button("1 hour") { player.setSleepTimer(minutes: 60) }
            Button("Cancel timer") { player.setSleepTimer(minutes: nil) }
        }
    }
}
