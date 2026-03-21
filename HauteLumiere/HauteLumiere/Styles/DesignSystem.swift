// DesignSystem.swift
// Haute Lumière — Design System

import SwiftUI

// MARK: - Brand Colors
extension Color {
    // Primary Palette
    static let hlCream = Color(hex: "FAFAF8")
    static let hlSurface = Color(hex: "FFFFFF")
    static let hlGlass = Color.white.opacity(0.7)

    // Forest Greens
    static let hlGreen900 = Color(hex: "0A1C14")
    static let hlGreen800 = Color(hex: "122E21")
    static let hlGreen700 = Color(hex: "1B402E")
    static let hlGreen600 = Color(hex: "2A5A42")
    static let hlGreen500 = Color(hex: "3A7A5A")
    static let hlGreen400 = Color(hex: "5A9A7A")
    static let hlGreen300 = Color(hex: "8FBFA8")
    static let hlGreen200 = Color(hex: "D1E0D7")
    static let hlGreen100 = Color(hex: "E8F0EA")
    static let hlGreen50 = Color(hex: "F4F8F5")

    // Gold Accents
    static let hlGold = Color(hex: "C5A059")
    static let hlGoldLight = Color(hex: "E6D0A1")
    static let hlGoldDark = Color(hex: "9A7A3A")
    static let hlGoldShimmer = Color(hex: "D4B87A")

    // Azure (Ava's signature)
    static let hlAzure = Color(hex: "7BA7C4")
    static let hlAzureLight = Color(hex: "A8C5D8")
    static let hlAzureDark = Color(hex: "5A8AA8")

    // Night Mode
    static let hlNightDeep = Color(hex: "0A1C14")
    static let hlNightForest = Color(hex: "122E21")
    static let hlNightMoss = Color(hex: "1B3A2B")
    static let hlNightText = Color(hex: "D1E0D7")
    static let hlNightTextMuted = Color(hex: "5C7065")
    static let hlNightGlow = Color(hex: "C5A059").opacity(0.6)

    // Text
    static let hlTextPrimary = Color(hex: "122E21")
    static let hlTextSecondary = Color(hex: "5C7065")
    static let hlTextTertiary = Color(hex: "8A9C91")

    // Semantic
    static let hlSuccess = Color(hex: "3A7A5A")
    static let hlWarning = Color(hex: "C5A059")
    static let hlError = Color(hex: "C45A5A")
    static let hlInfo = Color(hex: "7BA7C4")

    // Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Font Pairings (3 Swappable Styles)
/// Users can choose between three typographic identities
enum HLFontPairing: String, Codable, CaseIterable, Identifiable {
    case classicGrace = "Classic Grace"       // Cormorant Garamond + Manrope (default)
    case modernLuxe = "Modern Luxe"           // Playfair Display + Inter
    case timelessElegance = "Timeless Elegance" // Didot + Avenir Next

    var id: String { rawValue }

    var serifFamily: String {
        switch self {
        case .classicGrace: return "Cormorant Garamond"
        case .modernLuxe: return "Playfair Display"
        case .timelessElegance: return "Didot"
        }
    }

    var sansFamily: String {
        switch self {
        case .classicGrace: return "Manrope"
        case .modernLuxe: return "Inter"
        case .timelessElegance: return "Avenir Next"
        }
    }

    var description: String {
        switch self {
        case .classicGrace: return "Refined and scholarly — old-world warmth"
        case .modernLuxe: return "Bold and editorial — haute couture energy"
        case .timelessElegance: return "Clean and statuesque — French fashion house"
        }
    }
}

// MARK: - Color Palettes (3 Swappable Themes)
/// Three distinct luxury colorways the user can swap between
enum HLColorPalette: String, Codable, CaseIterable, Identifiable {
    case forestSanctuary = "Forest Sanctuary"    // Default: deep greens + gold
    case midnightVelvet = "Midnight Velvet"      // Charcoal + rose gold + blush
    case obsidianGold = "Obsidian & Gold"        // True black + gold + ivory

    var id: String { rawValue }

    var description: String {
        switch self {
        case .forestSanctuary: return "Emerald depths with golden light"
        case .midnightVelvet: return "Smoky noir with rose-gold warmth"
        case .obsidianGold: return "Absolute black with molten gold"
        }
    }

    // Primary background
    var bgDeep: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "0A1C14")
        case .midnightVelvet: return Color(hex: "1A1520")
        case .obsidianGold: return Color(hex: "0A0A0A")
        }
    }

    var bgMid: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "122E21")
        case .midnightVelvet: return Color(hex: "241E2E")
        case .obsidianGold: return Color(hex: "141414")
        }
    }

    var bgSurface: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "1B402E")
        case .midnightVelvet: return Color(hex: "2E2638")
        case .obsidianGold: return Color(hex: "1C1C1C")
        }
    }

    // Accent gold / rose / gold
    var accentPrimary: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "C5A059")
        case .midnightVelvet: return Color(hex: "C5908A")  // rose gold
        case .obsidianGold: return Color(hex: "D4AF37")    // pure gold
        }
    }

    var accentLight: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "E6D0A1")
        case .midnightVelvet: return Color(hex: "E8C5C0")  // blush
        case .obsidianGold: return Color(hex: "F0D78C")    // champagne
        }
    }

    var accentDark: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "9A7A3A")
        case .midnightVelvet: return Color(hex: "8A5A55")
        case .obsidianGold: return Color(hex: "8B7335")
        }
    }

    // Text colors
    var textPrimary: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "E8F0EA")
        case .midnightVelvet: return Color(hex: "F0E8EB")
        case .obsidianGold: return Color(hex: "FAFAF5")    // warm ivory
        }
    }

    var textSecondary: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "8FBFA8")
        case .midnightVelvet: return Color(hex: "9A8A95")
        case .obsidianGold: return Color(hex: "8A8A85")
        }
    }

    // Card / glass overlay
    var cardFill: Color {
        switch self {
        case .forestSanctuary: return Color.white.opacity(0.06)
        case .midnightVelvet: return Color.white.opacity(0.05)
        case .obsidianGold: return Color.white.opacity(0.04)
        }
    }

    // Diary-specific: dark luxurious base for journal
    var diaryBackground: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "080F0B")
        case .midnightVelvet: return Color(hex: "0F0B14")
        case .obsidianGold: return Color(hex: "050505")
        }
    }

    var diaryLaceOverlay: Color {
        switch self {
        case .forestSanctuary: return Color(hex: "C5A059").opacity(0.08)
        case .midnightVelvet: return Color(hex: "C5908A").opacity(0.08)
        case .obsidianGold: return Color(hex: "D4AF37").opacity(0.06)
        }
    }
}

// MARK: - Typography (Dynamic based on font pairing)
struct HLTypography {
    // Current pairing — set from AppState
    static var currentPairing: HLFontPairing = .classicGrace

    // Serif
    static func serifLight(_ size: CGFloat) -> Font {
        .custom(currentPairing.serifFamily, size: size).weight(.light)
    }
    static func serifRegular(_ size: CGFloat) -> Font {
        .custom(currentPairing.serifFamily, size: size)
    }
    static func serifMedium(_ size: CGFloat) -> Font {
        .custom(currentPairing.serifFamily, size: size).weight(.medium)
    }
    static func serifSemibold(_ size: CGFloat) -> Font {
        .custom(currentPairing.serifFamily, size: size).weight(.semibold)
    }
    static func serifBold(_ size: CGFloat) -> Font {
        .custom(currentPairing.serifFamily, size: size).weight(.bold)
    }
    static func serifItalic(_ size: CGFloat) -> Font {
        .custom(currentPairing.serifFamily, size: size).italic()
    }

    // Sans
    static func sansLight(_ size: CGFloat) -> Font {
        .custom(currentPairing.sansFamily, size: size).weight(.light)
    }
    static func sansRegular(_ size: CGFloat) -> Font {
        .custom(currentPairing.sansFamily, size: size)
    }
    static func sansMedium(_ size: CGFloat) -> Font {
        .custom(currentPairing.sansFamily, size: size).weight(.medium)
    }
    static func sansSemibold(_ size: CGFloat) -> Font {
        .custom(currentPairing.sansFamily, size: size).weight(.semibold)
    }

    // Preset Styles
    static let heroTitle = serifLight(42)
    static let screenTitle = serifMedium(32)
    static let sectionTitle = serifMedium(24)
    static let cardTitle = sansSemibold(16)
    static let bodyLarge = sansRegular(16)
    static let body = sansRegular(14)
    static let bodySmall = sansRegular(12)
    static let caption = sansLight(11)
    static let label = sansMedium(13)
    static let tabLabel = sansMedium(10)
}

// MARK: - Spacing
struct HLSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
struct HLRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let pill: CGFloat = 100
}

// MARK: - Shadows
extension View {
    func hlShadowSubtle() -> some View {
        self.shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    func hlShadowMedium() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 4)
    }

    func hlShadowElevated() -> some View {
        self.shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 8)
    }

    func hlGlassMorphism() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.lg))
    }

    func hlCard() -> some View {
        self
            .padding(HLSpacing.md)
            .background(Color.hlSurface)
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.lg))
            .hlShadowSubtle()
    }

    func hlGoldBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: HLRadius.lg)
                .stroke(
                    LinearGradient(
                        colors: [.hlGold, .hlGoldLight, .hlGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Animated Gradient Background
struct LumièreGradient: View {
    let colors: [Color]
    @State private var animateGradient = false

    init(colors: [Color] = [.hlGreen900, .hlGreen800, .hlGreen700]) {
        self.colors = colors
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Night Mode Forest Background
struct ForestNightBackground: View {
    let theme: AppState.NightModeTheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: theme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Firefly particles
            ForEach(0..<20, id: \.self) { index in
                FireflyParticle(index: index)
            }
        }
    }
}

struct FireflyParticle: View {
    let index: Int
    @State private var opacity: Double = 0
    @State private var position: CGPoint = .zero

    var body: some View {
        Circle()
            .fill(Color.hlGoldLight)
            .frame(width: CGFloat.random(in: 2...4))
            .opacity(opacity)
            .position(position)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...5))
                    .repeatForever(autoreverses: true)
                    .delay(Double.random(in: 0...3))
                ) {
                    opacity = Double.random(in: 0.2...0.7)
                }
            }
    }
}

// MARK: - Gold Shimmer Effect
struct GoldShimmer: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .hlGoldLight.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

extension View {
    func goldShimmer() -> some View {
        modifier(GoldShimmer())
    }

    /// Dark lace diary card: deep black with thin accent border + lace-pattern overlay
    func hlDiaryCard(palette: HLColorPalette = .forestSanctuary) -> some View {
        self
            .padding(HLSpacing.lg)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: HLRadius.xl)
                        .fill(palette.diaryBackground)
                    // Lace filigree pattern (simulated with layered borders)
                    RoundedRectangle(cornerRadius: HLRadius.xl)
                        .fill(palette.diaryLaceOverlay)
                    RoundedRectangle(cornerRadius: HLRadius.xl - 4)
                        .stroke(palette.accentPrimary.opacity(0.15), lineWidth: 0.5)
                        .padding(4)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.xl)
                    .stroke(
                        LinearGradient(
                            colors: [palette.accentPrimary.opacity(0.4), palette.accentLight.opacity(0.15), palette.accentPrimary.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    /// Social-media branded watermark overlay — "Haute Lumière" lower-left
    func hlBrandWatermark(palette: HLColorPalette = .forestSanctuary) -> some View {
        self.overlay(alignment: .bottomLeading) {
            HStack(spacing: 6) {
                Image(systemName: "light.max")
                    .font(.system(size: 10, weight: .ultraLight))
                    .foregroundColor(palette.accentPrimary.opacity(0.7))
                Text("Haute Lumière")
                    .font(HLTypography.serifLight(13))
                    .foregroundColor(palette.accentPrimary.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Dark Lace Filigree Background (Diary / Studio)
struct DarkLaceBackground: View {
    let palette: HLColorPalette

    var body: some View {
        ZStack {
            palette.diaryBackground.ignoresSafeArea()

            // Subtle radial gradient warm center
            RadialGradient(
                colors: [palette.accentPrimary.opacity(0.04), .clear],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()

            // Lace lattice pattern (decorative thin lines)
            GeometryReader { geo in
                Canvas { context, size in
                    let spacing: CGFloat = 40
                    let color = palette.accentPrimary.opacity(0.03)
                    for x in stride(from: 0, through: size.width, by: spacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x + spacing / 2, y: size.height))
                        context.stroke(path, with: .color(Color(color)), lineWidth: 0.5)
                    }
                    for y in stride(from: 0, through: size.height, by: spacing * 1.5) {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y + spacing / 3))
                        context.stroke(path, with: .color(Color(color)), lineWidth: 0.3)
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}
