package com.luminous.cosmic.data.models

import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime

// ─────────────────────────────────────────────
// Zodiac & Celestial Enumerations
// ─────────────────────────────────────────────

enum class ZodiacSign(
    val symbol: String,
    val unicode: String,
    val element: Element,
    val modality: Modality,
    val rulingPlanet: Planet,
    val degreesStart: Float
) {
    ARIES("Aries", "\u2648", Element.FIRE, Modality.CARDINAL, Planet.MARS, 0f),
    TAURUS("Taurus", "\u2649", Element.EARTH, Modality.FIXED, Planet.VENUS, 30f),
    GEMINI("Gemini", "\u264A", Element.AIR, Modality.MUTABLE, Planet.MERCURY, 60f),
    CANCER("Cancer", "\u264B", Element.WATER, Modality.CARDINAL, Planet.MOON, 90f),
    LEO("Leo", "\u264C", Element.FIRE, Modality.FIXED, Planet.SUN, 120f),
    VIRGO("Virgo", "\u264D", Element.EARTH, Modality.MUTABLE, Planet.MERCURY, 150f),
    LIBRA("Libra", "\u264E", Element.AIR, Modality.CARDINAL, Planet.VENUS, 180f),
    SCORPIO("Scorpio", "\u264F", Element.WATER, Modality.FIXED, Planet.PLUTO, 210f),
    SAGITTARIUS("Sagittarius", "\u2650", Element.FIRE, Modality.MUTABLE, Planet.JUPITER, 240f),
    CAPRICORN("Capricorn", "\u2651", Element.EARTH, Modality.CARDINAL, Planet.SATURN, 270f),
    AQUARIUS("Aquarius", "\u2652", Element.AIR, Modality.FIXED, Planet.URANUS, 300f),
    PISCES("Pisces", "\u2653", Element.WATER, Modality.MUTABLE, Planet.NEPTUNE, 330f);

    companion object {
        fun fromDegree(degree: Float): ZodiacSign {
            val normalized = ((degree % 360f) + 360f) % 360f
            return entries.lastOrNull { normalized >= it.degreesStart } ?: ARIES
        }
    }
}

enum class Element(val displayName: String) {
    FIRE("Fire"), EARTH("Earth"), AIR("Air"), WATER("Water")
}

enum class Modality(val displayName: String) {
    CARDINAL("Cardinal"), FIXED("Fixed"), MUTABLE("Mutable")
}

enum class Planet(
    val symbol: String,
    val unicode: String,
    val orbDefault: Float
) {
    SUN("Sun", "\u2609", 10f),
    MOON("Moon", "\u263D", 10f),
    MERCURY("Mercury", "\u263F", 7f),
    VENUS("Venus", "\u2640", 7f),
    MARS("Mars", "\u2642", 7f),
    JUPITER("Jupiter", "\u2643", 9f),
    SATURN("Saturn", "\u2644", 9f),
    URANUS("Uranus", "\u2645", 5f),
    NEPTUNE("Neptune", "\u2646", 5f),
    PLUTO("Pluto", "\u2647", 5f),
    NORTH_NODE("North Node", "\u260A", 5f),
    CHIRON("Chiron", "\u26B7", 3f);
}

enum class House(val number: Int, val description: String) {
    FIRST(1, "Self & Identity"),
    SECOND(2, "Values & Possessions"),
    THIRD(3, "Communication & Siblings"),
    FOURTH(4, "Home & Roots"),
    FIFTH(5, "Creativity & Romance"),
    SIXTH(6, "Health & Service"),
    SEVENTH(7, "Partnerships"),
    EIGHTH(8, "Transformation & Shared Resources"),
    NINTH(9, "Philosophy & Travel"),
    TENTH(10, "Career & Public Image"),
    ELEVENTH(11, "Community & Aspirations"),
    TWELFTH(12, "Unconscious & Spirituality")
}

enum class AspectType(
    val symbol: String,
    val angle: Float,
    val orb: Float,
    val nature: AspectNature
) {
    CONJUNCTION("\u260C", 0f, 8f, AspectNature.MAJOR),
    SEXTILE("\u26B9", 60f, 4f, AspectNature.HARMONIOUS),
    SQUARE("\u25A1", 90f, 7f, AspectNature.CHALLENGING),
    TRINE("\u25B3", 120f, 7f, AspectNature.HARMONIOUS),
    OPPOSITION("\u260D", 180f, 8f, AspectNature.CHALLENGING),
    QUINCUNX("Qx", 150f, 3f, AspectNature.MINOR),
    SEMISEXTILE("SSx", 30f, 2f, AspectNature.MINOR);
}

enum class AspectNature {
    MAJOR, HARMONIOUS, CHALLENGING, MINOR
}

enum class MoonPhase(val displayName: String, val emoji: String) {
    NEW_MOON("New Moon", "\uD83C\uDF11"),
    WAXING_CRESCENT("Waxing Crescent", "\uD83C\uDF12"),
    FIRST_QUARTER("First Quarter", "\uD83C\uDF13"),
    WAXING_GIBBOUS("Waxing Gibbous", "\uD83C\uDF14"),
    FULL_MOON("Full Moon", "\uD83C\uDF15"),
    WANING_GIBBOUS("Waning Gibbous", "\uD83C\uDF16"),
    LAST_QUARTER("Last Quarter", "\uD83C\uDF17"),
    WANING_CRESCENT("Waning Crescent", "\uD83C\uDF18")
}

// ─────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────

data class BirthData(
    val name: String = "",
    val birthDate: LocalDate = LocalDate.of(1990, 1, 1),
    val birthTime: LocalTime = LocalTime.NOON,
    val birthPlace: String = "",
    val latitude: Double = 0.0,
    val longitude: Double = 0.0,
    val timeZoneOffset: Int = 0
)

data class PlanetPlacement(
    val planet: Planet,
    val sign: ZodiacSign,
    val house: House,
    val degree: Float,
    val isRetrograde: Boolean = false
) {
    val formattedDegree: String
        get() {
            val signDegree = degree % 30f
            val deg = signDegree.toInt()
            val min = ((signDegree - deg) * 60).toInt()
            return "${sign.symbol} $deg\u00B0$min'"
        }
}

data class HouseCusp(
    val house: House,
    val sign: ZodiacSign,
    val degree: Float
)

data class Aspect(
    val planet1: Planet,
    val planet2: Planet,
    val type: AspectType,
    val orb: Float,
    val isApplying: Boolean = false
)

data class NatalChart(
    val birthData: BirthData,
    val planets: List<PlanetPlacement>,
    val houses: List<HouseCusp>,
    val aspects: List<Aspect>,
    val ascendantDegree: Float,
    val midheavenDegree: Float
) {
    val sunSign: ZodiacSign
        get() = planets.first { it.planet == Planet.SUN }.sign
    val moonSign: ZodiacSign
        get() = planets.first { it.planet == Planet.MOON }.sign
    val risingSign: ZodiacSign
        get() = ZodiacSign.fromDegree(ascendantDegree)
}

data class Transit(
    val planet: Planet,
    val natalPlanet: Planet,
    val aspectType: AspectType,
    val description: String,
    val startDate: LocalDate,
    val exactDate: LocalDate,
    val endDate: LocalDate,
    val intensity: Float = 0.5f
)

data class DailyInsight(
    val date: LocalDate,
    val title: String,
    val body: String,
    val moonPhase: MoonPhase,
    val transits: List<Transit>,
    val affirmation: String,
    val focusArea: String
)

data class JournalEntry(
    val id: String = java.util.UUID.randomUUID().toString(),
    val date: LocalDateTime = LocalDateTime.now(),
    val prompt: String = "",
    val content: String = "",
    val mood: String = "",
    val tags: List<String> = emptyList()
)

data class Meditation(
    val id: String,
    val title: String,
    val subtitle: String,
    val description: String,
    val durationMinutes: Int,
    val category: MeditationCategory,
    val steps: List<MeditationStep>
)

data class MeditationStep(
    val title: String,
    val instruction: String,
    val durationSeconds: Int,
    val breathPattern: BreathPattern? = null
)

data class BreathPattern(
    val inhaleSeconds: Int,
    val holdSeconds: Int,
    val exhaleSeconds: Int
)

enum class MeditationCategory(val displayName: String) {
    STARGAZER("Stargazer's Attunement"),
    LUNAR("Lunar Alignment"),
    ELEMENTAL("Elemental Balance"),
    PLANETARY("Planetary Meditation")
}

data class Chapter(
    val id: String,
    val number: Int,
    val title: String,
    val subtitle: String,
    val description: String,
    val sections: List<ChapterSection>,
    val isUnlocked: Boolean = true
)

data class ChapterSection(
    val title: String,
    val content: String,
    val relatedSign: ZodiacSign? = null
)

// ─────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────

sealed class Screen(val route: String) {
    object Onboarding : Screen("onboarding")
    object Dashboard : Screen("dashboard")
    object NatalChart : Screen("natal_chart")
    object DailyReflection : Screen("daily_reflection")
    object Meditation : Screen("meditation")
    object ChapterLibrary : Screen("chapter_library")
}
