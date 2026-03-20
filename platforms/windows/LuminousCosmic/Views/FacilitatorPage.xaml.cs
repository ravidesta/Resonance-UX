using Microsoft.UI;
using Microsoft.UI.Composition;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using Microsoft.UI.Xaml.Shapes;
using Windows.Media.SpeechRecognition;
using Windows.Media.SpeechSynthesis;
using Windows.UI;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// AI Facilitator page — Cosmic Guide chat interface with voice
/// and text input, animated avatar, acrylic message bubbles,
/// and Windows speech integration.
/// </summary>
public sealed partial class FacilitatorPage : Page
{
    private readonly List<GuideMessage> _messages = new();
    private readonly SpeechSynthesizer _synthesizer = new();
    private SpeechRecognizer? _speechRecognizer;
    private bool _isGuideTyping;
    private bool _isRecording;
    private readonly Random _random = new();
    private readonly DispatcherTimer _typingTimer = new();
    private int _typingDotIndex;

    private static readonly string[] GuideResponses = new[]
    {
        "That\u2019s a wonderful question to sit with. Your chart holds layers of meaning that unfold as you engage with them. The Sun illuminates your core vitality, but it\u2019s the Moon that reveals your emotional depths. What feels most alive for you right now?",
        "I appreciate your curiosity. In the cosmic framework, this moment is colored by the current transits \u2014 inviting you to notice where expansion meets your inner knowing. Rather than seeking a definitive answer, let\u2019s explore what resonates.",
        "There\u2019s something profound in what you\u2019re noticing. The astrological tradition would say you\u2019re touching on themes of your chart\u2019s deeper architecture. Trust your own experience. What does your intuition say?",
        "Growth often begins at the edge of what we know. The cosmos doesn\u2019t give easy answers, but it offers lenses \u2014 ways of seeing that illuminate what we might miss. What part of this feels most essential to you?",
        "Let\u2019s take a gentle look at this together. The current lunar energy supports reflective awareness. This isn\u2019t about forcing insight, but about creating space for it to arrive. Take a breath, and notice what surfaces."
    };

    public FacilitatorPage()
    {
        this.InitializeComponent();
        SetupTypingAnimation();
    }

    // ── Message Handling ──

    private async void SendMessage(string content, bool isVoice = false)
    {
        if (string.IsNullOrWhiteSpace(content)) return;

        // Hide welcome, show message area
        WelcomePanel.Visibility = Visibility.Collapsed;

        // Add user message
        var userMessage = new GuideMessage
        {
            Role = GuideMessageRole.User,
            Content = content.Trim(),
            Timestamp = DateTime.Now,
            IsVoice = isVoice
        };
        _messages.Add(userMessage);
        AddMessageToPanel(userMessage);

        MessageInput.Text = "";

        // Show typing indicator
        ShowTypingIndicator();

        // Simulate guide thinking
        int delay = _random.Next(1000, 2500);
        await Task.Delay(delay);

        // Generate guide response
        string response = GuideResponses[_random.Next(GuideResponses.Length)];
        var guideMessage = new GuideMessage
        {
            Role = GuideMessageRole.Guide,
            Content = response,
            Timestamp = DateTime.Now,
            IsVoice = false
        };
        _messages.Add(guideMessage);

        HideTypingIndicator();
        AddMessageToPanel(guideMessage);

        // Voice playback if enabled
        if (VoiceToggle.IsChecked == true)
        {
            await SpeakResponseAsync(response);
        }

        ScrollToBottom();
    }

    private void AddMessageToPanel(GuideMessage message)
    {
        bool isUser = message.Role == GuideMessageRole.User;

        // Create message bubble with acrylic background
        var bubble = new Border
        {
            MaxWidth = 550,
            HorizontalAlignment = isUser
                ? HorizontalAlignment.Right
                : HorizontalAlignment.Left,
            CornerRadius = new CornerRadius(16),
            Padding = new Thickness(14, 10, 14, 10),
            Margin = new Thickness(0, 0, 0, 4),
            RenderTransform = new TranslateTransform { Y = 12 },
            Opacity = 0
        };

        if (isUser)
        {
            // Gold-tinted acrylic for user
            bubble.Background = new AcrylicBrush
            {
                TintColor = Color.FromArgb(255, 197, 160, 89),
                TintOpacity = 0.12,
                FallbackColor = Color.FromArgb(30, 197, 160, 89)
            };
            bubble.BorderBrush = new SolidColorBrush(
                Color.FromArgb(50, 197, 160, 89));
            bubble.BorderThickness = new Thickness(0.5);
        }
        else
        {
            // Green-tinted acrylic for guide
            bubble.Background = new AcrylicBrush
            {
                TintColor = Color.FromArgb(255, 18, 46, 33),
                TintOpacity = 0.15,
                FallbackColor = Color.FromArgb(20, 18, 46, 33)
            };
            bubble.BorderBrush = new SolidColorBrush(
                Color.FromArgb(40, 138, 156, 145));
            bubble.BorderThickness = new Thickness(0.5);
        }

        // Message content
        var contentPanel = new StackPanel { Spacing = 4 };

        var contentText = new TextBlock
        {
            Text = message.Content,
            FontSize = 14,
            LineHeight = 22,
            TextWrapping = TextWrapping.Wrap,
            Foreground = new SolidColorBrush(
                Theme.ResonanceTheme.TextPrimary),
            IsTextSelectionEnabled = true
        };
        contentPanel.Children.Add(contentText);

        // Timestamp
        var timeText = new TextBlock
        {
            Text = message.Timestamp.ToString("h:mm tt"),
            FontSize = 10,
            Foreground = new SolidColorBrush(
                Theme.ResonanceTheme.TextMuted),
            HorizontalAlignment = isUser
                ? HorizontalAlignment.Right
                : HorizontalAlignment.Left
        };
        contentPanel.Children.Add(timeText);

        bubble.Child = contentPanel;

        // Insert before typing indicator
        int insertIndex = MessagesPanel.Children.IndexOf(TypingIndicator);
        if (insertIndex >= 0)
        {
            MessagesPanel.Children.Insert(insertIndex, bubble);
        }
        else
        {
            MessagesPanel.Children.Add(bubble);
        }

        // Animate in
        AnimateMessageIn(bubble);
    }

    private void AnimateMessageIn(Border bubble)
    {
        var storyboard = new Storyboard();

        // Fade in
        var fadeAnim = new DoubleAnimation
        {
            From = 0,
            To = 1,
            Duration = new Duration(TimeSpan.FromMilliseconds(350)),
            EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
        };
        Storyboard.SetTarget(fadeAnim, bubble);
        Storyboard.SetTargetProperty(fadeAnim, "Opacity");
        storyboard.Children.Add(fadeAnim);

        // Slide up
        var slideAnim = new DoubleAnimation
        {
            From = 12,
            To = 0,
            Duration = new Duration(TimeSpan.FromMilliseconds(400)),
            EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
        };
        Storyboard.SetTarget(slideAnim, bubble.RenderTransform);
        Storyboard.SetTargetProperty(slideAnim, "Y");
        storyboard.Children.Add(slideAnim);

        storyboard.Begin();
    }

    // ── Typing Indicator ──

    private void SetupTypingAnimation()
    {
        _typingTimer.Interval = TimeSpan.FromMilliseconds(300);
        _typingTimer.Tick += (s, e) =>
        {
            var dots = new[] { Dot1, Dot2, Dot3 };
            for (int i = 0; i < dots.Length; i++)
            {
                dots[i].Opacity = i == _typingDotIndex ? 1.0 : 0.4;
                var scale = i == _typingDotIndex ? 1.2 : 0.8;
                dots[i].RenderTransform = new ScaleTransform
                {
                    ScaleX = scale,
                    ScaleY = scale,
                    CenterX = 3.5,
                    CenterY = 3.5
                };
            }
            _typingDotIndex = (_typingDotIndex + 1) % 3;
        };
    }

    private void ShowTypingIndicator()
    {
        _isGuideTyping = true;
        TypingIndicator.Visibility = Visibility.Visible;
        StatusText.Text = "reflecting...";
        StatusText.Visibility = Visibility.Visible;
        _typingDotIndex = 0;
        _typingTimer.Start();
        ScrollToBottom();
    }

    private void HideTypingIndicator()
    {
        _isGuideTyping = false;
        TypingIndicator.Visibility = Visibility.Collapsed;
        StatusText.Visibility = Visibility.Collapsed;
        _typingTimer.Stop();
    }

    // ── Event Handlers ──

    private void Starter_Click(object sender, RoutedEventArgs e)
    {
        if (sender is Button button && button.Tag is string prompt)
        {
            SendMessage(prompt);
        }
    }

    private void SendButton_Click(object sender, RoutedEventArgs e)
    {
        SendMessage(MessageInput.Text);
    }

    private void MessageInput_KeyDown(object sender, KeyRoutedEventArgs e)
    {
        if (e.Key == Windows.System.VirtualKey.Enter && !IsShiftPressed())
        {
            e.Handled = true;
            SendMessage(MessageInput.Text);
        }
    }

    private static bool IsShiftPressed()
    {
        var state = Microsoft.UI.Input.InputKeyboardSource.GetKeyStateForCurrentThread(
            Windows.System.VirtualKey.Shift);
        return state.HasFlag(Windows.UI.Core.CoreVirtualKeyStates.Down);
    }

    private async void MicButton_Click(object sender, RoutedEventArgs e)
    {
        if (_isRecording)
        {
            StopRecording();
            return;
        }

        try
        {
            _speechRecognizer = new SpeechRecognizer();
            await _speechRecognizer.CompileConstraintsAsync();

            _isRecording = true;
            UpdateMicButtonState();

            var result = await _speechRecognizer.RecognizeAsync();

            _isRecording = false;
            UpdateMicButtonState();

            if (result.Status == SpeechRecognitionResultStatus.Success &&
                !string.IsNullOrWhiteSpace(result.Text))
            {
                SendMessage(result.Text, isVoice: true);
            }
        }
        catch
        {
            _isRecording = false;
            UpdateMicButtonState();
        }
        finally
        {
            _speechRecognizer?.Dispose();
            _speechRecognizer = null;
        }
    }

    private void StopRecording()
    {
        _isRecording = false;
        UpdateMicButtonState();
        _speechRecognizer?.Dispose();
        _speechRecognizer = null;
    }

    private void UpdateMicButtonState()
    {
        if (MicButton.Content is TextBlock micIcon)
        {
            micIcon.Foreground = new SolidColorBrush(
                _isRecording
                    ? Theme.ResonanceTheme.GoldPrimary
                    : Theme.ResonanceTheme.TextMuted);
        }
    }

    // ── Speech Synthesis ──

    private async Task SpeakResponseAsync(string text)
    {
        try
        {
            var stream = await _synthesizer.SynthesizeTextToStreamAsync(text);
            var mediaPlayer = new Windows.Media.Playback.MediaPlayer();
            mediaPlayer.Source = Windows.Media.Core.MediaSource.CreateFromStream(
                stream, stream.ContentType);
            mediaPlayer.Play();
        }
        catch
        {
            // Silent fail for speech synthesis
        }
    }

    // ── Helpers ──

    private void ScrollToBottom()
    {
        DispatcherQueue.TryEnqueue(() =>
        {
            ChatScrollViewer.ChangeView(null, ChatScrollViewer.ScrollableHeight, null);
        });
    }
}

// ── Models ──

public enum GuideMessageRole { User, Guide }

public class GuideMessage
{
    public GuideMessageRole Role { get; set; }
    public string Content { get; set; } = "";
    public DateTime Timestamp { get; set; } = DateTime.Now;
    public bool IsVoice { get; set; }
}
