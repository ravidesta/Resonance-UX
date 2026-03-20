import SwiftUI

struct PortfolioCardView: View {
    let repo: Repository
    let color: Color

    private var callsign: String {
        CallsignGenerator.generate(name: repo.name)
    }

    private var languages: [String] {
        LanguageDetector.detect(files: repo.files)
    }

    var body: some View {
        LivingSurface(glowColor: color) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .top, spacing: 14) {
                    ChromaticOrb(name: repo.name, color: color)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(callsign)
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .tracking(1.5)
                            .foregroundColor(.white.opacity(0.35))
                            .textCase(.uppercase)

                        Text(repo.name)
                            .font(.system(size: 20, weight: .semibold, design: .serif))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    BioIndicator(status: repo.status)
                }
                .padding(.bottom, 16)

                // Description
                Text(repo.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.45))
                    .lineSpacing(4)
                    .padding(.bottom, 12)

                // Language tags
                HStack(spacing: 6) {
                    ForEach(languages.prefix(4), id: \.self) { lang in
                        Text(lang)
                            .font(.system(size: 10, design: .monospaced))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.06))
                            .foregroundColor(.white.opacity(0.5))
                            .cornerRadius(6)
                    }
                }
                .padding(.bottom, 14)

                // Footer
                Divider()
                    .background(Color.white.opacity(0.04))

                HStack {
                    Text(repo.uploadDate, style: .date)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.35))

                    Spacer()

                    HStack(spacing: 4) {
                        Text("\(repo.files.count) files")
                        Text("|").opacity(0.3)
                        Text("\(repo.collaborators.count) collaborator\(repo.collaborators.count != 1 ? "s" : "")")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.35))
                }
                .padding(.top, 12)
            }
        }
    }
}
