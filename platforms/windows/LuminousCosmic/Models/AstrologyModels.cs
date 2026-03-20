namespace LuminousCosmic.Models;

// ═══════════════════════════════════════════════════════════════
// ENUMERATIONS
// ═══════════════════════════════════════════════════════════════

public enum ZodiacSign
{
    Aries, Taurus, Gemini, Cancer, Leo, Virgo,
    Libra, Scorpio, Sagittarius, Capricorn, Aquarius, Pisces
}

public enum Planet
{
    Sun, Moon, Mercury, Venus, Mars,
    Jupiter, Saturn, Uranus, Neptune, Pluto,
    NorthNode, SouthNode, Chiron, Ascendant, Midheaven
}

public enum HouseSystem
{
    Placidus, Koch, WholeSign, EqualHouse, Campanus, Regiomontanus
}

public enum AspectType
{
    Conjunction,    // 0 degrees
    Sextile,        // 60 degrees
    Square,         // 90 degrees
    Trine,          // 120 degrees
    Opposition,     // 180 degrees
    Quincunx,       // 150 degrees
    SemiSextile,    // 30 degrees
    SemiSquare,     // 45 degrees
    Sesquiquadrate, // 135 degrees
    Quintile        // 72 degrees
}

public enum Element
{
    Fire, Earth, Air, Water
}

public enum Modality
{
    Cardinal, Fixed, Mutable
}

public enum MoonPhase
{
    NewMoon, WaxingCrescent, FirstQuarter, WaxingGibbous,
    FullMoon, WaningGibbous, LastQuarter, WaningCrescent
}

public enum TransitType
{
    Conjunction, Opposition, Square, Trine, Sextile
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════

/// <summary>
/// Represents a planetary placement in the natal chart.
/// </summary>
public sealed class PlanetPlacement
{
    public Planet Planet { get; set; }
    public ZodiacSign Sign { get; set; }
    public int House { get; set; }
    public double Degrees { get; set; }        // 0-359.99 absolute ecliptic longitude
    public double SignDegrees { get; set; }     // 0-29.99 within sign
    public bool IsRetrograde { get; set; }

    public string DegreeDisplay =>
        $"{(int)SignDegrees}\u00b0{(int)((SignDegrees % 1) * 60)}' {Sign}";

    public string Glyph => GetPlanetGlyph(Planet);

    public static string GetPlanetGlyph(Planet planet) => planet switch
    {
        Planet.Sun => "\u2609",
        Planet.Moon => "\u263D",
        Planet.Mercury => "\u263F",
        Planet.Venus => "\u2640",
        Planet.Mars => "\u2642",
        Planet.Jupiter => "\u2643",
        Planet.Saturn => "\u2644",
        Planet.Uranus => "\u2645",
        Planet.Neptune => "\u2646",
        Planet.Pluto => "\u2647",
        Planet.NorthNode => "\u260A",
        Planet.SouthNode => "\u260B",
        Planet.Chiron => "\u26B7",
        Planet.Ascendant => "AC",
        Planet.Midheaven => "MC",
        _ => "?"
    };
}

/// <summary>
/// Represents an aspect (angular relationship) between two planets.
/// </summary>
public sealed class Aspect
{
    public Planet Planet1 { get; set; }
    public Planet Planet2 { get; set; }
    public AspectType Type { get; set; }
    public double Orb { get; set; }            // Deviation from exact aspect
    public bool IsApplying { get; set; }

    public string Description => $"{Planet1} {TypeSymbol} {Planet2} ({Orb:F1}\u00b0)";

    public string TypeSymbol => Type switch
    {
        AspectType.Conjunction => "\u260C",
        AspectType.Sextile => "\u26B9",
        AspectType.Square => "\u25A1",
        AspectType.Trine => "\u25B3",
        AspectType.Opposition => "\u260D",
        AspectType.Quincunx => "Qx",
        _ => "\u2022"
    };
}

/// <summary>
/// Represents a house cusp in the natal chart.
/// </summary>
public sealed class HouseCusp
{
    public int HouseNumber { get; set; }       // 1-12
    public ZodiacSign Sign { get; set; }
    public double Degrees { get; set; }        // Absolute ecliptic longitude
    public double SignDegrees { get; set; }

    public string Label => HouseNumber switch
    {
        1 => "I - Self",
        2 => "II - Resources",
        3 => "III - Communication",
        4 => "IV - Home",
        5 => "V - Creativity",
        6 => "VI - Service",
        7 => "VII - Partnership",
        8 => "VIII - Transformation",
        9 => "IX - Philosophy",
        10 => "X - Career",
        11 => "XI - Community",
        12 => "XII - Transcendence",
        _ => $"House {HouseNumber}"
    };
}

/// <summary>
/// Birth data required to calculate a natal chart.
/// </summary>
public sealed class BirthData
{
    public string Name { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; } = DateTime.Now;
    public TimeSpan BirthTime { get; set; } = TimeSpan.Zero;
    public string BirthCity { get; set; } = string.Empty;
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double TimezoneOffset { get; set; }

    public DateTime BirthDateTime => BirthDate.Date + BirthTime;
}

/// <summary>
/// A complete natal chart with all calculated positions.
/// </summary>
public sealed class NatalChart
{
    public BirthData BirthData { get; set; } = new();
    public List<PlanetPlacement> Planets { get; set; } = new();
    public List<HouseCusp> Houses { get; set; } = new();
    public List<Aspect> Aspects { get; set; } = new();
    public HouseSystem HouseSystem { get; set; } = HouseSystem.Placidus;

    public PlanetPlacement? SunSign => Planets.FirstOrDefault(p => p.Planet == Planet.Sun);
    public PlanetPlacement? MoonSign => Planets.FirstOrDefault(p => p.Planet == Planet.Moon);
    public PlanetPlacement? Rising => Planets.FirstOrDefault(p => p.Planet == Planet.Ascendant);

    public Element DominantElement
    {
        get
        {
            var counts = Planets
                .Where(p => p.Planet != Planet.Ascendant && p.Planet != Planet.Midheaven)
                .GroupBy(p => GetElement(p.Sign))
                .OrderByDescending(g => g.Count())
                .FirstOrDefault();
            return counts?.Key ?? Element.Earth;
        }
    }

    public static Element GetElement(ZodiacSign sign) => sign switch
    {
        ZodiacSign.Aries or ZodiacSign.Leo or ZodiacSign.Sagittarius => Element.Fire,
        ZodiacSign.Taurus or ZodiacSign.Virgo or ZodiacSign.Capricorn => Element.Earth,
        ZodiacSign.Gemini or ZodiacSign.Libra or ZodiacSign.Aquarius => Element.Air,
        ZodiacSign.Cancer or ZodiacSign.Scorpio or ZodiacSign.Pisces => Element.Water,
        _ => Element.Earth
    };

    public static Modality GetModality(ZodiacSign sign) => sign switch
    {
        ZodiacSign.Aries or ZodiacSign.Cancer or ZodiacSign.Libra or ZodiacSign.Capricorn => Modality.Cardinal,
        ZodiacSign.Taurus or ZodiacSign.Leo or ZodiacSign.Scorpio or ZodiacSign.Aquarius => Modality.Fixed,
        ZodiacSign.Gemini or ZodiacSign.Virgo or ZodiacSign.Sagittarius or ZodiacSign.Pisces => Modality.Mutable,
        _ => Modality.Cardinal
    };
}

/// <summary>
/// Represents a current planetary transit affecting the natal chart.
/// </summary>
public sealed class Transit
{
    public Planet TransitingPlanet { get; set; }
    public Planet NatalPlanet { get; set; }
    public TransitType Type { get; set; }
    public ZodiacSign TransitSign { get; set; }
    public double TransitDegrees { get; set; }
    public DateTime ExactDate { get; set; }
    public bool IsActive { get; set; }
    public string Interpretation { get; set; } = string.Empty;
    public string Theme { get; set; } = string.Empty;

    public string Summary =>
        $"{PlanetPlacement.GetPlanetGlyph(TransitingPlanet)} {TransitingPlanet} " +
        $"{Type} natal {PlanetPlacement.GetPlanetGlyph(NatalPlanet)} {NatalPlanet}";
}

/// <summary>
/// Moon phase information for a given date.
/// </summary>
public sealed class MoonPhaseInfo
{
    public MoonPhase Phase { get; set; }
    public ZodiacSign MoonSign { get; set; }
    public double Illumination { get; set; }     // 0.0 - 1.0
    public DateTime NextPhaseDate { get; set; }

    public string PhaseName => Phase switch
    {
        MoonPhase.NewMoon => "New Moon",
        MoonPhase.WaxingCrescent => "Waxing Crescent",
        MoonPhase.FirstQuarter => "First Quarter",
        MoonPhase.WaxingGibbous => "Waxing Gibbous",
        MoonPhase.FullMoon => "Full Moon",
        MoonPhase.WaningGibbous => "Waning Gibbous",
        MoonPhase.LastQuarter => "Last Quarter",
        MoonPhase.WaningCrescent => "Waning Crescent",
        _ => "Unknown"
    };

    public string PhaseEmoji => Phase switch
    {
        MoonPhase.NewMoon => "\U0001F311",
        MoonPhase.WaxingCrescent => "\U0001F312",
        MoonPhase.FirstQuarter => "\U0001F313",
        MoonPhase.WaxingGibbous => "\U0001F314",
        MoonPhase.FullMoon => "\U0001F315",
        MoonPhase.WaningGibbous => "\U0001F316",
        MoonPhase.LastQuarter => "\U0001F317",
        MoonPhase.WaningCrescent => "\U0001F318",
        _ => "\U0001F311"
    };

    public string Guidance => Phase switch
    {
        MoonPhase.NewMoon => "Set intentions. Plant seeds of new beginnings.",
        MoonPhase.WaxingCrescent => "Take the first steps. Build momentum.",
        MoonPhase.FirstQuarter => "Take decisive action. Overcome obstacles.",
        MoonPhase.WaxingGibbous => "Refine your approach. Trust the process.",
        MoonPhase.FullMoon => "Celebrate culmination. Release what no longer serves.",
        MoonPhase.WaningGibbous => "Share wisdom. Express gratitude.",
        MoonPhase.LastQuarter => "Let go. Forgive. Make space for the new.",
        MoonPhase.WaningCrescent => "Rest. Reflect. Surrender to stillness.",
        _ => "Observe the cosmic rhythm."
    };
}

/// <summary>
/// Daily reflection / journal entry.
/// </summary>
public sealed class ReflectionEntry
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime Date { get; set; } = DateTime.Today;
    public string Prompt { get; set; } = string.Empty;
    public string Response { get; set; } = string.Empty;
    public MoonPhase MoonPhase { get; set; }
    public ZodiacSign MoonSign { get; set; }
    public List<string> Tags { get; set; } = new();
    public int MoodRating { get; set; }           // 1-5
}

/// <summary>
/// A chapter in the cosmic architecture library.
/// </summary>
public sealed class CosmicChapter
{
    public int Number { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Subtitle { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public ZodiacSign? AssociatedSign { get; set; }
    public Planet? AssociatedPlanet { get; set; }
    public bool IsUnlocked { get; set; } = true;
    public double ReadingProgress { get; set; }   // 0.0 - 1.0
}

/// <summary>
/// Guided meditation session data.
/// </summary>
public sealed class MeditationSession
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public TimeSpan Duration { get; set; }
    public string Theme { get; set; } = string.Empty;
    public ZodiacSign? AssociatedSign { get; set; }
    public Planet? AssociatedPlanet { get; set; }
    public List<string> Prompts { get; set; } = new();
}

/// <summary>
/// Static zodiac sign metadata.
/// </summary>
public static class ZodiacMetadata
{
    public static string GetGlyph(ZodiacSign sign) => sign switch
    {
        ZodiacSign.Aries => "\u2648",
        ZodiacSign.Taurus => "\u2649",
        ZodiacSign.Gemini => "\u264A",
        ZodiacSign.Cancer => "\u264B",
        ZodiacSign.Leo => "\u264C",
        ZodiacSign.Virgo => "\u264D",
        ZodiacSign.Libra => "\u264E",
        ZodiacSign.Scorpio => "\u264F",
        ZodiacSign.Sagittarius => "\u2650",
        ZodiacSign.Capricorn => "\u2651",
        ZodiacSign.Aquarius => "\u2652",
        ZodiacSign.Pisces => "\u2653",
        _ => "?"
    };

    public static string GetRuler(ZodiacSign sign) => sign switch
    {
        ZodiacSign.Aries => "Mars",
        ZodiacSign.Taurus => "Venus",
        ZodiacSign.Gemini => "Mercury",
        ZodiacSign.Cancer => "Moon",
        ZodiacSign.Leo => "Sun",
        ZodiacSign.Virgo => "Mercury",
        ZodiacSign.Libra => "Venus",
        ZodiacSign.Scorpio => "Pluto",
        ZodiacSign.Sagittarius => "Jupiter",
        ZodiacSign.Capricorn => "Saturn",
        ZodiacSign.Aquarius => "Uranus",
        ZodiacSign.Pisces => "Neptune",
        _ => "Unknown"
    };

    public static string GetDateRange(ZodiacSign sign) => sign switch
    {
        ZodiacSign.Aries => "Mar 21 - Apr 19",
        ZodiacSign.Taurus => "Apr 20 - May 20",
        ZodiacSign.Gemini => "May 21 - Jun 20",
        ZodiacSign.Cancer => "Jun 21 - Jul 22",
        ZodiacSign.Leo => "Jul 23 - Aug 22",
        ZodiacSign.Virgo => "Aug 23 - Sep 22",
        ZodiacSign.Libra => "Sep 23 - Oct 22",
        ZodiacSign.Scorpio => "Oct 23 - Nov 21",
        ZodiacSign.Sagittarius => "Nov 22 - Dec 21",
        ZodiacSign.Capricorn => "Dec 22 - Jan 19",
        ZodiacSign.Aquarius => "Jan 20 - Feb 18",
        ZodiacSign.Pisces => "Feb 19 - Mar 20",
        _ => ""
    };
}
