// SettingsView.swift
// Resonance UX GitHub Backup — Intuitive Settings
// Kopia configuration integrated with AppFlowy-style UX

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: BackupViewModel
    @State private var selectedSection: SettingsSection = .general

    enum SettingsSection: String, CaseIterable {
        case general = "General"
        case storage = "Storage"
        case scheduling = "Scheduling"
        case retention = "Retention"
        case compression = "Compression"
        case server = "Server"
        case github = "GitHub"
        case security = "Security"
    }

    var body: some View {
        HSplitView {
            // Sidebar
            VStack(alignment: .leading, spacing: 2) {
                Text("SETTINGS")
                    .font(ResonanceTypography.callsignFont)
                    .foregroundColor(ResonanceColors.goldPrimary)
                    .tracking(2)
                    .padding(.horizontal, ResonanceSpacing.md)
                    .padding(.top, ResonanceSpacing.md)
                    .padding(.bottom, ResonanceSpacing.sm)

                ForEach(SettingsSection.allCases, id: \.self) { section in
                    Button(action: { selectedSection = section }) {
                        HStack {
                            Image(systemName: sectionIcon(section))
                                .frame(width: 20)
                                .foregroundColor(
                                    selectedSection == section
                                        ? ResonanceColors.goldPrimary
                                        : ResonanceColors.textMuted
                                )
                            Text(section.rawValue)
                                .font(ResonanceTypography.bodySystem)
                                .foregroundColor(
                                    selectedSection == section
                                        ? ResonanceColors.textMain
                                        : ResonanceColors.textMuted
                                )
                            Spacer()
                        }
                        .padding(.horizontal, ResonanceSpacing.md)
                        .padding(.vertical, 8)
                        .background(
                            selectedSection == section
                                ? ResonanceColors.goldPrimary.opacity(0.1)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                }
                Spacer()
            }
            .frame(width: 200)
            .background(.ultraThinMaterial)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: ResonanceSpacing.lg) {
                    switch selectedSection {
                    case .general: generalSettings
                    case .storage: storageSettings
                    case .scheduling: schedulingSettings
                    case .retention: retentionSettings
                    case .compression: compressionSettings
                    case .server: serverSettings
                    case .github: githubSettings
                    case .security: securitySettings
                    }
                }
                .padding(ResonanceSpacing.lg)
            }
        }
    }

    // MARK: - General Settings

    var generalSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("General", subtitle: "Core backup configuration")

            settingsGroup("Backup Path") {
                TextField("Backup directory", text: $viewModel.kopiaConfig.repositoryPath)
                    .textFieldStyle(.roundedBorder)
                Text("Where Kopia stores repository data locally")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }

            settingsGroup("Encryption") {
                SecureField("Repository password", text: $viewModel.kopiaConfig.encryptionPassword)
                    .textFieldStyle(.roundedBorder)
                Text("All data is encrypted at rest using AES-256-GCM")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }
        }
    }

    // MARK: - Storage Settings

    var storageSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Storage Backend", subtitle: "Where backups are stored")

            settingsGroup("This Device") {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.currentDevice.icon)
                        .font(.title2)
                        .foregroundColor(ResonanceColors.goldPrimary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.currentDevice.rawValue)
                            .font(ResonanceTypography.bodySystem)
                            .foregroundColor(ResonanceColors.textMain)
                        Text("Local backups: \(viewModel.backupPath)")
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.textLight)
                    }
                    Spacer()
                }
                HStack {
                    Text("Device label")
                        .font(ResonanceTypography.bodySystem)
                    Spacer()
                    TextField("My iPhone", text: $viewModel.deviceLabel)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                }
                Text("Label identifies this device in cloud backups (e.g. s3://bucket/My-iPhone/repo)")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }

            Text("Current: \(viewModel.kopiaConfig.storageBackend.displayName)")
                .font(ResonanceTypography.bodySystem)

            settingsGroup("Upload Configuration") {
                HStack {
                    Text("Parallel snapshots")
                    Spacer()
                    TextField("", value: $viewModel.kopiaConfig.upload.maxParallelSnapshots, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                }

                HStack {
                    Text("Parallel file reads")
                    Spacer()
                    TextField("", value: $viewModel.kopiaConfig.upload.maxParallelFileReads, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                }
            }

            settingsGroup("Azure Blob Storage") {
                Toggle("Upload repos to Azure Blob after cloning", isOn: $viewModel.uploadToAzure)

                if viewModel.uploadToAzure {
                    HStack {
                        Text("Storage Account")
                        Spacer()
                        TextField("mystorageaccount", text: $viewModel.azureAccount)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Container")
                        Spacer()
                        TextField("github-backups", text: $viewModel.azureContainer)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Account Key")
                        Spacer()
                        SecureField("Account key or SAS token", text: $viewModel.azureKey)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    Text("Repos upload via azcopy (or az cli fallback). Each repo gets its own folder in the container.")
                        .font(ResonanceTypography.captionSystem)
                        .foregroundColor(ResonanceColors.textLight)

                    if !viewModel.portfolios.isEmpty {
                        Button(action: {
                            Task {
                                await MainActor.run { viewModel.isLoading = true }
                                await viewModel.uploadAllToAzure()
                                await MainActor.run { viewModel.isLoading = false }
                            }
                        }) {
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "icloud.and.arrow.up")
                                }
                                Text(viewModel.isLoading ? "Uploading..." : "Upload All to Azure")
                                    .font(ResonanceTypography.bodySystem)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ResonanceColors.strategicBlue.opacity(0.15))
                            .foregroundColor(ResonanceColors.strategicBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(ResonanceColors.strategicBlue.opacity(0.4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.azureAccount.isEmpty || viewModel.azureContainer.isEmpty || viewModel.azureKey.isEmpty || viewModel.isLoading)
                    }

                    if !viewModel.azureProgress.isEmpty {
                        Text(viewModel.azureProgress)
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.strategicBlue)
                    }
                }
            }

            settingsGroup("Amazon S3 — Live Garden") {
                Toggle("Sync repos to Amazon S3", isOn: $viewModel.uploadToS3)

                if viewModel.uploadToS3 {
                    HStack {
                        Text("S3 Bucket")
                        Spacer()
                        TextField("my-github-backups", text: $viewModel.s3Bucket)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Region")
                        Spacer()
                        TextField("us-east-1", text: $viewModel.s3Region)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Access Key")
                        Spacer()
                        TextField("AKIA...", text: $viewModel.s3AccessKey)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Secret Key")
                        Spacer()
                        SecureField("Secret access key", text: $viewModel.s3SecretKey)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        Text("Path Prefix")
                        Spacer()
                        TextField("resonance-backups", text: $viewModel.s3Prefix)
                            .frame(width: 200)
                            .textFieldStyle(.roundedBorder)
                    }
                    Text("Each device syncs to its own S3 folder: s3://\(viewModel.s3Bucket.isEmpty ? "bucket" : viewModel.s3Bucket)/\(viewModel.s3Prefix.isEmpty ? viewModel.deviceLabel : "\(viewModel.s3Prefix)/\(viewModel.deviceLabel)")/repo-name")
                        .font(ResonanceTypography.captionSystem)
                        .foregroundColor(ResonanceColors.textLight)

                    HStack(spacing: ResonanceSpacing.sm) {
                        Image(systemName: "iphone")
                        Image(systemName: "ipad")
                        Image(systemName: "desktopcomputer")
                        Text("All devices keep local + Amazon copies in sync")
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.textMuted)
                    }

                    if !viewModel.portfolios.isEmpty {
                        Button(action: {
                            Task {
                                await MainActor.run { viewModel.isLoading = true }
                                await viewModel.uploadAllToS3()
                                await MainActor.run { viewModel.isLoading = false }
                            }
                        }) {
                            HStack(spacing: 8) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "leaf.arrow.triangle.circlepath")
                                }
                                Text(viewModel.isLoading ? "Syncing..." : "Sync to Amazon Now")
                                    .font(ResonanceTypography.bodySystem)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(ResonanceColors.growthGreen.opacity(0.15))
                            .foregroundColor(ResonanceColors.growthGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(ResonanceColors.growthGreen.opacity(0.4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.s3Bucket.isEmpty || viewModel.s3AccessKey.isEmpty || viewModel.s3SecretKey.isEmpty || viewModel.isLoading)
                    }

                    if !viewModel.s3Progress.isEmpty {
                        Text(viewModel.s3Progress)
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.growthGreen)
                    }
                }
            }
        }
    }

    // MARK: - Scheduling Settings

    var schedulingSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Scheduling", subtitle: "When backups run automatically")

            settingsGroup("Interval") {
                HStack {
                    Text("Backup every")
                    TextField("", value: $viewModel.kopiaConfig.scheduling.intervalHours, format: .number)
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                    Text("hours")
                }

                Toggle("Run missed schedules", isOn: $viewModel.kopiaConfig.scheduling.runMissed)
            }

            settingsGroup("Scheduled Times") {
                ForEach(viewModel.kopiaConfig.scheduling.timesOfDay.indices, id: \.self) { i in
                    HStack {
                        TextField("Time", text: $viewModel.kopiaConfig.scheduling.timesOfDay[i])
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                Text("Format: HH:MM (24-hour)")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }
        }
    }

    // MARK: - Retention Settings

    var retentionSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Retention", subtitle: "How long snapshots are kept")

            settingsGroup("Retention Policy") {
                retentionRow("Keep latest", value: $viewModel.kopiaConfig.retention.keepLatest)
                retentionRow("Keep hourly", value: $viewModel.kopiaConfig.retention.keepHourly)
                retentionRow("Keep daily", value: $viewModel.kopiaConfig.retention.keepDaily)
                retentionRow("Keep weekly", value: $viewModel.kopiaConfig.retention.keepWeekly)
                retentionRow("Keep monthly", value: $viewModel.kopiaConfig.retention.keepMonthly)
                retentionRow("Keep annual", value: $viewModel.kopiaConfig.retention.keepAnnual)
            }
        }
    }

    func retentionRow(_ label: String, value: Binding<Int>) -> some View {
        HStack {
            Text(label)
                .font(ResonanceTypography.bodySystem)
            Spacer()
            TextField("", value: value, format: .number)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
        }
    }

    // MARK: - Compression Settings

    var compressionSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Compression", subtitle: "Reduce backup storage size")

            settingsGroup("Algorithm") {
                Picker("Compression", selection: $viewModel.kopiaConfig.compression.algorithm) {
                    Text("Zstandard (zstd)").tag("zstd")
                    Text("Gzip").tag("gzip")
                    Text("None").tag("none")
                }
            }
        }
    }

    // MARK: - Server Settings

    var serverSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Server", subtitle: "Remote Kopia server connection")

            settingsGroup("Connection") {
                HStack {
                    Text("Host")
                    Spacer()
                    TextField("Host", text: $viewModel.serverConfig.host)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Port")
                    Spacer()
                    TextField("Port", value: $viewModel.serverConfig.port, format: .number)
                        .frame(width: 80)
                        .textFieldStyle(.roundedBorder)
                }
                Toggle("Use TLS", isOn: $viewModel.serverConfig.useTLS)
            }

            settingsGroup("Authentication") {
                HStack {
                    Text("Username")
                    Spacer()
                    TextField("Username", text: $viewModel.serverConfig.username)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Password")
                    Spacer()
                    SecureField("Password", text: $viewModel.serverConfig.password)
                        .frame(width: 200)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }

    // MARK: - GitHub Settings

    var githubSettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("GitHub Integration", subtitle: "Connect to GitHub for repository backup")

            settingsGroup("Personal Access Token") {
                SecureField("ghp_xxxxxxxxxxxxxxxxxxxx", text: $viewModel.githubToken)
                    .textFieldStyle(.roundedBorder)
                Text("Generate at GitHub → Settings → Developer settings → Personal access tokens")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)

                if !viewModel.githubToken.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ResonanceColors.growthGreen)
                        Text("Token saved")
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.growthGreen)
                    }
                }
            }

            settingsGroup("Backup Location") {
                HStack {
                    TextField("~/ResonanceBackups", text: $viewModel.backupPath)
                        .textFieldStyle(.roundedBorder)
                    #if os(macOS)
                    Button("Browse...") {
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = false
                        panel.canChooseDirectories = true
                        panel.canCreateDirectories = true
                        panel.allowsMultipleSelection = false
                        panel.prompt = "Choose Backup Folder"
                        if panel.runModal() == .OK, let url = panel.url {
                            viewModel.backupPath = url.path
                        }
                    }
                    #endif
                }
                Text("All repos will be mirror-cloned into this folder")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }

            settingsGroup("Clone All Repositories") {
                Text("Discover every repo on your GitHub account and clone them all into the backup location above")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)

                Button(action: {
                    Task { await viewModel.cloneAllRepos() }
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "square.and.arrow.down.on.square")
                        }
                        Text(viewModel.isLoading ? "Cloning..." : "Clone All My Repos")
                            .font(ResonanceTypography.bodySystem)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        viewModel.githubToken.isEmpty
                            ? ResonanceColors.textMuted.opacity(0.2)
                            : ResonanceColors.growthGreen.opacity(0.15)
                    )
                    .foregroundColor(
                        viewModel.githubToken.isEmpty
                            ? ResonanceColors.textMuted
                            : ResonanceColors.growthGreen
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.githubToken.isEmpty
                                    ? ResonanceColors.textMuted.opacity(0.3)
                                    : ResonanceColors.growthGreen.opacity(0.4),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.githubToken.isEmpty || viewModel.isLoading)

                if !viewModel.cloneProgress.isEmpty {
                    Text(viewModel.cloneProgress)
                        .font(ResonanceTypography.captionSystem)
                        .foregroundColor(ResonanceColors.goldPrimary)
                }
            }
        }
    }

    // MARK: - Security Settings

    var securitySettings: some View {
        VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
            sectionHeader("Security", subtitle: "Encryption and access control")

            settingsGroup("Bitstamp Verification") {
                Text("Every backup is timestamped using openbitstamp.org for cryptographic proof of existence")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }
        }
    }

    // MARK: - Helpers

    func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(ResonanceTypography.headingSystem)
                .foregroundColor(ResonanceColors.textMain)
            Text(subtitle)
                .font(ResonanceTypography.captionSystem)
                .foregroundColor(ResonanceColors.textMuted)
        }
    }

    func settingsGroup(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        LivingSurface(accentColor: ResonanceColors.goldPrimary) {
            VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                Text(title.uppercased())
                    .font(ResonanceTypography.callsignFont)
                    .foregroundColor(ResonanceColors.textMuted)
                    .tracking(1)
                content()
            }
            .padding(ResonanceSpacing.md)
        }
    }

    func sectionIcon(_ section: SettingsSection) -> String {
        switch section {
        case .general: return "gearshape"
        case .storage: return "internaldrive"
        case .scheduling: return "clock"
        case .retention: return "clock.arrow.circlepath"
        case .compression: return "archivebox"
        case .server: return "server.rack"
        case .github: return "arrow.triangle.branch"
        case .security: return "lock.shield"
        }
    }
}
