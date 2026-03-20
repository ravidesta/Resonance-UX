using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Navigation;
using LuminousCosmic.Models;

namespace LuminousCosmic.Views;

/// <summary>
/// Chapter library with two-pane layout: browsable chapter list and reading pane.
/// </summary>
public sealed partial class ChapterLibraryPage : Page
{
    private List<CosmicChapter> _allChapters = new();
    private List<CosmicChapter> _filteredChapters = new();
    private int _currentIndex = -1;

    public ChapterLibraryPage()
    {
        this.InitializeComponent();
        LoadChapters();
        _filteredChapters = new List<CosmicChapter>(_allChapters);
        ChapterListView.ItemsSource = _filteredChapters;
    }

    protected override void OnNavigatedTo(NavigationEventArgs e)
    {
        base.OnNavigatedTo(e);
    }

    private void CategoryFilter_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (CategoryFilter.SelectedItem is ComboBoxItem item)
        {
            string tag = item.Tag?.ToString() ?? "All";
            _filteredChapters = tag == "All"
                ? new List<CosmicChapter>(_allChapters)
                : _allChapters.Where(c => c.Category == tag).ToList();

            ChapterListView.ItemsSource = _filteredChapters;
        }
    }

    private void ChapterListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (ChapterListView.SelectedItem is CosmicChapter chapter)
        {
            _currentIndex = _filteredChapters.IndexOf(chapter);
            DisplayChapter(chapter);
        }
    }

    private void DisplayChapter(CosmicChapter chapter)
    {
        EmptyState.Visibility = Visibility.Collapsed;
        ContentPane.Visibility = Visibility.Visible;

        ReadingCategory.Text = chapter.Category.ToUpperInvariant();
        ReadingTitle.Text = $"Chapter {chapter.Number}: {chapter.Title}";
        ReadingSubtitle.Text = chapter.Subtitle;
        ReadingContent.Text = chapter.Content;

        // Mark as partially read
        if (chapter.ReadingProgress < 0.1)
        {
            chapter.ReadingProgress = 0.1;
        }
    }

    private void PreviousChapter_Click(object sender, RoutedEventArgs e)
    {
        if (_currentIndex > 0)
        {
            _currentIndex--;
            ChapterListView.SelectedIndex = _currentIndex;
        }
    }

    private void NextChapter_Click(object sender, RoutedEventArgs e)
    {
        if (_currentIndex < _filteredChapters.Count - 1)
        {
            _currentIndex++;
            ChapterListView.SelectedIndex = _currentIndex;

            // Mark previous chapter as fully read
            if (_currentIndex > 0)
            {
                _filteredChapters[_currentIndex - 1].ReadingProgress = 1.0;
            }
        }
    }

    private void LoadChapters()
    {
        _allChapters = new List<CosmicChapter>
        {
            new()
            {
                Number = 1,
                Title = "The Luminous Blueprint",
                Subtitle = "Understanding Your Cosmic Architecture",
                Category = "Foundations",
                ReadingProgress = 1.0,
                Content = "Every soul arrives with a luminous blueprint -- a cosmic architecture encoded at the moment of first breath. This is your natal chart: not a sentence written in the stars, but a map of potentials, a living mandala of your deepest nature.\n\n" +
                          "The natal chart is a snapshot of the heavens at your birth moment, capturing the positions of the Sun, Moon, and planets against the backdrop of the zodiac. It is arranged as a wheel divided into twelve houses, each governing a domain of human experience.\n\n" +
                          "To read this map is not to predict fate, but to illuminate the terrain of your inner landscape. Each planet represents a fundamental drive or faculty of consciousness. Each sign colors that drive with particular qualities. Each house places that energy in a specific area of life.\n\n" +
                          "As you explore your chart, remember: you are not the map. You are the territory itself -- vast, mysterious, and ever-evolving. The chart simply helps you navigate with greater awareness and intention.\n\n" +
                          "In the chapters that follow, we will journey through each layer of your cosmic architecture, from the radiant core of the Sun to the transcendent depths of the outer planets. Welcome to the luminous path."
            },
            new()
            {
                Number = 2,
                Title = "The Solar Core",
                Subtitle = "Your Sun Sign and Essential Identity",
                Category = "Planets",
                AssociatedPlanet = Planet.Sun,
                ReadingProgress = 0.6,
                Content = "The Sun is the heart of your chart -- the central fire around which all other energies orbit. It represents your essential identity, your core vitality, and the creative force that animates your being.\n\n" +
                          "Your Sun sign describes the fundamental quality of your consciousness. It is not merely a personality type, but a mode of being, a way of radiating your unique light into the world. When you are living in alignment with your Sun, you feel vital, purposeful, and authentically yourself.\n\n" +
                          "The house placement of your Sun reveals the life arena where this solar energy seeks its fullest expression. A Sun in the 10th house pours its radiance into career and public life. A Sun in the 4th house illuminates the private realm of home and inner foundation.\n\n" +
                          "The aspects your Sun makes to other planets create a complex web of energetic dialogue. A Sun conjunct Jupiter expands the solar nature with optimism and vision. A Sun square Saturn may challenge it with lessons of discipline and patience.\n\n" +
                          "To honor your Sun is to commit to becoming more fully yourself -- not the self that others expect, but the self that burns at your luminous center."
            },
            new()
            {
                Number = 3,
                Title = "The Lunar Mirror",
                Subtitle = "Your Moon Sign and Emotional Nature",
                Category = "Planets",
                AssociatedPlanet = Planet.Moon,
                ReadingProgress = 0.3,
                Content = "If the Sun is the light you shine, the Moon is the light you reflect. Your Moon sign reveals your emotional nature, your instinctual responses, and the inner world that only those closest to you may glimpse.\n\n" +
                          "The Moon governs your needs -- for security, comfort, belonging, and emotional nourishment. It is the part of you that existed before words, before thought, in the primal realm of feeling and sensation.\n\n" +
                          "A Moon in Water signs (Cancer, Scorpio, Pisces) creates deep emotional currents and powerful intuition. A Moon in Air signs (Gemini, Libra, Aquarius) processes feelings through the mind and through connection. A Moon in Fire signs (Aries, Leo, Sagittarius) needs action and inspiration. A Moon in Earth signs (Taurus, Virgo, Capricorn) seeks tangible comfort and practical stability.\n\n" +
                          "Understanding your Moon is understanding your inner child -- the part of you that still needs to be held, seen, and reassured. When you nurture your Moon, you build an unshakable emotional foundation from which your Sun can shine."
            },
            new()
            {
                Number = 4,
                Title = "The Rising Mask",
                Subtitle = "Your Ascendant and World Interface",
                Category = "Foundations",
                ReadingProgress = 0.0,
                Content = "The Ascendant -- or Rising sign -- is the sign that was ascending over the eastern horizon at your moment of birth. It is the doorway through which you entered this life, and it shapes how you meet the world and how the world meets you.\n\n" +
                          "Unlike the Sun (your essential self) or the Moon (your emotional self), the Ascendant is your interface self -- the lens through which you filter experience and the face you present to others. It is not a mask in the sense of being false; rather, it is the particular style of your engagement with reality.\n\n" +
                          "The Ascendant sets the entire structure of your house system, determining which areas of life are emphasized and how the energies of your chart distribute themselves across your existence.\n\n" +
                          "Your Ascendant ruler -- the planet that governs your rising sign -- becomes one of the most important planets in your chart, acting as a kind of cosmic guide for your life journey. Its sign, house, and aspects color the way you navigate your path.\n\n" +
                          "Learning to work consciously with your Ascendant means learning to show up in the world with greater authenticity and presence."
            },
            new()
            {
                Number = 5,
                Title = "Mercury's Messages",
                Subtitle = "Mind, Communication, and Perception",
                Category = "Planets",
                AssociatedPlanet = Planet.Mercury,
                ReadingProgress = 0.0,
                Content = "Mercury is the messenger of the gods -- the planet of mind, communication, and the bridges we build between inner and outer worlds. Its placement in your chart reveals how you think, learn, and express your ideas.\n\n" +
                          "Mercury in Fire signs thinks in bold strokes and speaks with enthusiasm. Mercury in Earth signs thinks practically and communicates with precision. Mercury in Air signs delights in ideas and thrives on intellectual exchange. Mercury in Water signs thinks intuitively and communicates through emotional resonance.\n\n" +
                          "When Mercury is retrograde in your natal chart, your thinking process may be more reflective, revisionary, and internally oriented. You may be someone who processes information best when given time to circle back and reconsider.\n\n" +
                          "Understanding your Mercury helps you optimize how you learn, how you share your thoughts, and how you make sense of the information flowing through your life."
            },
            new()
            {
                Number = 6,
                Title = "Venus and the Art of Love",
                Subtitle = "Values, Beauty, and Relationship",
                Category = "Planets",
                AssociatedPlanet = Planet.Venus,
                ReadingProgress = 0.0,
                Content = "Venus is the planet of love, beauty, and values. In your chart, she reveals what you find beautiful, how you give and receive love, what you value most deeply, and how you experience pleasure and harmony.\n\n" +
                          "Venus is both the artist and the lover within you. Her sign placement colors your aesthetic sensibility and romantic style. Her house placement shows where in life you seek beauty, connection, and peace.\n\n" +
                          "Venus in Earth signs loves through touch, comfort, and practical devotion. Venus in Water signs loves through emotional depth and merging. Venus in Fire signs loves with passion and grand gestures. Venus in Air signs loves through intellectual connection and social grace.\n\n" +
                          "Honoring your Venus means making space for what you love -- not as indulgence, but as a fundamental expression of your values and your capacity for joy."
            },
            new()
            {
                Number = 7,
                Title = "The Twelve Houses",
                Subtitle = "Domains of Human Experience",
                Category = "Houses",
                ReadingProgress = 0.0,
                Content = "The twelve houses of the natal chart divide human experience into fundamental domains. Each house represents an area of life where planetary energies express themselves.\n\n" +
                          "The Angular Houses (1, 4, 7, 10) are the pillars of your chart. The 1st House is self and identity. The 4th House is home and roots. The 7th House is partnership and the other. The 10th House is vocation and public role.\n\n" +
                          "The Succedent Houses (2, 5, 8, 11) deal with resources and stabilization. The 2nd House is personal values and possessions. The 5th House is creativity and joy. The 8th House is shared resources and transformation. The 11th House is community and aspirations.\n\n" +
                          "The Cadent Houses (3, 6, 9, 12) are about learning and adaptation. The 3rd House is communication and immediate environment. The 6th House is daily work and health. The 9th House is higher learning and philosophy. The 12th House is the unconscious and transcendence.\n\n" +
                          "An empty house is not an empty area of life -- it simply means that area may flow more naturally, without the concentrated focus that planets bring."
            },
            new()
            {
                Number = 8,
                Title = "Aspect Patterns",
                Subtitle = "The Sacred Geometry of Your Chart",
                Category = "Aspects",
                ReadingProgress = 0.0,
                Content = "Aspects are the angular relationships between planets in your chart -- the invisible threads that weave your cosmic energies into patterns of harmony, tension, and dynamic growth.\n\n" +
                          "The Conjunction (0 degrees) merges two planetary energies into a single, intensified force. The Trine (120 degrees) creates a natural, flowing harmony. The Sextile (60 degrees) offers opportunities for creative integration.\n\n" +
                          "The Square (90 degrees) generates friction and challenge -- but also the dynamic tension that drives growth and accomplishment. The Opposition (180 degrees) creates a polarity that demands balance and awareness of complementary forces.\n\n" +
                          "When aspects combine into larger patterns -- Grand Trines, T-Squares, Grand Crosses, Yods -- they create complex energetic signatures that shape the fundamental themes of your life.\n\n" +
                          "A Grand Trine (three trines forming a triangle) suggests an area of natural talent and ease. A T-Square (two squares and an opposition) indicates a persistent challenge that can become your greatest source of strength. A Yod (two quincunxes pointing to a focal planet) is sometimes called the 'Finger of God,' suggesting a specialized mission or adjustment."
            },
            new()
            {
                Number = 9,
                Title = "Transits and Becoming",
                Subtitle = "The Unfolding Cosmic Story",
                Category = "Transits",
                ReadingProgress = 0.0,
                Content = "While your natal chart is fixed at birth, the planets continue their celestial dance. Transits occur when the current planetary positions form aspects to your natal placements, activating and stimulating different areas of your chart.\n\n" +
                          "The inner planets (Sun, Moon, Mercury, Venus, Mars) make frequent transits that color your daily and weekly experience. The outer planets (Jupiter, Saturn, Uranus, Neptune, Pluto) make slower transits that correspond to major life themes and transformations.\n\n" +
                          "Saturn transits (every 7 years approximately) bring structure, responsibility, and maturation. Jupiter transits bring expansion, opportunity, and growth. Uranus transits (every 7 years) bring sudden awakening and liberation. Neptune transits dissolve boundaries and invite spiritual deepening. Pluto transits catalyze profound transformation.\n\n" +
                          "By tracking your transits, you can work more consciously with the cosmic timing of your life -- not to predict events, but to understand the underlying invitation of each period and respond with greater awareness."
            },
            new()
            {
                Number = 10,
                Title = "Integration",
                Subtitle = "Living Your Cosmic Architecture",
                Category = "Integration",
                ReadingProgress = 0.0,
                Content = "The ultimate purpose of studying your cosmic architecture is not knowledge for its own sake, but the integration of all these diverse energies into a conscious, creative, fulfilling life.\n\n" +
                          "Integration means honoring all parts of your chart -- not just the comfortable trines and sextiles, but also the challenging squares and oppositions. Every aspect of your chart has a gift to offer, even the aspects that create tension and difficulty.\n\n" +
                          "Daily practice is the key to integration. Take time each morning to check in with the current transits and moon phase. Use the reflection prompts to journal about your inner experience. Meditate with the planetary energies that are most active.\n\n" +
                          "Remember: your chart is not your destiny. It is your potential. What you do with that potential -- how you cultivate it, express it, and share it -- is the luminous art of living your cosmic architecture.\n\n" +
                          "You are not merely influenced by the stars. You are made of the same cosmic substance, expressing itself through the unique form of your life. Shine your light. The cosmos celebrates your becoming."
            }
        };
    }
}
