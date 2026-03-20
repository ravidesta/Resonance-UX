// ResonanceDesignSystem.swift
// Luminous Integral Architecture™ — Resonance UX Design System
//
// Shared design tokens, modifiers, and reusable components for all Apple platforms.

import SwiftUI

// MARK: - Color Palette

extension Color {

    // MARK: Backgrounds
    static let resonanceBgBase = Color("bgBase")
    static let resonanceBgBaseLight = Color(hex: 0xFAFAF8)
    static let resonanceBgBaseDark = Color(hex: 0x05100B)

    // MARK: Greens
    static let resonanceGreen900 = Color(hex: 0x0A1C14)
    static let resonanceGreen800 = Color(hex: 0x122E21)
    static let resonanceGreen700 = Color(hex: 0x1B402E)
    static let resonanceGreen600 = Color(hex: 0x265C3F)
    static let resonanceGreen500 = Color(hex: 0x358A5B)
    static let resonanceGreen400 = Color(hex: 0x5FAE80)
    static let resonanceGreen300 = Color(hex: 0x93C9A6)
    static let resonanceGreen200 = Color(hex: 0xD1E0D7)
    static let resonanceGreen100 = Color(hex: 0xEAF2EC)

    // MARK: Golds
    static let resonanceGoldPrimary = Color(hex: 0xC5A059)
    static let resonanceGoldLight = Color(hex: 0xE6D0A1)
    static let resonanceGoldDark = Color(hex: 0x9A7A3A)

    // MARK: Semantic (adaptive via view modifier)
    static let resonanceTextPrimary = Color.adaptive(
        light: Color(hex: 0x0A1C14),
        dark: Color(hex: 0xFAFAF8)
    )
    static let resonanceTextSecondary = Color.adaptive(
        light: Color(hex: 0x1B402E),
        dark: Color(hex: 0xD1E0D7)
    )
    static let resonanceSurface = Color.adaptive(
        light: .white.opacity(0.7),
        dark: Color(hex: 0x122E21).opacity(0.6)
    )
    static let resonanceDivider = Color.adaptive(
        light: Color(hex: 0xD1E0D7).opacity(0.6),
        dark: Color(hex: 0x1B402E).opacity(0.4)
    )

    // MARK: Highlight Colors (for book annotations)
    static let highlightYellow = Color(hex: 0xF5E6A3).opacity(0.5)
    static let highlightGreen  = Color(hex: 0xA8D5BA).opacity(0.5)
    static let highlightBlue   = Color(hex: 0xA3C4F5).opacity(0.5)
    static let highlightPink   = Color(hex: 0xF5A3C4).opacity(0.5)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    static func adaptive(light: Color, dark: Color) -> Color {
        #if os(watchOS)
        return dark
        #else
        return light
        #endif
    }
}

// MARK: - Adaptive Color View Modifier

struct AdaptiveColorModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let light: Color
    let dark: Color

    func body(content: Content) -> some View {
        content.foregroundStyle(colorScheme == .dark ? dark : light)
    }
}

// MARK: - Adaptive Background

struct AdaptiveBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(colorScheme == .dark ? Color.resonanceBgBaseDark : Color.resonanceBgBaseLight)
    }
}

extension View {
    func resonanceBackground() -> some View {
        modifier(AdaptiveBackground())
    }

    func adaptiveForeground(light: Color, dark: Color) -> some View {
        modifier(AdaptiveColorModifier(light: light, dark: dark))
    }
}

// MARK: - Typography

/// Design system typography built on Cormorant Garamond (serif) and Manrope (sans-serif).
struct ResonanceTypography {

    // MARK: Serif — Book Content

    static func serifDisplay(size: CGFloat = 34) -> Font {
        .custom("CormorantGaramond-Bold", size: size, relativeTo: .largeTitle)
    }

    static func serifTitle(size: CGFloat = 24) -> Font {
        .custom("CormorantGaramond-SemiBold", size: size, relativeTo: .title)
    }

    static func serifTitle2(size: CGFloat = 20) -> Font {
        .custom("CormorantGaramond-Medium", size: size, relativeTo: .title2)
    }

    static func serifBody(size: CGFloat = 18) -> Font {
        .custom("CormorantGaramond-Regular", size: size, relativeTo: .body)
    }

    static func serifBodyItalic(size: CGFloat = 18) -> Font {
        .custom("CormorantGaramond-Italic", size: size, relativeTo: .body)
    }

    static func serifCaption(size: CGFloat = 14) -> Font {
        .custom("CormorantGaramond-Light", size: size, relativeTo: .caption)
    }

    // MARK: Sans-Serif — UI Chrome

    static func sansDisplay(size: CGFloat = 30) -> Font {
        .custom("Manrope-ExtraBold", size: size, relativeTo: .largeTitle)
    }

    static func sansTitle(size: CGFloat = 20) -> Font {
        .custom("Manrope-Bold", size: size, relativeTo: .title2)
    }

    static func sansHeadline(size: CGFloat = 17) -> Font {
        .custom("Manrope-SemiBold", size: size, relativeTo: .headline)
    }

    static func sansBody(size: CGFloat = 16) -> Font {
        .custom("Manrope-Regular", size: size, relativeTo: .body)
    }

    static func sansCaption(size: CGFloat = 13) -> Font {
        .custom("Manrope-Medium", size: size, relativeTo: .caption)
    }

    static func sansCaption2(size: CGFloat = 11) -> Font {
        .custom("Manrope-Regular", size: size, relativeTo: .caption2)
    }

    // MARK: Fallbacks (system fonts that approximate the feel)

    static func serifFallback(_ style: Font.TextStyle) -> Font {
        switch style {
        case .largeTitle: return .system(.largeTitle, design: .serif).bold()
        case .title:      return .system(.title, design: .serif)
        case .body:       return .system(.body, design: .serif)
        case .caption:    return .system(.caption, design: .serif)
        default:          return .system(style, design: .serif)
        }
    }

    static func sansFallback(_ style: Font.TextStyle) -> Font {
        switch style {
        case .largeTitle: return .system(.largeTitle, design: .rounded).bold()
        case .title:      return .system(.title2, design: .rounded).weight(.semibold)
        case .body:       return .system(.body, design: .rounded)
        case .caption:    return .system(.caption, design: .rounded).weight(.light)
        default:          return .system(style, design: .rounded)
        }
    }
}

// MARK: - Glass Panel Modifier

struct GlassPanelModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            #if !os(watchOS)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            #else
            .background(Color.resonanceGreen800.opacity(0.6), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            #endif
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.12 : 0.3),
                                Color.white.opacity(0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Organic Blob Background

struct OrganicBlobView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let t = phase

            // Primary organic blob
            let blob1 = createBlobPath(
                center: CGPoint(x: w * 0.3, y: h * 0.4),
                radius: min(w, h) * 0.35,
                phase: t,
                lobes: 5
            )
            context.fill(
                blob1,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.resonanceGreen700.opacity(0.15),
                        Color.resonanceGoldPrimary.opacity(0.08)
                    ]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: w, y: h)
                )
            )

            // Secondary blob
            let blob2 = createBlobPath(
                center: CGPoint(x: w * 0.7, y: h * 0.6),
                radius: min(w, h) * 0.28,
                phase: t + .pi * 0.7,
                lobes: 4
            )
            context.fill(
                blob2,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.resonanceGoldPrimary.opacity(0.1),
                        Color.resonanceGreen200.opacity(0.06)
                    ]),
                    startPoint: CGPoint(x: w, y: 0),
                    endPoint: CGPoint(x: 0, y: h)
                )
            )

            // Tertiary subtle blob
            let blob3 = createBlobPath(
                center: CGPoint(x: w * 0.5, y: h * 0.2),
                radius: min(w, h) * 0.2,
                phase: t + .pi * 1.3,
                lobes: 6
            )
            context.fill(
                blob3,
                with: .color(Color.resonanceGreen200.opacity(0.05))
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func createBlobPath(center: CGPoint, radius: CGFloat, phase: CGFloat, lobes: Int) -> Path {
        var path = Path()
        let points = 120
        for i in 0..<points {
            let angle = (CGFloat(i) / CGFloat(points)) * .pi * 2
            let wobble = sin(angle * CGFloat(lobes) + phase) * 0.2
                + sin(angle * CGFloat(lobes + 2) + phase * 1.3) * 0.1
            let r = radius * (1.0 + wobble)
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Paper Texture Overlay

struct PaperTextureOverlay: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 4
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    let hash = sin(x * 12.9898 + y * 78.233) * 43758.5453
                    let noise = hash - floor(hash)
                    if noise > 0.92 {
                        let opacity = (noise - 0.92) * 5.0
                        context.fill(
                            Path(CGRect(x: x, y: y, width: 1, height: 1)),
                            with: .color(
                                colorScheme == .dark
                                    ? Color.white.opacity(opacity * 0.03)
                                    : Color.black.opacity(opacity * 0.04)
                            )
                        )
                    }
                    y += step
                }
                x += step
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Breathing Animation Modifier

struct BreathingModifier: ViewModifier {
    @State private var isBreathing = false
    var minScale: CGFloat = 0.97
    var maxScale: CGFloat = 1.03
    var duration: Double = 6

    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? maxScale : minScale)
            .opacity(isBreathing ? 1.0 : 0.92)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isBreathing = true
                }
            }
    }
}

extension View {
    func breathingAnimation(duration: Double = 6) -> some View {
        modifier(BreathingModifier(duration: duration))
    }
}

// MARK: - Button Styles

struct ResonancePrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResonanceTypography.sansHeadline())
            .foregroundStyle(Color.resonanceGreen900)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [Color.resonanceGoldLight, Color.resonanceGoldPrimary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .shadow(color: Color.resonanceGoldPrimary.opacity(0.3),
                    radius: configuration.isPressed ? 2 : 8,
                    y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ResonanceSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResonanceTypography.sansHeadline())
            .foregroundStyle(Color.resonanceGoldPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .strokeBorder(Color.resonanceGoldPrimary.opacity(0.5), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ResonanceGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(ResonanceTypography.sansBody())
            .foregroundStyle(Color.resonanceGoldPrimary)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ResonancePrimaryButtonStyle {
    static var resonancePrimary: ResonancePrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == ResonanceSecondaryButtonStyle {
    static var resonanceSecondary: ResonanceSecondaryButtonStyle { .init() }
}

extension ButtonStyle where Self == ResonanceGhostButtonStyle {
    static var resonanceGhost: ResonanceGhostButtonStyle { .init() }
}

// MARK: - Card Style

struct ResonanceCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colorScheme == .dark ? Color.resonanceGreen800.opacity(0.4) : Color.white.opacity(0.8))
            )
            #if !os(watchOS)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            #endif
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.resonanceDivider, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.06), radius: 8, y: 2)
    }
}

extension View {
    func resonanceCard() -> some View {
        modifier(ResonanceCardModifier())
    }
}

// MARK: - Progress Bar

struct ResonanceProgressBar: View {
    var progress: Double
    var height: CGFloat = 4

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.resonanceDivider)
                    .frame(height: height)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.resonanceGoldPrimary, Color.resonanceGoldLight],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(min(max(progress, 0), 1)), height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

// MARK: - Resonance Divider

struct ResonanceDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.resonanceGoldPrimary.opacity(0.0),
                        Color.resonanceGoldPrimary.opacity(0.3),
                        Color.resonanceGoldPrimary.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}

// MARK: - Icon Wrapper

struct ResonanceIcon: View {
    let systemName: String
    var size: CGFloat = 20

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(Color.resonanceGoldPrimary)
    }
}

// MARK: - Progress Ring

struct ResonanceProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 4
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.resonanceDivider, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    Color.resonanceGoldPrimary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Progress: \(Int(progress * 100)) percent")
    }
}

// MARK: - Environment Keys

struct ReadingFontSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 18
}

struct ReadingThemeKey: EnvironmentKey {
    static let defaultValue: ReadingTheme = .day
}

enum ReadingTheme: String, CaseIterable, Identifiable {
    case day, sepia, night
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .day:   return "Day"
        case .sepia: return "Sepia"
        case .night: return "Night"
        }
    }

    var background: Color {
        switch self {
        case .day:   return Color.resonanceBgBaseLight
        case .sepia: return Color(hex: 0xF4EEDE)
        case .night: return Color.resonanceBgBaseDark
        }
    }

    var foreground: Color {
        switch self {
        case .day:   return Color.resonanceGreen900
        case .sepia: return Color(hex: 0x3B2F1E)
        case .night: return Color(hex: 0xD1D1C7)
        }
    }

    var secondaryForeground: Color {
        switch self {
        case .day:   return Color.resonanceGreen700
        case .sepia: return Color(hex: 0x5C4A2A)
        case .night: return Color.resonanceGreen300
        }
    }
}

extension EnvironmentValues {
    var readingFontSize: CGFloat {
        get { self[ReadingFontSizeKey.self] }
        set { self[ReadingFontSizeKey.self] = newValue }
    }

    var readingTheme: ReadingTheme {
        get { self[ReadingThemeKey.self] }
        set { self[ReadingThemeKey.self] = newValue }
    }
}

// MARK: - Shared Models

struct Chapter: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let pageRange: ClosedRange<Int>
    let duration: TimeInterval?
    let isCompleted: Bool

    init(id: String = UUID().uuidString, title: String, subtitle: String? = nil,
         pageRange: ClosedRange<Int> = 1...1, duration: TimeInterval? = nil,
         isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.pageRange = pageRange
        self.duration = duration
        self.isCompleted = isCompleted
    }
}

struct Highlight: Identifiable {
    let id: String
    let text: String
    let color: Color
    let note: String?
    let chapterId: String
    let page: Int
    let createdAt: Date

    init(id: String = UUID().uuidString, text: String, color: Color = .highlightYellow,
         note: String? = nil, chapterId: String = "", page: Int = 0, createdAt: Date = .now) {
        self.id = id
        self.text = text
        self.color = color
        self.note = note
        self.chapterId = chapterId
        self.page = page
        self.createdAt = createdAt
    }
}

struct Bookmark: Identifiable {
    let id: String
    let page: Int
    let chapterId: String
    let label: String
    let createdAt: Date

    init(id: String = UUID().uuidString, page: Int = 0, chapterId: String = "",
         label: String = "", createdAt: Date = .now) {
        self.id = id
        self.page = page
        self.chapterId = chapterId
        self.label = label
        self.createdAt = createdAt
    }
}

// MARK: - Somatic Practice Card

struct SomaticPracticeCard: View {
    let title: String
    let instruction: String
    let durationSeconds: Int
    @State private var isActive = false
    @State private var timeRemaining: Int = 0
    @State private var breathPhase: BreathPhase = .inhale

    enum BreathPhase: String {
        case inhale = "Breathe In"
        case hold = "Hold"
        case exhale = "Breathe Out"
        case rest = "Rest"
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.resonanceGreen500)
                Text(title)
                    .font(ResonanceTypography.sansHeadline())
                Spacer()
                if isActive {
                    Text(formatTime(timeRemaining))
                        .font(ResonanceTypography.sansCaption())
                        .monospacedDigit()
                }
            }

            Text(instruction)
                .font(ResonanceTypography.serifBody())
                .foregroundStyle(Color.resonanceTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if isActive {
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.resonanceGreen500.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .fill(Color.resonanceGreen500.opacity(0.4))
                                .breathingAnimation(duration: breathPhase == .inhale ? 4 : 6)
                        )
                        .overlay(
                            Text(breathPhase.rawValue)
                                .font(ResonanceTypography.sansCaption())
                                .foregroundStyle(Color.resonanceGreen700)
                        )
                        .accessibilityLabel("Breathing guide: \(breathPhase.rawValue)")

                    ResonanceProgressBar(
                        progress: 1.0 - Double(timeRemaining) / Double(durationSeconds)
                    )
                }
            }

            Button(isActive ? "End Practice" : "Begin Practice") {
                if isActive {
                    isActive = false
                } else {
                    timeRemaining = durationSeconds
                    isActive = true
                    startTimer()
                }
            }
            .buttonStyle(.resonanceSecondary)
        }
        .glassPanel(cornerRadius: 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Somatic practice: \(title)")
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 && isActive {
                timeRemaining -= 1
                let cyclePosition = timeRemaining % 16
                if cyclePosition >= 12 { breathPhase = .inhale }
                else if cyclePosition >= 8 { breathPhase = .hold }
                else if cyclePosition >= 4 { breathPhase = .exhale }
                else { breathPhase = .rest }
            } else {
                timer.invalidate()
                isActive = false
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Reflection Question Card

struct ReflectionQuestionCard: View {
    let question: String
    let prompt: String?
    @State private var response: String = ""
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Reflection")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .textCase(.uppercase)
            }

            Text(question)
                .font(ResonanceTypography.serifTitle(size: 20))
                .foregroundStyle(Color.resonanceTextPrimary)

            if let prompt {
                Text(prompt)
                    .font(ResonanceTypography.serifBody(size: 16))
                    .foregroundStyle(Color.resonanceTextSecondary)
            }

            #if !os(watchOS)
            TextEditor(text: $response)
                .font(ResonanceTypography.serifBody())
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.resonanceSurface)
                )
                .accessibilityLabel("Your reflection response")
            #endif

            HStack {
                Spacer()
                Button(isSaved ? "Saved" : "Save Reflection") {
                    isSaved = true
                }
                .buttonStyle(.resonancePrimary)
                .disabled(response.isEmpty || isSaved)
            }
        }
        .glassPanel(cornerRadius: 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reflection question: \(question)")
    }
}

// MARK: - Quadrant Mapping Card

struct QuadrantMappingCard: View {
    let title: String
    @State private var entries: [String: String] = [
        "Interior Individual (I)": "",
        "Exterior Individual (It)": "",
        "Interior Collective (We)": "",
        "Exterior Collective (Its)": ""
    ]

    private let quadrantColors: [String: Color] = [
        "Interior Individual (I)": .resonanceGreen700,
        "Exterior Individual (It)": .resonanceGreen500,
        "Interior Collective (We)": .resonanceGoldPrimary,
        "Exterior Collective (Its)": .resonanceGoldDark
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundStyle(Color.resonanceGoldPrimary)
                Text("Quadrant Mapping")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .textCase(.uppercase)
            }

            Text(title)
                .font(ResonanceTypography.serifTitle(size: 20))

            #if !os(watchOS)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(entries.keys.sorted()), id: \.self) { quadrant in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quadrant)
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(quadrantColors[quadrant] ?? .resonanceGoldPrimary)

                        TextField("Enter...", text: Binding(
                            get: { entries[quadrant] ?? "" },
                            set: { entries[quadrant] = $0 }
                        ))
                        .font(ResonanceTypography.sansBody(size: 14))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.resonanceSurface)
                        )
                        .accessibilityLabel("\(quadrant) entry")
                    }
                }
            }
            #endif
        }
        .glassPanel(cornerRadius: 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Quadrant mapping exercise: \(title)")
    }
}

// MARK: - Preview

#if DEBUG
struct ResonanceDesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Luminous Integral Architecture")
                    .font(ResonanceTypography.serifDisplay())

                Text("Resonance UX Design System")
                    .font(ResonanceTypography.sansTitle())

                ResonanceDivider()

                HStack(spacing: 8) {
                    ForEach([Color.resonanceGreen900, .resonanceGreen700, .resonanceGreen500,
                             .resonanceGreen300, .resonanceGreen200], id: \.self) { c in
                        Circle().fill(c).frame(width: 28, height: 28)
                    }
                    ForEach([Color.resonanceGoldDark, .resonanceGoldPrimary, .resonanceGoldLight], id: \.self) { c in
                        Circle().fill(c).frame(width: 28, height: 28)
                    }
                }

                Button("Primary Action") {}
                    .buttonStyle(.resonancePrimary)

                Button("Secondary Action") {}
                    .buttonStyle(.resonanceSecondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Glass Card")
                        .font(ResonanceTypography.sansHeadline())
                    Text("Ultra-thin material frosted glass effect with gold gradient border.")
                        .font(ResonanceTypography.sansBody())
                }
                .resonanceCard()

                ResonanceProgressBar(progress: 0.65)

                ResonanceProgressRing(progress: 0.72)
            }
            .padding(24)
        }
        .resonanceBackground()
        .background(OrganicBlobView())
        .overlay(PaperTextureOverlay())
    }
}
#endif
