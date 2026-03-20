// =============================================================================
// Resonance UX - Daily Flow Page
// Phase timeline (Ascend, Zenith, Descent, Rest), spaciousness metrics,
// task cards with energy indicators, and storyboard animations.
// =============================================================================

using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using Microsoft.UI.Xaml.Shapes;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Numerics;
using Windows.UI;

namespace ResonanceApp.Views
{
    /// <summary>
    /// Daily Flow surfaces the user's day as a natural rhythm rather than
    /// a productivity treadmill. Tasks are organized by energy, not urgency.
    /// The timeline shows where you are in your day's arc.
    /// </summary>
    public sealed partial class DailyFlowPage : Page
    {
        // =====================================================================
        // View Models
        // =====================================================================
        private ObservableCollection<FlowTaskViewModel> _tasks;
        private ObservableCollection<PhaseSegment> _phaseSegments;
        private FlowMetrics _metrics;
        private App.ResonancePhase _activePhase;

        // =====================================================================
        // UI Elements
        // =====================================================================
        private Grid _rootLayout;
        private Grid _timelineContainer;
        private Canvas _timelineCanvas;
        private StackPanel _metricsPanel;
        private ListView _taskListView;
        private TextBlock _phaseTitle;
        private TextBlock _phaseSubtitle;
        private TextBlock _spaciousnessValue;
        private ProgressBar _spaciousnessBar;
        private Grid _addTaskPanel;

        // =====================================================================
        // Constructor
        // =====================================================================
        public DailyFlowPage()
        {
            _activePhase = App.Current.CurrentPhase;
            InitializeViewModels();
            BuildLayout();
            AnimateEntrance();

            App.Current.PhaseChanged += OnPhaseChanged;
            App.Current.DeepRestModeChanged += OnDeepRestChanged;
        }

        // =====================================================================
        // View Model Initialization
        // =====================================================================

        private void InitializeViewModels()
        {
            _phaseSegments = new ObservableCollection<PhaseSegment>
            {
                new PhaseSegment { Phase = App.ResonancePhase.Ascend,  Label = "Ascend",  StartHour = 5,  EndHour = 10, Color = Color.FromArgb(255, 168, 198, 178) },
                new PhaseSegment { Phase = App.ResonancePhase.Zenith,  Label = "Zenith",  StartHour = 10, EndHour = 16, Color = App.ResonanceColors.Gold },
                new PhaseSegment { Phase = App.ResonancePhase.Descent, Label = "Descent", StartHour = 16, EndHour = 21, Color = Color.FromArgb(255, 92, 112, 101) },
                new PhaseSegment { Phase = App.ResonancePhase.Rest,    Label = "Rest",    StartHour = 21, EndHour = 5,  Color = Color.FromArgb(255, 18, 46, 33) },
            };

            _tasks = new ObservableCollection<FlowTaskViewModel>
            {
                new FlowTaskViewModel { Title = "Morning reflection", Domain = "Personal", Energy = EnergyLevel.Low, Phase = App.ResonancePhase.Ascend, IsComplete = true },
                new FlowTaskViewModel { Title = "Deep work: Architecture review", Domain = "Work", Energy = EnergyLevel.High, Phase = App.ResonancePhase.Zenith, IsComplete = false },
                new FlowTaskViewModel { Title = "Write protocol notes", Domain = "Wellness", Energy = EnergyLevel.Medium, Phase = App.ResonancePhase.Zenith, IsComplete = false },
                new FlowTaskViewModel { Title = "Team sync", Domain = "Work", Energy = EnergyLevel.Medium, Phase = App.ResonancePhase.Zenith, IsComplete = false },
                new FlowTaskViewModel { Title = "Read chapter 4", Domain = "Personal", Energy = EnergyLevel.Low, Phase = App.ResonancePhase.Descent, IsComplete = false },
                new FlowTaskViewModel { Title = "Evening walk", Domain = "Personal", Energy = EnergyLevel.Low, Phase = App.ResonancePhase.Descent, IsComplete = false },
            };

            _metrics = new FlowMetrics
            {
                Spaciousness = 0.68,
                TasksPlanned = _tasks.Count,
                TasksComplete = _tasks.Count(t => t.IsComplete),
                FocusMinutesToday = 145,
                CurrentStreak = 3
            };
        }

        // =====================================================================
        // Layout
        // =====================================================================

        private void BuildLayout()
        {
            _rootLayout = new Grid
            {
                Padding = new Thickness(32, 24, 32, 24),
                RowSpacing = 24
            };
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Header
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = new GridLength(140) }); // Timeline
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Metrics
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // Tasks

            // --- Header ---
            var headerPanel = new StackPanel { Spacing = 4 };
            _phaseTitle = new TextBlock
            {
                Text = GetPhaseGreeting(_activePhase),
                FontSize = 28,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond"),
                Foreground = new SolidColorBrush(App.Current.IsDeepRestMode ? App.ResonanceColors.DeepRestText : App.ResonanceColors.Green900)
            };
            _phaseSubtitle = new TextBlock
            {
                Text = GetPhaseWisdom(_activePhase),
                FontSize = 14,
                Opacity = 0.6,
                FontFamily = new FontFamily("Manrope")
            };
            headerPanel.Children.Add(_phaseTitle);
            headerPanel.Children.Add(_phaseSubtitle);
            Grid.SetRow(headerPanel, 0);
            _rootLayout.Children.Add(headerPanel);

            // --- Phase Timeline ---
            BuildTimeline();
            Grid.SetRow(_timelineContainer, 1);
            _rootLayout.Children.Add(_timelineContainer);

            // --- Metrics Bar ---
            BuildMetricsPanel();
            Grid.SetRow(_metricsPanel, 2);
            _rootLayout.Children.Add(_metricsPanel);

            // --- Task List ---
            BuildTaskList();
            Grid.SetRow(_taskListView, 3);
            _rootLayout.Children.Add(_taskListView);

            this.Content = _rootLayout;
        }

        // =====================================================================
        // Phase Timeline
        // =====================================================================

        private void BuildTimeline()
        {
            _timelineContainer = new Grid
            {
                CornerRadius = new CornerRadius(12),
                Padding = new Thickness(20, 16, 20, 16),
                Background = CreateGlassBackground()
            };

            var timelineGrid = new Grid();
            timelineGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Labels
            timelineGrid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(40) }); // Bar
            timelineGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Time marks

            // Phase labels
            var labelsPanel = new Grid();
            labelsPanel.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(5, GridUnitType.Star) });  // Ascend 5h
            labelsPanel.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(6, GridUnitType.Star) });  // Zenith 6h
            labelsPanel.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(5, GridUnitType.Star) });  // Descent 5h
            labelsPanel.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(8, GridUnitType.Star) });  // Rest 8h

            for (int i = 0; i < _phaseSegments.Count; i++)
            {
                var seg = _phaseSegments[i];
                var label = new TextBlock
                {
                    Text = seg.Label,
                    FontSize = 12,
                    FontFamily = new FontFamily("Manrope"),
                    HorizontalAlignment = HorizontalAlignment.Center,
                    Opacity = seg.Phase == _activePhase ? 1.0 : 0.5,
                    FontWeight = seg.Phase == _activePhase ? new Windows.UI.Text.FontWeight(600) : new Windows.UI.Text.FontWeight(400)
                };
                Grid.SetColumn(label, i);
                labelsPanel.Children.Add(label);
            }
            Grid.SetRow(labelsPanel, 0);
            timelineGrid.Children.Add(labelsPanel);

            // Timeline bar with segments
            var barGrid = new Grid { Margin = new Thickness(0, 8, 0, 8) };
            barGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(5, GridUnitType.Star) });
            barGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(6, GridUnitType.Star) });
            barGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(5, GridUnitType.Star) });
            barGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(8, GridUnitType.Star) });

            for (int i = 0; i < _phaseSegments.Count; i++)
            {
                var seg = _phaseSegments[i];
                var segRect = new Border
                {
                    Background = new SolidColorBrush(seg.Color),
                    CornerRadius = new CornerRadius(
                        i == 0 ? 8 : 0,
                        i == _phaseSegments.Count - 1 ? 8 : 0,
                        i == _phaseSegments.Count - 1 ? 8 : 0,
                        i == 0 ? 8 : 0
                    ),
                    Opacity = seg.Phase == _activePhase ? 1.0 : 0.4,
                    Height = seg.Phase == _activePhase ? 28 : 20,
                    VerticalAlignment = VerticalAlignment.Center
                };
                Grid.SetColumn(segRect, i);
                barGrid.Children.Add(segRect);
            }

            // Current time indicator
            var nowHour = DateTime.Now.Hour + DateTime.Now.Minute / 60.0;
            var totalHours = 24.0;
            var nowFraction = ((nowHour - 5 + 24) % 24) / totalHours;
            var nowIndicator = new Ellipse
            {
                Width = 14,
                Height = 14,
                Fill = new SolidColorBrush(App.ResonanceColors.Gold),
                Stroke = new SolidColorBrush(Colors.White),
                StrokeThickness = 2,
                HorizontalAlignment = HorizontalAlignment.Left,
                VerticalAlignment = VerticalAlignment.Center,
                Margin = new Thickness(-7, 0, 0, 0),
                Translation = new Vector3((float)(nowFraction * 800), 0, 0) // Approximate
            };
            barGrid.Children.Add(nowIndicator);

            Grid.SetRow(barGrid, 1);
            timelineGrid.Children.Add(barGrid);

            // Time marks
            var timeMarks = new Grid();
            timeMarks.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(5, GridUnitType.Star) });
            timeMarks.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(6, GridUnitType.Star) });
            timeMarks.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(5, GridUnitType.Star) });
            timeMarks.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(8, GridUnitType.Star) });

            string[] times = { "5 AM", "10 AM", "4 PM", "9 PM" };
            for (int i = 0; i < times.Length; i++)
            {
                var mark = new TextBlock
                {
                    Text = times[i],
                    FontSize = 10,
                    Opacity = 0.4,
                    HorizontalAlignment = HorizontalAlignment.Left
                };
                Grid.SetColumn(mark, i);
                timeMarks.Children.Add(mark);
            }
            Grid.SetRow(timeMarks, 2);
            timelineGrid.Children.Add(timeMarks);

            _timelineContainer.Children.Add(timelineGrid);
        }

        // =====================================================================
        // Metrics Panel
        // =====================================================================

        private void BuildMetricsPanel()
        {
            _metricsPanel = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 16
            };

            // Spaciousness metric (primary)
            var spaciousnessCard = CreateMetricCard("Spaciousness", $"{(int)(_metrics.Spaciousness * 100)}%", true);
            _metricsPanel.Children.Add(spaciousnessCard);

            // Additional metrics
            _metricsPanel.Children.Add(CreateMetricCard("Focus", $"{_metrics.FocusMinutesToday} min", false));
            _metricsPanel.Children.Add(CreateMetricCard("Progress", $"{_metrics.TasksComplete}/{_metrics.TasksPlanned}", false));
            _metricsPanel.Children.Add(CreateMetricCard("Streak", $"{_metrics.CurrentStreak} days", false));
        }

        private Border CreateMetricCard(string label, string value, bool isPrimary)
        {
            var card = new Border
            {
                Background = CreateGlassBackground(),
                CornerRadius = new CornerRadius(10),
                Padding = new Thickness(20, 16, 20, 16),
                MinWidth = 140
            };

            var stack = new StackPanel { Spacing = 4 };

            stack.Children.Add(new TextBlock
            {
                Text = label,
                FontSize = 11,
                FontFamily = new FontFamily("Manrope"),
                Opacity = 0.6,
                CharacterSpacing = 60
            });

            var valueText = new TextBlock
            {
                Text = value,
                FontSize = isPrimary ? 32 : 24,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond"),
                Foreground = isPrimary
                    ? new SolidColorBrush(App.ResonanceColors.Gold)
                    : null
            };
            stack.Children.Add(valueText);

            if (isPrimary)
            {
                _spaciousnessBar = new ProgressBar
                {
                    Value = _metrics.Spaciousness * 100,
                    Maximum = 100,
                    Height = 4,
                    CornerRadius = new CornerRadius(2),
                    Margin = new Thickness(0, 4, 0, 0),
                    Foreground = new SolidColorBrush(App.ResonanceColors.Gold)
                };
                stack.Children.Add(_spaciousnessBar);
            }

            card.Child = stack;

            // Hover animation
            card.PointerEntered += (s, e) =>
            {
                card.Translation = new Vector3(0, -2, 0);
                card.Opacity = 1.0;
            };
            card.PointerExited += (s, e) =>
            {
                card.Translation = new Vector3(0, 0, 0);
            };

            return card;
        }

        // =====================================================================
        // Task List
        // =====================================================================

        private void BuildTaskList()
        {
            _taskListView = new ListView
            {
                ItemsSource = _tasks,
                SelectionMode = ListViewSelectionMode.None,
                Padding = new Thickness(0),
                IsItemClickEnabled = true
            };

            _taskListView.ItemTemplate = CreateTaskDataTemplate();
            _taskListView.ItemClick += OnTaskClicked;
        }

        private DataTemplate CreateTaskDataTemplate()
        {
            // Build the data template in code since we're in code-behind
            // In production, this would be in XAML with x:Bind
            var factory = new DataTemplate(() =>
            {
                var card = new Border
                {
                    Background = CreateGlassBackground(),
                    CornerRadius = new CornerRadius(10),
                    Padding = new Thickness(16, 14, 16, 14),
                    Margin = new Thickness(0, 0, 0, 8)
                };

                var grid = new Grid();
                grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(32) }); // Checkbox
                grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) }); // Content
                grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto }); // Energy
                grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto }); // Domain

                var checkBox = new CheckBox
                {
                    MinWidth = 20,
                    VerticalAlignment = VerticalAlignment.Center
                };
                Grid.SetColumn(checkBox, 0);
                grid.Children.Add(checkBox);

                var titleBlock = new TextBlock
                {
                    FontSize = 14,
                    FontFamily = new FontFamily("Manrope"),
                    VerticalAlignment = VerticalAlignment.Center,
                    Margin = new Thickness(8, 0, 0, 0)
                };
                Grid.SetColumn(titleBlock, 1);
                grid.Children.Add(titleBlock);

                // Energy indicator (colored dot)
                var energyDot = new Ellipse
                {
                    Width = 8,
                    Height = 8,
                    VerticalAlignment = VerticalAlignment.Center,
                    Margin = new Thickness(12, 0, 0, 0)
                };
                Grid.SetColumn(energyDot, 2);
                grid.Children.Add(energyDot);

                // Domain tag
                var domainBadge = new Border
                {
                    CornerRadius = new CornerRadius(4),
                    Padding = new Thickness(8, 2, 8, 2),
                    Margin = new Thickness(8, 0, 0, 0),
                    Background = new SolidColorBrush(Color.FromArgb(20, 197, 160, 89))
                };
                var domainText = new TextBlock
                {
                    FontSize = 10,
                    CharacterSpacing = 40,
                    VerticalAlignment = VerticalAlignment.Center
                };
                domainBadge.Child = domainText;
                Grid.SetColumn(domainBadge, 3);
                grid.Children.Add(domainBadge);

                card.Child = grid;

                // Hover lift effect
                card.PointerEntered += (s, e) =>
                {
                    card.Translation = new Vector3(0, -1, 0);
                };
                card.PointerExited += (s, e) =>
                {
                    card.Translation = new Vector3(0, 0, 0);
                };

                return card;
            });

            return factory;
        }

        private void OnTaskClicked(object sender, ItemClickEventArgs e)
        {
            if (e.ClickedItem is FlowTaskViewModel task)
            {
                task.IsComplete = !task.IsComplete;
                UpdateMetrics();
            }
        }

        private void UpdateMetrics()
        {
            _metrics.TasksComplete = _tasks.Count(t => t.IsComplete);
            // Recalculate spaciousness: more free time = more spacious
            var completionRatio = (double)_metrics.TasksComplete / _metrics.TasksPlanned;
            _metrics.Spaciousness = Math.Min(1.0, 0.4 + completionRatio * 0.5);

            if (_spaciousnessBar != null)
            {
                _spaciousnessBar.Value = _metrics.Spaciousness * 100;
            }
        }

        // =====================================================================
        // Phase Transition Animations
        // =====================================================================

        private void OnPhaseChanged(object sender, App.ResonancePhase newPhase)
        {
            _activePhase = newPhase;
            AnimatePhaseTransition(newPhase);
        }

        private void AnimatePhaseTransition(App.ResonancePhase newPhase)
        {
            // Fade out current content
            var fadeOut = new DoubleAnimation
            {
                To = 0.0,
                Duration = new Duration(TimeSpan.FromMilliseconds(300)),
                EasingFunction = new CubicEase { EasingMode = EasingMode.EaseIn }
            };

            var storyboard = new Storyboard();
            storyboard.Children.Add(fadeOut);
            Storyboard.SetTarget(fadeOut, _rootLayout);
            Storyboard.SetTargetProperty(fadeOut, "Opacity");

            storyboard.Completed += (s, e) =>
            {
                // Update content for new phase
                _phaseTitle.Text = GetPhaseGreeting(newPhase);
                _phaseSubtitle.Text = GetPhaseWisdom(newPhase);

                // Rebuild timeline with new active phase
                _rootLayout.Children.Remove(_timelineContainer);
                BuildTimeline();
                Grid.SetRow(_timelineContainer, 1);
                _rootLayout.Children.Add(_timelineContainer);

                // Fade back in
                var fadeIn = new DoubleAnimation
                {
                    To = 1.0,
                    Duration = new Duration(TimeSpan.FromMilliseconds(400)),
                    EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
                };
                var fadeInStoryboard = new Storyboard();
                fadeInStoryboard.Children.Add(fadeIn);
                Storyboard.SetTarget(fadeIn, _rootLayout);
                Storyboard.SetTargetProperty(fadeIn, "Opacity");
                fadeInStoryboard.Begin();
            };

            storyboard.Begin();
        }

        private void AnimateEntrance()
        {
            _rootLayout.Opacity = 0;
            _rootLayout.Translation = new Vector3(0, 16, 0);

            var timer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(100) };
            timer.Tick += (s, e) =>
            {
                timer.Stop();

                var fadeIn = new DoubleAnimation
                {
                    From = 0, To = 1,
                    Duration = new Duration(TimeSpan.FromMilliseconds(500)),
                    EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
                };
                var sb = new Storyboard();
                sb.Children.Add(fadeIn);
                Storyboard.SetTarget(fadeIn, _rootLayout);
                Storyboard.SetTargetProperty(fadeIn, "Opacity");
                sb.Begin();

                _rootLayout.Translation = new Vector3(0, 0, 0);
            };
            timer.Start();
        }

        private void OnDeepRestChanged(object sender, bool isDeepRest)
        {
            _phaseTitle.Foreground = new SolidColorBrush(
                isDeepRest ? App.ResonanceColors.DeepRestText : App.ResonanceColors.Green900);
        }

        // =====================================================================
        // Helpers
        // =====================================================================

        private Brush CreateGlassBackground()
        {
            if (App.Current.IsDeepRestMode)
            {
                return new SolidColorBrush(Color.FromArgb(40, 255, 255, 255));
            }
            return new SolidColorBrush(Color.FromArgb(180, 255, 255, 255));
        }

        private static string GetPhaseGreeting(App.ResonancePhase phase)
        {
            var hour = DateTime.Now.Hour;
            return phase switch
            {
                App.ResonancePhase.Ascend  => "Good morning",
                App.ResonancePhase.Zenith  => "In your element",
                App.ResonancePhase.Descent => "Winding down",
                App.ResonancePhase.Rest    => "Time to rest",
                _ => "Welcome"
            };
        }

        private static string GetPhaseWisdom(App.ResonancePhase phase)
        {
            return phase switch
            {
                App.ResonancePhase.Ascend  => "Build energy gently. The day will meet you where you are.",
                App.ResonancePhase.Zenith  => "Your focus is sharpest now. Honor it with deep work.",
                App.ResonancePhase.Descent => "Let the day's intensity fade. Reflection over reaction.",
                App.ResonancePhase.Rest    => "Nothing more is needed. Tomorrow will arrive on its own.",
                _ => ""
            };
        }
    }

    // =========================================================================
    // View Models
    // =========================================================================

    public enum EnergyLevel { Low, Medium, High }

    public class FlowTaskViewModel : INotifyPropertyChanged
    {
        private string _title;
        private string _domain;
        private EnergyLevel _energy;
        private App.ResonancePhase _phase;
        private bool _isComplete;

        public string Title
        {
            get => _title;
            set { _title = value; OnPropertyChanged(nameof(Title)); }
        }

        public string Domain
        {
            get => _domain;
            set { _domain = value; OnPropertyChanged(nameof(Domain)); }
        }

        public EnergyLevel Energy
        {
            get => _energy;
            set { _energy = value; OnPropertyChanged(nameof(Energy)); }
        }

        public App.ResonancePhase Phase
        {
            get => _phase;
            set { _phase = value; OnPropertyChanged(nameof(Phase)); }
        }

        public bool IsComplete
        {
            get => _isComplete;
            set { _isComplete = value; OnPropertyChanged(nameof(IsComplete)); }
        }

        public Color EnergyColor => Energy switch
        {
            EnergyLevel.Low    => Color.FromArgb(255, 168, 198, 178),
            EnergyLevel.Medium => App.ResonanceColors.Gold,
            EnergyLevel.High   => Color.FromArgb(255, 200, 120, 80),
            _ => Colors.Gray
        };

        public event PropertyChangedEventHandler PropertyChanged;
        private void OnPropertyChanged(string name) =>
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
    }

    public class PhaseSegment
    {
        public App.ResonancePhase Phase { get; set; }
        public string Label { get; set; }
        public int StartHour { get; set; }
        public int EndHour { get; set; }
        public Color Color { get; set; }
    }

    public class FlowMetrics
    {
        public double Spaciousness { get; set; }
        public int TasksPlanned { get; set; }
        public int TasksComplete { get; set; }
        public int FocusMinutesToday { get; set; }
        public int CurrentStreak { get; set; }
    }
}
