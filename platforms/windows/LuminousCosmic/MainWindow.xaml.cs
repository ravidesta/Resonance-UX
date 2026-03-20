using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media.Animation;
using LuminousCosmic.Models;
using LuminousCosmic.Views;

namespace LuminousCosmic;

/// <summary>
/// Main application window with NavigationView and content frame.
/// </summary>
public sealed partial class MainWindow : Window
{
    private NatalChart? _currentChart;
    private bool _hasCompletedOnboarding;

    public MainWindow()
    {
        this.InitializeComponent();

        // Set window title bar
        ExtendsContentIntoTitleBar = true;
        SetTitleBar(AppTitleBar);

        // Update moon phase in nav footer
        UpdateMoonPhaseDisplay();
    }

    private void NavView_Loaded(object sender, RoutedEventArgs e)
    {
        // Select Dashboard by default
        NavView.SelectedItem = NavDashboard;
        NavigateToPage("Dashboard");

        // Show onboarding if first launch
        if (!_hasCompletedOnboarding)
        {
            ShowOnboardingAsync();
        }
    }

    private void NavView_SelectionChanged(NavigationView sender, NavigationViewSelectionChangedEventArgs args)
    {
        if (args.SelectedItemContainer is NavigationViewItem item)
        {
            var tag = item.Tag?.ToString();
            if (!string.IsNullOrEmpty(tag))
            {
                NavigateToPage(tag);
            }
        }
    }

    private void NavigateToPage(string pageTag)
    {
        Type? pageType = pageTag switch
        {
            "Dashboard" => typeof(DashboardPage),
            "NatalChart" => typeof(NatalChartPage),
            "Reflection" => typeof(DailyReflectionPage),
            "Meditation" => typeof(MeditationPage),
            "Library" => typeof(ChapterLibraryPage),
            "Settings" => typeof(SettingsPage),
            _ => typeof(DashboardPage)
        };

        ContentFrame.Navigate(pageType, _currentChart,
            new SlideNavigationTransitionInfo
            {
                Effect = SlideNavigationTransitionEffect.FromRight
            });
    }

    private async void ShowOnboardingAsync()
    {
        await Task.Delay(500); // Brief delay for window to fully render

        var dialog = new OnboardingDialog
        {
            XamlRoot = Content.XamlRoot
        };

        var result = await dialog.ShowAsync();

        if (result == ContentDialogResult.Primary && dialog.BirthData != null)
        {
            _currentChart = ChartCalculator.CalculateChart(dialog.BirthData);
            _hasCompletedOnboarding = true;

            // Refresh current page with chart data
            NavigateToPage("Dashboard");
        }
        else
        {
            // Generate a demo chart
            _currentChart = ChartCalculator.CalculateChart(new BirthData
            {
                Name = "Cosmic Explorer",
                BirthDate = new DateTime(1990, 6, 21),
                BirthTime = new TimeSpan(14, 30, 0),
                Latitude = 40.7128,
                Longitude = -74.0060,
                TimezoneOffset = -5
            });
            _hasCompletedOnboarding = true;
        }
    }

    public void SetChart(NatalChart chart)
    {
        _currentChart = chart;
    }

    private void UpdateMoonPhaseDisplay()
    {
        var moonPhase = ChartCalculator.GetCurrentMoonPhase();
        NavMoonPhaseText.Text = moonPhase.PhaseName;
        NavMoonSignText.Text = $"in {moonPhase.MoonSign}";
    }
}
