import SwiftUI

struct PortfolioDetailView: View {
    @Binding var repo: Repository
    let color: Color
    let onBack: () -> Void

    @State private var activeTab = "overview"
    @State private var inviteEmail = ""
    @State private var secretKey = ""
    @State private var secretVal = ""

    private var callsign: String { CallsignGenerator.generate(name: repo.name) }
    private var languages: [String] { LanguageDetector.detect(files: repo.files) }
    private var hash: String { BitstampHash.generate(data: repo.name + "\(repo.lastSync)") }

    private let tabs = [
        ("overview", "Overview"), ("database", "Database"), ("calendar", "Calendar"),
        ("notes", "Notes"), ("files", "File Slots"), ("secrets", "Secrets"), ("collabs", "Team"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                tabBar
                tabContent
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 20) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white.opacity(0.6))
                    .padding(10)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(callsign)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(ResonanceTheme.gold)
                    .textCase(.uppercase)

                Text(repo.name)
                    .font(.system(size: 32, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            BioIndicator(status: repo.status)
            ChromaticOrb(name: repo.name, color: color, size: 40)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(tabs, id: \.0) { tab in
                    Button(action: { activeTab = tab.0 }) {
                        Text(tab.1)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(activeTab == tab.0 ? ResonanceTheme.gold : .white.opacity(0.5))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(activeTab == tab.0 ? ResonanceTheme.gold.opacity(0.15) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.03))
            .cornerRadius(12)
        }
        .padding(.bottom, 24)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch activeTab {
        case "overview":
            overviewTab
        case "database":
            databaseTab
        case "calendar":
            CalendarLedgerView(
                repos: [repo],
                events: [
                    BackupEvent(date: repo.lastSync, description: "Snapshot synced for \(repo.name)", hash: hash),
                    BackupEvent(date: repo.uploadDate, description: "Initial upload of \(repo.name)",
                                hash: BitstampHash.generate(data: repo.name + "\(repo.uploadDate)")),
                ]
            )
        case "notes":
            notesTab
        case "files":
            filesTab
        case "secrets":
            secretsTab
        case "collabs":
            collabsTab
        default:
            EmptyView()
        }
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        VStack(spacing: 20) {
            DetailSection(icon: "sun.max", title: "Portfolio Information") {
                VStack(spacing: 0) {
                    InfoRow(label: "Repository URL", value: repo.url, isLink: true)
                    InfoRow(label: "Upload Date", value: repo.uploadDate.formatted())
                    InfoRow(label: "Last Synchronized", value: repo.lastSync.formatted())
                    InfoRow(label: "Languages", value: languages.joined(separator: ", "))
                    InfoRow(label: "Files Tracked", value: "\(repo.files.count)")
                    InfoRow(label: "Stars / Forks", value: "\(repo.stars) / \(repo.forks)")
                    InfoRow(label: "Bitstamp Hash", value: hash, isMono: true, color: ResonanceTheme.gold)
                    InfoRow(label: "Callsign", value: callsign, isMono: true)
                    InfoRow(label: "Collaborators", value: repo.collaborators.isEmpty ? "None" : repo.collaborators.joined(separator: ", "))

                    HStack {
                        Text("Backup Status")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 160, alignment: .leading)

                        HStack(spacing: 8) {
                            BioIndicator(status: repo.status)
                            Text(repo.status.displayName)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                        }

                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
            }

            DetailSection(icon: "doc.text", title: "Files") {
                FlowLayout(spacing: 6) {
                    ForEach(repo.files, id: \.self) { file in
                        Text(file)
                            .font(.system(size: 12, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.04))
                            .foregroundColor(.white.opacity(0.5))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }

    // MARK: - Database Tab

    private var databaseTab: some View {
        DetailSection(icon: "tablecells", title: "Properties Database") {
            VStack(spacing: 0) {
                InfoRow(label: "Name", type: "Text", value: repo.name)
                InfoRow(label: "URL", type: "URL", value: repo.url)
                InfoRow(label: "Status", type: "Select", value: repo.status.displayName)
                InfoRow(label: "Upload Date", type: "Date", value: repo.uploadDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Last Sync", type: "Date", value: repo.lastSync.formatted(date: .abbreviated, time: .omitted))
                InfoRow(label: "Languages", type: "Multi-Select", value: languages.joined(separator: ", "))
                InfoRow(label: "File Count", type: "Number", value: "\(repo.files.count)")
                InfoRow(label: "Stars", type: "Number", value: "\(repo.stars)")
                InfoRow(label: "Forks", type: "Number", value: "\(repo.forks)")
                InfoRow(label: "Bitstamp", type: "Text", value: hash, isMono: true, color: ResonanceTheme.gold)
                InfoRow(label: "Callsign", type: "Text", value: callsign)
                InfoRow(label: "Collaborators", type: "Multi-Select", value: repo.collaborators.joined(separator: ", "))
                InfoRow(label: "Design Files", type: "Files", value: repo.designFiles.joined(separator: ", "))
            }
        }
    }

    // MARK: - Notes Tab

    private var notesTab: some View {
        DetailSection(icon: "pencil", title: "Landing Page & Notes") {
            VStack(alignment: .trailing, spacing: 12) {
                TextEditor(text: $repo.notes)
                    .scrollContentBackground(.hidden)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(minHeight: 120)
                    .padding(16)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )

                Button("Save Notes") {}
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [ResonanceTheme.gold, ResonanceTheme.goldDark],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(10)
            }
        }
    }

    // MARK: - Files Tab

    private var filesTab: some View {
        DetailSection(icon: "diamond", title: "File Slots") {
            VStack(spacing: 16) {
                let slots: [(String, String, [String])] = [
                    ("Design Files", "triangle", repo.designFiles),
                    ("Documentation", "line.3.horizontal", []),
                    ("Assets", "diamond", []),
                    ("Configuration", "gearshape", []),
                    ("Tests", "checkmark", []),
                    ("CI/CD", "arrow.triangle.2.circlepath", []),
                ]

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                    ForEach(slots, id: \.0) { slot in
                        VStack(spacing: 6) {
                            Image(systemName: slot.1)
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.4))

                            Text(slot.0)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(slot.2.isEmpty ? 0.35 : 0.6))
                                .textCase(.uppercase)
                                .tracking(0.5)

                            if !slot.2.isEmpty {
                                Text("\(slot.2.count) file\(slot.2.count != 1 ? "s" : "")")
                                    .font(.system(size: 10))
                                    .foregroundColor(ResonanceTheme.growthGreen)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    slot.2.isEmpty
                                        ? Color.white.opacity(0.1)
                                        : ResonanceTheme.growthGreen.opacity(0.2),
                                    style: slot.2.isEmpty
                                        ? StrokeStyle(lineWidth: 1, dash: [5])
                                        : StrokeStyle(lineWidth: 1)
                                )
                        )
                        .background(
                            slot.2.isEmpty
                                ? Color.clear
                                : ResonanceTheme.growthGreen.opacity(0.04)
                        )
                        .cornerRadius(12)
                    }
                }

                if !repo.designFiles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attached Design Files:")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.4))

                        ForEach(repo.designFiles, id: \.self) { file in
                            HStack(spacing: 6) {
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 8))
                                Text(file)
                            }
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Secrets Tab

    private var secretsTab: some View {
        DetailSection(icon: "lock.shield", title: "Secrets Vault") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Encrypted secrets stored locally. Never synced to remote unless explicitly configured.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.35))

                ForEach(repo.secrets) { secret in
                    HStack(spacing: 8) {
                        TextField("Key", text: .constant(secret.key))
                            .textFieldStyle(.plain)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                            .frame(maxWidth: 160)
                            .disabled(true)

                        SecureField("Value", text: .constant(secret.value))
                            .textFieldStyle(.plain)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(8)
                            .disabled(true)
                    }
                }

                HStack(spacing: 8) {
                    TextField("Key name", text: $secretKey)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: 160)

                    SecureField("Secret value", text: $secretVal)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(8)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(8)

                    Button("Add") {
                        if !secretKey.isEmpty && !secretVal.isEmpty {
                            repo.secrets.append(Secret(key: secretKey, value: secretVal))
                            secretKey = ""
                            secretVal = ""
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [ResonanceTheme.gold, ResonanceTheme.goldDark],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(10)
                }
            }
        }
    }

    // MARK: - Collaborators Tab

    private var collabsTab: some View {
        DetailSection(icon: "star", title: "Collaborators") {
            VStack(spacing: 12) {
                ForEach(repo.collaborators, id: \.self) { email in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [ResonanceTheme.growthGreen, ResonanceTheme.strategicBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 28, height: 28)

                            Text(String(email.prefix(1).uppercased()))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Text(email)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Text("Active")
                            .font(.system(size: 11))
                            .foregroundColor(ResonanceTheme.growthGreen)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.03))
                    .cornerRadius(10)
                }

                HStack(spacing: 8) {
                    TextField("Invite collaborator by email...", text: $inviteEmail)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.15))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )

                    Button("Invite") {
                        if !inviteEmail.isEmpty {
                            repo.collaborators.append(inviteEmail)
                            inviteEmail = ""
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(colors: [ResonanceTheme.gold, ResonanceTheme.goldDark],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(10)
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Supporting Views

struct DetailSection<Content: View>: View {
    var icon: String
    var title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.white.opacity(0.7))
            }

            content()
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

struct InfoRow: View {
    var label: String
    var type: String? = nil
    var value: String
    var isLink: Bool = false
    var isMono: Bool = false
    var color: Color? = nil

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 160, alignment: .leading)

            if let type = type {
                Text(type)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.25))
                    .frame(width: 80, alignment: .leading)
            }

            Text(value)
                .font(isMono ? .system(size: 12, design: .monospaced) : .system(size: 13))
                .foregroundColor(color ?? (isLink ? ResonanceTheme.growthGreen : .white.opacity(0.7)))
                .lineLimit(1)

            Spacer()
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.03))
                .frame(height: 1)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                   proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
