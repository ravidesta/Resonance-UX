using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// Guided meditation page with timer, breathing guidance, and session library.
/// </summary>
public sealed partial class MeditationPage : Page
{
    private NatalChart? _chart;
    private DispatcherTimer? _timer;
    private TimeSpan _remainingTime;
    private TimeSpan _totalDuration;
    private bool _isRunning;
    private bool _isPaused;
    private int _breathPhase; // 0=inhale, 1=hold, 2=exhale, 3=hold
    private int _breathCounter;

    private readonly string[] _breathGuidance = new[]
    {
        "Breathe in... draw cosmic light into your center",
        "Hold... let the light settle within you",
        "Breathe out... release what no longer serves",
        "Rest... in the space between breaths"
    };

    public MeditationPage()
    {
        this.InitializeComponent();
        _totalDuration = TimeSpan.FromMinutes(10);
        _remainingTime = _totalDuration;

        LoadMeditationLibrary();
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        _chart = e.Parameter as NatalChart;
        UpdateSessionForChart();
    }

    protected override void OnNavigatedFrom(NavigationEventArgs e)
    {
        base.OnNavigatedFrom(e);
        StopTimer();
    }

    private void UpdateSessionForChart()
    {
        if (_chart == null) return;

        var moonPhase = ChartCalculator.GetCurrentMoonPhase();

        SessionTitle.Text = moonPhase.Phase switch
        {
            MoonPhase.NewMoon => "New Moon Intention Setting",
            MoonPhase.FullMoon => "Full Moon Illumination",
            MoonPhase.WaxingCrescent or MoonPhase.WaxingGibbous => "Lunar Expansion Breathing",
            MoonPhase.WaningGibbous or MoonPhase.WaningCrescent => "Lunar Release Meditation",
            MoonPhase.FirstQuarter => "Courage & Action Meditation",
            MoonPhase.LastQuarter => "Letting Go Meditation",
            _ => "Cosmic Stillness"
        };

        GuidanceText.Text = moonPhase.Phase switch
        {
            MoonPhase.NewMoon =>
                "In the darkness of the new moon, turn inward.\n" +
                "Set your intention with each breath. What do you wish to create?",
            MoonPhase.FullMoon =>
                "Under the full moon's light, let everything be illuminated.\n" +
                "Breathe in radiance, breathe out gratitude.",
            _ =>
                "Close your eyes. Breathe in harmony with the lunar rhythm.\n" +
                "Let each inhale draw in cosmic light, each exhale release what no longer serves."
        };
    }

    private void DurationChanged(object sender, RoutedEventArgs e)
    {
        if (sender is RadioButton radio && int.TryParse(radio.Tag?.ToString(), out int minutes))
        {
            _totalDuration = TimeSpan.FromMinutes(minutes);
            _remainingTime = _totalDuration;
            UpdateTimerDisplay();
        }
    }

    private void StartMeditation_Click(object sender, RoutedEventArgs e)
    {
        if (_isPaused)
        {
            ResumeMeditation();
            return;
        }

        _remainingTime = _totalDuration;
        _isRunning = true;
        _isPaused = false;
        _breathPhase = 0;
        _breathCounter = 0;

        StartButton.Content = "Running...";
        StartButton.IsEnabled = false;
        PauseButton.Visibility = Visibility.Visible;
        StopButton.Visibility = Visibility.Visible;

        _timer = new DispatcherTimer
        {
            Interval = TimeSpan.FromSeconds(1)
        };
        _timer.Tick += Timer_Tick;
        _timer.Start();

        TimerRing.IsActive = true;
    }

    private void PauseMeditation_Click(object sender, RoutedEventArgs e)
    {
        if (_isRunning && !_isPaused)
        {
            _isPaused = true;
            _timer?.Stop();
            PauseButton.Content = "Resume";
            StartButton.Content = "Paused";
            GuidanceText.Text = "Meditation paused. Take your time.";
        }
        else if (_isPaused)
        {
            ResumeMeditation();
        }
    }

    private void ResumeMeditation()
    {
        _isPaused = false;
        _timer?.Start();
        PauseButton.Content = "Pause";
        StartButton.Content = "Running...";
    }

    private void StopMeditation_Click(object sender, RoutedEventArgs e)
    {
        StopTimer();
        CompleteMeditation();
    }

    private void Timer_Tick(object? sender, object e)
    {
        _remainingTime -= TimeSpan.FromSeconds(1);
        _breathCounter++;

        if (_remainingTime <= TimeSpan.Zero)
        {
            StopTimer();
            CompleteMeditation();
            return;
        }

        UpdateTimerDisplay();

        // Cycle breathing guidance every 4 seconds
        if (_breathCounter % 4 == 0)
        {
            _breathPhase = (_breathPhase + 1) % _breathGuidance.Length;
            GuidanceText.Text = _breathGuidance[_breathPhase];
        }

        // Update progress ring
        double elapsed = (_totalDuration - _remainingTime).TotalSeconds;
        double total = _totalDuration.TotalSeconds;
        TimerRing.Value = (elapsed / total) * 100;
    }

    private void UpdateTimerDisplay()
    {
        TimerText.Text = _remainingTime.ToString(@"mm\:ss");
        TimerLabel.Text = _remainingTime.TotalMinutes > 1 ? "minutes" : "seconds";
    }

    private void StopTimer()
    {
        _isRunning = false;
        _isPaused = false;
        _timer?.Stop();
        _timer = null;
    }

    private async void CompleteMeditation()
    {
        TimerRing.IsActive = false;
        TimerRing.Value = 100;
        TimerText.Text = "00:00";
        TimerLabel.Text = "complete";

        StartButton.Content = "Begin Meditation";
        StartButton.IsEnabled = true;
        PauseButton.Visibility = Visibility.Collapsed;
        StopButton.Visibility = Visibility.Collapsed;

        GuidanceText.Text = "Your meditation is complete.\n" +
                           "Gently return to awareness. Carry this stillness with you.";

        // Show completion dialog
        var dialog = new ContentDialog
        {
            Title = "Meditation Complete",
            Content = "Well done. You honored this time of cosmic stillness.\n\n" +
                     $"Duration: {_totalDuration.TotalMinutes:F0} minutes\n" +
                     "Consider recording a reflection about your experience.",
            PrimaryButtonText = "Write Reflection",
            CloseButtonText = "Continue",
            XamlRoot = this.XamlRoot
        };

        var result = await dialog.ShowAsync();
        if (result == ContentDialogResult.Primary)
        {
            Frame?.Navigate(typeof(DailyReflectionPage), _chart);
        }

        // Reset timer
        _remainingTime = _totalDuration;
        UpdateTimerDisplay();
        TimerRing.Value = 0;
    }

    private void LoadMeditationLibrary()
    {
        var sessions = new List<MeditationSession>
        {
            new()
            {
                Title = "Lunar Breathing",
                Description = "A gentle breathing meditation synchronized with the moon's rhythm. " +
                             "Inhale for 4 counts, hold for 4, exhale for 6.",
                Duration = TimeSpan.FromMinutes(10),
                Theme = "LUNAR ALIGNMENT",
                AssociatedPlanet = Planet.Moon
            },
            new()
            {
                Title = "Solar Radiance",
                Description = "Connect with your Sun sign's energy. Visualize golden light " +
                             "filling your body, illuminating your authentic self.",
                Duration = TimeSpan.FromMinutes(15),
                Theme = "SOLAR IDENTITY",
                AssociatedPlanet = Planet.Sun
            },
            new()
            {
                Title = "Planetary Body Scan",
                Description = "Journey through each planetary energy center in your body. " +
                             "From root (Saturn) to crown (Neptune).",
                Duration = TimeSpan.FromMinutes(20),
                Theme = "PLANETARY CHAKRAS",
            },
            new()
            {
                Title = "Mercury Mindfulness",
                Description = "Calm the mercurial mind through focused attention. " +
                             "Observe thoughts like planets passing through the sky.",
                Duration = TimeSpan.FromMinutes(10),
                Theme = "MENTAL CLARITY",
                AssociatedPlanet = Planet.Mercury
            },
            new()
            {
                Title = "Venus Heart Opening",
                Description = "Open your heart center to receive and give love. " +
                             "Let Venusian energy soften resistance and invite beauty.",
                Duration = TimeSpan.FromMinutes(12),
                Theme = "HEART CENTER",
                AssociatedPlanet = Planet.Venus
            },
            new()
            {
                Title = "Saturn's Grounding",
                Description = "Root yourself in the earth. Feel Saturn's steady, " +
                             "patient energy anchoring you to the present moment.",
                Duration = TimeSpan.FromMinutes(8),
                Theme = "GROUNDING",
                AssociatedPlanet = Planet.Saturn
            }
        };

        MeditationList.ItemsSource = sessions;
    }
}
