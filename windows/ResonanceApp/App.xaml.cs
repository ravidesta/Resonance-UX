// =============================================================================
// Resonance UX - Windows Native Application Entry Point
// WinUI 3 / .NET MAUI Application with Deep Rest mode detection
// Philosophy: Calm, intentional digital experiences
// =============================================================================

using Microsoft.UI;
using Microsoft.UI.Composition;
using Microsoft.UI.Composition.SystemBackdrops;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using Microsoft.Windows.AppLifecycle;
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using Windows.ApplicationModel;
using Windows.ApplicationModel.Activation;
using Windows.Foundation;
using Windows.Graphics;
using Windows.Storage;
using Windows.UI;
using Windows.UI.ViewManagement;
using WinRT.Interop;

namespace ResonanceApp
{
    /// <summary>
    /// Resonance UX Application — a philosophy-driven experience shell.
    /// Manages lifecycle, theming, Deep Rest mode, and system tray presence.
    /// </summary>
    public partial class App : Application
    {
        // =====================================================================
        // Resonance Design Tokens
        // =====================================================================
        public static class ResonanceColors
        {
            // Light palette
            public static readonly Color LightBase      = Color.FromArgb(255, 250, 250, 248); // #FAFAF8
            public static readonly Color LightSurface   = Color.FromArgb(255, 255, 255, 255); // #FFFFFF
            public static readonly Color Green900       = Color.FromArgb(255, 10,  28,  20);  // #0A1C14
            public static readonly Color Green800       = Color.FromArgb(255, 18,  46,  33);  // #122E21
            public static readonly Color Gold           = Color.FromArgb(255, 197, 160, 89);  // #C5A059
            public static readonly Color TextMuted      = Color.FromArgb(255, 92,  112, 101); // #5C7065

            // Deep Rest (dark) palette
            public static readonly Color DeepRestBase    = Color.FromArgb(255, 5,   16,  11);  // #05100B
            public static readonly Color DeepRestSurface = Color.FromArgb(255, 10,  28,  20);  // #0A1C14
            public static readonly Color DeepRestText    = Color.FromArgb(255, 250, 250, 248); // #FAFAF8
        }

        // =====================================================================
        // Application State
        // =====================================================================
        private MainWindow _mainWindow;
        private bool _isDeepRestMode;
        private DispatcherTimer _phaseMonitorTimer;
        private DispatcherTimer _themeTransitionTimer;
        private double _themeTransitionProgress;
        private bool _isTransitioning;
        private ApplicationDataContainer _localSettings;
        private SystemTrayManager _systemTrayManager;

        public static App Current => (App)Application.Current;
        public MainWindow MainWindow => _mainWindow;
        public bool IsDeepRestMode => _isDeepRestMode;

        public event EventHandler<bool> DeepRestModeChanged;
        public event EventHandler<ResonancePhase> PhaseChanged;

        // =====================================================================
        // Resonance Phase Tracking
        // =====================================================================
        public enum ResonancePhase
        {
            Ascend,   // Morning energy building
            Zenith,   // Peak focus and flow
            Descent,  // Winding down, reflective
            Rest      // Deep rest, minimal stimulation
        }

        public ResonancePhase CurrentPhase { get; private set; }

        // =====================================================================
        // Constructor
        // =====================================================================
        public App()
        {
            this.InitializeComponent();
            this.UnhandledException += OnUnhandledException;

            _localSettings = ApplicationData.Current.LocalSettings;
            _isDeepRestMode = LoadDeepRestPreference();

            InitializePhaseMonitoring();
        }

        // =====================================================================
        // Application Lifecycle
        // =====================================================================
        protected override void OnLaunched(LaunchActivatedEventArgs args)
        {
            _mainWindow = new MainWindow();

            ConfigureWindow(_mainWindow);
            ConfigureTitleBar(_mainWindow);
            ApplyResonanceTheme(_isDeepRestMode, animate: false);
            InitializeSystemTray();

            _mainWindow.Activate();

            // Gentle entrance — the window fades in rather than snapping
            PerformGentleEntrance();
        }

        /// <summary>
        /// Configure the main window with Resonance dimensions and behavior.
        /// </summary>
        private void ConfigureWindow(MainWindow window)
        {
            IntPtr hWnd = WindowNative.GetWindowHandle(window);
            WindowId windowId = Win32Interop.GetWindowIdFromWindow(hWnd);
            AppWindow appWindow = AppWindow.GetFromWindowId(windowId);

            // Set a calm, spacious default size
            appWindow.Resize(new SizeInt32(1440, 900));

            // Center the window on screen
            var displayArea = DisplayArea.GetFromWindowId(windowId, DisplayAreaFallback.Primary);
            if (displayArea != null)
            {
                var centerX = (displayArea.WorkArea.Width - 1440) / 2;
                var centerY = (displayArea.WorkArea.Height - 900) / 2;
                appWindow.Move(new PointInt32(centerX, centerY));
            }

            // Listen for close to support system tray minimization
            appWindow.Closing += OnWindowClosing;

            // Track visibility changes for power-aware behavior
            window.VisibilityChanged += OnWindowVisibilityChanged;
        }

        /// <summary>
        /// Customize the title bar for an immersive Resonance experience.
        /// </summary>
        private void ConfigureTitleBar(MainWindow window)
        {
            IntPtr hWnd = WindowNative.GetWindowHandle(window);
            WindowId windowId = Win32Interop.GetWindowIdFromWindow(hWnd);
            AppWindow appWindow = AppWindow.GetFromWindowId(windowId);

            if (AppWindowTitleBar.IsCustomizationSupported())
            {
                var titleBar = appWindow.TitleBar;
                titleBar.ExtendsContentIntoTitleBar = true;

                // In Deep Rest mode, use dark title bar; otherwise, light
                if (_isDeepRestMode)
                {
                    titleBar.BackgroundColor = ResonanceColors.DeepRestBase;
                    titleBar.ForegroundColor = ResonanceColors.DeepRestText;
                    titleBar.InactiveBackgroundColor = ResonanceColors.DeepRestBase;
                    titleBar.InactiveForegroundColor = ResonanceColors.TextMuted;
                    titleBar.ButtonBackgroundColor = Colors.Transparent;
                    titleBar.ButtonForegroundColor = ResonanceColors.DeepRestText;
                    titleBar.ButtonHoverBackgroundColor = ResonanceColors.DeepRestSurface;
                    titleBar.ButtonHoverForegroundColor = ResonanceColors.Gold;
                    titleBar.ButtonPressedBackgroundColor = ResonanceColors.Green800;
                    titleBar.ButtonPressedForegroundColor = ResonanceColors.Gold;
                }
                else
                {
                    titleBar.BackgroundColor = ResonanceColors.LightBase;
                    titleBar.ForegroundColor = ResonanceColors.Green900;
                    titleBar.InactiveBackgroundColor = ResonanceColors.LightBase;
                    titleBar.InactiveForegroundColor = ResonanceColors.TextMuted;
                    titleBar.ButtonBackgroundColor = Colors.Transparent;
                    titleBar.ButtonForegroundColor = ResonanceColors.Green900;
                    titleBar.ButtonHoverBackgroundColor = ResonanceColors.LightSurface;
                    titleBar.ButtonHoverForegroundColor = ResonanceColors.Gold;
                    titleBar.ButtonPressedBackgroundColor = ResonanceColors.LightBase;
                    titleBar.ButtonPressedForegroundColor = ResonanceColors.Gold;
                }
            }
        }

        // =====================================================================
        // Deep Rest Mode Detection and Management
        // =====================================================================

        /// <summary>
        /// Initialize the phase monitor that tracks time-of-day energy phases.
        /// Transitions between phases should feel natural, not jarring.
        /// </summary>
        private void InitializePhaseMonitoring()
        {
            UpdateCurrentPhase();

            _phaseMonitorTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromMinutes(5)
            };
            _phaseMonitorTimer.Tick += (s, e) =>
            {
                var previousPhase = CurrentPhase;
                UpdateCurrentPhase();

                if (previousPhase != CurrentPhase)
                {
                    PhaseChanged?.Invoke(this, CurrentPhase);

                    // Auto-enter Deep Rest during Rest phase if user prefers
                    if (CurrentPhase == ResonancePhase.Rest && GetAutoDeepRestEnabled())
                    {
                        SetDeepRestMode(true);
                    }
                    else if (CurrentPhase == ResonancePhase.Ascend && _isDeepRestMode && GetAutoDeepRestEnabled())
                    {
                        SetDeepRestMode(false);
                    }
                }
            };
            _phaseMonitorTimer.Start();
        }

        /// <summary>
        /// Determine current energy phase from time of day.
        /// These boundaries are suggestions — future versions will learn the user's rhythm.
        /// </summary>
        private void UpdateCurrentPhase()
        {
            var hour = DateTime.Now.Hour;
            CurrentPhase = hour switch
            {
                >= 5 and < 10  => ResonancePhase.Ascend,
                >= 10 and < 16 => ResonancePhase.Zenith,
                >= 16 and < 21 => ResonancePhase.Descent,
                _              => ResonancePhase.Rest
            };
        }

        /// <summary>
        /// Toggle Deep Rest mode with a smooth theme transition.
        /// Deep Rest reduces visual intensity, shifts to dark palette,
        /// and encourages the user to wind down.
        /// </summary>
        public void SetDeepRestMode(bool enabled)
        {
            if (_isDeepRestMode == enabled) return;

            _isDeepRestMode = enabled;
            SaveDeepRestPreference(enabled);
            ApplyResonanceTheme(enabled, animate: true);
            ConfigureTitleBar(_mainWindow);
            DeepRestModeChanged?.Invoke(this, enabled);

            // Update system tray icon to reflect mode
            _systemTrayManager?.UpdateIcon(enabled);
        }

        // =====================================================================
        // Theme Transitions
        // =====================================================================

        /// <summary>
        /// Apply the Resonance theme. When animated, the transition takes 800ms,
        /// easing gently between light and Deep Rest palettes.
        /// </summary>
        private void ApplyResonanceTheme(bool deepRest, bool animate)
        {
            if (animate && !_isTransitioning)
            {
                _isTransitioning = true;
                _themeTransitionProgress = 0.0;

                _themeTransitionTimer = new DispatcherTimer
                {
                    Interval = TimeSpan.FromMilliseconds(16) // ~60fps
                };
                _themeTransitionTimer.Tick += OnThemeTransitionTick;
                _themeTransitionTimer.Start();
            }
            else if (!animate)
            {
                ApplyThemeImmediate(deepRest);
            }
        }

        private void OnThemeTransitionTick(object sender, object e)
        {
            _themeTransitionProgress += 0.02; // ~50 frames over 800ms

            // Ease-in-out cubic for a calm transition
            double t = _themeTransitionProgress;
            double easedT = t < 0.5
                ? 4 * t * t * t
                : 1 - Math.Pow(-2 * t + 2, 3) / 2;

            if (_themeTransitionProgress >= 1.0)
            {
                _themeTransitionTimer.Stop();
                _themeTransitionTimer = null;
                _isTransitioning = false;
                ApplyThemeImmediate(_isDeepRestMode);
                return;
            }

            // Interpolate theme opacity on an overlay element in MainWindow
            _mainWindow?.SetThemeTransitionOpacity(easedT);
        }

        private void ApplyThemeImmediate(bool deepRest)
        {
            if (_mainWindow == null) return;

            _mainWindow.RequestedTheme = deepRest
                ? ElementTheme.Dark
                : ElementTheme.Light;

            // Update the Mica/Acrylic backdrop
            _mainWindow.SetBackdropForTheme(deepRest);
        }

        // =====================================================================
        // System Tray Integration
        // =====================================================================

        /// <summary>
        /// The system tray icon provides an unobtrusive presence.
        /// It shows the current phase, allows quick Deep Rest toggle,
        /// and surfaces intentional status without demanding attention.
        /// </summary>
        private void InitializeSystemTray()
        {
            _systemTrayManager = new SystemTrayManager(_isDeepRestMode);
            _systemTrayManager.DeepRestToggleRequested += (s, e) =>
            {
                SetDeepRestMode(!_isDeepRestMode);
            };
            _systemTrayManager.ShowWindowRequested += (s, e) =>
            {
                _mainWindow?.Activate();
            };
            _systemTrayManager.Initialize();
        }

        // =====================================================================
        // Gentle Entrance Animation
        // =====================================================================

        /// <summary>
        /// Rather than the window popping into existence, we ease it in.
        /// This sets the tone for the entire Resonance experience.
        /// </summary>
        private async void PerformGentleEntrance()
        {
            if (_mainWindow?.Content is FrameworkElement root)
            {
                root.Opacity = 0;
                root.Translation = new System.Numerics.Vector3(0, 12, 0);

                await Task.Delay(100);

                var compositor = root.DispatcherQueue != null
                    ? Microsoft.UI.Xaml.Media.CompositionTarget.GetCompositorForCurrentThread()
                    : null;

                // Animate opacity
                var fadeAnimation = new DoubleAnimation
                {
                    From = 0,
                    To = 1,
                    Duration = new Duration(TimeSpan.FromMilliseconds(600)),
                    EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
                };

                var storyboard = new Storyboard();
                storyboard.Children.Add(fadeAnimation);
                Storyboard.SetTarget(fadeAnimation, root);
                Storyboard.SetTargetProperty(fadeAnimation, "Opacity");
                storyboard.Begin();

                // Simultaneously animate translation
                var slideAnimation = new Vector3KeyFrameAnimation();
                root.Translation = new System.Numerics.Vector3(0, 0, 0);
            }
        }

        // =====================================================================
        // Window Events
        // =====================================================================

        private void OnWindowClosing(AppWindow sender, AppWindowClosingEventArgs args)
        {
            // Minimize to tray instead of closing, if user prefers
            if (GetMinimizeToTrayEnabled())
            {
                args.Cancel = true;
                _mainWindow?.Hide();
                _systemTrayManager?.ShowBalloon(
                    "Resonance",
                    "Still here, resting quietly in the background.",
                    BalloonIcon.Info
                );
            }
        }

        private void OnWindowVisibilityChanged(object sender, WindowVisibilityChangedEventArgs args)
        {
            if (!args.Visible)
            {
                // Reduce resource usage when hidden
                _phaseMonitorTimer.Interval = TimeSpan.FromMinutes(15);
            }
            else
            {
                _phaseMonitorTimer.Interval = TimeSpan.FromMinutes(5);
                UpdateCurrentPhase();
            }
        }

        private void OnUnhandledException(object sender, Microsoft.UI.Xaml.UnhandledExceptionEventArgs e)
        {
            Debug.WriteLine($"[Resonance] Unhandled exception: {e.Exception}");
            e.Handled = true;
        }

        // =====================================================================
        // Settings Persistence
        // =====================================================================

        private bool LoadDeepRestPreference()
        {
            return _localSettings.Values.TryGetValue("DeepRestMode", out var val) && val is bool b && b;
        }

        private void SaveDeepRestPreference(bool enabled)
        {
            _localSettings.Values["DeepRestMode"] = enabled;
        }

        private bool GetAutoDeepRestEnabled()
        {
            return _localSettings.Values.TryGetValue("AutoDeepRest", out var val) && val is bool b && b;
        }

        private bool GetMinimizeToTrayEnabled()
        {
            if (_localSettings.Values.TryGetValue("MinimizeToTray", out var val) && val is bool b)
                return b;
            return true; // Default to minimizing to tray
        }
    }

    // =========================================================================
    // System Tray Manager
    // =========================================================================

    /// <summary>
    /// Manages the system tray icon and its context menu.
    /// The tray icon is intentionally simple — a small leaf that shifts
    /// color with the current phase.
    /// </summary>
    public class SystemTrayManager
    {
        private bool _isDeepRest;
        private bool _isInitialized;

        public event EventHandler DeepRestToggleRequested;
        public event EventHandler ShowWindowRequested;

        public SystemTrayManager(bool isDeepRest)
        {
            _isDeepRest = isDeepRest;
        }

        public void Initialize()
        {
            // In a production WinUI 3 app, we'd use H.NotifyIcon or
            // direct Win32 Shell_NotifyIcon interop here.
            // This sets up the tray icon with a context menu:
            //   - "Open Resonance"
            //   - "Toggle Deep Rest"
            //   - Separator
            //   - "Set Status..." (intentional status submenu)
            //   - Separator
            //   - "Quit"
            _isInitialized = true;
            Debug.WriteLine("[Resonance] System tray initialized.");
        }

        public void UpdateIcon(bool deepRest)
        {
            _isDeepRest = deepRest;
            // Swap between light and dark tray icons
            Debug.WriteLine($"[Resonance] Tray icon updated. Deep Rest: {deepRest}");
        }

        public void ShowBalloon(string title, string message, BalloonIcon icon)
        {
            if (!_isInitialized) return;
            // Show a calm, non-aggressive notification balloon
            Debug.WriteLine($"[Resonance] Balloon: {title} - {message}");
        }
    }

    public enum BalloonIcon
    {
        None,
        Info,
        Warning
    }
}
