package com.resonance.app.data.repository

import com.resonance.app.data.models.Biomarker
import com.resonance.app.data.models.BiomarkerTrend
import com.resonance.app.data.models.Contact
import com.resonance.app.data.models.Conversation
import com.resonance.app.data.models.DailyFlow
import com.resonance.app.data.models.DailyPhase
import com.resonance.app.data.models.Document
import com.resonance.app.data.models.DocumentCategory
import com.resonance.app.data.models.Domain
import com.resonance.app.data.models.Encounter
import com.resonance.app.data.models.Message
import com.resonance.app.data.models.Patient
import com.resonance.app.data.models.PhaseType
import com.resonance.app.data.models.Protocol
import com.resonance.app.data.models.RiskLevel
import com.resonance.app.data.models.Task
import com.resonance.app.data.models.VitalSigns
import com.resonance.app.data.models.WritingSession
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.update
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime

// ─────────────────────────────────────────────
// Task Repository
// ─────────────────────────────────────────────

interface TaskRepository {
    val tasks: StateFlow<List<Task>>
    val dailyFlow: StateFlow<DailyFlow?>
    fun getTasksForPhase(phase: PhaseType): Flow<List<Task>>
    suspend fun addTask(task: Task)
    suspend fun updateTask(task: Task)
    suspend fun deleteTask(taskId: String)
    suspend fun reorderTasks(phase: PhaseType, fromIndex: Int, toIndex: Int)
    suspend fun toggleComplete(taskId: String)
    suspend fun refreshDailyFlow()
    fun getSpaciousness(): Flow<Float>
    fun getEnergyBudget(): Flow<Pair<Float, Float>>
}

class TaskRepositoryImpl : TaskRepository {

    private val _tasks = MutableStateFlow<List<Task>>(generateSampleTasks())
    override val tasks: StateFlow<List<Task>> = _tasks.asStateFlow()

    private val _dailyFlow = MutableStateFlow<DailyFlow?>(null)
    override val dailyFlow: StateFlow<DailyFlow?> = _dailyFlow.asStateFlow()

    init {
        refreshDailyFlowSync()
    }

    override fun getTasksForPhase(phase: PhaseType): Flow<List<Task>> =
        _tasks.map { taskList ->
            taskList.filter { it.assignedPhase == phase.name }
                .sortedBy { it.order }
        }

    override suspend fun addTask(task: Task) {
        _tasks.update { current -> current + task }
    }

    override suspend fun updateTask(task: Task) {
        _tasks.update { current ->
            current.map { if (it.id == task.id) task else it }
        }
    }

    override suspend fun deleteTask(taskId: String) {
        _tasks.update { current -> current.filter { it.id != taskId } }
    }

    override suspend fun reorderTasks(phase: PhaseType, fromIndex: Int, toIndex: Int) {
        _tasks.update { current ->
            val phaseTasks = current.filter { it.assignedPhase == phase.name }.toMutableList()
            val otherTasks = current.filter { it.assignedPhase != phase.name }

            if (fromIndex in phaseTasks.indices && toIndex in phaseTasks.indices) {
                val item = phaseTasks.removeAt(fromIndex)
                phaseTasks.add(toIndex, item)
                val reordered = phaseTasks.mapIndexed { index, task ->
                    task.copy(order = index)
                }
                otherTasks + reordered
            } else {
                current
            }
        }
    }

    override suspend fun toggleComplete(taskId: String) {
        _tasks.update { current ->
            current.map { task ->
                if (task.id == taskId) {
                    task.copy(
                        isCompleted = !task.isCompleted,
                        completedAt = if (!task.isCompleted) Instant.now().toString() else null,
                    )
                } else task
            }
        }
    }

    override suspend fun refreshDailyFlow() {
        delay(300) // simulate network
        refreshDailyFlowSync()
    }

    override fun getSpaciousness(): Flow<Float> = flow {
        while (true) {
            val completedRatio = _tasks.value.let { tasks ->
                if (tasks.isEmpty()) 0.7f
                else {
                    val totalEnergy = tasks.sumOf { it.energyCost }.toFloat()
                    val completedEnergy = tasks.filter { it.isCompleted }.sumOf { it.energyCost }.toFloat()
                    val baselineOpenness = 0.4f
                    baselineOpenness + (completedEnergy / totalEnergy.coerceAtLeast(1f)) * 0.5f
                }
            }
            emit(completedRatio.coerceIn(0f, 1f))
            delay(5000)
        }
    }

    override fun getEnergyBudget(): Flow<Pair<Float, Float>> =
        _tasks.map { taskList ->
            val used = taskList.filter { it.isCompleted }.sumOf { it.energyCost }.toFloat()
            val total = taskList.sumOf { it.energyCost }.toFloat()
            used to total
        }

    private fun refreshDailyFlowSync() {
        val now = LocalTime.now()
        val activePhase = PhaseType.forTime(now)

        _dailyFlow.value = DailyFlow(
            date = LocalDate.now().toString(),
            phases = PhaseType.entries.map { phase ->
                val phaseTasks = _tasks.value.filter { it.assignedPhase == phase.name }
                DailyPhase(
                    type = phase,
                    startTime = when (phase) {
                        PhaseType.ASCEND -> "06:00"
                        PhaseType.ZENITH -> "11:00"
                        PhaseType.DESCENT -> "15:00"
                        PhaseType.REST -> "20:00"
                    },
                    endTime = when (phase) {
                        PhaseType.ASCEND -> "11:00"
                        PhaseType.ZENITH -> "15:00"
                        PhaseType.DESCENT -> "20:00"
                        PhaseType.REST -> "06:00"
                    },
                    energyLevel = when (phase) {
                        PhaseType.ASCEND -> 3
                        PhaseType.ZENITH -> 4
                        PhaseType.DESCENT -> 2
                        PhaseType.REST -> 1
                    },
                    spaciousness = 0.7f,
                    isActive = phase == activePhase,
                    completedTasks = phaseTasks.count { it.isCompleted },
                    totalTasks = phaseTasks.size,
                )
            },
            intentionOfTheDay = "Move with clarity and calm",
        )
    }

    private fun generateSampleTasks(): List<Task> = listOf(
        Task(title = "Morning meditation", domain = Domain.HEALTH.name, energyCost = 1,
            assignedPhase = PhaseType.ASCEND.name, estimatedMinutes = 15, order = 0),
        Task(title = "Review design tokens", domain = Domain.WORK.name, energyCost = 3,
            assignedPhase = PhaseType.ASCEND.name, estimatedMinutes = 45, order = 1),
        Task(title = "Architecture review", domain = Domain.WORK.name, energyCost = 4,
            assignedPhase = PhaseType.ZENITH.name, estimatedMinutes = 90, order = 0),
        Task(title = "Team sync", domain = Domain.WORK.name, energyCost = 2,
            assignedPhase = PhaseType.ZENITH.name, estimatedMinutes = 30, order = 1),
        Task(title = "Reply to letters", domain = Domain.RELATIONSHIPS.name, energyCost = 2,
            assignedPhase = PhaseType.DESCENT.name, estimatedMinutes = 20, order = 0),
        Task(title = "Gentle walk", domain = Domain.HEALTH.name, energyCost = 1,
            assignedPhase = PhaseType.DESCENT.name, estimatedMinutes = 30, order = 1),
        Task(title = "Evening reflection", domain = Domain.PERSONAL.name, energyCost = 1,
            assignedPhase = PhaseType.REST.name, estimatedMinutes = 15, order = 0),
    )
}

// ─────────────────────────────────────────────
// Document Repository
// ─────────────────────────────────────────────

interface DocumentRepository {
    val documents: StateFlow<List<Document>>
    val activeSession: StateFlow<WritingSession?>
    fun getDocument(id: String): Flow<Document?>
    fun getDocumentsByCategory(category: DocumentCategory): Flow<List<Document>>
    suspend fun createDocument(document: Document): String
    suspend fun updateDocument(document: Document)
    suspend fun deleteDocument(id: String)
    suspend fun startWritingSession(documentId: String): WritingSession
    suspend fun endWritingSession(wordsWritten: Int)
    fun searchDocuments(query: String): Flow<List<Document>>
}

class DocumentRepositoryImpl : DocumentRepository {

    private val _documents = MutableStateFlow<List<Document>>(generateSampleDocuments())
    override val documents: StateFlow<List<Document>> = _documents.asStateFlow()

    private val _activeSession = MutableStateFlow<WritingSession?>(null)
    override val activeSession: StateFlow<WritingSession?> = _activeSession.asStateFlow()

    override fun getDocument(id: String): Flow<Document?> =
        _documents.map { docs -> docs.find { it.id == id } }

    override fun getDocumentsByCategory(category: DocumentCategory): Flow<List<Document>> =
        _documents.map { docs -> docs.filter { it.category == category.name } }

    override suspend fun createDocument(document: Document): String {
        _documents.update { it + document }
        return document.id
    }

    override suspend fun updateDocument(document: Document) {
        _documents.update { docs ->
            docs.map { if (it.id == document.id) document.copy(updatedAt = Instant.now().toString()) else it }
        }
    }

    override suspend fun deleteDocument(id: String) {
        _documents.update { docs -> docs.filter { it.id != id } }
    }

    override suspend fun startWritingSession(documentId: String): WritingSession {
        val session = WritingSession(documentId = documentId)
        _activeSession.value = session
        return session
    }

    override suspend fun endWritingSession(wordsWritten: Int) {
        _activeSession.update { session ->
            session?.copy(
                endedAt = Instant.now().toString(),
                wordsWritten = wordsWritten,
            )
        }
        _activeSession.value = null
    }

    override fun searchDocuments(query: String): Flow<List<Document>> =
        _documents.map { docs ->
            if (query.isBlank()) docs
            else docs.filter {
                it.title.contains(query, ignoreCase = true) ||
                        it.content.contains(query, ignoreCase = true) ||
                        it.tags.any { tag -> tag.contains(query, ignoreCase = true) }
            }
        }

    private fun generateSampleDocuments(): List<Document> = listOf(
        Document(title = "On Stillness", category = DocumentCategory.ESSAY.name,
            wordCount = 342, readingTimeMinutes = 2, isFavorite = true, tags = listOf("philosophy", "calm")),
        Document(title = "Morning Pages - March", category = DocumentCategory.JOURNAL.name,
            wordCount = 1205, readingTimeMinutes = 5),
        Document(title = "Letter to Elena", category = DocumentCategory.LETTER.name,
            wordCount = 480, readingTimeMinutes = 2),
        Document(title = "The Garden of Hours", category = DocumentCategory.POEM.name,
            wordCount = 67, readingTimeMinutes = 1),
    )
}

// ─────────────────────────────────────────────
// Sync Repository
// ─────────────────────────────────────────────

interface SyncRepository {
    val syncStatus: StateFlow<SyncStatus>
    val lastSyncTimestamp: StateFlow<String?>
    suspend fun syncAll()
    suspend fun syncTasks()
    suspend fun syncDocuments()
    suspend fun syncContacts()
    fun observeSyncStatus(): Flow<SyncStatus>
}

enum class SyncStatus { IDLE, SYNCING, SUCCESS, ERROR }

class SyncRepositoryImpl : SyncRepository {
    private val _syncStatus = MutableStateFlow(SyncStatus.IDLE)
    override val syncStatus: StateFlow<SyncStatus> = _syncStatus.asStateFlow()

    private val _lastSync = MutableStateFlow<String?>(null)
    override val lastSyncTimestamp: StateFlow<String?> = _lastSync.asStateFlow()

    override suspend fun syncAll() {
        _syncStatus.value = SyncStatus.SYNCING
        try {
            delay(1500) // simulate network
            syncTasks()
            syncDocuments()
            syncContacts()
            _lastSync.value = Instant.now().toString()
            _syncStatus.value = SyncStatus.SUCCESS
        } catch (e: Exception) {
            _syncStatus.value = SyncStatus.ERROR
        }
    }

    override suspend fun syncTasks() { delay(500) }
    override suspend fun syncDocuments() { delay(500) }
    override suspend fun syncContacts() { delay(500) }

    override fun observeSyncStatus(): Flow<SyncStatus> = _syncStatus.asStateFlow()
}

// ─────────────────────────────────────────────
// Biometric Repository
// ─────────────────────────────────────────────

interface BiometricRepository {
    val currentVitals: StateFlow<VitalSigns?>
    val patients: StateFlow<List<Patient>>
    val biomarkers: StateFlow<List<Biomarker>>
    fun getBiomarkersForPatient(patientId: String): Flow<List<Biomarker>>
    fun getVitalHistory(hours: Int): Flow<List<VitalSigns>>
    suspend fun recordVitals(vitals: VitalSigns)
    suspend fun addBiomarker(biomarker: Biomarker)
    fun getPatientsByRisk(riskLevel: RiskLevel): Flow<List<Patient>>
    suspend fun deployProtocol(protocol: Protocol, patientId: String)
}

class BiometricRepositoryImpl : BiometricRepository {

    private val _currentVitals = MutableStateFlow<VitalSigns?>(
        VitalSigns(heartRate = 72, hrv = 42f, sleepQuality = 0.78f,
            stressLevel = 0.35f, bloodOxygen = 98.2f, steps = 4520)
    )
    override val currentVitals: StateFlow<VitalSigns?> = _currentVitals.asStateFlow()

    private val _patients = MutableStateFlow(generateSamplePatients())
    override val patients: StateFlow<List<Patient>> = _patients.asStateFlow()

    private val _biomarkers = MutableStateFlow(generateSampleBiomarkers())
    override val biomarkers: StateFlow<List<Biomarker>> = _biomarkers.asStateFlow()

    override fun getBiomarkersForPatient(patientId: String): Flow<List<Biomarker>> =
        _biomarkers.asStateFlow().map { it } // simplified: would filter by patient in production

    override fun getVitalHistory(hours: Int): Flow<List<VitalSigns>> = flow {
        val history = (0 until hours).map { hour ->
            VitalSigns(
                heartRate = (60 + (Math.random() * 30).toInt()),
                hrv = (35 + Math.random() * 25).toFloat(),
                stressLevel = (Math.random() * 0.7).toFloat(),
            )
        }
        emit(history)
    }

    override suspend fun recordVitals(vitals: VitalSigns) {
        _currentVitals.value = vitals
    }

    override suspend fun addBiomarker(biomarker: Biomarker) {
        _biomarkers.update { it + biomarker }
    }

    override fun getPatientsByRisk(riskLevel: RiskLevel): Flow<List<Patient>> =
        _patients.map { patients ->
            patients.filter { it.riskLevel == riskLevel }
        }

    override suspend fun deployProtocol(protocol: Protocol, patientId: String) {
        delay(500) // simulate
    }

    private fun generateSamplePatients(): List<Patient> = listOf(
        Patient(name = "Sarah M.", dateOfBirth = "1985-06-15", mrn = "MRN-001",
            conditions = listOf("Hypertension", "Anxiety"), riskLevel = RiskLevel.HIGH),
        Patient(name = "David L.", dateOfBirth = "1992-03-22", mrn = "MRN-002",
            conditions = listOf("Type 2 Diabetes"), riskLevel = RiskLevel.MODERATE),
        Patient(name = "Maria G.", dateOfBirth = "1978-11-08", mrn = "MRN-003",
            conditions = listOf("Post-surgical"), riskLevel = RiskLevel.LOW),
        Patient(name = "James R.", dateOfBirth = "1960-01-30", mrn = "MRN-004",
            conditions = listOf("CHF", "COPD", "CKD Stage 3"), riskLevel = RiskLevel.CRITICAL),
    )

    private fun generateSampleBiomarkers(): List<Biomarker> = listOf(
        Biomarker(name = "Heart Rate", value = 72f, unit = "bpm",
            normalRangeLow = 60f, normalRangeHigh = 100f, trend = BiomarkerTrend.STABLE),
        Biomarker(name = "Blood Pressure (Sys)", value = 138f, unit = "mmHg",
            normalRangeLow = 90f, normalRangeHigh = 130f, trend = BiomarkerTrend.RISING),
        Biomarker(name = "HbA1c", value = 7.2f, unit = "%",
            normalRangeLow = 4f, normalRangeHigh = 5.7f, trend = BiomarkerTrend.FALLING),
        Biomarker(name = "Cortisol", value = 18.5f, unit = "mcg/dL",
            normalRangeLow = 6f, normalRangeHigh = 18f, trend = BiomarkerTrend.RISING),
    )
}
