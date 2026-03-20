import SwiftUI
import Security

// MARK: - Keychain Helper for GitHub Token

enum KeychainHelper {
    static let service = "com.resonance.portal"
    static let githubTokenKey = "github_personal_access_token"

    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
        var addQuery = query
        addQuery[kSecValueData as String] = data
        return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var currentView: NavigationTab = .gallery
    @State private var repos: [Repository] = Repository.samples
    @State private var selectedRepoIndex: Int? = nil
    @State private var searchText = ""
    @State private var showGitHubKeySheet = false
    @State private var githubToken: String = ""
    @State private var githubTokenSaved = false

    private var filteredRepos: [Repository] {
        if searchText.isEmpty { return repos }
        return repos.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var systemEvents: [BackupEvent] {
        repos.flatMap { r in
            [
                BackupEvent(date: r.lastSync, description: "Kopia snapshot: \(r.name)",
                            hash: BitstampHash.generate(data: r.name + "\(r.lastSync)")),
                BackupEvent(date: r.uploadDate, description: "Initial upload: \(r.name)",
                            hash: BitstampHash.generate(data: r.name + "\(r.uploadDate)")),
                BackupEvent(date: r.lastSync.addingTimeInterval(-86400), description: "Policy check: \(r.name)",
                            hash: BitstampHash.generate(data: r.name + "policy")),
                BackupEvent(date: r.lastSync.addingTimeInterval(-172800), description: "Bitstamp verified: \(r.name)",
                            hash: BitstampHash.generate(data: r.name + "bitstamp")),
            ]
        }.sorted { $0.date > $1.date }
    }

    enum NavigationTab: String, CaseIterable {
        case gallery = "Gallery"
        case database = "Database"
        case calendar = "Ledger"
        case report = "Report"
        case settings = "Settings"
    }

    var body: some View {
        ZStack {
            BreathingBackground()

            VStack(spacing: 0) {
                headerBar
                mainContent
            }
        }
        .onAppear {
            // Check if GitHub token exists in Keychain
            if let token = KeychainHelper.load(key: KeychainHelper.githubTokenKey) {
                githubToken = token
                githubTokenSaved = true
            }
        }
        .sheet(isPresented: $showGitHubKeySheet) {
            gitHubKeySheet
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 12) {
            // Title
            HStack(spacing: 4) {
                Text("Resonance")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundColor(ResonanceTheme.gold)
                Text("GitHub Backup Portal")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.25))
                TextField("Search portfolios...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.04))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .frame(maxWidth: 240)

            // Nav tabs
            HStack(spacing: 4) {
                ForEach(NavigationTab.allCases, id: \.self) { tab in
                    Button(action: {
                        currentView = tab
                        selectedRepoIndex = nil
                    }) {
                        Text(tab.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(currentView == tab && selectedRepoIndex == nil
                                             ? ResonanceTheme.gold : .white.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(currentView == tab && selectedRepoIndex == nil
                                        ? ResonanceTheme.gold.opacity(0.15) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)

            // GitHub Key button
            Button(action: { showGitHubKeySheet = true }) {
                Image(systemName: githubTokenSaved ? "key.fill" : "key")
                    .font(.system(size: 14))
                    .foregroundColor(githubTokenSaved ? ResonanceTheme.growthGreen : .white.opacity(0.5))
                    .padding(10)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.04)).frame(height: 1)
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        if let index = selectedRepoIndex {
            PortfolioDetailView(
                repo: $repos[index],
                color: ResonanceTheme.chromaticPalette[repos[index].id % ResonanceTheme.chromaticPalette.count],
                onBack: { selectedRepoIndex = nil }
            )
        } else {
            switch currentView {
            case .gallery:
                GalleryView(repos: filteredRepos) { repo in
                    selectedRepoIndex = repos.firstIndex(where: { $0.id == repo.id })
                }
            case .database:
                DatabaseView(repos: filteredRepos)
            case .calendar:
                ScrollView {
                    CalendarLedgerView(repos: repos, events: systemEvents)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 24)
                }
            case .report:
                ReportPreviewView(repos: repos)
            case .settings:
                SettingsView()
            }
        }
    }

    // MARK: - GitHub Key Sheet

    private var gitHubKeySheet: some View {
        NavigationStack {
            ZStack {
                ResonanceTheme.green900.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(ResonanceTheme.gold)
                        .padding(.top, 20)

                    Text("GitHub Personal Access Token")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.9))

                    Text("Your token is stored securely in the iOS Keychain and never leaves this device. It is used to authenticate with the GitHub API for backup operations.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("PERSONAL ACCESS TOKEN")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.35))

                        SecureField("ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", text: $githubToken)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(16)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 28)

                    VStack(spacing: 12) {
                        Button(action: saveGitHubToken) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield")
                                Text("Save to Keychain")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [ResonanceTheme.gold, ResonanceTheme.goldDark],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(12)
                        }

                        if githubTokenSaved {
                            Button(action: deleteGitHubToken) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash")
                                    Text("Remove Token")
                                }
                                .font(.system(size: 13))
                                .foregroundColor(ResonanceTheme.rhythmCoral)
                            }
                        }
                    }
                    .padding(.horizontal, 28)

                    if githubTokenSaved {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ResonanceTheme.growthGreen)
                            Text("Token saved in Keychain")
                                .font(.system(size: 12))
                                .foregroundColor(ResonanceTheme.growthGreen)
                        }
                    }

                    Spacer()

                    // Required scopes info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Required Scopes:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))

                        ForEach(["repo (Full control of private repositories)",
                                 "read:org (Read org membership)",
                                 "read:user (Read user profile data)"], id: \.self) { scope in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(ResonanceTheme.growthGreen.opacity(0.5))
                                    .frame(width: 4, height: 4)
                                Text(scope)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { showGitHubKeySheet = false }
                        .foregroundColor(ResonanceTheme.gold)
                }
            }
        }
    }

    private func saveGitHubToken() {
        if KeychainHelper.save(key: KeychainHelper.githubTokenKey, value: githubToken) {
            githubTokenSaved = true
        }
    }

    private func deleteGitHubToken() {
        KeychainHelper.delete(key: KeychainHelper.githubTokenKey)
        githubToken = ""
        githubTokenSaved = false
    }
}
