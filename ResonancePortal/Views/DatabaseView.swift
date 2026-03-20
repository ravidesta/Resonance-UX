import SwiftUI

struct DatabaseView: View {
    let repos: [Repository]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Portfolio Database")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.9))

                    Text("AppFlowy Integration")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ResonanceTheme.gold)
                }

                GlassPanel {
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Header row
                            HStack(spacing: 0) {
                                headerCell("STATUS", width: 60)
                                headerCell("PORTFOLIO", width: 120)
                                headerCell("CALLSIGN", width: 140)
                                headerCell("LANGUAGES", width: 100)
                                headerCell("FILES", width: 50)
                                headerCell("UPLOADED", width: 90)
                                headerCell("LAST SYNC", width: 90)
                                headerCell("COLLABS", width: 60)
                                headerCell("BITSTAMP", width: 110)
                            }
                            .padding(.vertical, 8)
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                            }

                            // Data rows
                            ForEach(repos) { repo in
                                let langs = LanguageDetector.detect(files: repo.files)
                                let hash = BitstampHash.generate(data: repo.name + "\(repo.lastSync)")

                                HStack(spacing: 0) {
                                    HStack {
                                        BioIndicator(status: repo.status)
                                    }
                                    .frame(width: 60)

                                    Text(repo.name)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.85))
                                        .frame(width: 120, alignment: .leading)

                                    Text(CallsignGenerator.generate(name: repo.name).replacingOccurrences(of: "Operation: ", with: "OP:"))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                        .frame(width: 140, alignment: .leading)
                                        .lineLimit(1)

                                    Text(langs.prefix(2).joined(separator: ", "))
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 100, alignment: .leading)

                                    Text("\(repo.files.count)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 50, alignment: .leading)

                                    Text(repo.uploadDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 90, alignment: .leading)

                                    Text(repo.lastSync.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 90, alignment: .leading)

                                    Text("\(repo.collaborators.count)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 60, alignment: .leading)

                                    Text(String(hash.prefix(12)) + "...")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(ResonanceTheme.gold.opacity(0.6))
                                        .frame(width: 110, alignment: .leading)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .overlay(alignment: .bottom) {
                                    Rectangle().fill(Color.white.opacity(0.03)).frame(height: 1)
                                }
                            }
                        }
                        .padding(4)
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }

    private func headerCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .regular, design: .monospaced))
            .tracking(1)
            .foregroundColor(.white.opacity(0.3))
            .frame(width: width, alignment: .leading)
            .padding(.horizontal, 12)
    }
}
