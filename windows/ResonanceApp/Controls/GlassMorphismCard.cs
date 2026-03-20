// =============================================================================
// Resonance UX - GlassMorphismCard Custom Control
// A WinUI 3 custom control with acrylic backdrop, animated border glow,
// depth shadow system, pointer interaction effects, and full accessibility.
// =============================================================================

using Microsoft.UI;
using Microsoft.UI.Composition;
using Microsoft.UI.Input;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Automation;
using Microsoft.UI.Xaml.Automation.Peers;
using Microsoft.UI.Xaml.Controls;
using Microsoft.UI.Xaml.Hosting;
using Microsoft.UI.Xaml.Input;
using Microsoft.UI.Xaml.Media;
using Microsoft.UI.Xaml.Media.Animation;
using System;
using System.Numerics;
using Windows.UI;

namespace ResonanceApp.Controls
{
    /// <summary>
    /// GlassMorphismCard — a frosted glass card with subtle depth and glow.
    ///
    /// Design philosophy: Cards should feel like they float on the surface,
    /// gently responding to interaction without demanding attention. The glass
    /// effect provides a sense of depth and layering that supports the Resonance
    /// principle of calm hierarchy.
    ///
    /// Features:
    /// - Acrylic/frosted glass backdrop with configurable tint and opacity
    /// - Animated border glow on hover and focus (gold accent)
    /// - Layered shadow system with depth levels
    /// - Smooth pointer tracking for subtle parallax
    /// - High contrast mode support
    /// - Narrator/screen reader accessibility
    /// - Keyboard focus visual
    /// </summary>
    [TemplatePart(Name = "PART_ContentPresenter", Type = typeof(ContentPresenter))]
    [TemplatePart(Name = "PART_BorderGlow", Type = typeof(Border))]
    public class GlassMorphismCard : ContentControl
    {
        // =====================================================================
        // Dependency Properties
        // =====================================================================

        public static readonly DependencyProperty ElevationProperty =
            DependencyProperty.Register(
                nameof(Elevation),
                typeof(GlassElevation),
                typeof(GlassMorphismCard),
                new PropertyMetadata(GlassElevation.Medium, OnElevationChanged));

        public static readonly DependencyProperty TintColorProperty =
            DependencyProperty.Register(
                nameof(TintColor),
                typeof(Color),
                typeof(GlassMorphismCard),
                new PropertyMetadata(Colors.White, OnTintColorChanged));

        public static readonly DependencyProperty TintOpacityProperty =
            DependencyProperty.Register(
                nameof(TintOpacity),
                typeof(double),
                typeof(GlassMorphismCard),
                new PropertyMetadata(0.78, OnTintOpacityChanged));

        public static readonly DependencyProperty BlurAmountProperty =
            DependencyProperty.Register(
                nameof(BlurAmount),
                typeof(double),
                typeof(GlassMorphismCard),
                new PropertyMetadata(30.0));

        public static readonly DependencyProperty GlowColorProperty =
            DependencyProperty.Register(
                nameof(GlowColor),
                typeof(Color),
                typeof(GlassMorphismCard),
                new PropertyMetadata(Color.FromArgb(0, 197, 160, 89))); // Gold, transparent

        public static readonly DependencyProperty GlowIntensityProperty =
            DependencyProperty.Register(
                nameof(GlowIntensity),
                typeof(double),
                typeof(GlassMorphismCard),
                new PropertyMetadata(0.0));

        public static readonly DependencyProperty IsInteractiveProperty =
            DependencyProperty.Register(
                nameof(IsInteractive),
                typeof(bool),
                typeof(GlassMorphismCard),
                new PropertyMetadata(true));

        public static readonly DependencyProperty EnableParallaxProperty =
            DependencyProperty.Register(
                nameof(EnableParallax),
                typeof(bool),
                typeof(GlassMorphismCard),
                new PropertyMetadata(true));

        public static readonly DependencyProperty CardCornerRadiusProperty =
            DependencyProperty.Register(
                nameof(CardCornerRadius),
                typeof(CornerRadius),
                typeof(GlassMorphismCard),
                new PropertyMetadata(new CornerRadius(10)));

        // =====================================================================
        // Properties
        // =====================================================================

        public GlassElevation Elevation
        {
            get => (GlassElevation)GetValue(ElevationProperty);
            set => SetValue(ElevationProperty, value);
        }

        public Color TintColor
        {
            get => (Color)GetValue(TintColorProperty);
            set => SetValue(TintColorProperty, value);
        }

        public double TintOpacity
        {
            get => (double)GetValue(TintOpacityProperty);
            set => SetValue(TintOpacityProperty, value);
        }

        public double BlurAmount
        {
            get => (double)GetValue(BlurAmountProperty);
            set => SetValue(BlurAmountProperty, value);
        }

        public Color GlowColor
        {
            get => (Color)GetValue(GlowColorProperty);
            set => SetValue(GlowColorProperty, value);
        }

        public double GlowIntensity
        {
            get => (double)GetValue(GlowIntensityProperty);
            set => SetValue(GlowIntensityProperty, value);
        }

        public bool IsInteractive
        {
            get => (bool)GetValue(IsInteractiveProperty);
            set => SetValue(IsInteractiveProperty, value);
        }

        public bool EnableParallax
        {
            get => (bool)GetValue(EnableParallaxProperty);
            set => SetValue(EnableParallaxProperty, value);
        }

        public CornerRadius CardCornerRadius
        {
            get => (CornerRadius)GetValue(CardCornerRadiusProperty);
            set => SetValue(CardCornerRadiusProperty, value);
        }

        // =====================================================================
        // Fields
        // =====================================================================

        private Compositor _compositor;
        private SpriteVisual _shadowVisual;
        private DropShadow _dropShadow;
        private Visual _rootVisual;
        private Border _glowBorder;
        private Border _outerBorder;
        private Grid _rootContainer;
        private ContentPresenter _contentPresenter;
        private bool _isPointerOver;
        private bool _isFocused;
        private bool _isPressed;
        private SpringVector3NaturalMotionAnimation _hoverSpring;
        private SpringVector3NaturalMotionAnimation _pressSpring;

        // =====================================================================
        // Constructor
        // =====================================================================

        public GlassMorphismCard()
        {
            this.DefaultStyleKey = typeof(GlassMorphismCard);
            this.Loading += OnLoading;
            this.Loaded += OnLoaded;
            this.Unloaded += OnUnloaded;

            // Set default padding and alignment
            this.Padding = new Thickness(20, 16, 20, 16);
            this.HorizontalContentAlignment = HorizontalAlignment.Stretch;
            this.VerticalContentAlignment = VerticalAlignment.Stretch;

            // Accessibility
            this.IsTabStop = true;
            this.UseSystemFocusVisuals = true;
            AutomationProperties.SetName(this, "Glass card");
        }

        // =====================================================================
        // Lifecycle
        // =====================================================================

        private void OnLoading(FrameworkElement sender, object args)
        {
            BuildVisualTree();
        }

        private void OnLoaded(object sender, RoutedEventArgs e)
        {
            SetupCompositionEffects();
            ApplyElevation(Elevation);
            RegisterPointerHandlers();
        }

        private void OnUnloaded(object sender, RoutedEventArgs e)
        {
            UnregisterPointerHandlers();
            _shadowVisual?.Dispose();
            _dropShadow?.Dispose();
        }

        // =====================================================================
        // Visual Tree Construction
        // =====================================================================

        private void BuildVisualTree()
        {
            _rootContainer = new Grid();

            // Outer border (receives the glow)
            _outerBorder = new Border
            {
                CornerRadius = CardCornerRadius,
                BorderThickness = new Thickness(1),
                BorderBrush = new SolidColorBrush(Color.FromArgb(20, 255, 255, 255))
            };

            // Glass background
            var isDeepRest = App.Current.IsDeepRestMode;
            var glassBrush = new AcrylicBrush
            {
                TintColor = isDeepRest
                    ? App.ResonanceColors.DeepRestSurface
                    : TintColor,
                TintOpacity = TintOpacity,
                FallbackColor = isDeepRest
                    ? App.ResonanceColors.DeepRestSurface
                    : TintColor
            };
            _outerBorder.Background = glassBrush;

            // Glow border (invisible by default, shows on hover/focus)
            _glowBorder = new Border
            {
                CornerRadius = CardCornerRadius,
                BorderThickness = new Thickness(1.5),
                BorderBrush = new SolidColorBrush(Color.FromArgb(0, 197, 160, 89)),
                IsHitTestVisible = false
            };

            // Content presenter
            _contentPresenter = new ContentPresenter
            {
                Content = this.Content,
                ContentTemplate = this.ContentTemplate,
                HorizontalAlignment = HorizontalContentAlignment,
                VerticalAlignment = VerticalContentAlignment,
                Padding = this.Padding
            };

            _outerBorder.Child = _contentPresenter;
            _rootContainer.Children.Add(_outerBorder);
            _rootContainer.Children.Add(_glowBorder);

            // Replace the content with our visual tree
            this.Content = null;
            this.ContentTemplateRoot = null;
        }

        // =====================================================================
        // Composition Effects (Shadow & Spring Animations)
        // =====================================================================

        private void SetupCompositionEffects()
        {
            if (_rootContainer == null) return;

            _rootVisual = ElementCompositionPreview.GetElementVisual(_rootContainer);
            _compositor = _rootVisual.Compositor;

            // Create the drop shadow
            _dropShadow = _compositor.CreateDropShadow();
            _dropShadow.Color = Color.FromArgb(30, 0, 0, 0);
            _dropShadow.BlurRadius = 8;
            _dropShadow.Offset = new Vector3(0, 2, 0);

            _shadowVisual = _compositor.CreateSpriteVisual();
            _shadowVisual.Shadow = _dropShadow;
            _shadowVisual.RelativeSizeAdjustment = Vector2.One;

            ElementCompositionPreview.SetElementChildVisual(_rootContainer, _shadowVisual);

            // Create spring animations for hover/press
            _hoverSpring = _compositor.CreateSpringVector3Animation();
            _hoverSpring.DampingRatio = 0.7f;
            _hoverSpring.Period = TimeSpan.FromMilliseconds(50);

            _pressSpring = _compositor.CreateSpringVector3Animation();
            _pressSpring.DampingRatio = 0.6f;
            _pressSpring.Period = TimeSpan.FromMilliseconds(30);

            // Enable implicit animations on the visual
            var implicitAnimations = _compositor.CreateImplicitAnimationCollection();
            var offsetAnimation = _compositor.CreateVector3KeyFrameAnimation();
            offsetAnimation.InsertExpressionKeyFrame(1.0f, "this.FinalValue");
            offsetAnimation.Duration = TimeSpan.FromMilliseconds(200);
            implicitAnimations["Offset"] = offsetAnimation;

            var scaleAnimation = _compositor.CreateVector3KeyFrameAnimation();
            scaleAnimation.InsertExpressionKeyFrame(1.0f, "this.FinalValue");
            scaleAnimation.Duration = TimeSpan.FromMilliseconds(200);
            implicitAnimations["Scale"] = scaleAnimation;

            _rootVisual.ImplicitAnimations = implicitAnimations;
        }

        // =====================================================================
        // Elevation & Shadow
        // =====================================================================

        private void ApplyElevation(GlassElevation elevation)
        {
            if (_dropShadow == null) return;

            var (blur, opacity, offsetY) = elevation switch
            {
                GlassElevation.Flat   => (0f,  0,  0f),
                GlassElevation.Low    => (4f,  15, 1f),
                GlassElevation.Medium => (8f,  25, 2f),
                GlassElevation.High   => (16f, 35, 4f),
                GlassElevation.Floating => (24f, 40, 8f),
                _ => (8f, 25, 2f)
            };

            _dropShadow.BlurRadius = blur;
            _dropShadow.Color = Color.FromArgb((byte)opacity, 0, 0, 0);
            _dropShadow.Offset = new Vector3(0, offsetY, 0);
        }

        private static void OnElevationChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is GlassMorphismCard card)
                card.ApplyElevation((GlassElevation)e.NewValue);
        }

        private static void OnTintColorChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is GlassMorphismCard card)
                card.UpdateGlassAppearance();
        }

        private static void OnTintOpacityChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is GlassMorphismCard card)
                card.UpdateGlassAppearance();
        }

        private void UpdateGlassAppearance()
        {
            if (_outerBorder?.Background is AcrylicBrush brush)
            {
                brush.TintColor = TintColor;
                brush.TintOpacity = TintOpacity;
            }
        }

        // =====================================================================
        // Pointer Interaction Effects
        // =====================================================================

        private void RegisterPointerHandlers()
        {
            if (!IsInteractive) return;

            this.PointerEntered += OnPointerEntered;
            this.PointerExited += OnPointerExited;
            this.PointerPressed += OnPointerPressed;
            this.PointerReleased += OnPointerReleased;
            this.PointerMoved += OnPointerMoved;
            this.GotFocus += OnGotFocus;
            this.LostFocus += OnLostFocus;
        }

        private void UnregisterPointerHandlers()
        {
            this.PointerEntered -= OnPointerEntered;
            this.PointerExited -= OnPointerExited;
            this.PointerPressed -= OnPointerPressed;
            this.PointerReleased -= OnPointerReleased;
            this.PointerMoved -= OnPointerMoved;
            this.GotFocus -= OnGotFocus;
            this.LostFocus -= OnLostFocus;
        }

        private void OnPointerEntered(object sender, PointerRoutedEventArgs e)
        {
            _isPointerOver = true;
            AnimateToHoverState();
        }

        private void OnPointerExited(object sender, PointerRoutedEventArgs e)
        {
            _isPointerOver = false;
            if (!_isFocused)
            {
                AnimateToRestState();
            }
        }

        private void OnPointerPressed(object sender, PointerRoutedEventArgs e)
        {
            _isPressed = true;
            AnimateToPressedState();
        }

        private void OnPointerReleased(object sender, PointerRoutedEventArgs e)
        {
            _isPressed = false;
            if (_isPointerOver)
                AnimateToHoverState();
            else
                AnimateToRestState();
        }

        private void OnPointerMoved(object sender, PointerRoutedEventArgs e)
        {
            if (!EnableParallax || !_isPointerOver || _rootVisual == null) return;

            var point = e.GetCurrentPoint(this);
            var width = this.ActualWidth;
            var height = this.ActualHeight;

            if (width <= 0 || height <= 0) return;

            // Calculate normalized position (-1 to 1)
            double normalX = (point.Position.X / width - 0.5) * 2.0;
            double normalY = (point.Position.Y / height - 0.5) * 2.0;

            // Subtle parallax tilt (max 1.5 degrees)
            float tiltX = (float)(-normalY * 1.5);
            float tiltY = (float)(normalX * 1.5);

            // Apply rotation via composition
            _rootVisual.RotationAxis = new Vector3(1, 0, 0);
            _rootVisual.RotationAngleInDegrees = tiltX;

            // Shift the shadow slightly opposite to pointer
            if (_dropShadow != null)
            {
                float shadowOffsetX = (float)(-normalX * 3);
                float shadowOffsetY = (float)(-normalY * 3) + GetElevationOffset();
                _dropShadow.Offset = new Vector3(shadowOffsetX, shadowOffsetY, 0);
            }
        }

        private void OnGotFocus(object sender, RoutedEventArgs e)
        {
            _isFocused = true;
            AnimateToHoverState();
        }

        private void OnLostFocus(object sender, RoutedEventArgs e)
        {
            _isFocused = false;
            if (!_isPointerOver)
            {
                AnimateToRestState();
            }
        }

        // =====================================================================
        // State Animations
        // =====================================================================

        private void AnimateToHoverState()
        {
            if (_rootVisual == null) return;

            // Lift the card slightly
            _rootVisual.Offset = new Vector3(0, -2, 0);

            // Scale up very subtly
            _rootVisual.Scale = new Vector3(1.005f, 1.005f, 1f);

            // Increase shadow depth
            if (_dropShadow != null)
            {
                _dropShadow.BlurRadius = GetElevationBlur() + 4;
                _dropShadow.Offset = new Vector3(0, GetElevationOffset() + 2, 0);
                _dropShadow.Color = Color.FromArgb((byte)(GetElevationShadowOpacity() + 10), 0, 0, 0);
            }

            // Animate border glow
            AnimateGlow(0.4);
        }

        private void AnimateToRestState()
        {
            if (_rootVisual == null) return;

            _rootVisual.Offset = Vector3.Zero;
            _rootVisual.Scale = Vector3.One;
            _rootVisual.RotationAngleInDegrees = 0;

            ApplyElevation(Elevation);
            AnimateGlow(0.0);
        }

        private void AnimateToPressedState()
        {
            if (_rootVisual == null) return;

            // Press down slightly
            _rootVisual.Offset = new Vector3(0, 1, 0);
            _rootVisual.Scale = new Vector3(0.995f, 0.995f, 1f);

            // Flatten shadow
            if (_dropShadow != null)
            {
                _dropShadow.BlurRadius = Math.Max(2, GetElevationBlur() - 4);
                _dropShadow.Offset = new Vector3(0, 1, 0);
            }

            AnimateGlow(0.6);
        }

        private void AnimateGlow(double targetOpacity)
        {
            if (_glowBorder == null) return;

            byte alpha = (byte)(targetOpacity * 100);
            var goldGlow = Color.FromArgb(alpha, 197, 160, 89);

            var animation = new ColorAnimation
            {
                To = goldGlow,
                Duration = new Duration(TimeSpan.FromMilliseconds(200)),
                EasingFunction = new CubicEase { EasingMode = EasingMode.EaseOut }
            };

            var storyboard = new Storyboard();
            storyboard.Children.Add(animation);
            Storyboard.SetTarget(animation, _glowBorder);
            Storyboard.SetTargetProperty(animation, "(Border.BorderBrush).(SolidColorBrush.Color)");
            storyboard.Begin();
        }

        // =====================================================================
        // Elevation Helpers
        // =====================================================================

        private float GetElevationBlur() => Elevation switch
        {
            GlassElevation.Flat => 0f,
            GlassElevation.Low => 4f,
            GlassElevation.Medium => 8f,
            GlassElevation.High => 16f,
            GlassElevation.Floating => 24f,
            _ => 8f
        };

        private float GetElevationOffset() => Elevation switch
        {
            GlassElevation.Flat => 0f,
            GlassElevation.Low => 1f,
            GlassElevation.Medium => 2f,
            GlassElevation.High => 4f,
            GlassElevation.Floating => 8f,
            _ => 2f
        };

        private int GetElevationShadowOpacity() => Elevation switch
        {
            GlassElevation.Flat => 0,
            GlassElevation.Low => 15,
            GlassElevation.Medium => 25,
            GlassElevation.High => 35,
            GlassElevation.Floating => 40,
            _ => 25
        };

        // =====================================================================
        // Accessibility
        // =====================================================================

        protected override AutomationPeer OnCreateAutomationPeer()
        {
            return new GlassMorphismCardAutomationPeer(this);
        }

        /// <summary>
        /// When high contrast mode is active, we disable glass effects
        /// and use solid colors with visible borders for clarity.
        /// </summary>
        private void ApplyHighContrastMode()
        {
            var accessibilitySettings = new Windows.UI.ViewManagement.AccessibilitySettings();
            if (accessibilitySettings.HighContrast)
            {
                _outerBorder.Background = new SolidColorBrush(
                    App.Current.IsDeepRestMode
                        ? App.ResonanceColors.DeepRestSurface
                        : App.ResonanceColors.LightSurface);
                _outerBorder.BorderBrush = new SolidColorBrush(
                    App.Current.IsDeepRestMode
                        ? App.ResonanceColors.DeepRestText
                        : App.ResonanceColors.Green900);
                _outerBorder.BorderThickness = new Thickness(2);

                // Disable visual effects that may confuse screen readers
                if (_dropShadow != null)
                    _dropShadow.Color = Colors.Transparent;
            }
        }
    }

    // =========================================================================
    // Supporting Types
    // =========================================================================

    public enum GlassElevation
    {
        Flat,
        Low,
        Medium,
        High,
        Floating
    }

    /// <summary>
    /// Automation peer for GlassMorphismCard.
    /// Exposes the card as a "Group" to screen readers with its content
    /// and interactive state.
    /// </summary>
    public class GlassMorphismCardAutomationPeer : FrameworkElementAutomationPeer
    {
        public GlassMorphismCardAutomationPeer(GlassMorphismCard owner) : base(owner) { }

        protected override string GetClassNameCore() => "GlassMorphismCard";

        protected override AutomationControlType GetAutomationControlTypeCore()
            => AutomationControlType.Group;

        protected override string GetNameCore()
        {
            var name = AutomationProperties.GetName(Owner);
            if (!string.IsNullOrEmpty(name)) return name;

            if (Owner is GlassMorphismCard card && card.Content is string text)
                return text;

            return "Glass card";
        }

        protected override string GetLocalizedControlTypeCore()
            => "Card";

        protected override bool IsContentElementCore() => true;
        protected override bool IsControlElementCore() => true;
    }
}
