using Microsoft.UI;
using Microsoft.UI.Composition.SystemBackdrops;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Media;
using Windows.UI;
using WinRT.Interop;

namespace LuminousCosmic.Theme;

/// <summary>
/// Manages Resonance UX theme switching between Day (light) and Night (dark) modes.
/// Applies Mica backdrop and adjusts the title bar to match the active theme.
/// </summary>
public sealed class ResonanceTheme
{
    public enum ThemeMode
    {
        Day,
        Night
    }

    private Window? _window;
    private MicaController? _micaController;
    private SystemBackdropConfiguration? _backdropConfig;

    public ThemeMode CurrentMode { get; private set; } = ThemeMode.Day;

    public event EventHandler<ThemeMode>? ThemeChanged;

    // ── Resonance Color Constants ──

    // Day mode
    public static readonly Color DayBackground = ColorFromHex("#FAFAF8");
    public static readonly Color DaySurface = ColorFromHex("#F5F4EE");
    public static readonly Color DayTextPrimary = ColorFromHex("#0A1C14");
    public static readonly Color DayTextSecondary = ColorFromHex("#5C7065");

    // Night mode
    public static readonly Color NightBackground = ColorFromHex("#05100B");
    public static readonly Color NightSurface = ColorFromHex("#0A1C14");
    public static readonly Color NightTextPrimary = ColorFromHex("#FAFAF8");
    public static readonly Color NightTextSecondary = ColorFromHex("#8A9C91");

    // Shared accents
    public static readonly Color GoldPrimary = ColorFromHex("#C5A059");
    public static readonly Color GoldLight = ColorFromHex("#E6D0A1");
    public static readonly Color GoldDark = ColorFromHex("#9A7A3A");
    public static readonly Color ForestDeep = ColorFromHex("#0A1C14");
    public static readonly Color ForestMid = ColorFromHex("#122E21");
    public static readonly Color ForestLight = ColorFromHex("#1B402E");

    public void Initialize(Window window)
    {
        _window = window;
        TrySetMicaBackdrop();
    }

    public void ApplyTheme(ThemeMode mode)
    {
        CurrentMode = mode;

        if (_window?.Content is FrameworkElement rootElement)
        {
            rootElement.RequestedTheme = mode == ThemeMode.Night
                ? ElementTheme.Dark
                : ElementTheme.Light;
        }

        ApplyTitleBarTheme(mode);
        UpdateBackdropTheme(mode);

        ThemeChanged?.Invoke(this, mode);
    }

    public void ToggleTheme()
    {
        ApplyTheme(CurrentMode == ThemeMode.Day ? ThemeMode.Night : ThemeMode.Day);
    }

    private void TrySetMicaBackdrop()
    {
        if (_window == null || !MicaController.IsSupported()) return;

        _backdropConfig = new SystemBackdropConfiguration
        {
            IsInputActive = true
        };

        _micaController = new MicaController
        {
            Kind = MicaKind.Base
        };

        _micaController.SetSystemBackdropConfiguration(_backdropConfig);
        _micaController.AddSystemBackdropTarget(
            _window.As<Microsoft.UI.Composition.SystemBackdrops.ICompositionSupportsSystemBackdrop>());
    }

    private void UpdateBackdropTheme(ThemeMode mode)
    {
        if (_backdropConfig != null)
        {
            _backdropConfig.Theme = mode == ThemeMode.Night
                ? SystemBackdropTheme.Dark
                : SystemBackdropTheme.Light;
        }
    }

    private void ApplyTitleBarTheme(ThemeMode mode)
    {
        if (_window == null) return;

        var titleBar = _window.AppWindow.TitleBar;
        if (titleBar == null) return;

        titleBar.ExtendsContentIntoTitleBar = true;

        if (mode == ThemeMode.Night)
        {
            titleBar.ButtonBackgroundColor = Colors.Transparent;
            titleBar.ButtonForegroundColor = NightTextPrimary;
            titleBar.ButtonHoverBackgroundColor = Color.FromArgb(30, 255, 255, 255);
            titleBar.ButtonHoverForegroundColor = NightTextPrimary;
            titleBar.ButtonInactiveBackgroundColor = Colors.Transparent;
            titleBar.ButtonInactiveForegroundColor = NightTextSecondary;
            titleBar.BackgroundColor = Colors.Transparent;
            titleBar.ForegroundColor = NightTextPrimary;
        }
        else
        {
            titleBar.ButtonBackgroundColor = Colors.Transparent;
            titleBar.ButtonForegroundColor = DayTextPrimary;
            titleBar.ButtonHoverBackgroundColor = Color.FromArgb(20, 0, 0, 0);
            titleBar.ButtonHoverForegroundColor = DayTextPrimary;
            titleBar.ButtonInactiveBackgroundColor = Colors.Transparent;
            titleBar.ButtonInactiveForegroundColor = DayTextSecondary;
            titleBar.BackgroundColor = Colors.Transparent;
            titleBar.ForegroundColor = DayTextPrimary;
        }
    }

    public static Color ColorFromHex(string hex)
    {
        hex = hex.TrimStart('#');
        byte a = 255;
        int offset = 0;

        if (hex.Length == 8)
        {
            a = Convert.ToByte(hex[..2], 16);
            offset = 2;
        }

        byte r = Convert.ToByte(hex.Substring(offset, 2), 16);
        byte g = Convert.ToByte(hex.Substring(offset + 2, 2), 16);
        byte b = Convert.ToByte(hex.Substring(offset + 4, 2), 16);

        return Color.FromArgb(a, r, g, b);
    }

    /// <summary>
    /// Gets the appropriate brush for the current theme.
    /// </summary>
    public SolidColorBrush GetThemedBrush(Color dayColor, Color nightColor)
    {
        return new SolidColorBrush(CurrentMode == ThemeMode.Night ? nightColor : dayColor);
    }
}
