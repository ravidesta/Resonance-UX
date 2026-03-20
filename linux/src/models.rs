// =============================================================================
// Resonance UX — Rust Data Models
//
// Complete domain model with serde serialization: tasks, phases, contacts,
// documents, patients, providers, biomarkers, protocols.
// =============================================================================

use chrono::{DateTime, Local, NaiveTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

// =============================================================================
// Enumerations
// =============================================================================

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum EnergyLevel {
    Low,
    Medium,
    High,
    Peak,
}

impl Default for EnergyLevel {
    fn default() -> Self {
        EnergyLevel::Medium
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum Domain {
    Personal,
    Work,
    Wellness,
    Creative,
    Social,
    Administrative,
}

impl Default for Domain {
    fn default() -> Self {
        Domain::Personal
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TaskPriority {
    Gentle,
    Steady,
    Focused,
    Urgent,
}

impl Default for TaskPriority {
    fn default() -> Self {
        TaskPriority::Gentle
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TaskStatus {
    Open,
    InProgress,
    Complete,
    Deferred,
    Released,
}

impl Default for TaskStatus {
    fn default() -> Self {
        TaskStatus::Open
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum IntentionalStatus {
    Available,
    Flowing,
    Focusing,
    Reflecting,
    Resting,
    InConversation,
}

impl Default for IntentionalStatus {
    fn default() -> Self {
        IntentionalStatus::Available
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum MessageKind {
    Letter,
    Note,
    Invitation,
    Acknowledgment,
    Reflection,
}

impl Default for MessageKind {
    fn default() -> Self {
        MessageKind::Note
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ProtocolStatus {
    Draft,
    Active,
    Paused,
    Completed,
    Archived,
}

impl Default for ProtocolStatus {
    fn default() -> Self {
        ProtocolStatus::Draft
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum BiomarkerCategory {
    Metabolic,
    Hormonal,
    Inflammatory,
    Cardiovascular,
    Nutritional,
    Neurological,
    Immune,
}

impl Default for BiomarkerCategory {
    fn default() -> Self {
        BiomarkerCategory::Metabolic
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum TrendDirection {
    Improving,
    Stable,
    Declining,
    Insufficient,
}

impl Default for TrendDirection {
    fn default() -> Self {
        TrendDirection::Stable
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum RiskLevel {
    Minimal,
    Low,
    Moderate,
    High,
    Critical,
}

impl Default for RiskLevel {
    fn default() -> Self {
        RiskLevel::Low
    }
}

// =============================================================================
// Task & Daily Flow Models
// =============================================================================

/// A Resonance task — an intention, not a demand.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ResonanceTask {
    pub id: String,
    pub title: String,
    #[serde(default)]
    pub description: String,
    pub domain: Domain,
    pub energy_required: EnergyLevel,
    pub priority: TaskPriority,
    pub status: TaskStatus,
    pub preferred_phase: crate::PhaseType,
    pub created_at: DateTime<Utc>,
    pub completed_at: Option<DateTime<Utc>>,
    pub due_date: Option<DateTime<Utc>>,
    pub estimated_minutes: u32,
    #[serde(default)]
    pub tags: Vec<String>,
}

impl Default for ResonanceTask {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            title: String::new(),
            description: String::new(),
            domain: Domain::default(),
            energy_required: EnergyLevel::default(),
            priority: TaskPriority::default(),
            status: TaskStatus::default(),
            preferred_phase: crate::PhaseType::Zenith,
            created_at: Utc::now(),
            completed_at: None,
            due_date: None,
            estimated_minutes: 30,
            tags: Vec::new(),
        }
    }
}

impl ResonanceTask {
    pub fn is_complete(&self) -> bool {
        self.status == TaskStatus::Complete
    }

    pub fn is_overdue(&self) -> bool {
        if let Some(due) = self.due_date {
            due < Utc::now() && !self.is_complete()
        } else {
            false
        }
    }
}

/// A daily phase with time boundaries and associated tasks.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DailyPhase {
    pub phase_type: crate::PhaseType,
    pub start_time: NaiveTime,
    pub end_time: NaiveTime,
    pub guidance: String,
    pub tasks: Vec<ResonanceTask>,
    pub spaciousness: f64,
}

impl DailyPhase {
    pub fn duration_hours(&self) -> f64 {
        let duration = self.end_time.signed_duration_since(self.start_time);
        duration.num_minutes() as f64 / 60.0
    }

    pub fn is_active(&self) -> bool {
        let now = Local::now().time();
        now >= self.start_time && now < self.end_time
    }
}

/// An event on the timeline.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TimelineEvent {
    pub id: String,
    pub title: String,
    pub start_time: DateTime<Utc>,
    pub end_time: DateTime<Utc>,
    pub domain: Domain,
    #[serde(default)]
    pub location: String,
    pub is_flexible: bool,
    pub linked_contact_id: Option<String>,
}

impl Default for TimelineEvent {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            title: String::new(),
            start_time: Utc::now(),
            end_time: Utc::now(),
            domain: Domain::default(),
            location: String::new(),
            is_flexible: true,
            linked_contact_id: None,
        }
    }
}

/// Aggregated flow metrics for the day.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FlowMetrics {
    pub spaciousness: f64,
    pub tasks_planned: usize,
    pub tasks_complete: usize,
    pub focus_minutes_today: u32,
    pub current_streak: u32,
}

impl Default for FlowMetrics {
    fn default() -> Self {
        Self {
            spaciousness: 0.0,
            tasks_planned: 0,
            tasks_complete: 0,
            focus_minutes_today: 0,
            current_streak: 0,
        }
    }
}

// =============================================================================
// Contact & Communication Models
// =============================================================================

/// A person in the user's constellation.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Contact {
    pub id: String,
    pub first_name: String,
    pub last_name: String,
    #[serde(default)]
    pub email: String,
    #[serde(default)]
    pub phone: String,
    #[serde(default)]
    pub avatar_uri: String,
    pub status: IntentionalStatus,
    pub last_contacted_at: DateTime<Utc>,
    #[serde(default)]
    pub relationship: String,
    pub primary_domain: Domain,
    #[serde(default)]
    pub notes: Vec<String>,
}

impl Default for Contact {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            first_name: String::new(),
            last_name: String::new(),
            email: String::new(),
            phone: String::new(),
            avatar_uri: String::new(),
            status: IntentionalStatus::default(),
            last_contacted_at: Utc::now(),
            relationship: String::new(),
            primary_domain: Domain::default(),
            notes: Vec::new(),
        }
    }
}

impl Contact {
    pub fn full_name(&self) -> String {
        format!("{} {}", self.first_name, self.last_name)
    }

    pub fn initials(&self) -> String {
        let f = self.first_name.chars().next().unwrap_or(' ');
        let l = self.last_name.chars().next().unwrap_or(' ');
        format!("{}{}", f, l).to_uppercase()
    }
}

/// A message — intentional, not interruptive.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Message {
    pub id: String,
    pub from_contact_id: String,
    pub to_contact_id: String,
    #[serde(default)]
    pub subject: String,
    pub body: String,
    pub kind: MessageKind,
    pub sent_at: DateTime<Utc>,
    pub read_at: Option<DateTime<Utc>>,
    pub is_encrypted: bool,
    pub thread_id: Option<String>,
}

impl Default for Message {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            from_contact_id: String::new(),
            to_contact_id: String::new(),
            subject: String::new(),
            body: String::new(),
            kind: MessageKind::default(),
            sent_at: Utc::now(),
            read_at: None,
            is_encrypted: false,
            thread_id: None,
        }
    }
}

impl Message {
    pub fn is_read(&self) -> bool {
        self.read_at.is_some()
    }
}

// =============================================================================
// Writer / Document Models
// =============================================================================

/// A document in the Writer sanctuary.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Document {
    pub id: String,
    pub title: String,
    #[serde(default)]
    pub content: String,
    #[serde(default)]
    pub excerpt: String,
    pub word_count: usize,
    pub created_at: DateTime<Local>,
    pub updated_at: DateTime<Local>,
    pub domain: Domain,
    #[serde(default)]
    pub tags: Vec<String>,
    pub is_favorite: bool,
    pub parent_folder_id: Option<String>,
}

impl Default for Document {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            title: String::new(),
            content: String::new(),
            excerpt: String::new(),
            word_count: 0,
            created_at: Local::now(),
            updated_at: Local::now(),
            domain: Domain::default(),
            tags: Vec::new(),
            is_favorite: false,
            parent_folder_id: None,
        }
    }
}

impl Document {
    pub fn reading_time_minutes(&self) -> usize {
        (self.word_count / 200).max(1)
    }
}

/// A writing session for stats tracking.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WritingSession {
    pub id: String,
    pub document_id: String,
    pub document_title: String,
    pub started_at: DateTime<Local>,
    pub ended_at: Option<DateTime<Local>>,
    pub words_written: usize,
    pub target_word_count: usize,
    pub focus_minutes: u32,
    pub flow_score: f64,
}

impl Default for WritingSession {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            document_id: String::new(),
            document_title: "Untitled".into(),
            started_at: Local::now(),
            ended_at: None,
            words_written: 0,
            target_word_count: 1000,
            focus_minutes: 0,
            flow_score: 0.0,
        }
    }
}

impl WritingSession {
    pub fn duration_minutes(&self) -> i64 {
        let end = self.ended_at.unwrap_or_else(Local::now);
        (end - self.started_at).num_minutes()
    }

    pub fn progress(&self) -> f64 {
        if self.target_word_count == 0 {
            return 0.0;
        }
        (self.words_written as f64 / self.target_word_count as f64).min(1.0)
    }
}

// =============================================================================
// Healthcare / Wellness Models
// =============================================================================

/// A patient in the wellness practice.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Patient {
    pub id: String,
    pub first_name: String,
    pub last_name: String,
    pub age: u32,
    pub primary_condition: String,
    pub risk_level: RiskLevel,
    pub status: String,
    pub assigned_provider_id: Option<String>,
    pub enrolled_at: DateTime<Utc>,
    pub last_encounter_at: Option<DateTime<Utc>>,
    pub next_encounter_at: Option<DateTime<Utc>>,
    pub biomarkers: Vec<Biomarker>,
    pub active_protocols: Vec<Protocol>,
    #[serde(default)]
    pub notes: String,
}

impl Default for Patient {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            first_name: String::new(),
            last_name: String::new(),
            age: 0,
            primary_condition: String::new(),
            risk_level: RiskLevel::default(),
            status: "Active".into(),
            assigned_provider_id: None,
            enrolled_at: Utc::now(),
            last_encounter_at: None,
            next_encounter_at: None,
            biomarkers: Vec::new(),
            active_protocols: Vec::new(),
            notes: String::new(),
        }
    }
}

impl Patient {
    pub fn full_name(&self) -> String {
        format!("{} {}", self.first_name, self.last_name)
    }
}

/// A healthcare provider.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Provider {
    pub id: String,
    pub first_name: String,
    pub last_name: String,
    pub specialty: String,
    #[serde(default)]
    pub credentials: String,
    pub active_patient_count: u32,
    pub practice_id: Option<String>,
    #[serde(default)]
    pub patient_ids: Vec<String>,
}

impl Default for Provider {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            first_name: String::new(),
            last_name: String::new(),
            specialty: String::new(),
            credentials: String::new(),
            active_patient_count: 0,
            practice_id: None,
            patient_ids: Vec::new(),
        }
    }
}

impl Provider {
    pub fn full_name(&self) -> String {
        format!("{} {}", self.first_name, self.last_name)
    }

    pub fn display_name(&self) -> String {
        format!("Dr. {}", self.last_name)
    }
}

/// A biomarker measurement.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Biomarker {
    pub id: String,
    pub name: String,
    #[serde(default)]
    pub code: String,
    pub value: f64,
    pub unit: String,
    pub target_low: f64,
    pub target_high: f64,
    pub optimal_value: f64,
    pub category: BiomarkerCategory,
    pub trend: TrendDirection,
    pub measured_at: DateTime<Utc>,
    #[serde(default)]
    pub history: Vec<f64>,
    #[serde(default)]
    pub history_dates: Vec<DateTime<Utc>>,
    #[serde(default)]
    pub lab_source: String,
}

impl Default for Biomarker {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name: String::new(),
            code: String::new(),
            value: 0.0,
            unit: String::new(),
            target_low: 0.0,
            target_high: 0.0,
            optimal_value: 0.0,
            category: BiomarkerCategory::default(),
            trend: TrendDirection::default(),
            measured_at: Utc::now(),
            history: Vec::new(),
            history_dates: Vec::new(),
            lab_source: String::new(),
        }
    }
}

impl Biomarker {
    pub fn is_in_range(&self) -> bool {
        self.value >= self.target_low && self.value <= self.target_high
    }

    pub fn is_optimal(&self) -> bool {
        if self.optimal_value == 0.0 {
            return self.is_in_range();
        }
        ((self.value - self.optimal_value) / self.optimal_value).abs() < 0.05
    }

    pub fn deviation_from_optimal(&self) -> f64 {
        if self.optimal_value == 0.0 {
            return 0.0;
        }
        (self.value - self.optimal_value) / self.optimal_value
    }
}

/// A treatment or wellness protocol.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Protocol {
    pub id: String,
    pub name: String,
    #[serde(default)]
    pub description: String,
    pub patient_id: String,
    pub provider_id: String,
    pub status: ProtocolStatus,
    pub started_at: DateTime<Utc>,
    pub ended_at: Option<DateTime<Utc>>,
    pub duration_weeks: u32,
    pub steps: Vec<ProtocolStep>,
    #[serde(default)]
    pub notes: String,
    pub adherence_score: f64,
}

impl Default for Protocol {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            name: String::new(),
            description: String::new(),
            patient_id: String::new(),
            provider_id: String::new(),
            status: ProtocolStatus::default(),
            started_at: Utc::now(),
            ended_at: None,
            duration_weeks: 12,
            steps: Vec::new(),
            notes: String::new(),
            adherence_score: 0.0,
        }
    }
}

impl Protocol {
    pub fn weeks_elapsed(&self) -> u32 {
        let elapsed = Utc::now().signed_duration_since(self.started_at);
        (elapsed.num_days() / 7) as u32
    }

    pub fn progress(&self) -> f64 {
        if self.duration_weeks == 0 {
            return 0.0;
        }
        (self.weeks_elapsed() as f64 / self.duration_weeks as f64).min(1.0)
    }
}

/// A step within a protocol.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProtocolStep {
    pub id: String,
    pub title: String,
    #[serde(default)]
    pub instructions: String,
    pub week_number: u32,
    pub is_complete: bool,
    #[serde(default)]
    pub notes: String,
}

impl Default for ProtocolStep {
    fn default() -> Self {
        Self {
            id: Uuid::new_v4().to_string(),
            title: String::new(),
            instructions: String::new(),
            week_number: 1,
            is_complete: false,
            notes: String::new(),
        }
    }
}
