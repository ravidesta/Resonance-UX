package com.luminous.cosmic.data.models

import java.time.LocalDate
import java.time.LocalTime
import java.time.temporal.ChronoUnit
import kotlin.math.*

/**
 * Simplified chart calculator for demonstration purposes.
 * Uses approximate astronomical calculations to generate a natal chart
 * that is visually representative. A production app would use Swiss Ephemeris
 * or a dedicated astrological calculation library.
 */
object ChartCalculator {

    // ─────────────────────────────────────────────
    // Public API
    // ─────────────────────────────────────────────

    fun calculateNatalChart(birthData: BirthData): NatalChart {
        val julianDay = toJulianDay(birthData.birthDate, birthData.birthTime)
        val siderealTime = calculateSiderealTime(julianDay, birthData.longitude)
        val obliquity = 23.4393 - 0.0000004 * (julianDay - 2451545.0)

        val ascendantDeg = calculateAscendant(siderealTime, birthData.latitude, obliquity)
        val midheavenDeg = calculateMidheaven(siderealTime)

        val planets = calculatePlanetPositions(julianDay, ascendantDeg)
        val houses = calculateHouses(ascendantDeg, midheavenDeg, birthData.latitude)
        val placedPlanets = assignHouses(planets, houses)
        val aspects = calculateAspects(placedPlanets)

        return NatalChart(
            birthData = birthData,
            planets = placedPlanets,
            houses = houses,
            aspects = aspects,
            ascendantDegree = ascendantDeg.toFloat(),
            midheavenDegree = midheavenDeg.toFloat()
        )
    }

    fun calculateCurrentMoonPhase(date: LocalDate = LocalDate.now()): MoonPhase {
        // Known new moon: January 6, 2000
        val knownNewMoon = LocalDate.of(2000, 1, 6)
        val daysSince = ChronoUnit.DAYS.between(knownNewMoon, date).toDouble()
        val lunarCycle = 29.53058867
        val phase = ((daysSince % lunarCycle) / lunarCycle * 8).toInt() % 8
        return MoonPhase.entries[phase]
    }

    fun calculateMoonIllumination(date: LocalDate = LocalDate.now()): Float {
        val knownNewMoon = LocalDate.of(2000, 1, 6)
        val daysSince = ChronoUnit.DAYS.between(knownNewMoon, date).toDouble()
        val lunarCycle = 29.53058867
        val phaseAngle = (daysSince % lunarCycle) / lunarCycle * 2 * PI
        return ((1 - cos(phaseAngle)) / 2).toFloat()
    }

    fun generateDailyInsight(chart: NatalChart, date: LocalDate = LocalDate.now()): DailyInsight {
        val moonPhase = calculateCurrentMoonPhase(date)
        val transits = generateTransits(chart, date)
        val dayOfYear = date.dayOfYear

        val titles = listOf(
            "Cosmic Currents", "Stellar Whispers", "Celestial Tides",
            "Astral Harmonics", "Luminous Pathways", "Ethereal Alignments"
        )
        val affirmations = listOf(
            "I am aligned with the rhythm of the cosmos.",
            "My inner light guides me through every transformation.",
            "I trust the celestial wisdom unfolding within me.",
            "Each moment is a sacred conversation with the stars.",
            "I honor my cosmic blueprint and its infinite potential.",
            "The universe conspires in favor of my highest evolution."
        )
        val focusAreas = listOf(
            "Inner reflection", "Creative expression", "Relationships",
            "Career growth", "Spiritual practice", "Physical vitality"
        )

        return DailyInsight(
            date = date,
            title = titles[dayOfYear % titles.size],
            body = generateDailyBody(chart, moonPhase, date),
            moonPhase = moonPhase,
            transits = transits,
            affirmation = affirmations[dayOfYear % affirmations.size],
            focusArea = focusAreas[dayOfYear % focusAreas.size]
        )
    }

    fun getSampleMeditations(): List<Meditation> = listOf(
        Meditation(
            id = "stargazer_1",
            title = "Stargazer's Attunement",
            subtitle = "Connect with Your Natal Sky",
            description = "A guided journey to connect with the celestial patterns " +
                "present at the moment of your birth. Feel the resonance of your " +
                "cosmic blueprint as you align with the stars.",
            durationMinutes = 15,
            category = MeditationCategory.STARGAZER,
            steps = listOf(
                MeditationStep(
                    "Grounding",
                    "Close your eyes. Feel the earth beneath you, solid and ancient. " +
                        "Imagine roots extending from your body deep into the ground.",
                    120,
                    BreathPattern(4, 4, 6)
                ),
                MeditationStep(
                    "Opening the Sky Within",
                    "Visualize the night sky above you. See the stars emerge one by one. " +
                        "Each star carries a frequency that resonates with a part of your being.",
                    180,
                    BreathPattern(4, 2, 6)
                ),
                MeditationStep(
                    "Planetary Alignment",
                    "Feel the planets in your chart activating. The Sun warms your core. " +
                        "The Moon soothes your emotions. Each planet illuminates its domain.",
                    240,
                    BreathPattern(5, 3, 7)
                ),
                MeditationStep(
                    "Integration",
                    "Allow all the celestial energies to harmonize within you. " +
                        "You are a living constellation. Carry this alignment forward.",
                    120,
                    BreathPattern(4, 4, 8)
                )
            )
        ),
        Meditation(
            id = "lunar_1",
            title = "Lunar Alignment",
            subtitle = "Harmonize with the Moon",
            description = "Attune to the current lunar phase and its influence on " +
                "your emotional landscape and intuitive wisdom.",
            durationMinutes = 10,
            category = MeditationCategory.LUNAR,
            steps = listOf(
                MeditationStep(
                    "Settling",
                    "Find stillness. Let your breath become like gentle ocean waves, " +
                        "rising and falling in rhythm with the lunar tide.",
                    90,
                    BreathPattern(4, 2, 6)
                ),
                MeditationStep(
                    "Moon Visualization",
                    "See the Moon in your mind's eye, glowing with silver-gold light. " +
                        "Feel its pull on your inner waters, on your dreams and feelings.",
                    180,
                    BreathPattern(4, 4, 6)
                ),
                MeditationStep(
                    "Emotional Release",
                    "With each exhale, release what no longer serves you into the moonlight. " +
                        "With each inhale, draw in lunar wisdom and clarity.",
                    180,
                    BreathPattern(5, 2, 8)
                ),
                MeditationStep(
                    "Closing",
                    "Thank the Moon for its guidance. Gently return to the present moment, " +
                        "carrying the Moon's serene light within your heart.",
                    60,
                    BreathPattern(4, 2, 6)
                )
            )
        ),
        Meditation(
            id = "elemental_1",
            title = "Elemental Balance",
            subtitle = "Fire, Earth, Air & Water",
            description = "Balance the four elements within your chart and your being. " +
                "Connect with the elemental forces that shape your cosmic architecture.",
            durationMinutes = 12,
            category = MeditationCategory.ELEMENTAL,
            steps = listOf(
                MeditationStep(
                    "Fire",
                    "Ignite the flame of Aries, Leo, and Sagittarius within. " +
                        "Feel courage, passion, and creative fire rising in your solar plexus.",
                    120,
                    BreathPattern(3, 2, 5)
                ),
                MeditationStep(
                    "Earth",
                    "Ground into Taurus, Virgo, and Capricorn energy. " +
                        "Feel stability, patience, and the beauty of embodied presence.",
                    120,
                    BreathPattern(5, 4, 7)
                ),
                MeditationStep(
                    "Air",
                    "Open to Gemini, Libra, and Aquarius currents. " +
                        "Feel your mind expand, ideas flowing like a fresh breeze.",
                    120,
                    BreathPattern(4, 2, 6)
                ),
                MeditationStep(
                    "Water",
                    "Dive into Cancer, Scorpio, and Pisces depths. " +
                        "Feel intuition, emotion, and spiritual connection flowing through you.",
                    120,
                    BreathPattern(5, 3, 8)
                )
            )
        )
    )

    fun getSampleChapters(): List<Chapter> = listOf(
        Chapter(
            id = "ch1",
            number = 1,
            title = "The Cosmic Blueprint",
            subtitle = "Understanding Your Natal Chart",
            description = "Discover the sacred map that was drawn at the moment of your first breath.",
            sections = listOf(
                ChapterSection(
                    "What Is a Natal Chart?",
                    "Your natal chart is a snapshot of the heavens at the exact moment you were born. " +
                        "It is not a prediction of fate but a map of potential\u2014a cosmic blueprint " +
                        "that reveals the energies, patterns, and themes woven into the fabric of your life.\n\n" +
                        "Think of it as the universe's love letter to you, written in the language of planets, " +
                        "signs, and houses. Each element speaks to a different dimension of your experience: " +
                        "your identity, your emotions, your relationships, your purpose."
                ),
                ChapterSection(
                    "The Three Pillars: Sun, Moon & Rising",
                    "The Sun sign represents your core identity\u2014the essence of who you are becoming. " +
                        "It is the light you are learning to shine.\n\n" +
                        "The Moon sign reveals your emotional nature\u2014how you feel, what you need for security, " +
                        "and the landscape of your inner world.\n\n" +
                        "The Rising sign (Ascendant) is the mask you wear and the lens through which others " +
                        "first perceive you. It colors your approach to new experiences."
                ),
                ChapterSection(
                    "Planets as Inner Voices",
                    "Each planet in your chart represents a different voice within your psyche. " +
                        "Mercury is how you think and communicate. Venus is how you love and what you value. " +
                        "Mars is how you assert yourself and pursue desires.\n\n" +
                        "The outer planets\u2014Jupiter, Saturn, Uranus, Neptune, and Pluto\u2014speak to " +
                        "generational themes and deeper evolutionary processes. They are the slow-moving " +
                        "architects of transformation."
                )
            )
        ),
        Chapter(
            id = "ch2",
            number = 2,
            title = "The Twelve Houses",
            subtitle = "Domains of Experience",
            description = "Explore the twelve houses of the zodiac wheel and the life areas they govern.",
            sections = listOf(
                ChapterSection(
                    "The Angular Houses (1, 4, 7, 10)",
                    "The angular houses are the four cardinal points of your chart. " +
                        "They represent the most active and visible areas of life:\n\n" +
                        "The 1st House (Self) is your identity and physical presence.\n" +
                        "The 4th House (Home) is your roots, family, and inner foundation.\n" +
                        "The 7th House (Partnership) is your relationships and how you meet others.\n" +
                        "The 10th House (Career) is your public role and life direction."
                ),
                ChapterSection(
                    "The Succedent Houses (2, 5, 8, 11)",
                    "These houses deal with resources, creativity, and values:\n\n" +
                        "The 2nd House governs personal values and material resources.\n" +
                        "The 5th House is the realm of creativity, romance, and joy.\n" +
                        "The 8th House explores shared resources, intimacy, and transformation.\n" +
                        "The 11th House encompasses community, friendship, and future visions."
                ),
                ChapterSection(
                    "The Cadent Houses (3, 6, 9, 12)",
                    "The cadent houses are spaces of learning, adaptation, and transcendence:\n\n" +
                        "The 3rd House is communication, learning, and immediate environment.\n" +
                        "The 6th House concerns daily routines, health, and acts of service.\n" +
                        "The 9th House opens to philosophy, higher education, and distant journeys.\n" +
                        "The 12th House is the realm of the unconscious, dreams, and spiritual dissolution."
                )
            )
        ),
        Chapter(
            id = "ch3",
            number = 3,
            title = "The Elements & Modalities",
            subtitle = "Fire, Earth, Air, Water & Beyond",
            description = "Understand the elemental and modal composition of your chart.",
            sections = listOf(
                ChapterSection(
                    "Fire Signs",
                    "Aries, Leo, and Sagittarius carry the element of Fire\u2014the spark of inspiration, " +
                        "courage, and creative will. Fire signs initiate, lead, and illuminate. " +
                        "When balanced, they bring warmth and vision. When unchecked, they can burn.",
                    ZodiacSign.ARIES
                ),
                ChapterSection(
                    "Earth Signs",
                    "Taurus, Virgo, and Capricorn embody Earth\u2014the principle of manifestation, " +
                        "structure, and sensory wisdom. Earth signs build, sustain, and ground. " +
                        "They remind us that the spiritual must be embodied to be real.",
                    ZodiacSign.TAURUS
                ),
                ChapterSection(
                    "Air Signs",
                    "Gemini, Libra, and Aquarius express Air\u2014the realm of thought, connection, " +
                        "and social exchange. Air signs analyze, relate, and innovate. " +
                        "They bridge the gap between inner vision and outer communication.",
                    ZodiacSign.GEMINI
                ),
                ChapterSection(
                    "Water Signs",
                    "Cancer, Scorpio, and Pisces flow with Water\u2014the depths of emotion, " +
                        "intuition, and psychic sensitivity. Water signs feel, transform, and heal. " +
                        "They navigate the unseen currents beneath the surface of life.",
                    ZodiacSign.CANCER
                )
            )
        ),
        Chapter(
            id = "ch4",
            number = 4,
            title = "Aspects & Cosmic Geometry",
            subtitle = "The Conversations Between Planets",
            description = "Learn how planetary aspects create the dynamic tensions and harmonies in your chart.",
            sections = listOf(
                ChapterSection(
                    "Conjunctions & Oppositions",
                    "A conjunction (0\u00B0) is a fusion of planetary energies\u2014two voices singing " +
                        "the same note, for better or worse. The blending can be powerful and focused.\n\n" +
                        "An opposition (180\u00B0) is a polarity\u2014two planets facing each other across the chart. " +
                        "It creates tension that demands integration, awareness of both sides."
                ),
                ChapterSection(
                    "Trines & Sextiles",
                    "A trine (120\u00B0) is a flowing, harmonious connection. The planets support each other " +
                        "naturally, like a river finding its course. Gifts here come easily\u2014sometimes " +
                        "so easily they are taken for granted.\n\n" +
                        "A sextile (60\u00B0) is an opportunity aspect. It offers potential but requires " +
                        "conscious effort to activate its benefits."
                ),
                ChapterSection(
                    "Squares",
                    "A square (90\u00B0) is a challenge aspect\u2014a creative friction between planets that " +
                        "demands action. Squares are not punishments; they are the growing edges of the soul. " +
                        "The greatest achievements often emerge from working with square energy."
                )
            )
        ),
        Chapter(
            id = "ch5",
            number = 5,
            title = "Transits & Evolution",
            subtitle = "The Living Sky",
            description = "Understand how current planetary movements activate your natal chart.",
            sections = listOf(
                ChapterSection(
                    "What Are Transits?",
                    "While your natal chart is fixed at the moment of birth, the planets continue to move. " +
                        "As they transit through the zodiac, they form aspects to your natal planets, " +
                        "activating different themes and potentials in your life.\n\n" +
                        "Transits are the universe's way of inviting you to grow, heal, and evolve."
                ),
                ChapterSection(
                    "Saturn Return",
                    "Around age 29 and again near 58, Saturn returns to the exact position it held " +
                        "at your birth. This is a profound rite of passage\u2014a cosmic audit of your " +
                        "structures, responsibilities, and the life you have built. It asks: " +
                        "Is this truly yours, or are you living someone else's design?"
                ),
                ChapterSection(
                    "The Outer Planet Transits",
                    "When Uranus, Neptune, or Pluto transit a sensitive point in your chart, " +
                        "the changes are often profound and long-lasting. Uranus liberates and disrupts. " +
                        "Neptune dissolves and inspires. Pluto destroys and regenerates.\n\n" +
                        "These transits are not events that happen to you\u2014they are evolutionary " +
                        "processes that happen through you."
                )
            ),
            isUnlocked = true
        )
    )

    // ─────────────────────────────────────────────
    // Private Calculations
    // ─────────────────────────────────────────────

    private fun toJulianDay(date: LocalDate, time: LocalTime): Double {
        val y = if (date.monthValue <= 2) date.year - 1 else date.year
        val m = if (date.monthValue <= 2) date.monthValue + 12 else date.monthValue
        val d = date.dayOfMonth + time.hour / 24.0 + time.minute / 1440.0

        val a = y / 100
        val b = 2 - a + a / 4
        return (365.25 * (y + 4716)).toInt() + (30.6001 * (m + 1)).toInt() + d + b - 1524.5
    }

    private fun calculateSiderealTime(jd: Double, longitude: Double): Double {
        val t = (jd - 2451545.0) / 36525.0
        var gst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) +
            0.000387933 * t * t - t * t * t / 38710000.0
        gst = ((gst % 360.0) + 360.0) % 360.0
        val lst = gst + longitude
        return ((lst % 360.0) + 360.0) % 360.0
    }

    private fun calculateAscendant(lst: Double, latitude: Double, obliquity: Double): Float {
        val lstRad = Math.toRadians(lst)
        val latRad = Math.toRadians(latitude)
        val oblRad = Math.toRadians(obliquity)

        val y = -cos(lstRad)
        val x = sin(oblRad) * tan(latRad) + cos(oblRad) * sin(lstRad)
        var asc = Math.toDegrees(atan2(y, x))
        asc = ((asc % 360.0) + 360.0) % 360.0
        return asc.toFloat()
    }

    private fun calculateMidheaven(lst: Double): Float {
        return lst.toFloat()
    }

    private fun calculatePlanetPositions(jd: Double, ascendant: Float): List<PlanetPlacement> {
        val t = (jd - 2451545.0) / 36525.0

        // Simplified mean longitude calculations
        val sunLong = normalize(280.4664567 + 360.0076983 * (jd - 2451545.0) / 365.25)
        val moonLong = normalize(218.3165 + 13.176396 * (jd - 2451545.0))
        val mercLong = normalize(sunLong + 30.0 * sin(Math.toRadians(t * 360 * 4.15)))
        val venusLong = normalize(sunLong + 46.0 * sin(Math.toRadians(t * 360 * 1.625)))
        val marsLong = normalize(355.433 + 0.5240208 * (jd - 2451545.0))
        val jupLong = normalize(34.351 + 0.0830854 * (jd - 2451545.0))
        val satLong = normalize(50.077 + 0.0334446 * (jd - 2451545.0))
        val uraLong = normalize(314.055 + 0.0117173 * (jd - 2451545.0))
        val nepLong = normalize(304.349 + 0.0059838 * (jd - 2451545.0))
        val pluLong = normalize(238.929 + 0.0039780 * (jd - 2451545.0))
        val nodeLong = normalize(125.044 - 0.0529539 * (jd - 2451545.0))
        val chironLong = normalize(209.0 + 0.0198770 * (jd - 2451545.0))

        val longitudes = mapOf(
            Planet.SUN to sunLong,
            Planet.MOON to moonLong,
            Planet.MERCURY to mercLong,
            Planet.VENUS to venusLong,
            Planet.MARS to marsLong,
            Planet.JUPITER to jupLong,
            Planet.SATURN to satLong,
            Planet.URANUS to uraLong,
            Planet.NEPTUNE to nepLong,
            Planet.PLUTO to pluLong,
            Planet.NORTH_NODE to nodeLong,
            Planet.CHIRON to chironLong
        )

        return longitudes.map { (planet, longitude) ->
            val deg = longitude.toFloat()
            PlanetPlacement(
                planet = planet,
                sign = ZodiacSign.fromDegree(deg),
                house = House.FIRST, // Placeholder, assigned later
                degree = deg,
                isRetrograde = planet in listOf(
                    Planet.MERCURY, Planet.VENUS, Planet.MARS,
                    Planet.JUPITER, Planet.SATURN
                ) && (jd.toLong() % 7 == 0L) // Simplified retrograde
            )
        }
    }

    private fun calculateHouses(ascendant: Double, midheaven: Double, latitude: Double): List<HouseCusp> {
        // Simplified equal house system from Ascendant
        return House.entries.map { house ->
            val degree = normalize(ascendant + (house.number - 1) * 30.0).toFloat()
            HouseCusp(
                house = house,
                sign = ZodiacSign.fromDegree(degree),
                degree = degree
            )
        }
    }

    private fun assignHouses(
        planets: List<PlanetPlacement>,
        houses: List<HouseCusp>
    ): List<PlanetPlacement> {
        return planets.map { planet ->
            val houseIndex = houses.indexOfLast { cusp ->
                planet.degree >= cusp.degree
            }.let { if (it == -1) 11 else it }
            planet.copy(house = House.entries[houseIndex])
        }
    }

    private fun calculateAspects(planets: List<PlanetPlacement>): List<Aspect> {
        val aspects = mutableListOf<Aspect>()
        for (i in planets.indices) {
            for (j in i + 1 until planets.size) {
                val p1 = planets[i]
                val p2 = planets[j]
                var diff = abs(p1.degree - p2.degree)
                if (diff > 180f) diff = 360f - diff

                for (type in AspectType.entries) {
                    val orb = abs(diff - type.angle)
                    if (orb <= type.orb) {
                        aspects.add(
                            Aspect(
                                planet1 = p1.planet,
                                planet2 = p2.planet,
                                type = type,
                                orb = orb,
                                isApplying = p1.degree < p2.degree
                            )
                        )
                        break
                    }
                }
            }
        }
        return aspects
    }

    private fun generateTransits(chart: NatalChart, date: LocalDate): List<Transit> {
        val currentJd = toJulianDay(date, LocalTime.NOON)
        val currentPlanets = calculatePlanetPositions(currentJd, chart.ascendantDegree)

        val transits = mutableListOf<Transit>()
        val transitPlanets = listOf(Planet.SUN, Planet.MOON, Planet.MERCURY, Planet.VENUS, Planet.MARS, Planet.JUPITER, Planet.SATURN)

        for (transitPlanet in currentPlanets.filter { it.planet in transitPlanets }) {
            for (natalPlanet in chart.planets.take(7)) {
                var diff = abs(transitPlanet.degree - natalPlanet.degree)
                if (diff > 180f) diff = 360f - diff

                for (type in listOf(AspectType.CONJUNCTION, AspectType.TRINE, AspectType.SQUARE, AspectType.OPPOSITION)) {
                    val orb = abs(diff - type.angle)
                    if (orb <= type.orb * 0.6f) {
                        transits.add(
                            Transit(
                                planet = transitPlanet.planet,
                                natalPlanet = natalPlanet.planet,
                                aspectType = type,
                                description = generateTransitDescription(
                                    transitPlanet.planet, natalPlanet.planet, type
                                ),
                                startDate = date.minusDays(3),
                                exactDate = date,
                                endDate = date.plusDays(3),
                                intensity = 1f - (orb / type.orb)
                            )
                        )
                        break
                    }
                }
            }
        }
        return transits.sortedByDescending { it.intensity }.take(5)
    }

    private fun generateTransitDescription(
        transit: Planet, natal: Planet, aspect: AspectType
    ): String {
        val nature = when (aspect.nature) {
            AspectNature.HARMONIOUS -> "harmoniously activates"
            AspectNature.CHALLENGING -> "brings creative tension to"
            AspectNature.MAJOR -> "powerfully aligns with"
            AspectNature.MINOR -> "subtly influences"
        }
        return "Transiting ${transit.symbol} $nature your natal ${natal.symbol}, " +
            "inviting you to explore the relationship between ${transit.symbol.lowercase()} " +
            "energy and your ${natal.symbol.lowercase()} expression."
    }

    private fun generateDailyBody(
        chart: NatalChart, moonPhase: MoonPhase, date: LocalDate
    ): String {
        val sunSign = chart.sunSign
        val moonSign = chart.moonSign
        return "With the ${moonPhase.displayName} illuminating the sky, today invites " +
            "${sunSign.symbol} Suns to attune to their inner rhythm. " +
            "Your ${moonSign.symbol} Moon craves emotional nourishment through " +
            "${moonSign.element.displayName.lowercase()} activities. " +
            "Pay attention to the subtle shifts in energy as the cosmic architecture " +
            "of this day unfolds its unique pattern for you."
    }

    private fun normalize(degrees: Double): Double = ((degrees % 360.0) + 360.0) % 360.0
}
