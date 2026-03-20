using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using LuminousCosmic.Theme;

namespace LuminousCosmic;

/// <summary>
/// Luminous Cosmic Architecture - Application entry point.
/// Manages theme initialization and the main window lifecycle.
/// </summary>
public partial class App : Application
{
    private Window? _window;

    public static ResonanceTheme ThemeManager { get; } = new();

    public static Window? MainAppWindow { get; private set; }

    public App()
    {
        this.InitializeComponent();
    }

    protected override void OnLaunched(LaunchActivatedEventArgs args)
    {
        _window = new MainWindow();
        MainAppWindow = _window;

        // Apply saved theme preference
        ThemeManager.Initialize(_window);
        ThemeManager.ApplyTheme(ThemeManager.CurrentMode);

        _window.Activate();
    }
}
