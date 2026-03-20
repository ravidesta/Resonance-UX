namespace LuminousCosmic.Models;

/// <summary>
/// Calculates natal chart positions using simplified astronomical algorithms.
///
/// NOTE: This is a demonstration calculator using approximations.
/// For production use, integrate Swiss Ephemeris or a professional
/// astronomical library for precise planetary positions.
/// </summary>
public static class ChartCalculator
{
    private static readonly Random _rng = new();

    // Approximate mean orbital periods in days (for simplified calculation)
    private static readonly Dictionary<Planet, double> OrbitalPeriods = new()
    {
        { Planet.Sun, 365.25 },
        { Planet.Moon, 27.32 },
        { Planet.Mercury, 87.97 },
        { Planet.Venus, 224.70 },
        { Planet.Mars, 686.97 },
        { Planet.Jupiter, 4332.59 },
        { Planet.Saturn, 10759.22 },
        { Planet.Uranus, 30688.50 },
        { Planet.Neptune, 60182.00 },
        { Planet.Pluto, 90560.00 },
    };

    // Approximate ecliptic longitude at J2000.0 epoch (Jan 1, 2000 12:00 TT)
    private static readonly Dictionary<Planet, double> J2000Positions = new()
    {
        { Planet.Sun, 280.46 },
        { Planet.Moon, 218.32 },
        { Planet.Mercury, 252.25 },
        { Planet.Venus, 181.98 },
        { Planet.Mars, 355.43 },
        { Planet.Jupiter, 34.35 },
        { Planet.Saturn, 49.94 },
        { Planet.Uranus, 313.23 },
        { Planet.Neptune, 304.88 },
        { Planet.Pluto, 238.93 },
    };

    /// <summary>
    /// Calculates a natal chart from birth data.
    /// </summary>
    public static NatalChart CalculateChart(BirthData birthData)
    {
        var chart = new NatalChart
        {
            BirthData = birthData,
            HouseSystem = HouseSystem.Placidus
        };

        // Calculate Julian Day Number
        double jd = ToJulianDay(birthData.BirthDateTime, birthData.TimezoneOffset);

        // Days since J2000.0 epoch
        double daysSinceEpoch = jd - 2451545.0;

        // Calculate planetary positions
        chart.Planets = CalculatePlanetPositions(daysSinceEpoch, birthData);

        // Calculate house cusps
        chart.Houses = CalculateHouseCusps(daysSinceEpoch, birthData.Latitude, birthData.Longitude);

        // Assign houses to planets
        AssignHouses(chart);

        // Calculate aspects between planets
        chart.Aspects = CalculateAspects(chart.Planets);

        return chart;
    }

    /// <summary>
    /// Calculates approximate planetary positions.
    /// </summary>
    private static List<PlanetPlacement> CalculatePlanetPositions(double daysSinceEpoch, BirthData birthData)
    {
        var placements = new List<PlanetPlacement>();

        foreach (var (planet, basePosition) in J2000Positions)
        {
            double period = OrbitalPeriods[planet];
            double dailyMotion = 360.0 / period;
            double longitude = NormalizeDegrees(basePosition + dailyMotion * daysSinceEpoch);

            // Add perturbation for realism (simplified)
            longitude = ApplyPerturbation(planet, longitude, daysSinceEpoch);

            var sign = GetSignFromLongitude(longitude);
            double signDegrees = longitude % 30.0;

            placements.Add(new PlanetPlacement
            {
                Planet = planet,
                Sign = sign,
                Degrees = longitude,
                SignDegrees = signDegrees,
                IsRetrograde = IsRetrograde(planet, daysSinceEpoch)
            });
        }

        // Add Ascendant based on birth time and location
        double ascDegrees = CalculateAscendant(daysSinceEpoch, birthData.Latitude, birthData.Longitude);
        placements.Add(new PlanetPlacement
        {
            Planet = Planet.Ascendant,
            Sign = GetSignFromLongitude(ascDegrees),
            Degrees = ascDegrees,
            SignDegrees = ascDegrees % 30.0,
            IsRetrograde = false
        });

        // Midheaven is approximately 90 degrees before Ascendant
        double mcDegrees = NormalizeDegrees(ascDegrees - 90);
        placements.Add(new PlanetPlacement
        {
            Planet = Planet.Midheaven,
            Sign = GetSignFromLongitude(mcDegrees),
            Degrees = mcDegrees,
            SignDegrees = mcDegrees % 30.0,
            IsRetrograde = false
        });

        // North Node (approximate mean node)
        double nodePeriod = 6793.5; // days
        double nodeLongitude = NormalizeDegrees(125.04 - (360.0 / nodePeriod) * daysSinceEpoch);
        placements.Add(new PlanetPlacement
        {
            Planet = Planet.NorthNode,
            Sign = GetSignFromLongitude(nodeLongitude),
            Degrees = nodeLongitude,
            SignDegrees = nodeLongitude % 30.0,
            IsRetrograde = true
        });

        // Chiron (approximate)
        double chironPeriod = 18500.0;
        double chironLong = NormalizeDegrees(209.0 + (360.0 / chironPeriod) * daysSinceEpoch);
        placements.Add(new PlanetPlacement
        {
            Planet = Planet.Chiron,
            Sign = GetSignFromLongitude(chironLong),
            Degrees = chironLong,
            SignDegrees = chironLong % 30.0,
            IsRetrograde = false
        });

        return placements;
    }

    /// <summary>
    /// Applies simplified perturbation corrections.
    /// </summary>
    private static double ApplyPerturbation(Planet planet, double longitude, double daysSinceEpoch)
    {
        double t = daysSinceEpoch / 36525.0; // Julian centuries

        return planet switch
        {
            // Sun: equation of center
            Planet.Sun => longitude +
                1.9146 * Math.Sin(ToRadians(357.5291 + 35999.0503 * t)) +
                0.0200 * Math.Sin(ToRadians(2 * (357.5291 + 35999.0503 * t))),

            // Moon: major perturbation terms
            Planet.Moon => longitude +
                6.289 * Math.Sin(ToRadians(134.963 + 477198.868 * t)) +
                1.274 * Math.Sin(ToRadians(259.183 - 413335.36 * t)),

            // Mercury: equation of center
            Planet.Mercury => longitude +
                23.44 * Math.Sin(ToRadians(174.795 + 4.09233 * daysSinceEpoch)),

            // Venus
            Planet.Venus => longitude +
                0.7758 * Math.Sin(ToRadians(50.4161 + 1.60213 * daysSinceEpoch)),

            // Mars
            Planet.Mars => longitude +
                10.691 * Math.Sin(ToRadians(19.3730 + 0.52403 * daysSinceEpoch)),

            // Outer planets: smaller perturbations
            Planet.Jupiter => longitude +
                5.555 * Math.Sin(ToRadians(225.0 + 0.08309 * daysSinceEpoch)),

            Planet.Saturn => longitude +
                6.40 * Math.Sin(ToRadians(317.0 + 0.03346 * daysSinceEpoch)),

            _ => longitude
        };
    }

    /// <summary>
    /// Determines if a planet appears to be retrograde (simplified).
    /// </summary>
    private static bool IsRetrograde(Planet planet, double daysSinceEpoch)
    {
        if (planet == Planet.Sun || planet == Planet.Moon) return false;

        // Simplified retrograde detection using synodic period
        double synodicPeriod = planet switch
        {
            Planet.Mercury => 115.88,
            Planet.Venus => 583.9,
            Planet.Mars => 779.94,
            Planet.Jupiter => 398.88,
            Planet.Saturn => 378.09,
            Planet.Uranus => 369.66,
            Planet.Neptune => 367.49,
            Planet.Pluto => 366.72,
            _ => 400.0
        };

        double retroFraction = planet switch
        {
            Planet.Mercury => 0.19,
            Planet.Venus => 0.07,
            Planet.Mars => 0.09,
            _ => 0.12
        };

        double phase = (daysSinceEpoch % synodicPeriod) / synodicPeriod;
        return phase < retroFraction;
    }

    /// <summary>
    /// Calculates the Ascendant degree (simplified).
    /// </summary>
    private static double CalculateAscendant(double daysSinceEpoch, double latitude, double longitude)
    {
        // Local Sidereal Time approximation
        double gmst = NormalizeDegrees(280.46061837 + 360.98564736629 * daysSinceEpoch);
        double lst = NormalizeDegrees(gmst + longitude);

        // Obliquity of the ecliptic
        double obliquity = 23.4393 - 0.0000004 * daysSinceEpoch;
        double oblRad = ToRadians(obliquity);
        double latRad = ToRadians(latitude);
        double lstRad = ToRadians(lst);

        // Ascendant formula
        double y = -Math.Cos(lstRad);
        double x = Math.Sin(oblRad) * Math.Tan(latRad) + Math.Cos(oblRad) * Math.Sin(lstRad);
        double ascendant = NormalizeDegrees(ToDegrees(Math.Atan2(y, x)));

        return ascendant;
    }

    /// <summary>
    /// Calculates house cusps using simplified Placidus-like system.
    /// </summary>
    private static List<HouseCusp> CalculateHouseCusps(double daysSinceEpoch, double latitude, double longitude)
    {
        double ascDegrees = CalculateAscendant(daysSinceEpoch, latitude, longitude);
        var cusps = new List<HouseCusp>();

        for (int i = 1; i <= 12; i++)
        {
            // Simplified: equal house system offset from Ascendant
            double cuspDegree = NormalizeDegrees(ascDegrees + (i - 1) * 30.0);

            cusps.Add(new HouseCusp
            {
                HouseNumber = i,
                Sign = GetSignFromLongitude(cuspDegree),
                Degrees = cuspDegree,
                SignDegrees = cuspDegree % 30.0
            });
        }

        return cusps;
    }

    /// <summary>
    /// Assigns house numbers to planet placements based on house cusps.
    /// </summary>
    private static void AssignHouses(NatalChart chart)
    {
        foreach (var planet in chart.Planets)
        {
            planet.House = 1;
            for (int i = 0; i < chart.Houses.Count; i++)
            {
                int next = (i + 1) % 12;
                double start = chart.Houses[i].Degrees;
                double end = chart.Houses[next].Degrees;

                bool inHouse;
                if (start < end)
                    inHouse = planet.Degrees >= start && planet.Degrees < end;
                else
                    inHouse = planet.Degrees >= start || planet.Degrees < end;

                if (inHouse)
                {
                    planet.House = chart.Houses[i].HouseNumber;
                    break;
                }
            }
        }
    }

    /// <summary>
    /// Calculates aspects between all planet pairs.
    /// </summary>
    public static List<Aspect> CalculateAspects(List<PlanetPlacement> planets)
    {
        var aspects = new List<Aspect>();
        var majorPlanets = planets.Where(p =>
            p.Planet != Planet.Ascendant &&
            p.Planet != Planet.Midheaven &&
            p.Planet != Planet.SouthNode).ToList();

        var aspectAngles = new (AspectType type, double angle, double orb)[]
        {
            (AspectType.Conjunction, 0, 8),
            (AspectType.Sextile, 60, 6),
            (AspectType.Square, 90, 7),
            (AspectType.Trine, 120, 8),
            (AspectType.Opposition, 180, 8),
            (AspectType.Quincunx, 150, 3),
        };

        for (int i = 0; i < majorPlanets.Count; i++)
        {
            for (int j = i + 1; j < majorPlanets.Count; j++)
            {
                double diff = Math.Abs(majorPlanets[i].Degrees - majorPlanets[j].Degrees);
                if (diff > 180) diff = 360 - diff;

                foreach (var (type, angle, maxOrb) in aspectAngles)
                {
                    double orb = Math.Abs(diff - angle);
                    if (orb <= maxOrb)
                    {
                        aspects.Add(new Aspect
                        {
                            Planet1 = majorPlanets[i].Planet,
                            Planet2 = majorPlanets[j].Planet,
                            Type = type,
                            Orb = Math.Round(orb, 2),
                            IsApplying = majorPlanets[i].Degrees < majorPlanets[j].Degrees
                        });
                        break; // Only one aspect per pair
                    }
                }
            }
        }

        return aspects;
    }

    /// <summary>
    /// Calculates current moon phase information.
    /// </summary>
    public static MoonPhaseInfo GetCurrentMoonPhase()
    {
        return GetMoonPhaseForDate(DateTime.Now);
    }

    /// <summary>
    /// Calculates moon phase for a specific date.
    /// </summary>
    public static MoonPhaseInfo GetMoonPhaseForDate(DateTime date)
    {
        // Known new moon: January 6, 2000
        var knownNewMoon = new DateTime(2000, 1, 6, 18, 14, 0);
        double daysSince = (date - knownNewMoon).TotalDays;
        double synodicMonth = 29.53058770576;

        double lunation = daysSince / synodicMonth;
        double phasePosition = lunation - Math.Floor(lunation); // 0.0 to 1.0

        var phase = phasePosition switch
        {
            < 0.0625 => MoonPhase.NewMoon,
            < 0.1875 => MoonPhase.WaxingCrescent,
            < 0.3125 => MoonPhase.FirstQuarter,
            < 0.4375 => MoonPhase.WaxingGibbous,
            < 0.5625 => MoonPhase.FullMoon,
            < 0.6875 => MoonPhase.WaningGibbous,
            < 0.8125 => MoonPhase.LastQuarter,
            < 0.9375 => MoonPhase.WaningCrescent,
            _ => MoonPhase.NewMoon
        };

        // Approximate illumination
        double illumination = 0.5 * (1 - Math.Cos(2 * Math.PI * phasePosition));

        // Approximate moon sign (moon moves ~13.2 degrees/day through zodiac)
        double jd = ToJulianDay(date, 0);
        double daysSinceEpoch = jd - 2451545.0;
        double moonLong = NormalizeDegrees(218.32 + 13.1764 * daysSinceEpoch +
            6.289 * Math.Sin(ToRadians(134.963 + 13.0650 * daysSinceEpoch)));

        // Days until next phase
        double daysToNextPhase = synodicMonth * (Math.Ceiling(phasePosition * 8) / 8.0 - phasePosition);

        return new MoonPhaseInfo
        {
            Phase = phase,
            MoonSign = GetSignFromLongitude(moonLong),
            Illumination = Math.Round(illumination, 3),
            NextPhaseDate = date.AddDays(daysToNextPhase)
        };
    }

    /// <summary>
    /// Generates sample transits for the current period.
    /// </summary>
    public static List<Transit> GetCurrentTransits(NatalChart chart)
    {
        var transits = new List<Transit>();
        var now = DateTime.Now;
        var jd = ToJulianDay(now, 0);
        var daysSinceEpoch = jd - 2451545.0;

        // Calculate current positions of slow-moving planets
        var currentPositions = new Dictionary<Planet, double>();
        foreach (var (planet, basePos) in J2000Positions)
        {
            double period = OrbitalPeriods[planet];
            double longitude = NormalizeDegrees(basePos + (360.0 / period) * daysSinceEpoch);
            currentPositions[planet] = longitude;
        }

        // Check outer planet transits to natal planets
        var outerPlanets = new[] { Planet.Jupiter, Planet.Saturn, Planet.Uranus, Planet.Neptune, Planet.Pluto };
        var natalPlanets = chart.Planets.Where(p =>
            p.Planet == Planet.Sun || p.Planet == Planet.Moon ||
            p.Planet == Planet.Mercury || p.Planet == Planet.Venus ||
            p.Planet == Planet.Mars || p.Planet == Planet.Ascendant).ToList();

        foreach (var outer in outerPlanets)
        {
            if (!currentPositions.ContainsKey(outer)) continue;
            double transitLong = currentPositions[outer];

            foreach (var natal in natalPlanets)
            {
                double diff = Math.Abs(transitLong - natal.Degrees);
                if (diff > 180) diff = 360 - diff;

                TransitType? transitType = diff switch
                {
                    < 5 => TransitType.Conjunction,
                    > 175 and < 185 => TransitType.Opposition,
                    > 85 and < 95 => TransitType.Square,
                    > 115 and < 125 => TransitType.Trine,
                    > 55 and < 65 => TransitType.Sextile,
                    _ => null
                };

                if (transitType.HasValue)
                {
                    transits.Add(new Transit
                    {
                        TransitingPlanet = outer,
                        NatalPlanet = natal.Planet,
                        Type = transitType.Value,
                        TransitSign = GetSignFromLongitude(transitLong),
                        TransitDegrees = transitLong,
                        ExactDate = now.AddDays(_rng.Next(-3, 10)),
                        IsActive = true,
                        Theme = GetTransitTheme(outer, natal.Planet, transitType.Value),
                        Interpretation = GetTransitInterpretation(outer, natal.Planet, transitType.Value)
                    });
                }
            }
        }

        // If no transits found, add some representative ones
        if (transits.Count == 0)
        {
            transits.Add(new Transit
            {
                TransitingPlanet = Planet.Jupiter,
                NatalPlanet = Planet.Sun,
                Type = TransitType.Trine,
                TransitSign = ZodiacSign.Gemini,
                ExactDate = now.AddDays(3),
                IsActive = true,
                Theme = "Expansion & Growth",
                Interpretation = "Jupiter harmonizes with your Sun, bringing opportunities for expansion and optimism."
            });
            transits.Add(new Transit
            {
                TransitingPlanet = Planet.Saturn,
                NatalPlanet = Planet.Moon,
                Type = TransitType.Sextile,
                TransitSign = ZodiacSign.Pisces,
                ExactDate = now.AddDays(7),
                IsActive = true,
                Theme = "Emotional Maturity",
                Interpretation = "Saturn supports your Moon, encouraging emotional discipline and inner stability."
            });
        }

        return transits;
    }

    private static string GetTransitTheme(Planet transiting, Planet natal, TransitType type) =>
        (transiting, natal) switch
        {
            (Planet.Jupiter, Planet.Sun) => "Expansion & Identity",
            (Planet.Jupiter, Planet.Moon) => "Emotional Growth",
            (Planet.Jupiter, Planet.Venus) => "Love & Abundance",
            (Planet.Saturn, Planet.Sun) => "Discipline & Structure",
            (Planet.Saturn, Planet.Moon) => "Emotional Maturity",
            (Planet.Uranus, _) => "Awakening & Change",
            (Planet.Neptune, _) => "Intuition & Dreams",
            (Planet.Pluto, _) => "Transformation & Power",
            _ => "Cosmic Influence"
        };

    private static string GetTransitInterpretation(Planet transiting, Planet natal, TransitType type)
    {
        string quality = type switch
        {
            TransitType.Conjunction => "merges its energy with",
            TransitType.Trine => "harmonizes beautifully with",
            TransitType.Sextile => "offers opportunities to",
            TransitType.Square => "challenges and catalyzes",
            TransitType.Opposition => "creates a dynamic tension with",
            _ => "influences"
        };

        return $"{transiting} {quality} your natal {natal}, inviting a period of {GetTransitTheme(transiting, natal, type).ToLower()}.";
    }

    // ── Helper Methods ──

    private static double ToJulianDay(DateTime dt, double timezoneOffset)
    {
        var utc = dt.AddHours(-timezoneOffset);
        int y = utc.Year, m = utc.Month, d = utc.Day;
        double h = utc.Hour + utc.Minute / 60.0 + utc.Second / 3600.0;

        if (m <= 2) { y--; m += 12; }

        int a = y / 100;
        int b = 2 - a + a / 4;

        return Math.Floor(365.25 * (y + 4716)) + Math.Floor(30.6001 * (m + 1)) + d + h / 24.0 + b - 1524.5;
    }

    private static ZodiacSign GetSignFromLongitude(double longitude)
    {
        longitude = NormalizeDegrees(longitude);
        int signIndex = (int)(longitude / 30.0);
        return (ZodiacSign)signIndex;
    }

    private static double NormalizeDegrees(double degrees)
    {
        degrees %= 360.0;
        if (degrees < 0) degrees += 360.0;
        return degrees;
    }

    private static double ToRadians(double degrees) => degrees * Math.PI / 180.0;
    private static double ToDegrees(double radians) => radians * 180.0 / Math.PI;
}
