import SwiftUI

struct ReportPreviewView: View {
    let repos: [Repository]

    private var todayFormatted: String {
        Date().formatted(.dateTime.year().month(.wide).day())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Report Preview")
                            .font(.system(size: 24, weight: .light, design: .serif))
                            .foregroundColor(.white.opacity(0.9))
                        Text("PDFKit")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(ResonanceTheme.gold)
                    }
                    Spacer()
                    Button("Export PDF") {}
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

                // Report paper
                VStack(alignment: .leading, spacing: 0) {
                    Text("Resonance GitHub Backup Portal")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundColor(Color(hex: "0A1C14"))
                        .padding(.bottom, 8)

                    Text("Generated: \(todayFormatted) | Portfolios: \(repos.count) | Engine: Kopia + AppFlowy")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "5C7065"))
                        .padding(.bottom, 24)

                    ForEach(repos) { repo in
                        let langs = LanguageDetector.detect(files: repo.files)
                        let hash = BitstampHash.generate(data: repo.name + "\(repo.lastSync)")

                        VStack(alignment: .leading, spacing: 12) {
                            Text(CallsignGenerator.generate(name: repo.name))
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(Color(hex: "1B402E"))
                                .padding(.top, 16)

                            reportRow("Repository", repo.name)
                            reportRow("URL", repo.url)
                            reportRow("Description", repo.description)
                            reportRow("Languages", langs.joined(separator: ", "))
                            reportRow("Files", "\(repo.files.count)")
                            reportRow("Upload Date", repo.uploadDate.formatted(date: .abbreviated, time: .omitted))
                            reportRow("Last Sync", repo.lastSync.formatted(date: .abbreviated, time: .omitted))
                            reportRow("Status", repo.status.displayName)
                            reportRow("Bitstamp Hash", hash, isMono: true)
                            reportRow("Collaborators", repo.collaborators.isEmpty ? "None" : repo.collaborators.joined(separator: ", "))
                            reportRow("Design Files", repo.designFiles.isEmpty ? "None" : repo.designFiles.joined(separator: ", "))
                        }

                        Divider().padding(.vertical, 8)
                    }

                    // System config
                    Text("System Configuration")
                        .font(.system(size: 20, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "1B402E"))
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    reportRow("Backup Engine", "Kopia (encrypted, deduplicated)")
                    reportRow("Database", "AppFlowy (auto-generated slides)")
                    reportRow("Compression", "ZSTD Fastest")
                    reportRow("Encryption", "AES-256-GCM")
                    reportRow("Schedule", "Every 6 hours (0 */6 * * *)")
                    reportRow("Bitstamp Source", "openbitstamp.org")
                }
                .padding(40)
                .background(Color.white.opacity(0.95))
                .cornerRadius(12)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }

    private func reportRow(_ label: String, _ value: String, isMono: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "1B402E"))
                .frame(width: 140, alignment: .leading)

            Text(value)
                .font(isMono ? .system(size: 11, design: .monospaced) : .system(size: 13))
                .foregroundColor(Color(hex: "122E21"))

            Spacer()
        }
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(hex: "E5EBE7")).frame(height: 1)
        }
    }
}
