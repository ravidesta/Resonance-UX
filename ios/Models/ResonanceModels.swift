// ResonanceModels.swift
// Resonance UX — Core Data Models
//
// Foundational data types that flow through the entire Resonance
// ecosystem. Every model is Codable for cloud sync and Identifiable
// for SwiftUI diffing.

import SwiftUI

// MARK: - Task

struct ResonanceTask: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var energyLevel: TaskEnergyLevel
    var domain: String
    var isCompleted: Bool
    var collaborators: [String]
    var scheduledTime: Date?
    var estimatedMinutes: Int
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    var phase: DailyPhaseKind?

    init(
        id: UUID = UUID(),
        title: String,
        energyLevel: TaskEnergyLevel = .balancedFlow,
        domain: String = "General",
        isCompleted: Bool = false,
        collaborators: [String] = [],
        scheduledTime: Date? = nil,
        estimatedMinutes: Int = 30,
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        phase: DailyPhaseKind? = nil
    ) {
        self.id = id
        self.title = title
        self.energyLevel = energyLevel
        self.domain = domain
        self.isCompleted = isCompleted
        self.collaborators = collaborators
        self.scheduledTime = scheduledTime
        self.estimatedMinutes = estimatedMinutes
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.phase = phase
    }
}

enum TaskEnergyLevel: String, Codable, CaseIterable, Identifiable, Hashable {
    case highDeep       = "high_deep"
    case balancedFlow   = "balanced_flow"
    case lowAdmin       = "low_admin"
    case restorative    = "restorative"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .highDeep:     return "High / Deep"
        case .balancedFlow: return "Balanced / Flow"
        case .lowAdmin:     return "Low / Admin"
        case .restorative:  return "Restorative"
        }
    }

    var icon: String {
        switch self {
        case .highDeep:     return "bolt.fill"
        case .balancedFlow: return "wind"
        case .lowAdmin:     return "tray.full"
        case .restorative:  return "leaf"
        }
    }
}

// MARK: - Daily Phase

struct DailyPhase: Identifiable, Codable {
    let id: UUID
    var kind: DailyPhaseKind
    var date: Date
    var events: [PhaseEvent]
    var spaciousnessMinutes: Int
    var startHour: Int
    var endHour: Int

    init(
        id: UUID = UUID(),
        kind: DailyPhaseKind,
        date: Date = Date(),
        events: [PhaseEvent] = [],
        spaciousnessMinutes: Int = 0,
        startHour: Int = 0,
        endHour: Int = 0
    ) {
        self.id = id
        self.kind = kind
        self.date = date
        self.events = events
        self.spaciousnessMinutes = spaciousnessMinutes
        self.startHour = startHour
        self.endHour = endHour
    }

    var spaciousnessHours: Double {
        Double(spaciousnessMinutes) / 60.0
    }
}

struct PhaseEvent: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var startTime: Date
    var durationMinutes: Int
    var energyLevel: TaskEnergyLevel
    var isFlexible: Bool
    var location: String?

    init(
        id: UUID = UUID(),
        title: String,
        startTime: Date = Date(),
        durationMinutes: Int = 30,
        energyLevel: TaskEnergyLevel = .balancedFlow,
        isFlexible: Bool = true,
        location: String? = nil
    ) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.durationMinutes = durationMinutes
        self.energyLevel = energyLevel
        self.isFlexible = isFlexible
        self.location = location
    }
}

// MARK: - Contact

struct ResonanceContact: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var initials: String
    var intentionalStatus: ContactStatus
    var lastMessage: String
    var lastMessageTime: Date
    var isInnerCircle: Bool
    var phoneNumber: String?
    var email: String?
    var avatarColorHex: UInt

    init(
        id: UUID = UUID(),
        name: String,
        initials: String? = nil,
        intentionalStatus: ContactStatus = .openConnect,
        lastMessage: String = "",
        lastMessageTime: Date = Date(),
        isInnerCircle: Bool = true,
        phoneNumber: String? = nil,
        email: String? = nil,
        avatarColorHex: UInt = 0x122E21
    ) {
        self.id = id
        self.name = name
        self.initials = initials ?? String(name.split(separator: " ").compactMap(\.first))
        self.intentionalStatus = intentionalStatus
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.isInnerCircle = isInnerCircle
        self.phoneNumber = phoneNumber
        self.email = email
        self.avatarColorHex = avatarColorHex
    }
}

enum ContactStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case deepWork     = "deep_work"
    case recharging   = "recharging"
    case openConnect  = "open_to_connect"
    case inFlow       = "in_flow"
    case offline      = "offline"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .deepWork:    return "Deep work phase"
        case .recharging:  return "Recharging"
        case .openConnect: return "Open to connect"
        case .inFlow:      return "In flow"
        case .offline:     return "Offline — resting"
        }
    }
}

// MARK: - Document

struct ResonanceDocument: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var tags: [String]
    var folderId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isFavorite: Bool = false,
        tags: [String] = [],
        folderId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.tags = tags
        self.folderId = folderId
    }

    var wordCount: Int {
        content.split(separator: " ").count
    }

    var readingTimeMinutes: Int {
        max(1, wordCount / 238)
    }

    var characterCount: Int {
        content.count
    }
}

// MARK: - Patient & Provider

struct Patient: Identifiable, Codable {
    let id: UUID
    var name: String
    var initials: String
    var dateOfBirth: Date
    var frequency: Double
    var biomarkerIds: [UUID]
    var protocolIds: [UUID]
    var lastEncounter: Date
    var rsdRisk: RSDRiskLevel
    var clinicalNotes: String
    var insuranceProvider: String?
    var emergencyContact: String?

    init(
        id: UUID = UUID(),
        name: String,
        initials: String? = nil,
        dateOfBirth: Date = Date(),
        frequency: Double = 5.0,
        biomarkerIds: [UUID] = [],
        protocolIds: [UUID] = [],
        lastEncounter: Date = Date(),
        rsdRisk: RSDRiskLevel = .low,
        clinicalNotes: String = "",
        insuranceProvider: String? = nil,
        emergencyContact: String? = nil
    ) {
        self.id = id
        self.name = name
        self.initials = initials ?? String(name.split(separator: " ").compactMap(\.first))
        self.dateOfBirth = dateOfBirth
        self.frequency = frequency
        self.biomarkerIds = biomarkerIds
        self.protocolIds = protocolIds
        self.lastEncounter = lastEncounter
        self.rsdRisk = rsdRisk
        self.clinicalNotes = clinicalNotes
        self.insuranceProvider = insuranceProvider
        self.emergencyContact = emergencyContact
    }
}

struct Provider: Identifiable, Codable {
    let id: UUID
    var name: String
    var credentials: String          // e.g. "MD, PhD"
    var specialty: String
    var patientIds: [UUID]
    var retainerClients: Int
    var utilizationPercent: Double
    var nextAvailableSlot: Date
    var retreatSchedule: [RetreatEvent]

    init(
        id: UUID = UUID(),
        name: String,
        credentials: String = "",
        specialty: String = "",
        patientIds: [UUID] = [],
        retainerClients: Int = 0,
        utilizationPercent: Double = 0,
        nextAvailableSlot: Date = Date(),
        retreatSchedule: [RetreatEvent] = []
    ) {
        self.id = id
        self.name = name
        self.credentials = credentials
        self.specialty = specialty
        self.patientIds = patientIds
        self.retainerClients = retainerClients
        self.utilizationPercent = utilizationPercent
        self.nextAvailableSlot = nextAvailableSlot
        self.retreatSchedule = retreatSchedule
    }
}

struct RetreatEvent: Identifiable, Codable {
    let id: UUID
    var name: String
    var location: String
    var startDate: Date
    var endDate: Date
    var participantCount: Int
    var maxParticipants: Int
    var description: String

    init(
        id: UUID = UUID(),
        name: String,
        location: String = "",
        startDate: Date = Date(),
        endDate: Date = Date(),
        participantCount: Int = 0,
        maxParticipants: Int = 20,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.participantCount = participantCount
        self.maxParticipants = maxParticipants
        self.description = description
    }
}

enum RSDRiskLevel: String, Codable, CaseIterable, Hashable {
    case low, moderate, elevated

    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Biomarker (Codable version)

struct BiomarkerRecord: Identifiable, Codable {
    let id: UUID
    var name: String
    var value: Double
    var unit: String
    var normalRangeLow: Double
    var normalRangeHigh: Double
    var trend: BiomarkerTrend
    var recordedAt: Date
    var patientId: UUID

    var isAnomaly: Bool {
        value < normalRangeLow || value > normalRangeHigh
    }

    init(
        id: UUID = UUID(),
        name: String,
        value: Double,
        unit: String,
        normalRangeLow: Double,
        normalRangeHigh: Double,
        trend: BiomarkerTrend = .stable,
        recordedAt: Date = Date(),
        patientId: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.unit = unit
        self.normalRangeLow = normalRangeLow
        self.normalRangeHigh = normalRangeHigh
        self.trend = trend
        self.recordedAt = recordedAt
        self.patientId = patientId
    }
}

enum BiomarkerTrend: String, Codable {
    case rising, falling, stable
}

// MARK: - Protocol (Codable version)

struct WellnessProtocol: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var category: ProtocolCategory
    var isActive: Bool
    var adherencePercent: Double
    var durationDays: Int
    var startDate: Date?
    var patientId: UUID

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        category: ProtocolCategory = .nervous,
        isActive: Bool = false,
        adherencePercent: Double = 0,
        durationDays: Int = 30,
        startDate: Date? = nil,
        patientId: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.isActive = isActive
        self.adherencePercent = adherencePercent
        self.durationDays = durationDays
        self.startDate = startDate
        self.patientId = patientId
    }
}

enum ProtocolCategory: String, Codable, CaseIterable {
    case nervous  = "nervous_system"
    case hormonal = "hormonal"
    case sleep    = "sleep"
    case movement = "movement"
    case crisis   = "crisis"
}

// MARK: - Frequency / Wellness Metrics

struct FrequencySnapshot: Identifiable, Codable {
    let id: UUID
    var value: Double           // 0.0 – 10.0
    var timestamp: Date
    var source: FrequencySource
    var components: FrequencyComponents

    init(
        id: UUID = UUID(),
        value: Double,
        timestamp: Date = Date(),
        source: FrequencySource = .composite,
        components: FrequencyComponents = FrequencyComponents()
    ) {
        self.id = id
        self.value = value
        self.timestamp = timestamp
        self.source = source
        self.components = components
    }
}

enum FrequencySource: String, Codable {
    case composite       // blended from all inputs
    case hrv             // heart rate variability
    case sleep           // sleep quality score
    case breathwork      // session-based
    case selfReport      // patient check-in
}

struct FrequencyComponents: Codable {
    var nervousSystemRegulation: Double  // 0-10
    var sleepQuality: Double             // 0-10
    var movementBalance: Double          // 0-10
    var socialConnection: Double         // 0-10
    var purposeAlignment: Double         // 0-10

    init(
        nervousSystemRegulation: Double = 5.0,
        sleepQuality: Double = 5.0,
        movementBalance: Double = 5.0,
        socialConnection: Double = 5.0,
        purposeAlignment: Double = 5.0
    ) {
        self.nervousSystemRegulation = nervousSystemRegulation
        self.sleepQuality = sleepQuality
        self.movementBalance = movementBalance
        self.socialConnection = socialConnection
        self.purposeAlignment = purposeAlignment
    }

    var composite: Double {
        (nervousSystemRegulation + sleepQuality + movementBalance + socialConnection + purposeAlignment) / 5.0
    }
}

// MARK: - Breathwork

struct BreathworkSession: Identifiable, Codable {
    let id: UUID
    var technique: BreathworkTechnique
    var durationSeconds: Int
    var startedAt: Date
    var completedAt: Date?
    var preHRV: Double?
    var postHRV: Double?
    var isCohortSession: Bool
    var cohortParticipants: Int

    init(
        id: UUID = UUID(),
        technique: BreathworkTechnique = .boxBreathing,
        durationSeconds: Int = 300,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        preHRV: Double? = nil,
        postHRV: Double? = nil,
        isCohortSession: Bool = false,
        cohortParticipants: Int = 0
    ) {
        self.id = id
        self.technique = technique
        self.durationSeconds = durationSeconds
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.preHRV = preHRV
        self.postHRV = postHRV
        self.isCohortSession = isCohortSession
        self.cohortParticipants = cohortParticipants
    }
}

enum BreathworkTechnique: String, Codable, CaseIterable {
    case boxBreathing    = "box_breathing"
    case fourSevenEight  = "4_7_8"
    case coherence       = "coherence"
    case wim_hof         = "wim_hof"
    case resonant        = "resonant"

    var displayName: String {
        switch self {
        case .boxBreathing:   return "Box Breathing"
        case .fourSevenEight: return "4-7-8"
        case .coherence:      return "Coherence"
        case .wim_hof:        return "Wim Hof"
        case .resonant:       return "Resonant Breathing"
        }
    }
}

// MARK: - Message

struct ResonanceMessage: Identifiable, Codable {
    let id: UUID
    var senderId: UUID
    var recipientId: UUID
    var text: String?
    var isVoiceMessage: Bool
    var voiceDurationSeconds: Int
    var timestamp: Date
    var isRead: Bool
    var isEncrypted: Bool

    init(
        id: UUID = UUID(),
        senderId: UUID = UUID(),
        recipientId: UUID = UUID(),
        text: String? = nil,
        isVoiceMessage: Bool = false,
        voiceDurationSeconds: Int = 0,
        timestamp: Date = Date(),
        isRead: Bool = false,
        isEncrypted: Bool = true
    ) {
        self.id = id
        self.senderId = senderId
        self.recipientId = recipientId
        self.text = text
        self.isVoiceMessage = isVoiceMessage
        self.voiceDurationSeconds = voiceDurationSeconds
        self.timestamp = timestamp
        self.isRead = isRead
        self.isEncrypted = isEncrypted
    }
}

// MARK: - Notification Preference

struct NotificationPreference: Codable {
    var allowDuringDeepWork: Bool = false
    var allowDuringRest: Bool = false
    var batchIntervalMinutes: Int = 30
    var useCalmTone: Bool = true
    var vibrationPattern: VibrationPattern = .gentle

    enum VibrationPattern: String, Codable {
        case gentle, minimal, none
    }
}

// MARK: - Sync Metadata

struct SyncMetadata: Codable {
    var lastSyncTimestamp: Date
    var deviceId: String
    var conflictResolution: ConflictResolution

    enum ConflictResolution: String, Codable {
        case lastWriteWins
        case manualResolve
        case mergeFields
    }
}
