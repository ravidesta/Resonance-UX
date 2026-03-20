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

            // Backend picker would go here
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
