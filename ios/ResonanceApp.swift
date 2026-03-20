// ResonanceApp.swift
// Resonance UX — iOS Entry Point
//
// A philosophy-driven experience shell focused on calm, intentional
// digital interaction, nervous system regulation, and energy-based
// task management.

import SwiftUI

// MARK: - Design Tokens

struct ResonanceTheme {
    // MARK: Light Palette
    struct Light {
        static let base        = Color("LightBase",       default: Color(hex: 0xFAFAF8))
        static let surface     = Color("LightSurface",    default: Color(hex: 0xFFFFFF))
        static let green900    = Color("LightGreen900",   default: Color(hex: 0x0A1C14))
        static let green800    = Color("LightGreen800",   default: Color(hex: 0x122E21))
        static let gold        = Color("LightGold",       default: Color(hex: 0xC5A059))
        static let textMuted   = Color("LightTextMuted",  default: Color(hex: 0x5C7065))
        static let borderSubtle = Color(hex: 0x0A1C14).opacity(0.08)
    }

    // MARK: Dark Palette — "Deep Rest"
    struct DeepRest {
        static let base        = Color("DeepRestBase",    default: Color(hex: 0x05100B))
        static let surface     = Color("DeepRestSurface", default: Color(hex: 0x0A1C14))
        static let gold        = Color("DeepRestGold",    default: Color(hex: 0xC5A059))
        static let text        = Color("DeepRestText",    default: Color(hex: 0xFAFAF8))
        static let textMuted   = Color(hex: 0xFAFAF8).opacity(0.55)
        static let borderSubtle = Color(hex: 0xFAFAF8).opacity(0.06)
    }

    // MARK: Semantic Tokens
    struct Spacing {
        static let xs:   CGFloat = 4
        static let sm:   CGFloat = 8
        static let md:   CGFloat = 16
        static let lg:   CGFloat = 24
        static let xl:   CGFloat = 32
        static let xxl:  CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    struct Radius {
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let lg:  CGFloat = 20
        static let xl:  CGFloat = 28
        static let pill: CGFloat = 999
    }

    struct Animation {
        static let gentle  = SwiftUI.Animation.spring(response: 0.55, dampingFraction: 0.82)
        static let calm    = SwiftUI.Animation.spring(response: 0.7,  dampingFraction: 0.78)
        static let breathe = SwiftUI.Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)
        static let phaseTransition = SwiftUI.Animation.spring(response: 0.9, dampingFraction: 0.85)
    }

    struct Typography {
        static let serifFamily  = "Cormorant Garamond"
        static let sansFamily   = "Manrope"

        static func serif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .custom(serifFamily, size: size).weight(weight)
        }

        static func sans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
            .custom(sansFamily, size: size).weight(weight)
        }

        static let displayLarge  = serif(42, weight: .light)
        static let displayMedium = serif(32, weight: .regular)
        static let headlineLarge = sans(22, weight: .semibold)
        static let headlineMed   = sans(18, weight: .semibold)
        static let bodyLarge     = sans(17, weight: .regular)
        static let bodyMedium    = sans(15, weight: .regular)
        static let bodySmall     = sans(13, weight: .regular)
        static let caption       = sans(11, weight: .medium)
        static let overline      = sans(11, weight: .semibold)
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8)  & 0xFF) / 255.0,
            blue:  Double( hex        & 0xFF) / 255.0,
            opacity: alpha
        )
    }

    /// Fallback initializer — returns `defaultColor` when the named asset is missing.
    init(_ named: String, default defaultColor: Color) {
        if UIColor(named: named) != nil {
            self.init(named)
        } else {
            self = defaultColor
        }
    }
}

// MARK: - Environment Keys

private struct DeepRestModeKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct CurrentPhaseKey: EnvironmentKey {
    static let defaultValue: DailyPhaseKind = .ascend
}

extension EnvironmentValues {
    var isDeepRestMode: Bool {
        get { self[DeepRestModeKey.self] }
        set { self[DeepRestModeKey.self] = newValue }
    }

    var currentPhase: DailyPhaseKind {
        get { self[CurrentPhaseKey.self] }
        set { self[CurrentPhaseKey.self] = newValue }
    }
}

// MARK: - Adaptive Color Modifier

struct AdaptiveColors: ViewModifier {
    @Environment(\.isDeepRestMode) private var isDeepRest

    var base:    Color { isDeepRest ? ResonanceTheme.DeepRest.base    : ResonanceTheme.Light.base }
    var surface: Color { isDeepRest ? ResonanceTheme.DeepRest.surface : ResonanceTheme.Light.surface }
    var text:    Color { isDeepRest ? ResonanceTheme.DeepRest.text    : ResonanceTheme.Light.green900 }
    var muted:   Color { isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted }
    var gold:    Color { ResonanceTheme.Light.gold }
    var border:  Color { isDeepRest ? ResonanceTheme.DeepRest.borderSubtle : ResonanceTheme.Light.borderSubtle }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func resonanceColors() -> some View {
        modifier(AdaptiveColors())
    }
}

// MARK: - Tab Definitions

enum ResonanceTab: String, CaseIterable, Identifiable {
    case flow    = "Flow"
    case focus   = "Focus"
    case create  = "Create"
    case letters = "Letters"
    case canvas  = "Canvas"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .flow:    return "circle.hexagongrid"
        case .focus:   return "eye"
        case .create:  return "pencil.and.outline"
        case .letters: return "envelope.open"
        case .canvas:  return "paintpalette"
        }
    }

    var intentLabel: String {
        switch self {
        case .flow:    return "Daily Rhythms"
        case .focus:   return "Deep Focus"
        case .create:  return "Writing Sanctuary"
        case .letters: return "Inner Circle"
        case .canvas:  return "Creative Canvas"
        }
    }
}

// MARK: - App Entry Point

@main
struct ResonanceApp: App {
    @AppStorage("deepRestMode") private var deepRestMode = false
    @State private var selectedTab: ResonanceTab = .flow
    @State private var showPhaseTransition = false
    @State private var currentPhase: DailyPhaseKind = .ascend
    @StateObject private var appState = ResonanceAppState()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Adaptive background
                (deepRestMode ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base)
                    .ignoresSafeArea()

                TabView(selection: $selectedTab) {
                    DailyFlowView()
                        .tabItem {
                            Label(ResonanceTab.flow.rawValue, systemImage: ResonanceTab.flow.icon)
                        }
                        .tag(ResonanceTab.flow)

                    WellnessHolarchyView()
                        .tabItem {
                            Label(ResonanceTab.focus.rawValue, systemImage: ResonanceTab.focus.icon)
                        }
                        .tag(ResonanceTab.focus)

                    WriterView()
                        .tabItem {
                            Label(ResonanceTab.create.rawValue, systemImage: ResonanceTab.create.icon)
                        }
                        .tag(ResonanceTab.create)

                    InnerCircleView()
                        .tabItem {
                            Label(ResonanceTab.letters.rawValue, systemImage: ResonanceTab.letters.icon)
                        }
                        .tag(ResonanceTab.letters)

                    CanvasPlaceholderView()
                        .tabItem {
                            Label(ResonanceTab.canvas.rawValue, systemImage: ResonanceTab.canvas.icon)
                        }
                        .tag(ResonanceTab.canvas)
                }
                .tint(ResonanceTheme.Light.gold)

                // Phase transition overlay
                if showPhaseTransition {
                    PhaseTransitionOverlay(phase: currentPhase)
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
            .environment(\.isDeepRestMode, deepRestMode)
            .environment(\.currentPhase, currentPhase)
            .environmentObject(appState)
            .preferredColorScheme(deepRestMode ? .dark : .light)
            .onAppear {
                configureAppearance()
                computeCurrentPhase()
            }
            .onChange(of: deepRestMode) { _ in
                configureAppearance()
            }
        }
    }

    // MARK: - Appearance

    private func configureAppearance() {
        let tabBar = UITabBarAppearance()
        tabBar.configureWithDefaultBackground()

        if deepRestMode {
            tabBar.backgroundColor = UIColor(ResonanceTheme.DeepRest.surface)
        } else {
            tabBar.backgroundColor = UIColor(ResonanceTheme.Light.surface)
        }

        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar

        let navBar = UINavigationBarAppearance()
        navBar.configureWithDefaultBackground()
        navBar.largeTitleTextAttributes = [
            .font: UIFont(name: ResonanceTheme.Typography.serifFamily, size: 34) ?? .systemFont(ofSize: 34),
            .foregroundColor: deepRestMode
                ? UIColor(ResonanceTheme.DeepRest.text)
                : UIColor(ResonanceTheme.Light.green900)
        ]
        navBar.titleTextAttributes = [
            .font: UIFont(name: ResonanceTheme.Typography.sansFamily, size: 17) ?? .systemFont(ofSize: 17),
            .foregroundColor: deepRestMode
                ? UIColor(ResonanceTheme.DeepRest.text)
                : UIColor(ResonanceTheme.Light.green900)
        ]

        UINavigationBar.appearance().standardAppearance = navBar
        UINavigationBar.appearance().scrollEdgeAppearance = navBar
    }

    private func computeCurrentPhase() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:   currentPhase = .ascend
        case 12..<15:  currentPhase = .zenith
        case 15..<20:  currentPhase = .descent
        default:       currentPhase = .rest
        }
    }
}

// MARK: - App State

class ResonanceAppState: ObservableObject {
    @Published var intentionalStatus: String = "Open to connect"
    @Published var spaciousnessHours: Double = 4.0
    @Published var currentFrequency: Double = 7.2
    @Published var isInFocusMode: Bool = false
    @Published var activeBreathworkSession: Bool = false

    func transitionToPhase(_ phase: DailyPhaseKind) {
        withAnimation(ResonanceTheme.Animation.phaseTransition) {
            // Phase-appropriate adjustments
            switch phase {
            case .ascend:
                intentionalStatus = "Ascending — building energy"
            case .zenith:
                intentionalStatus = "At peak — deep work"
                isInFocusMode = true
            case .descent:
                intentionalStatus = "Winding down — lighter tasks"
                isInFocusMode = false
            case .rest:
                intentionalStatus = "Recharging"
            }
        }
    }
}

// MARK: - Phase Transition Overlay

struct PhaseTransitionOverlay: View {
    let phase: DailyPhaseKind
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            phase.color.opacity(0.15)
                .ignoresSafeArea()

            VStack(spacing: ResonanceTheme.Spacing.lg) {
                Image(systemName: phase.icon)
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundColor(phase.color)

                Text("Transitioning to \(phase.label)")
                    .font(ResonanceTheme.Typography.displayMedium)
                    .foregroundColor(phase.color)

                Text(phase.intention)
                    .font(ResonanceTheme.Typography.bodyLarge)
                    .foregroundColor(phase.color.opacity(0.7))
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) { opacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.8)) { opacity = 0 }
            }
        }
    }
}

// MARK: - Canvas Placeholder

struct CanvasPlaceholderView: View {
    @Environment(\.isDeepRestMode) private var isDeepRest

    var body: some View {
        NavigationStack {
            ZStack {
                (isDeepRest ? ResonanceTheme.DeepRest.base : ResonanceTheme.Light.base)
                    .ignoresSafeArea()

                VStack(spacing: ResonanceTheme.Spacing.lg) {
                    OrganicBlobView()
                        .frame(width: 200, height: 200)

                    Text("Creative Canvas")
                        .font(ResonanceTheme.Typography.displayMedium)
                        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.text : ResonanceTheme.Light.green900)

                    Text("A space for visual expression.\nComing soon.")
                        .font(ResonanceTheme.Typography.bodyLarge)
                        .foregroundColor(isDeepRest ? ResonanceTheme.DeepRest.textMuted : ResonanceTheme.Light.textMuted)
                        .multilineTextAlignment(.center)
                }
            }
            .navigationTitle("Canvas")
        }
    }
}

// MARK: - Daily Phase Kind (shared enum)

enum DailyPhaseKind: String, CaseIterable, Identifiable, Codable {
    case ascend, zenith, descent, rest

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ascend:  return "Ascend"
        case .zenith:  return "Zenith"
        case .descent: return "Descent"
        case .rest:    return "Rest"
        }
    }

    var icon: String {
        switch self {
        case .ascend:  return "sunrise"
        case .zenith:  return "sun.max"
        case .descent: return "sunset"
        case .rest:    return "moon.stars"
        }
    }

    var color: Color {
        switch self {
        case .ascend:  return Color(hex: 0xC5A059)
        case .zenith:  return Color(hex: 0x0A1C14)
        case .descent: return Color(hex: 0x5C7065)
        case .rest:    return Color(hex: 0x122E21)
        }
    }

    var intention: String {
        switch self {
        case .ascend:  return "Building energy for the day ahead"
        case .zenith:  return "Peak capacity — honor the depth"
        case .descent: return "Gracefully releasing intensity"
        case .rest:    return "Deep restoration and stillness"
        }
    }

    var timeRange: String {
        switch self {
        case .ascend:  return "5 AM – 12 PM"
        case .zenith:  return "12 PM – 3 PM"
        case .descent: return "3 PM – 8 PM"
        case .rest:    return "8 PM – 5 AM"
        }
    }
}
