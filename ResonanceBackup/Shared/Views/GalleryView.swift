// GalleryView.swift
// Resonance UX GitHub Backup — Gallery Mode
// Each repo displayed as a living surface cell with callsign & logo

import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var viewModel: BackupViewModel
    @State private var selectedPortfolio: Portfolio?
    @State private var searchText = ""
    @State private var filterLanguage = "All"
    @State private var viewStyle: ViewStyle = .gallery

    enum ViewStyle: String, CaseIterable {
        case gallery = "Gallery"
        case list = "List"
        case database = "Database"
    }

    var filteredPortfolios: [Portfolio] {
        viewModel.portfolios.filter { portfolio in
            let matchesSearch = searchText.isEmpty ||
                portfolio.repositoryName.localizedCaseInsensitiveContains(searchText) ||
                portfolio.callsign.localizedCaseInsensitiveContains(searchText)
            let matchesLang = filterLanguage == "All" || portfolio.primaryLanguage == filterLanguage
            return matchesSearch && matchesLang
        }
    }

    var allLanguages: [String] {
        let langs = Set(viewModel.portfolios.map(\.primaryLanguage))
        return ["All"] + langs.sorted()
    }

    var body: some View {
        ZStack {
            BioluminescentBackground(portfolioColor: ResonanceColors.growthGreen)

            VStack(spacing: 0) {
                // Header
                galleryHeader

                // Content
                ScrollView {
                    switch viewStyle {
                    case .gallery:
                        galleryGrid
                    case .list:
                        listView
                    case .database:
                        databaseView
                    }
                }
                .padding(.horizontal, ResonanceSpacing.md)
            }
        }
        .sheet(item: $selectedPortfolio) { portfolio in
            PortfolioDetailView(portfolio: portfolio)
                .environmentObject(viewModel)
        }
    }

    // MARK: - Header

    var galleryHeader: some View {
        VStack(spacing: ResonanceSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RESONANCE BACKUP")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.goldPrimary)
                        .tracking(3)

                    Text("Portfolio Gallery")
                        .font(ResonanceTypography.titleSystem)
                        .foregroundColor(ResonanceColors.textMain)
                }

                Spacer()

                // View Style Picker
                Picker("View", selection: $viewStyle) {
                    ForEach(ViewStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 240)

                // Field Coherence (aggregate status)
                fieldCoherenceIndicator
            }

            HStack(spacing: ResonanceSpacing.sm) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ResonanceColors.textMuted)
                    TextField("Search portfolios...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(ResonanceSpacing.sm)
                .glassPanel()

                // Language filter
                Picker("Language", selection: $filterLanguage) {
                    ForEach(allLanguages, id: \.self) { lang in
                        Text(lang).tag(lang)
                    }
                }
                .frame(width: 150)

                Text("\(filteredPortfolios.count) projects")
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textMuted)
            }
        }
        .padding(ResonanceSpacing.md)
    }

    // MARK: - Gallery Grid

    var galleryGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 280, maximum: 400), spacing: ResonanceSpacing.md)],
            spacing: ResonanceSpacing.md
        ) {
            ForEach(filteredPortfolios) { portfolio in
                PortfolioCellView(portfolio: portfolio)
                    .onTapGesture { selectedPortfolio = portfolio }
            }
        }
        .padding(.bottom, ResonanceSpacing.xl)
    }

    // MARK: - List View

    var listView: some View {
        LazyVStack(spacing: ResonanceSpacing.sm) {
            ForEach(filteredPortfolios) { portfolio in
                PortfolioListRow(portfolio: portfolio)
                    .onTapGesture { selectedPortfolio = portfolio }
            }
        }
        .padding(.bottom, ResonanceSpacing.xl)
    }

    // MARK: - Database View

    var databaseView: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                databaseColumn("Callsign", width: 200)
                databaseColumn("Language", width: 100)
                databaseColumn("Status", width: 80)
                databaseColumn("Size", width: 80)
                databaseColumn("Files", width: 60)
                databaseColumn("Last Sync", width: 140)
                databaseColumn("Bitstamp", width: 120)
                Spacer()
            }
            .padding(.vertical, ResonanceSpacing.sm)
            .background(ResonanceColors.green800.opacity(0.1))

            ForEach(filteredPortfolios) { portfolio in
                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        IndicatorLight(status: portfolio.backupStatus, size: 6)
                        Text(portfolio.displayCallsign)
                            .font(ResonanceTypography.callsignFont)
                            .lineLimit(1)
                    }
                    .frame(width: 200, alignment: .leading)

                    Text(portfolio.primaryLanguage)
                        .font(ResonanceTypography.captionSystem)
                        .frame(width: 100, alignment: .leading)

                    Text(portfolio.backupStatus.rawValue)
                        .font(ResonanceTypography.captionSystem)
                        .frame(width: 80, alignment: .leading)

                    Text(formatBytes(portfolio.totalSize))
                        .font(ResonanceTypography.monoFont)
                        .frame(width: 80, alignment: .trailing)

                    Text("\(portfolio.fileCount)")
                        .font(ResonanceTypography.monoFont)
                        .frame(width: 60, alignment: .trailing)

                    Text(portfolio.lastSyncDate.formatted(.dateTime.month().day().hour().minute()))
                        .font(ResonanceTypography.captionSystem)
                        .frame(width: 140, alignment: .leading)

                    Text(portfolio.bitstampRecords.last?.bitstampHash.prefix(12) ?? "—")
                        .font(ResonanceTypography.monoFont)
                        .frame(width: 120, alignment: .leading)

                    Spacer()
                }
                .padding(.vertical, 6)
                .padding(.horizontal, ResonanceSpacing.sm)
                .contentShape(Rectangle())
                .onTapGesture { selectedPortfolio = portfolio }
            }
        }
        .glassPanel()
        .padding(.bottom, ResonanceSpacing.xl)
    }

    func databaseColumn(_ title: String, width: CGFloat) -> some View {
        Text(title)
            .font(ResonanceTypography.callsignFont)
            .foregroundColor(ResonanceColors.textMuted)
            .frame(width: width, alignment: .leading)
    }

    // MARK: - Field Coherence

    var fieldCoherenceIndicator: some View {
        let synced = viewModel.portfolios.filter { $0.backupStatus == .synced }.count
        let total = max(viewModel.portfolios.count, 1)
        let coherence = Double(synced) / Double(total)

        return VStack(alignment: .trailing, spacing: 2) {
            Text("FIELD COHERENCE")
                .font(ResonanceTypography.callsignFont)
                .foregroundColor(ResonanceColors.textMuted)
                .tracking(1)

            HStack(spacing: 4) {
                ChromaticOrb(
                    color: coherence > 0.8 ? ResonanceColors.growthGreen : ResonanceColors.warmthAmber,
                    size: 8, pulse: coherence < 1.0
                )
                Text("\(Int(coherence * 100))%")
                    .font(ResonanceTypography.monoFont)
                    .foregroundColor(ResonanceColors.goldPrimary)
            }
        }
    }

    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Portfolio Cell (Gallery Mode)

struct PortfolioCellView: View {
    let portfolio: Portfolio
    @Environment(\.colorScheme) var scheme

    var body: some View {
        LivingSurface(accentColor: portfolio.accentColor) {
            VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                // Top: Logo + Callsign + Status
                HStack {
                    // Logo
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(portfolio.accentColor.opacity(0.15))
                            .frame(width: 48, height: 48)

                        Text(portfolio.logoEmoji)
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(portfolio.displayCallsign)
                            .font(ResonanceTypography.callsignFont)
                            .foregroundColor(portfolio.accentColor)
                            .tracking(1.5)
                            .lineLimit(1)

                        Text(portfolio.repositoryName)
                            .font(ResonanceTypography.subheadingSystem)
                            .foregroundColor(ResonanceColors.textMain)
                            .lineLimit(1)
                    }

                    Spacer()

                    IndicatorLight(status: portfolio.backupStatus, size: 8)
                }

                // Description
                Text(portfolio.repositoryDescription)
                    .font(ResonanceTypography.bodySystem)
                    .foregroundColor(ResonanceColors.textMuted)
                    .lineLimit(2)

                // Language bar
                HStack(spacing: 4) {
                    ForEach(portfolio.languages.prefix(4)) { lang in
                        HStack(spacing: 2) {
                            Circle()
                                .fill(languageColor(lang.language))
                                .frame(width: 8, height: 8)
                            Text(lang.language)
                                .font(ResonanceTypography.captionSystem)
                                .foregroundColor(ResonanceColors.textLight)
                        }
                    }
                    Spacer()
                }

                Divider().opacity(0.3)

                // Bottom stats
                HStack {
                    Label("\(portfolio.fileCount)", systemImage: "doc")
                    Spacer()
                    Label(formatBytes(portfolio.totalSize), systemImage: "internaldrive")
                    Spacer()
                    Label(portfolio.lastSyncDate.formatted(.dateTime.month().day()),
                          systemImage: "clock")
                }
                .font(ResonanceTypography.captionSystem)
                .foregroundColor(ResonanceColors.textMuted)

                // File Slots Preview
                if !portfolio.fileSlots.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(portfolio.fileSlots.prefix(3)) { slot in
                            Text(slot.name)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(portfolio.accentColor.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        if portfolio.fileSlots.count > 3 {
                            Text("+\(portfolio.fileSlots.count - 3)")
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(ResonanceColors.textLight)
                        }
                    }
                }
            }
            .padding(ResonanceSpacing.md)
        }
    }

    func languageColor(_ lang: String) -> Color {
        switch lang.lowercased() {
        case "swift": return .orange
        case "python": return .blue
        case "javascript": return .yellow
        case "typescript": return Color(hex: "3178C6")
        case "rust": return Color(hex: "DEA584")
        case "go": return Color(hex: "00ADD8")
        case "dart": return Color(hex: "0175C2")
        case "ruby": return .red
        default: return .gray
        }
    }

    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Portfolio List Row

struct PortfolioListRow: View {
    let portfolio: Portfolio

    var body: some View {
        HStack(spacing: ResonanceSpacing.md) {
            IndicatorLight(status: portfolio.backupStatus, size: 6)

            Text(portfolio.logoEmoji)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(portfolio.displayCallsign)
                    .font(ResonanceTypography.callsignFont)
                    .foregroundColor(portfolio.accentColor)
                    .tracking(1)

                Text(portfolio.repositoryDescription)
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textMuted)
                    .lineLimit(1)
            }

            Spacer()

            Text(portfolio.primaryLanguage)
                .font(ResonanceTypography.captionSystem)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(portfolio.accentColor.opacity(0.12))
                .clipShape(Capsule())

            Text(portfolio.lastSyncDate.formatted(.dateTime.month().day().hour().minute()))
                .font(ResonanceTypography.monoFont)
                .foregroundColor(ResonanceColors.textLight)
        }
        .padding(ResonanceSpacing.sm)
        .glassPanel()
    }
}
