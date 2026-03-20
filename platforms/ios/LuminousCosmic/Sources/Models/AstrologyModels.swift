// AstrologyModels.swift
// Luminous Cosmic Architecture™
// Core Data Models for Astrological Calculations

import SwiftUI

// MARK: - Zodiac Sign

enum ZodiacSign: Int, CaseIterable, Identifiable, Codable {
    case aries = 0, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .aries: return "Aries"
        case .taurus: return "Taurus"
        case .gemini: return "Gemini"
        case .cancer: return "Cancer"
        case .leo: return "Leo"
        case .virgo: return "Virgo"
        case .libra: return "Libra"
        case .scorpio: return "Scorpio"
        case .sagittarius: return "Sagittarius"
        case .capricorn: return "Capricorn"
        case .aquarius: return "Aquarius"
        case .pisces: return "Pisces"
        }
    }

    var glyph: String {
        switch self {
        case .aries: return "\u{2648}"
        case .taurus: return "\u{2649}"
        case .gemini: return "\u{264A}"
        case .cancer: return "\u{264B}"
        case .leo: return "\u{264C}"
        case .virgo: return "\u{264D}"
        case .libra: return "\u{264E}"
        case .scorpio: return "\u{264F}"
        case .sagittarius: return "\u{2650}"
        case .capricorn: return "\u{2651}"
        case .aquarius: return "\u{2652}"
        case .pisces: return "\u{2653}"
        }
    }

    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }

    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }

    var ruler: Planet {
        switch self {
        case .aries: return .mars
        case .taurus: return .venus
        case .gemini: return .mercury
        case .cancer: return .moon
        case .leo: return .sun
        case .virgo: return .mercury
        case .libra: return .venus
        case .scorpio: return .pluto
        case .sagittarius: return .jupiter
        case .capricorn: return .saturn
        case .aquarius: return .uranus
        case .pisces: return .neptune
        }
    }

    var color: Color {
        element.color
    }

    var startDegree: Double {
        Double(rawValue) * 30.0
    }
}

// MARK: - Element

enum Element: String, CaseIterable, Codable {
    case fire, earth, air, water

    var color: Color {
        switch self {
        case .fire: return ResonanceColors.fire
        case .earth: return ResonanceColors.earth
        case .air: return ResonanceColors.air
        case .water: return ResonanceColors.water
        }
    }

    var name: String { rawValue.capitalized }
}

// MARK: - Modality

enum Modality: String, CaseIterable, Codable {
    case cardinal, fixed, mutable
    var name: String { rawValue.capitalized }
}

// MARK: - Planet

enum Planet: Int, CaseIterable, Identifiable, Codable {
    case sun = 0, moon, mercury, venus, mars
    case jupiter, saturn, uranus, neptune, pluto
    case northNode, chiron, ascendant, midheaven

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .mercury: return "Mercury"
        case .venus: return "Venus"
        case .mars: return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn: return "Saturn"
        case .uranus: return "Uranus"
        case .neptune: return "Neptune"
        case .pluto: return "Pluto"
        case .northNode: return "North Node"
        case .chiron: return "Chiron"
        case .ascendant: return "Ascendant"
        case .midheaven: return "Midheaven"
        }
    }

    var glyph: String {
        switch self {
        case .sun: return "\u{2609}"
        case .moon: return "\u{263D}"
        case .mercury: return "\u{263F}"
        case .venus: return "\u{2640}"
        case .mars: return "\u{2642}"
        case .jupiter: return "\u{2643}"
        case .saturn: return "\u{2644}"
        case .uranus: return "\u{2645}"
        case .neptune: return "\u{2646}"
        case .pluto: return "\u{2647}"
        case .northNode: return "\u{260A}"
        case .chiron: return "\u{26B7}"
        case .ascendant: return "AC"
        case .midheaven: return "MC"
        }
    }

    var shortName: String {
        switch self {
        case .sun: return "Su"
        case .moon: return "Mo"
        case .mercury: return "Me"
        case .venus: return "Ve"
        case .mars: return "Ma"
        case .jupiter: return "Ju"
        case .saturn: return "Sa"
        case .uranus: return "Ur"
        case .neptune: return "Ne"
        case .pluto: return "Pl"
        case .northNode: return "NN"
        case .chiron: return "Ch"
        case .ascendant: return "AC"
        case .midheaven: return "MC"
        }
    }

    var isPersonal: Bool {
        switch self {
        case .sun, .moon, .mercury, .venus, .mars: return true
        default: return false
        }
    }

    var color: Color {
        switch self {
        case .sun: return ResonanceColors.goldPrimary
        case .moon: return Color(hex: "C0C0D0")
        case .mercury: return ResonanceColors.air
        case .venus: return Color(hex: "D4A0B0")
        case .mars: return ResonanceColors.fire
        case .jupiter: return Color(hex: "8B6CB0")
        case .saturn: return ResonanceColors.earth
        case .uranus: return Color(hex: "4FC1C9")
        case .neptune: return Color(hex: "6A8EC9")
        case .pluto: return Color(hex: "8B5E6B")
        case .northNode: return ResonanceColors.goldLight
        case .chiron: return Color(hex: "A0926B")
        case .ascendant: return ResonanceColors.goldPrimary
        case .midheaven: return ResonanceColors.goldPrimary
        }
    }
}

// MARK: - Planetary Position

struct PlanetaryPosition: Identifiable, Codable {
    let id: UUID
    let planet: Planet
    let longitude: Double // 0-360 degrees
    let isRetrograde: Bool

    var sign: ZodiacSign {
        ZodiacSign(rawValue: Int(longitude / 30.0) % 12) ?? .aries
    }

    var degreeInSign: Double {
        longitude.truncatingRemainder(dividingBy: 30.0)
    }

    var formattedPosition: String {
        let deg = Int(degreeInSign)
        let min = Int((degreeInSign - Double(deg)) * 60)
        let retro = isRetrograde ? " R" : ""
        return "\(deg)\u{00B0}\(min)' \(sign.name)\(retro)"
    }

    init(planet: Planet, longitude: Double, isRetrograde: Bool = false) {
        self.id = UUID()
        self.planet = planet
        self.longitude = longitude.truncatingRemainder(dividingBy: 360.0)
        self.isRetrograde = isRetrograde
    }
}

// MARK: - House

struct House: Identifiable, Codable {
    let id: UUID
    let number: Int // 1-12
    let cuspDegree: Double // 0-360

    var sign: ZodiacSign {
        ZodiacSign(rawValue: Int(cuspDegree / 30.0) % 12) ?? .aries
    }

    var romanNumeral: String {
        let numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]
        return numerals[number - 1]
    }

    var meaning: String {
        switch number {
        case 1: return "Self & Identity"
        case 2: return "Values & Resources"
        case 3: return "Communication"
        case 4: return "Home & Roots"
        case 5: return "Creativity & Joy"
        case 6: return "Health & Service"
        case 7: return "Partnerships"
        case 8: return "Transformation"
        case 9: return "Philosophy & Travel"
        case 10: return "Career & Legacy"
        case 11: return "Community & Vision"
        case 12: return "Spirituality & Dreams"
        default: return ""
        }
    }

    init(number: Int, cuspDegree: Double) {
        self.id = UUID()
        self.number = number
        self.cuspDegree = cuspDegree
    }
}

// MARK: - Aspect

enum AspectType: String, CaseIterable, Codable {
    case conjunction
    case sextile
    case square
    case trine
    case opposition

    var angle: Double {
        switch self {
        case .conjunction: return 0
        case .sextile: return 60
        case .square: return 90
        case .trine: return 120
        case .opposition: return 180
        }
    }

    var orb: Double {
        switch self {
        case .conjunction: return 8
        case .sextile: return 6
        case .square: return 7
        case .trine: return 8
        case .opposition: return 8
        }
    }

    var symbol: String {
        switch self {
        case .conjunction: return "\u{260C}"
        case .sextile: return "\u{26B9}"
        case .square: return "\u{25A1}"
        case .trine: return "\u{25B3}"
        case .opposition: return "\u{260D}"
        }
    }

    var name: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .conjunction: return ResonanceColors.goldPrimary
        case .sextile: return ResonanceColors.air
        case .square: return ResonanceColors.fire
        case .trine: return ResonanceColors.water
        case .opposition: return ResonanceColors.fire.opacity(0.8)
        }
    }

    var isHarmonious: Bool {
        switch self {
        case .trine, .sextile: return true
        case .conjunction: return true // generally
        case .square, .opposition: return false
        }
    }

    var lineStyle: StrokeStyle {
        switch self {
        case .conjunction: return StrokeStyle(lineWidth: 1.5)
        case .sextile: return StrokeStyle(lineWidth: 1, dash: [4, 4])
        case .square: return StrokeStyle(lineWidth: 1.5)
        case .trine: return StrokeStyle(lineWidth: 1.5)
        case .opposition: return StrokeStyle(lineWidth: 1.5, dash: [8, 4])
        }
    }
}

struct Aspect: Identifiable, Codable {
    let id: UUID
    let planet1: Planet
    let planet2: Planet
    let type: AspectType
    let exactAngle: Double
    let orb: Double

    var description: String {
        "\(planet1.name) \(type.symbol) \(planet2.name) (\(String(format: "%.1f", orb))\u{00B0})"
    }

    init(planet1: Planet, planet2: Planet, type: AspectType, exactAngle: Double, orb: Double) {
        self.id = UUID()
        self.planet1 = planet1
        self.planet2 = planet2
        self.type = type
        self.exactAngle = exactAngle
        self.orb = orb
    }
}

// MARK: - Natal Chart

struct NatalChart: Identifiable, Codable {
    let id: UUID
    let birthDate: Date
    let birthPlace: String
    let latitude: Double
    let longitude: Double
    let planets: [PlanetaryPosition]
    let houses: [House]
    let aspects: [Aspect]

    var sunSign: ZodiacSign {
        planets.first(where: { $0.planet == .sun })?.sign ?? .aries
    }

    var moonSign: ZodiacSign {
        planets.first(where: { $0.planet == .moon })?.sign ?? .aries
    }

    var risingSign: ZodiacSign {
        planets.first(where: { $0.planet == .ascendant })?.sign ?? .aries
    }

    init(
        birthDate: Date,
        birthPlace: String,
        latitude: Double = 0,
        longitude: Double = 0,
        planets: [PlanetaryPosition],
        houses: [House],
        aspects: [Aspect]
    ) {
        self.id = UUID()
        self.birthDate = birthDate
        self.birthPlace = birthPlace
        self.latitude = latitude
        self.longitude = longitude
        self.planets = planets
        self.houses = houses
        self.aspects = aspects
    }
}

// MARK: - Transit

struct Transit: Identifiable {
    let id = UUID()
    let planet: Planet
    let sign: ZodiacSign
    let aspectType: AspectType?
    let natalPlanet: Planet?
    let description: String
    let startDate: Date
    let endDate: Date
    let intensity: Double // 0-1

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
}

// MARK: - Moon Phase

enum MoonPhase: String, CaseIterable {
    case newMoon = "New Moon"
    case waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter"
    case waxingGibbous = "Waxing Gibbous"
    case fullMoon = "Full Moon"
    case waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter"
    case waningCrescent = "Waning Crescent"

    var icon: String {
        switch self {
        case .newMoon: return "\u{1F311}"
        case .waxingCrescent: return "\u{1F312}"
        case .firstQuarter: return "\u{1F313}"
        case .waxingGibbous: return "\u{1F314}"
        case .fullMoon: return "\u{1F315}"
        case .waningGibbous: return "\u{1F316}"
        case .lastQuarter: return "\u{1F317}"
        case .waningCrescent: return "\u{1F318}"
        }
    }

    var illumination: Double {
        switch self {
        case .newMoon: return 0.0
        case .waxingCrescent: return 0.25
        case .firstQuarter: return 0.5
        case .waxingGibbous: return 0.75
        case .fullMoon: return 1.0
        case .waningGibbous: return 0.75
        case .lastQuarter: return 0.5
        case .waningCrescent: return 0.25
        }
    }

    var ritual: String {
        switch self {
        case .newMoon: return "Set intentions, plant seeds of desire"
        case .waxingCrescent: return "Take initial action, build momentum"
        case .firstQuarter: return "Push through challenges, commit"
        case .waxingGibbous: return "Refine and adjust your approach"
        case .fullMoon: return "Celebrate, release what no longer serves"
        case .waningGibbous: return "Express gratitude, share wisdom"
        case .lastQuarter: return "Let go, forgive, create space"
        case .waningCrescent: return "Rest, surrender, dream"
        }
    }
}

// MARK: - Journal Entry

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let prompt: String
    var response: String
    let transitContext: String?
    let moonPhase: String?

    init(date: Date = Date(), prompt: String, response: String = "", transitContext: String? = nil, moonPhase: String? = nil) {
        self.id = UUID()
        self.date = date
        self.prompt = prompt
        self.response = response
        self.transitContext = transitContext
        self.moonPhase = moonPhase
    }
}

// MARK: - Chapter

struct BookChapter: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let content: [ChapterSection]
}

struct ChapterSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

// MARK: - Meditation

struct GuidedMeditation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let duration: TimeInterval
    let steps: [MeditationStep]
    let category: MeditationCategory
}

struct MeditationStep: Identifiable {
    let id = UUID()
    let instruction: String
    let duration: TimeInterval
    let breathPattern: BreathPattern?
}

struct BreathPattern {
    let inhale: TimeInterval
    let hold: TimeInterval
    let exhale: TimeInterval
}

enum MeditationCategory: String, CaseIterable {
    case attunement = "Stargazer's Attunement"
    case planetary = "Planetary Meditation"
    case elemental = "Elemental Balancing"
    case lunar = "Lunar Alignment"
}

// MARK: - User Profile

struct UserProfile: Codable {
    var name: String
    var birthDate: Date
    var birthTime: Date?
    var birthPlace: String
    var latitude: Double
    var longitude: Double
    var isDarkMode: Bool
    var hasCompletedOnboarding: Bool
    var natalChart: NatalChart?

    static let empty = UserProfile(
        name: "",
        birthDate: Date(),
        birthTime: nil,
        birthPlace: "",
        latitude: 0,
        longitude: 0,
        isDarkMode: false,
        hasCompletedOnboarding: false,
        natalChart: nil
    )
}
