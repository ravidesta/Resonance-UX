import Foundation

// MARK: - Repository Model

struct Repository: Identifiable, Equatable {
    let id: Int
    var name: String
    var url: String
    var description: String
    var files: [String]
    var uploadDate: Date
    var lastSync: Date
    var stars: Int
    var forks: Int
    var status: SyncStatus
    var secrets: [Secret]
    var notes: String
    var collaborators: [String]
    var designFiles: [String]

    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }
}

enum SyncStatus: String, CaseIterable {
    case synced = "synced"
    case pending = "pending"
    case error = "error"
    case backingUp = "backing-up"

    var displayName: String {
        switch self {
        case .synced: return "Synced"
        case .pending: return "Pending"
        case .error: return "Error"
        case .backingUp: return "Backing Up"
        }
    }
}

struct Secret: Identifiable, Equatable {
    let id = UUID()
    var key: String
    var value: String
}

struct BackupEvent: Identifiable {
    let id = UUID()
    var date: Date
    var description: String
    var hash: String
}

// MARK: - Language Detection

enum LanguageDetector {
    static let signatures: [String: [String]] = [
        "JavaScript": [".js", ".jsx", ".mjs", "package.json"],
        "TypeScript": [".ts", ".tsx", "tsconfig.json"],
        "Python": [".py", "requirements.txt", "setup.py", "Pipfile"],
        "Rust": [".rs", "Cargo.toml"],
        "Go": [".go", "go.mod"],
        "Java": [".java", "pom.xml", "build.gradle"],
        "C#": [".cs", ".csproj", ".sln"],
        "C++": [".cpp", ".hpp", ".cc"],
        "Ruby": [".rb", "Gemfile"],
        "PHP": [".php", "composer.json"],
        "Swift": [".swift", "Package.swift"],
        "Kotlin": [".kt", ".kts"],
        "Dart": [".dart", "pubspec.yaml"],
        "HTML": [".html", ".htm"],
        "CSS": [".css", ".scss", ".sass"],
        "Shell": [".sh", ".bash"],
        "Markdown": [".md"],
        "YAML": [".yml", ".yaml"],
    ]

    static func detect(files: [String]) -> [String] {
        var counts: [String: Int] = [:]
        for file in files {
            let lower = file.lowercased()
            for (lang, sigs) in signatures {
                if sigs.contains(where: { lower.hasSuffix($0.lowercased()) }) {
                    counts[lang, default: 0] += 1
                }
            }
        }
        return counts.sorted { $0.value > $1.value }.map(\.key)
    }
}

// MARK: - Callsign Generator

enum CallsignGenerator {
    static let adjectives = [
        "Silent", "Crimson", "Phantom", "Velvet", "Cobalt", "Ember",
        "Obsidian", "Ivory", "Sapphire", "Radiant", "Verdant", "Azure",
        "Ethereal", "Stellar", "Quantum", "Prismatic", "Orbital", "Nexus",
    ]

    static func generate(name: String) -> String {
        let hash = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let adj = adjectives[hash % adjectives.count]
        let formatted = name
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return "Operation: \(adj) \(formatted)"
    }
}

// MARK: - Bitstamp Hash

enum BitstampHash {
    static func generate(data: String) -> String {
        var h: UInt32 = 0x811c9dc5
        for scalar in data.unicodeScalars {
            h ^= UInt32(scalar.value)
            h = h &* 0x01000193
        }
        let hex = String(format: "%08x", h)
        let reversed = String(hex.reversed())
        return "0x\(hex)\(reversed)"
    }
}

// MARK: - Sample Data

extension Repository {
    static let samples: [Repository] = {
        let formatter = ISO8601DateFormatter()
        return [
            Repository(
                id: 1, name: "Resonance-UX",
                url: "https://github.com/ravidesta/Resonance-UX",
                description: "Calm productivity UX with breathing animations and intentional design",
                files: ["Resonance 1", "Resonance 3", "Daily Flow with Night Mode", "To Do",
                        "package.json", "index.js", "App.js", "style.css"],
                uploadDate: formatter.date(from: "2026-03-14T10:30:00Z") ?? Date(),
                lastSync: formatter.date(from: "2026-03-16T08:15:00Z") ?? Date(),
                stars: 12, forks: 3, status: .synced,
                secrets: [], notes: "Core UX framework for all Resonance products.",
                collaborators: ["elena@resonance.dev"],
                designFiles: ["mockups.fig", "color-palette.svg", "typography-guide.pdf"]
            ),
            Repository(
                id: 2, name: "kopia",
                url: "https://github.com/ravidesta/kopia",
                description: "Fast and secure backup tool with encryption and deduplication",
                files: ["main.go", "go.mod", "cli/app.go", "snapshot/policy/scheduling_policy.go",
                        "repo/blob/s3/s3_storage.go", "Makefile"],
                uploadDate: formatter.date(from: "2026-03-10T14:00:00Z") ?? Date(),
                lastSync: formatter.date(from: "2026-03-16T07:00:00Z") ?? Date(),
                stars: 5200, forks: 380, status: .synced,
                secrets: [], notes: "Backup engine powering the portal. Handles snapshots and policies.",
                collaborators: [],
                designFiles: []
            ),
            Repository(
                id: 3, name: "AppFlowy",
                url: "https://github.com/ravidesta/AppFlowy",
                description: "Open-source Notion alternative with databases, calendars, and kanban",
                files: ["pubspec.yaml", "lib/main.dart", "lib/workspace/database.dart",
                        "lib/plugins/calendar.dart", "rust-lib/Cargo.toml"],
                uploadDate: formatter.date(from: "2026-03-12T09:00:00Z") ?? Date(),
                lastSync: formatter.date(from: "2026-03-15T22:30:00Z") ?? Date(),
                stars: 48000, forks: 3100, status: .pending,
                secrets: [], notes: "Database and calendar engine for portfolio management.",
                collaborators: ["dev@appflowy.io"],
                designFiles: ["ui-components.fig"]
            ),
            Repository(
                id: 4, name: "design",
                url: "https://github.com/ravidesta/design",
                description: "Luminous OS design system — bioluminescent surfaces and chromatic intelligence",
                files: ["book", "README.md", "assets/chromatic-orb.svg", "assets/particles.json"],
                uploadDate: formatter.date(from: "2026-03-13T16:45:00Z") ?? Date(),
                lastSync: formatter.date(from: "2026-03-16T06:00:00Z") ?? Date(),
                stars: 8, forks: 1, status: .synced,
                secrets: [], notes: "Living design system with breathing surfaces and particle fields.",
                collaborators: [],
                designFiles: ["book", "chromatic-orb.svg", "field-coherence-spec.pdf"]
            ),
        ]
    }()
}
