// KopiaConfig.swift
// Resonance UX GitHub Backup — Kopia Backup Configuration
// Intuitive defaults for AppFlowy-integrated backup settings

import Foundation

// MARK: - Kopia Configuration (Intuitive Defaults)

struct KopiaConfig: Codable {
    var repositoryPath: String
    var storageBackend: StorageBackend
    var encryptionPassword: String
    var scheduling: SchedulingConfig
    var retention: RetentionConfig
    var compression: CompressionConfig
    var upload: UploadConfig

    static var intuitiveDefaults: KopiaConfig {
        KopiaConfig(
            repositoryPath: "~/ResonanceBackups",
            storageBackend: .local(path: "~/ResonanceBackups/kopia-repo"),
            encryptionPassword: "",
            scheduling: .intuitiveDefaults,
            retention: .intuitiveDefaults,
            compression: .intuitiveDefaults,
            upload: .intuitiveDefaults
        )
    }
}

// MARK: - Storage Backend

enum StorageBackend: Codable {
    case local(path: String)
    case s3(bucket: String, endpoint: String, accessKey: String, secretKey: String)
    case sftp(host: String, port: Int, username: String, keyPath: String)
    case webdav(url: String, username: String, password: String)
    case b2(bucket: String, accountID: String, appKey: String)
    case gcs(bucket: String, credentialsPath: String)
    case azure(container: String, storageAccount: String, sasToken: String)

    var displayName: String {
        switch self {
        case .local: return "Local Filesystem"
        case .s3: return "S3 / Compatible"
        case .sftp: return "SFTP"
        case .webdav: return "WebDAV"
        case .b2: return "Backblaze B2"
        case .gcs: return "Google Cloud Storage"
        case .azure: return "Azure Blob Storage"
        }
    }

    var iconName: String {
        switch self {
        case .local: return "internaldrive"
        case .s3: return "cloud"
        case .sftp: return "server.rack"
        case .webdav: return "globe"
        case .b2: return "flame"
        case .gcs: return "cloud.fill"
        case .azure: return "cloud.bolt"
        }
    }
}

// MARK: - Scheduling

struct SchedulingConfig: Codable {
    var intervalHours: Int           // Backup every N hours
    var timesOfDay: [String]         // Specific times: ["02:00", "14:00"]
    var cronExpression: String?      // Optional cron
    var runMissed: Bool              // Run if a schedule was missed

    static var intuitiveDefaults: SchedulingConfig {
        SchedulingConfig(
            intervalHours: 6,
            timesOfDay: ["02:00", "14:00"],
            cronExpression: nil,
            runMissed: true
        )
    }
}

// MARK: - Retention

struct RetentionConfig: Codable {
    var keepLatest: Int
    var keepHourly: Int
    var keepDaily: Int
    var keepWeekly: Int
    var keepMonthly: Int
    var keepAnnual: Int

    static var intuitiveDefaults: RetentionConfig {
        RetentionConfig(
            keepLatest: 10,
            keepHourly: 24,
            keepDaily: 30,
            keepWeekly: 8,
            keepMonthly: 12,
            keepAnnual: 3
        )
    }
}

// MARK: - Compression

struct CompressionConfig: Codable {
    var algorithm: String            // "zstd", "gzip", "none"
    var compressExtensions: [String] // Only compress these
    var neverCompress: [String]      // Skip these

    static var intuitiveDefaults: CompressionConfig {
        CompressionConfig(
            algorithm: "zstd",
            compressExtensions: [".swift", ".dart", ".go", ".rs", ".py", ".js", ".ts",
                                 ".json", ".yaml", ".yml", ".toml", ".xml", ".html",
                                 ".css", ".md", ".txt", ".csv", ".sql"],
            neverCompress: [".zip", ".gz", ".tar", ".png", ".jpg", ".jpeg",
                           ".mp4", ".mov", ".avi", ".pdf", ".woff2"]
        )
    }
}

// MARK: - Upload

struct UploadConfig: Codable {
    var maxParallelSnapshots: Int
    var maxParallelFileReads: Int
    var ignorePatterns: [String]

    static var intuitiveDefaults: UploadConfig {
        UploadConfig(
            maxParallelSnapshots: 1,
            maxParallelFileReads: 4,
            ignorePatterns: [
                ".git", "node_modules", ".build", "build", "DerivedData",
                "__pycache__", ".pytest_cache", "target", ".gradle",
                "Pods", ".cocoapods", "vendor/bundle"
            ]
        )
    }
}

// MARK: - Server Configuration

struct ServerConfig: Codable {
    var host: String
    var port: Int
    var useTLS: Bool
    var username: String
    var password: String
    var apiEndpoint: String

    static var defaults: ServerConfig {
        ServerConfig(
            host: "localhost",
            port: 51515,
            useTLS: false,
            username: "resonance",
            password: "",
            apiEndpoint: "/api/v1"
        )
    }

    var baseURL: String {
        let scheme = useTLS ? "https" : "http"
        return "\(scheme)://\(host):\(port)\(apiEndpoint)"
    }
}

// MARK: - Server Command (File Menu Actions)

struct ServerCommand: Identifiable, Codable {
    let id: UUID
    var name: String
    var command: String
    var description: String
    var category: CommandCategory
    var icon: String
    var requiresConfirmation: Bool
    var isDestructive: Bool

    enum CommandCategory: String, Codable, CaseIterable {
        case backup = "Backup"
        case restore = "Restore"
        case maintenance = "Maintenance"
        case server = "Server"
        case repository = "Repository"
        case snapshot = "Snapshot"
        case policy = "Policy"
        case system = "System"
    }

    static var defaultCommands: [ServerCommand] {
        [
            // Backup
            ServerCommand(id: UUID(), name: "Backup Now", command: "kopia snapshot create --all",
                         description: "Create snapshot of all configured sources",
                         category: .backup, icon: "arrow.up.doc", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Backup Selected", command: "kopia snapshot create",
                         description: "Create snapshot of selected portfolio",
                         category: .backup, icon: "arrow.up.doc.on.clipboard", requiresConfirmation: false, isDestructive: false),

            // Restore
            ServerCommand(id: UUID(), name: "Restore Latest", command: "kopia snapshot restore",
                         description: "Restore the most recent snapshot",
                         category: .restore, icon: "arrow.down.doc", requiresConfirmation: true, isDestructive: false),
            ServerCommand(id: UUID(), name: "Mount Snapshot", command: "kopia mount",
                         description: "Mount a snapshot as a filesystem",
                         category: .restore, icon: "externaldrive.badge.plus", requiresConfirmation: false, isDestructive: false),

            // Maintenance
            ServerCommand(id: UUID(), name: "Run Maintenance", command: "kopia maintenance run",
                         description: "Run repository maintenance (GC, compaction)",
                         category: .maintenance, icon: "wrench.and.screwdriver", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Verify Integrity", command: "kopia snapshot verify",
                         description: "Verify snapshot data integrity",
                         category: .maintenance, icon: "checkmark.shield", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Clear Cache", command: "kopia cache clear",
                         description: "Clear local cache",
                         category: .maintenance, icon: "trash.circle", requiresConfirmation: true, isDestructive: false),

            // Server
            ServerCommand(id: UUID(), name: "Start Server", command: "kopia server start",
                         description: "Start Kopia server for remote access",
                         category: .server, icon: "play.circle", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Stop Server", command: "kopia server shutdown",
                         description: "Gracefully stop the Kopia server",
                         category: .server, icon: "stop.circle", requiresConfirmation: true, isDestructive: false),
            ServerCommand(id: UUID(), name: "Server Status", command: "kopia server status",
                         description: "Check Kopia server status",
                         category: .server, icon: "antenna.radiowaves.left.and.right", requiresConfirmation: false, isDestructive: false),

            // Repository
            ServerCommand(id: UUID(), name: "Repo Status", command: "kopia repository status",
                         description: "Show repository connection info",
                         category: .repository, icon: "info.circle", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Sync Repository", command: "kopia repository sync-to",
                         description: "Sync repository to another location",
                         category: .repository, icon: "arrow.triangle.2.circlepath", requiresConfirmation: true, isDestructive: false),

            // Snapshot
            ServerCommand(id: UUID(), name: "List Snapshots", command: "kopia snapshot list",
                         description: "List all snapshots",
                         category: .snapshot, icon: "list.bullet.rectangle", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Compare Snapshots", command: "kopia diff",
                         description: "Compare two snapshots",
                         category: .snapshot, icon: "arrow.left.arrow.right", requiresConfirmation: false, isDestructive: false),

            // Policy
            ServerCommand(id: UUID(), name: "Show Policies", command: "kopia policy show --global",
                         description: "Display current backup policies",
                         category: .policy, icon: "doc.text.magnifyingglass", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Set Retention", command: "kopia policy set",
                         description: "Configure retention policy",
                         category: .policy, icon: "clock.arrow.circlepath", requiresConfirmation: false, isDestructive: false),

            // System (GitHub integration)
            ServerCommand(id: UUID(), name: "Clone Repository", command: "git clone",
                         description: "Clone a GitHub repository for backup",
                         category: .system, icon: "arrow.down.circle", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Pull Updates", command: "git pull --all",
                         description: "Pull latest changes from all remotes",
                         category: .system, icon: "arrow.down.to.line", requiresConfirmation: false, isDestructive: false),
            ServerCommand(id: UUID(), name: "Analyze Project", command: "resonance-analyze",
                         description: "Run language detection and project analysis",
                         category: .system, icon: "wand.and.stars", requiresConfirmation: false, isDestructive: false),
        ]
    }
}
