using System.Numerics;
using Microsoft.Graphics.Canvas;
using Microsoft.Graphics.Canvas.Geometry;
using Microsoft.Graphics.Canvas.Text;
using Microsoft.Graphics.Canvas.UI;
using Microsoft.Graphics.Canvas.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using Windows.UI;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// Natal chart page with Win2D canvas rendering of the zodiac wheel,
/// planetary positions, house cusps, and aspect lines.
/// </summary>
public sealed partial class NatalChartPage : Page
{
    private NatalChart? _chart;

    // ── Resonance Color Palette ──
    private static readonly Color GoldPrimary = Color.FromArgb(255, 197, 160, 89);
    private static readonly Color GoldLight = Color.FromArgb(255, 230, 208, 161);
    private static readonly Color GoldDark = Color.FromArgb(255, 154, 122, 58);
    private static readonly Color ForestDeep = Color.FromArgb(255, 10, 28, 20);
    private static readonly Color ForestMid = Color.FromArgb(255, 18, 46, 33);
    private static readonly Color ForestLight = Color.FromArgb(255, 27, 64, 46);
    private static readonly Color ForestNight = Color.FromArgb(255, 5, 16, 11);
    private static readonly Color CreamWhite = Color.FromArgb(255, 250, 250, 248);
    private static readonly Color ForestMuted = Color.FromArgb(255, 92, 112, 101);

    // Element colors
    private static readonly Color FireColor = Color.FromArgb(255, 184, 92, 58);
    private static readonly Color EarthColor = Color.FromArgb(255, 107, 125, 74);
    private static readonly Color AirColor = Color.FromArgb(255, 122, 155, 175);
    private static readonly Color WaterColor = Color.FromArgb(255, 74, 107, 125);

    // Aspect colors
    private static readonly Color ConjunctionColor = GoldPrimary;
    private static readonly Color SextileColor = AirColor;
    private static readonly Color SquareColor = FireColor;
    private static readonly Color TrineColor = EarthColor;
    private static readonly Color OppositionColor = Color.FromArgb(255, 154, 74, 74);

    public NatalChartPage()
    {
        this.InitializeComponent();
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        _chart = e.Parameter as NatalChart;

        if (_chart == null)
        {
            _chart = ChartCalculator.CalculateChart(new BirthData
            {
                Name = "Cosmic Explorer",
                BirthDate = new DateTime(1990, 6, 21),
                BirthTime = new TimeSpan(14, 30, 0),
                Latitude = 40.7128,
                Longitude = -74.0060,
                TimezoneOffset = -5
            });
        }

        PopulateDetails();
    }

    private void PopulateDetails()
    {
        if (_chart == null) return;

        var bd = _chart.BirthData;
        ChartTitleText.Text = $"{bd.Name}'s Cosmic Blueprint";
        ChartSubtitleText.Text = $"Born {bd.BirthDate:MMMM d, yyyy} at {bd.BirthDateTime:h:mm tt}";

        // Big Three
        var sun = _chart.SunSign;
        var moon = _chart.MoonSign;
        var rising = _chart.Rising;

        if (sun != null)
        {
            SunSignText.Text = $"Sun in {sun.Sign}";
            SunHouseText.Text = $"{sun.DegreeDisplay} - {GetHouseOrdinal(sun.House)} House";
        }
        if (moon != null)
        {
            MoonSignText.Text = $"Moon in {moon.Sign}";
            MoonHouseText.Text = $"{moon.DegreeDisplay} - {GetHouseOrdinal(moon.House)} House";
        }
        if (rising != null)
        {
            RisingSignText.Text = $"Rising in {rising.Sign}";
            RisingDegreeText.Text = rising.DegreeDisplay;
        }

        // Lists
        PlanetPositionsList.ItemsSource = _chart.Planets;
        AspectsList.ItemsSource = _chart.Aspects;
        HousesList.ItemsSource = _chart.Houses;
    }

    private static string GetHouseOrdinal(int house) => house switch
    {
        1 => "1st", 2 => "2nd", 3 => "3rd",
        _ => $"{house}th"
    };

    // ══════════════════════════════════════════════════════════════
    // WIN2D CHART RENDERING
    // ══════════════════════════════════════════════════════════════

    private void ChartCanvas_CreateResources(CanvasControl sender, CanvasCreateResourcesEventArgs args)
    {
        // Resources loaded on demand during Draw
    }

    private void ChartCanvas_Draw(CanvasControl sender, CanvasDrawEventArgs args)
    {
        var ds = args.DrawingSession;
        float w = (float)sender.ActualWidth;
        float h = (float)sender.ActualHeight;
        float cx = w / 2f;
        float cy = h / 2f;
        float maxRadius = Math.Min(cx, cy) - 20f;

        // Radii for different rings
        float outerR = maxRadius;
        float zodiacOuterR = maxRadius;
        float zodiacInnerR = maxRadius * 0.85f;
        float houseOuterR = zodiacInnerR;
        float planetR = maxRadius * 0.68f;
        float innerR = maxRadius * 0.35f;
        float centerR = maxRadius * 0.18f;

        // Clear with dark background
        ds.Clear(ForestNight);

        // ── 1. Outer gold ring ──
        DrawRing(ds, cx, cy, outerR, outerR - 3f, GoldPrimary);

        // ── 2. Zodiac segments (12 colored segments) ──
        DrawZodiacWheel(ds, cx, cy, zodiacOuterR - 3f, zodiacInnerR);

        // ── 3. Zodiac sign glyphs ──
        DrawZodiacGlyphs(ds, cx, cy, (zodiacOuterR + zodiacInnerR) / 2f - 4f);

        // ── 4. Inner gold ring (between zodiac and houses) ──
        DrawRing(ds, cx, cy, zodiacInnerR, zodiacInnerR - 2f, GoldDark);

        // ── 5. House lines ──
        DrawHouseLines(ds, cx, cy, houseOuterR - 2f, innerR);

        // ── 6. House numbers ──
        DrawHouseNumbers(ds, cx, cy, (houseOuterR + innerR) / 2f - 10f);

        // ── 7. Aspect lines (connecting planets) ──
        DrawAspectLines(ds, cx, cy, planetR);

        // ── 8. Planet symbols ──
        DrawPlanets(ds, cx, cy, planetR);

        // ── 9. Center circle ──
        ds.FillCircle(cx, cy, centerR, ForestDeep);
        DrawRing(ds, cx, cy, centerR, centerR - 1.5f, GoldDark);

        // Center decoration
        var centerFormat = new CanvasTextFormat
        {
            FontFamily = "Segoe UI Symbol",
            FontSize = centerR * 0.6f,
            HorizontalAlignment = CanvasHorizontalAlignment.Center,
            VerticalAlignment = CanvasVerticalAlignment.Center
        };
        ds.DrawText("\u2726", cx, cy, GoldPrimary, centerFormat);

        // ── 10. Outer decorative ring ──
        DrawRing(ds, cx, cy, outerR + 2f, outerR + 1f, Color.FromArgb(60, 197, 160, 89));
    }

    private void DrawRing(CanvasDrawingSession ds, float cx, float cy,
                          float outerR, float innerR, Color color)
    {
        ds.DrawCircle(cx, cy, (outerR + innerR) / 2f, color, outerR - innerR);
    }

    private void DrawZodiacWheel(CanvasDrawingSession ds, float cx, float cy,
                                  float outerR, float innerR)
    {
        double ascDegrees = _chart?.Rising?.Degrees ?? 0;

        for (int i = 0; i < 12; i++)
        {
            var sign = (ZodiacSign)i;
            var element = NatalChart.GetElement(sign);

            Color segColor = element switch
            {
                Element.Fire => Color.FromArgb(40, FireColor.R, FireColor.G, FireColor.B),
                Element.Earth => Color.FromArgb(40, EarthColor.R, EarthColor.G, EarthColor.B),
                Element.Air => Color.FromArgb(40, AirColor.R, AirColor.G, AirColor.B),
                Element.Water => Color.FromArgb(40, WaterColor.R, WaterColor.G, WaterColor.B),
                _ => Color.FromArgb(30, 255, 255, 255)
            };

            // Each sign occupies 30 degrees, offset by ascendant
            double startAngle = (i * 30.0 - ascDegrees - 90) * Math.PI / 180.0;
            double endAngle = ((i + 1) * 30.0 - ascDegrees - 90) * Math.PI / 180.0;

            // Draw filled arc segment
            using var pathBuilder = new CanvasPathBuilder(ds);
            pathBuilder.BeginFigure(
                cx + outerR * (float)Math.Cos(startAngle),
                cy + outerR * (float)Math.Sin(startAngle));

            // Outer arc
            int arcSteps = 15;
            for (int s = 1; s <= arcSteps; s++)
            {
                double angle = startAngle + (endAngle - startAngle) * s / arcSteps;
                pathBuilder.AddLine(
                    cx + outerR * (float)Math.Cos(angle),
                    cy + outerR * (float)Math.Sin(angle));
            }

            // Inner arc (reverse)
            for (int s = arcSteps; s >= 0; s--)
            {
                double angle = startAngle + (endAngle - startAngle) * s / arcSteps;
                pathBuilder.AddLine(
                    cx + innerR * (float)Math.Cos(angle),
                    cy + innerR * (float)Math.Sin(angle));
            }

            pathBuilder.EndFigure(CanvasFigureLoop.Closed);

            using var geo = CanvasGeometry.CreatePath(pathBuilder);
            ds.FillGeometry(geo, segColor);

            // Draw segment divider line
            ds.DrawLine(
                cx + innerR * (float)Math.Cos(startAngle),
                cy + innerR * (float)Math.Sin(startAngle),
                cx + outerR * (float)Math.Cos(startAngle),
                cy + outerR * (float)Math.Sin(startAngle),
                Color.FromArgb(60, GoldDark.R, GoldDark.G, GoldDark.B), 0.5f);
        }
    }

    private void DrawZodiacGlyphs(CanvasDrawingSession ds, float cx, float cy, float radius)
    {
        double ascDegrees = _chart?.Rising?.Degrees ?? 0;

        var format = new CanvasTextFormat
        {
            FontFamily = "Segoe UI Symbol",
            FontSize = 16,
            HorizontalAlignment = CanvasHorizontalAlignment.Center,
            VerticalAlignment = CanvasVerticalAlignment.Center
        };

        for (int i = 0; i < 12; i++)
        {
            var sign = (ZodiacSign)i;
            double midAngle = ((i * 30.0 + 15.0) - ascDegrees - 90) * Math.PI / 180.0;

            float gx = cx + radius * (float)Math.Cos(midAngle);
            float gy = cy + radius * (float)Math.Sin(midAngle);

            string glyph = ZodiacMetadata.GetGlyph(sign);

            // Background circle for readability
            ds.FillCircle(gx, gy, 12, Color.FromArgb(120, ForestDeep.R, ForestDeep.G, ForestDeep.B));
            ds.DrawText(glyph, gx, gy, GoldLight, format);
        }
    }

    private void DrawHouseLines(CanvasDrawingSession ds, float cx, float cy,
                                 float outerR, float innerR)
    {
        if (_chart?.Houses == null) return;

        double ascDegrees = _chart.Rising?.Degrees ?? 0;

        foreach (var house in _chart.Houses)
        {
            double angle = (house.Degrees - ascDegrees - 90) * Math.PI / 180.0;

            float lineWidth = (house.HouseNumber == 1 || house.HouseNumber == 4 ||
                             house.HouseNumber == 7 || house.HouseNumber == 10) ? 1.5f : 0.7f;

            Color lineColor = (house.HouseNumber == 1 || house.HouseNumber == 10)
                ? GoldPrimary
                : Color.FromArgb(80, GoldDark.R, GoldDark.G, GoldDark.B);

            ds.DrawLine(
                cx + innerR * (float)Math.Cos(angle),
                cy + innerR * (float)Math.Sin(angle),
                cx + outerR * (float)Math.Cos(angle),
                cy + outerR * (float)Math.Sin(angle),
                lineColor, lineWidth);
        }
    }

    private void DrawHouseNumbers(CanvasDrawingSession ds, float cx, float cy, float radius)
    {
        if (_chart?.Houses == null) return;

        double ascDegrees = _chart.Rising?.Degrees ?? 0;

        var format = new CanvasTextFormat
        {
            FontFamily = "Segoe UI Variable",
            FontSize = 10,
            HorizontalAlignment = CanvasHorizontalAlignment.Center,
            VerticalAlignment = CanvasVerticalAlignment.Center
        };

        for (int i = 0; i < _chart.Houses.Count; i++)
        {
            int next = (i + 1) % 12;
            double startDeg = _chart.Houses[i].Degrees;
            double endDeg = _chart.Houses[next].Degrees;

            if (endDeg < startDeg) endDeg += 360;
            double midDeg = (startDeg + endDeg) / 2.0;

            double angle = (midDeg - ascDegrees - 90) * Math.PI / 180.0;

            float nx = cx + radius * (float)Math.Cos(angle);
            float ny = cy + radius * (float)Math.Sin(angle);

            ds.DrawText((_chart.Houses[i].HouseNumber).ToString(),
                       nx, ny, ForestMuted, format);
        }
    }

    private void DrawAspectLines(CanvasDrawingSession ds, float cx, float cy, float radius)
    {
        if (_chart?.Aspects == null || _chart.Planets == null) return;

        double ascDegrees = _chart.Rising?.Degrees ?? 0;

        foreach (var aspect in _chart.Aspects)
        {
            var p1 = _chart.Planets.FirstOrDefault(p => p.Planet == aspect.Planet1);
            var p2 = _chart.Planets.FirstOrDefault(p => p.Planet == aspect.Planet2);
            if (p1 == null || p2 == null) continue;

            double angle1 = (p1.Degrees - ascDegrees - 90) * Math.PI / 180.0;
            double angle2 = (p2.Degrees - ascDegrees - 90) * Math.PI / 180.0;

            float x1 = cx + radius * (float)Math.Cos(angle1);
            float y1 = cy + radius * (float)Math.Sin(angle1);
            float x2 = cx + radius * (float)Math.Cos(angle2);
            float y2 = cy + radius * (float)Math.Sin(angle2);

            Color lineColor = aspect.Type switch
            {
                AspectType.Conjunction => ConjunctionColor,
                AspectType.Sextile => SextileColor,
                AspectType.Square => SquareColor,
                AspectType.Trine => TrineColor,
                AspectType.Opposition => OppositionColor,
                _ => ForestMuted
            };

            // Reduce opacity based on orb (tighter orb = more visible)
            byte alpha = (byte)(200 - (int)(aspect.Orb * 20));
            lineColor = Color.FromArgb(alpha, lineColor.R, lineColor.G, lineColor.B);

            float strokeWidth = aspect.Type switch
            {
                AspectType.Conjunction => 1.8f,
                AspectType.Opposition => 1.5f,
                AspectType.Square => 1.3f,
                AspectType.Trine => 1.3f,
                _ => 0.8f
            };

            // Dashed lines for challenging aspects
            if (aspect.Type == AspectType.Square || aspect.Type == AspectType.Opposition)
            {
                var style = new CanvasStrokeStyle
                {
                    DashStyle = CanvasDashStyle.Dash,
                    DashCap = CanvasCapStyle.Round
                };
                ds.DrawLine(x1, y1, x2, y2, lineColor, strokeWidth, style);
            }
            else
            {
                ds.DrawLine(x1, y1, x2, y2, lineColor, strokeWidth);
            }
        }
    }

    private void DrawPlanets(CanvasDrawingSession ds, float cx, float cy, float radius)
    {
        if (_chart?.Planets == null) return;

        double ascDegrees = _chart.Rising?.Degrees ?? 0;

        var format = new CanvasTextFormat
        {
            FontFamily = "Segoe UI Symbol",
            FontSize = 14,
            HorizontalAlignment = CanvasHorizontalAlignment.Center,
            VerticalAlignment = CanvasVerticalAlignment.Center
        };

        var retroFormat = new CanvasTextFormat
        {
            FontFamily = "Segoe UI",
            FontSize = 8,
            HorizontalAlignment = CanvasHorizontalAlignment.Center,
            VerticalAlignment = CanvasVerticalAlignment.Center
        };

        // Avoid overlapping planets by adjusting positions
        var positions = new List<(PlanetPlacement planet, double adjustedAngle)>();
        var sortedPlanets = _chart.Planets
            .Where(p => p.Planet != Planet.Ascendant && p.Planet != Planet.Midheaven)
            .OrderBy(p => p.Degrees)
            .ToList();

        double minSeparation = 8.0; // minimum degrees between symbols

        foreach (var planet in sortedPlanets)
        {
            double angle = planet.Degrees;

            // Check for overlap with already placed planets
            foreach (var (_, existingAngle) in positions)
            {
                double diff = Math.Abs(angle - existingAngle);
                if (diff > 180) diff = 360 - diff;

                if (diff < minSeparation)
                {
                    angle += minSeparation - diff;
                }
            }

            positions.Add((planet, angle));
        }

        foreach (var (planet, adjustedAngle) in positions)
        {
            double angle = (adjustedAngle - ascDegrees - 90) * Math.PI / 180.0;

            float px = cx + radius * (float)Math.Cos(angle);
            float py = cy + radius * (float)Math.Sin(angle);

            // Planet background circle
            ds.FillCircle(px, py, 13, ForestDeep);
            ds.DrawCircle(px, py, 13, GoldDark, 1f);

            // Planet glyph
            ds.DrawText(planet.Glyph, px, py - 1, GoldLight, format);

            // Retrograde indicator
            if (planet.IsRetrograde)
            {
                ds.DrawText("R", px + 10, py + 8,
                    Color.FromArgb(180, FireColor.R, FireColor.G, FireColor.B),
                    retroFormat);
            }

            // Line from planet to zodiac wheel
            double lineAngle = (planet.Degrees - ascDegrees - 90) * Math.PI / 180.0;
            float lineStartR = radius + 15;
            float lineEndR = radius * 1.22f;
            ds.DrawLine(
                cx + lineStartR * (float)Math.Cos(lineAngle),
                cy + lineStartR * (float)Math.Sin(lineAngle),
                cx + lineEndR * (float)Math.Cos(lineAngle),
                cy + lineEndR * (float)Math.Sin(lineAngle),
                Color.FromArgb(50, GoldPrimary.R, GoldPrimary.G, GoldPrimary.B), 0.5f);
        }
    }
}
