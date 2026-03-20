// =============================================================================
// Resonance UX — Daily Flow View (Rust + GTK4)
//
// Phase timeline (Ascend, Zenith, Descent, Rest), spaciousness gauge,
// task cards with energy indicators, Cairo drawing for the timeline,
// and CSS animations for phase transitions.
// =============================================================================

use crate::models::{DailyPhase, EnergyLevel, FlowMetrics, ResonanceTask, TaskStatus};
use crate::{AppState, PhaseType};
use chrono::{Local, Timelike};
use gtk4::glib;
use gtk4::prelude::*;
use std::cell::RefCell;
use std::f64::consts::PI;
use std::rc::Rc;

// =============================================================================
// View Builder
// =============================================================================

pub fn build_daily_flow_view(state: &Rc<RefCell<AppState>>) -> gtk4::Box {
    let root = gtk4::Box::new(gtk4::Orientation::Vertical, 0);
    root.add_css_class("resonance-page");
    root.set_margin_start(32);
    root.set_margin_end(32);
    root.set_margin_top(24);
    root.set_margin_bottom(24);

    // Sample data
    let tasks = Rc::new(RefCell::new(create_sample_tasks()));
    let metrics = Rc::new(RefCell::new(compute_metrics(&tasks.borrow())));
    let current_phase = state.borrow().current_phase;

    // --- Header ---
    let header = build_header(current_phase);
    root.append(&header);

    // --- Phase Timeline (Cairo custom drawing) ---
    let timeline = build_timeline(current_phase);
    root.append(&timeline);

    // --- Metrics Bar ---
    let metrics_bar = build_metrics_bar(&metrics.borrow());
    root.append(&metrics_bar);

    // --- Task List ---
    let task_list = build_task_list(&tasks, &metrics);
    root.append(&task_list);

    // Add entrance animation CSS class
    root.add_css_class("resonance-fade-in");

    root
}

// =============================================================================
// Header
// =============================================================================

fn build_header(phase: PhaseType) -> gtk4::Box {
    let header_box = gtk4::Box::new(gtk4::Orientation::Vertical, 4);
    header_box.set_margin_bottom(20);

    let greeting = gtk4::Label::new(Some(phase_greeting(phase)));
    greeting.set_halign(gtk4::Align::Start);
    greeting.add_css_class("resonance-display");
    greeting.add_css_class("title-1");
    header_box.append(&greeting);

    let wisdom = gtk4::Label::new(Some(phase.guidance()));
    wisdom.set_halign(gtk4::Align::Start);
    wisdom.add_css_class("resonance-body");
    wisdom.add_css_class("dim-label");
    header_box.append(&wisdom);

    header_box
}

fn phase_greeting(phase: PhaseType) -> &'static str {
    match phase {
        PhaseType::Ascend => "Good morning",
        PhaseType::Zenith => "In your element",
        PhaseType::Descent => "Winding down",
        PhaseType::Rest => "Time to rest",
    }
}

// =============================================================================
// Phase Timeline (Cairo Drawing)
// =============================================================================

fn build_timeline(active_phase: PhaseType) -> gtk4::Frame {
    let frame = gtk4::Frame::new(None);
    frame.add_css_class("resonance-card");
    frame.set_margin_bottom(16);

    let drawing_area = gtk4::DrawingArea::new();
    drawing_area.set_content_height(120);
    drawing_area.set_content_width(800);

    let phase = active_phase;
    drawing_area.set_draw_func(move |_, cr, width, height| {
        draw_timeline(cr, width as f64, height as f64, phase);
    });

    frame.set_child(Some(&drawing_area));
    frame
}

fn draw_timeline(cr: &cairo::Context, width: f64, height: f64, active_phase: PhaseType) {
    let padding = 20.0;
    let bar_y = height * 0.5;
    let bar_height = 24.0;
    let label_y = bar_y - bar_height - 8.0;
    let time_y = bar_y + bar_height + 16.0;

    // Phase segments: (name, fraction of 24h, color_r, color_g, color_b)
    let phases = [
        ("Ascend", 5.0 / 24.0, PhaseType::Ascend, 0.66, 0.78, 0.70),
        ("Zenith", 6.0 / 24.0, PhaseType::Zenith, 0.77, 0.63, 0.35),
        ("Descent", 5.0 / 24.0, PhaseType::Descent, 0.36, 0.44, 0.40),
        ("Rest", 8.0 / 24.0, PhaseType::Rest, 0.07, 0.18, 0.13),
    ];

    let usable_width = width - 2.0 * padding;
    let mut x = padding;
    let radius = 8.0;

    for (i, (name, fraction, ptype, r, g, b)) in phases.iter().enumerate() {
        let seg_width = usable_width * fraction;
        let is_active = *ptype == active_phase;
        let alpha = if is_active { 1.0 } else { 0.35 };
        let seg_bar_height = if is_active { bar_height + 4.0 } else { bar_height - 4.0 };
        let seg_y = bar_y - seg_bar_height / 2.0;

        // Draw rounded segment
        let (tl, tr, br, bl) = match i {
            0 => (radius, 0.0, 0.0, radius),
            3 => (0.0, radius, radius, 0.0),
            _ => (0.0, 0.0, 0.0, 0.0),
        };

        cr.set_source_rgba(*r, *g, *b, alpha);
        draw_rounded_rect(cr, x, seg_y, seg_width, seg_bar_height, tl, tr, br, bl);
        let _ = cr.fill();

        // Phase label
        let label_alpha = if is_active { 1.0 } else { 0.5 };
        cr.set_source_rgba(0.4, 0.5, 0.44, label_alpha);
        cr.set_font_size(if is_active { 13.0 } else { 11.0 });
        let extents = cr.text_extents(name).unwrap();
        let label_x = x + (seg_width - extents.width()) / 2.0;
        cr.move_to(label_x, label_y);
        let _ = cr.show_text(name);

        x += seg_width;
    }

    // Time marks
    let times = ["5 AM", "10 AM", "4 PM", "9 PM"];
    let positions = [0.0, 5.0 / 24.0, 11.0 / 24.0, 16.0 / 24.0];
    cr.set_source_rgba(0.5, 0.5, 0.5, 0.4);
    cr.set_font_size(10.0);
    for (time, pos) in times.iter().zip(positions.iter()) {
        let tx = padding + usable_width * pos;
        cr.move_to(tx, time_y);
        let _ = cr.show_text(time);
    }

    // Current time indicator (gold dot)
    let now = Local::now();
    let hours_since_5am = ((now.hour() as f64 + now.minute() as f64 / 60.0) - 5.0 + 24.0) % 24.0;
    let now_fraction = hours_since_5am / 24.0;
    let dot_x = padding + usable_width * now_fraction;
    let dot_y = bar_y;

    // Gold dot
    cr.set_source_rgba(0.77, 0.63, 0.35, 1.0); // #C5A059
    cr.arc(dot_x, dot_y, 7.0, 0.0, 2.0 * PI);
    let _ = cr.fill();

    // White ring
    cr.set_source_rgba(1.0, 1.0, 1.0, 0.9);
    cr.set_line_width(2.0);
    cr.arc(dot_x, dot_y, 7.0, 0.0, 2.0 * PI);
    let _ = cr.stroke();
}

fn draw_rounded_rect(
    cr: &cairo::Context,
    x: f64, y: f64, w: f64, h: f64,
    tl: f64, tr: f64, br: f64, bl: f64,
) {
    cr.new_path();
    cr.arc(x + tl, y + tl, tl, PI, 1.5 * PI);
    cr.arc(x + w - tr, y + tr, tr, 1.5 * PI, 2.0 * PI);
    cr.arc(x + w - br, y + h - br, br, 0.0, 0.5 * PI);
    cr.arc(x + bl, y + h - bl, bl, 0.5 * PI, PI);
    cr.close_path();
}

// =============================================================================
// Metrics Bar
// =============================================================================

fn build_metrics_bar(metrics: &FlowMetrics) -> gtk4::Box {
    let bar = gtk4::Box::new(gtk4::Orientation::Horizontal, 12);
    bar.set_margin_bottom(16);
    bar.set_homogeneous(true);

    bar.append(&build_metric_card(
        "Spaciousness",
        &format!("{}%", (metrics.spaciousness * 100.0) as i32),
        true,
    ));
    bar.append(&build_metric_card(
        "Focus",
        &format!("{} min", metrics.focus_minutes_today),
        false,
    ));
    bar.append(&build_metric_card(
        "Progress",
        &format!("{}/{}", metrics.tasks_complete, metrics.tasks_planned),
        false,
    ));
    bar.append(&build_metric_card(
        "Streak",
        &format!("{} days", metrics.current_streak),
        false,
    ));

    bar
}

fn build_metric_card(label: &str, value: &str, is_primary: bool) -> gtk4::Frame {
    let frame = gtk4::Frame::new(None);
    frame.add_css_class("resonance-card");

    let card_box = gtk4::Box::new(gtk4::Orientation::Vertical, 4);
    card_box.set_margin_start(16);
    card_box.set_margin_end(16);
    card_box.set_margin_top(12);
    card_box.set_margin_bottom(12);

    let label_widget = gtk4::Label::new(Some(&label.to_uppercase()));
    label_widget.set_halign(gtk4::Align::Start);
    label_widget.add_css_class("resonance-label");
    label_widget.add_css_class("dim-label");
    card_box.append(&label_widget);

    let value_widget = gtk4::Label::new(Some(value));
    value_widget.set_halign(gtk4::Align::Start);
    value_widget.add_css_class("resonance-display");
    value_widget.add_css_class("title-2");
    if is_primary {
        value_widget.add_css_class("resonance-accent");
    }
    card_box.append(&value_widget);

    if is_primary {
        let progress = gtk4::ProgressBar::new();
        progress.set_fraction(0.68);
        progress.add_css_class("resonance-progress");
        progress.set_margin_top(4);
        card_box.append(&progress);
    }

    frame.set_child(Some(&card_box));
    frame
}

// =============================================================================
// Spaciousness Gauge (Cairo)
// =============================================================================

pub fn build_spaciousness_gauge(value: f64) -> gtk4::DrawingArea {
    let area = gtk4::DrawingArea::new();
    area.set_content_width(80);
    area.set_content_height(80);

    area.set_draw_func(move |_, cr, width, height| {
        let cx = width as f64 / 2.0;
        let cy = height as f64 / 2.0;
        let radius = (width.min(height) as f64 / 2.0) - 6.0;

        // Background arc (muted)
        cr.set_source_rgba(0.36, 0.44, 0.40, 0.2);
        cr.set_line_width(4.0);
        cr.arc(cx, cy, radius, 0.75 * PI, 2.25 * PI);
        let _ = cr.stroke();

        // Value arc (gold)
        let sweep = value * 1.5 * PI; // 270 degrees max
        cr.set_source_rgba(0.77, 0.63, 0.35, 1.0);
        cr.set_line_width(4.0);
        cr.arc(cx, cy, radius, 0.75 * PI, 0.75 * PI + sweep);
        let _ = cr.stroke();

        // Center text
        cr.set_source_rgba(0.77, 0.63, 0.35, 1.0);
        cr.set_font_size(18.0);
        let text = format!("{}%", (value * 100.0) as i32);
        let extents = cr.text_extents(&text).unwrap();
        cr.move_to(cx - extents.width() / 2.0, cy + extents.height() / 2.0);
        let _ = cr.show_text(&text);
    });

    area
}

// =============================================================================
// Task List
// =============================================================================

fn build_task_list(
    tasks: &Rc<RefCell<Vec<ResonanceTask>>>,
    metrics: &Rc<RefCell<FlowMetrics>>,
) -> gtk4::ScrolledWindow {
    let scroll = gtk4::ScrolledWindow::new();
    scroll.set_vexpand(true);
    scroll.set_policy(gtk4::PolicyType::Never, gtk4::PolicyType::Automatic);

    let list_box = gtk4::ListBox::new();
    list_box.set_selection_mode(gtk4::SelectionMode::None);
    list_box.add_css_class("boxed-list");
    list_box.set_margin_top(4);

    let tasks_ref = tasks.borrow();
    for (index, task) in tasks_ref.iter().enumerate() {
        let row = build_task_row(task, index, tasks, metrics);
        list_box.append(&row);
    }

    scroll.set_child(Some(&list_box));
    scroll
}

fn build_task_row(
    task: &ResonanceTask,
    index: usize,
    tasks: &Rc<RefCell<Vec<ResonanceTask>>>,
    metrics: &Rc<RefCell<FlowMetrics>>,
) -> libadwaita::ActionRow {
    let row = libadwaita::ActionRow::new();
    row.set_title(&task.title);
    row.set_subtitle(&format!("{:?}", task.domain));
    row.add_css_class("resonance-task-row");

    // Checkbox
    let check = gtk4::CheckButton::new();
    check.set_active(task.status == TaskStatus::Complete);

    let tasks_clone = tasks.clone();
    let metrics_clone = metrics.clone();
    check.connect_toggled(move |btn| {
        let mut tasks = tasks_clone.borrow_mut();
        if let Some(t) = tasks.get_mut(index) {
            t.status = if btn.is_active() {
                TaskStatus::Complete
            } else {
                TaskStatus::Open
            };
        }
        let mut m = metrics_clone.borrow_mut();
        *m = compute_metrics(&tasks);
    });
    row.add_prefix(&check);

    // Energy indicator dot
    let energy_dot = gtk4::DrawingArea::new();
    energy_dot.set_content_width(10);
    energy_dot.set_content_height(10);

    let energy = task.energy_required;
    energy_dot.set_draw_func(move |_, cr, w, h| {
        let (r, g, b) = match energy {
            EnergyLevel::Low => (0.66, 0.78, 0.70),
            EnergyLevel::Medium => (0.77, 0.63, 0.35),
            EnergyLevel::High => (0.78, 0.47, 0.31),
            EnergyLevel::Peak => (0.82, 0.30, 0.28),
        };
        cr.set_source_rgb(r, g, b);
        cr.arc(w as f64 / 2.0, h as f64 / 2.0, 4.0, 0.0, 2.0 * PI);
        let _ = cr.fill();
    });
    row.add_suffix(&energy_dot);

    // Domain badge
    let domain_label = gtk4::Label::new(Some(&format!("{:?}", task.domain)));
    domain_label.add_css_class("resonance-badge");
    row.add_suffix(&domain_label);

    row
}

// =============================================================================
// Sample Data & Helpers
// =============================================================================

fn create_sample_tasks() -> Vec<ResonanceTask> {
    use crate::models::Domain;
    vec![
        ResonanceTask {
            id: uuid::Uuid::new_v4().to_string(),
            title: "Morning reflection".into(),
            domain: Domain::Personal,
            energy_required: EnergyLevel::Low,
            preferred_phase: PhaseType::Ascend,
            status: TaskStatus::Complete,
            ..Default::default()
        },
        ResonanceTask {
            id: uuid::Uuid::new_v4().to_string(),
            title: "Deep work: Architecture review".into(),
            domain: Domain::Work,
            energy_required: EnergyLevel::High,
            preferred_phase: PhaseType::Zenith,
            status: TaskStatus::Open,
            ..Default::default()
        },
        ResonanceTask {
            id: uuid::Uuid::new_v4().to_string(),
            title: "Write protocol notes".into(),
            domain: Domain::Wellness,
            energy_required: EnergyLevel::Medium,
            preferred_phase: PhaseType::Zenith,
            status: TaskStatus::Open,
            ..Default::default()
        },
        ResonanceTask {
            id: uuid::Uuid::new_v4().to_string(),
            title: "Team sync".into(),
            domain: Domain::Work,
            energy_required: EnergyLevel::Medium,
            preferred_phase: PhaseType::Zenith,
            status: TaskStatus::Open,
            ..Default::default()
        },
        ResonanceTask {
            id: uuid::Uuid::new_v4().to_string(),
            title: "Read chapter 4".into(),
            domain: Domain::Personal,
            energy_required: EnergyLevel::Low,
            preferred_phase: PhaseType::Descent,
            status: TaskStatus::Open,
            ..Default::default()
        },
        ResonanceTask {
            id: uuid::Uuid::new_v4().to_string(),
            title: "Evening walk".into(),
            domain: Domain::Personal,
            energy_required: EnergyLevel::Low,
            preferred_phase: PhaseType::Descent,
            status: TaskStatus::Open,
            ..Default::default()
        },
    ]
}

fn compute_metrics(tasks: &[ResonanceTask]) -> FlowMetrics {
    let complete = tasks.iter().filter(|t| t.status == TaskStatus::Complete).count();
    let total = tasks.len();
    let ratio = if total > 0 { complete as f64 / total as f64 } else { 0.0 };

    FlowMetrics {
        spaciousness: (0.4 + ratio * 0.5).min(1.0),
        tasks_planned: total,
        tasks_complete: complete,
        focus_minutes_today: 145,
        current_streak: 3,
    }
}
