// AudioEngine.swift
// Haute Lumière — Audio & Soundscape Engine

import SwiftUI
import AVFoundation
import Combine

/// Manages all audio playback including guided sessions, soundscapes,
/// binaural beats generation, and sound mixing
final class AudioEngine: ObservableObject {
    // MARK: - Published State
    @Published var isPlaying: Bool = false
    @Published var currentSessionTitle: String = ""
    @Published var currentSessionType: SessionType?
    @Published var elapsed: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var progress: Double = 0
    @Published var volume: Float = 0.8

    // Soundscape mixing
    @Published var activeSoundscapes: [ActiveSoundscape] = []
    @Published var binauralEnabled: Bool = false
    @Published var binauralFrequency: Double = 4.0 // Hz (theta default)

    // Mini player
    @Published var showMiniPlayer: Bool = false

    // MARK: - Audio Session
    private var audioSession: AVAudioSession { AVAudioSession.sharedInstance() }
    private var timer: Timer?
    private var audioPlayers: [UUID: AVAudioPlayer] = [:]

    struct ActiveSoundscape: Identifiable {
        let id: UUID
        let type: SoundscapeType
        var volume: Float
        var isPlaying: Bool

        init(type: SoundscapeType, volume: Float = 0.7) {
            self.id = UUID()
            self.type = type
            self.volume = volume
            self.isPlaying = true
        }
    }

    // MARK: - Initialization
    init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Playback Control
    func play(session title: String, type: SessionType, durationMinutes: Int) {
        currentSessionTitle = title
        currentSessionType = type
        duration = TimeInterval(durationMinutes * 60)
        elapsed = 0
        isPlaying = true
        showMiniPlayer = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, self.isPlaying else { return }
            self.elapsed += 1
            self.progress = self.elapsed / self.duration
            if self.elapsed >= self.duration {
                self.completeSession()
            }
        }
    }

    func pause() {
        isPlaying = false
        timer?.invalidate()
    }

    func resume() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self, self.isPlaying else { return }
            self.elapsed += 1
            self.progress = self.elapsed / self.duration
            if self.elapsed >= self.duration {
                self.completeSession()
            }
        }
    }

    func stop() {
        isPlaying = false
        timer?.invalidate()
        elapsed = 0
        progress = 0
        showMiniPlayer = false
    }

    func seek(to progress: Double) {
        elapsed = duration * progress
        self.progress = progress
    }

    private func completeSession() {
        isPlaying = false
        timer?.invalidate()
        progress = 1.0
        // Trigger completion haptics and notification
    }

    // MARK: - Soundscape Mixing
    func addSoundscape(_ type: SoundscapeType, volume: Float = 0.7) {
        let scape = ActiveSoundscape(type: type, volume: volume)
        activeSoundscapes.append(scape)
    }

    func removeSoundscape(_ id: UUID) {
        activeSoundscapes.removeAll { $0.id == id }
    }

    func updateSoundscapeVolume(_ id: UUID, volume: Float) {
        if let index = activeSoundscapes.firstIndex(where: { $0.id == id }) {
            activeSoundscapes[index].volume = volume
        }
    }

    func clearAllSoundscapes() {
        activeSoundscapes.removeAll()
    }

    // MARK: - Binaural Beats
    func startBinauralBeats(frequency: Double) {
        binauralFrequency = frequency
        binauralEnabled = true
        // In production: Use AVAudioEngine with two oscillators
        // Left ear: base frequency (e.g., 200 Hz)
        // Right ear: base + binaural frequency (e.g., 204 Hz for 4 Hz theta)
    }

    func stopBinauralBeats() {
        binauralEnabled = false
    }

    // MARK: - Formatted Time
    var elapsedFormatted: String {
        formatTime(elapsed)
    }

    var remainingFormatted: String {
        formatTime(max(0, duration - elapsed))
    }

    var durationFormatted: String {
        formatTime(duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
