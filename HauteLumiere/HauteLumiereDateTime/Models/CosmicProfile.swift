// CosmicProfile.swift
// Haute Lumière Date & Time — Cosmic Profile Models
//
// Birth data → Full cosmic identity across 5 traditions:
// Western Astrology, Numerology, Ayurveda, Five Elements, Enneagram
// Each tradition produces its own assessment; together they form
// the most personalized cosmic intelligence available anywhere.

import Foundation

// MARK: - Birth Data (User Input)
struct BirthData: Codable, Identifiable {
    let id: UUID
    var dateOfBirth: Date
    var timeOfBirth: Date?       // Optional but unlocks full chart
    var birthCity: String
    var birthCountry: String
    var latitude: Double
    var longitude: Double
    var timeZoneOffset: Int      // UTC offset at birth location
    var fullName: String         // For numerology

    init(name: String = "", dateOfBirth: Date = Date(), city: String = "", country: String = "") {
        self.id = UUID()
        self.fullName = name
        self.dateOfBirth = dateOfBirth
        self.birthCity = city
        self.birthCountry = country
        self.latitude = 0
        self.longitude = 0
        self.timeZoneOffset = 0
    }

    var hasBirthTime: Bool { timeOfBirth != nil }
}

// MARK: - Complete Cosmic Profile
struct CosmicProfile: Codable, Identifiable {
    let id: UUID
    let birthData: BirthData
    var astrology: AstrologyProfile
    var numerology: NumerologyProfile
    var ayurveda: AyurvedaProfile
    var fiveElements: FiveElementsProfile
    var enneagram: EnneagramProfile
    var createdAt: Date

    init(birthData: BirthData) {
        self.id = UUID()
        self.birthData = birthData
        self.astrology = AstrologyProfile(birthData: birthData)
        self.numerology = NumerologyProfile(name: birthData.fullName, birthDate: birthData.dateOfBirth)
        self.ayurveda = AyurvedaProfile(birthData: birthData)
        self.fiveElements = FiveElementsProfile(birthData: birthData)
        self.enneagram = EnneagramProfile()
        self.createdAt = Date()
    }
}

// MARK: - Western Astrology Profile
struct AstrologyProfile: Codable {
    // Core Identity
    var sunSign: ZodiacSign
    var moonSign: ZodiacSign
    var risingSign: ZodiacSign      // Requires birth time

    // Planets
    var mercury: PlanetPlacement
    var venus: PlanetPlacement
    var mars: PlanetPlacement
    var jupiter: PlanetPlacement
    var saturn: PlanetPlacement
    var uranus: PlanetPlacement
    var neptune: PlanetPlacement
    var pluto: PlanetPlacement
    var northNode: PlanetPlacement  // Destiny point

    // Calculated
    var aspects: [Aspect]
    var houses: [HousePlacement]
    var dominantElement: AstroElement
    var dominantModality: Modality

    init(birthData: BirthData) {
        let month = Calendar.current.component(.month, from: birthData.dateOfBirth)
        let day = Calendar.current.component(.day, from: birthData.dateOfBirth)
        self.sunSign = ZodiacSign.fromDate(month: month, day: day)
        self.moonSign = .cancer // Calculated from ephemeris in production
        self.risingSign = .libra // Requires birth time + location

        // Simplified placements (real app uses Swiss Ephemeris)
        self.mercury = PlanetPlacement(planet: .mercury, sign: sunSign, degree: 15.0, house: 1, isRetrograde: false)
        self.venus = PlanetPlacement(planet: .venus, sign: sunSign.next, degree: 22.0, house: 2, isRetrograde: false)
        self.mars = PlanetPlacement(planet: .mars, sign: sunSign.previous, degree: 8.0, house: 6, isRetrograde: false)
        self.jupiter = PlanetPlacement(planet: .jupiter, sign: .sagittarius, degree: 12.0, house: 9, isRetrograde: false)
        self.saturn = PlanetPlacement(planet: .saturn, sign: .capricorn, degree: 28.0, house: 10, isRetrograde: false)
        self.uranus = PlanetPlacement(planet: .uranus, sign: .aquarius, degree: 5.0, house: 11, isRetrograde: false)
        self.neptune = PlanetPlacement(planet: .neptune, sign: .pisces, degree: 19.0, house: 12, isRetrograde: false)
        self.pluto = PlanetPlacement(planet: .pluto, sign: .scorpio, degree: 14.0, house: 8, isRetrograde: false)
        self.northNode = PlanetPlacement(planet: .northNode, sign: .leo, degree: 3.0, house: 5, isRetrograde: true)

        self.aspects = []
        self.houses = []
        self.dominantElement = sunSign.element
        self.dominantModality = sunSign.modality
    }

    var allPlanets: [PlanetPlacement] {
        [mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto, northNode]
    }
}

// MARK: - Zodiac
enum ZodiacSign: String, Codable, CaseIterable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var displayName: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    var element: AstroElement {
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

    var rulingPlanet: CelestialBody {
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

    var next: ZodiacSign {
        let all = ZodiacSign.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 1) % 12]
    }

    var previous: ZodiacSign {
        let all = ZodiacSign.allCases
        let idx = all.firstIndex(of: self)!
        return all[(idx + 11) % 12]
    }

    static func fromDate(month: Int, day: Int) -> ZodiacSign {
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return .aries
        case (4, 20...30), (5, 1...20): return .taurus
        case (5, 21...31), (6, 1...20): return .gemini
        case (6, 21...30), (7, 1...22): return .cancer
        case (7, 23...31), (8, 1...22): return .leo
        case (8, 23...31), (9, 1...22): return .virgo
        case (9, 23...30), (10, 1...22): return .libra
        case (10, 23...31), (11, 1...21): return .scorpio
        case (11, 22...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...19): return .capricorn
        case (1, 20...31), (2, 1...18): return .aquarius
        case (2, 19...29), (3, 1...20): return .pisces
        default: return .aries
        }
    }
}

enum AstroElement: String, Codable { case fire, earth, air, water }
enum Modality: String, Codable { case cardinal, fixed, mutable }

enum CelestialBody: String, Codable, CaseIterable {
    case sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto, northNode

    var displayName: String {
        switch self {
        case .northNode: return "North Node"
        default: return rawValue.capitalized
        }
    }

    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        case .northNode: return "☊"
        }
    }

    /// Significance in the chart — what this planet governs
    var domain: String {
        switch self {
        case .sun: return "Core identity, vitality, life purpose"
        case .moon: return "Emotions, intuition, inner world, needs"
        case .mercury: return "Communication, thinking, learning, perception"
        case .venus: return "Love, beauty, values, pleasure, attraction"
        case .mars: return "Drive, ambition, courage, sexuality, conflict"
        case .jupiter: return "Expansion, luck, wisdom, abundance, faith"
        case .saturn: return "Discipline, structure, karmic lessons, mastery"
        case .uranus: return "Revolution, innovation, freedom, awakening"
        case .neptune: return "Dreams, spirituality, illusion, transcendence"
        case .pluto: return "Transformation, power, death/rebirth, shadow"
        case .northNode: return "Soul's purpose, destiny, evolutionary direction"
        }
    }
}

struct PlanetPlacement: Codable, Identifiable {
    let id: UUID
    let planet: CelestialBody
    let sign: ZodiacSign
    let degree: Double
    let house: Int
    let isRetrograde: Bool

    init(planet: CelestialBody, sign: ZodiacSign, degree: Double, house: Int, isRetrograde: Bool) {
        self.id = UUID()
        self.planet = planet
        self.sign = sign
        self.degree = degree
        self.house = house
        self.isRetrograde = isRetrograde
    }
}

struct Aspect: Codable, Identifiable {
    let id: UUID
    let planet1: CelestialBody
    let planet2: CelestialBody
    let type: AspectType
    let orb: Double // degrees of inexactness

    enum AspectType: String, Codable {
        case conjunction = "Conjunction"     // 0° — fusion
        case sextile = "Sextile"            // 60° — opportunity
        case square = "Square"              // 90° — tension/growth
        case trine = "Trine"               // 120° — harmony/flow
        case opposition = "Opposition"      // 180° — polarity/awareness

        var nature: String {
            switch self {
            case .conjunction: return "Intensification"
            case .sextile: return "Opportunity"
            case .square: return "Creative tension"
            case .trine: return "Natural flow"
            case .opposition: return "Dynamic balance"
            }
        }
    }
}

struct HousePlacement: Codable, Identifiable {
    let id: UUID
    let house: Int
    let sign: ZodiacSign
    let planets: [CelestialBody]

    static let houseNames = [
        "Self & Identity", "Values & Resources", "Communication & Mind",
        "Home & Foundations", "Creativity & Joy", "Health & Service",
        "Partnerships", "Transformation & Shared Resources", "Philosophy & Travel",
        "Career & Public Life", "Community & Aspirations", "Spirituality & Transcendence"
    ]
}

// MARK: - Numerology Profile
struct NumerologyProfile: Codable {
    var lifePathNumber: Int
    var expressionNumber: Int
    var soulUrgeNumber: Int
    var personalityNumber: Int
    var birthdayNumber: Int
    var maturityNumber: Int
    var currentPersonalYear: Int
    var currentPersonalMonth: Int

    init(name: String, birthDate: Date) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: birthDate)
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 2000

        self.lifePathNumber = NumerologyProfile.reduceToSingle(month + day + NumerologyProfile.reduceDigits(year))
        self.birthdayNumber = NumerologyProfile.reduceToSingle(day)
        self.expressionNumber = NumerologyProfile.nameToNumber(name)
        self.soulUrgeNumber = NumerologyProfile.vowelsToNumber(name)
        self.personalityNumber = NumerologyProfile.consonantsToNumber(name)
        self.maturityNumber = NumerologyProfile.reduceToSingle(lifePathNumber + expressionNumber)

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        self.currentPersonalYear = NumerologyProfile.reduceToSingle(month + day + NumerologyProfile.reduceDigits(currentYear))
        self.currentPersonalMonth = NumerologyProfile.reduceToSingle(currentPersonalYear + currentMonth)
    }

    static func reduceToSingle(_ num: Int) -> Int {
        var n = abs(num)
        while n > 9 && n != 11 && n != 22 && n != 33 { // Master numbers preserved
            n = String(n).compactMap(\.wholeNumberValue).reduce(0, +)
        }
        return n
    }

    static func reduceDigits(_ num: Int) -> Int {
        String(num).compactMap(\.wholeNumberValue).reduce(0, +)
    }

    static func nameToNumber(_ name: String) -> Int {
        let values: [Character: Int] = ["a":1,"b":2,"c":3,"d":4,"e":5,"f":6,"g":7,"h":8,"i":9,
                                         "j":1,"k":2,"l":3,"m":4,"n":5,"o":6,"p":7,"q":8,"r":9,
                                         "s":1,"t":2,"u":3,"v":4,"w":5,"x":6,"y":7,"z":8]
        let total = name.lowercased().compactMap { values[$0] }.reduce(0, +)
        return reduceToSingle(total)
    }

    static func vowelsToNumber(_ name: String) -> Int {
        let vowels: Set<Character> = ["a","e","i","o","u"]
        let values: [Character: Int] = ["a":1,"e":5,"i":9,"o":6,"u":3]
        let total = name.lowercased().filter { vowels.contains($0) }.compactMap { values[$0] }.reduce(0, +)
        return reduceToSingle(total)
    }

    static func consonantsToNumber(_ name: String) -> Int {
        let vowels: Set<Character> = ["a","e","i","o","u"," "]
        let values: [Character: Int] = ["b":2,"c":3,"d":4,"f":6,"g":7,"h":8,"j":1,"k":2,"l":3,"m":4,
                                         "n":5,"p":7,"q":8,"r":9,"s":1,"t":2,"v":4,"w":5,"x":6,"y":7,"z":8]
        let total = name.lowercased().filter { !vowels.contains($0) }.compactMap { values[$0] }.reduce(0, +)
        return reduceToSingle(total)
    }

    /// Life Path meaning (1-9, 11, 22, 33)
    var lifePathMeaning: String {
        switch lifePathNumber {
        case 1: return "The Pioneer — Leadership, independence, originality. You're here to forge new paths."
        case 2: return "The Diplomat — Cooperation, sensitivity, balance. You're here to bridge and harmonize."
        case 3: return "The Creator — Expression, joy, creativity. You're here to inspire through communication."
        case 4: return "The Builder — Structure, discipline, foundation. You're here to create lasting value."
        case 5: return "The Adventurer — Freedom, change, experience. You're here to explore all of life."
        case 6: return "The Nurturer — Responsibility, love, service. You're here to heal and support."
        case 7: return "The Seeker — Wisdom, analysis, spirituality. You're here to understand the mysteries."
        case 8: return "The Powerhouse — Authority, abundance, karma. You're here to master the material."
        case 9: return "The Humanitarian — Compassion, completion, universal love. You're here to serve humanity."
        case 11: return "The Illuminator — Master number. Spiritual insight, intuition, visionary inspiration."
        case 22: return "The Master Builder — Master number. Manifesting grand visions into reality."
        case 33: return "The Master Teacher — Master number. Uplifting humanity through compassionate wisdom."
        default: return "A unique vibration in the cosmic tapestry."
        }
    }
}

// MARK: - Ayurveda Profile
struct AyurvedaProfile: Codable {
    var primaryDosha: Dosha
    var secondaryDosha: Dosha
    var prakruti: String      // Birth constitution
    var vikruti: String       // Current imbalance
    var seasonalRecommendations: [String]
    var dietaryGuidance: [String]
    var practiceRecommendations: [String]

    enum Dosha: String, Codable, CaseIterable {
        case vata = "Vata"
        case pitta = "Pitta"
        case kapha = "Kapha"

        var element: String {
            switch self {
            case .vata: return "Air + Space"
            case .pitta: return "Fire + Water"
            case .kapha: return "Earth + Water"
            }
        }

        var qualities: [String] {
            switch self {
            case .vata: return ["Creative", "Quick-thinking", "Adaptable", "Energetic", "Visionary"]
            case .pitta: return ["Focused", "Determined", "Intelligent", "Passionate", "Charismatic"]
            case .kapha: return ["Steady", "Compassionate", "Patient", "Strong", "Loyal"]
            }
        }

        var balancingPractices: [String] {
            switch self {
            case .vata: return ["Grounding meditation", "Warm oil massage", "Gentle yoga", "Nourishing warm foods", "Regular routine"]
            case .pitta: return ["Cooling breathwork", "Nature walks", "Sitali breathing", "Cool foods", "Moon gazing"]
            case .kapha: return ["Dynamic breathwork", "Vigorous movement", "Kapalabhati", "Light spicy foods", "Sunrise practice"]
            }
        }
    }

    init(birthData: BirthData) {
        // Simplified dosha determination from birth season
        let month = Calendar.current.component(.month, from: birthData.dateOfBirth)
        switch month {
        case 10...2: self.primaryDosha = .vata; self.secondaryDosha = .kapha
        case 3...6: self.primaryDosha = .pitta; self.secondaryDosha = .vata
        default: self.primaryDosha = .kapha; self.secondaryDosha = .pitta
        }
        self.prakruti = "\(primaryDosha.rawValue)-\(secondaryDosha.rawValue)"
        self.vikruti = primaryDosha.rawValue
        self.seasonalRecommendations = primaryDosha.balancingPractices
        self.dietaryGuidance = []
        self.practiceRecommendations = primaryDosha.balancingPractices
    }
}

// MARK: - Five Elements Profile (Wu Xing)
struct FiveElementsProfile: Codable {
    var dominantElement: WuXingElement
    var secondaryElement: WuXingElement
    var deficientElement: WuXingElement
    var elementBalance: [WuXingElement: Double]

    enum WuXingElement: String, Codable, CaseIterable {
        case wood = "Wood"
        case fire = "Fire"
        case earth = "Earth"
        case metal = "Metal"
        case water = "Water"

        var season: String {
            switch self {
            case .wood: return "Spring"
            case .fire: return "Summer"
            case .earth: return "Late Summer"
            case .metal: return "Autumn"
            case .water: return "Winter"
            }
        }

        var organ: String {
            switch self {
            case .wood: return "Liver / Gallbladder"
            case .fire: return "Heart / Small Intestine"
            case .earth: return "Spleen / Stomach"
            case .metal: return "Lungs / Large Intestine"
            case .water: return "Kidneys / Bladder"
            }
        }

        var emotion: String {
            switch self {
            case .wood: return "Anger → Kindness"
            case .fire: return "Joy → Compassion"
            case .earth: return "Worry → Empathy"
            case .metal: return "Grief → Courage"
            case .water: return "Fear → Wisdom"
            }
        }

        var qiGungBreathing: String {
            switch self {
            case .wood: return "Liver Cleansing Breath — SHHHH sound"
            case .fire: return "Heart Harmonizing — HAWWW sound"
            case .earth: return "Spleen Strengthening — WHOOO sound"
            case .metal: return "Lung Purifying — SSSS sound"
            case .water: return "Kidney Nourishing — CHEWWW sound"
            }
        }
    }

    init(birthData: BirthData) {
        let year = Calendar.current.component(.year, from: birthData.dateOfBirth)
        let elementIndex = (year % 10) / 2
        let elements = WuXingElement.allCases
        self.dominantElement = elements[elementIndex % 5]
        self.secondaryElement = elements[(elementIndex + 1) % 5]
        self.deficientElement = elements[(elementIndex + 3) % 5]
        self.elementBalance = Dictionary(uniqueKeysWithValues: elements.map { ($0, $0 == self.dominantElement ? 8.0 : $0 == self.secondaryElement ? 6.5 : 5.0) })
    }
}

// MARK: - Enneagram Profile
struct EnneagramProfile: Codable {
    var coreType: EnneagramType
    var wing: EnneagramType
    var instinctualVariant: InstinctualVariant
    var integrationDirection: EnneagramType
    var disintegrationDirection: EnneagramType
    var triadicCenter: TriadicCenter

    enum EnneagramType: Int, Codable, CaseIterable {
        case reformer = 1, helper = 2, achiever = 3
        case individualist = 4, investigator = 5, loyalist = 6
        case enthusiast = 7, challenger = 8, peacemaker = 9

        var displayName: String {
            switch self {
            case .reformer: return "The Reformer"
            case .helper: return "The Helper"
            case .achiever: return "The Achiever"
            case .individualist: return "The Individualist"
            case .investigator: return "The Investigator"
            case .loyalist: return "The Loyalist"
            case .enthusiast: return "The Enthusiast"
            case .challenger: return "The Challenger"
            case .peacemaker: return "The Peacemaker"
            }
        }

        var coreMotivation: String {
            switch self {
            case .reformer: return "To be good, right, and balanced"
            case .helper: return "To be loved and needed"
            case .achiever: return "To be valuable and worthwhile"
            case .individualist: return "To be unique and authentic"
            case .investigator: return "To be capable and competent"
            case .loyalist: return "To be secure and supported"
            case .enthusiast: return "To be satisfied and fulfilled"
            case .challenger: return "To be strong and in control"
            case .peacemaker: return "To be at peace and harmonious"
            }
        }

        var coreFear: String {
            switch self {
            case .reformer: return "Being corrupt or defective"
            case .helper: return "Being unwanted or unloved"
            case .achiever: return "Being worthless or without value"
            case .individualist: return "Having no identity or significance"
            case .investigator: return "Being helpless or incompetent"
            case .loyalist: return "Being without support or guidance"
            case .enthusiast: return "Being deprived or trapped in pain"
            case .challenger: return "Being controlled or vulnerable"
            case .peacemaker: return "Loss of connection or fragmentation"
            }
        }
    }

    enum InstinctualVariant: String, Codable {
        case selfPreservation = "Self-Preservation"
        case sexual = "Sexual / One-to-One"
        case social = "Social"
    }

    enum TriadicCenter: String, Codable {
        case body = "Body Center (8-9-1)"
        case heart = "Heart Center (2-3-4)"
        case head = "Head Center (5-6-7)"
    }

    init() {
        self.coreType = .individualist
        self.wing = .investigator
        self.instinctualVariant = .selfPreservation
        self.integrationDirection = .reformer
        self.disintegrationDirection = .helper
        self.triadicCenter = .heart
    }
}

// MARK: - Daily Cosmic Forecast
struct DailyCosmicForecast: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sunTransit: ZodiacSign
    let moonPhase: MoonPhase
    let planetaryTransits: [TransitEvent]
    var lifeWheelForecasts: [LifeWheelForecast]
    var auspiciousTimes: [AuspiciousTime]
    var dailyNumerology: DailyNumerology
    var doshaAdvice: String
    var elementFocus: FiveElementsProfile.WuXingElement
    var overallEnergy: String
    var cosmicWeather: String

    enum MoonPhase: String, Codable {
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
            case .newMoon: return "moon.fill"
            case .waxingCrescent: return "moon.stars.fill"
            case .firstQuarter: return "moon.circle"
            case .waxingGibbous: return "moon.haze.fill"
            case .fullMoon: return "sun.and.horizon.fill"
            case .waningGibbous: return "moon.haze"
            case .lastQuarter: return "moon.circle"
            case .waningCrescent: return "moon.stars"
            }
        }
    }
}

struct TransitEvent: Codable, Identifiable {
    let id: UUID
    let planet: CelestialBody
    let transitSign: ZodiacSign
    let aspectToNatal: Aspect.AspectType?
    let natalPlanet: CelestialBody?
    let significance: String
}

struct LifeWheelForecast: Codable, Identifiable {
    let id: UUID
    let dimension: String    // Career, Love, Health, etc.
    let energy: Double       // 1-10 daily energy rating
    let forecast: String     // Personalized narrative
    let auspiciousFor: [String] // What this day is good for in this area
    let cosmicSupport: String   // Which planets/numbers support this
}

struct AuspiciousTime: Codable, Identifiable {
    let id: UUID
    let timeWindow: String   // "6:00 AM - 8:30 AM"
    let activity: String     // "Initiate new projects"
    let planetaryHour: CelestialBody
    let strength: AuspiciousStrength
    let traditions: [String] // Which traditions agree on this

    enum AuspiciousStrength: String, Codable {
        case exceptional = "Exceptional"
        case strong = "Strong"
        case favorable = "Favorable"
        case neutral = "Neutral"
    }
}

struct DailyNumerology: Codable {
    let universalDay: Int
    let personalDay: Int
    let vibration: String
    let advice: String
}

// MARK: - Reading Products
struct CosmicReading: Identifiable, Codable {
    let id: UUID
    let type: ReadingType
    let title: String
    let description: String
    let pageCount: Int
    let price: Decimal
    let traditions: [CosmicTradition]
    let generatedPDFData: Data?
    let createdAt: Date

    enum ReadingType: String, Codable {
        case bespokeReading = "Bespoke Reading"          // $30, 10-page PDF
        case yearAhead = "Year Ahead"                     // $99, comprehensive
        case relationshipReading = "Relationship Reading"  // $99, synastry + composite
        case monthlyCollectible = "Monthly Collectible"   // Included with subscription
    }
}

enum CosmicTradition: String, Codable, CaseIterable {
    case westernAstrology = "Western Astrology"
    case numerology = "Numerology"
    case ayurveda = "Ayurveda"
    case fiveElements = "Five Elements"
    case enneagram = "Enneagram"

    var icon: String {
        switch self {
        case .westernAstrology: return "star.circle.fill"
        case .numerology: return "number.circle.fill"
        case .ayurveda: return "leaf.circle.fill"
        case .fiveElements: return "flame.circle.fill"
        case .enneagram: return "circle.hexagongrid.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .westernAstrology: return "Planetary positions at your birth moment reveal your cosmic blueprint"
        case .numerology: return "The vibrational essence of your name and birth date"
        case .ayurveda: return "Your constitutional body-mind type and path to balance"
        case .fiveElements: return "The interplay of Wood, Fire, Earth, Metal, Water in your being"
        case .enneagram: return "Your core personality structure and path of integration"
        }
    }
}

// MARK: - Friend / Referral
struct FriendInvite: Identifiable, Codable {
    let id: UUID
    let inviterProfileId: UUID
    let inviteeEmail: String
    var status: InviteStatus
    let sentAt: Date
    var acceptedAt: Date?
    var rewardClaimed: Bool // Both get free relationship PDF

    enum InviteStatus: String, Codable {
        case pending, accepted, expired
    }

    init(inviterProfileId: UUID, inviteeEmail: String) {
        self.id = UUID()
        self.inviterProfileId = inviterProfileId
        self.inviteeEmail = inviteeEmail
        self.status = .pending
        self.sentAt = Date()
        self.rewardClaimed = false
    }
}
