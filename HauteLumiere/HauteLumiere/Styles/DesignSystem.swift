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

// MARK: - Typography
struct HLTypography {
    // Serif — Cormorant Garamond
    static func serifLight(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size).weight(.light)
    }
    static func serifRegular(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size)
    }
    static func serifMedium(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size).weight(.medium)
    }
    static func serifSemibold(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size).weight(.semibold)
    }
    static func serifBold(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size).weight(.bold)
    }
    static func serifItalic(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size).italic()
    }

    // Sans — Manrope
    static func sansLight(_ size: CGFloat) -> Font {
        .custom("Manrope", size: size).weight(.light)
    }
    static func sansRegular(_ size: CGFloat) -> Font {
        .custom("Manrope", size: size)
    }
    static func sansMedium(_ size: CGFloat) -> Font {
        .custom("Manrope", size: size).weight(.medium)
    }
    static func sansSemibold(_ size: CGFloat) -> Font {
        .custom("Manrope", size: size).weight(.semibold)
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
}
