// BackupViewModel.swift
// Resonance UX GitHub Backup — Main ViewModel
// Orchestrates all backup, portfolio, marketplace, and calendar operations

import SwiftUI
import Combine

// MARK: - Device Type

enum ResonanceDevice: String, CaseIterable, Identifiable {
    case iPhone = "iPhone"
    case iPad = "iPad"
    case mac = "Mac"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .iPhone: return "iphone"
        case .iPad: return "ipad"
        case .mac: return "desktopcomputer"
        }
    }

    var defaultBackupPath: String {
        switch self {
        case .iPhone:
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                .map { $0 + "/ResonanceBackups" } ?? "~/ResonanceBackups"
        case .iPad:
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
                .map { $0 + "/ResonanceBackups" } ?? "~/ResonanceBackups"
        case .mac:
            return "~/ResonanceBackups"
        }
    }

    static var current: ResonanceDevice {
        #if os(macOS)
        return .mac
        #else
        return UIDevice.current.userInterfaceIdiom == .pad ? .iPad : .iPhone
        #endif
    }
}

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
    @Published var backupPath: String = ResonanceDevice.current.defaultBackupPath
    @Published var cloneProgress: String = ""
    @Published var azureAccount: String = ""
    @Published var azureContainer: String = ""
    @Published var azureKey: String = ""
    @Published var uploadToAzure: Bool = false
    @Published var azureProgress: String = ""

    // Amazon S3
    @Published var uploadToS3: Bool = false
    @Published var s3Bucket: String = ""
    @Published var s3Region: String = "us-east-1"
    @Published var s3AccessKey: String = ""
    @Published var s3SecretKey: String = ""
    @Published var s3Prefix: String = ""
    @Published var s3Progress: String = ""

    // Device
    @Published var currentDevice: ResonanceDevice = .current
    @Published var deviceLabel: String = ResonanceDevice.current.rawValue

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

    // MARK: - Resolved backup path

    var resolvedBackupPath: String {
        NSString(string: backupPath).expandingTildeInPath
    }

    // MARK: - Clone All Repos

    /// Fetches every repo from GitHub and mirror-clones them into backupPath.
    func cloneAllRepos() async {
        guard !githubToken.isEmpty else {
            await MainActor.run { cloneProgress = "No GitHub token — add it above first." }
            return
        }

        await MainActor.run {
            isLoading = true
            cloneProgress = "Fetching repo list from GitHub..."
        }

        let repos = await backupService.fetchAllRepos(token: githubToken)

        guard !repos.isEmpty else {
            await MainActor.run {
                isLoading = false
                cloneProgress = "No repos found. Check your token permissions."
            }
            return
        }

        let dest = resolvedBackupPath
        try? FileManager.default.createDirectory(atPath: dest, withIntermediateDirectories: true)

        await MainActor.run {
            cloneProgress = "Found \(repos.count) repos. Cloning..."
            // Build portfolio entries for each
            portfolios = repos.enumerated().map { (i, repo) in
                Portfolio.fromGitHubRepo(
                    name: repo.name,
                    url: repo.cloneUrl,
                    desc: repo.description ?? "",
                    lang: repo.language ?? "Unknown",
                    index: i
                )
            }
        }

        for (i, portfolio) in portfolios.enumerated() {
            let repoDir = "\(dest)/\(portfolio.repositoryName).git"

            await MainActor.run {
                cloneProgress = "[\(i + 1)/\(portfolios.count)] \(portfolio.repositoryName)..."
                portfolios[i].backupStatus = .syncing
            }

            if backupService.repositoryExists(at: repoDir) {
                let result = await backupService.pullLatest(repoPath: repoDir, token: githubToken)
                await MainActor.run {
                    portfolios[i].backupStatus = result.isSuccess ? .synced : .error
                    portfolios[i].lastSyncDate = Date()
                    logChange(
                        portfolioID: portfolio.id,
                        action: .sync,
                        description: result.isSuccess ? "Pulled latest" : "Pull failed: \(result.output)"
                    )
                }
            } else {
                let result = await backupService.cloneRepository(
                    url: portfolio.repositoryURL, destination: repoDir, token: githubToken
                )
                await MainActor.run {
                    portfolios[i].backupStatus = result.isSuccess ? .synced : .error
                    portfolios[i].lastSyncDate = Date()
                    logChange(
                        portfolioID: portfolio.id,
                        action: .upload,
                        description: result.isSuccess ? "Cloned from GitHub" : "Clone failed: \(result.output)"
                    )
                }
            }
        }

        // Upload to Azure if enabled
        if uploadToAzure && !azureAccount.isEmpty && !azureContainer.isEmpty && !azureKey.isEmpty {
            await uploadAllToAzure()
        }

        // Upload to Amazon S3 if enabled
        if uploadToS3 && !s3Bucket.isEmpty && !s3AccessKey.isEmpty && !s3SecretKey.isEmpty {
            await uploadAllToS3()
        }

        await MainActor.run {
            isLoading = false
            let succeeded = portfolios.filter { $0.backupStatus == .synced }.count
            cloneProgress = "Done — \(succeeded)/\(portfolios.count) repos cloned to \(backupPath)"
        }
    }

    // MARK: - Azure Upload

    func uploadAllToAzure() async {
        let dest = resolvedBackupPath

        for (i, portfolio) in portfolios.enumerated() {
            let repoDir = "\(dest)/\(portfolio.repositoryName).git"
            guard portfolio.backupStatus == .synced else { continue }

            await MainActor.run {
                azureProgress = "Uploading [\(i + 1)/\(portfolios.count)] \(portfolio.repositoryName) to Azure..."
            }

            let result = await backupService.uploadToAzureBlob(
                repoPath: repoDir,
                repoName: portfolio.repositoryName,
                account: azureAccount,
                container: azureContainer,
                key: azureKey
            )

            await MainActor.run {
                logChange(
                    portfolioID: portfolio.id,
                    action: .backup,
                    description: result.isSuccess
                        ? "Uploaded to Azure Blob (\(azureContainer))"
                        : "Azure upload failed: \(result.output)"
                )
            }
        }

        let uploaded = portfolios.filter { $0.backupStatus == .synced }.count
        await MainActor.run {
            azureProgress = "Azure upload done — \(uploaded) repos → \(azureAccount)/\(azureContainer)"
        }
    }

    // MARK: - Amazon S3 Upload

    func uploadAllToS3() async {
        let dest = resolvedBackupPath
        // Include device name in S3 prefix so each device gets its own garden
        let devicePrefix: String
        if s3Prefix.isEmpty {
            devicePrefix = deviceLabel
        } else {
            devicePrefix = "\(s3Prefix.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/\(deviceLabel)"
        }

        for (i, portfolio) in portfolios.enumerated() {
            let repoDir = "\(dest)/\(portfolio.repositoryName).git"
            guard portfolio.backupStatus == .synced else { continue }

            await MainActor.run {
                s3Progress = "Syncing [\(i + 1)/\(portfolios.count)] \(portfolio.repositoryName) → S3..."
            }

            let result = await backupService.uploadToS3(
                repoPath: repoDir,
                repoName: portfolio.repositoryName,
                bucket: s3Bucket,
                region: s3Region,
                accessKey: s3AccessKey,
                secretKey: s3SecretKey,
                prefix: devicePrefix
            )

            await MainActor.run {
                logChange(
                    portfolioID: portfolio.id,
                    action: .backup,
                    description: result.isSuccess
                        ? "Synced to S3 (\(s3Bucket)/\(devicePrefix)/\(portfolio.repositoryName))"
                        : "S3 upload failed: \(result.output)"
                )
            }
        }

        let uploaded = portfolios.filter { $0.backupStatus == .synced }.count
        await MainActor.run {
            s3Progress = "Amazon sync done — \(uploaded) repos → s3://\(s3Bucket)/\(devicePrefix)/"
        }
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

        let repoPath = "\(resolvedBackupPath)/\(portfolio.repositoryName).git"

        try? FileManager.default.createDirectory(
            atPath: resolvedBackupPath, withIntermediateDirectories: true
        )

        if backupService.repositoryExists(at: repoPath) {
            let pullResult = await backupService.pullLatest(repoPath: repoPath, token: githubToken)
            if !pullResult.isSuccess {
                await MainActor.run {
                    portfolios[index].backupStatus = .error
                    logChange(portfolioID: portfolio.id, action: .sync,
                              description: "Pull failed: \(pullResult.output)")
                }
                return
            }
        } else {
            let cloneResult = await backupService.cloneRepository(
                url: portfolio.repositoryURL, destination: repoPath, token: githubToken
            )
            if !cloneResult.isSuccess {
                await MainActor.run {
                    portfolios[index].backupStatus = .error
                    logChange(portfolioID: portfolio.id, action: .upload,
                              description: "Clone failed: \(cloneResult.output)")
                }
                return
            }
        }

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
                description: snapshotResult.isSuccess ? "Synced and backed up" : "Snapshot failed: \(snapshotResult.output)",
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
}
