// =============================================================================
// Resonance UX - Main Window Code-Behind
// NavigationView shell with Mica/Acrylic backdrop, responsive layout,
// and keyboard shortcuts for calm, intentional navigation.
// =============================================================================

using Microsoft.UI;
using Microsoft.UI.Composition;
using Microsoft.UI.Composition.SystemBackdrops;
using Microsoft.UI.Input;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using Microsoft.UI.Xaml.Navigation;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Numerics;
using System.Runtime.InteropServices;
using Windows.System;
using Windows.UI;
using WinRT;

namespace ResonanceApp
{
    /// <summary>
    /// Main window for the Resonance UX ecosystem.
    /// Houses the NavigationView shell, manages backdrop materials,
    /// and orchestrates page transitions with intentional pacing.
    /// </summary>
    public sealed partial class MainWindow : Window
    {
        // =====================================================================
        // Fields
        // =====================================================================
        private MicaController _micaController;
        private DesktopAcrylicController _acrylicController;
        private SystemBackdropConfiguration _backdropConfig;
        private NavigationView _navigationView;
        private Frame _contentFrame;
        private Grid _rootGrid;
        private Grid _themeTransitionOverlay;
        private TextBlock _phaseIndicator;
        private TextBlock _statusIndicator;
        private StackPanel _titleBarContent;
        private double _currentWidth;
        private bool _isCompactMode;
        private readonly Dictionary<string, Type> _pageMap;

        // =====================================================================
        // Constructor
        // =====================================================================
        public MainWindow()
        {
            _pageMap = new Dictionary<string, Type>
            {
                { "Flow",     typeof(Views.DailyFlowPage) },
                { "Focus",    typeof(Views.FocusPage) },
                { "Create",   typeof(Views.WriterPage) },
                { "Letters",  typeof(Views.LettersPage) },
                { "Canvas",   typeof(Views.CanvasPage) },
                { "Wellness", typeof(Views.WellnessDashboardPage) },
                { "Settings", typeof(Views.SettingsPage) }
            };

            BuildLayout();
            SetupBackdrop();
            RegisterKeyboardShortcuts();
            SubscribeToAppEvents();

            this.SizeChanged += OnWindowSizeChanged;
            this.Activated += OnWindowActivated;
        }

        // =====================================================================
        // Layout Construction
        // =====================================================================

        /// <summary>
        /// Build the visual tree programmatically.
        /// The layout is: TitleBar region at top, NavigationView filling the rest.
        /// A translucent overlay sits above everything for theme transitions.
        /// </summary>
        private void BuildLayout()
        {
            _rootGrid = new Grid();
            _rootGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(48) }); // Title bar
            _rootGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });

            // --- Title Bar Region ---
            _titleBarContent = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                VerticalAlignment = VerticalAlignment.Center,
                Padding = new Thickness(16, 0, 0, 0),
                Spacing = 12
            };

            var appIcon = new FontIcon
            {
                Glyph = "\uE790", // Leaf icon
                FontSize = 16,
                Foreground = new SolidColorBrush(App.ResonanceColors.Gold)
            };

            var appTitle = new TextBlock
            {
                Text = "Resonance",
                Style = (Style)Application.Current.Resources["CaptionTextBlockStyle"],
                VerticalAlignment = VerticalAlignment.Center,
                FontWeight = new Windows.UI.Text.FontWeight(500)
            };

            _phaseIndicator = new TextBlock
            {
                Text = GetPhaseDisplayText(App.Current.CurrentPhase),
                FontSize = 11,
                Opacity = 0.6,
                VerticalAlignment = VerticalAlignment.Center,
                Margin = new Thickness(8, 0, 0, 0)
            };

            _statusIndicator = new TextBlock
            {
                Text = "",
                FontSize = 11,
                Opacity = 0.5,
                VerticalAlignment = VerticalAlignment.Center,
                Margin = new Thickness(8, 0, 0, 0),
                Foreground = new SolidColorBrush(App.ResonanceColors.Gold)
            };

            _titleBarContent.Children.Add(appIcon);
            _titleBarContent.Children.Add(appTitle);
            _titleBarContent.Children.Add(_phaseIndicator);
            _titleBarContent.Children.Add(_statusIndicator);

            Grid.SetRow(_titleBarContent, 0);
            _rootGrid.Children.Add(_titleBarContent);

            // Set the title bar drag region
            this.ExtendsContentIntoTitleBar = true;
            this.SetTitleBar(_titleBarContent);

            // --- Navigation View ---
            _navigationView = new NavigationView
            {
                IsBackButtonVisible = NavigationViewBackButtonVisible.Collapsed,
                IsSettingsVisible = true,
                PaneDisplayMode = NavigationViewPaneDisplayMode.Left,
                OpenPaneLength = 240,
                CompactPaneLength = 56,
                IsPaneOpen = true,
                PaneTitle = "",
                IsTabStop = false
            };

            // Navigation items with intentional naming
            _navigationView.MenuItems.Add(CreateNavItem("Flow", "\uE823", "Daily Flow"));
            _navigationView.MenuItems.Add(CreateNavItem("Focus", "\uE7B8", "Focus Sessions"));
            _navigationView.MenuItems.Add(new NavigationViewItemSeparator());
            _navigationView.MenuItems.Add(CreateNavItem("Create", "\uE70F", "Writer Sanctuary"));
            _navigationView.MenuItems.Add(CreateNavItem("Letters", "\uE715", "Letters"));
            _navigationView.MenuItems.Add(CreateNavItem("Canvas", "\uE7AC", "Canvas"));
            _navigationView.MenuItems.Add(new NavigationViewItemSeparator());
            _navigationView.MenuItems.Add(CreateNavItem("Wellness", "\uE95E", "Wellness Dashboard"));

            // Footer items
            var deepRestToggle = new NavigationViewItem
            {
                Content = "Deep Rest",
                Icon = new FontIcon { Glyph = "\uE708" },
                Tag = "DeepRestToggle"
            };
            _navigationView.FooterMenuItems.Add(deepRestToggle);

            // Content frame for page hosting
            _contentFrame = new Frame();
            _contentFrame.Navigated += OnContentNavigated;

            var contentContainer = new Grid
            {
                Padding = new Thickness(0)
            };
            contentContainer.Children.Add(_contentFrame);
            _navigationView.Content = contentContainer;

            _navigationView.SelectionChanged += OnNavigationSelectionChanged;
            _navigationView.DisplayModeChanged += OnNavigationDisplayModeChanged;

            Grid.SetRow(_navigationView, 1);
            _rootGrid.Children.Add(_navigationView);

            // --- Theme Transition Overlay ---
            _themeTransitionOverlay = new Grid
            {
                Background = new SolidColorBrush(Colors.Transparent),
                IsHitTestVisible = false,
                Opacity = 0
            };
            Grid.SetRowSpan(_themeTransitionOverlay, 2);
            _rootGrid.Children.Add(_themeTransitionOverlay);

            this.Content = _rootGrid;

            // Navigate to Daily Flow by default
            _navigationView.SelectedItem = _navigationView.MenuItems[0];
        }

        private NavigationViewItem CreateNavItem(string tag, string glyph, string content)
        {
            return new NavigationViewItem
            {
                Content = content,
                Tag = tag,
                Icon = new FontIcon { Glyph = glyph }
            };
        }

        // =====================================================================
        // Backdrop / Material Setup
        // =====================================================================

        /// <summary>
        /// Set up Mica (preferred) or Acrylic as the window backdrop.
        /// Mica provides that calm, grounded feeling on Windows 11.
        /// Falls back to Acrylic on Windows 10.
        /// </summary>
        private void SetupBackdrop()
        {
            if (MicaController.IsSupported())
            {
                SetupMicaBackdrop();
            }
            else if (DesktopAcrylicController.IsSupported())
            {
                SetupAcrylicBackdrop();
            }
        }

        private void SetupMicaBackdrop()
        {
            _backdropConfig = new SystemBackdropConfiguration();
            _backdropConfig.IsInputActive = true;

            UpdateBackdropTheme();

            _micaController = new MicaController
            {
                Kind = MicaKind.Base
            };
            _micaController.AddSystemBackdropTarget(this.As<ICompositionSupportsSystemBackdrop>());
            _micaController.SetSystemBackdropConfiguration(_backdropConfig);
        }

        private void SetupAcrylicBackdrop()
        {
            _backdropConfig = new SystemBackdropConfiguration();
            _backdropConfig.IsInputActive = true;

            UpdateBackdropTheme();

            _acrylicController = new DesktopAcrylicController
            {
                TintColor = App.Current.IsDeepRestMode
                    ? App.ResonanceColors.DeepRestBase
                    : App.ResonanceColors.LightBase,
                TintOpacity = 0.85f,
                LuminosityOpacity = 0.92f
            };
            _acrylicController.AddSystemBackdropTarget(this.As<ICompositionSupportsSystemBackdrop>());
            _acrylicController.SetSystemBackdropConfiguration(_backdropConfig);
        }

        private void UpdateBackdropTheme()
        {
            if (_backdropConfig == null) return;
            _backdropConfig.Theme = App.Current.IsDeepRestMode
                ? SystemBackdropTheme.Dark
                : SystemBackdropTheme.Light;
        }

        /// <summary>
        /// Called by App during theme transition to update backdrop material.
        /// </summary>
        public void SetBackdropForTheme(bool deepRest)
        {
            UpdateBackdropTheme();

            if (_micaController != null)
            {
                _micaController.Kind = deepRest ? MicaKind.BaseAlt : MicaKind.Base;
            }

            if (_acrylicController != null)
            {
                _acrylicController.TintColor = deepRest
                    ? App.ResonanceColors.DeepRestBase
                    : App.ResonanceColors.LightBase;
            }
        }

        /// <summary>
        /// Called by App during animated theme transition to fade the overlay.
        /// </summary>
        public void SetThemeTransitionOpacity(double progress)
        {
            if (_themeTransitionOverlay == null) return;

            var targetColor = App.Current.IsDeepRestMode
                ? App.ResonanceColors.DeepRestBase
                : App.ResonanceColors.LightBase;

            // Fade the overlay in then out (peak at 0.5 progress)
            double overlayOpacity = progress < 0.5
                ? progress * 2.0 * 0.3
                : (1.0 - progress) * 2.0 * 0.3;

            _themeTransitionOverlay.Background = new SolidColorBrush(targetColor);
            _themeTransitionOverlay.Opacity = overlayOpacity;
        }

        // =====================================================================
        // Navigation
        // =====================================================================

        private void OnNavigationSelectionChanged(NavigationView sender, NavigationViewSelectionChangedEventArgs args)
        {
            if (args.IsSettingsSelected)
            {
                NavigateToPage("Settings");
                return;
            }

            if (args.SelectedItem is NavigationViewItem item)
            {
                var tag = item.Tag?.ToString();

                if (tag == "DeepRestToggle")
                {
                    App.Current.SetDeepRestMode(!App.Current.IsDeepRestMode);
                    return;
                }

                NavigateToPage(tag);
            }
        }

        private void NavigateToPage(string tag)
        {
            if (string.IsNullOrEmpty(tag)) return;

            if (_pageMap.TryGetValue(tag, out var pageType))
            {
                // Use a calm slide transition
                var options = new FrameNavigationOptions
                {
                    TransitionInfoOverride = new SlideNavigationTransitionInfo
                    {
                        Effect = SlideNavigationTransitionEffect.FromRight
                    },
                    IsNavigationStackEnabled = true
                };

                _contentFrame.NavigateToType(pageType, null, options);
            }
        }

        private void OnContentNavigated(object sender, NavigationEventArgs e)
        {
            // Update the visual state of the navigation
            Debug.WriteLine($"[Resonance] Navigated to: {e.SourcePageType.Name}");
        }

        private void OnNavigationDisplayModeChanged(NavigationView sender, NavigationViewDisplayModeChangedEventArgs args)
        {
            // Adjust title bar padding based on nav display mode
            var leftPadding = args.DisplayMode == NavigationViewDisplayMode.Minimal ? 48 : 0;
            _titleBarContent.Padding = new Thickness(16 + leftPadding, 0, 0, 0);
        }

        // =====================================================================
        // Responsive Layout
        // =====================================================================

        private void OnWindowSizeChanged(object sender, WindowSizeChangedEventArgs args)
        {
            _currentWidth = args.Size.Width;

            bool shouldBeCompact = _currentWidth < 768;
            if (shouldBeCompact != _isCompactMode)
            {
                _isCompactMode = shouldBeCompact;
                ApplyResponsiveLayout();
            }
        }

        private void ApplyResponsiveLayout()
        {
            if (_isCompactMode)
            {
                _navigationView.PaneDisplayMode = NavigationViewPaneDisplayMode.LeftMinimal;
                _navigationView.IsPaneOpen = false;
            }
            else if (_currentWidth < 1024)
            {
                _navigationView.PaneDisplayMode = NavigationViewPaneDisplayMode.LeftCompact;
                _navigationView.IsPaneOpen = false;
            }
            else
            {
                _navigationView.PaneDisplayMode = NavigationViewPaneDisplayMode.Left;
                _navigationView.IsPaneOpen = true;
            }
        }

        // =====================================================================
        // Keyboard Shortcuts
        // =====================================================================

        /// <summary>
        /// Register keyboard shortcuts for quick, calm navigation.
        /// Shortcuts use Ctrl+number for tabs and special keys for modes.
        /// </summary>
        private void RegisterKeyboardShortcuts()
        {
            // We register accelerators on the root grid
            var shortcuts = new (VirtualKey Key, VirtualKeyModifiers Mod, Action Handler)[]
            {
                (VirtualKey.Number1, VirtualKeyModifiers.Control, () => SelectNavByTag("Flow")),
                (VirtualKey.Number2, VirtualKeyModifiers.Control, () => SelectNavByTag("Focus")),
                (VirtualKey.Number3, VirtualKeyModifiers.Control, () => SelectNavByTag("Create")),
                (VirtualKey.Number4, VirtualKeyModifiers.Control, () => SelectNavByTag("Letters")),
                (VirtualKey.Number5, VirtualKeyModifiers.Control, () => SelectNavByTag("Canvas")),
                (VirtualKey.Number6, VirtualKeyModifiers.Control, () => SelectNavByTag("Wellness")),
                (VirtualKey.D,      VirtualKeyModifiers.Control | VirtualKeyModifiers.Shift, () => App.Current.SetDeepRestMode(!App.Current.IsDeepRestMode)),
                (VirtualKey.F11,    VirtualKeyModifiers.None, ToggleFullScreen),
                (VirtualKey.Escape, VirtualKeyModifiers.None, ExitFullScreenOrFocusMode),
            };

            foreach (var (key, mod, handler) in shortcuts)
            {
                var accel = new KeyboardAccelerator
                {
                    Key = key,
                    Modifiers = mod
                };
                accel.Invoked += (s, e) =>
                {
                    handler();
                    e.Handled = true;
                };
                _rootGrid.KeyboardAccelerators.Add(accel);
            }
        }

        private void SelectNavByTag(string tag)
        {
            foreach (var item in _navigationView.MenuItems)
            {
                if (item is NavigationViewItem navItem && navItem.Tag?.ToString() == tag)
                {
                    _navigationView.SelectedItem = navItem;
                    return;
                }
            }
        }

        private void ToggleFullScreen()
        {
            var presenter = this.AppWindow.Presenter;
            if (presenter.Kind == AppWindowPresenterKind.FullScreen)
            {
                this.AppWindow.SetPresenter(AppWindowPresenterKind.Default);
                _navigationView.IsPaneVisible = true;
            }
            else
            {
                this.AppWindow.SetPresenter(AppWindowPresenterKind.FullScreen);
                _navigationView.IsPaneVisible = false;
            }
        }

        private void ExitFullScreenOrFocusMode()
        {
            if (this.AppWindow.Presenter.Kind == AppWindowPresenterKind.FullScreen)
            {
                this.AppWindow.SetPresenter(AppWindowPresenterKind.Default);
                _navigationView.IsPaneVisible = true;
            }
        }

        // =====================================================================
        // App Event Subscriptions
        // =====================================================================

        private void SubscribeToAppEvents()
        {
            App.Current.PhaseChanged += OnPhaseChanged;
            App.Current.DeepRestModeChanged += OnDeepRestModeChanged;
        }

        private void OnPhaseChanged(object sender, App.ResonancePhase phase)
        {
            _phaseIndicator.Text = GetPhaseDisplayText(phase);
        }

        private void OnDeepRestModeChanged(object sender, bool isDeepRest)
        {
            _statusIndicator.Text = isDeepRest ? "Deep Rest" : "";
        }

        private void OnWindowActivated(object sender, WindowActivatedEventArgs args)
        {
            if (_backdropConfig != null)
            {
                _backdropConfig.IsInputActive = args.WindowActivationState != WindowActivationState.Deactivated;
            }
        }

        // =====================================================================
        // Helpers
        // =====================================================================

        private static string GetPhaseDisplayText(App.ResonancePhase phase)
        {
            return phase switch
            {
                App.ResonancePhase.Ascend  => "Ascending",
                App.ResonancePhase.Zenith  => "At Zenith",
                App.ResonancePhase.Descent => "Descending",
                App.ResonancePhase.Rest    => "Resting",
                _ => ""
            };
        }

        public new ElementTheme RequestedTheme
        {
            set
            {
                if (Content is FrameworkElement fe)
                {
                    fe.RequestedTheme = value;
                }
            }
        }

        public void Hide()
        {
            // Minimize to tray — hide the window
            var hWnd = WinRT.Interop.WindowNative.GetWindowHandle(this);
            ShowWindow(hWnd, 0); // SW_HIDE
        }

        [DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
}
