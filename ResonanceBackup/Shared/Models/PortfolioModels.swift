// PortfolioModels.swift
// Resonance UX GitHub Backup — Core Data Models
// Each repository = one Portfolio (slide/cell in gallery)

import SwiftUI
import Foundation

// MARK: - Portfolio (One per Repository)

struct Portfolio: Identifiable, Codable {
    let id: UUID
    var callsign: String                    // "Operation: <repo-name>"
    var repositoryName: String
    var repositoryURL: String               // Original GitHub URL
    var repositoryDescription: String
    var primaryLanguage: String             // Detected language
    var languages: [LanguageBreakdown]      // All languages used
    var dateOfUpload: Date
    var lastSyncDate: Date
    var accentColorIndex: Int               // Index into ResonanceColors.portfolioAccents

    // Database Properties
    var properties: [PortfolioProperty]
    var secrets: [SecretEntry]
    var fileSlots: [FileSlot]
    var collaborators: [Collaborator]
    var notes: String                       // Landing page / notes content
    var tags: [String]

    // Backup State
    var backupStatus: BackupStatus
    var kopiaSnapshotID: String?
    var totalSize: Int64                    // bytes
    var fileCount: Int
    var commitCount: Int
    var branchCount: Int

    // Logo & Identity
    var logoEmoji: String                   // Fallback emoji logo
    var customLogoData: Data?               // Custom uploaded logo

    // Changelog
    var changelog: [ChangeLogEntry]

    // Bitstamp
    var bitstampRecords: [BitstampRecord]

    var displayCallsign: String {
        "OPERATION : \(repositoryName.uppercased())"
    }

    var accentColor: Color {
        ResonanceColors.accentFor(index: accentColorIndex)
    }

    static func fromGitHubRepo(name: String, url: String, desc: String, lang: String, index: Int) -> Portfolio {
        Portfolio(
            id: UUID(),
            callsign: "Operation: \(name)",
            repositoryName: name,
            repositoryURL: url,
            repositoryDescription: desc,
            primaryLanguage: lang,
            languages: [],
            dateOfUpload: Date(),
            lastSyncDate: Date(),
            accentColorIndex: index,
            properties: Self.defaultProperties(for: lang),
            secrets: [],
            fileSlots: Self.defaultFileSlots(),
            collaborators: [],
            notes: "# \(name)\n\n\(desc)\n\n---\n\nUploaded from GitHub on \(Date().formatted())",
            tags: [lang.lowercased()],
            backupStatus: .queued,
            kopiaSnapshotID: nil,
            totalSize: 0,
            fileCount: 0,
            commitCount: 0,
            branchCount: 0,
            logoEmoji: Self.emojiForLanguage(lang),
            customLogoData: nil,
            changelog: [],
            bitstampRecords: []
        )
    }

    static func defaultProperties(for language: String) -> [PortfolioProperty] {
        [
            PortfolioProperty(key: "Language", value: language, kind: .text),
            PortfolioProperty(key: "License", value: "Unknown", kind: .text),
            PortfolioProperty(key: "Visibility", value: "Private", kind: .select),
            PortfolioProperty(key: "Stars", value: "0", kind: .number),
            PortfolioProperty(key: "Forks", value: "0", kind: .number),
            PortfolioProperty(key: "Last Commit", value: Date().formatted(), kind: .date),
            PortfolioProperty(key: "Health", value: "Good", kind: .select),
            PortfolioProperty(key: "Backup Frequency", value: "Daily", kind: .select),
            PortfolioProperty(key: "Storage Backend", value: "Local", kind: .select),
        ]
    }

    static func defaultFileSlots() -> [FileSlot] {
        [
            FileSlot(name: "Design Files", description: "UI/UX mockups, Figma exports, Sketch files", files: []),
            FileSlot(name: "Documentation", description: "README, API docs, guides", files: []),
            FileSlot(name: "Assets", description: "Icons, images, fonts, media", files: []),
            FileSlot(name: "Configuration", description: "CI/CD configs, env templates, Docker files", files: []),
            FileSlot(name: "Test Reports", description: "Coverage reports, test results", files: []),
            FileSlot(name: "Release Artifacts", description: "Build outputs, binaries, packages", files: []),
        ]
    }

    static func emojiForLanguage(_ lang: String) -> String {
        switch lang.lowercased() {
        case "swift": return "🦅"
        case "python": return "🐍"
        case "javascript", "typescript": return "⚡"
        case "rust": return "🦀"
        case "go": return "🐹"
        case "java", "kotlin": return "☕"
        case "ruby": return "💎"
        case "c", "c++", "cpp": return "⚙️"
        case "dart", "flutter": return "🎯"
        case "html", "css": return "🌐"
        case "shell", "bash": return "🐚"
        default: return "📦"
        }
    }
}

// MARK: - Portfolio Property (Database Field)

struct PortfolioProperty: Identifiable, Codable {
    let id: UUID
    var key: String
    var value: String
    var kind: PropertyKind

    init(key: String, value: String, kind: PropertyKind) {
        self.id = UUID()
        self.key = key
        self.value = value
        self.kind = kind
    }

    enum PropertyKind: String, Codable {
        case text, number, date, select, multiSelect, url, email, checkbox
    }
}

// MARK: - Secret Entry

struct SecretEntry: Identifiable, Codable {
    let id: UUID
    var name: String
    var value: String          // Encrypted at rest
    var createdAt: Date
    var lastUsed: Date?

    init(name: String, value: String) {
        self.id = UUID()
        self.name = name
        self.value = value
        self.createdAt = Date()
        self.lastUsed = nil
    }
}

// MARK: - File Slot

struct FileSlot: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var files: [AttachedFile]

    init(name: String, description: String, files: [AttachedFile]) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.files = files
    }
}

struct AttachedFile: Identifiable, Codable {
    let id: UUID
    var fileName: String
    var fileSize: Int64
    var mimeType: String
    var uploadDate: Date
    var localPath: String?

    init(fileName: String, fileSize: Int64, mimeType: String) {
        self.id = UUID()
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.uploadDate = Date()
    }
}

// MARK: - Collaborator

struct Collaborator: Identifiable, Codable {
    let id: UUID
    var username: String
    var email: String?
    var role: CollaboratorRole
    var invitedAt: Date
    var acceptedAt: Date?
    var avatarURL: String?

    enum CollaboratorRole: String, Codable, CaseIterable {
        case owner = "Owner"
        case admin = "Admin"
        case contributor = "Contributor"
        case viewer = "Viewer"
    }

    init(username: String, email: String? = nil, role: CollaboratorRole = .viewer) {
        self.id = UUID()
        self.username = username
        self.email = email
        self.role = role
        self.invitedAt = Date()
    }
}

// MARK: - Changelog Entry (Calendar Ledger)

struct ChangeLogEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var action: ChangeAction
    var description: String
    var commitHash: String?
    var bitstampHash: String?
    var filesChanged: Int
    var insertions: Int
    var deletions: Int

    enum ChangeAction: String, Codable, CaseIterable {
        case upload = "Upload"
        case sync = "Sync"
        case backup = "Backup"
        case restore = "Restore"
        case propertyChange = "Property Change"
        case secretAdded = "Secret Added"
        case collaboratorInvited = "Collaborator Invited"
        case fileAttached = "File Attached"
        case noteUpdated = "Note Updated"
    }

    init(action: ChangeAction, description: String, commitHash: String? = nil) {
        self.id = UUID()
        self.date = Date()
        self.action = action
        self.description = description
        self.commitHash = commitHash
        self.filesChanged = 0
        self.insertions = 0
        self.deletions = 0
    }
}

// MARK: - Bitstamp Record

struct BitstampRecord: Identifiable, Codable {
    let id: UUID
    var timestamp: Date
    var projectHash: String          // SHA-256 of project state
    var bitstampHash: String         // Hash from openbitstamp.org
    var bitcoinBlockHeight: Int?
    var source: String               // "openbitstamp.org", etc.
    var verificationURL: String?

    init(projectHash: String, bitstampHash: String, source: String) {
        self.id = UUID()
        self.timestamp = Date()
        self.projectHash = projectHash
        self.bitstampHash = bitstampHash
        self.source = source
    }
}

// MARK: - Language Breakdown

struct LanguageBreakdown: Identifiable, Codable {
    let id: UUID
    var language: String
    var percentage: Double
    var lineCount: Int
    var fileCount: Int

    init(language: String, percentage: Double, lineCount: Int, fileCount: Int) {
        self.id = UUID()
        self.language = language
        self.percentage = percentage
        self.lineCount = lineCount
        self.fileCount = fileCount
    }
}
