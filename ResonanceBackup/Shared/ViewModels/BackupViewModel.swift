// BackupViewModel.swift
// Resonance UX GitHub Backup — Main ViewModel
// Orchestrates all backup, portfolio, marketplace, and calendar operations

import SwiftUI
import Combine

class BackupViewModel: ObservableObject {
    // MARK: - Published State
    @Published var portfolios: [Portfolio] = []
    @Published var marketplaceListings: [MarketplaceListing] = []
    @Published var transactions: [TransactionRecord] = []
    @Published var kopiaConfig: KopiaConfig = .intuitiveDefaults
    @Published var serverConfig: ServerConfig = .defaults
    @Published var isLoading = false
    @Published var selectedNavigation: NavigationDestination = .gallery
    @Published var globalCommandOutput: String = ""
    @Published var githubToken: String = ""

    // Services
    let backupService = GitHubBackupService()

    enum NavigationDestination: String, CaseIterable {
        case gallery = "Gallery"
        case marketplace = "Marketplace"
        case calendar = "Calendar"
        case terminal = "Terminal"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .gallery: return "square.grid.2x2"
            case .marketplace: return "storefront"
            case .calendar: return "calendar"
            case .terminal: return "terminal"
            case .settings: return "gearshape"
            }
        }
    }

    // MARK: - Initialization

    init() {
        loadSampleData()
    }

    // MARK: - Portfolio Operations

    func addRepository(url: String, name: String, description: String, language: String) {
        let portfolio = Portfolio.fromGitHubRepo(
            name: name, url: url, desc: description,
            lang: language, index: portfolios.count
        )
        portfolios.append(portfolio)
        logChange(portfolioID: portfolio.id, action: .upload, description: "Repository added from \(url)")
    }

    func syncPortfolio(_ portfolio: Portfolio) async {
        guard let index = portfolios.firstIndex(where: { $0.id == portfolio.id }) else { return }

        await MainActor.run { portfolios[index].backupStatus = .syncing }

        // Pull latest
        let repoPath = "\(kopiaConfig.repositoryPath)/\(portfolio.repositoryName)"
        _ = await backupService.pullLatest(repoPath: repoPath)

        // Create Kopia snapshot
        let snapshotResult = await backupService.createSnapshot(
            path: repoPath,
            tags: ["portfolio": portfolio.id.uuidString, "repo": portfolio.repositoryName]
        )

        // Generate bitstamp
        let projectHash = await backupService.generateProjectHash(repoPath: repoPath)
        let bitstamp = await backupService.fetchBitstampHash(projectHash: projectHash)

        await MainActor.run {
            portfolios[index].backupStatus = snapshotResult.isSuccess ? .synced : .error
            portfolios[index].lastSyncDate = Date()
            portfolios[index].bitstampRecords.append(bitstamp)

            logChange(
                portfolioID: portfolio.id,
                action: .sync,
                description: "Synced and backed up",
                commitHash: projectHash,
                bitstampHash: bitstamp.bitstampHash
            )
        }
    }

    func backupAll() async {
        for portfolio in portfolios {
            await syncPortfolio(portfolio)
        }
    }

    // MARK: - Changelog

    func logChange(portfolioID: UUID, action: ChangeLogEntry.ChangeAction,
                   description: String, commitHash: String? = nil, bitstampHash: String? = nil) {
        guard let index = portfolios.firstIndex(where: { $0.id == portfolioID }) else { return }

        var entry = ChangeLogEntry(action: action, description: description, commitHash: commitHash)
        entry.bitstampHash = bitstampHash
        portfolios[index].changelog.insert(entry, at: 0)
    }

    // MARK: - Marketplace

    func createListing(portfolioID: UUID, type: MarketplaceListing.ListingType) {
        guard let portfolio = portfolios.first(where: { $0.id == portfolioID }) else { return }

        let listing = MarketplaceListing(
            portfolioID: portfolioID,
            seller: "resonance-user",
            name: portfolio.repositoryName,
            description: portfolio.repositoryDescription,
            language: portfolio.primaryLanguage,
            type: type
        )
        marketplaceListings.append(listing)

        logChange(portfolioID: portfolioID, action: .propertyChange,
                  description: "Listed on marketplace as \(type.rawValue)")
    }

    // MARK: - Collaborators

    func inviteCollaborator(portfolioID: UUID, username: String, email: String?,
                           role: Collaborator.CollaboratorRole) {
        guard let index = portfolios.firstIndex(where: { $0.id == portfolioID }) else { return }

        let collab = Collaborator(username: username, email: email, role: role)
        portfolios[index].collaborators.append(collab)

        logChange(portfolioID: portfolioID, action: .collaboratorInvited,
                  description: "Invited \(username) as \(role.rawValue)")
    }

    // MARK: - Secrets

    func addSecret(portfolioID: UUID, name: String, value: String) {
        guard let index = portfolios.firstIndex(where: { $0.id == portfolioID }) else { return }

        let secret = SecretEntry(name: name, value: value)
        portfolios[index].secrets.append(secret)

        logChange(portfolioID: portfolioID, action: .secretAdded,
                  description: "Secret '\(name)' added")
    }

    // MARK: - Sample Data

    func loadSampleData() {
        let repos: [(String, String, String, String)] = [
            ("Resonance-UX", "https://github.com/ravidesta/Resonance-UX",
             "Calm, intentional productivity design system with bioluminescent aesthetics", "JavaScript"),
            ("AppFlowy", "https://github.com/ravidesta/AppFlowy",
             "Open-source Notion alternative. Flutter + Rust, privacy-first, collaborative workspace", "Dart"),
            ("kopia", "https://github.com/ravidesta/kopia",
             "Fast, secure backup tool with encryption, deduplication, and compression", "Go"),
            ("design", "https://github.com/ravidesta/design",
             "Luminous OS design system — bioluminescent portfolio architecture", "Markdown"),
        ]

        for (i, repo) in repos.enumerated() {
            var portfolio = Portfolio.fromGitHubRepo(
                name: repo.0, url: repo.1, desc: repo.2, lang: repo.3, index: i
            )

            // Add sample data
            portfolio.fileCount = [23, 1034, 1034, 1][i]
            portfolio.totalSize = [82400, 15_200_000, 9_800_000, 7646][i]
            portfolio.commitCount = [12, 4521, 3892, 1][i]
            portfolio.branchCount = [2, 45, 28, 2][i]
            portfolio.backupStatus = [.synced, .synced, .synced, .synced][i]

            portfolio.languages = [
                LanguageBreakdown(language: repo.3, percentage: 65, lineCount: 0, fileCount: 10),
                LanguageBreakdown(language: "CSS", percentage: 20, lineCount: 0, fileCount: 5),
                LanguageBreakdown(language: "JSON", percentage: 15, lineCount: 0, fileCount: 3),
            ]

            // Sample changelog
            portfolio.changelog = [
                ChangeLogEntry(action: .upload, description: "Initial backup from GitHub"),
                ChangeLogEntry(action: .sync, description: "Pulled latest changes"),
                ChangeLogEntry(action: .backup, description: "Kopia snapshot created"),
            ]

            // Sample bitstamp
            portfolio.bitstampRecords = [
                BitstampRecord(
                    projectHash: "a1b2c3d4e5f6789012345678",
                    bitstampHash: "OBS-\(UUID().uuidString.prefix(16))",
                    source: "openbitstamp.org"
                )
            ]

            portfolios.append(portfolio)
        }
    }
}
