// =============================================================================
// Resonance UX — Theme Module (Rust + GTK4 CSS)
//
// Generates the complete CSS for the Resonance design system:
// color palette, light/Deep Rest mode, font loading, glass morphism,
// animation keyframes, and all custom widget classes.
// =============================================================================

/// Resonance Design Tokens — Colors
pub struct ResonanceColors;

impl ResonanceColors {
    // Light palette
    pub const LIGHT_BASE: &'static str = "#FAFAF8";
    pub const LIGHT_SURFACE: &'static str = "#FFFFFF";
    pub const GREEN_900: &'static str = "#0A1C14";
    pub const GREEN_800: &'static str = "#122E21";
    pub const GREEN_700: &'static str = "#1A4030";
    pub const GREEN_600: &'static str = "#2A5A44";
    pub const GREEN_500: &'static str = "#3D7A5E";
    pub const GREEN_400: &'static str = "#5A9A7A";
    pub const GREEN_300: &'static str = "#80B898";
    pub const GREEN_200: &'static str = "#A8D4B8";
    pub const GREEN_100: &'static str = "#D4EDE0";
    pub const GREEN_50: &'static str = "#EDF7F1";
    pub const GOLD: &'static str = "#C5A059";
    pub const GOLD_LIGHT: &'static str = "#D4B87A";
    pub const GOLD_DARK: &'static str = "#A6853E";
    pub const TEXT_MUTED: &'static str = "#5C7065";
    pub const TEXT_SUBTLE: &'static str = "#8A9E92";
    pub const BORDER_LIGHT: &'static str = "#E8E8E4";

    // Deep Rest (dark) palette
    pub const DEEP_REST_BASE: &'static str = "#05100B";
    pub const DEEP_REST_SURFACE: &'static str = "#0A1C14";
    pub const DEEP_REST_ELEVATED: &'static str = "#122E21";
    pub const DEEP_REST_TEXT: &'static str = "#FAFAF8";
    pub const DEEP_REST_TEXT_MUTED: &'static str = "#8A9E92";
    pub const DEEP_REST_BORDER: &'static str = "#1A3528";
}

/// Resonance Design Tokens — Typography
pub struct ResonanceFonts;

impl ResonanceFonts {
    pub const DISPLAY: &'static str = "Cormorant Garamond";
    pub const BODY: &'static str = "Manrope";
    pub const MONO: &'static str = "JetBrains Mono";
}

/// Resonance Design Tokens — Spacing
pub struct ResonanceSpacing;

impl ResonanceSpacing {
    pub const XS: i32 = 4;
    pub const SM: i32 = 8;
    pub const MD: i32 = 16;
    pub const LG: i32 = 24;
    pub const XL: i32 = 32;
    pub const XXL: i32 = 48;
    pub const HUGE: i32 = 64;
}

// =============================================================================
// Main Theme
// =============================================================================

pub struct ResonanceTheme;

impl ResonanceTheme {
    /// Generate the complete Resonance CSS stylesheet.
    pub fn generate_css() -> String {
        let mut css = String::with_capacity(8192);

        // Font imports
        css.push_str(&Self::generate_font_imports());

        // Light mode (default)
        css.push_str(&Self::generate_light_css());

        // Deep Rest (dark) mode
        css.push_str(&Self::generate_dark_css());

        // Shared component styles
        css.push_str(&Self::generate_component_css());

        // Glass morphism
        css.push_str(&Self::generate_glass_css());

        // Animation keyframes
        css.push_str(&Self::generate_animation_css());

        // Typography classes
        css.push_str(&Self::generate_typography_css());

        // Custom widgets
        css.push_str(&Self::generate_widget_css());

        css
    }

    // =========================================================================
    // Font Imports
    // =========================================================================

    fn generate_font_imports() -> String {
        format!(
            r#"
/* ==========================================================================
   Resonance UX — Font Loading
   Display: Cormorant Garamond | Body: Manrope | Mono: JetBrains Mono
   ========================================================================== */

/* Fonts are expected to be installed system-wide or via Flatpak font dirs.
   These @font-face rules serve as fallback documentation. */

"#
        )
    }

    // =========================================================================
    // Light Mode CSS
    // =========================================================================

    fn generate_light_css() -> String {
        format!(
            r#"
/* ==========================================================================
   Light Mode (Default)
   ========================================================================== */

window,
.resonance-window {{
    background-color: {base};
    color: {text};
}}

headerbar {{
    background-color: transparent;
    border-bottom: 1px solid {border};
    box-shadow: none;
}}

headerbar .title {{
    font-family: "{display_font}";
    font-weight: 300;
}}

.resonance-page {{
    background-color: {base};
}}

.resonance-sidebar {{
    background-color: alpha({surface}, 0.9);
    border-right: 1px solid {border};
}}

"#,
            base = ResonanceColors::LIGHT_BASE,
            surface = ResonanceColors::LIGHT_SURFACE,
            text = ResonanceColors::GREEN_900,
            border = ResonanceColors::BORDER_LIGHT,
            display_font = ResonanceFonts::DISPLAY,
        )
    }

    // =========================================================================
    // Deep Rest (Dark Mode) CSS
    // =========================================================================

    fn generate_dark_css() -> String {
        format!(
            r#"
/* ==========================================================================
   Deep Rest Mode (Dark)
   ========================================================================== */

window.dark,
.dark .resonance-window,
@media (prefers-color-scheme: dark) {{
    window,
    .resonance-window {{
        background-color: {base};
        color: {text};
    }}

    headerbar {{
        background-color: transparent;
        border-bottom: 1px solid {border};
    }}

    .resonance-page {{
        background-color: {base};
    }}

    .resonance-sidebar {{
        background-color: alpha({surface}, 0.85);
        border-right: 1px solid {border};
    }}

    .resonance-card {{
        background-color: alpha({elevated}, 0.7);
        border: 1px solid {border};
    }}

    .resonance-accent {{
        color: {gold};
    }}

    .resonance-accent-text {{
        color: {gold};
    }}

    .resonance-editor {{
        color: {text};
        background-color: transparent;
    }}

    .resonance-editor-title {{
        color: {text};
    }}
}}

"#,
            base = ResonanceColors::DEEP_REST_BASE,
            surface = ResonanceColors::DEEP_REST_SURFACE,
            elevated = ResonanceColors::DEEP_REST_ELEVATED,
            text = ResonanceColors::DEEP_REST_TEXT,
            border = ResonanceColors::DEEP_REST_BORDER,
            gold = ResonanceColors::GOLD,
        )
    }

    // =========================================================================
    // Component Styles
    // =========================================================================

    fn generate_component_css() -> String {
        format!(
            r#"
/* ==========================================================================
   Resonance Component Styles
   ========================================================================== */

/* Card */
.resonance-card {{
    background-color: alpha({surface}, 0.85);
    border-radius: 10px;
    border: 1px solid alpha({border}, 0.5);
    padding: 0;
    transition: all 200ms cubic-bezier(0.2, 0, 0, 1);
}}

.resonance-card:hover {{
    box-shadow: 0 4px 16px alpha(black, 0.08);
    border-color: alpha({gold}, 0.3);
}}

/* Badge */
.resonance-badge {{
    background-color: alpha({gold}, 0.12);
    color: {gold_dark};
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 10px;
    font-family: "{body_font}";
    letter-spacing: 0.5px;
}}

/* Progress bar */
.resonance-progress trough {{
    background-color: alpha({muted}, 0.15);
    border-radius: 2px;
    min-height: 4px;
}}

.resonance-progress progress {{
    background-color: {gold};
    border-radius: 2px;
    min-height: 4px;
}}

/* Phase indicator */
.resonance-phase-indicator {{
    font-family: "{body_font}";
    font-size: 12px;
    opacity: 0.6;
    letter-spacing: 0.5px;
}}

/* Accent colors */
.resonance-accent {{
    color: {gold};
}}

.resonance-accent-text {{
    color: {gold};
}}

/* Task row */
.resonance-task-row {{
    transition: background-color 200ms ease;
}}

.resonance-task-row:hover {{
    background-color: alpha({gold}, 0.06);
}}

/* Stats bar */
.resonance-stats-bar {{
    background-color: alpha({surface}, 0.9);
    border-radius: 20px;
    padding: 8px 20px;
    box-shadow: 0 2px 12px alpha(black, 0.06);
    border: 1px solid alpha({border}, 0.5);
}}

/* Label style */
.resonance-label {{
    font-family: "{body_font}";
    font-size: 10px;
    letter-spacing: 1px;
    font-weight: 500;
}}

"#,
            surface = ResonanceColors::LIGHT_SURFACE,
            border = ResonanceColors::BORDER_LIGHT,
            gold = ResonanceColors::GOLD,
            gold_dark = ResonanceColors::GOLD_DARK,
            muted = ResonanceColors::TEXT_MUTED,
            body_font = ResonanceFonts::BODY,
        )
    }

    // =========================================================================
    // Glass Morphism CSS
    // =========================================================================

    fn generate_glass_css() -> String {
        format!(
            r#"
/* ==========================================================================
   Glass Morphism
   ========================================================================== */

.resonance-glass {{
    background-color: alpha({surface}, 0.72);
    border: 1px solid alpha(white, 0.18);
    border-radius: 12px;
    box-shadow:
        0 2px 8px alpha(black, 0.04),
        inset 0 1px 0 alpha(white, 0.2);
}}

.resonance-glass-dark {{
    background-color: alpha({dark_surface}, 0.65);
    border: 1px solid alpha(white, 0.08);
    border-radius: 12px;
    box-shadow:
        0 2px 12px alpha(black, 0.15),
        inset 0 1px 0 alpha(white, 0.05);
}}

.resonance-glass-elevated {{
    background-color: alpha({surface}, 0.82);
    border: 1px solid alpha(white, 0.25);
    border-radius: 16px;
    box-shadow:
        0 8px 32px alpha(black, 0.08),
        0 2px 8px alpha(black, 0.04),
        inset 0 1px 0 alpha(white, 0.3);
}}

"#,
            surface = ResonanceColors::LIGHT_SURFACE,
            dark_surface = ResonanceColors::DEEP_REST_SURFACE,
        )
    }

    // =========================================================================
    // Animation Keyframes
    // =========================================================================

    fn generate_animation_css() -> String {
        r#"
/* ==========================================================================
   Animation Keyframes
   ========================================================================== */

/* Gentle fade in */
@keyframes resonance-fade-in {
    from {
        opacity: 0;
        transform: translateY(12px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.resonance-fade-in {
    animation: resonance-fade-in 500ms cubic-bezier(0.2, 0, 0, 1) forwards;
}

/* Slow pulse for attention (non-aggressive) */
@keyframes resonance-pulse {
    0%, 100% {
        opacity: 1;
    }
    50% {
        opacity: 0.7;
    }
}

.resonance-pulse {
    animation: resonance-pulse 3s ease-in-out infinite;
}

/* Gold glow on focus */
@keyframes resonance-glow {
    from {
        box-shadow: 0 0 0 0 alpha(#C5A059, 0);
    }
    to {
        box-shadow: 0 0 0 3px alpha(#C5A059, 0.2);
    }
}

.resonance-glow:focus {
    animation: resonance-glow 300ms ease forwards;
}

/* Phase transition crossfade */
@keyframes resonance-phase-transition {
    0% {
        opacity: 1;
    }
    40% {
        opacity: 0;
    }
    60% {
        opacity: 0;
    }
    100% {
        opacity: 1;
    }
}

.resonance-phase-transition {
    animation: resonance-phase-transition 800ms cubic-bezier(0.4, 0, 0.2, 1) forwards;
}

/* Slide in from right */
@keyframes resonance-slide-in-right {
    from {
        opacity: 0;
        transform: translateX(24px);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

.resonance-slide-in-right {
    animation: resonance-slide-in-right 400ms cubic-bezier(0.2, 0, 0, 1) forwards;
}

/* Scale in (for cards appearing) */
@keyframes resonance-scale-in {
    from {
        opacity: 0;
        transform: scale(0.96);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
}

.resonance-scale-in {
    animation: resonance-scale-in 300ms cubic-bezier(0.2, 0, 0, 1) forwards;
}

"#
        .to_string()
    }

    // =========================================================================
    // Typography CSS
    // =========================================================================

    fn generate_typography_css() -> String {
        format!(
            r#"
/* ==========================================================================
   Resonance Typography
   ========================================================================== */

.resonance-display {{
    font-family: "{display_font}", serif;
    font-weight: 300;
}}

.resonance-heading {{
    font-family: "{body_font}", sans-serif;
    font-weight: 600;
}}

.resonance-body {{
    font-family: "{body_font}", sans-serif;
    font-weight: 400;
    line-height: 1.5;
}}

.resonance-mono {{
    font-family: "{mono_font}", monospace;
    font-weight: 400;
}}

/* Editor styles */
.resonance-editor {{
    font-family: "{display_font}", serif;
    font-size: 18px;
    line-height: 1.7;
    color: {text};
    background-color: transparent;
    border: none;
    caret-color: {gold};
}}

.resonance-editor-title {{
    font-family: "{display_font}", serif;
    font-size: 32px;
    font-weight: 300;
    border: none;
    background-color: transparent;
    padding: 0;
    min-height: 48px;
}}

.resonance-editor-title:focus {{
    box-shadow: none;
    border: none;
}}

"#,
            display_font = ResonanceFonts::DISPLAY,
            body_font = ResonanceFonts::BODY,
            mono_font = ResonanceFonts::MONO,
            text = ResonanceColors::GREEN_900,
            gold = ResonanceColors::GOLD,
        )
    }

    // =========================================================================
    // Widget-Specific CSS
    // =========================================================================

    fn generate_widget_css() -> String {
        format!(
            r#"
/* ==========================================================================
   Widget-Specific Styles
   ========================================================================== */

/* Navigation sidebar items */
.navigation-sidebar row {{
    border-radius: 8px;
    margin: 2px 4px;
    padding: 4px;
    transition: background-color 200ms ease;
}}

.navigation-sidebar row:selected {{
    background-color: alpha({gold}, 0.12);
    color: {green_900};
}}

.navigation-sidebar row:hover:not(:selected) {{
    background-color: alpha({gold}, 0.06);
}}

/* Buttons */
button.resonance-primary {{
    background-color: {gold};
    color: white;
    border-radius: 6px;
    padding: 8px 16px;
    font-family: "{body_font}";
    font-weight: 500;
    border: none;
    transition: all 200ms ease;
}}

button.resonance-primary:hover {{
    background-color: {gold_dark};
    box-shadow: 0 2px 8px alpha({gold}, 0.3);
}}

button.resonance-secondary {{
    background-color: transparent;
    color: {green_900};
    border: 1px solid {border};
    border-radius: 6px;
    padding: 8px 16px;
    font-family: "{body_font}";
    transition: all 200ms ease;
}}

button.resonance-secondary:hover {{
    border-color: alpha({gold}, 0.4);
    background-color: alpha({gold}, 0.06);
}}

/* Switch (toggle) */
switch {{
    border-radius: 12px;
}}

switch:checked {{
    background-color: {gold};
}}

switch:checked slider {{
    background-color: white;
}}

/* Search entry */
searchentry {{
    border-radius: 8px;
    font-family: "{body_font}";
    font-size: 13px;
    transition: border-color 200ms ease;
}}

searchentry:focus {{
    border-color: alpha({gold}, 0.5);
    box-shadow: 0 0 0 2px alpha({gold}, 0.15);
}}

/* Scrollbar */
scrollbar slider {{
    background-color: alpha({muted}, 0.3);
    border-radius: 4px;
    min-width: 6px;
    min-height: 6px;
}}

scrollbar slider:hover {{
    background-color: alpha({muted}, 0.5);
}}

/* Lists */
.boxed-list {{
    background-color: transparent;
    border: none;
}}

.boxed-list > row {{
    background-color: alpha({surface}, 0.6);
    border-radius: 8px;
    margin: 2px 0;
    transition: background-color 200ms ease;
}}

.boxed-list > row:hover {{
    background-color: alpha({gold}, 0.06);
}}

/* Tooltip */
tooltip {{
    background-color: alpha({green_900}, 0.9);
    color: {light_base};
    border-radius: 6px;
    padding: 4px 8px;
    font-family: "{body_font}";
    font-size: 12px;
}}

"#,
            gold = ResonanceColors::GOLD,
            gold_dark = ResonanceColors::GOLD_DARK,
            green_900 = ResonanceColors::GREEN_900,
            surface = ResonanceColors::LIGHT_SURFACE,
            border = ResonanceColors::BORDER_LIGHT,
            muted = ResonanceColors::TEXT_MUTED,
            light_base = ResonanceColors::LIGHT_BASE,
            body_font = ResonanceFonts::BODY,
        )
    }
}

// =============================================================================
// Theme Switching Helper
// =============================================================================

/// Apply the Resonance theme mode at runtime.
/// In GTK4 with Libadwaita, this primarily works through the StyleManager.
pub fn set_deep_rest_mode(enabled: bool) {
    let style_manager = libadwaita::StyleManager::default();
    if enabled {
        style_manager.set_color_scheme(libadwaita::ColorScheme::ForceDark);
        log::info!("Deep Rest mode enabled via StyleManager.");
    } else {
        style_manager.set_color_scheme(libadwaita::ColorScheme::Default);
        log::info!("Deep Rest mode disabled. Following system preference.");
    }
}

/// Check if the system is currently in dark mode.
pub fn is_system_dark() -> bool {
    let style_manager = libadwaita::StyleManager::default();
    style_manager.is_dark()
}
