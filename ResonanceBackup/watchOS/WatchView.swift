// WatchView.swift
// Resonance UX GitHub Backup — watchOS Companion
// Portfolio status updates, backup notifications, bitstamp confirmations

import SwiftUI

// MARK: - Watch App Entry

struct ResonanceWatchView: View {
    @State var portfolios: [WatchPortfolio] = WatchPortfolio.sampleData
    @State var selectedPortfolio: WatchPortfolio?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RESONANCE")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "C5A059"))
                                .tracking(2)
                            Text("Backup")
                                .font(.system(size: 16, weight: .medium, design: .serif))
                        }
                        Spacer()
                        coherenceGauge
                    }
                    .padding(.horizontal, 4)

                    // Portfolio cards
                    ForEach(portfolios) { portfolio in
                        NavigationLink(value: portfolio) {
                            watchPortfolioCard(portfolio)
                        }
                        .buttonStyle(.plain)
                    }

                    // Quick Actions
                    Button(action: { triggerBackupAll() }) {
                        HStack {
                            Image(systemName: "arrow.up.doc")
                            Text("Backup All")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "59C9A5").opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Portfolios")
            .navigationDestination(for: WatchPortfolio.self) { portfolio in
                watchPortfolioDetail(portfolio)
            }
        }
    }

    // MARK: - Coherence Gauge

    var coherenceGauge: some View {
        let synced = portfolios.filter { $0.status == .synced }.count
        let total = max(portfolios.count, 1)
        let pct = Double(synced) / Double(total)

        return ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                .frame(width: 32, height: 32)

            Circle()
                .trim(from: 0, to: pct)
                .stroke(
                    pct > 0.8 ? Color(hex: "59C9A5") : Color(hex: "F4A261"),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))

            Text("\(Int(pct * 100))")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
        }
    }

    // MARK: - Portfolio Card

    func watchPortfolioCard(_ portfolio: WatchPortfolio) -> some View {
        HStack(spacing: 8) {
            // Status indicator (bioluminescent)
            Circle()
                .fill(statusColor(portfolio.status))
                .frame(width: 8, height: 8)
                .shadow(color: statusColor(portfolio.status).opacity(0.5), radius: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(portfolio.emoji + " " + portfolio.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                Text(portfolio.language)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(portfolio.status.rawValue)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(statusColor(portfolio.status))

                Text(portfolio.lastSync)
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Portfolio Detail

    func watchPortfolioDetail(_ portfolio: WatchPortfolio) -> some View {
        ScrollView {
            VStack(spacing: 8) {
                // Callsign
                Text("OPERATION : \(portfolio.name.uppercased())")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "C5A059"))
                    .tracking(1)

                // Logo
                Text(portfolio.emoji)
                    .font(.system(size: 36))
                    .padding(8)

                // Status
                HStack {
                    Circle()
                        .fill(statusColor(portfolio.status))
                        .frame(width: 6, height: 6)
                        .shadow(color: statusColor(portfolio.status).opacity(0.6), radius: 3)
                    Text(portfolio.status.rawValue)
                        .font(.system(size: 11, weight: .medium))
                }

                Divider().opacity(0.3)

                // Stats
                VStack(spacing: 4) {
                    watchStat("Language", portfolio.language)
                    watchStat("Files", "\(portfolio.fileCount)")
                    watchStat("Size", portfolio.size)
                    watchStat("Last Sync", portfolio.lastSync)
                }

                // Last bitstamp
                if let bitstamp = portfolio.lastBitstamp {
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "C5A059"))
                            Text("Bitstamp")
                                .font(.system(size: 10, weight: .bold))
                        }
                        Text(bitstamp.prefix(16).description)
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(Color(hex: "C5A059"))
                    }
                    .padding(6)
                    .background(Color(hex: "C5A059").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Actions
                Button(action: {}) {
                    Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(hex: "59C9A5").opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                // Recent changes
                Text("RECENT")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(1)

                ForEach(portfolio.recentChanges, id: \.self) { change in
                    HStack {
                        Circle()
                            .fill(Color(hex: "59C9A5"))
                            .frame(width: 4, height: 4)
                        Text(change)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle(portfolio.name)
    }

    func watchStat(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 10, weight: .medium))
        }
    }

    func statusColor(_ status: BackupStatus) -> Color {
        switch status {
        case .synced: return Color(hex: "59C9A5")
        case .syncing: return Color(hex: "F4A261")
        case .error: return Color(hex: "EF6461")
        case .idle: return Color(hex: "7B8CDE")
        case .queued: return Color(hex: "4ECDC4")
        }
    }

    func triggerBackupAll() {
        // Send WatchConnectivity message to iPhone
    }
}

// MARK: - Watch Portfolio Model (Simplified)

struct WatchPortfolio: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let emoji: String
    let language: String
    let status: BackupStatus
    let lastSync: String
    let fileCount: Int
    let size: String
    let lastBitstamp: String?
    let recentChanges: [String]

    static var sampleData: [WatchPortfolio] {
        [
            WatchPortfolio(name: "Resonance-UX", emoji: "⚡", language: "JavaScript",
                          status: .synced, lastSync: "2h ago", fileCount: 23, size: "82 KB",
                          lastBitstamp: "OBS-a1b2c3d4e5f67890",
                          recentChanges: ["Initial backup", "Synced", "Snapshot created"]),
            WatchPortfolio(name: "AppFlowy", emoji: "🎯", language: "Dart",
                          status: .synced, lastSync: "4h ago", fileCount: 1034, size: "15.2 MB",
                          lastBitstamp: "OBS-f8e7d6c5b4a39012",
                          recentChanges: ["Pulled latest", "Backup complete", "Bitstamp verified"]),
            WatchPortfolio(name: "kopia", emoji: "🐹", language: "Go",
                          status: .syncing, lastSync: "now", fileCount: 1034, size: "9.8 MB",
                          lastBitstamp: nil,
                          recentChanges: ["Syncing...", "Fetching remotes"]),
            WatchPortfolio(name: "design", emoji: "📦", language: "Markdown",
                          status: .synced, lastSync: "1d ago", fileCount: 1, size: "7.6 KB",
                          lastBitstamp: "OBS-1234567890abcdef",
                          recentChanges: ["Design doc updated", "Backup complete"]),
        ]
    }
}
