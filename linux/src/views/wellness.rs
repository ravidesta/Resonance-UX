// =============================================================================
// Resonance UX — Wellness Dashboard View (Rust + GTK4)
//
// Multi-pane layout with GtkGrid, custom Cairo biomarker charts,
// provider/patient view switching, encrypted messaging panel,
// and protocol deployment interface.
// =============================================================================

use crate::models::{
    Biomarker, BiomarkerCategory, Patient, Protocol, ProtocolStatus, Provider,
    RiskLevel, TrendDirection,
};
use crate::AppState;
use gtk4::glib;
use gtk4::prelude::*;
use std::cell::RefCell;
use std::f64::consts::PI;
use std::rc::Rc;

// =============================================================================
// View Builder
// =============================================================================

pub fn build_wellness_view(state: &Rc<RefCell<AppState>>) -> gtk4::Box {
    let root = gtk4::Box::new(gtk4::Orientation::Vertical, 0);
    root.add_css_class("resonance-page");
    root.set_margin_start(24);
    root.set_margin_end(24);
    root.set_margin_top(16);
    root.set_margin_bottom(16);

    let provider = create_sample_provider();
    let patients = Rc::new(RefCell::new(create_sample_patients()));
    let selected_patient: Rc<RefCell<Option<usize>>> = Rc::new(RefCell::new(None));

    // --- Header ---
    let header = build_header(&provider);
    root.append(&header);

    // --- Metrics Bar ---
    let metrics = build_metrics_bar();
    root.append(&metrics);

    // --- Main content: Patient List + Detail Pane ---
    let main_paned = gtk4::Paned::new(gtk4::Orientation::Horizontal);
    main_paned.set_position(380);
    main_paned.set_vexpand(true);
    main_paned.set_shrink_start_child(false);
    main_paned.set_shrink_end_child(false);

    // Left: patient list
    let patient_panel = build_patient_panel(&patients, &selected_patient);
    main_paned.set_start_child(Some(&patient_panel));

    // Right: detail pane (biomarkers, protocols, messaging)
    let detail_pane = build_detail_pane(&patients, &selected_patient);
    main_paned.set_end_child(Some(&detail_pane));

    root.append(&main_paned);
    root.add_css_class("resonance-fade-in");
    root
}

// =============================================================================
// Header
// =============================================================================

fn build_header(provider: &Provider) -> gtk4::Box {
    let header = gtk4::Box::new(gtk4::Orientation::Horizontal, 0);
    header.set_margin_bottom(16);

    let title_box = gtk4::Box::new(gtk4::Orientation::Vertical, 2);
    title_box.set_hexpand(true);

    let title = gtk4::Label::new(Some("Wellness Dashboard"));
    title.set_halign(gtk4::Align::Start);
    title.add_css_class("resonance-display");
    title.add_css_class("title-1");
    title_box.append(&title);

    let subtitle = gtk4::Label::new(Some(&format!(
        "{} \u{2022} {}",
        provider.display_name(),
        provider.specialty
    )));
    subtitle.set_halign(gtk4::Align::Start);
    subtitle.add_css_class("dim-label");
    subtitle.add_css_class("resonance-body");
    title_box.append(&subtitle);

    header.append(&title_box);

    // View toggle buttons
    let toggle_box = gtk4::Box::new(gtk4::Orientation::Horizontal, 4);
    toggle_box.set_valign(gtk4::Align::Center);
    toggle_box.add_css_class("linked");

    for label in &["Overview", "Patients", "Admin"] {
        let btn = gtk4::ToggleButton::with_label(label);
        btn.add_css_class("flat");
        if *label == "Overview" {
            btn.set_active(true);
        }
        toggle_box.append(&btn);
    }
    header.append(&toggle_box);

    header
}

// =============================================================================
// Metrics Bar
// =============================================================================

fn build_metrics_bar() -> gtk4::Box {
    let bar = gtk4::Box::new(gtk4::Orientation::Horizontal, 12);
    bar.set_margin_bottom(16);
    bar.set_homogeneous(true);

    let metrics = [
        ("PATIENTS TODAY", "4/6", false),
        ("AVG ENCOUNTER", "35 min", false),
        ("SATISFACTION", "4.8", true),
        ("PROTOCOLS", "3", false),
        ("REVENUE", "$3,240", false),
        ("OPEN CLAIMS", "12", false),
    ];

    for (label, value, highlight) in metrics {
        bar.append(&build_metric_card(label, value, highlight));
    }

    bar
}

fn build_metric_card(label: &str, value: &str, highlight: bool) -> gtk4::Frame {
    let frame = gtk4::Frame::new(None);
    frame.add_css_class("resonance-card");

    let card = gtk4::Box::new(gtk4::Orientation::Vertical, 2);
    card.set_margin_start(14);
    card.set_margin_end(14);
    card.set_margin_top(10);
    card.set_margin_bottom(10);

    let label_w = gtk4::Label::new(Some(label));
    label_w.set_halign(gtk4::Align::Start);
    label_w.add_css_class("resonance-label");
    label_w.add_css_class("dim-label");
    card.append(&label_w);

    let value_w = gtk4::Label::new(Some(value));
    value_w.set_halign(gtk4::Align::Start);
    value_w.add_css_class("title-3");
    value_w.add_css_class("resonance-display");
    if highlight {
        value_w.add_css_class("resonance-accent");
    }
    card.append(&value_w);

    frame.set_child(Some(&card));
    frame
}

// =============================================================================
// Patient Panel (Left Pane)
// =============================================================================

fn build_patient_panel(
    patients: &Rc<RefCell<Vec<Patient>>>,
    selected: &Rc<RefCell<Option<usize>>>,
) -> gtk4::Box {
    let panel = gtk4::Box::new(gtk4::Orientation::Vertical, 12);
    panel.set_margin_end(8);

    // Search
    let search = gtk4::SearchEntry::new();
    search.set_placeholder_text(Some("Search patients..."));
    panel.append(&search);

    // Patient list
    let scroll = gtk4::ScrolledWindow::new();
    scroll.set_vexpand(true);
    scroll.set_policy(gtk4::PolicyType::Never, gtk4::PolicyType::Automatic);

    let list_box = gtk4::ListBox::new();
    list_box.set_selection_mode(gtk4::SelectionMode::Single);
    list_box.add_css_class("boxed-list");

    for (i, patient) in patients.borrow().iter().enumerate() {
        let row = build_patient_row(patient);
        list_box.append(&row);
    }

    let selected_clone = selected.clone();
    list_box.connect_row_selected(move |_, row| {
        if let Some(row) = row {
            *selected_clone.borrow_mut() = Some(row.index() as usize);
            log::info!("Selected patient index: {}", row.index());
        }
    });

    scroll.set_child(Some(&list_box));
    panel.append(&scroll);

    // Recent encounters summary
    let encounters_frame = gtk4::Frame::new(None);
    encounters_frame.add_css_class("resonance-card");

    let enc_box = gtk4::Box::new(gtk4::Orientation::Vertical, 6);
    enc_box.set_margin_start(14);
    enc_box.set_margin_end(14);
    enc_box.set_margin_top(10);
    enc_box.set_margin_bottom(10);

    let enc_header = gtk4::Label::new(Some("RECENT ENCOUNTERS"));
    enc_header.set_halign(gtk4::Align::Start);
    enc_header.add_css_class("resonance-label");
    enc_header.add_css_class("dim-label");
    enc_box.append(&enc_header);

    let encounters = [
        ("Lisa Park", "Protocol Review", "1 hr ago"),
        ("David Chen", "Initial Assessment", "2 hrs ago"),
        ("Emma Wilson", "Follow-up", "3.5 hrs ago"),
    ];

    for (name, enc_type, time) in encounters {
        let row = gtk4::Box::new(gtk4::Orientation::Horizontal, 0);
        row.set_margin_top(4);

        let info = gtk4::Box::new(gtk4::Orientation::Vertical, 0);
        info.set_hexpand(true);

        let name_l = gtk4::Label::new(Some(name));
        name_l.set_halign(gtk4::Align::Start);
        name_l.add_css_class("heading");
        info.append(&name_l);

        let type_l = gtk4::Label::new(Some(enc_type));
        type_l.set_halign(gtk4::Align::Start);
        type_l.add_css_class("dim-label");
        type_l.add_css_class("caption");
        info.append(&type_l);

        row.append(&info);

        let time_l = gtk4::Label::new(Some(time));
        time_l.add_css_class("dim-label");
        time_l.add_css_class("caption");
        time_l.set_valign(gtk4::Align::Center);
        row.append(&time_l);

        enc_box.append(&row);
    }

    encounters_frame.set_child(Some(&enc_box));
    panel.append(&encounters_frame);

    panel
}

fn build_patient_row(patient: &Patient) -> libadwaita::ActionRow {
    let row = libadwaita::ActionRow::new();
    row.set_title(&patient.full_name());
    row.set_subtitle(&format!(
        "Age {} \u{2022} {}",
        patient.age, patient.primary_condition
    ));

    // Risk level indicator
    let risk_dot = gtk4::DrawingArea::new();
    risk_dot.set_content_width(12);
    risk_dot.set_content_height(12);

    let risk = patient.risk_level;
    risk_dot.set_draw_func(move |_, cr, w, h| {
        let (r, g, b) = match risk {
            RiskLevel::Minimal => (0.5, 0.8, 0.6),
            RiskLevel::Low => (0.66, 0.78, 0.70),
            RiskLevel::Moderate => (0.77, 0.63, 0.35),
            RiskLevel::High => (0.78, 0.47, 0.31),
            RiskLevel::Critical => (0.82, 0.30, 0.28),
        };
        cr.set_source_rgb(r, g, b);
        cr.arc(w as f64 / 2.0, h as f64 / 2.0, 5.0, 0.0, 2.0 * PI);
        let _ = cr.fill();
    });
    row.add_suffix(&risk_dot);

    // Status label
    let status = gtk4::Label::new(Some(&patient.status));
    status.add_css_class("resonance-accent-text");
    status.add_css_class("caption");
    row.add_suffix(&status);

    row
}

// =============================================================================
// Detail Pane (Right: Biomarkers, Protocols, Messaging)
// =============================================================================

fn build_detail_pane(
    patients: &Rc<RefCell<Vec<Patient>>>,
    selected: &Rc<RefCell<Option<usize>>>,
) -> gtk4::Box {
    let pane = gtk4::Box::new(gtk4::Orientation::Vertical, 12);
    pane.set_margin_start(8);

    // Show first patient by default for demo
    let patients_ref = patients.borrow();
    if let Some(patient) = patients_ref.first() {
        // Patient header
        let header = build_patient_detail_header(patient);
        pane.append(&header);

        // Biomarker grid
        let biomarkers = build_biomarker_grid(&patient.biomarkers);
        pane.append(&biomarkers);

        // Protocol actions
        let actions = build_protocol_actions(patient);
        pane.append(&actions);
    } else {
        // Placeholder
        let placeholder = gtk4::Label::new(Some("Select a patient to view details"));
        placeholder.set_valign(gtk4::Align::Center);
        placeholder.set_vexpand(true);
        placeholder.add_css_class("dim-label");
        pane.append(&placeholder);
    }

    pane
}

fn build_patient_detail_header(patient: &Patient) -> gtk4::Frame {
    let frame = gtk4::Frame::new(None);
    frame.add_css_class("resonance-card");

    let header = gtk4::Box::new(gtk4::Orientation::Horizontal, 0);
    header.set_margin_start(16);
    header.set_margin_end(16);
    header.set_margin_top(14);
    header.set_margin_bottom(14);

    let info = gtk4::Box::new(gtk4::Orientation::Vertical, 2);
    info.set_hexpand(true);

    let name = gtk4::Label::new(Some(&patient.full_name()));
    name.set_halign(gtk4::Align::Start);
    name.add_css_class("resonance-display");
    name.add_css_class("title-2");
    info.append(&name);

    let details = gtk4::Label::new(Some(&format!(
        "Age {} \u{2022} {} \u{2022} {}",
        patient.age, patient.primary_condition, patient.status
    )));
    details.set_halign(gtk4::Align::Start);
    details.add_css_class("dim-label");
    details.add_css_class("resonance-body");
    info.append(&details);

    let next = gtk4::Label::new(Some("Next: in 1 hr"));
    next.set_halign(gtk4::Align::Start);
    next.add_css_class("resonance-accent-text");
    next.add_css_class("caption");
    info.append(&next);

    header.append(&info);

    // Action buttons
    let btn_box = gtk4::Box::new(gtk4::Orientation::Horizontal, 4);
    btn_box.set_valign(gtk4::Align::Center);

    for icon in &[
        "mail-unread-symbolic",
        "text-editor-symbolic",
        "emblem-system-symbolic",
    ] {
        let btn = gtk4::Button::from_icon_name(*icon);
        btn.add_css_class("flat");
        btn.add_css_class("circular");
        btn_box.append(&btn);
    }
    header.append(&btn_box);

    frame.set_child(Some(&header));
    frame
}

// =============================================================================
// Biomarker Grid with Cairo Charts
// =============================================================================

fn build_biomarker_grid(biomarkers: &[Biomarker]) -> gtk4::ScrolledWindow {
    let scroll = gtk4::ScrolledWindow::new();
    scroll.set_vexpand(true);
    scroll.set_policy(gtk4::PolicyType::Never, gtk4::PolicyType::Automatic);

    let grid = gtk4::Grid::new();
    grid.set_column_spacing(12);
    grid.set_row_spacing(12);
    grid.set_column_homogeneous(true);

    let cols = 2;
    for (i, biomarker) in biomarkers.iter().enumerate() {
        let card = build_biomarker_card(biomarker);
        grid.attach(&card, (i % cols) as i32, (i / cols) as i32, 1, 1);
    }

    scroll.set_child(Some(&grid));
    scroll
}

fn build_biomarker_card(biomarker: &Biomarker) -> gtk4::Frame {
    let frame = gtk4::Frame::new(None);
    frame.add_css_class("resonance-card");

    let card = gtk4::Box::new(gtk4::Orientation::Vertical, 6);
    card.set_margin_start(14);
    card.set_margin_end(14);
    card.set_margin_top(12);
    card.set_margin_bottom(12);

    // Header with name and trend
    let header = gtk4::Box::new(gtk4::Orientation::Horizontal, 0);

    let name = gtk4::Label::new(Some(&biomarker.name));
    name.set_halign(gtk4::Align::Start);
    name.set_hexpand(true);
    name.add_css_class("heading");
    header.append(&name);

    let trend_icon = match biomarker.trend {
        TrendDirection::Improving => "\u{2191}",   // up arrow
        TrendDirection::Declining => "\u{2193}",   // down arrow
        _ => "\u{2192}",                           // right arrow
    };
    let trend_label = gtk4::Label::new(Some(trend_icon));
    match biomarker.trend {
        TrendDirection::Improving => trend_label.add_css_class("success"),
        TrendDirection::Declining => trend_label.add_css_class("error"),
        _ => trend_label.add_css_class("dim-label"),
    };
    header.append(&trend_label);
    card.append(&header);

    // Value
    let value_box = gtk4::Box::new(gtk4::Orientation::Horizontal, 4);

    let value_label = gtk4::Label::new(Some(&format!("{:.1}", biomarker.value)));
    value_label.add_css_class("resonance-display");
    value_label.add_css_class("title-1");
    if !biomarker.is_in_range() {
        value_label.add_css_class("resonance-accent");
    }
    value_box.append(&value_label);

    let unit_label = gtk4::Label::new(Some(&biomarker.unit));
    unit_label.add_css_class("dim-label");
    unit_label.add_css_class("caption");
    unit_label.set_valign(gtk4::Align::End);
    unit_label.set_margin_bottom(6);
    value_box.append(&unit_label);
    card.append(&value_box);

    // Target
    let target = gtk4::Label::new(Some(&format!(
        "Target: {:.1} {}",
        biomarker.optimal_value, biomarker.unit
    )));
    target.set_halign(gtk4::Align::Start);
    target.add_css_class("dim-label");
    target.add_css_class("caption");
    card.append(&target);

    // Sparkline chart (Cairo)
    let history = biomarker.history.clone();
    let chart = gtk4::DrawingArea::new();
    chart.set_content_height(40);
    chart.set_margin_top(4);

    chart.set_draw_func(move |_, cr, width, height| {
        draw_sparkline(cr, width as f64, height as f64, &history);
    });
    card.append(&chart);

    frame.set_child(Some(&card));
    frame
}

fn draw_sparkline(cr: &cairo::Context, width: f64, height: f64, data: &[f64]) {
    if data.is_empty() {
        return;
    }

    let padding = 4.0;
    let usable_w = width - 2.0 * padding;
    let usable_h = height - 2.0 * padding;

    let min_val = data.iter().cloned().fold(f64::INFINITY, f64::min) * 0.9;
    let max_val = data.iter().cloned().fold(f64::NEG_INFINITY, f64::max) * 1.1;
    let range = (max_val - min_val).max(0.001);

    let bar_width = (usable_w / data.len() as f64) - 3.0;

    for (i, &val) in data.iter().enumerate() {
        let normalized = (val - min_val) / range;
        let bar_height = (normalized * usable_h).max(4.0);
        let x = padding + i as f64 * (bar_width + 3.0);
        let y = height - padding - bar_height;

        let is_last = i == data.len() - 1;
        if is_last {
            cr.set_source_rgba(0.77, 0.63, 0.35, 1.0); // Gold for latest
        } else {
            cr.set_source_rgba(0.77, 0.63, 0.35, 0.25); // Faded gold for history
        }

        // Rounded top bar
        let radius = 3.0_f64.min(bar_width / 2.0);
        cr.new_path();
        cr.arc(x + radius, y + radius, radius, PI, 1.5 * PI);
        cr.arc(x + bar_width - radius, y + radius, radius, 1.5 * PI, 2.0 * PI);
        cr.line_to(x + bar_width, y + bar_height);
        cr.line_to(x, y + bar_height);
        cr.close_path();
        let _ = cr.fill();
    }
}

// =============================================================================
// Protocol Actions
// =============================================================================

fn build_protocol_actions(patient: &Patient) -> gtk4::Frame {
    let frame = gtk4::Frame::new(None);
    frame.add_css_class("resonance-card");

    let actions = gtk4::Box::new(gtk4::Orientation::Horizontal, 8);
    actions.set_margin_start(14);
    actions.set_margin_end(14);
    actions.set_margin_top(10);
    actions.set_margin_bottom(10);

    let deploy_btn = gtk4::Button::with_label("Deploy Protocol");
    deploy_btn.add_css_class("suggested-action");

    let patient_name = patient.full_name();
    deploy_btn.connect_clicked(move |_| {
        log::info!("Deploying protocol for: {}", patient_name);
    });
    actions.append(&deploy_btn);

    let labs_btn = gtk4::Button::with_label("Order Labs");
    labs_btn.add_css_class("flat");
    actions.append(&labs_btn);

    let msg_btn = gtk4::Button::with_label("Send Message");
    msg_btn.add_css_class("flat");
    actions.append(&msg_btn);

    let export_btn = gtk4::Button::with_label("Export Report");
    export_btn.add_css_class("flat");
    actions.append(&export_btn);

    frame.set_child(Some(&actions));
    frame
}

// =============================================================================
// Encrypted Messaging Panel
// =============================================================================

pub fn build_messaging_panel() -> gtk4::Box {
    let panel = gtk4::Box::new(gtk4::Orientation::Vertical, 8);
    panel.add_css_class("resonance-card");
    panel.set_margin_start(14);
    panel.set_margin_end(14);
    panel.set_margin_top(10);
    panel.set_margin_bottom(10);

    let header = gtk4::Box::new(gtk4::Orientation::Horizontal, 0);
    let title = gtk4::Label::new(Some("Secure Messages"));
    title.set_halign(gtk4::Align::Start);
    title.set_hexpand(true);
    title.add_css_class("heading");
    header.append(&title);

    let lock_icon = gtk4::Image::from_icon_name("channel-secure-symbolic");
    lock_icon.add_css_class("dim-label");
    header.append(&lock_icon);
    panel.append(&header);

    let info = gtk4::Label::new(Some("End-to-end encrypted. Messages are stored locally."));
    info.set_halign(gtk4::Align::Start);
    info.add_css_class("dim-label");
    info.add_css_class("caption");
    panel.append(&info);

    // Message input
    let input_box = gtk4::Box::new(gtk4::Orientation::Horizontal, 8);
    let entry = gtk4::Entry::new();
    entry.set_placeholder_text(Some("Type a secure message..."));
    entry.set_hexpand(true);
    input_box.append(&entry);

    let send_btn = gtk4::Button::from_icon_name("mail-send-symbolic");
    send_btn.add_css_class("suggested-action");
    send_btn.add_css_class("circular");
    input_box.append(&send_btn);
    panel.append(&input_box);

    panel
}

// =============================================================================
// Sample Data
// =============================================================================

fn create_sample_provider() -> Provider {
    Provider {
        first_name: "Sarah".into(),
        last_name: "Chen".into(),
        specialty: "Integrative Medicine".into(),
        credentials: "MD, IFMCP".into(),
        active_patient_count: 48,
        ..Default::default()
    }
}

fn create_sample_patients() -> Vec<Patient> {
    vec![
        Patient {
            first_name: "James".into(),
            last_name: "Mitchell".into(),
            age: 52,
            primary_condition: "Metabolic Syndrome".into(),
            risk_level: RiskLevel::Moderate,
            status: "Active Protocol".into(),
            biomarkers: vec![
                Biomarker {
                    name: "HbA1c".into(),
                    value: 6.2,
                    unit: "%".into(),
                    optimal_value: 5.7,
                    target_low: 4.0,
                    target_high: 5.7,
                    category: BiomarkerCategory::Metabolic,
                    trend: TrendDirection::Improving,
                    history: vec![7.1, 6.8, 6.5, 6.2],
                    ..Default::default()
                },
                Biomarker {
                    name: "Fasting Glucose".into(),
                    value: 112.0,
                    unit: "mg/dL".into(),
                    optimal_value: 85.0,
                    target_low: 70.0,
                    target_high: 100.0,
                    category: BiomarkerCategory::Metabolic,
                    trend: TrendDirection::Improving,
                    history: vec![135.0, 128.0, 118.0, 112.0],
                    ..Default::default()
                },
                Biomarker {
                    name: "Triglycerides".into(),
                    value: 165.0,
                    unit: "mg/dL".into(),
                    optimal_value: 100.0,
                    target_low: 0.0,
                    target_high: 150.0,
                    category: BiomarkerCategory::Metabolic,
                    trend: TrendDirection::Stable,
                    history: vec![190.0, 178.0, 170.0, 165.0],
                    ..Default::default()
                },
                Biomarker {
                    name: "CRP".into(),
                    value: 1.8,
                    unit: "mg/L".into(),
                    optimal_value: 0.5,
                    target_low: 0.0,
                    target_high: 1.0,
                    category: BiomarkerCategory::Inflammatory,
                    trend: TrendDirection::Declining,
                    history: vec![1.2, 1.4, 1.6, 1.8],
                    ..Default::default()
                },
            ],
            ..Default::default()
        },
        Patient {
            first_name: "Maria".into(),
            last_name: "Santos".into(),
            age: 38,
            primary_condition: "Thyroid Optimization".into(),
            risk_level: RiskLevel::Low,
            status: "Follow-up".into(),
            biomarkers: vec![
                Biomarker {
                    name: "TSH".into(),
                    value: 2.1,
                    unit: "mIU/L".into(),
                    optimal_value: 2.0,
                    target_low: 0.5,
                    target_high: 4.0,
                    category: BiomarkerCategory::Hormonal,
                    trend: TrendDirection::Improving,
                    history: vec![4.5, 3.2, 2.6, 2.1],
                    ..Default::default()
                },
                Biomarker {
                    name: "Free T4".into(),
                    value: 1.3,
                    unit: "ng/dL".into(),
                    optimal_value: 1.4,
                    target_low: 0.8,
                    target_high: 1.8,
                    category: BiomarkerCategory::Hormonal,
                    trend: TrendDirection::Stable,
                    history: vec![0.9, 1.1, 1.2, 1.3],
                    ..Default::default()
                },
            ],
            ..Default::default()
        },
        Patient {
            first_name: "Robert".into(),
            last_name: "Kim".into(),
            age: 67,
            primary_condition: "Cardiovascular Prevention".into(),
            risk_level: RiskLevel::High,
            status: "Monitoring".into(),
            biomarkers: vec![
                Biomarker {
                    name: "LDL-P".into(),
                    value: 1280.0,
                    unit: "nmol/L".into(),
                    optimal_value: 800.0,
                    target_low: 0.0,
                    target_high: 1000.0,
                    category: BiomarkerCategory::Cardiovascular,
                    trend: TrendDirection::Stable,
                    history: vec![1450.0, 1380.0, 1320.0, 1280.0],
                    ..Default::default()
                },
                Biomarker {
                    name: "hs-CRP".into(),
                    value: 2.4,
                    unit: "mg/L".into(),
                    optimal_value: 0.5,
                    target_low: 0.0,
                    target_high: 1.0,
                    category: BiomarkerCategory::Inflammatory,
                    trend: TrendDirection::Declining,
                    history: vec![1.8, 2.0, 2.2, 2.4],
                    ..Default::default()
                },
            ],
            ..Default::default()
        },
    ]
}
