// PortfolioDetailView.swift
// Resonance UX GitHub Backup — Full portfolio/slide view
// Database properties, notes landing page, secrets, file slots, collaborators

import SwiftUI

struct PortfolioDetailView: View {
    @State var portfolio: Portfolio
    @EnvironmentObject var viewModel: BackupViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: DetailTab = .overview
    @State private var showInviteSheet = false
    @State private var showSecretSheet = false

    enum DetailTab: String, CaseIterable {
        case overview = "Overview"
        case database = "Database"
        case calendar = "Calendar"
        case files = "Files"
        case secrets = "Secrets"
        case collaborators = "Team"
        case marketplace = "Marketplace"
        case notes = "Notes"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BioluminescentBackground(portfolioColor: portfolio.accentColor)

                VStack(spacing: 0) {
                    portfolioHeader
                    tabBar
                    tabContent
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Print Brief") { viewModel.printBrief(for: portfolio) }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    var portfolioHeader: some View {
        HStack(spacing: ResonanceSpacing.md) {
            // Logo
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        RadialGradient(
                            colors: [portfolio.accentColor.opacity(0.3), portfolio.accentColor.opacity(0.05)],
                            center: UnitPoint(x: 0.3, y: 0.3),
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 64, height: 64)

                Text(portfolio.logoEmoji)
                    .font(.system(size: 32))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(portfolio.displayCallsign)
                    .font(ResonanceTypography.callsignFont)
                    .foregroundColor(portfolio.accentColor)
                    .tracking(2)

                Text(portfolio.repositoryName)
                    .font(ResonanceTypography.headingSystem)
                    .foregroundColor(ResonanceColors.textMain)

                HStack(spacing: ResonanceSpacing.sm) {
                    Label(portfolio.primaryLanguage, systemImage: "chevron.left.forwardslash.chevron.right")
                    Label(portfolio.repositoryURL, systemImage: "link")
                        .lineLimit(1)
                }
                .font(ResonanceTypography.captionSystem)
                .foregroundColor(ResonanceColors.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                IndicatorLight(status: portfolio.backupStatus, size: 10)
                Text(portfolio.backupStatus.rawValue)
                    .font(ResonanceTypography.callsignFont)
                    .foregroundColor(ResonanceColors.textMuted)

                Text("Uploaded \(portfolio.dateOfUpload.formatted(.dateTime.year().month().day()))")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textLight)
            }
        }
        .padding(ResonanceSpacing.md)
    }

    // MARK: - Tab Bar

    var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.rawValue)
                            .font(ResonanceTypography.captionSystem)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .padding(.horizontal, ResonanceSpacing.md)
                            .padding(.vertical, ResonanceSpacing.sm)
                            .background(
                                selectedTab == tab
                                    ? portfolio.accentColor.opacity(0.15)
                                    : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, ResonanceSpacing.md)
        }
        .padding(.vertical, ResonanceSpacing.xs)
    }

    // MARK: - Tab Content

    @ViewBuilder
    var tabContent: some View {
        ScrollView {
            switch selectedTab {
            case .overview:
                overviewSection
            case .database:
                databaseSection
            case .calendar:
                CalendarLedgerView(portfolio: portfolio)
            case .files:
                fileSlotsSection
            case .secrets:
                secretsSection
            case .collaborators:
                collaboratorsSection
            case .marketplace:
                MarketplaceView()
                    .environmentObject(viewModel)
            case .notes:
                notesSection
            }
        }
    }

    // MARK: - Overview

    var overviewSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            // Stats Grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: ResonanceSpacing.sm) {
                statCard("Files", value: "\(portfolio.fileCount)", icon: "doc")
                statCard("Size", value: formatBytes(portfolio.totalSize), icon: "internaldrive")
                statCard("Commits", value: "\(portfolio.commitCount)", icon: "arrow.triangle.branch")
                statCard("Branches", value: "\(portfolio.branchCount)", icon: "arrow.triangle.branch")
                statCard("Collaborators", value: "\(portfolio.collaborators.count)", icon: "person.2")
                statCard("Changes", value: "\(portfolio.changelog.count)", icon: "clock.arrow.circlepath")
            }

            // Language breakdown
            if !portfolio.languages.isEmpty {
                LivingSurface(accentColor: portfolio.accentColor) {
                    VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        Text("LANGUAGE BREAKDOWN")
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(ResonanceColors.textMuted)
                            .tracking(1)

                        ForEach(portfolio.languages) { lang in
                            HStack {
                                Text(lang.language)
                                    .font(ResonanceTypography.bodySystem)
                                Spacer()
                                Text("\(Int(lang.percentage))%")
                                    .font(ResonanceTypography.monoFont)

                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(portfolio.accentColor)
                                        .frame(width: geo.size.width * lang.percentage / 100)
                                }
                                .frame(width: 100, height: 6)
                            }
                        }
                    }
                    .padding(ResonanceSpacing.md)
                }
            }

            // Recent Changes
            if !portfolio.changelog.isEmpty {
                LivingSurface(accentColor: portfolio.accentColor) {
                    VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        Text("RECENT CHANGES")
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(ResonanceColors.textMuted)
                            .tracking(1)

                        ForEach(portfolio.changelog.prefix(5)) { entry in
                            HStack {
                                ChromaticOrb(color: portfolio.accentColor, size: 6, pulse: false)
                                Text(entry.action.rawValue)
                                    .font(ResonanceTypography.captionSystem)
                                    .fontWeight(.medium)
                                Text(entry.description)
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textMuted)
                                    .lineLimit(1)
                                Spacer()
                                Text(entry.date.formatted(.dateTime.month().day().hour().minute()))
                                    .font(ResonanceTypography.monoFont)
                                    .foregroundColor(ResonanceColors.textLight)
                            }
                        }
                    }
                    .padding(ResonanceSpacing.md)
                }
            }
        }
        .padding(ResonanceSpacing.md)
    }

    func statCard(_ title: String, value: String, icon: String) -> some View {
        LivingSurface(accentColor: portfolio.accentColor) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .tracking(1)
                    Text(value)
                        .font(ResonanceTypography.headingSystem)
                        .foregroundColor(ResonanceColors.textMain)
                }
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(portfolio.accentColor.opacity(0.5))
            }
            .padding(ResonanceSpacing.md)
        }
    }

    // MARK: - Database Section

    var databaseSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            LivingSurface(accentColor: portfolio.accentColor) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                    Text("PROPERTIES")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .tracking(1)

                    ForEach(portfolio.properties) { prop in
                        HStack {
                            Text(prop.key)
                                .font(ResonanceTypography.bodySystem)
                                .foregroundColor(ResonanceColors.textMuted)
                                .frame(width: 140, alignment: .leading)

                            Text(prop.value)
                                .font(ResonanceTypography.bodySystem)
                                .foregroundColor(ResonanceColors.textMain)

                            Spacer()

                            Text(prop.kind.rawValue)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(ResonanceColors.textLight)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(ResonanceColors.borderLight)
                                .clipShape(Capsule())
                        }
                        Divider().opacity(0.2)
                    }
                }
                .padding(ResonanceSpacing.md)
            }

            // Original URL & Upload Date
            LivingSurface(accentColor: portfolio.accentColor) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                    Text("SOURCE INFORMATION")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .tracking(1)

                    HStack {
                        Text("Original URL")
                            .foregroundColor(ResonanceColors.textMuted)
                        Spacer()
                        Text(portfolio.repositoryURL)
                            .foregroundColor(portfolio.accentColor)
                    }
                    .font(ResonanceTypography.bodySystem)

                    HStack {
                        Text("Upload Date")
                            .foregroundColor(ResonanceColors.textMuted)
                        Spacer()
                        Text(portfolio.dateOfUpload.formatted())
                    }
                    .font(ResonanceTypography.bodySystem)

                    HStack {
                        Text("Last Sync")
                            .foregroundColor(ResonanceColors.textMuted)
                        Spacer()
                        Text(portfolio.lastSyncDate.formatted())
                    }
                    .font(ResonanceTypography.bodySystem)

                    if let snapshot = portfolio.kopiaSnapshotID {
                        HStack {
                            Text("Kopia Snapshot")
                                .foregroundColor(ResonanceColors.textMuted)
                            Spacer()
                            Text(snapshot)
                                .font(ResonanceTypography.monoFont)
                        }
                        .font(ResonanceTypography.bodySystem)
                    }
                }
                .padding(ResonanceSpacing.md)
            }

            // Bitstamp Records
            if !portfolio.bitstampRecords.isEmpty {
                LivingSurface(accentColor: portfolio.accentColor) {
                    VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        Text("BITSTAMP VERIFICATION")
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(ResonanceColors.textMuted)
                            .tracking(1)

                        ForEach(portfolio.bitstampRecords) { record in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(record.timestamp.formatted())
                                        .font(ResonanceTypography.captionSystem)
                                    Spacer()
                                    Text(record.source)
                                        .font(ResonanceTypography.captionSystem)
                                        .foregroundColor(portfolio.accentColor)
                                }
                                Text("Project: \(record.projectHash.prefix(24))...")
                                    .font(ResonanceTypography.monoFont)
                                    .foregroundColor(ResonanceColors.textMuted)
                                Text("Bitstamp: \(record.bitstampHash.prefix(24))...")
                                    .font(ResonanceTypography.monoFont)
                                    .foregroundColor(ResonanceColors.goldPrimary)
                            }
                            Divider().opacity(0.2)
                        }
                    }
                    .padding(ResonanceSpacing.md)
                }
            }
        }
        .padding(ResonanceSpacing.md)
    }

    // MARK: - File Slots Section

    var fileSlotsSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            ForEach(portfolio.fileSlots) { slot in
                LivingSurface(accentColor: portfolio.accentColor) {
                    VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(portfolio.accentColor)
                            Text(slot.name.uppercased())
                                .font(ResonanceTypography.callsignFont)
                                .foregroundColor(ResonanceColors.textMuted)
                                .tracking(1)
                            Spacer()
                            Text("\(slot.files.count) files")
                                .font(ResonanceTypography.captionSystem)
                                .foregroundColor(ResonanceColors.textLight)
                        }

                        Text(slot.description)
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.textMuted)

                        if slot.files.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 4) {
                                    Image(systemName: "plus.rectangle.on.folder")
                                        .font(.system(size: 24))
                                        .foregroundColor(portfolio.accentColor.opacity(0.4))
                                    Text("Drop files here")
                                        .font(ResonanceTypography.captionSystem)
                                        .foregroundColor(ResonanceColors.textLight)
                                }
                                .padding(ResonanceSpacing.lg)
                                Spacer()
                            }
                        } else {
                            ForEach(slot.files) { file in
                                HStack {
                                    Image(systemName: "doc")
                                        .foregroundColor(ResonanceColors.textMuted)
                                    Text(file.fileName)
                                        .font(ResonanceTypography.bodySystem)
                                    Spacer()
                                    Text(formatBytes(file.fileSize))
                                        .font(ResonanceTypography.monoFont)
                                        .foregroundColor(ResonanceColors.textLight)
                                }
                            }
                        }
                    }
                    .padding(ResonanceSpacing.md)
                }
            }
        }
        .padding(ResonanceSpacing.md)
    }

    // MARK: - Secrets Section

    var secretsSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            LivingSurface(accentColor: portfolio.accentColor) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
                    HStack {
                        Text("SECRETS VAULT")
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(ResonanceColors.textMuted)
                            .tracking(1)
                        Spacer()
                        Button(action: { showSecretSheet = true }) {
                            Label("Add Secret", systemImage: "plus")
                                .font(ResonanceTypography.captionSystem)
                        }
                    }

                    if portfolio.secrets.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 32))
                                    .foregroundColor(portfolio.accentColor.opacity(0.3))
                                Text("No secrets stored")
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textLight)
                                Text("API keys, tokens, and credentials are encrypted at rest")
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textLight)
                            }
                            .padding(ResonanceSpacing.lg)
                            Spacer()
                        }
                    } else {
                        ForEach(portfolio.secrets) { secret in
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(ResonanceColors.goldPrimary)
                                Text(secret.name)
                                    .font(ResonanceTypography.bodySystem)
                                Spacer()
                                Text("••••••••")
                                    .font(ResonanceTypography.monoFont)
                                    .foregroundColor(ResonanceColors.textLight)
                                Text(secret.createdAt.formatted(.dateTime.month().day()))
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textLight)
                            }
                            Divider().opacity(0.2)
                        }
                    }
                }
                .padding(ResonanceSpacing.md)
            }
        }
        .padding(ResonanceSpacing.md)
    }

    // MARK: - Collaborators Section

    var collaboratorsSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            LivingSurface(accentColor: portfolio.accentColor) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.md) {
                    HStack {
                        Text("COLLABORATORS")
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(ResonanceColors.textMuted)
                            .tracking(1)
                        Spacer()
                        Button(action: { showInviteSheet = true }) {
                            Label("Invite", systemImage: "person.badge.plus")
                                .font(ResonanceTypography.captionSystem)
                        }
                    }

                    if portfolio.collaborators.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Image(systemName: "person.2.circle")
                                    .font(.system(size: 32))
                                    .foregroundColor(portfolio.accentColor.opacity(0.3))
                                Text("No collaborators yet")
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textLight)
                                Text("Invite team members to view and contribute")
                                    .font(ResonanceTypography.captionSystem)
                                    .foregroundColor(ResonanceColors.textLight)
                            }
                            .padding(ResonanceSpacing.lg)
                            Spacer()
                        }
                    } else {
                        ForEach(portfolio.collaborators) { collab in
                            HStack {
                                Circle()
                                    .fill(portfolio.accentColor.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(String(collab.username.prefix(1)).uppercased())
                                            .font(ResonanceTypography.callsignFont)
                                            .foregroundColor(portfolio.accentColor)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(collab.username)
                                        .font(ResonanceTypography.bodySystem)
                                    if let email = collab.email {
                                        Text(email)
                                            .font(ResonanceTypography.captionSystem)
                                            .foregroundColor(ResonanceColors.textLight)
                                    }
                                }

                                Spacer()

                                Text(collab.role.rawValue)
                                    .font(ResonanceTypography.callsignFont)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(portfolio.accentColor.opacity(0.12))
                                    .clipShape(Capsule())

                                if collab.acceptedAt == nil {
                                    Text("Pending")
                                        .font(ResonanceTypography.captionSystem)
                                        .foregroundColor(ResonanceColors.warmthAmber)
                                }
                            }
                            Divider().opacity(0.2)
                        }
                    }
                }
                .padding(ResonanceSpacing.md)
            }
        }
        .padding(ResonanceSpacing.md)
    }

    // MARK: - Notes Section

    var notesSection: some View {
        VStack(spacing: ResonanceSpacing.md) {
            LivingSurface(accentColor: portfolio.accentColor) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                    Text("NOTES & LANDING PAGE")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .tracking(1)

                    TextEditor(text: $portfolio.notes)
                        .font(ResonanceTypography.bodySystem)
                        .frame(minHeight: 300)
                        .scrollContentBackground(.hidden)
                }
                .padding(ResonanceSpacing.md)
            }

            // Tags
            LivingSurface(accentColor: portfolio.accentColor) {
                VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                    Text("TAGS")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.textMuted)
                        .tracking(1)

                    FlowLayout(spacing: 6) {
                        ForEach(portfolio.tags, id: \.self) { tag in
                            Text(tag)
                                .font(ResonanceTypography.captionSystem)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(portfolio.accentColor.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(ResonanceSpacing.md)
            }
        }
        .padding(ResonanceSpacing.md)
    }

    func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
    }
}
