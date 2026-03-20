import SwiftUI

struct SettingsView: View {
    @State private var kopiaPath = "/usr/local/bin/kopia"
    @State private var repoPath = "~/KopiaBackups"
    @State private var schedule = "0 */6 * * *"
    @State private var retention = "30"
    @State private var appflowyPath = "~/AppFlowy"
    @State private var serverUrl = "https://localhost:51515"
    @State private var compression = "zstd-fastest"
    @State private var encryption = "AES256-GCM"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Settings")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Intuitive Defaults")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ResonanceTheme.gold)
                }
                .padding(.bottom, 8)

                // Kopia
                settingGroup("Kopia Backup Engine") {
                    settingRow("Kopia Executable", $kopiaPath)
                    settingRow("Repository Path", $repoPath)
                    settingRow("Snapshot Schedule (Cron)", $schedule)
                    settingRow("Retention (days)", $retention)
                    settingPicker("Compression", selection: $compression,
                                  options: ["zstd-fastest": "ZSTD Fastest", "zstd-better": "ZSTD Better",
                                            "gzip": "GZIP", "none": "None"])
                    settingPicker("Encryption", selection: $encryption,
                                  options: ["AES256-GCM": "AES-256-GCM", "CHACHA20-POLY1305": "ChaCha20-Poly1305"])
                }

                // AppFlowy
                settingGroup("AppFlowy Integration") {
                    settingRow("AppFlowy Data Path", $appflowyPath)
                    settingDisplay("Auto-create Database", "Enabled", color: ResonanceTheme.growthGreen)
                    settingDisplay("Calendar Sync", "Enabled", color: ResonanceTheme.growthGreen)
                    settingDisplay("Auto-generate Slides", "Enabled", color: ResonanceTheme.growthGreen)
                }

                // Server
                settingGroup("Server Configuration") {
                    settingRow("Upload Server URL", $serverUrl)
                    settingDisplay("Auto-analyze Projects", "Enabled", color: ResonanceTheme.growthGreen)
                    settingDisplay("Bitstamp Verification", "openbitstamp.org", color: ResonanceTheme.growthGreen)
                }

                // PDF
                settingGroup("PDF Report Settings (iPad)") {
                    settingDisplay("Report Engine", "PDFKit")
                    settingDisplay("Auto-generate on Sync", "Optional", color: ResonanceTheme.gold)
                    settingDisplay("Include Bitstamp Hashes", "Enabled", color: ResonanceTheme.growthGreen)
                }

                // Save button
                HStack {
                    Spacer()
                    Button("Save & Apply Configuration") {}
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [ResonanceTheme.gold, ResonanceTheme.goldDark],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(10)
                    Spacer()
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }

    // MARK: - Setting Components

    private func settingGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 16)

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

    private func settingRow(_ label: String, _ binding: Binding<String>) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))

            Spacer()

            TextField("", text: binding)
                .textFieldStyle(.plain)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .frame(maxWidth: 280)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.03)).frame(height: 1)
        }
    }

    private func settingPicker(_ label: String, selection: Binding<String>, options: [String: String]) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))

            Spacer()

            Picker("", selection: selection) {
                ForEach(Array(options.keys.sorted()), id: \.self) { key in
                    Text(options[key] ?? key).tag(key)
                }
            }
            .pickerStyle(.menu)
            .tint(.white.opacity(0.7))
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.03)).frame(height: 1)
        }
    }

    private func settingDisplay(_ label: String, _ value: String, color: Color = .white.opacity(0.7)) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))

            Spacer()

            Text(value)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.2))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.03)).frame(height: 1)
        }
    }
}
