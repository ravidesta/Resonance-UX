package com.resonance.app.viewmodel

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.resonance.app.data.models.Biomarker
import com.resonance.app.data.models.Contact
import com.resonance.app.data.models.Conversation
import com.resonance.app.data.models.DailyFlow
import com.resonance.app.data.models.Document
import com.resonance.app.data.models.DocumentCategory
import com.resonance.app.data.models.EnergyLevel
import com.resonance.app.data.models.IntentionalStatus
import com.resonance.app.data.models.LuminizeStyle
import com.resonance.app.data.models.Message
import com.resonance.app.data.models.MessageType
import com.resonance.app.data.models.Patient
import com.resonance.app.data.models.PhaseType
import com.resonance.app.data.models.Protocol
import com.resonance.app.data.models.RiskLevel
import com.resonance.app.data.models.Task
import com.resonance.app.data.models.VitalSigns
import com.resonance.app.data.models.WritingSession
import com.resonance.app.data.repository.BiometricRepository
import com.resonance.app.data.repository.BiometricRepositoryImpl
import com.resonance.app.data.repository.DocumentRepository
import com.resonance.app.data.repository.DocumentRepositoryImpl
import com.resonance.app.data.repository.SyncRepository
import com.resonance.app.data.repository.SyncRepositoryImpl
import com.resonance.app.data.repository.SyncStatus
import com.resonance.app.data.repository.TaskRepository
import com.resonance.app.data.repository.TaskRepositoryImpl
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalTime

// ─────────────────────────────────────────────
// Daily Flow ViewModel
// ─────────────────────────────────────────────

class DailyFlowViewModel(
    private val savedStateHandle: SavedStateHandle,
    // In production with Hilt: @Inject constructor(private val taskRepository: TaskRepository, ...)
) : ViewModel() {

    private val taskRepository: TaskRepository = TaskRepositoryImpl()
    private val syncRepository: SyncRepository = SyncRepositoryImpl()

    val tasks: StateFlow<List<Task>> = taskRepository.tasks

    val dailyFlow: StateFlow<DailyFlow?> = taskRepository.dailyFlow

    private val _activePhase = MutableStateFlow(PhaseType.forTime(LocalTime.now()))
    val activePhase: StateFlow<PhaseType> = _activePhase.asStateFlow()

    val spaciousness: StateFlow<Float> = taskRepository.getSpaciousness()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0.7f)

    val energyBudget: StateFlow<Pair<Float, Float>> = taskRepository.getEnergyBudget()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0f to 100f)

    val completionStats: StateFlow<CompletionStats> = tasks.map { taskList ->
        CompletionStats(
            completed = taskList.count { it.isCompleted },
            total = taskList.size,
            totalEnergyUsed = taskList.filter { it.isCompleted }.sumOf { it.energyCost },
            totalEnergyBudget = taskList.sumOf { it.energyCost },
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), CompletionStats())

    val syncStatus: StateFlow<SyncStatus> = syncRepository.syncStatus

    private val _intention = MutableStateFlow(
        savedStateHandle.get<String>("intention") ?: "Move with clarity and calm"
    )
    val intention: StateFlow<String> = _intention.asStateFlow()

    // UI events
    private val _events = MutableSharedFlow<DailyFlowEvent>()
    val events = _events.asSharedFlow()

    init {
        viewModelScope.launch {
            taskRepository.refreshDailyFlow()
        }
    }

    fun addTask(task: Task) = viewModelScope.launch {
        taskRepository.addTask(task)
        _events.emit(DailyFlowEvent.TaskAdded(task.title))
    }

    fun toggleTaskComplete(taskId: String) = viewModelScope.launch {
        taskRepository.toggleComplete(taskId)
        _events.emit(DailyFlowEvent.TaskToggled)
    }

    fun deleteTask(taskId: String) = viewModelScope.launch {
        taskRepository.deleteTask(taskId)
        _events.emit(DailyFlowEvent.TaskDeleted)
    }

    fun reorderTasks(phase: PhaseType, fromIndex: Int, toIndex: Int) = viewModelScope.launch {
        taskRepository.reorderTasks(phase, fromIndex, toIndex)
    }

    fun updateIntention(text: String) {
        _intention.value = text
        savedStateHandle["intention"] = text
    }

    fun sync() = viewModelScope.launch {
        syncRepository.syncAll()
    }
}

data class CompletionStats(
    val completed: Int = 0,
    val total: Int = 0,
    val totalEnergyUsed: Int = 0,
    val totalEnergyBudget: Int = 0,
) {
    val completionFraction: Float get() = if (total > 0) completed.toFloat() / total else 0f
}

sealed class DailyFlowEvent {
    data class TaskAdded(val title: String) : DailyFlowEvent()
    data object TaskToggled : DailyFlowEvent()
    data object TaskDeleted : DailyFlowEvent()
}

// ─────────────────────────────────────────────
// Writer ViewModel
// ─────────────────────────────────────────────

class WriterViewModel(
    private val savedStateHandle: SavedStateHandle,
) : ViewModel() {

    private val documentRepository: DocumentRepository = DocumentRepositoryImpl()

    val documents: StateFlow<List<Document>> = documentRepository.documents

    private val _selectedDocumentId = MutableStateFlow<String?>(null)
    val selectedDocumentId: StateFlow<String?> = _selectedDocumentId.asStateFlow()

    val selectedDocument: StateFlow<Document?> = combine(
        documents,
        _selectedDocumentId,
    ) { docs, selectedId ->
        selectedId?.let { id -> docs.find { it.id == id } } ?: docs.firstOrNull()
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    private val _isFocusMode = MutableStateFlow(false)
    val isFocusMode: StateFlow<Boolean> = _isFocusMode.asStateFlow()

    private val _isLuminizing = MutableStateFlow(false)
    val isLuminizing: StateFlow<Boolean> = _isLuminizing.asStateFlow()

    val activeSession: StateFlow<WritingSession?> = documentRepository.activeSession

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    val searchResults: StateFlow<List<Document>> = documentRepository.searchDocuments("")
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val _selectedCategory = MutableStateFlow<DocumentCategory?>(null)
    val selectedCategory: StateFlow<DocumentCategory?> = _selectedCategory.asStateFlow()

    val filteredDocuments: StateFlow<List<Document>> = combine(
        documents,
        _selectedCategory,
    ) { docs, category ->
        if (category == null) docs
        else docs.filter { it.category == category.name }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun selectDocument(id: String) {
        _selectedDocumentId.value = id
        savedStateHandle["selectedDocId"] = id
    }

    fun toggleFocusMode() {
        _isFocusMode.update { !it }
    }

    fun updateContent(documentId: String, content: String) = viewModelScope.launch {
        val wordCount = content.split("\\s+".toRegex()).filter { it.isNotBlank() }.size
        val readingTime = (wordCount / 200f).toInt().coerceAtLeast(1)
        documents.value.find { it.id == documentId }?.let { doc ->
            documentRepository.updateDocument(
                doc.copy(
                    content = content,
                    wordCount = wordCount,
                    readingTimeMinutes = readingTime,
                )
            )
        }
    }

    fun createNewDocument(title: String = "Untitled", category: DocumentCategory = DocumentCategory.NOTE) =
        viewModelScope.launch {
            val doc = Document(title = title, category = category.name)
            val id = documentRepository.createDocument(doc)
            _selectedDocumentId.value = id
        }

    fun deleteDocument(id: String) = viewModelScope.launch {
        documentRepository.deleteDocument(id)
        if (_selectedDocumentId.value == id) {
            _selectedDocumentId.value = null
        }
    }

    fun luminizeProse(style: LuminizeStyle = LuminizeStyle.CLARIFY) = viewModelScope.launch {
        _isLuminizing.value = true
        delay(3000) // simulate AI processing
        _isLuminizing.value = false
    }

    fun startFocusSession() = viewModelScope.launch {
        _selectedDocumentId.value?.let { docId ->
            documentRepository.startWritingSession(docId)
        }
    }

    fun endFocusSession(wordsWritten: Int) = viewModelScope.launch {
        documentRepository.endWritingSession(wordsWritten)
    }

    fun setCategory(category: DocumentCategory?) {
        _selectedCategory.value = category
    }

    fun setSearchQuery(query: String) {
        _searchQuery.value = query
    }
}

// ─────────────────────────────────────────────
// Wellness ViewModel
// ─────────────────────────────────────────────

class WellnessViewModel(
    private val savedStateHandle: SavedStateHandle,
) : ViewModel() {

    private val biometricRepository: BiometricRepository = BiometricRepositoryImpl()

    val patients: StateFlow<List<Patient>> = biometricRepository.patients
    val biomarkers: StateFlow<List<Biomarker>> = biometricRepository.biomarkers
    val currentVitals: StateFlow<VitalSigns?> = biometricRepository.currentVitals

    private val _selectedTab = MutableStateFlow(0)
    val selectedTab: StateFlow<Int> = _selectedTab.asStateFlow()

    private val _selectedPatient = MutableStateFlow<Patient?>(null)
    val selectedPatient: StateFlow<Patient?> = _selectedPatient.asStateFlow()

    private val _isTranslationActive = MutableStateFlow(false)
    val isTranslationActive: StateFlow<Boolean> = _isTranslationActive.asStateFlow()

    private val _protocolDeploymentStatus = MutableStateFlow<ProtocolDeploymentStatus>(
        ProtocolDeploymentStatus.Idle
    )
    val protocolDeploymentStatus: StateFlow<ProtocolDeploymentStatus> =
        _protocolDeploymentStatus.asStateFlow()

    val criticalPatients: StateFlow<List<Patient>> =
        biometricRepository.getPatientsByRisk(RiskLevel.CRITICAL)
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val highRiskPatients: StateFlow<List<Patient>> =
        biometricRepository.getPatientsByRisk(RiskLevel.HIGH)
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun selectTab(index: Int) {
        _selectedTab.value = index
    }

    fun selectPatient(patient: Patient?) {
        _selectedPatient.value = patient
    }

    fun toggleTranslation() {
        _isTranslationActive.update { !it }
    }

    fun deployProtocol(protocol: Protocol) = viewModelScope.launch {
        _protocolDeploymentStatus.value = ProtocolDeploymentStatus.Deploying(protocol.name)
        try {
            _selectedPatient.value?.let { patient ->
                biometricRepository.deployProtocol(protocol, patient.id)
            }
            _protocolDeploymentStatus.value = ProtocolDeploymentStatus.Success(protocol.name)
            delay(2000)
            _protocolDeploymentStatus.value = ProtocolDeploymentStatus.Idle
        } catch (e: Exception) {
            _protocolDeploymentStatus.value = ProtocolDeploymentStatus.Error(e.message ?: "Unknown error")
        }
    }

    fun recordVitals(vitals: VitalSigns) = viewModelScope.launch {
        biometricRepository.recordVitals(vitals)
    }

    fun addBiomarker(biomarker: Biomarker) = viewModelScope.launch {
        biometricRepository.addBiomarker(biomarker)
    }
}

sealed class ProtocolDeploymentStatus {
    data object Idle : ProtocolDeploymentStatus()
    data class Deploying(val protocolName: String) : ProtocolDeploymentStatus()
    data class Success(val protocolName: String) : ProtocolDeploymentStatus()
    data class Error(val message: String) : ProtocolDeploymentStatus()
}

// ─────────────────────────────────────────────
// Inner Circle ViewModel
// ─────────────────────────────────────────────

class InnerCircleViewModel(
    private val savedStateHandle: SavedStateHandle,
) : ViewModel() {

    private val _contacts = MutableStateFlow(generateSampleContacts())
    val contacts: StateFlow<List<Contact>> = _contacts.asStateFlow()

    private val _selectedContact = MutableStateFlow<Contact?>(null)
    val selectedContact: StateFlow<Contact?> = _selectedContact.asStateFlow()

    private val _conversations = MutableStateFlow<Map<String, List<Message>>>(emptyMap())
    val conversations: StateFlow<Map<String, List<Message>>> = _conversations.asStateFlow()

    private val _myStatus = MutableStateFlow(IntentionalStatus.Available)
    val myStatus: StateFlow<IntentionalStatus> = _myStatus.asStateFlow()

    private val _isRecording = MutableStateFlow(false)
    val isRecording: StateFlow<Boolean> = _isRecording.asStateFlow()

    val groupedContacts: StateFlow<Map<Int, List<Contact>>> = _contacts.map { contactList ->
        contactList.groupBy { it.circleRing }.toSortedMap()
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyMap())

    val unreadCount: StateFlow<Int> = _contacts.map { contactList ->
        contactList.sumOf { it.unreadCount }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    fun selectContact(contact: Contact?) {
        _selectedContact.value = contact
        contact?.let { markAsRead(it.id) }
    }

    fun sendMessage(contactId: String, content: String) = viewModelScope.launch {
        val message = Message(
            conversationId = contactId,
            senderId = "me",
            content = content,
            isFromMe = true,
        )
        _conversations.update { current ->
            val existing = current[contactId] ?: emptyList()
            current + (contactId to (existing + message))
        }
    }

    fun sendVoiceMessage(contactId: String, durationMs: Long, waveform: List<Float>) =
        viewModelScope.launch {
            val message = Message(
                conversationId = contactId,
                senderId = "me",
                content = "",
                type = MessageType.VOICE.name,
                isFromMe = true,
                voiceDurationMs = durationMs,
                waveformData = waveform,
            )
            _conversations.update { current ->
                val existing = current[contactId] ?: emptyList()
                current + (contactId to (existing + message))
            }
        }

    fun setMyStatus(status: IntentionalStatus) {
        _myStatus.value = status
    }

    fun toggleRecording() {
        _isRecording.update { !it }
    }

    private fun markAsRead(contactId: String) {
        _contacts.update { contacts ->
            contacts.map { c ->
                if (c.id == contactId) c.copy(unreadCount = 0) else c
            }
        }
    }

    fun refreshContacts() = viewModelScope.launch {
        delay(1000) // simulate network refresh
    }

    private fun generateSampleContacts(): List<Contact> = listOf(
        Contact(name = "Elena", statusText = "Deep work phase", circleRing = 1,
            lastMessagePreview = "The new design feels so calm", lastMessageTime = "10:15 AM", unreadCount = 2),
        Contact(name = "Marcus", statusText = "Open to connect", circleRing = 1,
            lastMessagePreview = "Voice message", lastMessageTime = "9:42 AM", isFavorite = true),
        Contact(name = "Aria", statusText = "Recharging", circleRing = 1,
            lastMessagePreview = "Let's sync tomorrow", lastMessageTime = "Yesterday"),
        Contact(name = "James", statusText = "In flow", circleRing = 2,
            lastMessagePreview = "Sent you the updated protocol", lastMessageTime = "Yesterday"),
        Contact(name = "Luna", statusText = "Available", circleRing = 2,
            lastMessagePreview = "Beautiful reflection!", lastMessageTime = "Mon", unreadCount = 1),
        Contact(name = "Kai", statusText = "Reflecting", circleRing = 2,
            lastMessagePreview = "I'll review the wellness metrics", lastMessageTime = "Sun"),
        Contact(name = "Sage", statusText = "Open to connect", circleRing = 3,
            lastMessagePreview = "Thanks for the breathwork guide", lastMessageTime = "Last week"),
    )
}
