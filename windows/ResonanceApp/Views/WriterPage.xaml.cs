// =============================================================================
// Resonance UX - Writer Sanctuary Page
// A calm, distraction-free writing environment with RichEditBox,
// focus mode, floating stats, Luminize Prose integration, and Ink support.
// =============================================================================

using Microsoft.UI;
using Microsoft.UI.Input;
using Microsoft.UI.Text;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics;
using System.Numerics;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.Storage;
using Windows.Storage.Pickers;
using Windows.UI;
using Windows.UI.Core;

namespace ResonanceApp.Views
{
    /// <summary>
    /// Writer Sanctuary — a place for thoughtful composition.
    /// The interface strips away everything unnecessary, leaving only
    /// the writer and their words. Focus mode deepens this further.
    /// </summary>
    public sealed partial class WriterPage : Page
    {
        // =====================================================================
        // State
        // =====================================================================
        private bool _isFocusMode;
        private bool _isSidebarOpen;
        private bool _isStatsVisible;
        private WritingSession _currentSession;
        private ObservableCollection<DocumentViewModel> _documents;
        private DispatcherTimer _autoSaveTimer;
        private DispatcherTimer _statsUpdateTimer;
        private DateTime _sessionStartTime;
        private int _wordCountAtSessionStart;

        // =====================================================================
        // UI Elements
        // =====================================================================
        private Grid _rootGrid;
        private SplitView _splitView;
        private RichEditBox _editor;
        private Grid _editorContainer;
        private StackPanel _sidebarContent;
        private ListView _documentList;
        private Grid _statsOverlay;
        private TextBlock _wordCountText;
        private TextBlock _sessionTimeText;
        private TextBlock _readingTimeText;
        private TextBlock _luminizeStatusText;
        private Button _focusModeButton;
        private Button _luminizeButton;
        private InkCanvas _inkCanvas;
        private InkToolbar _inkToolbar;
        private bool _inkModeEnabled;
        private Grid _toolbarPanel;

        // =====================================================================
        // Constructor
        // =====================================================================
        public WriterPage()
        {
            InitializeState();
            BuildLayout();
            StartTimers();
            RegisterShortcuts();
        }

        private void InitializeState()
        {
            _isSidebarOpen = true;
            _isStatsVisible = true;
            _sessionStartTime = DateTime.Now;
            _wordCountAtSessionStart = 0;

            _currentSession = new WritingSession
            {
                StartedAt = DateTime.Now,
                DocumentTitle = "Untitled",
                WordCount = 0,
                TargetWordCount = 1000
            };

            _documents = new ObservableCollection<DocumentViewModel>
            {
                new DocumentViewModel { Title = "On Intentional Design", Excerpt = "The space between elements speaks as loudly as...", WordCount = 2340, LastModified = DateTime.Now.AddHours(-2) },
                new DocumentViewModel { Title = "Protocol Notes: March", Excerpt = "Patient outcomes improved by 23% when the...", WordCount = 1580, LastModified = DateTime.Now.AddDays(-1) },
                new DocumentViewModel { Title = "Letters to the Team", Excerpt = "What I've learned about building calm software...", WordCount = 890, LastModified = DateTime.Now.AddDays(-3) },
                new DocumentViewModel { Title = "Canvas Philosophy", Excerpt = "A canvas does not demand. It receives...", WordCount = 450, LastModified = DateTime.Now.AddDays(-7) },
            };
        }

        // =====================================================================
        // Layout
        // =====================================================================

        private void BuildLayout()
        {
            _rootGrid = new Grid();

            // SplitView: sidebar + editor
            _splitView = new SplitView
            {
                IsPaneOpen = _isSidebarOpen,
                DisplayMode = SplitViewDisplayMode.Inline,
                OpenPaneLength = 280,
                PanePlacement = SplitViewPanePlacement.Left,
                PaneBackground = new SolidColorBrush(Color.FromArgb(
                    App.Current.IsDeepRestMode ? (byte)200 : (byte)240,
                    App.Current.IsDeepRestMode ? (byte)10 : (byte)250,
                    App.Current.IsDeepRestMode ? (byte)28 : (byte)250,
                    App.Current.IsDeepRestMode ? (byte)20 : (byte)248
                ))
            };

            // --- Sidebar ---
            BuildSidebar();

            // --- Editor Area ---
            BuildEditorArea();

            _rootGrid.Children.Add(_splitView);

            // --- Floating Stats Bar ---
            BuildStatsOverlay();
            _rootGrid.Children.Add(_statsOverlay);

            // --- Toolbar ---
            BuildToolbar();
            _rootGrid.Children.Add(_toolbarPanel);

            this.Content = _rootGrid;
        }

        // =====================================================================
        // Sidebar (Document Library)
        // =====================================================================

        private void BuildSidebar()
        {
            _sidebarContent = new StackPanel
            {
                Padding = new Thickness(16, 20, 16, 16),
                Spacing = 16
            };

            // Sidebar header
            var headerStack = new StackPanel { Spacing = 4 };
            headerStack.Children.Add(new TextBlock
            {
                Text = "Library",
                FontSize = 20,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond")
            });
            headerStack.Children.Add(new TextBlock
            {
                Text = $"{_documents.Count} documents",
                FontSize = 12,
                Opacity = 0.5,
                FontFamily = new FontFamily("Manrope")
            });
            _sidebarContent.Children.Add(headerStack);

            // Search box
            var searchBox = new AutoSuggestBox
            {
                PlaceholderText = "Search documents...",
                QueryIcon = new SymbolIcon(Symbol.Find),
                FontFamily = new FontFamily("Manrope"),
                FontSize = 13
            };
            searchBox.TextChanged += OnSearchTextChanged;
            _sidebarContent.Children.Add(searchBox);

            // New document button
            var newDocButton = new Button
            {
                Content = "New Document",
                HorizontalAlignment = HorizontalAlignment.Stretch,
                Style = (Style)Application.Current.Resources["AccentButtonStyle"]
            };
            newDocButton.Click += OnNewDocument;
            _sidebarContent.Children.Add(newDocButton);

            // Document list
            _documentList = new ListView
            {
                ItemsSource = _documents,
                SelectionMode = ListViewSelectionMode.Single,
                Padding = new Thickness(0)
            };

            _documentList.ItemTemplate = CreateDocumentItemTemplate();
            _documentList.SelectionChanged += OnDocumentSelected;
            _sidebarContent.Children.Add(_documentList);

            // Writing stats in sidebar
            var statsSection = new StackPanel
            {
                Spacing = 8,
                Margin = new Thickness(0, 16, 0, 0)
            };
            statsSection.Children.Add(new TextBlock
            {
                Text = "SESSION",
                FontSize = 10,
                CharacterSpacing = 80,
                Opacity = 0.4,
                FontFamily = new FontFamily("Manrope")
            });
            statsSection.Children.Add(CreateSidebarStat("Words today", "0"));
            statsSection.Children.Add(CreateSidebarStat("Session", "0 min"));
            statsSection.Children.Add(CreateSidebarStat("Target", $"{_currentSession.TargetWordCount}"));
            _sidebarContent.Children.Add(statsSection);

            _splitView.Pane = _sidebarContent;
        }

        private DataTemplate CreateDocumentItemTemplate()
        {
            return new DataTemplate(() =>
            {
                var card = new Border
                {
                    Padding = new Thickness(12, 10, 12, 10),
                    Margin = new Thickness(0, 2, 0, 2),
                    CornerRadius = new CornerRadius(8),
                    Background = new SolidColorBrush(Colors.Transparent)
                };

                var stack = new StackPanel { Spacing = 4 };

                var title = new TextBlock
                {
                    FontSize = 13,
                    FontWeight = new Windows.UI.Text.FontWeight(500),
                    FontFamily = new FontFamily("Manrope"),
                    TextTrimming = TextTrimming.CharacterEllipsis
                };

                var excerpt = new TextBlock
                {
                    FontSize = 11,
                    Opacity = 0.5,
                    TextTrimming = TextTrimming.CharacterEllipsis,
                    MaxLines = 2,
                    TextWrapping = TextWrapping.Wrap
                };

                var meta = new StackPanel { Orientation = Orientation.Horizontal, Spacing = 8 };
                var wordCount = new TextBlock { FontSize = 10, Opacity = 0.4 };
                var modified = new TextBlock { FontSize = 10, Opacity = 0.4 };
                meta.Children.Add(wordCount);
                meta.Children.Add(modified);

                stack.Children.Add(title);
                stack.Children.Add(excerpt);
                stack.Children.Add(meta);
                card.Child = stack;

                card.PointerEntered += (s, e) =>
                    card.Background = new SolidColorBrush(Color.FromArgb(20, 197, 160, 89));
                card.PointerExited += (s, e) =>
                    card.Background = new SolidColorBrush(Colors.Transparent);

                return card;
            });
        }

        private StackPanel CreateSidebarStat(string label, string value)
        {
            var sp = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                HorizontalAlignment = HorizontalAlignment.Stretch
            };
            sp.Children.Add(new TextBlock
            {
                Text = label,
                FontSize = 12,
                Opacity = 0.6,
                FontFamily = new FontFamily("Manrope"),
                Width = 100
            });
            sp.Children.Add(new TextBlock
            {
                Text = value,
                FontSize = 12,
                FontFamily = new FontFamily("Manrope"),
                Foreground = new SolidColorBrush(App.ResonanceColors.Gold)
            });
            return sp;
        }

        // =====================================================================
        // Editor Area
        // =====================================================================

        private void BuildEditorArea()
        {
            _editorContainer = new Grid
            {
                Padding = new Thickness(48, 32, 48, 80) // Spacious margins
            };
            _editorContainer.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Title
            _editorContainer.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // Editor

            // Document title
            var titleBox = new TextBox
            {
                Text = _currentSession.DocumentTitle,
                FontSize = 32,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond"),
                BorderThickness = new Thickness(0),
                Background = new SolidColorBrush(Colors.Transparent),
                PlaceholderText = "Untitled",
                Margin = new Thickness(0, 0, 0, 16),
                Padding = new Thickness(0)
            };
            titleBox.TextChanged += (s, e) =>
            {
                _currentSession.DocumentTitle = titleBox.Text;
            };
            Grid.SetRow(titleBox, 0);
            _editorContainer.Children.Add(titleBox);

            // Main editor
            _editor = new RichEditBox
            {
                FontFamily = new FontFamily("Cormorant Garamond"),
                FontSize = 18,
                AcceptsReturn = true,
                IsSpellCheckEnabled = true,
                TextWrapping = TextWrapping.Wrap,
                BorderThickness = new Thickness(0),
                Background = new SolidColorBrush(Colors.Transparent),
                Padding = new Thickness(0),
                VerticalAlignment = VerticalAlignment.Stretch,
                HorizontalAlignment = HorizontalAlignment.Stretch,
                SelectionHighlightColor = new SolidColorBrush(App.ResonanceColors.Gold),
                MaxWidth = 720 // Optimal reading width
            };

            // Set editor formatting
            _editor.Document.SetDefaultCharacterFormat(new Windows.UI.Text.CharacterFormat
            {
                Size = 18
            });

            _editor.TextChanged += OnEditorTextChanged;
            _editor.SelectionChanged += OnEditorSelectionChanged;

            Grid.SetRow(_editor, 1);
            _editorContainer.Children.Add(_editor);

            // Ink layer (for Surface devices)
            _inkCanvas = new InkCanvas
            {
                Visibility = Visibility.Collapsed
            };
            Grid.SetRow(_inkCanvas, 1);
            _editorContainer.Children.Add(_inkCanvas);

            _inkToolbar = new InkToolbar
            {
                TargetInkCanvas = _inkCanvas,
                Visibility = Visibility.Collapsed,
                VerticalAlignment = VerticalAlignment.Top,
                HorizontalAlignment = HorizontalAlignment.Right
            };
            Grid.SetRow(_inkToolbar, 1);
            _editorContainer.Children.Add(_inkToolbar);

            _splitView.Content = _editorContainer;
        }

        // =====================================================================
        // Floating Stats Overlay
        // =====================================================================

        private void BuildStatsOverlay()
        {
            _statsOverlay = new Grid
            {
                VerticalAlignment = VerticalAlignment.Bottom,
                HorizontalAlignment = HorizontalAlignment.Center,
                Margin = new Thickness(0, 0, 0, 20),
                Padding = new Thickness(20, 10, 20, 10),
                CornerRadius = new CornerRadius(20),
                Background = new SolidColorBrush(Color.FromArgb(
                    App.Current.IsDeepRestMode ? (byte)180 : (byte)220,
                    App.Current.IsDeepRestMode ? (byte)10 : (byte)255,
                    App.Current.IsDeepRestMode ? (byte)28 : (byte)255,
                    App.Current.IsDeepRestMode ? (byte)20 : (byte)255
                )),
                Opacity = 0.9,
                Translation = new Vector3(0, 0, 16) // Elevated
            };

            var shadow = new ThemeShadow();
            _statsOverlay.Shadow = shadow;

            var statsStack = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 24
            };

            _wordCountText = new TextBlock
            {
                Text = "0 words",
                FontSize = 12,
                FontFamily = new FontFamily("Manrope"),
                Opacity = 0.7
            };
            statsStack.Children.Add(_wordCountText);

            _sessionTimeText = new TextBlock
            {
                Text = "0 min",
                FontSize = 12,
                FontFamily = new FontFamily("Manrope"),
                Opacity = 0.7
            };
            statsStack.Children.Add(_sessionTimeText);

            _readingTimeText = new TextBlock
            {
                Text = "< 1 min read",
                FontSize = 12,
                FontFamily = new FontFamily("Manrope"),
                Opacity = 0.7
            };
            statsStack.Children.Add(_readingTimeText);

            _luminizeStatusText = new TextBlock
            {
                Text = "",
                FontSize = 12,
                FontFamily = new FontFamily("Manrope"),
                Foreground = new SolidColorBrush(App.ResonanceColors.Gold),
                Opacity = 0.8
            };
            statsStack.Children.Add(_luminizeStatusText);

            _statsOverlay.Children.Add(statsStack);
        }

        // =====================================================================
        // Toolbar
        // =====================================================================

        private void BuildToolbar()
        {
            _toolbarPanel = new Grid
            {
                VerticalAlignment = VerticalAlignment.Top,
                HorizontalAlignment = HorizontalAlignment.Right,
                Margin = new Thickness(0, 8, 16, 0)
            };

            var buttonStack = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 4
            };

            // Sidebar toggle
            var sidebarBtn = CreateToolbarButton("\uE700", "Toggle sidebar");
            sidebarBtn.Click += (s, e) => ToggleSidebar();
            buttonStack.Children.Add(sidebarBtn);

            // Focus mode
            _focusModeButton = CreateToolbarButton("\uE7B8", "Focus mode");
            _focusModeButton.Click += (s, e) => ToggleFocusMode();
            buttonStack.Children.Add(_focusModeButton);

            // Ink mode (for Surface)
            var inkBtn = CreateToolbarButton("\uED63", "Ink mode");
            inkBtn.Click += (s, e) => ToggleInkMode();
            buttonStack.Children.Add(inkBtn);

            // Luminize Prose
            _luminizeButton = CreateToolbarButton("\uE945", "Luminize Prose");
            _luminizeButton.Click += async (s, e) => await LuminizeProse();
            buttonStack.Children.Add(_luminizeButton);

            // More options
            var moreBtn = CreateToolbarButton("\uE712", "More");
            var flyout = new MenuFlyout();
            flyout.Items.Add(new MenuFlyoutItem { Text = "Export as PDF", Icon = new SymbolIcon(Symbol.Page) });
            flyout.Items.Add(new MenuFlyoutItem { Text = "Export as Markdown", Icon = new SymbolIcon(Symbol.Document) });
            flyout.Items.Add(new MenuFlyoutSeparator());
            flyout.Items.Add(new MenuFlyoutItem { Text = "Set word target...", Icon = new SymbolIcon(Symbol.Target) });
            flyout.Items.Add(new MenuFlyoutItem { Text = "Reading view", Icon = new SymbolIcon(Symbol.Read) });
            moreBtn.Flyout = flyout;
            buttonStack.Children.Add(moreBtn);

            _toolbarPanel.Children.Add(buttonStack);
        }

        private Button CreateToolbarButton(string glyph, string tooltip)
        {
            var btn = new Button
            {
                Content = new FontIcon { Glyph = glyph, FontSize = 14 },
                Width = 36,
                Height = 36,
                Padding = new Thickness(0),
                Background = new SolidColorBrush(Colors.Transparent),
                BorderThickness = new Thickness(0),
                CornerRadius = new CornerRadius(8)
            };
            ToolTipService.SetToolTip(btn, tooltip);
            return btn;
        }

        // =====================================================================
        // Focus Mode
        // =====================================================================

        /// <summary>
        /// Focus mode strips everything away: no sidebar, no toolbar, no stats.
        /// Just the writer and the blank page. The window goes full-screen.
        /// Press Escape to return to the sanctuary.
        /// </summary>
        private void ToggleFocusMode()
        {
            _isFocusMode = !_isFocusMode;

            if (_isFocusMode)
            {
                // Enter focus mode
                _splitView.IsPaneOpen = false;
                _splitView.DisplayMode = SplitViewDisplayMode.Overlay;
                _toolbarPanel.Visibility = Visibility.Collapsed;
                _statsOverlay.Opacity = 0.4;

                // Expand editor margins for centered reading experience
                _editorContainer.Padding = new Thickness(120, 60, 120, 100);

                // Request full screen from the app window
                var mainWindow = App.Current.MainWindow;
                mainWindow.AppWindow.SetPresenter(Microsoft.UI.Windowing.AppWindowPresenterKind.FullScreen);

                // Gentle fade transition
                AnimateEditorFocus(true);
            }
            else
            {
                // Exit focus mode
                _splitView.DisplayMode = SplitViewDisplayMode.Inline;
                _splitView.IsPaneOpen = _isSidebarOpen;
                _toolbarPanel.Visibility = Visibility.Visible;
                _statsOverlay.Opacity = 0.9;

                _editorContainer.Padding = new Thickness(48, 32, 48, 80);

                var mainWindow = App.Current.MainWindow;
                mainWindow.AppWindow.SetPresenter(Microsoft.UI.Windowing.AppWindowPresenterKind.Default);

                AnimateEditorFocus(false);
            }
        }

        private void AnimateEditorFocus(bool entering)
        {
            var targetOpacity = entering ? 0.0 : 1.0;
            var editorScale = entering ? 1.02 : 1.0;

            // Brief pulse animation on the editor
            var anim = new DoubleAnimation
            {
                To = 1.0,
                Duration = new Duration(TimeSpan.FromMilliseconds(entering ? 600 : 300)),
                EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
            };
            var sb = new Storyboard();
            sb.Children.Add(anim);
            Storyboard.SetTarget(anim, _editor);
            Storyboard.SetTargetProperty(anim, "Opacity");
            sb.Begin();
        }

        // =====================================================================
        // Ink Support (Surface Devices)
        // =====================================================================

        private void ToggleInkMode()
        {
            _inkModeEnabled = !_inkModeEnabled;

            if (_inkModeEnabled)
            {
                _inkCanvas.Visibility = Visibility.Visible;
                _inkToolbar.Visibility = Visibility.Visible;
                _editor.IsReadOnly = true;

                // Configure ink for handwriting
                var inkPresenter = _inkCanvas.InkPresenter;
                inkPresenter.InputDeviceTypes =
                    CoreInputDeviceTypes.Pen |
                    CoreInputDeviceTypes.Touch;

                var drawingAttributes = new Windows.UI.Input.Inking.InkDrawingAttributes
                {
                    Color = App.Current.IsDeepRestMode
                        ? App.ResonanceColors.DeepRestText
                        : App.ResonanceColors.Green900,
                    Size = new Size(2, 2),
                    IgnorePressure = false,
                    FitToCurve = true
                };
                inkPresenter.UpdateDefaultDrawingAttributes(drawingAttributes);
            }
            else
            {
                _inkCanvas.Visibility = Visibility.Collapsed;
                _inkToolbar.Visibility = Visibility.Collapsed;
                _editor.IsReadOnly = false;
            }
        }

        // =====================================================================
        // Luminize Prose Integration
        // =====================================================================

        /// <summary>
        /// Luminize Prose analyzes the writing and suggests improvements
        /// that align with the Resonance philosophy — clarity over cleverness,
        /// breathing room over density, intention over impulse.
        /// </summary>
        private async Task LuminizeProse()
        {
            _luminizeStatusText.Text = "Luminizing...";
            _luminizeButton.IsEnabled = false;

            try
            {
                // Get editor text
                _editor.Document.GetText(TextGetOptions.None, out string text);

                if (string.IsNullOrWhiteSpace(text))
                {
                    _luminizeStatusText.Text = "Nothing to luminize yet.";
                    return;
                }

                // Simulate AI analysis (in production, this calls the Resonance API)
                await Task.Delay(1500);

                var analysis = AnalyzeProseLocally(text);

                _luminizeStatusText.Text = analysis.Summary;

                // Highlight suggested improvements in the editor
                if (analysis.Suggestions.Count > 0)
                {
                    ShowLuminizeSuggestions(analysis.Suggestions);
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"[Resonance] Luminize error: {ex.Message}");
                _luminizeStatusText.Text = "Luminize unavailable";
            }
            finally
            {
                _luminizeButton.IsEnabled = true;

                // Clear status after a pause
                var timer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(5) };
                timer.Tick += (s, e) =>
                {
                    timer.Stop();
                    _luminizeStatusText.Text = "";
                };
                timer.Start();
            }
        }

        private LuminizeAnalysis AnalyzeProseLocally(string text)
        {
            var words = text.Split(new[] { ' ', '\n', '\r', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            var sentences = text.Split(new[] { '.', '!', '?' }, StringSplitOptions.RemoveEmptyEntries);

            double avgWordsPerSentence = sentences.Length > 0
                ? (double)words.Length / sentences.Length
                : 0;

            var suggestions = new List<LuminizeSuggestion>();

            // Check for overly long sentences
            if (avgWordsPerSentence > 25)
            {
                suggestions.Add(new LuminizeSuggestion
                {
                    Type = "Spaciousness",
                    Message = "Some sentences could breathe more. Consider splitting long thoughts."
                });
            }

            // Check for passive voice indicators
            var passiveWords = new[] { "was", "were", "been", "being", "is", "are" };
            int passiveCount = 0;
            foreach (var word in words)
            {
                if (Array.IndexOf(passiveWords, word.ToLower()) >= 0) passiveCount++;
            }
            if (passiveCount > words.Length * 0.1)
            {
                suggestions.Add(new LuminizeSuggestion
                {
                    Type = "Directness",
                    Message = "Consider more active voice for directness and clarity."
                });
            }

            string summary = suggestions.Count == 0
                ? "Prose looks luminous."
                : $"{suggestions.Count} gentle suggestion{(suggestions.Count > 1 ? "s" : "")}";

            return new LuminizeAnalysis { Summary = summary, Suggestions = suggestions };
        }

        private void ShowLuminizeSuggestions(List<LuminizeSuggestion> suggestions)
        {
            // Show suggestions in a teaching tip attached to the editor
            var tipContent = new StackPanel { Spacing = 8 };
            foreach (var suggestion in suggestions)
            {
                var item = new StackPanel { Spacing = 2 };
                item.Children.Add(new TextBlock
                {
                    Text = suggestion.Type,
                    FontSize = 11,
                    FontWeight = FontWeights.SemiBold,
                    Foreground = new SolidColorBrush(App.ResonanceColors.Gold)
                });
                item.Children.Add(new TextBlock
                {
                    Text = suggestion.Message,
                    FontSize = 12,
                    TextWrapping = TextWrapping.Wrap,
                    Opacity = 0.8
                });
                tipContent.Children.Add(item);
            }

            var teachingTip = new TeachingTip
            {
                Title = "Luminize Prose",
                Content = tipContent,
                PreferredPlacement = TeachingTipPlacementMode.Bottom,
                IsLightDismissEnabled = true,
                Target = _editor
            };

            _rootGrid.Children.Add(teachingTip);
            teachingTip.IsOpen = true;
        }

        // =====================================================================
        // Editor Events
        // =====================================================================

        private void OnEditorTextChanged(object sender, RoutedEventArgs e)
        {
            _editor.Document.GetText(TextGetOptions.None, out string text);
            var words = text.Split(new[] { ' ', '\n', '\r', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            int wordCount = words.Length;

            _currentSession.WordCount = wordCount;
            _wordCountText.Text = $"{wordCount} word{(wordCount != 1 ? "s" : "")}";

            // Reading time (avg 200 wpm)
            int readingMinutes = Math.Max(1, wordCount / 200);
            _readingTimeText.Text = $"{readingMinutes} min read";
        }

        private void OnEditorSelectionChanged(object sender, RoutedEventArgs e)
        {
            // Could update formatting toolbar state here
        }

        // =====================================================================
        // Sidebar and Document Management
        // =====================================================================

        private void ToggleSidebar()
        {
            _isSidebarOpen = !_isSidebarOpen;
            _splitView.IsPaneOpen = _isSidebarOpen;
        }

        private void OnDocumentSelected(object sender, SelectionChangedEventArgs e)
        {
            if (_documentList.SelectedItem is DocumentViewModel doc)
            {
                _currentSession.DocumentTitle = doc.Title;
                // Load document content into editor
                _editor.Document.SetText(TextSetOptions.None, "");
                Debug.WriteLine($"[Resonance] Opening document: {doc.Title}");
            }
        }

        private void OnNewDocument(object sender, RoutedEventArgs e)
        {
            var newDoc = new DocumentViewModel
            {
                Title = "Untitled",
                Excerpt = "",
                WordCount = 0,
                LastModified = DateTime.Now
            };
            _documents.Insert(0, newDoc);
            _documentList.SelectedItem = newDoc;
            _editor.Document.SetText(TextSetOptions.None, "");
        }

        private void OnSearchTextChanged(AutoSuggestBox sender, AutoSuggestBoxTextChangedEventArgs args)
        {
            if (args.Reason == AutoSuggestionBoxTextChangeReason.UserInput)
            {
                var query = sender.Text.ToLower();
                // Filter documents (in production, this would use a proper search index)
                Debug.WriteLine($"[Resonance] Searching documents: {query}");
            }
        }

        // =====================================================================
        // Timers
        // =====================================================================

        private void StartTimers()
        {
            // Auto-save every 30 seconds
            _autoSaveTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(30) };
            _autoSaveTimer.Tick += (s, e) => AutoSave();
            _autoSaveTimer.Start();

            // Update session stats every second
            _statsUpdateTimer = new DispatcherTimer { Interval = TimeSpan.FromSeconds(1) };
            _statsUpdateTimer.Tick += (s, e) => UpdateSessionStats();
            _statsUpdateTimer.Start();
        }

        private void AutoSave()
        {
            Debug.WriteLine("[Resonance] Auto-saving document...");
            // In production: save to local SQLite + queue for sync
        }

        private void UpdateSessionStats()
        {
            var elapsed = DateTime.Now - _sessionStartTime;
            _sessionTimeText.Text = elapsed.TotalMinutes < 60
                ? $"{(int)elapsed.TotalMinutes} min"
                : $"{(int)elapsed.TotalHours}h {elapsed.Minutes}m";
        }

        // =====================================================================
        // Keyboard Shortcuts
        // =====================================================================

        private void RegisterShortcuts()
        {
            var shortcuts = new (Windows.System.VirtualKey Key, Windows.System.VirtualKeyModifiers Mod, Action Handler)[]
            {
                (Windows.System.VirtualKey.B, Windows.System.VirtualKeyModifiers.Control | Windows.System.VirtualKeyModifiers.Shift, ToggleSidebar),
                (Windows.System.VirtualKey.F, Windows.System.VirtualKeyModifiers.Control | Windows.System.VirtualKeyModifiers.Shift, ToggleFocusMode),
                (Windows.System.VirtualKey.L, Windows.System.VirtualKeyModifiers.Control | Windows.System.VirtualKeyModifiers.Shift, async () => await LuminizeProse()),
                (Windows.System.VirtualKey.S, Windows.System.VirtualKeyModifiers.Control, AutoSave),
            };

            foreach (var (key, mod, handler) in shortcuts)
            {
                var accel = new KeyboardAccelerator { Key = key, Modifiers = mod };
                accel.Invoked += (s, e) => { handler(); e.Handled = true; };
                _rootGrid.KeyboardAccelerators.Add(accel);
            }
        }
    }

    // =========================================================================
    // Writer View Models
    // =========================================================================

    public class DocumentViewModel : INotifyPropertyChanged
    {
        public string Title { get; set; }
        public string Excerpt { get; set; }
        public int WordCount { get; set; }
        public DateTime LastModified { get; set; }

        public string FormattedDate => LastModified.ToString("MMM d");

        public event PropertyChangedEventHandler PropertyChanged;
    }

    public class WritingSession
    {
        public DateTime StartedAt { get; set; }
        public string DocumentTitle { get; set; }
        public int WordCount { get; set; }
        public int TargetWordCount { get; set; }
    }

    public class LuminizeAnalysis
    {
        public string Summary { get; set; }
        public List<LuminizeSuggestion> Suggestions { get; set; } = new();
    }

    public class LuminizeSuggestion
    {
        public string Type { get; set; }
        public string Message { get; set; }
        public int StartIndex { get; set; }
        public int Length { get; set; }
    }
}
