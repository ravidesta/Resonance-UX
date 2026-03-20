using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// Home dashboard with cosmic overview, moon phase, transits, and quick actions.
/// </summary>
public sealed partial class DashboardPage : Page
{
    private NatalChart? _chart;

    public DashboardPage()
    {
        this.InitializeComponent();
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);

        _chart = e.Parameter as NatalChart;

        if (_chart == null)
        {
            // Create demo chart if none provided
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

        PopulateDashboard();
    }

    private void PopulateDashboard()
    {
        if (_chart == null) return;

        // Greeting
        var hour = DateTime.Now.Hour;
        var greeting = hour switch
        {
            < 12 => "Good morning",
            < 17 => "Good afternoon",
            _ => "Good evening"
        };
        GreetingText.Text = $"{greeting}, {_chart.BirthData.Name}";
        DateText.Text = DateTime.Now.ToString("dddd, MMMM d, yyyy");

        // Sun / Moon / Rising
        var sun = _chart.SunSign;
        var moon = _chart.MoonSign;
        var rising = _chart.Rising;
        SunMoonText.Text = $"Sun in {sun?.Sign} | Moon in {moon?.Sign} | Rising: {rising?.Sign}";

        // Moon phase
        var moonPhase = ChartCalculator.GetCurrentMoonPhase();
        MoonPhaseEmoji.Text = moonPhase.PhaseEmoji;
        MoonPhaseName.Text = moonPhase.PhaseName;
        MoonSignText.Text = $"Moon in {moonPhase.MoonSign}";
        MoonGuidanceText.Text = moonPhase.Guidance;

        // Element balance
        var planets = _chart.Planets.Where(p =>
            p.Planet != Planet.Ascendant && p.Planet != Planet.Midheaven).ToList();
        int total = planets.Count;
        if (total > 0)
        {
            int fire = planets.Count(p => NatalChart.GetElement(p.Sign) == Element.Fire);
            int earth = planets.Count(p => NatalChart.GetElement(p.Sign) == Element.Earth);
            int air = planets.Count(p => NatalChart.GetElement(p.Sign) == Element.Air);
            int water = planets.Count(p => NatalChart.GetElement(p.Sign) == Element.Water);

            FireBar.Value = fire * 100.0 / total;
            EarthBar.Value = earth * 100.0 / total;
            AirBar.Value = air * 100.0 / total;
            WaterBar.Value = water * 100.0 / total;

            FirePercent.Text = $"{fire * 100 / total}%";
            EarthPercent.Text = $"{earth * 100 / total}%";
            AirPercent.Text = $"{air * 100 / total}%";
            WaterPercent.Text = $"{water * 100 / total}%";
        }

        // Daily insight based on Sun sign
        DailyInsightText.Text = GetDailyInsight(sun?.Sign ?? ZodiacSign.Aries);

        // Transits
        var transits = ChartCalculator.GetCurrentTransits(_chart);
        TransitsList.ItemsSource = transits;

        // Planets list
        PlanetsList.ItemsSource = _chart.Planets
            .Where(p => p.Planet != Planet.SouthNode)
            .ToList();

        // Reflection prompt based on moon phase
        ReflectionPromptText.Text = GetReflectionPrompt(moonPhase.Phase);
    }

    private static string GetDailyInsight(ZodiacSign sunSign) => sunSign switch
    {
        ZodiacSign.Aries => "Your pioneering spirit is activated today. Channel your fire into intentional creation.",
        ZodiacSign.Taurus => "Ground yourself in sensory pleasure. Beauty and stability are your allies today.",
        ZodiacSign.Gemini => "Your mind is sparkling with connections. Let curiosity guide your path.",
        ZodiacSign.Cancer => "Nurture what matters most. Your emotional wisdom is your superpower.",
        ZodiacSign.Leo => "Radiate your authentic light. Creative self-expression opens new doors.",
        ZodiacSign.Virgo => "Attend to the sacred details. Your discernment serves a higher purpose.",
        ZodiacSign.Libra => "Seek harmony in all things. Relationships mirror your inner balance.",
        ZodiacSign.Scorpio => "Dive deep into transformation. Intensity is where your power lives.",
        ZodiacSign.Sagittarius => "Expand your horizons. Adventure and meaning await the seeker.",
        ZodiacSign.Capricorn => "Build with purpose. Your ambition is the scaffold for your dreams.",
        ZodiacSign.Aquarius => "Honor your uniqueness. Innovation comes from the edges, not the center.",
        ZodiacSign.Pisces => "Trust your intuition. The unseen world speaks through your sensitivity.",
        _ => "The cosmos unfolds its wisdom for you today."
    };

    private static string GetReflectionPrompt(MoonPhase phase) => phase switch
    {
        MoonPhase.NewMoon => "What new intention would you like to set for this lunar cycle?",
        MoonPhase.WaxingCrescent => "What first step can you take toward your intention today?",
        MoonPhase.FirstQuarter => "What obstacle is asking you to grow? How will you meet it?",
        MoonPhase.WaxingGibbous => "What refinements can you make to align more deeply with your path?",
        MoonPhase.FullMoon => "What has come to fruition? What are you ready to release?",
        MoonPhase.WaningGibbous => "What wisdom have you gained that you can share with others?",
        MoonPhase.LastQuarter => "What are you ready to forgive and let go of?",
        MoonPhase.WaningCrescent => "How can you honor rest and surrender today?",
        _ => "What seeds are you planting during this lunar cycle?"
    };

    private void ExploreChart_Click(object sender, RoutedEventArgs e)
    {
        if (Frame != null)
        {
            Frame.Navigate(typeof(NatalChartPage), _chart);
        }
    }

    private void BeginReflection_Click(object sender, RoutedEventArgs e)
    {
        if (Frame != null)
        {
            Frame.Navigate(typeof(DailyReflectionPage), _chart);
        }
    }

    private void StartMeditation_Click(object sender, RoutedEventArgs e)
    {
        if (Frame != null)
        {
            Frame.Navigate(typeof(MeditationPage), _chart);
        }
    }
}
