// ResultsView.swift
// Luminous Cognitive Styles™ — iOS
// Standalone results view with share/export capabilities

import SwiftUI

struct ResultsView: View {
    let profile: CognitiveProfile
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?

    var body: some View {
        CognitiveSignatureView(profile: profile) {
            renderAndShare()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
                    .foregroundColor(LCSTheme.goldAccent)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        renderAndShare()
                    } label: {
                        Label("Share as Image", systemImage: "photo")
                    }

                    Button {
                        shareAsText()
                    } label: {
                        Label("Share as Text", systemImage: "doc.text")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(LCSTheme.goldAccent)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheetView(items: [image])
            }
        }
    }

    private func renderAndShare() {
        let renderer = ImageRenderer(content: shareableCard)
        renderer.scale = 3.0
        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
        }
    }

    private func shareAsText() {
        let text = generateShareText()
        renderedImage = nil
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }

    // MARK: - Shareable Card (for image export)

    private var shareableCard: some View {
        VStack(spacing: 20) {
            Text("Luminous Cognitive Styles™")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(2)
                .foregroundColor(LCSTheme.goldAccent)

            Text(profile.profileTypeName)
                .font(.title.weight(.bold))
                .foregroundColor(.white)

            RadarChartView(profile: profile, animated: false, size: 200)

            VStack(spacing: 8) {
                ForEach(CognitiveDimension.allCases) { dim in
                    HStack {
                        Circle()
                            .fill(dim.color)
                            .frame(width: 8, height: 8)
                        Text(dim.shortName)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 80, alignment: .leading)
                        Text(ScoreFormatter.formatted(profile.score(for: dim)))
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundColor(dim.color)
                        Spacer()
                        Text(ScoreFormatter.poleLabel(dimension: dim, score: profile.score(for: dim)))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding()

            Text("luminouscognitivestyles.com")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(30)
        .frame(width: 400)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LCSTheme.deepNavy)
        )
    }

    private func generateShareText() -> String {
        var lines = ["My Luminous Cognitive Styles™ Profile"]
        lines.append(profile.profileTypeName)
        lines.append("")
        for dim in CognitiveDimension.allCases {
            let score = profile.score(for: dim)
            let pole = ScoreFormatter.poleLabel(dimension: dim, score: score)
            lines.append("\(dim.name): \(ScoreFormatter.formatted(score)) (\(pole))")
        }
        lines.append("")
        lines.append(profile.profileSummary)
        return lines.joined(separator: "\n")
    }
}

// MARK: - Share Sheet

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
