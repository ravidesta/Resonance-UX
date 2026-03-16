// PrintBriefView.swift
// Resonance UX GitHub Backup — Print Brief System
// Uses UI print and project logos to generate a printable brief

import SwiftUI

struct PrintBriefView: View {
    let portfolio: Portfolio

    var body: some View {
        VStack(spacing: 0) {
            briefContent
        }
        .frame(width: 612, height: 792) // US Letter at 72dpi
        .background(Color.white)
    }

    var briefContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header Banner
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("RESONANCE BACKUP")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "C5A059"))
                        .tracking(3)

                    Text("PROJECT BRIEF")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "122E21"))
                }

                Spacer()

                // Project Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(portfolio.accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Text(portfolio.logoEmoji)
                        .font(.system(size: 28))
                }
            }

            // Callsign
            Text(portfolio.displayCallsign)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(portfolio.accentColor)
                .tracking(2)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(portfolio.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Divider()

            // Two-column info
            HStack(alignment: .top, spacing: 24) {
                // Left column
                VStack(alignment: .leading, spacing: 8) {
                    briefField("Repository", portfolio.repositoryName)
                    briefField("Language", portfolio.primaryLanguage)
                    briefField("Upload Date", portfolio.dateOfUpload.formatted(.dateTime.year().month().day()))
                    briefField("Last Sync", portfolio.lastSyncDate.formatted(.dateTime.year().month().day()))
                    briefField("Status", portfolio.backupStatus.rawValue)
                    briefField("Files", "\(portfolio.fileCount)")
                    briefField("Size", formatBytes(portfolio.totalSize))
                }

                // Right column
                VStack(alignment: .leading, spacing: 8) {
                    briefField("Source URL", portfolio.repositoryURL)
                    briefField("Commits", "\(portfolio.commitCount)")
                    briefField("Branches", "\(portfolio.branchCount)")
                    briefField("Collaborators", "\(portfolio.collaborators.count)")
                    briefField("Changelog Entries", "\(portfolio.changelog.count)")

                    if let snapshot = portfolio.kopiaSnapshotID {
                        briefField("Kopia Snapshot", String(snapshot.prefix(16)))
                    }
                }
            }

            Divider()

            // Description
            Text("DESCRIPTION")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .tracking(1)

            Text(portfolio.repositoryDescription)
                .font(.system(size: 10, design: .default))
                .foregroundColor(Color(hex: "122E21"))

            // Languages
            if !portfolio.languages.isEmpty {
                Text("LANGUAGES")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(1)
                    .padding(.top, 4)

                HStack(spacing: 12) {
                    ForEach(portfolio.languages.prefix(6)) { lang in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(portfolio.accentColor)
                                .frame(width: 6, height: 6)
                            Text("\(lang.language) \(Int(lang.percentage))%")
                                .font(.system(size: 9))
                        }
                    }
                }
            }

            // Properties
            Text("PROPERTIES")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .tracking(1)
                .padding(.top, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                ForEach(portfolio.properties) { prop in
                    HStack {
                        Text(prop.key)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(prop.value)
                            .font(.system(size: 9))
                    }
                }
            }

            // File Slots
            if !portfolio.fileSlots.isEmpty {
                Text("FILE SLOTS")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                    .tracking(1)
                    .padding(.top, 4)

                HStack(spacing: 8) {
                    ForEach(portfolio.fileSlots) { slot in
                        VStack(spacing: 2) {
                            Text(slot.name)
                                .font(.system(size: 8, weight: .medium))
                            Text("\(slot.files.count) files")
                                .font(.system(size: 7))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }

            // Bitstamp
            if let lastBitstamp = portfolio.bitstampRecords.last {
                Divider()
                HStack {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "C5A059"))
                    Text("Bitstamp: \(lastBitstamp.bitstampHash)")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color(hex: "C5A059"))
                    Spacer()
                    Text(lastBitstamp.source)
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            // Footer
            HStack {
                Text("Generated by Resonance Backup")
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                Text(Date().formatted())
                    .font(.system(size: 7, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(36)
    }

    func briefField(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label.uppercased())
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "122E21"))
                .lineLimit(2)
        }
    }

    func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}

// MARK: - Print Extension

#if os(macOS)
import AppKit

extension BackupViewModel {
    func printBrief(for portfolio: Portfolio) {
        let printView = NSHostingView(rootView: PrintBriefView(portfolio: portfolio))
        printView.frame = NSRect(x: 0, y: 0, width: 612, height: 792)

        let printInfo = NSPrintInfo.shared
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.isHorizontallyCentered = true
        printInfo.isVerticallyCentered = false

        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.run()
    }
}
#else
extension BackupViewModel {
    func printBrief(for portfolio: Portfolio) {
        // iOS/visionOS: Use UIPrintInteractionController
        // Placeholder for cross-platform print
    }
}
#endif
