package com.resonance.app.data.models

import kotlinx.serialization.Serializable
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.util.UUID

// ─────────────────────────────────────────────
// Energy & Phase System
// ─────────────────────────────────────────────

sealed class EnergyLevel(val value: Int, val label: String) {
    data object Depleted : EnergyLevel(0, "Depleted")
    data object Low : EnergyLevel(1, "Low")
    data object Moderate : EnergyLevel(2, "Moderate")
    data object High : EnergyLevel(3, "High")
    data object Peak : EnergyLevel(4, "Peak")

    companion object {
        fun fromValue(v: Int): EnergyLevel = when {
            v <= 0 -> Depleted
            v == 1 -> Low
            v == 2 -> Moderate
            v == 3 -> High
            else -> Peak
        }
    }

    val normalizedValue: Float get() = value / 4f
}

enum class PhaseType(val displayName: String, val emoji: String) {
    ASCEND("Ascend", "\u2191"),
    ZENITH("Zenith", "\u2600"),
    DESCENT("Descent", "\u2193"),
    REST("Rest", "\u263D");

    companion object {
        fun forTime(time: LocalTime): PhaseType = when (time.hour) {
            in 5..10 -> ASCEND
            in 11..14 -> ZENITH
            in 15..19 -> DESCENT
            else -> REST
        }
    }
}

@Serializable
data class DailyPhase(
    val type: PhaseType,
    val startTime: String, // ISO time
    val endTime: String,
    val energyLevel: Int,
    val spaciousness: Float, // 0.0 - 1.0
    val isActive: Boolean = false,
    val completedTasks: Int = 0,
    val totalTasks: Int = 0
) {
    val progressFraction: Float
        get() = if (totalTasks > 0) completedTasks.toFloat() / totalTasks else 0f
}

@Serializable
data class DailyFlow(
    val id: String = UUID.randomUUID().toString(),
    val date: String, // ISO date
    val phases: List<DailyPhase>,
    val overallSpaciousness: Float = 0.7f,
    val energyBudgetUsed: Float = 0f,
    val energyBudgetTotal: Float = 100f,
    val intentionOfTheDay: String = ""
)

// ─────────────────────────────────────────────
// Tasks & Domains
// ─────────────────────────────────────────────

enum class Domain(val displayName: String, val colorHex: Long) {
    PERSONAL("Personal", 0xFF0A1C14),
    WORK("Work", 0xFF122E21),
    HEALTH("Health", 0xFF1A4032),
    CREATIVE("Creative", 0xFFC5A059),
    LEARNING("Learning", 0xFF2D5A3F),
    RELATIONSHIPS("Relationships", 0xFF3D7A5F)
}

enum class TaskPriority { ESSENTIAL, IMPORTANT, FLEXIBLE, ASPIRATIONAL }

@Serializable
data class Task(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val description: String = "",
    val domain: String = Domain.PERSONAL.name,
    val energyCost: Int = 2, // 1-4
    val priority: String = TaskPriority.FLEXIBLE.name,
    val assignedPhase: String = PhaseType.ASCEND.name,
    val isCompleted: Boolean = false,
    val completedAt: String? = null,
    val createdAt: String = Instant.now().toString(),
    val estimatedMinutes: Int = 30,
    val isRecurring: Boolean = false,
    val recurringPattern: String? = null,
    val notes: String = "",
    val order: Int = 0
)

@Serializable
data class TimelineEvent(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val startTime: String,
    val endTime: String? = null,
    val phase: String,
    val energyCost: Int = 1,
    val type: TimelineEventType = TimelineEventType.TASK,
    val isCompleted: Boolean = false,
    val taskId: String? = null
)

enum class TimelineEventType {
    TASK, APPOINTMENT, BREAK, RITUAL, TRANSITION
}

// ─────────────────────────────────────────────
// Contacts & Messaging (Inner Circle)
// ─────────────────────────────────────────────

sealed class IntentionalStatus(val displayText: String, val allowsInterruption: Boolean) {
    data object DeepWork : IntentionalStatus("Deep work phase", false)
    data object Recharging : IntentionalStatus("Recharging", false)
    data object OpenToConnect : IntentionalStatus("Open to connect", true)
    data object InFlow : IntentionalStatus("In flow", false)
    data object Available : IntentionalStatus("Available", true)
    data object Reflecting : IntentionalStatus("Reflecting", false)
    data class Custom(val text: String, val interruptible: Boolean) :
        IntentionalStatus(text, interruptible)

    companion object {
        val allPresets = listOf(DeepWork, Recharging, OpenToConnect, InFlow, Available, Reflecting)

        fun fromString(s: String): IntentionalStatus = when (s) {
            "Deep work phase" -> DeepWork
            "Recharging" -> Recharging
            "Open to connect" -> OpenToConnect
            "In flow" -> InFlow
            "Available" -> Available
            "Reflecting" -> Reflecting
            else -> Custom(s, true)
        }
    }
}

@Serializable
data class Contact(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val avatarUrl: String? = null,
    val statusText: String = "Available",
    val lastSeen: String? = null,
    val circleRing: Int = 1, // 1 = innermost, 3 = outermost
    val isFavorite: Boolean = false,
    val unreadCount: Int = 0,
    val lastMessagePreview: String? = null,
    val lastMessageTime: String? = null
)

enum class MessageType { TEXT, VOICE, IMAGE, VIDEO, DOCUMENT, SYSTEM }

@Serializable
data class Message(
    val id: String = UUID.randomUUID().toString(),
    val conversationId: String,
    val senderId: String,
    val content: String,
    val type: String = MessageType.TEXT.name,
    val timestamp: String = Instant.now().toString(),
    val isRead: Boolean = false,
    val voiceDurationMs: Long? = null,
    val waveformData: List<Float>? = null,
    val replyToId: String? = null,
    val isFromMe: Boolean = false
)

@Serializable
data class Conversation(
    val id: String = UUID.randomUUID().toString(),
    val contactId: String,
    val messages: List<Message> = emptyList(),
    val lastActivity: String = Instant.now().toString(),
    val isArchived: Boolean = false
)

// ─────────────────────────────────────────────
// Writer / Documents
// ─────────────────────────────────────────────

enum class DocumentCategory { JOURNAL, ESSAY, LETTER, NOTE, STORY, POEM, REFLECTION }

@Serializable
data class Document(
    val id: String = UUID.randomUUID().toString(),
    val title: String = "Untitled",
    val content: String = "",
    val category: String = DocumentCategory.NOTE.name,
    val createdAt: String = Instant.now().toString(),
    val updatedAt: String = Instant.now().toString(),
    val wordCount: Int = 0,
    val readingTimeMinutes: Int = 0,
    val isFavorite: Boolean = false,
    val isArchived: Boolean = false,
    val tags: List<String> = emptyList(),
    val focusSessionCount: Int = 0,
    val totalFocusMinutes: Int = 0
)

@Serializable
data class WritingSession(
    val id: String = UUID.randomUUID().toString(),
    val documentId: String,
    val startedAt: String = Instant.now().toString(),
    val endedAt: String? = null,
    val wordsWritten: Int = 0,
    val durationMinutes: Int = 0,
    val focusScore: Float = 0f // 0.0 - 1.0
)

@Serializable
data class LuminizeRequest(
    val originalText: String,
    val style: LuminizeStyle = LuminizeStyle.CLARIFY,
    val preserveVoice: Boolean = true
)

enum class LuminizeStyle(val displayName: String) {
    CLARIFY("Clarify"),
    ELEVATE("Elevate"),
    SIMPLIFY("Simplify"),
    POETIC("Make Poetic"),
    CONCISE("Make Concise")
}

// ─────────────────────────────────────────────
// Wellness / Healthcare
// ─────────────────────────────────────────────

@Serializable
data class Patient(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val dateOfBirth: String,
    val mrn: String, // Medical Record Number
    val primaryProvider: String? = null,
    val conditions: List<String> = emptyList(),
    val allergies: List<String> = emptyList(),
    val currentMedications: List<String> = emptyList(),
    val riskLevel: RiskLevel = RiskLevel.MODERATE,
    val lastEncounter: String? = null,
    val avatarUrl: String? = null
)

enum class RiskLevel(val displayName: String) {
    LOW("Low"), MODERATE("Moderate"), HIGH("High"), CRITICAL("Critical")
}

@Serializable
data class Provider(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val specialty: String,
    val avatarUrl: String? = null,
    val activePatients: Int = 0,
    val nextAvailable: String? = null,
    val isOnCall: Boolean = false
)

@Serializable
data class Biomarker(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val value: Float,
    val unit: String,
    val normalRangeLow: Float,
    val normalRangeHigh: Float,
    val timestamp: String = Instant.now().toString(),
    val trend: BiomarkerTrend = BiomarkerTrend.STABLE,
    val category: String = "General"
) {
    val isInRange: Boolean get() = value in normalRangeLow..normalRangeHigh
    val deviationPercent: Float
        get() {
            val mid = (normalRangeLow + normalRangeHigh) / 2f
            return if (mid > 0) ((value - mid) / mid) * 100f else 0f
        }
}

enum class BiomarkerTrend { RISING, FALLING, STABLE, VOLATILE }

@Serializable
data class Protocol(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val description: String,
    val steps: List<ProtocolStep> = emptyList(),
    val frequency: String = Frequency.DAILY.name,
    val isActive: Boolean = false,
    val patientId: String? = null,
    val deployedAt: String? = null,
    val outcomes: List<String> = emptyList()
)

@Serializable
data class ProtocolStep(
    val order: Int,
    val instruction: String,
    val isCompleted: Boolean = false,
    val completedAt: String? = null,
    val notes: String = ""
)

enum class Frequency(val displayName: String) {
    ONCE("Once"),
    DAILY("Daily"),
    TWICE_DAILY("Twice Daily"),
    WEEKLY("Weekly"),
    BIWEEKLY("Biweekly"),
    MONTHLY("Monthly"),
    AS_NEEDED("As Needed")
}

@Serializable
data class Encounter(
    val id: String = UUID.randomUUID().toString(),
    val patientId: String,
    val providerId: String,
    val date: String,
    val chiefComplaint: String = "",
    val notes: String = "",
    val biomarkers: List<Biomarker> = emptyList(),
    val protocols: List<String> = emptyList(),
    val status: EncounterStatus = EncounterStatus.IN_PROGRESS
)

enum class EncounterStatus {
    SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED, FOLLOW_UP_NEEDED
}

// ─────────────────────────────────────────────
// RSD Lightning Protocol (Wear OS & mobile)
// ─────────────────────────────────────────────

@Serializable
data class RsdProtocol(
    val id: String = UUID.randomUUID().toString(),
    val name: String = "RSD Lightning Protocol",
    val steps: List<RsdStep> = defaultRsdSteps(),
    val activatedAt: String? = null,
    val completedAt: String? = null,
    val intensityBefore: Int = 0, // 1-10
    val intensityAfter: Int? = null
)

@Serializable
data class RsdStep(
    val order: Int,
    val label: String,
    val instruction: String,
    val durationSeconds: Int,
    val breathPattern: BreathPattern? = null,
    val hapticPattern: String? = null
)

@Serializable
data class BreathPattern(
    val inhaleSeconds: Int = 4,
    val holdSeconds: Int = 4,
    val exhaleSeconds: Int = 6,
    val pauseSeconds: Int = 2,
    val cycles: Int = 3
)

fun defaultRsdSteps(): List<RsdStep> = listOf(
    RsdStep(1, "Ground", "Feel your feet on the floor. Name 3 things you can see.", 15, null, "DOUBLE_TAP"),
    RsdStep(2, "Breathe", "Box breathing: In 4, Hold 4, Out 6, Pause 2", 60,
        BreathPattern(4, 4, 6, 2, 3), "SLOW_PULSE"),
    RsdStep(3, "Label", "Name the emotion without judgment. 'I notice I'm feeling...'", 20, null, "SINGLE_TAP"),
    RsdStep(4, "Reframe", "This feeling is temporary. What would my calm self say?", 20, null, null),
    RsdStep(5, "Act", "Choose one small, intentional action.", 15, null, "COMPLETION")
)

// ─────────────────────────────────────────────
// Vital Signs (Wear OS)
// ─────────────────────────────────────────────

@Serializable
data class VitalSigns(
    val heartRate: Int? = null,
    val hrv: Float? = null,
    val sleepQuality: Float? = null, // 0.0 - 1.0
    val stressLevel: Float? = null,
    val bodyTemperature: Float? = null,
    val bloodOxygen: Float? = null,
    val steps: Int = 0,
    val timestamp: String = Instant.now().toString()
)

// ─────────────────────────────────────────────
// Navigation
// ─────────────────────────────────────────────

enum class ResonanceScreen(val route: String, val label: String) {
    FLOW("flow", "Flow"),
    FOCUS("focus", "Focus"),
    CREATE("create", "Create"),
    LETTERS("letters", "Letters"),
    CANVAS("canvas", "Canvas")
}
