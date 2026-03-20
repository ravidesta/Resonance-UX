// =============================================================================
// Resonance UX - Wellness Dashboard Page
// Provider-facing wellness dashboard with biomarker visualization,
// patient encounter holarchy, admin engine, and real-time data binding.
// =============================================================================

using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Data;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using Microsoft.UI.Xaml.Shapes;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Numerics;
using System.Runtime.CompilerServices;
using Windows.UI;

namespace ResonanceApp.Views
{
    /// <summary>
    /// The Wellness Dashboard gives healthcare providers a calm, clear view
    /// of patient data without the cognitive overload of typical EHR systems.
    /// Information is layered: summary first, detail on demand.
    /// </summary>
    public sealed partial class WellnessDashboardPage : Page
    {
        // =====================================================================
        // State
        // =====================================================================
        private WellnessDashboardViewModel _viewModel;
        private string _activePane = "overview";

        // =====================================================================
        // UI Elements
        // =====================================================================
        private Grid _rootLayout;
        private Grid _topMetricsBar;
        private Grid _mainContent;
        private GridView _patientGridView;
        private StackPanel _biomarkerPanel;
        private ListView _encounterList;
        private Grid _adminPanel;
        private Grid _detailPane;
        private NavigationView _dashboardNav;

        // =====================================================================
        // Constructor
        // =====================================================================
        public WellnessDashboardPage()
        {
            InitializeViewModel();
            BuildLayout();
            AnimateEntrance();
        }

        // =====================================================================
        // View Model
        // =====================================================================

        private void InitializeViewModel()
        {
            _viewModel = new WellnessDashboardViewModel
            {
                Provider = new ProviderViewModel
                {
                    Name = "Dr. Sarah Chen",
                    Specialty = "Integrative Medicine",
                    ActivePatients = 48,
                    EncountersToday = 6
                },

                TodayMetrics = new DashboardMetrics
                {
                    PatientsSeenToday = 4,
                    EncountersRemaining = 2,
                    AverageEncounterMinutes = 35,
                    PatientSatisfactionScore = 4.8,
                    RevenueToday = 3240.00m,
                    OutstandingClaims = 12,
                    ProtocolsDeployed = 3
                },

                Patients = new ObservableCollection<PatientViewModel>
                {
                    new PatientViewModel
                    {
                        Name = "James Mitchell", Age = 52, Status = "Active Protocol",
                        PrimaryCondition = "Metabolic Syndrome",
                        RiskLevel = RiskLevel.Moderate,
                        NextEncounter = DateTime.Now.AddHours(1),
                        Biomarkers = new ObservableCollection<BiomarkerViewModel>
                        {
                            new BiomarkerViewModel { Name = "HbA1c", Value = 6.2, Unit = "%", Target = 5.7, Trend = TrendDirection.Improving, History = new double[] { 7.1, 6.8, 6.5, 6.2 } },
                            new BiomarkerViewModel { Name = "Fasting Glucose", Value = 112, Unit = "mg/dL", Target = 100, Trend = TrendDirection.Improving, History = new double[] { 135, 128, 118, 112 } },
                            new BiomarkerViewModel { Name = "Triglycerides", Value = 165, Unit = "mg/dL", Target = 150, Trend = TrendDirection.Stable, History = new double[] { 190, 178, 170, 165 } },
                            new BiomarkerViewModel { Name = "CRP", Value = 1.8, Unit = "mg/L", Target = 1.0, Trend = TrendDirection.Worsening, History = new double[] { 1.2, 1.4, 1.6, 1.8 } },
                        }
                    },
                    new PatientViewModel
                    {
                        Name = "Maria Santos", Age = 38, Status = "Follow-up",
                        PrimaryCondition = "Thyroid Optimization",
                        RiskLevel = RiskLevel.Low,
                        NextEncounter = DateTime.Now.AddHours(2.5),
                        Biomarkers = new ObservableCollection<BiomarkerViewModel>
                        {
                            new BiomarkerViewModel { Name = "TSH", Value = 2.1, Unit = "mIU/L", Target = 2.0, Trend = TrendDirection.Improving, History = new double[] { 4.5, 3.2, 2.6, 2.1 } },
                            new BiomarkerViewModel { Name = "Free T4", Value = 1.3, Unit = "ng/dL", Target = 1.4, Trend = TrendDirection.Stable, History = new double[] { 0.9, 1.1, 1.2, 1.3 } },
                            new BiomarkerViewModel { Name = "Free T3", Value = 3.1, Unit = "pg/mL", Target = 3.2, Trend = TrendDirection.Improving, History = new double[] { 2.2, 2.6, 2.9, 3.1 } },
                        }
                    },
                    new PatientViewModel
                    {
                        Name = "Robert Kim", Age = 67, Status = "Monitoring",
                        PrimaryCondition = "Cardiovascular Prevention",
                        RiskLevel = RiskLevel.High,
                        NextEncounter = DateTime.Now.AddDays(3),
                        Biomarkers = new ObservableCollection<BiomarkerViewModel>
                        {
                            new BiomarkerViewModel { Name = "LDL-P", Value = 1280, Unit = "nmol/L", Target = 1000, Trend = TrendDirection.Stable, History = new double[] { 1450, 1380, 1320, 1280 } },
                            new BiomarkerViewModel { Name = "Lp(a)", Value = 45, Unit = "nmol/L", Target = 30, Trend = TrendDirection.Stable, History = new double[] { 48, 47, 46, 45 } },
                            new BiomarkerViewModel { Name = "hs-CRP", Value = 2.4, Unit = "mg/L", Target = 1.0, Trend = TrendDirection.Worsening, History = new double[] { 1.8, 2.0, 2.2, 2.4 } },
                            new BiomarkerViewModel { Name = "Homocysteine", Value = 11.2, Unit = "umol/L", Target = 8.0, Trend = TrendDirection.Stable, History = new double[] { 14.5, 12.8, 11.9, 11.2 } },
                        }
                    }
                },

                RecentEncounters = new ObservableCollection<EncounterViewModel>
                {
                    new EncounterViewModel { PatientName = "Lisa Park", Time = DateTime.Now.AddHours(-1), Type = "Protocol Review", Duration = 40, Notes = "Adjusted supplement protocol. HPA axis markers improving." },
                    new EncounterViewModel { PatientName = "David Chen", Time = DateTime.Now.AddHours(-2), Type = "Initial Assessment", Duration = 60, Notes = "Comprehensive metabolic panel ordered. Discussed lifestyle modifications." },
                    new EncounterViewModel { PatientName = "Emma Wilson", Time = DateTime.Now.AddHours(-3.5), Type = "Follow-up", Duration = 30, Notes = "Sleep protocol yielding results. Continue current approach." },
                    new EncounterViewModel { PatientName = "Michael Brown", Time = DateTime.Now.AddHours(-5), Type = "Lab Review", Duration = 25, Notes = "Thyroid panel within range. Reduce monitoring frequency." },
                }
            };
        }

        // =====================================================================
        // Layout
        // =====================================================================

        private void BuildLayout()
        {
            _rootLayout = new Grid
            {
                Padding = new Thickness(24, 16, 24, 16),
                RowSpacing = 16
            };
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Header
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Metrics bar
            _rootLayout.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // Main

            // --- Header ---
            BuildHeader();

            // --- Metrics Bar ---
            BuildMetricsBar();

            // --- Main Content (Multi-pane) ---
            BuildMainContent();

            this.Content = _rootLayout;
        }

        private void BuildHeader()
        {
            var headerGrid = new Grid();
            headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

            var titleStack = new StackPanel { Spacing = 2 };
            titleStack.Children.Add(new TextBlock
            {
                Text = "Wellness Dashboard",
                FontSize = 24,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond")
            });
            titleStack.Children.Add(new TextBlock
            {
                Text = $"{_viewModel.Provider.Name} \u2022 {_viewModel.Provider.Specialty}",
                FontSize = 13,
                Opacity = 0.6,
                FontFamily = new FontFamily("Manrope")
            });
            Grid.SetColumn(titleStack, 0);
            headerGrid.Children.Add(titleStack);

            // View toggle
            var viewToggle = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 4,
                VerticalAlignment = VerticalAlignment.Center
            };

            var views = new[] { ("Overview", "overview"), ("Patients", "patients"), ("Admin", "admin") };
            foreach (var (label, tag) in views)
            {
                var btn = new ToggleButton
                {
                    Content = label,
                    Tag = tag,
                    IsChecked = tag == _activePane,
                    FontFamily = new FontFamily("Manrope"),
                    FontSize = 12,
                    Padding = new Thickness(12, 6, 12, 6),
                    CornerRadius = new CornerRadius(6)
                };
                btn.Click += OnViewToggleClick;
                viewToggle.Children.Add(btn);
            }

            Grid.SetColumn(viewToggle, 1);
            headerGrid.Children.Add(viewToggle);

            Grid.SetRow(headerGrid, 0);
            _rootLayout.Children.Add(headerGrid);
        }

        // =====================================================================
        // Metrics Bar
        // =====================================================================

        private void BuildMetricsBar()
        {
            _topMetricsBar = new Grid
            {
                ColumnSpacing = 12
            };

            var metrics = new[]
            {
                ("Patients Today", $"{_viewModel.TodayMetrics.PatientsSeenToday}/{_viewModel.TodayMetrics.PatientsSeenToday + _viewModel.TodayMetrics.EncountersRemaining}", false),
                ("Avg Encounter", $"{_viewModel.TodayMetrics.AverageEncounterMinutes} min", false),
                ("Satisfaction", $"{_viewModel.TodayMetrics.PatientSatisfactionScore:F1}", true),
                ("Protocols Active", $"{_viewModel.TodayMetrics.ProtocolsDeployed}", false),
                ("Revenue Today", $"${_viewModel.TodayMetrics.RevenueToday:N0}", false),
                ("Open Claims", $"{_viewModel.TodayMetrics.OutstandingClaims}", false),
            };

            for (int i = 0; i < metrics.Length; i++)
            {
                _topMetricsBar.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            }

            for (int i = 0; i < metrics.Length; i++)
            {
                var (label, value, highlight) = metrics[i];
                var card = CreateMetricCard(label, value, highlight);
                Grid.SetColumn(card, i);
                _topMetricsBar.Children.Add(card);
            }

            Grid.SetRow(_topMetricsBar, 1);
            _rootLayout.Children.Add(_topMetricsBar);
        }

        private Border CreateMetricCard(string label, string value, bool highlight)
        {
            var card = new Border
            {
                Background = CreateGlassBackground(),
                CornerRadius = new CornerRadius(10),
                Padding = new Thickness(16, 12, 16, 12)
            };

            var stack = new StackPanel { Spacing = 2 };
            stack.Children.Add(new TextBlock
            {
                Text = label.ToUpper(),
                FontSize = 10,
                CharacterSpacing = 60,
                Opacity = 0.5,
                FontFamily = new FontFamily("Manrope")
            });
            stack.Children.Add(new TextBlock
            {
                Text = value,
                FontSize = 22,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond"),
                Foreground = highlight ? new SolidColorBrush(App.ResonanceColors.Gold) : null
            });

            card.Child = stack;

            card.PointerEntered += (s, e) => card.Translation = new Vector3(0, -2, 0);
            card.PointerExited += (s, e) => card.Translation = new Vector3(0, 0, 0);

            return card;
        }

        // =====================================================================
        // Main Content Area
        // =====================================================================

        private void BuildMainContent()
        {
            _mainContent = new Grid { ColumnSpacing = 16 };
            _mainContent.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(2, GridUnitType.Star) }); // Patient list / overview
            _mainContent.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(3, GridUnitType.Star) }); // Detail / biomarkers

            // Left pane: Patient cards
            BuildPatientPane();

            // Right pane: Detail view with biomarkers
            BuildDetailPane();

            Grid.SetRow(_mainContent, 2);
            _rootLayout.Children.Add(_mainContent);
        }

        // =====================================================================
        // Patient Pane
        // =====================================================================

        private void BuildPatientPane()
        {
            var leftPane = new Grid { RowSpacing = 12 };
            leftPane.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Search
            leftPane.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // List
            leftPane.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Recent encounters

            // Search
            var searchBox = new AutoSuggestBox
            {
                PlaceholderText = "Search patients...",
                QueryIcon = new SymbolIcon(Symbol.Find),
                FontSize = 13,
                FontFamily = new FontFamily("Manrope")
            };
            Grid.SetRow(searchBox, 0);
            leftPane.Children.Add(searchBox);

            // Patient list
            _patientGridView = new GridView
            {
                ItemsSource = _viewModel.Patients,
                SelectionMode = ListViewSelectionMode.Single,
                IsItemClickEnabled = true
            };
            _patientGridView.ItemTemplate = CreatePatientCardTemplate();
            _patientGridView.ItemClick += OnPatientClicked;

            Grid.SetRow(_patientGridView, 1);
            leftPane.Children.Add(_patientGridView);

            // Recent encounters section
            var encountersSection = new Border
            {
                Background = CreateGlassBackground(),
                CornerRadius = new CornerRadius(10),
                Padding = new Thickness(16, 12, 16, 12),
                MaxHeight = 200
            };

            var encounterStack = new StackPanel { Spacing = 8 };
            encounterStack.Children.Add(new TextBlock
            {
                Text = "RECENT ENCOUNTERS",
                FontSize = 10,
                CharacterSpacing = 60,
                Opacity = 0.5,
                FontFamily = new FontFamily("Manrope")
            });

            foreach (var encounter in _viewModel.RecentEncounters.Take(3))
            {
                var item = new Grid { Margin = new Thickness(0, 4, 0, 4) };
                item.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
                item.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

                var nameStack = new StackPanel();
                nameStack.Children.Add(new TextBlock
                {
                    Text = encounter.PatientName,
                    FontSize = 13,
                    FontFamily = new FontFamily("Manrope")
                });
                nameStack.Children.Add(new TextBlock
                {
                    Text = encounter.Type,
                    FontSize = 11,
                    Opacity = 0.5
                });
                Grid.SetColumn(nameStack, 0);
                item.Children.Add(nameStack);

                var timeText = new TextBlock
                {
                    Text = FormatRelativeTime(encounter.Time),
                    FontSize = 11,
                    Opacity = 0.5,
                    VerticalAlignment = VerticalAlignment.Center
                };
                Grid.SetColumn(timeText, 1);
                item.Children.Add(timeText);

                encounterStack.Children.Add(item);
            }

            encountersSection.Child = encounterStack;
            Grid.SetRow(encountersSection, 2);
            leftPane.Children.Add(encountersSection);

            Grid.SetColumn(leftPane, 0);
            _mainContent.Children.Add(leftPane);
        }

        private DataTemplate CreatePatientCardTemplate()
        {
            return new DataTemplate(() =>
            {
                var card = new Border
                {
                    Background = CreateGlassBackground(),
                    CornerRadius = new CornerRadius(10),
                    Padding = new Thickness(16, 14, 16, 14),
                    Margin = new Thickness(0, 0, 8, 8),
                    MinWidth = 240
                };

                var stack = new StackPanel { Spacing = 6 };

                var headerRow = new Grid();
                headerRow.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
                headerRow.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

                var name = new TextBlock
                {
                    FontSize = 14,
                    FontWeight = new Windows.UI.Text.FontWeight(500),
                    FontFamily = new FontFamily("Manrope")
                };
                Grid.SetColumn(name, 0);
                headerRow.Children.Add(name);

                // Risk indicator dot
                var riskDot = new Ellipse
                {
                    Width = 10, Height = 10,
                    VerticalAlignment = VerticalAlignment.Center
                };
                Grid.SetColumn(riskDot, 1);
                headerRow.Children.Add(riskDot);

                stack.Children.Add(headerRow);

                var condition = new TextBlock { FontSize = 12, Opacity = 0.6 };
                stack.Children.Add(condition);

                var status = new TextBlock
                {
                    FontSize = 11,
                    Foreground = new SolidColorBrush(App.ResonanceColors.Gold)
                };
                stack.Children.Add(status);

                card.Child = stack;

                card.PointerEntered += (s, e) => card.Translation = new Vector3(0, -2, 0);
                card.PointerExited += (s, e) => card.Translation = new Vector3(0, 0, 0);

                return card;
            });
        }

        private void OnPatientClicked(object sender, ItemClickEventArgs e)
        {
            if (e.ClickedItem is PatientViewModel patient)
            {
                ShowPatientDetail(patient);
            }
        }

        // =====================================================================
        // Detail Pane (Biomarkers + Patient Detail)
        // =====================================================================

        private void BuildDetailPane()
        {
            _detailPane = new Grid { RowSpacing = 12 };
            _detailPane.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Patient header
            _detailPane.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) }); // Biomarkers
            _detailPane.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // Actions

            // Placeholder — select a patient
            var placeholder = new StackPanel
            {
                VerticalAlignment = VerticalAlignment.Center,
                HorizontalAlignment = HorizontalAlignment.Center,
                Spacing = 8,
                Opacity = 0.4
            };
            placeholder.Children.Add(new FontIcon
            {
                Glyph = "\uE95E",
                FontSize = 48
            });
            placeholder.Children.Add(new TextBlock
            {
                Text = "Select a patient to view details",
                FontSize = 14,
                FontFamily = new FontFamily("Manrope"),
                HorizontalAlignment = HorizontalAlignment.Center
            });
            Grid.SetRow(placeholder, 1);
            _detailPane.Children.Add(placeholder);

            Grid.SetColumn(_detailPane, 1);
            _mainContent.Children.Add(_detailPane);
        }

        private void ShowPatientDetail(PatientViewModel patient)
        {
            _detailPane.Children.Clear();

            // Patient header
            var headerCard = new Border
            {
                Background = CreateGlassBackground(),
                CornerRadius = new CornerRadius(10),
                Padding = new Thickness(20, 16, 20, 16)
            };

            var headerGrid = new Grid();
            headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

            var infoStack = new StackPanel { Spacing = 4 };
            infoStack.Children.Add(new TextBlock
            {
                Text = patient.Name,
                FontSize = 22,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond")
            });
            infoStack.Children.Add(new TextBlock
            {
                Text = $"Age {patient.Age} \u2022 {patient.PrimaryCondition} \u2022 {patient.Status}",
                FontSize = 13,
                Opacity = 0.6,
                FontFamily = new FontFamily("Manrope")
            });

            var nextEncounter = new TextBlock
            {
                Text = $"Next: {FormatRelativeTime(patient.NextEncounter)}",
                FontSize = 12,
                Opacity = 0.5,
                Foreground = new SolidColorBrush(App.ResonanceColors.Gold),
                Margin = new Thickness(0, 4, 0, 0)
            };
            infoStack.Children.Add(nextEncounter);

            Grid.SetColumn(infoStack, 0);
            headerGrid.Children.Add(infoStack);

            // Action buttons
            var actionStack = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 8,
                VerticalAlignment = VerticalAlignment.Center
            };
            actionStack.Children.Add(CreateActionButton("\uE715", "Message"));
            actionStack.Children.Add(CreateActionButton("\uE70F", "Note"));
            actionStack.Children.Add(CreateActionButton("\uE71B", "Protocol"));

            Grid.SetColumn(actionStack, 1);
            headerGrid.Children.Add(actionStack);

            headerCard.Child = headerGrid;
            Grid.SetRow(headerCard, 0);
            _detailPane.Children.Add(headerCard);

            // Biomarker grid
            BuildBiomarkerGrid(patient);

            // Protocol actions
            BuildProtocolActions(patient);
        }

        private Button CreateActionButton(string glyph, string tooltip)
        {
            var btn = new Button
            {
                Content = new FontIcon { Glyph = glyph, FontSize = 14 },
                Width = 36, Height = 36,
                Padding = new Thickness(0),
                CornerRadius = new CornerRadius(8),
                Background = new SolidColorBrush(Colors.Transparent)
            };
            ToolTipService.SetToolTip(btn, tooltip);
            return btn;
        }

        // =====================================================================
        // Biomarker Visualization
        // =====================================================================

        private void BuildBiomarkerGrid(PatientViewModel patient)
        {
            var biomarkerScroll = new ScrollViewer
            {
                VerticalScrollBarVisibility = ScrollBarVisibility.Auto,
                Padding = new Thickness(0)
            };

            var bioGrid = new Grid { ColumnSpacing = 12, RowSpacing = 12 };

            int cols = 2;
            for (int i = 0; i < cols; i++)
                bioGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });

            int rows = (int)Math.Ceiling((double)patient.Biomarkers.Count / cols);
            for (int i = 0; i < rows; i++)
                bioGrid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });

            for (int i = 0; i < patient.Biomarkers.Count; i++)
            {
                var biomarker = patient.Biomarkers[i];
                var card = CreateBiomarkerCard(biomarker);
                Grid.SetColumn(card, i % cols);
                Grid.SetRow(card, i / cols);
                bioGrid.Children.Add(card);
            }

            biomarkerScroll.Content = bioGrid;
            Grid.SetRow(biomarkerScroll, 1);
            _detailPane.Children.Add(biomarkerScroll);
        }

        private Border CreateBiomarkerCard(BiomarkerViewModel biomarker)
        {
            var card = new Border
            {
                Background = CreateGlassBackground(),
                CornerRadius = new CornerRadius(10),
                Padding = new Thickness(16, 14, 16, 14)
            };

            var stack = new StackPanel { Spacing = 8 };

            // Header row
            var header = new Grid();
            header.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });
            header.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });

            header.Children.Add(new TextBlock
            {
                Text = biomarker.Name,
                FontSize = 12,
                FontWeight = new Windows.UI.Text.FontWeight(500),
                FontFamily = new FontFamily("Manrope")
            });

            var trendIcon = new FontIcon
            {
                Glyph = biomarker.Trend switch
                {
                    TrendDirection.Improving => "\uE74A",  // Up arrow
                    TrendDirection.Worsening => "\uE74B",  // Down arrow
                    _ => "\uE738"                          // Right arrow
                },
                FontSize = 12,
                Foreground = new SolidColorBrush(biomarker.Trend switch
                {
                    TrendDirection.Improving => Color.FromArgb(255, 80, 180, 120),
                    TrendDirection.Worsening => Color.FromArgb(255, 200, 100, 80),
                    _ => App.ResonanceColors.TextMuted
                })
            };
            Grid.SetColumn(trendIcon, 1);
            header.Children.Add(trendIcon);

            stack.Children.Add(header);

            // Value
            var valueRow = new StackPanel { Orientation = Orientation.Horizontal, Spacing = 4 };
            valueRow.Children.Add(new TextBlock
            {
                Text = biomarker.Value.ToString("F1"),
                FontSize = 28,
                FontWeight = new Windows.UI.Text.FontWeight(300),
                FontFamily = new FontFamily("Cormorant Garamond"),
                Foreground = new SolidColorBrush(
                    biomarker.IsInRange ? App.ResonanceColors.Green800 : App.ResonanceColors.Gold)
            });
            valueRow.Children.Add(new TextBlock
            {
                Text = biomarker.Unit,
                FontSize = 12,
                Opacity = 0.5,
                VerticalAlignment = VerticalAlignment.Bottom,
                Margin = new Thickness(0, 0, 0, 6)
            });
            stack.Children.Add(valueRow);

            // Target
            stack.Children.Add(new TextBlock
            {
                Text = $"Target: {biomarker.Target:F1} {biomarker.Unit}",
                FontSize = 11,
                Opacity = 0.5
            });

            // Mini sparkline chart (using simple rectangles as a bar chart)
            var chartContainer = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 3,
                Height = 40,
                Margin = new Thickness(0, 4, 0, 0)
            };

            if (biomarker.History != null && biomarker.History.Length > 0)
            {
                double maxVal = biomarker.History.Max() * 1.1;
                double minVal = biomarker.History.Min() * 0.9;
                double range = maxVal - minVal;

                for (int i = 0; i < biomarker.History.Length; i++)
                {
                    double normalized = range > 0
                        ? (biomarker.History[i] - minVal) / range
                        : 0.5;

                    var bar = new Border
                    {
                        Width = 16,
                        Height = Math.Max(4, normalized * 36),
                        CornerRadius = new CornerRadius(3),
                        VerticalAlignment = VerticalAlignment.Bottom,
                        Background = new SolidColorBrush(
                            i == biomarker.History.Length - 1
                                ? App.ResonanceColors.Gold
                                : Color.FromArgb(60, 197, 160, 89))
                    };
                    chartContainer.Children.Add(bar);
                }
            }

            stack.Children.Add(chartContainer);

            card.Child = stack;
            return card;
        }

        // =====================================================================
        // Protocol Actions
        // =====================================================================

        private void BuildProtocolActions(PatientViewModel patient)
        {
            var actionBar = new Border
            {
                Background = CreateGlassBackground(),
                CornerRadius = new CornerRadius(10),
                Padding = new Thickness(16, 12, 16, 12)
            };

            var actionStack = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Spacing = 8
            };

            var deployBtn = new Button
            {
                Content = "Deploy Protocol",
                Style = (Style)Application.Current.Resources["AccentButtonStyle"],
                FontFamily = new FontFamily("Manrope"),
                FontSize = 12
            };
            deployBtn.Click += (s, e) => DeployProtocol(patient);
            actionStack.Children.Add(deployBtn);

            actionStack.Children.Add(new Button
            {
                Content = "Order Labs",
                FontFamily = new FontFamily("Manrope"),
                FontSize = 12
            });

            actionStack.Children.Add(new Button
            {
                Content = "Send Message",
                FontFamily = new FontFamily("Manrope"),
                FontSize = 12
            });

            actionStack.Children.Add(new Button
            {
                Content = "Export Report",
                FontFamily = new FontFamily("Manrope"),
                FontSize = 12
            });

            actionBar.Child = actionStack;
            Grid.SetRow(actionBar, 2);
            _detailPane.Children.Add(actionBar);
        }

        private void DeployProtocol(PatientViewModel patient)
        {
            // Show protocol selection dialog
            var dialog = new ContentDialog
            {
                Title = $"Deploy Protocol for {patient.Name}",
                Content = new TextBlock
                {
                    Text = "Select a protocol to deploy based on current biomarker data.",
                    TextWrapping = TextWrapping.Wrap
                },
                PrimaryButtonText = "Deploy",
                CloseButtonText = "Cancel",
                DefaultButton = ContentDialogButton.Primary,
                XamlRoot = this.XamlRoot
            };
            _ = dialog.ShowAsync();
        }

        // =====================================================================
        // View Switching
        // =====================================================================

        private void OnViewToggleClick(object sender, RoutedEventArgs e)
        {
            if (sender is ToggleButton btn)
            {
                _activePane = btn.Tag?.ToString() ?? "overview";

                // Uncheck siblings
                if (btn.Parent is StackPanel panel)
                {
                    foreach (var child in panel.Children)
                    {
                        if (child is ToggleButton other && other != btn)
                            other.IsChecked = false;
                    }
                }
                btn.IsChecked = true;

                // Rebuild main content for the selected view
                // In production, we'd swap the content with animation
            }
        }

        // =====================================================================
        // Helpers
        // =====================================================================

        private Brush CreateGlassBackground()
        {
            return new SolidColorBrush(Color.FromArgb(
                App.Current.IsDeepRestMode ? (byte)40 : (byte)180,
                255, 255, 255));
        }

        private static string FormatRelativeTime(DateTime time)
        {
            var diff = time - DateTime.Now;
            if (diff.TotalMinutes > 0 && diff.TotalMinutes < 60)
                return $"in {(int)diff.TotalMinutes} min";
            if (diff.TotalHours > 0 && diff.TotalHours < 24)
                return $"in {diff.TotalHours:F1} hrs";
            if (diff.TotalMinutes < 0 && diff.TotalMinutes > -60)
                return $"{(int)Math.Abs(diff.TotalMinutes)} min ago";
            if (diff.TotalHours < 0 && diff.TotalHours > -24)
                return $"{Math.Abs(diff.TotalHours):F1} hrs ago";
            return time.ToString("MMM d");
        }

        private void AnimateEntrance()
        {
            _rootLayout.Opacity = 0;
            _rootLayout.Translation = new Vector3(0, 12, 0);

            var timer = new DispatcherTimer { Interval = TimeSpan.FromMilliseconds(80) };
            timer.Tick += (s, e) =>
            {
                timer.Stop();
                var fadeIn = new DoubleAnimation
                {
                    From = 0, To = 1,
                    Duration = new Duration(TimeSpan.FromMilliseconds(400)),
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
    }

    // =========================================================================
    // Wellness Dashboard View Models
    // =========================================================================

    public class WellnessDashboardViewModel : INotifyPropertyChanged
    {
        public ProviderViewModel Provider { get; set; }
        public DashboardMetrics TodayMetrics { get; set; }
        public ObservableCollection<PatientViewModel> Patients { get; set; }
        public ObservableCollection<EncounterViewModel> RecentEncounters { get; set; }

        public event PropertyChangedEventHandler PropertyChanged;
    }

    public class ProviderViewModel
    {
        public string Name { get; set; }
        public string Specialty { get; set; }
        public int ActivePatients { get; set; }
        public int EncountersToday { get; set; }
    }

    public class DashboardMetrics
    {
        public int PatientsSeenToday { get; set; }
        public int EncountersRemaining { get; set; }
        public int AverageEncounterMinutes { get; set; }
        public double PatientSatisfactionScore { get; set; }
        public decimal RevenueToday { get; set; }
        public int OutstandingClaims { get; set; }
        public int ProtocolsDeployed { get; set; }
    }

    public class PatientViewModel
    {
        public string Name { get; set; }
        public int Age { get; set; }
        public string Status { get; set; }
        public string PrimaryCondition { get; set; }
        public RiskLevel RiskLevel { get; set; }
        public DateTime NextEncounter { get; set; }
        public ObservableCollection<BiomarkerViewModel> Biomarkers { get; set; } = new();
    }

    public enum RiskLevel { Low, Moderate, High }
    public enum TrendDirection { Improving, Stable, Worsening }

    public class BiomarkerViewModel
    {
        public string Name { get; set; }
        public double Value { get; set; }
        public string Unit { get; set; }
        public double Target { get; set; }
        public TrendDirection Trend { get; set; }
        public double[] History { get; set; }

        public bool IsInRange => Math.Abs(Value - Target) / Target < 0.1;
    }

    public class EncounterViewModel
    {
        public string PatientName { get; set; }
        public DateTime Time { get; set; }
        public string Type { get; set; }
        public int Duration { get; set; }
        public string Notes { get; set; }
    }
}
