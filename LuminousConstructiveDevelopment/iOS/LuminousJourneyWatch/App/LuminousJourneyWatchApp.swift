// MARK: - Luminous Journey™ watchOS App
// Micro-interactions: somatic check-ins, breathing entrainment, season tracking.
// 3-screen carousel: Somatic Check-In | Breathing Entrainment | Current Season

import SwiftUI

@main
struct LuminousJourneyWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
    }
}

// MARK: - Watch Home (3-Screen Carousel)

struct WatchHomeView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            SomaticCheckInWatch()
                .tag(0)
            BreathingEntrainmentWatch()
                .tag(1)
            SeasonTrackerWatch()
                .tag(2)
        }
        .tabViewStyle(.verticalPage)
    }
}

// MARK: - Screen 1: Somatic Check-In

struct SomaticCheckInWatch: View {
    @State private var selectedArea: String?
    @State private var selectedIntensity: Double = 0.5

    let bodyAreas = ["Head", "Jaw", "Chest", "Belly", "Shoulders", "Hands"]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Body Check-In")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(Color(hex: "C5A059"))

                Text("Where do you\nnotice sensation?")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 55))], spacing: 8) {
                    ForEach(bodyAreas, id: \.self) { area in
                        Button(action: { selectedArea = area }) {
                            Text(area)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(selectedArea == area ? Color(hex: "FAFAF8") : Color(hex: "8A9C91"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedArea == area
                                            ? Color(hex: "1B402E")
                                            : Color(hex: "1B402E").opacity(0.2))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                if selectedArea != nil {
                    VStack(spacing: 4) {
                        Text("Intensity")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Slider(value: $selectedIntensity, in: 0...1)
                            .tint(Color(hex: "C5A059"))
                    }

                    Button(action: { /* Log somatic state + haptic */ }) {
                        Text("Log")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "FAFAF8"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(hex: "1B402E"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Screen 2: Breathing Entrainment (matches iPAD patient entrainment)

struct BreathingEntrainmentWatch: View {
    @State private var isBreathing = false
    @State private var orbScale: CGFloat = 0.6
    @State private var phase: BreathPhase = .inhale

    enum BreathPhase: String {
        case inhale = "Inhale"
        case hold = "Hold"
        case exhale = "Exhale"
        case rest = "Rest"
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(phase.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "C5A059"))
                .animation(.easeInOut, value: phase)

            // Breathing orb (matches patient RSD Lightning Protocol orb)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "C5A059").opacity(0.3),
                                Color(hex: "1B402E").opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(orbScale)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "C5A059"), Color(hex: "1B402E")],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(orbScale)
            }

            Button(action: { toggleBreathing() }) {
                Text(isBreathing ? "Stop" : "Begin")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "FAFAF8"))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(Color(hex: "1B402E"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleBreathing() {
        isBreathing.toggle()
        if isBreathing {
            startBreathCycle()
        }
    }

    private func startBreathCycle() {
        guard isBreathing else { return }
        // 4-7-8 pattern
        phase = .inhale
        withAnimation(.easeInOut(duration: 4)) { orbScale = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            guard self.isBreathing else { return }
            self.phase = .hold
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                guard self.isBreathing else { return }
                self.phase = .exhale
                withAnimation(.easeInOut(duration: 8)) { self.orbScale = 0.6 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    guard self.isBreathing else { return }
                    self.phase = .rest
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.startBreathCycle()
                    }
                }
            }
        }
    }
}

// MARK: - Screen 3: Season Tracker

struct SeasonTrackerWatch: View {
    @State private var currentSeason: SomaticSeason = .compression

    var body: some View {
        VStack(spacing: 12) {
            Text("Season")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .textCase(.uppercase)

            Text(currentSeason.rawValue)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(Color(hex: "C5A059"))

            Circle()
                .fill(seasonColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: seasonIcon)
                        .foregroundColor(Color(hex: "FAFAF8"))
                )

            Text(currentSeason.description)
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(3)

            // Season selector
            HStack(spacing: 6) {
                ForEach(SomaticSeason.allCases, id: \.self) { season in
                    Button(action: { currentSeason = season }) {
                        Circle()
                            .fill(season == currentSeason ? seasonColorFor(season) : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var seasonColor: Color { seasonColorFor(currentSeason) }

    private func seasonColorFor(_ season: SomaticSeason) -> Color {
        switch season {
        case .compression: return Color(hex: "8A5A4A")
        case .trembling:   return Color(hex: "B07A5A")
        case .emptiness:   return Color(hex: "A8B5AD")
        case .emergence:   return Color(hex: "4A9A6A")
        case .integration: return Color(hex: "C5A059")
        }
    }

    private var seasonIcon: String {
        switch currentSeason {
        case .compression: return "arrow.down.to.line"
        case .trembling:   return "waveform"
        case .emptiness:   return "circle.dashed"
        case .emergence:   return "leaf"
        case .integration: return "infinity"
        }
    }
}

// MARK: - Watch Complications

import ClockKit

struct LuminousComplicationDescriptor {
    static let somatic = CLKComplicationDescriptor(
        identifier: "com.luminous.journey.somatic",
        displayName: "Somatic Check-In",
        supportedFamilies: [.graphicCircular, .graphicCorner, .graphicBezel, .modularSmall]
    )

    static let season = CLKComplicationDescriptor(
        identifier: "com.luminous.journey.season",
        displayName: "Current Season",
        supportedFamilies: [.graphicCircular, .graphicCorner, .modularSmall]
    )

    static let breathe = CLKComplicationDescriptor(
        identifier: "com.luminous.journey.breathe",
        displayName: "Breathe",
        supportedFamilies: [.graphicCircular, .graphicBezel]
    )
}

// MARK: - Color Extension for Watch

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

// MARK: - Somatic Season (duplicated for watch target)

enum SomaticSeason: String, CaseIterable {
    case compression = "Compression"
    case trembling = "Trembling"
    case emptiness = "Emptiness"
    case emergence = "Emergence"
    case integration = "Integration"

    var description: String {
        switch self {
        case .compression: return "Increasing tension. Something strains."
        case .trembling: return "Between structures. Waves of feeling."
        case .emptiness: return "Stillness. Not-yet-knowing."
        case .emergence: return "New patterns forming in the body."
        case .integration: return "Settling into a new home."
        }
    }
}
