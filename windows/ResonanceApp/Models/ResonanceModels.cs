// =============================================================================
// Resonance UX - C# Data Models
// Complete domain model for the Resonance ecosystem: tasks, phases, contacts,
// documents, patients, providers, biomarkers, and protocols.
// All models implement INotifyPropertyChanged for real-time data binding.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Text.Json.Serialization;

namespace ResonanceApp.Models
{
    // =========================================================================
    // Base Observable Model
    // =========================================================================

    /// <summary>
    /// Base class for all Resonance models that participate in data binding.
    /// Provides clean INotifyPropertyChanged implementation.
    /// </summary>
    public abstract class ObservableModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        protected bool SetProperty<T>(ref T field, T value, [CallerMemberName] string propertyName = null)
        {
            if (EqualityComparer<T>.Default.Equals(field, value))
                return false;

            field = value;
            OnPropertyChanged(propertyName);
            return true;
        }

        protected void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    // =========================================================================
    // Enumerations
    // =========================================================================

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum EnergyLevel
    {
        Low,
        Medium,
        High,
        Peak
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum PhaseType
    {
        Ascend,
        Zenith,
        Descent,
        Rest
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum Domain
    {
        Personal,
        Work,
        Wellness,
        Creative,
        Social,
        Administrative
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum TaskPriority
    {
        Gentle,    // Can wait, no pressure
        Steady,    // Should attend to it today
        Focused,   // Needs dedicated attention
        Urgent     // Rare — truly time-sensitive
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum TaskStatus
    {
        Open,
        InProgress,
        Complete,
        Deferred,
        Released   // Intentionally let go
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum IntentionalStatus
    {
        Available,       // Open to connection
        Flowing,         // In a creative or productive flow
        Focusing,        // Deep work, prefer no interruption
        Reflecting,      // Contemplative time
        Resting,         // Away, recharging
        InConversation   // Actively engaged with someone
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum MessageKind
    {
        Letter,          // Thoughtful, asynchronous
        Note,            // Brief, informational
        Invitation,      // Request for connection
        Acknowledgment,  // Simple receipt / thanks
        Reflection       // Shared thought or insight
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum ProtocolStatus
    {
        Draft,
        Active,
        Paused,
        Completed,
        Archived
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum BiomarkerCategory
    {
        Metabolic,
        Hormonal,
        Inflammatory,
        Cardiovascular,
        Nutritional,
        Neurological,
        Immune
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum TrendDirection
    {
        Improving,
        Stable,
        Declining,
        Insufficient   // Not enough data points
    }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public enum RiskLevel
    {
        Minimal,
        Low,
        Moderate,
        High,
        Critical
    }

    // =========================================================================
    // Task & Daily Flow Models
    // =========================================================================

    /// <summary>
    /// A Resonance task is not a demand — it's an intention.
    /// Tasks carry energy information so they can be placed
    /// in the right part of the day's natural rhythm.
    /// </summary>
    public class ResonanceTask : ObservableModel
    {
        private string _id;
        private string _title;
        private string _description;
        private Domain _domain;
        private EnergyLevel _energyRequired;
        private TaskPriority _priority;
        private TaskStatus _status;
        private PhaseType _preferredPhase;
        private DateTime _createdAt;
        private DateTime? _completedAt;
        private DateTime? _dueDate;
        private int _estimatedMinutes;
        private List<string> _tags;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string Title { get => _title; set => SetProperty(ref _title, value); }
        public string Description { get => _description; set => SetProperty(ref _description, value); }
        public Domain Domain { get => _domain; set => SetProperty(ref _domain, value); }
        public EnergyLevel EnergyRequired { get => _energyRequired; set => SetProperty(ref _energyRequired, value); }
        public TaskPriority Priority { get => _priority; set => SetProperty(ref _priority, value); }
        public TaskStatus Status { get => _status; set => SetProperty(ref _status, value); }
        public PhaseType PreferredPhase { get => _preferredPhase; set => SetProperty(ref _preferredPhase, value); }
        public DateTime CreatedAt { get => _createdAt; set => SetProperty(ref _createdAt, value); }
        public DateTime? CompletedAt { get => _completedAt; set => SetProperty(ref _completedAt, value); }
        public DateTime? DueDate { get => _dueDate; set => SetProperty(ref _dueDate, value); }
        public int EstimatedMinutes { get => _estimatedMinutes; set => SetProperty(ref _estimatedMinutes, value); }
        public List<string> Tags { get => _tags; set => SetProperty(ref _tags, value); }

        public bool IsComplete => Status == TaskStatus.Complete;
        public bool IsOverdue => DueDate.HasValue && DueDate.Value < DateTime.Now && !IsComplete;

        public ResonanceTask()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _createdAt = DateTime.UtcNow;
            _status = TaskStatus.Open;
            _priority = TaskPriority.Gentle;
            _tags = new List<string>();
        }
    }

    /// <summary>
    /// A phase in the daily rhythm, with its time boundaries and
    /// the tasks naturally suited to it.
    /// </summary>
    public class DailyPhase : ObservableModel
    {
        private PhaseType _type;
        private TimeSpan _startTime;
        private TimeSpan _endTime;
        private string _guidance;
        private ObservableCollection<ResonanceTask> _tasks;
        private double _spaciousness; // 0.0 (packed) to 1.0 (wide open)

        public PhaseType Type { get => _type; set => SetProperty(ref _type, value); }
        public TimeSpan StartTime { get => _startTime; set => SetProperty(ref _startTime, value); }
        public TimeSpan EndTime { get => _endTime; set => SetProperty(ref _endTime, value); }
        public string Guidance { get => _guidance; set => SetProperty(ref _guidance, value); }
        public ObservableCollection<ResonanceTask> Tasks { get => _tasks; set => SetProperty(ref _tasks, value); }
        public double Spaciousness { get => _spaciousness; set => SetProperty(ref _spaciousness, value); }

        public TimeSpan Duration => EndTime - StartTime;
        public bool IsActive
        {
            get
            {
                var now = DateTime.Now.TimeOfDay;
                return now >= StartTime && now < EndTime;
            }
        }

        public DailyPhase()
        {
            _tasks = new ObservableCollection<ResonanceTask>();
        }
    }

    /// <summary>
    /// An event on the daily timeline — meetings, blocks, transitions.
    /// </summary>
    public class TimelineEvent : ObservableModel
    {
        private string _id;
        private string _title;
        private DateTime _startTime;
        private DateTime _endTime;
        private Domain _domain;
        private string _location;
        private bool _isFlexible;
        private string _linkedContactId;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string Title { get => _title; set => SetProperty(ref _title, value); }
        public DateTime StartTime { get => _startTime; set => SetProperty(ref _startTime, value); }
        public DateTime EndTime { get => _endTime; set => SetProperty(ref _endTime, value); }
        public Domain Domain { get => _domain; set => SetProperty(ref _domain, value); }
        public string Location { get => _location; set => SetProperty(ref _location, value); }
        public bool IsFlexible { get => _isFlexible; set => SetProperty(ref _isFlexible, value); }
        public string LinkedContactId { get => _linkedContactId; set => SetProperty(ref _linkedContactId, value); }

        public TimeSpan Duration => EndTime - StartTime;
    }

    // =========================================================================
    // Contact & Communication Models
    // =========================================================================

    /// <summary>
    /// A person in the user's constellation of relationships.
    /// Resonance treats contacts as people, not leads or resources.
    /// </summary>
    public class Contact : ObservableModel
    {
        private string _id;
        private string _firstName;
        private string _lastName;
        private string _email;
        private string _phone;
        private string _avatarUri;
        private IntentionalStatus _status;
        private DateTime _lastContactedAt;
        private string _relationship;
        private Domain _primaryDomain;
        private List<string> _notes;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string FirstName { get => _firstName; set => SetProperty(ref _firstName, value); }
        public string LastName { get => _lastName; set => SetProperty(ref _lastName, value); }
        public string Email { get => _email; set => SetProperty(ref _email, value); }
        public string Phone { get => _phone; set => SetProperty(ref _phone, value); }
        public string AvatarUri { get => _avatarUri; set => SetProperty(ref _avatarUri, value); }
        public IntentionalStatus Status { get => _status; set => SetProperty(ref _status, value); }
        public DateTime LastContactedAt { get => _lastContactedAt; set => SetProperty(ref _lastContactedAt, value); }
        public string Relationship { get => _relationship; set => SetProperty(ref _relationship, value); }
        public Domain PrimaryDomain { get => _primaryDomain; set => SetProperty(ref _primaryDomain, value); }
        public List<string> Notes { get => _notes; set => SetProperty(ref _notes, value); }

        public string FullName => $"{FirstName} {LastName}";
        public string Initials => $"{FirstName?[..1]}{LastName?[..1]}".ToUpper();

        public Contact()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _status = IntentionalStatus.Available;
            _notes = new List<string>();
        }
    }

    /// <summary>
    /// A message in the Resonance communication system.
    /// Messages are intentional — not notifications, not interruptions.
    /// </summary>
    public class Message : ObservableModel
    {
        private string _id;
        private string _fromContactId;
        private string _toContactId;
        private string _subject;
        private string _body;
        private MessageKind _kind;
        private DateTime _sentAt;
        private DateTime? _readAt;
        private bool _isEncrypted;
        private string _threadId;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string FromContactId { get => _fromContactId; set => SetProperty(ref _fromContactId, value); }
        public string ToContactId { get => _toContactId; set => SetProperty(ref _toContactId, value); }
        public string Subject { get => _subject; set => SetProperty(ref _subject, value); }
        public string Body { get => _body; set => SetProperty(ref _body, value); }
        public MessageKind Kind { get => _kind; set => SetProperty(ref _kind, value); }
        public DateTime SentAt { get => _sentAt; set => SetProperty(ref _sentAt, value); }
        public DateTime? ReadAt { get => _readAt; set => SetProperty(ref _readAt, value); }
        public bool IsEncrypted { get => _isEncrypted; set => SetProperty(ref _isEncrypted, value); }
        public string ThreadId { get => _threadId; set => SetProperty(ref _threadId, value); }

        public bool IsRead => ReadAt.HasValue;

        public Message()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _sentAt = DateTime.UtcNow;
            _kind = MessageKind.Note;
        }
    }

    // =========================================================================
    // Writer / Document Models
    // =========================================================================

    /// <summary>
    /// A document in the Writer sanctuary.
    /// </summary>
    public class Document : ObservableModel
    {
        private string _id;
        private string _title;
        private string _content;
        private string _excerpt;
        private int _wordCount;
        private DateTime _createdAt;
        private DateTime _updatedAt;
        private Domain _domain;
        private List<string> _tags;
        private bool _isFavorite;
        private string _parentFolderId;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string Title { get => _title; set => SetProperty(ref _title, value); }
        public string Content { get => _content; set => SetProperty(ref _content, value); }
        public string Excerpt { get => _excerpt; set => SetProperty(ref _excerpt, value); }
        public int WordCount { get => _wordCount; set => SetProperty(ref _wordCount, value); }
        public DateTime CreatedAt { get => _createdAt; set => SetProperty(ref _createdAt, value); }
        public DateTime UpdatedAt { get => _updatedAt; set => SetProperty(ref _updatedAt, value); }
        public Domain Domain { get => _domain; set => SetProperty(ref _domain, value); }
        public List<string> Tags { get => _tags; set => SetProperty(ref _tags, value); }
        public bool IsFavorite { get => _isFavorite; set => SetProperty(ref _isFavorite, value); }
        public string ParentFolderId { get => _parentFolderId; set => SetProperty(ref _parentFolderId, value); }

        public int ReadingTimeMinutes => Math.Max(1, WordCount / 200);

        public Document()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _createdAt = DateTime.UtcNow;
            _updatedAt = DateTime.UtcNow;
            _tags = new List<string>();
        }
    }

    /// <summary>
    /// Tracks a writing session for the Writer's stats and streaks.
    /// </summary>
    public class WritingSession : ObservableModel
    {
        private string _id;
        private string _documentId;
        private DateTime _startedAt;
        private DateTime? _endedAt;
        private int _wordsWritten;
        private int _targetWordCount;
        private int _focusMinutes;
        private double _flowScore; // 0.0 to 1.0, how "in flow" the session felt

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string DocumentId { get => _documentId; set => SetProperty(ref _documentId, value); }
        public DateTime StartedAt { get => _startedAt; set => SetProperty(ref _startedAt, value); }
        public DateTime? EndedAt { get => _endedAt; set => SetProperty(ref _endedAt, value); }
        public int WordsWritten { get => _wordsWritten; set => SetProperty(ref _wordsWritten, value); }
        public int TargetWordCount { get => _targetWordCount; set => SetProperty(ref _targetWordCount, value); }
        public int FocusMinutes { get => _focusMinutes; set => SetProperty(ref _focusMinutes, value); }
        public double FlowScore { get => _flowScore; set => SetProperty(ref _flowScore, value); }

        public TimeSpan Duration => (EndedAt ?? DateTime.UtcNow) - StartedAt;
        public double Progress => TargetWordCount > 0 ? (double)WordsWritten / TargetWordCount : 0;

        public WritingSession()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _startedAt = DateTime.UtcNow;
            _targetWordCount = 500;
        }
    }

    // =========================================================================
    // Healthcare / Wellness Models
    // =========================================================================

    /// <summary>
    /// A patient in the wellness practice.
    /// </summary>
    public class Patient : ObservableModel
    {
        private string _id;
        private string _firstName;
        private string _lastName;
        private int _age;
        private string _primaryCondition;
        private RiskLevel _riskLevel;
        private string _assignedProviderId;
        private DateTime _enrolledAt;
        private DateTime? _lastEncounterAt;
        private DateTime? _nextEncounterAt;
        private ObservableCollection<Biomarker> _biomarkers;
        private ObservableCollection<Protocol> _activeProtocols;
        private string _notes;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string FirstName { get => _firstName; set => SetProperty(ref _firstName, value); }
        public string LastName { get => _lastName; set => SetProperty(ref _lastName, value); }
        public int Age { get => _age; set => SetProperty(ref _age, value); }
        public string PrimaryCondition { get => _primaryCondition; set => SetProperty(ref _primaryCondition, value); }
        public RiskLevel RiskLevel { get => _riskLevel; set => SetProperty(ref _riskLevel, value); }
        public string AssignedProviderId { get => _assignedProviderId; set => SetProperty(ref _assignedProviderId, value); }
        public DateTime EnrolledAt { get => _enrolledAt; set => SetProperty(ref _enrolledAt, value); }
        public DateTime? LastEncounterAt { get => _lastEncounterAt; set => SetProperty(ref _lastEncounterAt, value); }
        public DateTime? NextEncounterAt { get => _nextEncounterAt; set => SetProperty(ref _nextEncounterAt, value); }
        public ObservableCollection<Biomarker> Biomarkers { get => _biomarkers; set => SetProperty(ref _biomarkers, value); }
        public ObservableCollection<Protocol> ActiveProtocols { get => _activeProtocols; set => SetProperty(ref _activeProtocols, value); }
        public string Notes { get => _notes; set => SetProperty(ref _notes, value); }

        public string FullName => $"{FirstName} {LastName}";

        public Patient()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _biomarkers = new ObservableCollection<Biomarker>();
            _activeProtocols = new ObservableCollection<Protocol>();
        }
    }

    /// <summary>
    /// A healthcare provider using the Resonance wellness platform.
    /// </summary>
    public class Provider : ObservableModel
    {
        private string _id;
        private string _firstName;
        private string _lastName;
        private string _specialty;
        private string _credentials;
        private int _activePatientCount;
        private string _practiceId;
        private ObservableCollection<string> _patientIds;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string FirstName { get => _firstName; set => SetProperty(ref _firstName, value); }
        public string LastName { get => _lastName; set => SetProperty(ref _lastName, value); }
        public string Specialty { get => _specialty; set => SetProperty(ref _specialty, value); }
        public string Credentials { get => _credentials; set => SetProperty(ref _credentials, value); }
        public int ActivePatientCount { get => _activePatientCount; set => SetProperty(ref _activePatientCount, value); }
        public string PracticeId { get => _practiceId; set => SetProperty(ref _practiceId, value); }
        public ObservableCollection<string> PatientIds { get => _patientIds; set => SetProperty(ref _patientIds, value); }

        public string FullName => $"{FirstName} {LastName}";
        public string DisplayName => $"Dr. {LastName}";

        public Provider()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _patientIds = new ObservableCollection<string>();
        }
    }

    /// <summary>
    /// A biomarker measurement — a single data point in a patient's health story.
    /// </summary>
    public class Biomarker : ObservableModel
    {
        private string _id;
        private string _name;
        private string _code;
        private double _value;
        private string _unit;
        private double _targetLow;
        private double _targetHigh;
        private double _optimalValue;
        private BiomarkerCategory _category;
        private TrendDirection _trend;
        private DateTime _measuredAt;
        private List<double> _history;
        private List<DateTime> _historyDates;
        private string _labSource;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string Name { get => _name; set => SetProperty(ref _name, value); }
        public string Code { get => _code; set => SetProperty(ref _code, value); }
        public double Value { get => _value; set => SetProperty(ref _value, value); }
        public string Unit { get => _unit; set => SetProperty(ref _unit, value); }
        public double TargetLow { get => _targetLow; set => SetProperty(ref _targetLow, value); }
        public double TargetHigh { get => _targetHigh; set => SetProperty(ref _targetHigh, value); }
        public double OptimalValue { get => _optimalValue; set => SetProperty(ref _optimalValue, value); }
        public BiomarkerCategory Category { get => _category; set => SetProperty(ref _category, value); }
        public TrendDirection Trend { get => _trend; set => SetProperty(ref _trend, value); }
        public DateTime MeasuredAt { get => _measuredAt; set => SetProperty(ref _measuredAt, value); }
        public List<double> History { get => _history; set => SetProperty(ref _history, value); }
        public List<DateTime> HistoryDates { get => _historyDates; set => SetProperty(ref _historyDates, value); }
        public string LabSource { get => _labSource; set => SetProperty(ref _labSource, value); }

        public bool IsInRange => Value >= TargetLow && Value <= TargetHigh;
        public bool IsOptimal => Math.Abs(Value - OptimalValue) / OptimalValue < 0.05;
        public double DeviationFromOptimal => OptimalValue > 0 ? (Value - OptimalValue) / OptimalValue : 0;

        public Biomarker()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _measuredAt = DateTime.UtcNow;
            _history = new List<double>();
            _historyDates = new List<DateTime>();
        }
    }

    /// <summary>
    /// A treatment or wellness protocol assigned to a patient.
    /// </summary>
    public class Protocol : ObservableModel
    {
        private string _id;
        private string _name;
        private string _description;
        private string _patientId;
        private string _providerId;
        private ProtocolStatus _status;
        private DateTime _startedAt;
        private DateTime? _endedAt;
        private int _durationWeeks;
        private ObservableCollection<ProtocolStep> _steps;
        private string _notes;
        private double _adherenceScore; // 0.0 to 1.0

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string Name { get => _name; set => SetProperty(ref _name, value); }
        public string Description { get => _description; set => SetProperty(ref _description, value); }
        public string PatientId { get => _patientId; set => SetProperty(ref _patientId, value); }
        public string ProviderId { get => _providerId; set => SetProperty(ref _providerId, value); }
        public ProtocolStatus Status { get => _status; set => SetProperty(ref _status, value); }
        public DateTime StartedAt { get => _startedAt; set => SetProperty(ref _startedAt, value); }
        public DateTime? EndedAt { get => _endedAt; set => SetProperty(ref _endedAt, value); }
        public int DurationWeeks { get => _durationWeeks; set => SetProperty(ref _durationWeeks, value); }
        public ObservableCollection<ProtocolStep> Steps { get => _steps; set => SetProperty(ref _steps, value); }
        public string Notes { get => _notes; set => SetProperty(ref _notes, value); }
        public double AdherenceScore { get => _adherenceScore; set => SetProperty(ref _adherenceScore, value); }

        public int WeeksElapsed => (int)((DateTime.UtcNow - StartedAt).TotalDays / 7);
        public double Progress => DurationWeeks > 0 ? (double)WeeksElapsed / DurationWeeks : 0;

        public Protocol()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
            _startedAt = DateTime.UtcNow;
            _status = ProtocolStatus.Draft;
            _steps = new ObservableCollection<ProtocolStep>();
        }
    }

    /// <summary>
    /// A step within a protocol.
    /// </summary>
    public class ProtocolStep : ObservableModel
    {
        private string _id;
        private string _title;
        private string _instructions;
        private int _weekNumber;
        private bool _isComplete;
        private string _notes;

        public string Id { get => _id; set => SetProperty(ref _id, value); }
        public string Title { get => _title; set => SetProperty(ref _title, value); }
        public string Instructions { get => _instructions; set => SetProperty(ref _instructions, value); }
        public int WeekNumber { get => _weekNumber; set => SetProperty(ref _weekNumber, value); }
        public bool IsComplete { get => _isComplete; set => SetProperty(ref _isComplete, value); }
        public string Notes { get => _notes; set => SetProperty(ref _notes, value); }

        public ProtocolStep()
        {
            _id = Guid.NewGuid().ToString("N")[..12];
        }
    }
}
