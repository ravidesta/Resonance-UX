using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using LuminousCosmic.Models;
using LuminousCosmic.Theme;

namespace LuminousCosmic.Views;

/// <summary>
/// Settings page with theme toggle, chart configuration, and app preferences.
/// </summary>
public sealed partial class SettingsPage : Page
{
    public SettingsPage()
    {
        this.InitializeComponent();
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);

        // Sync toggle with current theme state
        ThemeToggle.IsOn = App.ThemeManager.CurrentMode == ResonanceTheme.ThemeMode.Night;
    }

    private void ThemeToggle_Toggled(object sender, RoutedEventArgs e)
    {
        var mode = ThemeToggle.IsOn
            ? ResonanceTheme.ThemeMode.Night
            : ResonanceTheme.ThemeMode.Day;

        App.ThemeManager.ApplyTheme(mode);
    }

    private async void UpdateBirthData_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OnboardingDialog
        {
            XamlRoot = this.XamlRoot
        };

        var result = await dialog.ShowAsync();

        if (result == ContentDialogResult.Primary && dialog.BirthData != null)
        {
            var chart = ChartCalculator.CalculateChart(dialog.BirthData);

            // Update the main window's chart
            if (App.MainAppWindow is MainWindow mainWindow)
            {
                mainWindow.SetChart(chart);
            }

            CurrentBirthDataText.Text =
                $"Chart calculated for {dialog.BirthData.Name}, born " +
                $"{dialog.BirthData.BirthDate:MMMM d, yyyy} at " +
                $"{dialog.BirthData.BirthDateTime:h:mm tt} in {dialog.BirthData.BirthCity}.";
        }
    }

    private void ResetToDemo_Click(object sender, RoutedEventArgs e)
    {
        var demoData = new BirthData
        {
            Name = "Cosmic Explorer",
            BirthDate = new DateTime(1990, 6, 21),
            BirthTime = new TimeSpan(14, 30, 0),
            Latitude = 40.7128,
            Longitude = -74.0060,
            TimezoneOffset = -5
        };

        var chart = ChartCalculator.CalculateChart(demoData);

        if (App.MainAppWindow is MainWindow mainWindow)
        {
            mainWindow.SetChart(chart);
        }

        CurrentBirthDataText.Text = "Your current chart is calculated for the demo profile.";
    }
}
