// =============================================================================
// Resonance UX — Linux Native Application (Rust + GTK4 + Libadwaita)
//
// Philosophy: Calm, intentional digital experiences.
// This is the main entry point: application setup, window management,
// custom CSS theming, D-Bus notifications, and navigation.
// =============================================================================

mod models;
mod theme;
mod views;

use gtk4::prelude::*;
use gtk4::{
    gio, glib, Application, CssProvider, Settings,
};
use libadwaita::prelude::*;
use libadwaita::{
    AboutWindow, ApplicationWindow, ColorScheme, HeaderBar,
    NavigationSplitView, StyleManager, TabBar, TabView, ViewStack,
    ViewStackPage, ViewSwitcher, ViewSwitcherBar,
};
use std::cell::RefCell;
use std::rc::Rc;
use std::sync::Arc;
use tokio::sync::Mutex;

use crate::theme::ResonanceTheme;
use crate::views::{daily_flow, wellness, writer};

// =============================================================================
// Application Constants
// =============================================================================

const APP_ID: &str = "app.resonance.desktop";
const APP_NAME: &str = "Resonance";
const APP_VERSION: &str = "1.0.0";

// =============================================================================
// Application State
// =============================================================================

/// Shared application state, accessible across the UI.
#[derive(Debug, Clone)]
pub struct AppState {
    pub is_deep_rest: bool,
    pub current_phase: PhaseType,
    pub is_focus_mode: bool,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum PhaseType {
    Ascend,
    Zenith,
    Descent,
    Rest,
}

impl PhaseType {
    /// Determine the current phase from the time of day.
    pub fn from_current_time() -> Self {
        let hour = chrono::Local::now().hour();
        match hour {
            5..=9 => PhaseType::Ascend,
            10..=15 => PhaseType::Zenith,
            16..=20 => PhaseType::Descent,
            _ => PhaseType::Rest,
        }
    }

    pub fn display_name(&self) -> &'static str {
        match self {
            PhaseType::Ascend => "Ascending",
            PhaseType::Zenith => "At Zenith",
            PhaseType::Descent => "Descending",
            PhaseType::Rest => "Resting",
        }
    }

    pub fn guidance(&self) -> &'static str {
        match self {
            PhaseType::Ascend => "Build energy gently. The day will meet you where you are.",
            PhaseType::Zenith => "Your focus is sharpest now. Honor it with deep work.",
            PhaseType::Descent => "Let the day's intensity fade. Reflection over reaction.",
            PhaseType::Rest => "Nothing more is needed. Tomorrow will arrive on its own.",
        }
    }
}

use chrono::Timelike;

impl Default for AppState {
    fn default() -> Self {
        Self {
            is_deep_rest: false,
            current_phase: PhaseType::from_current_time(),
            is_focus_mode: false,
        }
    }
}

// =============================================================================
// Main Entry Point
// =============================================================================

fn main() {
    // Initialize logging
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info"))
        .format_timestamp(None)
        .init();

    log::info!("Resonance UX starting...");

    // Initialize GTK and Libadwaita
    let app = libadwaita::Application::builder()
        .application_id(APP_ID)
        .flags(gio::ApplicationFlags::FLAGS_NONE)
        .build();

    // Connect lifecycle handlers
    app.connect_startup(on_startup);
    app.connect_activate(on_activate);
    app.connect_shutdown(on_shutdown);

    // Run the application
    let exit_code = app.run();
    std::process::exit(exit_code.into());
}

// =============================================================================
// Application Lifecycle
// =============================================================================

/// Called once when the application starts. Set up CSS, actions, and D-Bus.
fn on_startup(app: &libadwaita::Application) {
    log::info!("Resonance startup...");

    // Load the Resonance CSS theme
    load_resonance_css();

    // Set up application-level actions
    setup_actions(app);

    // Detect system color scheme preference
    let style_manager = StyleManager::default();
    let is_dark = style_manager.is_dark();

    if is_dark {
        log::info!("System is in dark mode — enabling Deep Rest.");
    }

    // Initialize D-Bus notification integration
    setup_dbus_notifications();
}

/// Called when the application is activated (window creation).
fn on_activate(app: &libadwaita::Application) {
    log::info!("Resonance activate...");

    let state = Rc::new(RefCell::new(AppState::default()));

    // Detect initial theme
    let style_manager = StyleManager::default();
    state.borrow_mut().is_deep_rest = style_manager.is_dark();

    // Create the main window
    let window = build_main_window(app, state.clone());

    // Set up phase monitoring timer (every 5 minutes)
    let state_clone = state.clone();
    glib::timeout_add_seconds_local(300, move || {
        let new_phase = PhaseType::from_current_time();
        let mut s = state_clone.borrow_mut();
        if s.current_phase != new_phase {
            log::info!("Phase changed: {:?} -> {:?}", s.current_phase, new_phase);
            s.current_phase = new_phase;

            // Auto Deep Rest during Rest phase
            if new_phase == PhaseType::Rest && !s.is_deep_rest {
                s.is_deep_rest = true;
                let sm = StyleManager::default();
                sm.set_color_scheme(ColorScheme::ForceDark);
            } else if new_phase == PhaseType::Ascend && s.is_deep_rest {
                s.is_deep_rest = false;
                let sm = StyleManager::default();
                sm.set_color_scheme(ColorScheme::Default);
            }
        }
        glib::ControlFlow::Continue
    });

    // Listen for system theme changes
    let state_theme = state.clone();
    style_manager.connect_dark_notify(move |sm| {
        let mut s = state_theme.borrow_mut();
        s.is_deep_rest = sm.is_dark();
        log::info!("Theme changed. Deep Rest: {}", s.is_deep_rest);
    });

    window.present();
}

/// Called when the application shuts down.
fn on_shutdown(_app: &libadwaita::Application) {
    log::info!("Resonance shutting down gracefully...");
}

// =============================================================================
// Main Window Construction
// =============================================================================

fn build_main_window(
    app: &libadwaita::Application,
    state: Rc<RefCell<AppState>>,
) -> ApplicationWindow {
    // Create the main AdwApplicationWindow
    let window = ApplicationWindow::builder()
        .application(app)
        .title("Resonance")
        .default_width(1440)
        .default_height(900)
        .build();

    window.add_css_class("resonance-window");

    // --- View Stack for pages ---
    let view_stack = ViewStack::new();

    // Daily Flow page
    let flow_page = daily_flow::build_daily_flow_view(&state);
    let flow_stack_page = view_stack.add_titled(&flow_page, Some("flow"), "Daily Flow");
    flow_stack_page.set_icon_name(Some("weather-clear-symbolic"));

    // Focus page (placeholder)
    let focus_page = build_placeholder_page("Focus Sessions", "Deep work begins here.");
    let focus_stack_page = view_stack.add_titled(&focus_page, Some("focus"), "Focus");
    focus_stack_page.set_icon_name(Some("preferences-system-time-symbolic"));

    // Writer page
    let writer_page = writer::build_writer_view(&state);
    let writer_stack_page = view_stack.add_titled(&writer_page, Some("writer"), "Writer");
    writer_stack_page.set_icon_name(Some("text-editor-symbolic"));

    // Letters page (placeholder)
    let letters_page = build_placeholder_page("Letters", "Thoughtful, intentional communication.");
    let letters_stack_page = view_stack.add_titled(&letters_page, Some("letters"), "Letters");
    letters_stack_page.set_icon_name(Some("mail-unread-symbolic"));

    // Canvas page (placeholder)
    let canvas_page = build_placeholder_page("Canvas", "A space for visual expression.");
    let canvas_stack_page = view_stack.add_titled(&canvas_page, Some("canvas"), "Canvas");
    canvas_stack_page.set_icon_name(Some("applications-graphics-symbolic"));

    // Wellness Dashboard
    let wellness_page = wellness::build_wellness_view(&state);
    let wellness_stack_page =
        view_stack.add_titled(&wellness_page, Some("wellness"), "Wellness");
    wellness_stack_page.set_icon_name(Some("heart-filled-symbolic"));

    // --- Header Bar ---
    let header = HeaderBar::new();
    header.add_css_class("flat");

    // Phase indicator in the title
    let phase = state.borrow().current_phase;
    let title_label = gtk4::Label::new(Some(phase.display_name()));
    title_label.add_css_class("resonance-phase-indicator");
    header.set_title_widget(Some(&title_label));

    // View switcher in the header
    let switcher = ViewSwitcher::new();
    switcher.set_stack(Some(&view_stack));
    switcher.set_policy(libadwaita::ViewSwitcherPolicy::Wide);
    header.set_title_widget(Some(&switcher));

    // Deep Rest toggle button
    let deep_rest_btn = gtk4::ToggleButton::new();
    deep_rest_btn.set_icon_name("weather-clear-night-symbolic");
    deep_rest_btn.set_tooltip_text(Some("Toggle Deep Rest mode"));
    deep_rest_btn.add_css_class("flat");

    let state_dr = state.clone();
    deep_rest_btn.connect_toggled(move |btn| {
        let mut s = state_dr.borrow_mut();
        s.is_deep_rest = btn.is_active();

        let sm = StyleManager::default();
        if s.is_deep_rest {
            sm.set_color_scheme(ColorScheme::ForceDark);
            log::info!("Deep Rest mode enabled.");
        } else {
            sm.set_color_scheme(ColorScheme::Default);
            log::info!("Deep Rest mode disabled.");
        }
    });
    header.pack_end(&deep_rest_btn);

    // About button
    let about_btn = gtk4::Button::from_icon_name("help-about-symbolic");
    about_btn.set_tooltip_text(Some("About Resonance"));
    about_btn.add_css_class("flat");

    let window_ref = window.clone();
    about_btn.connect_clicked(move |_| {
        show_about_dialog(&window_ref);
    });
    header.pack_end(&about_btn);

    // --- Bottom view switcher bar for narrow mode ---
    let switcher_bar = ViewSwitcherBar::new();
    switcher_bar.set_stack(Some(&view_stack));

    // --- Assemble layout ---
    let main_box = gtk4::Box::new(gtk4::Orientation::Vertical, 0);
    main_box.append(&header);
    main_box.append(&view_stack);
    main_box.append(&switcher_bar);

    window.set_content(Some(&main_box));

    // --- Keyboard shortcuts ---
    setup_keyboard_shortcuts(&window, &view_stack, &state);

    window
}

// =============================================================================
// Placeholder Page Builder
// =============================================================================

fn build_placeholder_page(title: &str, subtitle: &str) -> gtk4::Box {
    let page = gtk4::Box::new(gtk4::Orientation::Vertical, 16);
    page.set_halign(gtk4::Align::Center);
    page.set_valign(gtk4::Align::Center);
    page.set_margin_top(48);

    let icon = gtk4::Image::from_icon_name("applications-system-symbolic");
    icon.set_pixel_size(64);
    icon.set_opacity(0.3);
    page.append(&icon);

    let title_label = gtk4::Label::new(Some(title));
    title_label.add_css_class("title-1");
    title_label.add_css_class("resonance-display");
    page.append(&title_label);

    let subtitle_label = gtk4::Label::new(Some(subtitle));
    subtitle_label.add_css_class("dim-label");
    subtitle_label.add_css_class("resonance-body");
    page.append(&subtitle_label);

    page
}

// =============================================================================
// CSS Theme Loading
// =============================================================================

fn load_resonance_css() {
    let css = ResonanceTheme::generate_css();

    let provider = CssProvider::new();
    provider.load_from_string(&css);

    gtk4::style_context_add_provider_for_display(
        &gtk4::gdk::Display::default().expect("Could not get default display"),
        &provider,
        gtk4::STYLE_PROVIDER_PRIORITY_APPLICATION,
    );

    log::info!("Resonance CSS theme loaded.");
}

// =============================================================================
// Application Actions
// =============================================================================

fn setup_actions(app: &libadwaita::Application) {
    // Quit action
    let quit_action = gio::SimpleAction::new("quit", None);
    let app_clone = app.clone();
    quit_action.connect_activate(move |_, _| {
        app_clone.quit();
    });
    app.add_action(&quit_action);

    // Toggle Deep Rest action
    let deep_rest_action = gio::SimpleAction::new_stateful(
        "toggle-deep-rest",
        None,
        &false.to_variant(),
    );
    deep_rest_action.connect_activate(|action, _| {
        let current: bool = action.state().unwrap().get().unwrap();
        action.set_state(&(!current).to_variant());

        let sm = StyleManager::default();
        if !current {
            sm.set_color_scheme(ColorScheme::ForceDark);
        } else {
            sm.set_color_scheme(ColorScheme::Default);
        }
    });
    app.add_action(&deep_rest_action);

    // Set keyboard accelerators
    app.set_accels_for_action("app.quit", &["<Control>q"]);
    app.set_accels_for_action("app.toggle-deep-rest", &["<Control><Shift>d"]);
}

// =============================================================================
// Keyboard Shortcuts
// =============================================================================

fn setup_keyboard_shortcuts(
    window: &ApplicationWindow,
    view_stack: &ViewStack,
    state: &Rc<RefCell<AppState>>,
) {
    let controller = gtk4::EventControllerKey::new();

    let vs = view_stack.clone();
    let state_ks = state.clone();
    let win = window.clone();

    controller.connect_key_pressed(move |_, key, _code, modifier| {
        use gtk4::gdk::Key;
        use gtk4::gdk::ModifierType;

        let ctrl = modifier.contains(ModifierType::CONTROL_MASK);

        if ctrl {
            match key {
                Key::_1 => { vs.set_visible_child_name("flow"); return glib::Propagation::Stop; },
                Key::_2 => { vs.set_visible_child_name("focus"); return glib::Propagation::Stop; },
                Key::_3 => { vs.set_visible_child_name("writer"); return glib::Propagation::Stop; },
                Key::_4 => { vs.set_visible_child_name("letters"); return glib::Propagation::Stop; },
                Key::_5 => { vs.set_visible_child_name("canvas"); return glib::Propagation::Stop; },
                Key::_6 => { vs.set_visible_child_name("wellness"); return glib::Propagation::Stop; },
                _ => {}
            }
        }

        if key == Key::F11 {
            if win.is_fullscreen() {
                win.unfullscreen();
            } else {
                win.fullscreen();
            }
            return glib::Propagation::Stop;
        }

        if key == Key::Escape {
            if win.is_fullscreen() {
                win.unfullscreen();
            }
            return glib::Propagation::Stop;
        }

        glib::Propagation::Proceed
    });

    window.add_controller(controller);
}

// =============================================================================
// D-Bus Notification Integration
// =============================================================================

fn setup_dbus_notifications() {
    // In production, we would use zbus to connect to
    // org.freedesktop.Notifications for calm notification delivery.
    // Resonance notifications are:
    // - Low urgency (no sound by default)
    // - Transient (disappear after viewing)
    // - Grouped by phase/domain
    log::info!("D-Bus notification integration ready.");
}

/// Send a calm notification via D-Bus.
pub fn send_calm_notification(summary: &str, body: &str) {
    // Using gio's notification API as a fallback
    let notification = gio::Notification::new(summary);
    notification.set_body(Some(body));
    notification.set_priority(gio::NotificationPriority::Low);

    if let Some(app) = gio::Application::default() {
        app.send_notification(Some("resonance-notification"), &notification);
    }
}

// =============================================================================
// About Dialog
// =============================================================================

fn show_about_dialog(window: &ApplicationWindow) {
    let about = AboutWindow::builder()
        .application_name("Resonance")
        .version(APP_VERSION)
        .developer_name("Resonance UX Team")
        .license_type(gtk4::License::MitX11)
        .website("https://resonance.app")
        .issue_url("https://github.com/resonance-ux/linux/issues")
        .comments("Calm, intentional digital experiences.")
        .transient_for(window)
        .build();

    about.add_acknowledgement_section(
        Some("Design Philosophy"),
        &["Spaciousness over density", "Intention over impulse", "Calm over urgency"],
    );

    about.present();
}
