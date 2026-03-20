// ResonanceService.swift
// Resonance UX — Service Layer
//
// Networking, AI prose refinement, biometric sync, calm notifications,
// and cross-device cloud continuity. Every service honors the user's
// current phase and intentional status.

import SwiftUI
import Combine

// MARK: - Cloud Sync Protocol

protocol CloudSyncable {
    associatedtype Model: Codable & Identifiable
    func push(_ items: [Model]) async throws
    func pull(since: Date) async throws -> [Model]
    func resolve(conflict: SyncConflict<Model>) async throws -> Model
}

struct SyncConflict<T: Codable & Identifiable> {
    let local: T
    let remote: T
    let localTimestamp: Date
    let remoteTimestamp: Date
}

// MARK: - API Client

final class ResonanceAPIClient: ObservableObject {
    static let shared = ResonanceAPIClient()

    @Published var isOnline: Bool = true
    @Published var lastSyncDate: Date?
    @Published var syncInProgress: Bool = false

    private let baseURL: URL
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()

    init(baseURL: URL = URL(string: "https://api.resonance.systems/v1")!) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = [
            "Content-Type": "application/json",
            "X-Resonance-Client": "ios-native"
        ]
        self.session = URLSession(configuration: config)

        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: Generic Request

    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil
    ) async throws -> T {
        var url = baseURL.appendingPathComponent(endpoint)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if let body = body {
            urlRequest.httpBody = try encoder.encode(AnyEncodable(body))
        }

        // Add auth token if available
        if let token = TokenStore.shared.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResonanceError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ResonanceError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return try decoder.decode(T.self, from: data)
    }

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    // MARK: Sync

    func syncAll() async throws {
        await MainActor.run { syncInProgress = true }
        defer { Task { @MainActor in syncInProgress = false } }

        async let taskSync = syncTasks()
        async let docSync = syncDocuments()
        async let contactSync = syncContacts()

        let _ = try await (taskSync, docSync, contactSync)

        await MainActor.run { lastSyncDate = Date() }
    }

    private func syncTasks() async throws {
        let remoteTasks: [ResonanceTask] = try await request(endpoint: "tasks")
        // Merge logic would live here
    }

    private func syncDocuments() async throws {
        let remoteDocs: [ResonanceDocument] = try await request(endpoint: "documents")
    }

    private func syncContacts() async throws {
        let remoteContacts: [ResonanceContact] = try await request(endpoint: "contacts")
    }
}

// MARK: - Token Store

final class TokenStore {
    static let shared = TokenStore()
    private init() {}

    var accessToken: String? {
        // In production, read from Keychain
        UserDefaults.standard.string(forKey: "resonance_access_token")
    }

    func store(token: String) {
        // In production, write to Keychain with kSecAttrAccessible
        UserDefaults.standard.set(token, forKey: "resonance_access_token")
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: "resonance_access_token")
    }
}

// MARK: - Luminize Service (AI Prose Refinement)

final class LuminizeService: ObservableObject {
    static let shared = LuminizeService()

    @Published var isProcessing: Bool = false
    @Published var lastResult: LuminizeResult?

    enum Mode: String, Codable {
        case clarity, rhythm, depth, simplify
    }

    struct LuminizeResult {
        let originalText: String
        let refinedText: String
        let mode: Mode
        let changeCount: Int
        let timestamp: Date
    }

    /// Refine prose using the Resonance AI engine.
    func luminize(text: String, mode: Mode) async throws -> LuminizeResult {
        await MainActor.run { isProcessing = true }
        defer { Task { @MainActor in isProcessing = false } }

        // Build the prompt based on mode
        let systemPrompt = luminizeSystemPrompt(for: mode)

        let payload: [String: Any] = [
            "text": text,
            "mode": mode.rawValue,
            "system_prompt": systemPrompt,
            "max_tokens": 4096,
            "temperature": modeTemperature(mode)
        ]

        // In production, call the actual API
        let refined: String = try await ResonanceAPIClient.shared.request(
            endpoint: "luminize",
            method: .post,
            body: ["text": text, "mode": mode.rawValue]
        )

        let result = LuminizeResult(
            originalText: text,
            refinedText: refined,
            mode: mode,
            changeCount: computeChangeCount(original: text, refined: refined),
            timestamp: Date()
        )

        await MainActor.run { lastResult = result }
        return result
    }

    private func luminizeSystemPrompt(for mode: Mode) -> String {
        switch mode {
        case .clarity:
            return """
            You are a prose editor focused on clarity. Preserve the author's voice
            and intent. Remove unnecessary words. Sharpen ideas. Do not add new
            concepts — only refine what exists. Return only the refined text.
            """
        case .rhythm:
            return """
            You are a prose editor focused on rhythm and cadence. Vary sentence
            lengths for natural flow. Create musicality in the language. Preserve
            meaning exactly. Return only the refined text.
            """
        case .depth:
            return """
            You are a prose editor focused on depth. Enrich imagery and sensory
            detail. Deepen metaphors. Add resonance to key passages. Stay true
            to the author's intent. Return only the refined text.
            """
        case .simplify:
            return """
            You are a prose editor focused on simplification. Reduce complexity.
            Use shorter sentences. Replace jargon with plain language. Preserve
            all meaning. Return only the refined text.
            """
        }
    }

    private func modeTemperature(_ mode: Mode) -> Double {
        switch mode {
        case .clarity:  return 0.3
        case .rhythm:   return 0.5
        case .depth:    return 0.7
        case .simplify: return 0.2
        }
    }

    private func computeChangeCount(original: String, refined: String) -> Int {
        // Simple word-level diff count
        let originalWords = Set(original.split(separator: " "))
        let refinedWords = Set(refined.split(separator: " "))
        return originalWords.symmetricDifference(refinedWords).count
    }
}

// MARK: - Biometric Sync Service

final class BiometricSyncService: ObservableObject {
    static let shared = BiometricSyncService()

    @Published var latestHRV: Double?
    @Published var latestCortisol: Double?
    @Published var isMonitoring: Bool = false
    @Published var lastBiomarkerUpdate: Date?

    private var cancellables = Set<AnyCancellable>()

    /// Begin continuous biometric monitoring via HealthKit + wearable bridge.
    func startMonitoring() {
        isMonitoring = true

        // In production this would use HKObserverQuery and
        // HKAnchoredObjectQuery to stream real-time data.
        // Here we simulate periodic updates.

        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchLatestReadings()
            }
            .store(in: &cancellables)
    }

    func stopMonitoring() {
        isMonitoring = false
        cancellables.removeAll()
    }

    /// Fetch the most recent biometric readings.
    func fetchLatestReadings() {
        // HealthKit integration placeholder
        // HKHealthStore().execute(query) ...

        // Simulated values for development
        latestHRV = Double.random(in: 35...65)
        lastBiomarkerUpdate = Date()
    }

    /// Upload a biomarker snapshot to the provider's dashboard.
    func reportBiomarkerAnomaly(_ biomarker: BiomarkerRecord) async throws {
        try await ResonanceAPIClient.shared.request(
            endpoint: "biomarkers/anomaly",
            method: .post,
            body: biomarker
        ) as EmptyResponse
    }

    /// Request biomarker history for charting.
    func fetchHistory(
        biomarkerName: String,
        days: Int = 30
    ) async throws -> [BiomarkerRecord] {
        try await ResonanceAPIClient.shared.request(
            endpoint: "biomarkers/history?name=\(biomarkerName)&days=\(days)"
        )
    }
}

// MARK: - Notification Service (Calm Notifications)

final class CalmNotificationService: ObservableObject {
    static let shared = CalmNotificationService()

    @Published var preferences = NotificationPreference()
    @Published var pendingCount: Int = 0

    private var batchTimer: Timer?

    /// Request notification permission with a gentle explanation.
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    /// Schedule a calm notification that respects the user's current phase.
    func scheduleCalm(
        title: String,
        body: String,
        deliverAfter: TimeInterval = 0,
        respectPhase: Bool = true
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = preferences.useCalmTone ? .default : nil
        content.interruptionLevel = .passive  // Never intrusive

        var delay = deliverAfter

        // If respecting phase, batch notifications
        if respectPhase && preferences.batchIntervalMinutes > 0 {
            delay = max(delay, Double(preferences.batchIntervalMinutes * 60))
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        pendingCount += 1
    }

    /// Deliver phase transition notification with appropriate gentleness.
    func notifyPhaseTransition(to phase: DailyPhaseKind) {
        let messages: [DailyPhaseKind: (String, String)] = [
            .ascend:  ("Ascending", "Energy is building. What wants your attention today?"),
            .zenith:  ("Zenith approaching", "Peak capacity. Honor the depth available to you."),
            .descent: ("Gentle descent", "Begin releasing intensity. Lighter tasks welcome."),
            .rest:    ("Rest phase", "The day is complete. Allow restoration."),
        ]

        if let (title, body) = messages[phase] {
            scheduleCalm(title: title, body: body, deliverAfter: 0, respectPhase: false)
        }
    }

    /// Clear all pending notifications — useful when entering Deep Rest mode.
    func clearAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        pendingCount = 0
    }
}

// MARK: - Notification framework stub (for compilation outside Xcode)

import Foundation

#if !canImport(UserNotifications)
class UNUserNotificationCenter {
    static func current() -> UNUserNotificationCenter { .init() }
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool { true }
    func add(_ request: UNNotificationRequest) {}
    func removeAllPendingNotificationRequests() {}
}
struct UNAuthorizationOptions: OptionSet {
    let rawValue: Int
    static let alert = UNAuthorizationOptions(rawValue: 1)
    static let sound = UNAuthorizationOptions(rawValue: 2)
    static let badge = UNAuthorizationOptions(rawValue: 4)
}
class UNMutableNotificationContent {
    var title = ""
    var body = ""
    var sound: UNNotificationSound?
    var interruptionLevel: UNNotificationInterruptionLevel = .passive
}
enum UNNotificationInterruptionLevel { case passive, active, timeSensitive, critical }
class UNNotificationSound { static let `default` = UNNotificationSound() }
class UNTimeIntervalNotificationTrigger {
    init(timeInterval: TimeInterval, repeats: Bool) {}
}
class UNNotificationRequest {
    init(identifier: String, content: UNMutableNotificationContent, trigger: UNTimeIntervalNotificationTrigger) {}
}
#endif

// MARK: - Breathwork Service

final class BreathworkService: ObservableObject {
    static let shared = BreathworkService()

    @Published var activeSession: BreathworkSession?
    @Published var isCohortSynced: Bool = false

    private var timer: Timer?

    /// Start a solo breathwork session.
    func startSession(technique: BreathworkTechnique, durationSeconds: Int) {
        activeSession = BreathworkSession(
            technique: technique,
            durationSeconds: durationSeconds,
            startedAt: Date()
        )
    }

    /// Join a cohort breathwork session for group entrainment.
    func joinCohort(sessionId: String) async throws {
        // In production, connect via WebSocket for real-time sync
        let session: BreathworkSession = try await ResonanceAPIClient.shared.request(
            endpoint: "breathwork/cohort/\(sessionId)"
        )
        await MainActor.run {
            activeSession = session
            isCohortSynced = true
        }
    }

    /// Complete the current session and record metrics.
    func completeSession(postHRV: Double?) async throws {
        guard var session = activeSession else { return }
        session.completedAt = Date()
        session.postHRV = postHRV

        try await ResonanceAPIClient.shared.request(
            endpoint: "breathwork/sessions",
            method: .post,
            body: session
        ) as EmptyResponse

        await MainActor.run {
            activeSession = nil
            isCohortSynced = false
        }
    }
}

// MARK: - Helpers

struct EmptyResponse: Decodable {}

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ wrapped: any Encodable) {
        _encode = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - Resonance Errors

enum ResonanceError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case syncConflict(description: String)
    case notAuthenticated
    case biometricPermissionDenied
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let code, _):
            return "Request failed with status \(code)."
        case .syncConflict(let desc):
            return "Sync conflict: \(desc)"
        case .notAuthenticated:
            return "Please sign in to continue."
        case .biometricPermissionDenied:
            return "Health data access is needed for biometric features."
        case .networkUnavailable:
            return "You appear to be offline. Changes will sync when connectivity returns."
        }
    }
}

// MARK: - Cloud Sync Coordinator

final class CloudSyncCoordinator: ObservableObject {
    static let shared = CloudSyncCoordinator()

    @Published var syncState: SyncState = .idle
    @Published var lastSync: Date?
    @Published var pendingChanges: Int = 0

    enum SyncState {
        case idle, syncing, error(String)
    }

    private var backgroundTask: Task<Void, Never>?

    /// Begin periodic background sync.
    func startPeriodicSync(intervalSeconds: TimeInterval = 300) {
        backgroundTask?.cancel()
        backgroundTask = Task {
            while !Task.isCancelled {
                await performSync()
                try? await Task.sleep(nanoseconds: UInt64(intervalSeconds * 1_000_000_000))
            }
        }
    }

    func stopPeriodicSync() {
        backgroundTask?.cancel()
        backgroundTask = nil
    }

    @MainActor
    private func performSync() async {
        syncState = .syncing
        do {
            try await ResonanceAPIClient.shared.syncAll()
            syncState = .idle
            lastSync = Date()
            pendingChanges = 0
        } catch {
            syncState = .error(error.localizedDescription)
        }
    }

    /// Record a local change that needs to be synced.
    func markDirty() {
        pendingChanges += 1
    }
}
