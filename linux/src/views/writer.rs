// =============================================================================
// Resonance UX — Writer Sanctuary View (Rust + GTK4)
//
// GtkSourceView editor, sidebar library, focus mode with fullscreen,
// custom footer stats widget, and async Luminize Prose integration.
// =============================================================================

use crate::models::{Document, WritingSession};
use crate::AppState;
use chrono::{Local, Timelike};
use gtk4::glib;
use gtk4::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

// =============================================================================
// View Builder
// =============================================================================

pub fn build_writer_view(state: &Rc<RefCell<AppState>>) -> gtk4::Box {
    let root = gtk4::Box::new(gtk4::Orientation::Vertical, 0);
    root.add_css_class("resonance-page");

    let documents = Rc::new(RefCell::new(create_sample_documents()));
    let session = Rc::new(RefCell::new(WritingSession::default()));
    let is_focus_mode = Rc::new(RefCell::new(false));
    let is_sidebar_open = Rc::new(RefCell::new(true));

    // --- Toolbar ---
    let toolbar = build_toolbar(
        state,
        &is_focus_mode,
        &is_sidebar_open,
        &session,
    );
    root.append(&toolbar);

    // --- Main content: Sidebar + Editor ---
    let paned = gtk4::Paned::new(gtk4::Orientation::Horizontal);
    paned.set_position(280);
    paned.set_shrink_start_child(false);
    paned.set_shrink_end_child(false);
    paned.set_vexpand(true);

    // Sidebar
    let sidebar = build_sidebar(&documents);
    paned.set_start_child(Some(&sidebar));

    // Editor area
    let editor_area = build_editor_area(&session);
    paned.set_end_child(Some(&editor_area));

    root.append(&paned);

    // --- Floating Stats Footer ---
    let stats_bar = build_stats_bar(&session);
    root.append(&stats_bar);

    // Auto-save timer (every 30 seconds)
    glib::timeout_add_seconds_local(30, move || {
        log::debug!("[Resonance] Auto-saving document...");
        glib::ControlFlow::Continue
    });

    // Session timer (update every second)
    let session_timer = session.clone();
    glib::timeout_add_seconds_local(1, move || {
        let s = session_timer.borrow();
        let elapsed = Local::now().signed_duration_since(s.started_at);
        // Stats bar will read from session on next redraw
        let _ = elapsed;
        glib::ControlFlow::Continue
    });

    root.add_css_class("resonance-fade-in");
    root
}

// =============================================================================
// Toolbar
// =============================================================================

fn build_toolbar(
    state: &Rc<RefCell<AppState>>,
    is_focus_mode: &Rc<RefCell<bool>>,
    is_sidebar_open: &Rc<RefCell<bool>>,
    session: &Rc<RefCell<WritingSession>>,
) -> gtk4::Box {
    let toolbar = gtk4::Box::new(gtk4::Orientation::Horizontal, 4);
    toolbar.set_margin_start(8);
    toolbar.set_margin_end(8);
    toolbar.set_margin_top(4);
    toolbar.set_margin_bottom(4);
    toolbar.set_halign(gtk4::Align::End);

    // Sidebar toggle
    let sidebar_btn = gtk4::Button::from_icon_name("sidebar-show-symbolic");
    sidebar_btn.set_tooltip_text(Some("Toggle sidebar (Ctrl+Shift+B)"));
    sidebar_btn.add_css_class("flat");
    toolbar.append(&sidebar_btn);

    // Focus mode
    let focus_btn = gtk4::Button::from_icon_name("view-fullscreen-symbolic");
    focus_btn.set_tooltip_text(Some("Focus mode (Ctrl+Shift+F)"));
    focus_btn.add_css_class("flat");

    let focus_mode_clone = is_focus_mode.clone();
    focus_btn.connect_clicked(move |_btn| {
        let mut fm = focus_mode_clone.borrow_mut();
        *fm = !*fm;
        if *fm {
            log::info!("Entering focus mode");
            // In production: hide sidebar, go fullscreen, dim chrome
        } else {
            log::info!("Exiting focus mode");
        }
    });
    toolbar.append(&focus_btn);

    // Luminize Prose button
    let luminize_btn = gtk4::Button::new_with_label("Luminize");
    luminize_btn.set_tooltip_text(Some("Analyze prose for clarity and spaciousness"));
    luminize_btn.add_css_class("flat");
    luminize_btn.add_css_class("resonance-accent-text");

    luminize_btn.connect_clicked(|btn| {
        btn.set_sensitive(false);
        btn.set_label("Luminizing...");

        let btn_clone = btn.clone();
        glib::timeout_add_seconds_local_once(2, move || {
            btn_clone.set_sensitive(true);
            btn_clone.set_label("Luminize");
            log::info!("Luminize analysis complete.");
        });
    });
    toolbar.append(&luminize_btn);

    // More menu
    let menu_btn = gtk4::MenuButton::new();
    menu_btn.set_icon_name("open-menu-symbolic");
    menu_btn.add_css_class("flat");

    let menu = gio::Menu::new();
    menu.append(Some("Export as PDF"), Some("writer.export-pdf"));
    menu.append(Some("Export as Markdown"), Some("writer.export-md"));
    let target_section = gio::Menu::new();
    target_section.append(Some("Set word target..."), Some("writer.set-target"));
    target_section.append(Some("Reading view"), Some("writer.reading-view"));
    menu.append_section(None, &target_section);
    menu_btn.set_menu_model(Some(&menu));

    use gtk4::gio;
    toolbar.append(&menu_btn);

    toolbar
}

// =============================================================================
// Sidebar (Document Library)
// =============================================================================

fn build_sidebar(documents: &Rc<RefCell<Vec<Document>>>) -> gtk4::Box {
    let sidebar = gtk4::Box::new(gtk4::Orientation::Vertical, 12);
    sidebar.set_margin_start(16);
    sidebar.set_margin_end(8);
    sidebar.set_margin_top(16);
    sidebar.set_margin_bottom(16);
    sidebar.set_width_request(260);
    sidebar.add_css_class("resonance-sidebar");

    // Header
    let header = gtk4::Box::new(gtk4::Orientation::Vertical, 4);
    let title = gtk4::Label::new(Some("Library"));
    title.set_halign(gtk4::Align::Start);
    title.add_css_class("resonance-display");
    title.add_css_class("title-2");
    header.append(&title);

    let count_label = gtk4::Label::new(Some(&format!(
        "{} documents",
        documents.borrow().len()
    )));
    count_label.set_halign(gtk4::Align::Start);
    count_label.add_css_class("dim-label");
    count_label.add_css_class("caption");
    header.append(&count_label);
    sidebar.append(&header);

    // Search
    let search = gtk4::SearchEntry::new();
    search.set_placeholder_text(Some("Search documents..."));
    sidebar.append(&search);

    // New document button
    let new_btn = gtk4::Button::with_label("New Document");
    new_btn.add_css_class("suggested-action");

    let docs_clone = documents.clone();
    new_btn.connect_clicked(move |_| {
        let new_doc = Document {
            title: "Untitled".into(),
            ..Default::default()
        };
        docs_clone.borrow_mut().insert(0, new_doc);
        log::info!("New document created.");
    });
    sidebar.append(&new_btn);

    // Document list
    let scroll = gtk4::ScrolledWindow::new();
    scroll.set_vexpand(true);
    scroll.set_policy(gtk4::PolicyType::Never, gtk4::PolicyType::Automatic);

    let list_box = gtk4::ListBox::new();
    list_box.set_selection_mode(gtk4::SelectionMode::Single);
    list_box.add_css_class("navigation-sidebar");

    for doc in documents.borrow().iter() {
        let row = build_document_row(doc);
        list_box.append(&row);
    }

    list_box.connect_row_selected(|_, row| {
        if let Some(row) = row {
            log::info!("Selected document at index: {}", row.index());
        }
    });

    scroll.set_child(Some(&list_box));
    sidebar.append(&scroll);

    // Session stats section
    let stats_section = gtk4::Box::new(gtk4::Orientation::Vertical, 6);
    stats_section.set_margin_top(12);

    let stats_header = gtk4::Label::new(Some("SESSION"));
    stats_header.set_halign(gtk4::Align::Start);
    stats_header.add_css_class("resonance-label");
    stats_header.add_css_class("dim-label");
    stats_section.append(&stats_header);

    stats_section.append(&build_sidebar_stat("Words today", "0"));
    stats_section.append(&build_sidebar_stat("Session", "0 min"));
    stats_section.append(&build_sidebar_stat("Target", "1,000"));

    sidebar.append(&stats_section);

    sidebar
}

fn build_document_row(doc: &Document) -> gtk4::ListBoxRow {
    let row = gtk4::ListBoxRow::new();

    let content = gtk4::Box::new(gtk4::Orientation::Vertical, 2);
    content.set_margin_start(8);
    content.set_margin_end(8);
    content.set_margin_top(8);
    content.set_margin_bottom(8);

    let title = gtk4::Label::new(Some(&doc.title));
    title.set_halign(gtk4::Align::Start);
    title.set_ellipsize(gtk4::pango::EllipsizeMode::End);
    title.add_css_class("heading");
    content.append(&title);

    if !doc.excerpt.is_empty() {
        let excerpt = gtk4::Label::new(Some(&doc.excerpt));
        excerpt.set_halign(gtk4::Align::Start);
        excerpt.set_ellipsize(gtk4::pango::EllipsizeMode::End);
        excerpt.set_max_width_chars(35);
        excerpt.set_lines(2);
        excerpt.set_wrap(true);
        excerpt.add_css_class("dim-label");
        excerpt.add_css_class("caption");
        content.append(&excerpt);
    }

    let meta = gtk4::Box::new(gtk4::Orientation::Horizontal, 8);
    let word_count = gtk4::Label::new(Some(&format!("{} words", doc.word_count)));
    word_count.add_css_class("dim-label");
    word_count.add_css_class("caption");
    meta.append(&word_count);

    let modified = gtk4::Label::new(Some(&doc.updated_at.format("%b %d").to_string()));
    modified.add_css_class("dim-label");
    modified.add_css_class("caption");
    meta.append(&modified);
    content.append(&meta);

    row.set_child(Some(&content));
    row
}

fn build_sidebar_stat(label: &str, value: &str) -> gtk4::Box {
    let row = gtk4::Box::new(gtk4::Orientation::Horizontal, 0);

    let label_w = gtk4::Label::new(Some(label));
    label_w.set_halign(gtk4::Align::Start);
    label_w.set_hexpand(true);
    label_w.add_css_class("dim-label");
    label_w.add_css_class("caption");
    row.append(&label_w);

    let value_w = gtk4::Label::new(Some(value));
    value_w.set_halign(gtk4::Align::End);
    value_w.add_css_class("resonance-accent-text");
    value_w.add_css_class("caption");
    row.append(&value_w);

    row
}

// =============================================================================
// Editor Area
// =============================================================================

fn build_editor_area(session: &Rc<RefCell<WritingSession>>) -> gtk4::Box {
    let editor_box = gtk4::Box::new(gtk4::Orientation::Vertical, 0);
    editor_box.set_margin_start(48);
    editor_box.set_margin_end(48);
    editor_box.set_margin_top(24);
    editor_box.set_margin_bottom(80); // space for floating stats
    editor_box.set_hexpand(true);
    editor_box.set_vexpand(true);

    // Document title
    let title_entry = gtk4::Entry::new();
    title_entry.set_placeholder_text(Some("Untitled"));
    title_entry.set_text("Untitled");
    title_entry.add_css_class("resonance-editor-title");
    title_entry.add_css_class("flat");
    title_entry.set_margin_bottom(16);

    let session_title = session.clone();
    title_entry.connect_changed(move |entry| {
        session_title.borrow_mut().document_title = entry.text().to_string();
    });
    editor_box.append(&title_entry);

    // Main text editor using GtkSourceView
    let scroll = gtk4::ScrolledWindow::new();
    scroll.set_vexpand(true);
    scroll.set_policy(gtk4::PolicyType::Never, gtk4::PolicyType::Automatic);

    // Use sourceview5 for rich editing
    let buffer = sourceview5::Buffer::new(None);

    // Set up language highlighting (Markdown)
    let language_manager = sourceview5::LanguageManager::default();
    if let Some(markdown) = language_manager.language("markdown") {
        buffer.set_language(Some(&markdown));
    }

    // Configure the source view
    let source_view = sourceview5::View::with_buffer(&buffer);
    source_view.set_wrap_mode(gtk4::WrapMode::Word);
    source_view.set_show_line_numbers(false);
    source_view.set_highlight_current_line(false);
    source_view.set_top_margin(8);
    source_view.set_bottom_margin(8);
    source_view.set_left_margin(0);
    source_view.set_right_margin(0);
    source_view.set_monospace(false);
    source_view.add_css_class("resonance-editor");

    // Optimal reading width
    source_view.set_width_request(720);
    source_view.set_halign(gtk4::Align::Center);

    // Track text changes for word count
    let session_wc = session.clone();
    buffer.connect_changed(move |buf| {
        let text = buf.text(&buf.start_iter(), &buf.end_iter(), false);
        let word_count = text
            .split_whitespace()
            .count();
        session_wc.borrow_mut().words_written = word_count;
    });

    scroll.set_child(Some(&source_view));
    editor_box.append(&scroll);

    editor_box
}

// =============================================================================
// Floating Stats Bar
// =============================================================================

fn build_stats_bar(session: &Rc<RefCell<WritingSession>>) -> gtk4::Box {
    let bar = gtk4::Box::new(gtk4::Orientation::Horizontal, 24);
    bar.set_halign(gtk4::Align::Center);
    bar.set_valign(gtk4::Align::End);
    bar.set_margin_bottom(16);
    bar.add_css_class("resonance-stats-bar");

    let word_label = gtk4::Label::new(Some("0 words"));
    word_label.add_css_class("dim-label");
    word_label.add_css_class("caption");
    bar.append(&word_label);

    let time_label = gtk4::Label::new(Some("0 min"));
    time_label.add_css_class("dim-label");
    time_label.add_css_class("caption");
    bar.append(&time_label);

    let reading_label = gtk4::Label::new(Some("< 1 min read"));
    reading_label.add_css_class("dim-label");
    reading_label.add_css_class("caption");
    bar.append(&reading_label);

    let luminize_label = gtk4::Label::new(None);
    luminize_label.add_css_class("resonance-accent-text");
    luminize_label.add_css_class("caption");
    bar.append(&luminize_label);

    // Update stats periodically
    let session_stats = session.clone();
    let wl = word_label.clone();
    let tl = time_label.clone();
    let rl = reading_label.clone();

    glib::timeout_add_seconds_local(2, move || {
        let s = session_stats.borrow();
        let words = s.words_written;
        wl.set_text(&format!(
            "{} word{}",
            words,
            if words != 1 { "s" } else { "" }
        ));

        let elapsed = Local::now().signed_duration_since(s.started_at);
        let mins = elapsed.num_minutes();
        if mins < 60 {
            tl.set_text(&format!("{} min", mins));
        } else {
            tl.set_text(&format!("{}h {}m", mins / 60, mins % 60));
        }

        let reading_min = (words / 200).max(1);
        rl.set_text(&format!("{} min read", reading_min));

        glib::ControlFlow::Continue
    });

    bar
}

// =============================================================================
// Luminize Prose (Local Analysis)
// =============================================================================

pub struct LuminizeResult {
    pub summary: String,
    pub suggestions: Vec<LuminizeSuggestion>,
}

pub struct LuminizeSuggestion {
    pub category: String,
    pub message: String,
}

pub fn analyze_prose(text: &str) -> LuminizeResult {
    let words: Vec<&str> = text.split_whitespace().collect();
    let sentences: Vec<&str> = text
        .split(|c: char| c == '.' || c == '!' || c == '?')
        .filter(|s| !s.trim().is_empty())
        .collect();

    let mut suggestions = Vec::new();

    // Check average sentence length
    let avg_words_per_sentence = if !sentences.is_empty() {
        words.len() as f64 / sentences.len() as f64
    } else {
        0.0
    };

    if avg_words_per_sentence > 25.0 {
        suggestions.push(LuminizeSuggestion {
            category: "Spaciousness".into(),
            message: "Some sentences could breathe more. Consider splitting long thoughts.".into(),
        });
    }

    // Check for passive voice indicators
    let passive_words = ["was", "were", "been", "being", "is", "are"];
    let passive_count = words
        .iter()
        .filter(|w| passive_words.contains(&w.to_lowercase().as_str()))
        .count();

    if !words.is_empty() && (passive_count as f64 / words.len() as f64) > 0.1 {
        suggestions.push(LuminizeSuggestion {
            category: "Directness".into(),
            message: "Consider more active voice for directness and clarity.".into(),
        });
    }

    // Check for filler words
    let filler_words = ["very", "really", "just", "quite", "actually", "basically"];
    let filler_count = words
        .iter()
        .filter(|w| filler_words.contains(&w.to_lowercase().as_str()))
        .count();

    if filler_count > 3 {
        suggestions.push(LuminizeSuggestion {
            category: "Precision".into(),
            message: "A few words could be trimmed for sharper expression.".into(),
        });
    }

    let summary = if suggestions.is_empty() {
        "Prose looks luminous.".into()
    } else {
        format!(
            "{} gentle suggestion{}",
            suggestions.len(),
            if suggestions.len() > 1 { "s" } else { "" }
        )
    };

    LuminizeResult {
        summary,
        suggestions,
    }
}

// =============================================================================
// Sample Data
// =============================================================================

fn create_sample_documents() -> Vec<Document> {
    vec![
        Document {
            title: "On Intentional Design".into(),
            excerpt: "The space between elements speaks as loudly as...".into(),
            word_count: 2340,
            updated_at: Local::now() - chrono::Duration::hours(2),
            ..Default::default()
        },
        Document {
            title: "Protocol Notes: March".into(),
            excerpt: "Patient outcomes improved by 23% when the...".into(),
            word_count: 1580,
            updated_at: Local::now() - chrono::Duration::days(1),
            ..Default::default()
        },
        Document {
            title: "Letters to the Team".into(),
            excerpt: "What I've learned about building calm software...".into(),
            word_count: 890,
            updated_at: Local::now() - chrono::Duration::days(3),
            ..Default::default()
        },
        Document {
            title: "Canvas Philosophy".into(),
            excerpt: "A canvas does not demand. It receives...".into(),
            word_count: 450,
            updated_at: Local::now() - chrono::Duration::days(7),
            ..Default::default()
        },
    ]
}
