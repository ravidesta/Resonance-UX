// ResonanceWatchApp.swift
// Resonance UX — watchOS Companion
//
// Wrist-level nervous system awareness. Frequency complications,
// RSD Lightning Protocol as a 1-tap crisis tool, breathwork sync,
// and minimal vital display. Every haptic is intentional.

import SwiftUI
import ClockKit

// MARK: - watchOS App Entry Point

@main
struct ResonanceWatchApp: App {
    @StateObject private var watchState = WatchAppState()

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(watchState)
        }
    }
}

// MARK: - Watch App State

class WatchAppState: ObservableObject {
    @Published var currentFrequency: Double = 7.2
    @Published var intentionalStatus: WatchStatus = .openConnect
    @Published var activePhase: DailyPhaseKind = .ascend
    @Published var latestHRV: Double = 45.0
    @Published var cortisolTrend: CortisolTrend = .stable
    @Published var isBreathworkActive: Bool = false
    @Published var breathworkElapsed: TimeInterval = 0
    @Published var showRSDProtocol: Bool = false

    enum WatchStatus: String, CaseIterable {
        case deepWork    = "Deep work"
        case recharging  = "Recharging"
        case openConnect = "Open"
        case inFlow      = "In flow"

        var icon: String {
            switch self {
            case .deepWork:    return "eye.slash"
            case .recharging:  return "moon.zzz"
            case .openConnect: return "hand.wave"
            case .inFlow:      return "wind"
            }
        }
    }

    enum CortisolTrend: String {
        case rising, falling, stable
        var icon: String {
            switch self {
            case .rising: return "arrow.up.right"
            case .falling: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
    }

    func computePhase() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  activePhase = .ascend
        case 12..<15: activePhase = .zenith
        case 15..<20: activePhase = .descent
        default:      activePhase = .rest
        }
    }
}

// MARK: - Watch Content View

struct WatchContentView: View {
    @EnvironmentObject private var watchState: WatchAppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    frequencyHeader
                    phaseIndicator
                    vitalsRow
                    actionButtons
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Resonance")
            .sheet(isPresented: $watchState.showRSDProtocol) {
                WatchRSDView()
                    .environmentObject(watchState)
            }
            .onAppear {
                watchState.computePhase()
            }
        }
    }

    // MARK: - Frequency Header

    private var frequencyHeader: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.1f", watchState.currentFrequency))
                .font(.system(size: 42, weight: .light, design: .rounded))
                .foregroundColor(Color(hex: 0xC5A059))

            Text("FREQUENCY")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1.5)

            // Mini frequency bars
            HStack(spacing: 1.5) {
                ForEach(0..<15, id: \.self) { i in
                    let active = Double(i) / 15.0 < watchState.currentFrequency / 10.0
                    RoundedRectangle(cornerRadius: 1)
                        .fill(active ? Color(hex: 0xC5A059) : Color(hex: 0xC5A059).opacity(0.15))
                        .frame(width: 3, height: active ? 10 : 4)
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Phase Indicator

    private var phaseIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: watchState.activePhase.icon)
                .font(.system(size: 14))
                .foregroundColor(watchState.activePhase.color)

            VStack(alignment: .leading, spacing: 1) {
                Text(watchState.activePhase.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)

                Text(watchState.activePhase.timeRange)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Status indicator
            HStack(spacing: 3) {
                Circle()
                    .fill(Color(hex: 0xC5A059))
                    .frame(width: 5, height: 5)
                Text(watchState.intentionalStatus.rawValue)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.06))
        )
    }

    // MARK: - Vitals Row

    private var vitalsRow: some View {
        HStack(spacing: 8) {
            VitalCard(
                icon: "heart.fill",
                value: String(format: "%.0f", watchState.latestHRV),
                unit: "ms",
                label: "HRV",
                color: Color(hex: 0x122E21)
            )

            VitalCard(
                icon: "waveform.path.ecg",
                value: watchState.cortisolTrend.rawValue.capitalized,
                unit: "",
                label: "Cortisol",
                color: Color(hex: 0xC5A059),
                trendIcon: watchState.cortisolTrend.icon
            )
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 6) {
            // RSD Lightning — 1-tap crisis regulation
            Button {
                WKInterfaceDevice.current().play(.notification)
                watchState.showRSDProtocol = true
            } label: {
                HStack {
                    Image(systemName: "bolt.heart.fill")
                        .foregroundColor(.red)
                    Text("RSD Lightning")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red.opacity(0.15))
                )
            }
            .buttonStyle(.plain)

            // Breathwork
            Button {
                toggleBreathwork()
            } label: {
                HStack {
                    Image(systemName: watchState.isBreathworkActive ? "stop.fill" : "wind")
                        .foregroundColor(Color(hex: 0xC5A059))
                    Text(watchState.isBreathworkActive ? "Stop Breathwork" : "Start Breathwork")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: 0xC5A059).opacity(0.12))
                )
            }
            .buttonStyle(.plain)

            // Phase selector (Digital Crown scrollable)
            NavigationLink {
                WatchPhaseView()
                    .environmentObject(watchState)
            } label: {
                HStack {
                    Image(systemName: "circle.hexagongrid")
                        .foregroundColor(Color(hex: 0x5C7065))
                    Text("Daily Phases")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: 0x5C7065).opacity(0.12))
                )
            }
            .buttonStyle(.plain)

            // Status selector
            NavigationLink {
                WatchStatusView()
                    .environmentObject(watchState)
            } label: {
                HStack {
                    Image(systemName: watchState.intentionalStatus.icon)
                        .foregroundColor(.white.opacity(0.6))
                    Text("Set Status")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.06))
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleBreathwork() {
        if watchState.isBreathworkActive {
            watchState.isBreathworkActive = false
            watchState.breathworkElapsed = 0
            WKInterfaceDevice.current().play(.stop)
        } else {
            watchState.isBreathworkActive = true
            WKInterfaceDevice.current().play(.start)
        }
    }
}

// MARK: - Vital Card

struct VitalCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    var trendIcon: String? = nil

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
                if let trend = trendIcon {
                    Image(systemName: trend)
                        .font(.system(size: 9))
                        .foregroundColor(color)
                }
            }

            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Watch RSD Lightning Protocol

struct WatchRSDView: View {
    @EnvironmentObject private var watchState: WatchAppState
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 0
    @State private var breatheScale: CGFloat = 1.0

    private let steps: [(String, String, String)] = [
        ("Orient", "Look around.\n5 things you see.", "eye"),
        ("Ground", "Feet on floor.\nFeel gravity.", "arrow.down"),
        ("Breathe", "In: 4\nHold: 7\nOut: 8", "wind"),
        ("Contain", "Hand on chest.\nYou are safe.", "hand.raised"),
        ("Return", "This moment\nis manageable.", "checkmark.circle"),
    ]

    var body: some View {
        VStack(spacing: 8) {
            // Progress dots
            HStack(spacing: 4) {
                ForEach(0..<steps.count, id: \.self) { i in
                    Circle()
                        .fill(i <= currentStep ? Color(hex: 0xC5A059) : Color(hex: 0xC5A059).opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }

            let step = steps[currentStep]

            Image(systemName: step.2)
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(Color(hex: 0xC5A059))
                .scaleEffect(currentStep == 2 ? breatheScale : 1.0)

            Text(step.0)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)

            Text(step.1)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Spacer()

            Button {
                if currentStep < steps.count - 1 {
                    WKInterfaceDevice.current().play(.click)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep += 1
                    }
                } else {
                    WKInterfaceDevice.current().play(.success)
                    dismiss()
                }
            } label: {
                Text(currentStep < steps.count - 1 ? "Next" : "Regulated")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: 0xC5A059))
        }
        .padding(.horizontal, 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                breatheScale = 1.3
            }
        }
    }
}

// MARK: - Watch Phase View (Digital Crown Scrollable)

struct WatchPhaseView: View {
    @EnvironmentObject private var watchState: WatchAppState
    @State private var selectedPhaseIndex: Int = 0

    var body: some View {
        VStack(spacing: 8) {
            let phase = DailyPhaseKind.allCases[selectedPhaseIndex]

            Image(systemName: phase.icon)
                .font(.system(size: 32, weight: .ultraLight))
                .foregroundColor(phase.color)

            Text(phase.label)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)

            Text(phase.timeRange)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))

            Text(phase.intention)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)

            if phase == watchState.activePhase {
                Text("CURRENT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color(hex: 0xC5A059))
                    .tracking(1.5)
            }
        }
        .focusable()
        .digitalCrownRotation(
            $selectedPhaseIndex,
            from: 0,
            through: DailyPhaseKind.allCases.count - 1,
            by: 1,
            sensitivity: .medium,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onAppear {
            if let index = DailyPhaseKind.allCases.firstIndex(of: watchState.activePhase) {
                selectedPhaseIndex = index
            }
        }
        .navigationTitle("Phases")
    }
}

// MARK: - Watch Status View

struct WatchStatusView: View {
    @EnvironmentObject private var watchState: WatchAppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(WatchAppState.WatchStatus.allCases, id: \.self) { status in
                Button {
                    WKInterfaceDevice.current().play(.click)
                    watchState.intentionalStatus = status
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: status.icon)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0xC5A059))

                        Text(status.rawValue)
                            .font(.system(size: 14))

                        Spacer()

                        if status == watchState.intentionalStatus {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: 0xC5A059))
                        }
                    }
                }
            }
        }
        .navigationTitle("Status")
    }
}

// MARK: - Breathwork Session View

struct WatchBreathworkView: View {
    @EnvironmentObject private var watchState: WatchAppState

    @State private var breathPhase: BreathPhase = .inhale
    @State private var circleScale: CGFloat = 0.6
    @State private var elapsed: TimeInterval = 0
    @State private var timer: Timer?

    enum BreathPhase: String {
        case inhale  = "Breathe in"
        case hold    = "Hold"
        case exhale  = "Breathe out"
        case pause   = "Pause"
    }

    var body: some View {
        VStack(spacing: 8) {
            // Time
            Text(formatTime(elapsed))
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))

            Spacer()

            // Breathing circle
            ZStack {
                Circle()
                    .fill(Color(hex: 0xC5A059).opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(circleScale)

                Circle()
                    .stroke(Color(hex: 0xC5A059).opacity(0.3), lineWidth: 2)
                    .frame(width: 100, height: 100)

                Text(breathPhase.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }

            Spacer()

            // Cohort indicator
            if watchState.isBreathworkActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 5, height: 5)
                    Text("Cohort synced")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .onAppear {
            startBreathCycle()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startBreathCycle() {
        // 4-7-8 breathing pattern
        let pattern: [(BreathPhase, TimeInterval, CGFloat)] = [
            (.inhale, 4, 1.0),
            (.hold,   7, 1.0),
            (.exhale, 8, 0.6),
            (.pause,  2, 0.6),
        ]

        var currentIndex = 0

        func nextPhase() {
            let (phase, duration, targetScale) = pattern[currentIndex]
            breathPhase = phase

            WKInterfaceDevice.current().play(.click)

            withAnimation(.easeInOut(duration: duration)) {
                circleScale = targetScale
            }

            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
                elapsed += duration
                currentIndex = (currentIndex + 1) % pattern.count
                nextPhase()
            }
        }

        nextPhase()
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Complication Provider

class ResonanceComplicationProvider: NSObject, CLKComplicationDataSource {
    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let frequency = 7.2
        let status = "Open"
        let template: CLKComplicationTemplate

        switch complication.family {
        case .circularSmall:
            let t = CLKComplicationTemplateCircularSmallSimpleText()
            t.textProvider = CLKSimpleTextProvider(text: String(format: "%.1f", frequency))
            template = t

        case .modularSmall:
            let t = CLKComplicationTemplateModularSmallSimpleText()
            t.textProvider = CLKSimpleTextProvider(text: String(format: "%.1f", frequency))
            template = t

        case .utilitarianSmall:
            let t = CLKComplicationTemplateUtilitarianSmallFlat()
            t.textProvider = CLKSimpleTextProvider(text: "\(String(format: "%.1f", frequency)) Hz")
            template = t

        case .utilitarianLarge:
            let t = CLKComplicationTemplateUtilitarianLargeFlat()
            t.textProvider = CLKSimpleTextProvider(text: "Resonance \(String(format: "%.1f", frequency)) — \(status)")
            template = t

        case .graphicCircular:
            let t = CLKComplicationTemplateGraphicCircularStackText()
            t.line1TextProvider = CLKSimpleTextProvider(text: String(format: "%.1f", frequency))
            t.line2TextProvider = CLKSimpleTextProvider(text: "FREQ")
            template = t

        case .graphicRectangular:
            let t = CLKComplicationTemplateGraphicRectangularStandardBody()
            t.headerTextProvider = CLKSimpleTextProvider(text: "Resonance")
            t.body1TextProvider = CLKSimpleTextProvider(text: "Frequency: \(String(format: "%.1f", frequency))")
            t.body2TextProvider = CLKSimpleTextProvider(text: "Status: \(status)")
            template = t

        default:
            handler(nil)
            return
        }

        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        handler([
            CLKComplicationDescriptor(
                identifier: "resonance_frequency",
                displayName: "Resonance Frequency",
                supportedFamilies: [
                    .circularSmall, .modularSmall,
                    .utilitarianSmall, .utilitarianLarge,
                    .graphicCircular, .graphicRectangular
                ]
            )
        ])
    }

    func getPrivacyBehavior(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void
    ) {
        handler(.showOnLockScreen)
    }
}

// MARK: - WKInterfaceDevice Stub (for compilation outside watchOS)

#if !os(watchOS)
class WKInterfaceDevice {
    static func current() -> WKInterfaceDevice { .init() }
    func play(_ type: WKHapticType) {}
}
enum WKHapticType {
    case notification, click, start, stop, success, failure, retry
}
#endif
