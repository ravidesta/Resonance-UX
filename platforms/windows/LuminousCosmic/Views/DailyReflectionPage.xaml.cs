using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// Daily reflection and journaling page with cosmic prompts,
/// mood tracking, and tag-based organization.
/// </summary>
public sealed partial class DailyReflectionPage : Page
{
    private NatalChart? _chart;
    private int _selectedMood;
    private readonly List<ReflectionEntry> _pastEntries = new();

    public DailyReflectionPage()
    {
        this.InitializeComponent();
        LoadSampleEntries();
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
        _chart = e.Parameter as NatalChart;
        PopulatePage();
    }

    private void PopulatePage()
    {
        var moonPhase = ChartCalculator.GetCurrentMoonPhase();

        ContextMoonPhase.Text = moonPhase.PhaseName;
        ContextMoonSign.Text = $"Moon in {moonPhase.MoonSign}";
        ContextDate.Text = DateTime.Now.ToString("MMMM d, yyyy");

        // Set prompt based on moon phase and chart
        PromptText.Text = GetCosmicPrompt(moonPhase);

        PastReflectionsList.ItemsSource = _pastEntries;
    }

    private string GetCosmicPrompt(MoonPhaseInfo moonPhase)
    {
        var sun = _chart?.SunSign?.Sign ?? ZodiacSign.Aries;

        return (moonPhase.Phase, NatalChart.GetElement(sun)) switch
        {
            (MoonPhase.NewMoon, Element.Fire) => "What bold new vision ignites your spirit at this threshold?",
            (MoonPhase.NewMoon, Element.Earth) => "What practical seed are you ready to plant in fertile ground?",
            (MoonPhase.NewMoon, Element.Air) => "What new idea or connection wants to take form in your life?",
            (MoonPhase.NewMoon, Element.Water) => "What intuitive knowing is surfacing from your depths?",
            (MoonPhase.FullMoon, _) => "What has come to fullness? What illumination asks for your attention?",
            (MoonPhase.WaxingCrescent, _) => "What small but meaningful step can you take today toward your intention?",
            (MoonPhase.FirstQuarter, _) => "What challenge before you is actually an invitation to grow?",
            (MoonPhase.WaxingGibbous, _) => "What refinements can you make to align more deeply with your path?",
            (MoonPhase.WaningGibbous, _) => "What gifts of wisdom have you received that you can now share?",
            (MoonPhase.LastQuarter, _) => "What are you gently releasing to make space for what comes next?",
            (MoonPhase.WaningCrescent, _) => "In this quiet space of surrender, what do you notice within?",
            _ => "What is the cosmos whispering to you today?"
        };
    }

    private void MoodButton_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button button && int.TryParse(button.Tag?.ToString(), out int mood))
        {
            _selectedMood = mood;

            // Update button visual states
            var buttons = new[] { Mood1, Mood2, Mood3, Mood4, Mood5 };
            foreach (var btn in buttons)
            {
                if (int.TryParse(btn.Tag?.ToString(), out int btnMood))
                {
                    if (btnMood <= mood)
                    {
                        btn.Background = new Microsoft.UI.Xaml.Media.SolidColorBrush(
                            Theme.ResonanceTheme.GoldPrimary);
                        btn.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(
                            Theme.ResonanceTheme.ForestDeep);
                    }
                    else
                    {
                        btn.Background = new Microsoft.UI.Xaml.Media.SolidColorBrush(
                            Microsoft.UI.Colors.Transparent);
                        btn.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(
                            Theme.ResonanceTheme.GoldPrimary);
                    }
                }
            }
        }
    }

    private async void SaveReflection_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(ReflectionTextBox.Text))
        {
            var dialog = new ContentDialog
            {
                Title = "Empty Reflection",
                Content = "Please write something in your reflection before saving.",
                CloseButtonText = "OK",
                XamlRoot = this.XamlRoot
            };
            await dialog.ShowAsync();
            return;
        }

        var moonPhase = ChartCalculator.GetCurrentMoonPhase();

        var entry = new ReflectionEntry
        {
            Date = DateTime.Today,
            Prompt = PromptText.Text,
            Response = ReflectionTextBox.Text,
            MoodRating = _selectedMood,
            MoonPhase = moonPhase.Phase,
            MoonSign = moonPhase.MoonSign
        };

        // Collect selected tags
        foreach (var child in TagsPanel.Children)
        {
            if (child is ToggleButton toggle && toggle.IsChecked == true)
            {
                entry.Tags.Add(toggle.Content?.ToString() ?? "");
            }
        }

        _pastEntries.Insert(0, entry);
        PastReflectionsList.ItemsSource = null;
        PastReflectionsList.ItemsSource = _pastEntries;

        // Clear form
        ReflectionTextBox.Text = "";
        _selectedMood = 0;

        // Show confirmation
        var confirmDialog = new ContentDialog
        {
            Title = "Reflection Saved",
            Content = "Your cosmic reflection has been preserved in the journal.",
            CloseButtonText = "Continue",
            XamlRoot = this.XamlRoot
        };
        await confirmDialog.ShowAsync();
    }

    private void LoadSampleEntries()
    {
        _pastEntries.AddRange(new[]
        {
            new ReflectionEntry
            {
                Date = DateTime.Today.AddDays(-1),
                Prompt = "What seeds are you planting during this lunar cycle?",
                Response = "I'm planting seeds of patience and self-compassion. The waxing moon reminds me that growth takes time.",
                MoodRating = 4,
                MoonPhase = MoonPhase.WaxingCrescent,
                Tags = new List<string> { "Growth", "Gratitude" }
            },
            new ReflectionEntry
            {
                Date = DateTime.Today.AddDays(-3),
                Prompt = "What bold new vision ignites your spirit?",
                Response = "A creative project that combines art and astronomy. I feel the fire element calling me to express myself more boldly.",
                MoodRating = 5,
                MoonPhase = MoonPhase.NewMoon,
                Tags = new List<string> { "Creativity", "Insight" }
            },
            new ReflectionEntry
            {
                Date = DateTime.Today.AddDays(-7),
                Prompt = "What has come to fullness? What are you ready to release?",
                Response = "The full moon illuminated a pattern of overthinking. I release the need to control outcomes.",
                MoodRating = 3,
                MoonPhase = MoonPhase.FullMoon,
                Tags = new List<string> { "Release", "Challenge" }
            }
        });
    }
}
