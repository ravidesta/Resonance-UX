// ResonanceTVApp.swift
// Resonance UX — tvOS Living Room Experience
//
// Ambient wellness display for shared spaces. Guided breathwork
// via Siri Remote, immersive retreat content, family wellness
// dashboards, and soundscape integration. Designed to transform
// the television from a source of stimulation into a tool for
// collective regulation.

import SwiftUI

// MARK: - tvOS App Entry Point

@main
struct ResonanceTVApp: App {
    @StateObject private var tvState = TVAppState()

    var body: some Scene {
        WindowGroup {
            TVContentView()
                .environmentObject(tvState)
        }
    }
}

// MARK: - TV App State

class TVAppState: ObservableObject {
    @Published var currentMode: TVMode = .ambient
    @Published var familyFrequency: Double = 7.0
    @Published var activeSoundscape: Soundscape? = nil
    @Published var isBreathworkActive: Bool = false
    @Published var breathworkTechnique: TVBreathworkTechnique = .coherence
    @Published var focusModeActive: Bool = false
    @Published var focusModeOwner: String = ""
    @Published var ambientTheme: AmbientTheme = .forest

    enum TVMode: String, CaseIterable, Identifiable {
        case ambient    = "Ambient"
        case breathwork = "Breathwork"
        case retreats   = "Retreats"
        case family     = "Family"
        case focus      = "Focus"
        case soundscape = "Soundscape"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .ambient:    return "sparkles.tv"
            case .breathwork: return "wind"
            case .retreats:   return "leaf.circle"
            case .family:     return "person.3"
            case .focus:      return "eye"
            case .soundscape: return "waveform"
            }
        }

        var description: String {
            switch self {
            case .ambient:    return "Gentle visual presence"
            case .breathwork: return "Guided breathing sessions"
            case .retreats:   return "Immersive content"
            case .family:     return "Collective wellness"
            case .focus:      return "Shared focus environment"
            case .soundscape: return "Ambient sound layers"
            }
        }
    }

    enum AmbientTheme: String, CaseIterable {
        case forest   = "Forest"
        case ocean    = "Ocean"
        case mountain = "Mountain"
        case desert   = "Desert"
        case aurora   = "Aurora"

        var primaryColor: Color {
            switch self {
            case .forest:   return Color(hex: 0x122E21)
            case .ocean:    return Color(hex: 0x0A1C3C)
            case .mountain: return Color(hex: 0x2C2C3A)
            case .desert:   return Color(hex: 0xC5A059)
            case .aurora:   return Color(hex: 0x1A3A2A)
            }
        }

        var secondaryColor: Color {
            switch self {
            case .forest:   return Color(hex: 0xC5A059)
            case .ocean:    return Color(hex: 0x5C8FA0)
            case .mountain: return Color(hex: 0x8A8A9A)
            case .desert:   return Color(hex: 0xE8D5B0)
            case .aurora:   return Color(hex: 0x6ABFA0)
            }
        }
    }
}

// MARK: - Soundscape

struct Soundscape: Identifiable {
    let id = UUID()
    var name: String
    var layers: [SoundLayer]
    var duration: TimeInterval?  // nil = infinite

    struct SoundLayer: Identifiable {
        let id = UUID()
        var name: String
        var volume: Double  // 0.0 – 1.0
        var icon: String
    }

    static let samples: [Soundscape] = [
        Soundscape(name: "Forest Rain", layers: [
            .init(name: "Rain", volume: 0.7, icon: "cloud.rain"),
            .init(name: "Leaves", volume: 0.3, icon: "leaf"),
            .init(name: "Bird calls", volume: 0.15, icon: "bird"),
            .init(name: "Thunder (distant)", volume: 0.1, icon: "cloud.bolt"),
        ]),
        Soundscape(name: "Ocean Depth", layers: [
            .init(name: "Waves", volume: 0.6, icon: "water.waves"),
            .init(name: "Undertow", volume: 0.3, icon: "arrow.down.forward"),
            .init(name: "Whale song", volume: 0.2, icon: "waveform"),
        ]),
        Soundscape(name: "Mountain Stillness", layers: [
            .init(name: "Wind", volume: 0.4, icon: "wind"),
            .init(name: "Stream", volume: 0.3, icon: "drop"),
            .init(name: "Crickets", volume: 0.15, icon: "ant"),
        ]),
        Soundscape(name: "Deep Rest", layers: [
            .init(name: "Brown noise", volume: 0.5, icon: "waveform.path"),
            .init(name: "Heartbeat", volume: 0.2, icon: "heart"),
            .init(name: "Breathing", volume: 0.15, icon: "wind"),
        ]),
    ]
}

// MARK: - TV Breathwork Technique

enum TVBreathworkTechnique: String, CaseIterable, Identifiable {
    case coherence     = "Coherence"
    case fourSevenEight = "4-7-8"
    case boxBreathing  = "Box Breathing"
    case resonant      = "Resonant"

    var id: String { rawValue }

    var inhale: TimeInterval {
        switch self {
        case .coherence:      return 5
        case .fourSevenEight: return 4
        case .boxBreathing:   return 4
        case .resonant:       return 5.5
        }
    }

    var hold: TimeInterval {
        switch self {
        case .coherence:      return 0
        case .fourSevenEight: return 7
        case .boxBreathing:   return 4
        case .resonant:       return 0
        }
    }

    var exhale: TimeInterval {
        switch self {
        case .coherence:      return 5
        case .fourSevenEight: return 8
        case .boxBreathing:   return 4
        case .resonant:       return 5.5
        }
    }

    var description: String {
        switch self {
        case .coherence:      return "5 seconds in, 5 seconds out. Balances the autonomic nervous system."
        case .fourSevenEight: return "4 in, 7 hold, 8 out. Activates the parasympathetic response."
        case .boxBreathing:   return "4 in, 4 hold, 4 out, 4 hold. Navy SEAL regulation technique."
        case .resonant:       return "5.5 seconds in, 5.5 seconds out. Matches the body's resonant frequency."
        }
    }
}

// MARK: - TV Content View

struct TVContentView: View {
    @EnvironmentObject private var tvState: TVAppState

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen ambient background
                ambientBackground

                VStack {
                    // Top bar
                    topBar
                        .padding(.horizontal, 60)
                        .padding(.top, 40)

                    Spacer()

                    // Mode content
                    modeContent

                    Spacer()

                    // Bottom mode selector (Siri Remote navigable)
                    modeSelector
                        .padding(.horizontal, 60)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Ambient Background

    private var ambientBackground: some View {
        ZStack {
            Color(hex: 0x05100B)
                .ignoresSafeArea()

            // Animated gradient background
            TimelineView(.animation(minimumInterval: 1.0 / 15.0)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate

                    // Layer 1 — slow drift
                    let grad1Center = CGPoint(
                        x: size.width * (0.3 + sin(time * 0.1) * 0.2),
                        y: size.height * (0.4 + cos(time * 0.08) * 0.2)
                    )
                    let gradient1 = Gradient(colors: [
                        tvState.ambientTheme.primaryColor.opacity(0.25),
                        Color.clear
                    ])
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: grad1Center.x - size.width * 0.4,
                            y: grad1Center.y - size.height * 0.4,
                            width: size.width * 0.8,
                            height: size.height * 0.8
                        )),
                        with: .radialGradient(gradient1, center: grad1Center, startRadius: 0, endRadius: size.width * 0.4)
                    )

                    // Layer 2 — secondary drift
                    let grad2Center = CGPoint(
                        x: size.width * (0.7 + cos(time * 0.07) * 0.15),
                        y: size.height * (0.6 + sin(time * 0.12) * 0.15)
                    )
                    let gradient2 = Gradient(colors: [
                        tvState.ambientTheme.secondaryColor.opacity(0.12),
                        Color.clear
                    ])
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: grad2Center.x - size.width * 0.35,
                            y: grad2Center.y - size.height * 0.35,
                            width: size.width * 0.7,
                            height: size.height * 0.7
                        )),
                        with: .radialGradient(gradient2, center: grad2Center, startRadius: 0, endRadius: size.width * 0.35)
                    )
                }
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Resonance")
                    .font(.custom("Cormorant Garamond", size: 36).weight(.light))
                    .foregroundColor(.white)

                Text(tvState.currentMode.description)
                    .font(.custom("Manrope", size: 16))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            // Family frequency
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Family Frequency")
                        .font(.custom("Manrope", size: 12).weight(.medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1.0)

                    Text(String(format: "%.1f", tvState.familyFrequency))
                        .font(.custom("Manrope", size: 28).weight(.light))
                        .foregroundColor(Color(hex: 0xC5A059))
                }

                // Mini frequency ring
                ZStack {
                    Circle()
                        .stroke(Color(hex: 0xC5A059).opacity(0.15), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    Circle()
                        .trim(from: 0, to: tvState.familyFrequency / 10.0)
                        .stroke(Color(hex: 0xC5A059), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                }
            }

            // Phase indicator
            if tvState.focusModeActive {
                HStack(spacing: 8) {
                    Image(systemName: "eye")
                        .foregroundColor(Color(hex: 0xC5A059))
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Focus Mode")
                            .font(.custom("Manrope", size: 14).weight(.semibold))
                            .foregroundColor(.white)
                        Text("\(tvState.focusModeOwner) is in deep work")
                            .font(.custom("Manrope", size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: 0xC5A059).opacity(0.1))
                )
            }
        }
    }

    // MARK: - Mode Content

    @ViewBuilder
    private var modeContent: some View {
        switch tvState.currentMode {
        case .ambient:
            ambientContent
        case .breathwork:
            breathworkContent
        case .retreats:
            retreatsContent
        case .family:
            familyContent
        case .focus:
            focusContent
        case .soundscape:
            soundscapeContent
        }
    }

    // MARK: Ambient

    private var ambientContent: some View {
        VStack(spacing: 20) {
            // Large organic blob
            TVOrganicBlob(
                primaryColor: tvState.ambientTheme.primaryColor,
                secondaryColor: tvState.ambientTheme.secondaryColor
            )
            .frame(width: 400, height: 400)

            // Current time
            Text(Date().formatted(date: .omitted, time: .shortened))
                .font(.custom("Cormorant Garamond", size: 64).weight(.light))
                .foregroundColor(.white.opacity(0.6))

            // Theme selector
            HStack(spacing: 16) {
                ForEach(TVAppState.AmbientTheme.allCases, id: \.self) { theme in
                    Button {
                        withAnimation(.easeInOut(duration: 2.0)) {
                            tvState.ambientTheme = theme
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(theme.primaryColor)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle().stroke(theme == tvState.ambientTheme ? Color.white : Color.clear, lineWidth: 2)
                                )
                            Text(theme.rawValue)
                                .font(.custom("Manrope", size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
    }

    // MARK: Breathwork

    private var breathworkContent: some View {
        VStack(spacing: 30) {
            if tvState.isBreathworkActive {
                activeBreathworkView
            } else {
                breathworkSelectionView
            }
        }
    }

    private var breathworkSelectionView: some View {
        VStack(spacing: 24) {
            Text("Guided Breathwork")
                .font(.custom("Cormorant Garamond", size: 48).weight(.light))
                .foregroundColor(.white)

            Text("Use the Siri Remote to select a technique")
                .font(.custom("Manrope", size: 16))
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 24) {
                ForEach(TVBreathworkTechnique.allCases) { technique in
                    Button {
                        tvState.breathworkTechnique = technique
                        withAnimation(.easeInOut(duration: 0.5)) {
                            tvState.isBreathworkActive = true
                        }
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "wind")
                                .font(.system(size: 32, weight: .ultraLight))
                                .foregroundColor(Color(hex: 0xC5A059))

                            Text(technique.rawValue)
                                .font(.custom("Manrope", size: 18).weight(.semibold))
                                .foregroundColor(.white)

                            Text(technique.description)
                                .font(.custom("Manrope", size: 13))
                                .foregroundColor(.white.opacity(0.4))
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        .frame(width: 200)
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.06))
                                )
                        )
                    }
                }
            }
        }
    }

    private var activeBreathworkView: some View {
        TVBreathworkActiveView(technique: tvState.breathworkTechnique) {
            withAnimation(.easeInOut(duration: 0.5)) {
                tvState.isBreathworkActive = false
            }
        }
    }

    // MARK: Retreats

    private var retreatsContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 32) {
                ForEach(TVRetreat.samples) { retreat in
                    Button {
                        // Open retreat detail
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: 0x122E21), Color(hex: 0xC5A059).opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 400, height: 225)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white.opacity(0.8))
                                            Spacer()
                                        }
                                        .padding(16)
                                    }
                                )

                            Text(retreat.name)
                                .font(.custom("Cormorant Garamond", size: 24))
                                .foregroundColor(.white)

                            Text(retreat.description)
                                .font(.custom("Manrope", size: 14))
                                .foregroundColor(.white.opacity(0.4))
                                .lineLimit(2)

                            Text(retreat.duration)
                                .font(.custom("Manrope", size: 12))
                                .foregroundColor(Color(hex: 0xC5A059))
                        }
                        .frame(width: 400)
                    }
                }
            }
            .padding(.horizontal, 80)
        }
    }

    // MARK: Family

    private var familyContent: some View {
        VStack(spacing: 32) {
            Text("Family Wellness")
                .font(.custom("Cormorant Garamond", size: 48).weight(.light))
                .foregroundColor(.white)

            HStack(spacing: 40) {
                ForEach(FamilyMember.samples) { member in
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: 0xC5A059).opacity(member.frequency / 10.0), Color.clear],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Circle()
                                .stroke(Color(hex: 0xC5A059).opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)

                            Text(member.initials)
                                .font(.custom("Manrope", size: 24).weight(.semibold))
                                .foregroundColor(.white)
                        }

                        Text(member.name)
                            .font(.custom("Manrope", size: 16).weight(.medium))
                            .foregroundColor(.white)

                        Text(String(format: "%.1f", member.frequency))
                            .font(.custom("Manrope", size: 28).weight(.light))
                            .foregroundColor(Color(hex: 0xC5A059))

                        Text(member.status)
                            .font(.custom("Manrope", size: 12))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }

            // Family average
            VStack(spacing: 8) {
                Text("COLLECTIVE FREQUENCY")
                    .font(.custom("Manrope", size: 12).weight(.semibold))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(2.0)

                Text(String(format: "%.1f", tvState.familyFrequency))
                    .font(.custom("Cormorant Garamond", size: 72).weight(.light))
                    .foregroundColor(Color(hex: 0xC5A059))
            }
        }
    }

    // MARK: Focus

    private var focusContent: some View {
        VStack(spacing: 24) {
            if tvState.focusModeActive {
                VStack(spacing: 16) {
                    Image(systemName: "eye")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundColor(Color(hex: 0xC5A059))

                    Text("\(tvState.focusModeOwner) is in deep work")
                        .font(.custom("Cormorant Garamond", size: 36).weight(.light))
                        .foregroundColor(.white)

                    Text("The household is holding space for focus")
                        .font(.custom("Manrope", size: 16))
                        .foregroundColor(.white.opacity(0.4))

                    // Ambient indicator
                    TVOrganicBlob(
                        primaryColor: Color(hex: 0x122E21),
                        secondaryColor: Color(hex: 0xC5A059).opacity(0.3)
                    )
                    .frame(width: 200, height: 200)
                }
            } else {
                VStack(spacing: 16) {
                    Text("Focus Mode")
                        .font(.custom("Cormorant Garamond", size: 48).weight(.light))
                        .foregroundColor(.white)

                    Text("Activate to signal deep work to the household")
                        .font(.custom("Manrope", size: 16))
                        .foregroundColor(.white.opacity(0.4))

                    Button {
                        tvState.focusModeActive = true
                        tvState.focusModeOwner = "You"
                    } label: {
                        Text("Enter Focus")
                            .font(.custom("Manrope", size: 18).weight(.semibold))
                            .foregroundColor(Color(hex: 0x05100B))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                Capsule().fill(Color(hex: 0xC5A059))
                            )
                    }
                }
            }
        }
    }

    // MARK: Soundscape

    private var soundscapeContent: some View {
        VStack(spacing: 24) {
            Text("Soundscapes")
                .font(.custom("Cormorant Garamond", size: 48).weight(.light))
                .foregroundColor(.white)

            HStack(spacing: 24) {
                ForEach(Soundscape.samples) { scape in
                    Button {
                        tvState.activeSoundscape = scape
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .font(.system(size: 28, weight: .ultraLight))
                                .foregroundColor(Color(hex: 0xC5A059))

                            Text(scape.name)
                                .font(.custom("Manrope", size: 16).weight(.semibold))
                                .foregroundColor(.white)

                            // Layer icons
                            HStack(spacing: 6) {
                                ForEach(scape.layers) { layer in
                                    Image(systemName: layer.icon)
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(layer.volume))
                                }
                            }
                        }
                        .frame(width: 180)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(tvState.activeSoundscape?.id == scape.id
                                    ? Color(hex: 0xC5A059).opacity(0.1)
                                    : Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(tvState.activeSoundscape?.id == scape.id
                                            ? Color(hex: 0xC5A059).opacity(0.3)
                                            : Color.white.opacity(0.06))
                                )
                        )
                    }
                }
            }

            // Active soundscape mixer
            if let scape = tvState.activeSoundscape {
                VStack(spacing: 12) {
                    Text("Now Playing: \(scape.name)")
                        .font(.custom("Manrope", size: 14))
                        .foregroundColor(Color(hex: 0xC5A059))

                    HStack(spacing: 24) {
                        ForEach(scape.layers) { layer in
                            VStack(spacing: 6) {
                                Image(systemName: layer.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(layer.volume))

                                // Volume bar
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color(hex: 0xC5A059).opacity(0.15))
                                    .frame(width: 4, height: 40)
                                    .overlay(alignment: .bottom) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(hex: 0xC5A059))
                                            .frame(width: 4, height: 40 * layer.volume)
                                    }

                                Text(layer.name)
                                    .font(.custom("Manrope", size: 10))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        HStack(spacing: 16) {
            ForEach(TVAppState.TVMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        tvState.currentMode = mode
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 22, weight: tvState.currentMode == mode ? .regular : .ultraLight))
                            .foregroundColor(tvState.currentMode == mode ? Color(hex: 0xC5A059) : .white.opacity(0.3))

                        Text(mode.rawValue)
                            .font(.custom("Manrope", size: 12))
                            .foregroundColor(tvState.currentMode == mode ? .white : .white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06))
                )
        )
    }
}

// MARK: - TV Breathwork Active View

struct TVBreathworkActiveView: View {
    let technique: TVBreathworkTechnique
    let onStop: () -> Void

    @State private var breathPhase: String = "Breathe in"
    @State private var circleScale: CGFloat = 0.5
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?
    @State private var cycleCount: Int = 0

    var body: some View {
        VStack(spacing: 24) {
            // Technique name
            Text(technique.rawValue)
                .font(.custom("Manrope", size: 14).weight(.semibold))
                .foregroundColor(Color(hex: 0xC5A059).opacity(0.6))
                .tracking(2.0)

            // Breathing circle
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color(hex: 0xC5A059).opacity(0.1), lineWidth: 2)
                    .frame(width: 300, height: 300)

                // Breathing fill
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: 0xC5A059).opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(circleScale)

                VStack(spacing: 8) {
                    Text(breathPhase)
                        .font(.custom("Cormorant Garamond", size: 32).weight(.light))
                        .foregroundColor(.white)

                    Text(formatTime(elapsed))
                        .font(.custom("Manrope", size: 16).weight(.light))
                        .foregroundColor(.white.opacity(0.4))
                        .monospacedDigit()
                }
            }

            // Cycle count
            Text("Cycle \(cycleCount)")
                .font(.custom("Manrope", size: 14))
                .foregroundColor(.white.opacity(0.3))

            // Stop button (Siri Remote clickable)
            Button(action: {
                timer?.invalidate()
                onStop()
            }) {
                Text("End Session")
                    .font(.custom("Manrope", size: 16).weight(.medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
            }
        }
        .onAppear { startBreathCycle() }
        .onDisappear { timer?.invalidate() }
    }

    private func startBreathCycle() {
        func runPhase(_ label: String, _ duration: TimeInterval, _ targetScale: CGFloat, next: @escaping () -> Void) {
            breathPhase = label
            withAnimation(.easeInOut(duration: duration)) {
                circleScale = targetScale
            }
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                elapsed += duration
                next()
            }
        }

        func cycle() {
            cycleCount += 1
            runPhase("Breathe in", technique.inhale, 1.0) {
                if technique.hold > 0 {
                    runPhase("Hold", technique.hold, 1.0) {
                        runPhase("Breathe out", technique.exhale, 0.5) {
                            cycle()
                        }
                    }
                } else {
                    runPhase("Breathe out", technique.exhale, 0.5) {
                        cycle()
                    }
                }
            }
        }

        cycle()
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - TV Organic Blob

struct TVOrganicBlob: View {
    var primaryColor: Color
    var secondaryColor: Color

    @State private var scale: CGFloat = 0.9

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let baseRadius = min(size.width, size.height) * 0.35
                let time = timeline.date.timeIntervalSinceReferenceDate

                for layer in 0..<4 {
                    let offset = Double(layer) * 0.8
                    let layerScale = 1.0 - Double(layer) * 0.12
                    let opacity = 0.25 - Double(layer) * 0.05

                    var path = Path()
                    let pointCount = 10
                    var points: [CGPoint] = []

                    for i in 0..<pointCount {
                        let angle = (Double(i) / Double(pointCount)) * .pi * 2
                        let noise = sin(time * 0.15 + offset + Double(i) * 1.1) * 0.12 + 1.0
                        let r = baseRadius * layerScale * noise
                        points.append(CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r))
                    }

                    guard points.count >= 3 else { continue }
                    path.move(to: CGPoint(
                        x: (points.last!.x + points[0].x) / 2,
                        y: (points.last!.y + points[0].y) / 2
                    ))
                    for i in 0..<points.count {
                        let next = points[(i + 1) % points.count]
                        let mid = CGPoint(x: (points[i].x + next.x) / 2, y: (points[i].y + next.y) / 2)
                        path.addQuadCurve(to: mid, control: points[i])
                    }
                    path.closeSubpath()

                    let color = layer % 2 == 0 ? primaryColor : secondaryColor
                    context.fill(path, with: .color(color.opacity(opacity)))
                }
            }
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

// MARK: - Supporting Models

struct FamilyMember: Identifiable {
    let id = UUID()
    var name: String
    var initials: String
    var frequency: Double
    var status: String

    static let samples: [FamilyMember] = [
        FamilyMember(name: "You", initials: "ME", frequency: 7.2, status: "Open to connect"),
        FamilyMember(name: "Partner", initials: "AK", frequency: 6.8, status: "In flow"),
        FamilyMember(name: "Child", initials: "LK", frequency: 8.1, status: "Playing"),
    ]
}

struct TVRetreat: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var duration: String

    static let samples: [TVRetreat] = [
        TVRetreat(name: "Nervous System Reset", description: "A guided 45-minute session combining breathwork, cold exposure visualization, and progressive relaxation.", duration: "45 minutes"),
        TVRetreat(name: "Forest Bathing", description: "Immersive visual and auditory forest environment with gentle movement prompts.", duration: "60 minutes"),
        TVRetreat(name: "Dawn Meditation", description: "Watch a real-time sunrise with synchronized breathing guidance.", duration: "30 minutes"),
        TVRetreat(name: "Sound Healing Journey", description: "Crystal bowl harmonics with binaural beats for deep parasympathetic activation.", duration: "40 minutes"),
    ]
}
