// CosmicEngine.swift
// Haute Lumière Date & Time — Cosmic Intelligence Engine
//
// The core intelligence service that synthesizes all 5 traditions
// (astrology, numerology, ayurveda, five elements, enneagram) into
// a unified cosmic guidance system. Integrates with Life & Light
// Living Systems appreciative coaching from the main Haute Lumière app.
//
// Every meditation, reading, and forecast is synchronized with
// the user's stars, numbers, doshas, elements, and type.

import SwiftUI
import Combine

final class CosmicEngine: ObservableObject {
    // MARK: - Published State
    @Published var profile: CosmicProfile?
    @Published var birthData: BirthData = BirthData()
    @Published var todaysForecast: DailyCosmicForecast?
    @Published var isGenerating: Bool = false

    // MARK: - Social / Referral
    @Published var friendInvites: [FriendInvite] = []
    @Published var invitesRemaining: Int = 5

    // MARK: - Reading History
    @Published var readings: [CosmicReading] = []
    @Published var monthlyReports: [CosmicReading] = []

    // MARK: - Haute Lumière Integration
    /// Living Systems profile from the coaching app
    @Published var livingSystemsProfile: LivingSystemsProfile?
    /// Current coaching phase from Team Life Force
    @Published var coachingPhase: FiveDPhase = .discover

    // MARK: - Profile Generation

    func generateProfile(from birthData: BirthData) {
        self.birthData = birthData
        isGenerating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.profile = CosmicProfile(birthData: birthData)
            self.todaysForecast = self.generateDailyForecast()
            self.isGenerating = false
        }
    }

    // MARK: - Daily Forecast Generation

    func generateDailyForecast() -> DailyCosmicForecast? {
        guard let profile else { return nil }

        let today = Date()
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: today) ?? 1
        let month = Calendar.current.component(.month, from: today)
        let day = Calendar.current.component(.day, from: today)

        // Current sun transit
        let sunTransit = ZodiacSign.fromDate(month: month, day: day)

        // Moon phase (simplified 29.5-day cycle)
        let moonPhases = DailyCosmicForecast.MoonPhase.allCases
        let moonIndex = (dayOfYear % 29) / 4
        let moonPhase = moonPhases[min(moonIndex, moonPhases.count - 1)]

        // Life wheel forecasts — one for each dimension
        let lifeWheelDimensions = ["Career", "Love", "Health", "Finances", "Creativity",
                                    "Relationships", "Spirituality", "Personal Growth",
                                    "Fun & Recreation", "Environment"]

        let lifeWheelForecasts = lifeWheelDimensions.enumerated().map { index, dimension -> LifeWheelForecast in
            let energy = cosmicEnergyForDimension(dimension, day: dayOfYear, profile: profile)
            return LifeWheelForecast(
                id: UUID(),
                dimension: dimension,
                energy: energy,
                forecast: generateDimensionForecast(dimension, energy: energy, profile: profile),
                auspiciousFor: auspiciousActivities(dimension, energy: energy),
                cosmicSupport: cosmicSupportingFactors(dimension, profile: profile)
            )
        }

        // Auspicious times
        let auspiciousTimes = generateAuspiciousTimes(profile: profile, dayOfYear: dayOfYear)

        // Daily numerology
        let universalDay = NumerologyProfile.reduceToSingle(month + day + Calendar.current.component(.year, from: today))
        let personalDay = NumerologyProfile.reduceToSingle(universalDay + profile.numerology.lifePathNumber)
        let dailyNumerology = DailyNumerology(
            universalDay: universalDay,
            personalDay: personalDay,
            vibration: numerologyVibration(personalDay),
            advice: numerologyAdvice(personalDay, phase: coachingPhase)
        )

        // Element focus for today
        let elementIndex = dayOfYear % 5
        let elementFocus = FiveElementsProfile.WuXingElement.allCases[elementIndex]

        // Cosmic weather synthesis
        let cosmicWeather = synthesizeCosmicWeather(
            sunTransit: sunTransit, moonPhase: moonPhase,
            personalDay: personalDay, elementFocus: elementFocus,
            profile: profile
        )

        return DailyCosmicForecast(
            id: UUID(),
            date: today,
            sunTransit: sunTransit,
            moonPhase: moonPhase,
            planetaryTransits: [],
            lifeWheelForecasts: lifeWheelForecasts,
            auspiciousTimes: auspiciousTimes,
            dailyNumerology: dailyNumerology,
            doshaAdvice: doshaAdviceForToday(profile.ayurveda, moonPhase: moonPhase),
            elementFocus: elementFocus,
            overallEnergy: "\(Int(lifeWheelForecasts.map(\.energy).reduce(0, +) / Double(lifeWheelForecasts.count) * 10))%",
            cosmicWeather: cosmicWeather
        )
    }

    // MARK: - Cosmic Energy Calculation

    private func cosmicEnergyForDimension(_ dimension: String, day: Int, profile: CosmicProfile) -> Double {
        // Synthesize energy from all traditions
        let astroFactor = Double((day + profile.astrology.sunSign.hashValue) % 10) / 10.0
        let numFactor = Double(profile.numerology.currentPersonalYear % 9 + 1) / 10.0
        let elementFactor = (profile.fiveElements.elementBalance[profile.fiveElements.dominantElement] ?? 5.0) / 10.0

        let base = (astroFactor + numFactor + elementFactor) / 3.0
        return min(10.0, max(3.0, base * 10.0 + Double.random(in: -1...1)))
    }

    private func generateDimensionForecast(_ dimension: String, energy: Double, profile: CosmicProfile) -> String {
        let sign = profile.astrology.sunSign.displayName
        let lifePath = profile.numerology.lifePathNumber
        let dosha = profile.ayurveda.primaryDosha.rawValue

        if energy >= 8 {
            return "Exceptional cosmic alignment for \(dimension.lowercased()) today. Your \(sign) sun harmonizes with current transits, and your Life Path \(lifePath) resonance amplifies this. Your \(dosha) constitution is naturally supported — lean into bold moves."
        } else if energy >= 6 {
            return "Steady, favorable energy for \(dimension.lowercased()). The planets support measured progress. Your \(dosha) dosha benefits from staying grounded today. Good time for consolidation rather than initiation."
        } else {
            return "A day for reflection in \(dimension.lowercased()). Current transits suggest introspection rather than action. Your \(sign) nature may feel pulled inward — honor that. This is the calm before forward momentum."
        }
    }

    private func auspiciousActivities(_ dimension: String, energy: Double) -> [String] {
        if energy >= 7 {
            return ["Initiate new projects", "Have important conversations", "Make decisions"]
        } else if energy >= 5 {
            return ["Continue ongoing work", "Nurture relationships", "Plan ahead"]
        } else {
            return ["Rest and reflect", "Journal", "Meditate on intentions"]
        }
    }

    private func cosmicSupportingFactors(_ dimension: String, profile: CosmicProfile) -> String {
        let planet = profile.astrology.allPlanets.randomElement()!
        return "\(planet.planet.symbol) \(planet.planet.displayName) in \(planet.sign.displayName) supports your \(dimension.lowercased()) through \(planet.planet.domain.components(separatedBy: ",").first ?? "growth")"
    }

    // MARK: - Auspicious Times

    private func generateAuspiciousTimes(profile: CosmicProfile, dayOfYear: Int) -> [AuspiciousTime] {
        let planetaryHours: [CelestialBody] = [.sun, .venus, .mercury, .moon, .saturn, .jupiter, .mars]
        let hourIndex = dayOfYear % 7

        return [
            AuspiciousTime(
                id: UUID(),
                timeWindow: "6:00 AM — 8:30 AM",
                activity: "Begin new initiatives, set intentions",
                planetaryHour: planetaryHours[hourIndex],
                strength: .exceptional,
                traditions: ["Astrology", "Numerology", "Five Elements"]
            ),
            AuspiciousTime(
                id: UUID(),
                timeWindow: "10:00 AM — 11:30 AM",
                activity: "Important meetings, negotiations",
                planetaryHour: planetaryHours[(hourIndex + 1) % 7],
                strength: .strong,
                traditions: ["Astrology", "Ayurveda"]
            ),
            AuspiciousTime(
                id: UUID(),
                timeWindow: "2:00 PM — 3:30 PM",
                activity: "Creative work, artistic expression",
                planetaryHour: planetaryHours[(hourIndex + 3) % 7],
                strength: .favorable,
                traditions: ["Numerology", "Enneagram"]
            ),
            AuspiciousTime(
                id: UUID(),
                timeWindow: "7:00 PM — 9:00 PM",
                activity: "Deep practice, meditation, reflection",
                planetaryHour: planetaryHours[(hourIndex + 5) % 7],
                strength: .strong,
                traditions: ["Astrology", "Ayurveda", "Five Elements"]
            ),
        ]
    }

    // MARK: - Numerology Helpers

    private func numerologyVibration(_ number: Int) -> String {
        switch number {
        case 1: return "New beginnings, leadership energy"
        case 2: return "Partnership, receptivity, patience"
        case 3: return "Creative expression, joy, communication"
        case 4: return "Foundation building, discipline, structure"
        case 5: return "Change, freedom, adventure"
        case 6: return "Love, responsibility, nurturing"
        case 7: return "Introspection, wisdom, spiritual depth"
        case 8: return "Power, abundance, manifestation"
        case 9: return "Completion, compassion, release"
        case 11: return "Spiritual illumination, mastery"
        case 22: return "Master manifestation, grand vision"
        default: return "Unique vibrational energy"
        }
    }

    private func numerologyAdvice(_ number: Int, phase: FiveDPhase) -> String {
        "Personal Day \(number) in your \(phase.displayName) phase: \(numerologyVibration(number)). Align your actions with this energy for maximum flow."
    }

    // MARK: - Dosha / Element Helpers

    private func doshaAdviceForToday(_ ayurveda: AyurvedaProfile, moonPhase: DailyCosmicForecast.MoonPhase) -> String {
        let dosha = ayurveda.primaryDosha
        switch moonPhase {
        case .newMoon, .waningCrescent:
            return "\(dosha.rawValue) dominant: Rest and restore today. The new moon invites inward movement. Favor warm, grounding practices."
        case .fullMoon, .waxingGibbous:
            return "\(dosha.rawValue) dominant: Full moon amplifies your energy. Channel it through breathwork. Avoid overstimulation."
        default:
            return "\(dosha.rawValue) dominant: Balanced day ahead. Follow your \(dosha.rawValue) balancing practices for optimal flow."
        }
    }

    // MARK: - Cosmic Weather Synthesis

    private func synthesizeCosmicWeather(sunTransit: ZodiacSign, moonPhase: DailyCosmicForecast.MoonPhase, personalDay: Int, elementFocus: FiveElementsProfile.WuXingElement, profile: CosmicProfile) -> String {
        """
        Sun in \(sunTransit.displayName) \(sunTransit.symbol) · \(moonPhase.rawValue) · Personal Day \(personalDay) · \(elementFocus.rawValue) Element Focus

        Your \(profile.astrology.sunSign.displayName) sun meets today's \(sunTransit.displayName) energy. \
        The \(moonPhase.rawValue.lowercased()) invites \(moonPhase == .fullMoon ? "expansion and visibility" : moonPhase == .newMoon ? "intention setting and planting seeds" : "steady progress"). \
        Your \(profile.ayurveda.primaryDosha.rawValue) constitution benefits from \(elementFocus.rawValue.lowercased()) element practices today — \
        particularly \(elementFocus.qiGungBreathing.lowercased()).

        Numerological vibration: \(numerologyVibration(personalDay)).
        """
    }

    // MARK: - Meditation Synchronization

    /// Generate a meditation recommendation synchronized with current cosmic weather
    func cosmicMeditationRecommendation() -> CosmicMeditationSync? {
        guard let profile, let forecast = todaysForecast else { return nil }

        let dosha = profile.ayurveda.primaryDosha
        let element = forecast.elementFocus
        let moonPhase = forecast.moonPhase

        // Select breathing technique based on dosha + element + moon
        let breathingTechnique: String
        switch (dosha, moonPhase) {
        case (.vata, .newMoon), (.vata, .waningCrescent):
            breathingTechnique = "Nadi Shodhana (Alternate Nostril) — grounding for Vata during quiet moon"
        case (.pitta, .fullMoon), (.pitta, .waxingGibbous):
            breathingTechnique = "Sitali (Cooling Breath) — soothing Pitta under full moon intensity"
        case (.kapha, _):
            breathingTechnique = "Kapalabhati (Skull Shining) — energizing Kapha with \(element.rawValue) element support"
        default:
            breathingTechnique = "Coherent Breathing — harmonizing all systems under \(moonPhase.rawValue.lowercased())"
        }

        // Select soundscape based on element
        let soundscape: String
        switch element {
        case .wood: soundscape = "Forest sounds with morning birds"
        case .fire: soundscape = "Crackling fire with Tibetan bowls"
        case .earth: soundscape = "Rain on earth with deep drone"
        case .metal: soundscape = "Crystal singing bowls with wind"
        case .water: soundscape = "Ocean waves with whale song"
        }

        // Visualization theme from astrology
        let visualization: String
        switch profile.astrology.sunSign.element {
        case .fire: visualization = "Golden light expanding from your solar plexus"
        case .earth: visualization = "Roots growing deep into rich, dark earth"
        case .air: visualization = "Rising through clouds into crystalline sky"
        case .water: visualization = "Floating in warm, luminous water under starlight"
        }

        // Duration recommendation from numerology
        let duration: Int
        switch forecast.dailyNumerology.personalDay {
        case 1, 8: duration = 20
        case 2, 6: duration = 30
        case 3, 5, 7: duration = 25
        case 4, 9: duration = 15
        case 11, 22: duration = 33  // Master number duration
        default: duration = 20
        }

        return CosmicMeditationSync(
            breathingTechnique: breathingTechnique,
            soundscape: soundscape,
            visualization: visualization,
            duration: duration,
            binauralFrequency: moonPhase == .fullMoon ? 7.83 : 4.0,
            cosmicRationale: "Today's \(moonPhase.rawValue.lowercased()) in \(profile.astrology.sunSign.element.rawValue) season, combined with your \(dosha.rawValue) constitution and \(element.rawValue) element focus, calls for \(breathingTechnique.components(separatedBy: "—").first ?? "this practice").",
            auspiciousTime: forecast.auspiciousTimes.last?.timeWindow ?? "7:00 PM — 9:00 PM"
        )
    }

    // MARK: - Friend Invites / Referral

    func sendInvite(to email: String) -> Bool {
        guard invitesRemaining > 0, let profile else { return false }
        let invite = FriendInvite(inviterProfileId: profile.id, inviteeEmail: email)
        friendInvites.append(invite)
        invitesRemaining -= 1
        return true
    }

    func acceptInvite(_ invite: FriendInvite) {
        if let index = friendInvites.firstIndex(where: { $0.id == invite.id }) {
            friendInvites[index].status = .accepted
            friendInvites[index].acceptedAt = Date()
            // Both get complimentary year-ahead relationship PDF
            friendInvites[index].rewardClaimed = true
        }
    }

    // MARK: - Planet Interpretation (1-4000 words)

    func interpretPlanet(_ placement: PlanetPlacement, profile: CosmicProfile) -> PlanetInterpretation {
        let planet = placement.planet
        let sign = placement.sign

        // Generate rich, personalized interpretation
        let coreInterpretation = "\(planet.displayName) \(planet.symbol) in \(sign.displayName) \(sign.symbol)"

        let personalizedBody = """
        Your \(planet.displayName) in \(sign.displayName) speaks to a fundamental dimension of who you are.

        \(planet.domain). When this energy expresses through \(sign.displayName), it takes on the qualities of \(sign.element.rawValue) — \
        \(sign.modality.rawValue) in nature, \(sign.element == .fire ? "passionate and initiating" : sign.element == .earth ? "grounded and practical" : sign.element == .air ? "intellectual and communicative" : "intuitive and emotional").

        In your \(placement.house)\(ordinalSuffix(placement.house)) house, this placement touches \(HousePlacement.houseNames[placement.house - 1]). \
        This means your \(planet.displayName.lowercased()) energy is channeled primarily through this life domain.

        \(placement.isRetrograde ? "This planet is retrograde in your chart, suggesting an internalized, reflective relationship with this energy. You may process \(planet.displayName.lowercased()) themes more deeply than most, sometimes revisiting old patterns before integrating new ones." : "This planet moves direct in your chart, indicating a natural, outward expression of this energy.")

        At \(String(format: "%.1f", placement.degree))° \(sign.displayName), you carry this energy at a \(placement.degree < 10 ? "fresh, initiating" : placement.degree < 20 ? "developed, expressive" : "mature, masterful") stage of the sign's evolution.

        How this connects to your coaching journey: In your current \(coachingPhase.displayName) phase, your \(planet.displayName.lowercased()) asks you to \(phaseSpecificPlanetAdvice(planet, phase: coachingPhase)).

        Your \(profile.ayurveda.primaryDosha.rawValue) dosha influences how you experience this placement — \
        \(profile.ayurveda.primaryDosha == .vata ? "with heightened sensitivity and creative variability" : profile.ayurveda.primaryDosha == .pitta ? "with focused intensity and transformative drive" : "with steady persistence and nurturing depth").

        Numerologically, your Life Path \(profile.numerology.lifePathNumber) adds another layer: \
        the vibration of \(profile.numerology.lifePathNumber) combined with \(planet.displayName) in \(sign.displayName) \
        creates a unique frequency in your cosmic signature that few people share.
        """

        return PlanetInterpretation(
            placement: placement,
            title: coreInterpretation,
            body: personalizedBody,
            relatedLifeWheel: lifeWheelDimension(for: planet),
            relatedLivingSystem: livingSystemLevel(for: planet),
            meditationAlignment: meditationForPlanet(planet)
        )
    }

    private func ordinalSuffix(_ n: Int) -> String {
        switch n {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    private func phaseSpecificPlanetAdvice(_ planet: CelestialBody, phase: FiveDPhase) -> String {
        switch (planet, phase) {
        case (.sun, .discover): return "explore what truly lights you up — not what you've been told should"
        case (.sun, .define): return "clarify your core identity and shed borrowed definitions"
        case (.sun, .develop): return "practice showing up as your authentic self daily"
        case (.sun, .deepen): return "own your light fully, even in rooms that feel too dim for it"
        case (.sun, .deliver): return "radiate — your presence itself has become the teaching"
        case (.moon, _): return "honor your emotional needs without apology"
        case (.venus, _): return "let yourself receive beauty and love without earning it"
        case (.mars, _): return "direct your energy with precision, not force"
        case (.jupiter, _): return "expand into the opportunities that feel aligned, not just available"
        case (.saturn, _): return "embrace the discipline that sets you free"
        default: return "integrate this energy consciously into your daily practice"
        }
    }

    private func lifeWheelDimension(for planet: CelestialBody) -> String {
        switch planet {
        case .sun: return "Personal Growth"
        case .moon: return "Health"
        case .mercury: return "Career"
        case .venus: return "Romance"
        case .mars: return "Career"
        case .jupiter: return "Spirituality"
        case .saturn: return "Finances"
        case .uranus: return "Fun & Recreation"
        case .neptune: return "Spirituality"
        case .pluto: return "Personal Growth"
        case .northNode: return "Contribution"
        }
    }

    private func livingSystemLevel(for planet: CelestialBody) -> String {
        switch planet {
        case .sun: return "Purpose Alignment"
        case .moon: return "Emotional Regulation"
        case .mercury: return "Mind-Body Coherence"
        case .venus: return "Relational Harmony"
        case .mars: return "Cellular Vitality"
        case .jupiter: return "Community Belonging"
        case .saturn: return "Societal Presence"
        case .neptune, .pluto: return "Transcendence"
        default: return "Mind-Body Coherence"
        }
    }

    private func meditationForPlanet(_ planet: CelestialBody) -> String {
        switch planet {
        case .sun: return "Solar Plexus Activation — 20min golden light visualization"
        case .moon: return "Yoga Nidra — 30min lunar cycle body scan"
        case .mercury: return "Mindful Breathing — 15min focused awareness"
        case .venus: return "Heart Opening — 25min loving-kindness with rose quartz visualization"
        case .mars: return "Dynamic Breathing — 15min Kapalabhati for channeling fire"
        case .jupiter: return "Expansion Meditation — 30min cosmic journey visualization"
        case .saturn: return "Discipline Practice — 20min structured box breathing"
        case .uranus: return "Freedom Meditation — 20min sky-gazing visualization"
        case .neptune: return "Transcendence Journey — 45min deep Yoga Nidra"
        case .pluto: return "Shadow Integration — 30min guided self-inquiry"
        case .northNode: return "Destiny Meditation — 25min North Node visualization"
        }
    }
}

// MARK: - Cosmic Meditation Sync Model
struct CosmicMeditationSync: Codable, Identifiable {
    let id: UUID
    let breathingTechnique: String
    let soundscape: String
    let visualization: String
    let duration: Int
    let binauralFrequency: Double
    let cosmicRationale: String
    let auspiciousTime: String

    init(breathingTechnique: String, soundscape: String, visualization: String, duration: Int, binauralFrequency: Double, cosmicRationale: String, auspiciousTime: String) {
        self.id = UUID()
        self.breathingTechnique = breathingTechnique
        self.soundscape = soundscape
        self.visualization = visualization
        self.duration = duration
        self.binauralFrequency = binauralFrequency
        self.cosmicRationale = cosmicRationale
        self.auspiciousTime = auspiciousTime
    }
}

// MARK: - Planet Interpretation
struct PlanetInterpretation: Identifiable {
    let id = UUID()
    let placement: PlanetPlacement
    let title: String
    let body: String
    let relatedLifeWheel: String
    let relatedLivingSystem: String
    let meditationAlignment: String
}

// MARK: - Moon Phase CaseIterable
extension DailyCosmicForecast.MoonPhase: CaseIterable {
    static var allCases: [DailyCosmicForecast.MoonPhase] = [
        .newMoon, .waxingCrescent, .firstQuarter, .waxingGibbous,
        .fullMoon, .waningGibbous, .lastQuarter, .waningCrescent
    ]
}
