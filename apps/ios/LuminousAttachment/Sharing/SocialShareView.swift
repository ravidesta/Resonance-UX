// SocialShareView.swift
// Luminous Attachment — Resonance UX
// Share card generator with platform-specific sharing via URL schemes

import SwiftUI

struct SocialShareView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(UserProfile.self) private var profile

    @State private var selectedType: ShareCardType = .quote
    @State private var selectedBackground: ShareCardBackground = .greenGradient
    @State private var cardTitle: String = ""
    @State private var cardBody: String = ""
    @State private var showActivitySheet = false
    @State private var renderedImage: UIImage?
    @State private var showPlatformPicker = false

    private let quotes: [String] = [
        "Your attachment style is not your destiny. It is your starting point.",
        "Healing is not linear. Some days you plant seeds; other days you water them.",
        "Secure attachment is not the absence of fear. It is the presence of trust.",
        "You are allowed to outgrow the coping mechanisms that once saved you.",
        "Vulnerability is not weakness. It is the birthplace of connection.",
        "The way you were loved as a child is not a verdict. It is a chapter.",
        "Repair matters more than perfection in love.",
        "Your body keeps the score, but it also keeps the compass.",
    ]

    var body: some View {
        let scheme = theme.effectiveScheme
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection(scheme: scheme)
                typeSelector(scheme: scheme)
                cardPreview(scheme: scheme)
                backgroundSelector(scheme: scheme)
                contentEditor(scheme: scheme)
                shareActions(scheme: scheme)
                platformButtons(scheme: scheme)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(theme.background(for: scheme).ignoresSafeArea())
        .navigationTitle("Share")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showActivitySheet) {
            if let image = renderedImage {
                ActivityViewController(activityItems: [
                    image,
                    "\(cardBody)\n\n— Luminous Attachment by Resonance UX\nhttps://luminousattachment.com"
                ])
            }
        }
        .onAppear {
            populateDefaultContent()
        }
    }

    // MARK: - Header

    @ViewBuilder
    private func headerSection(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create & Share")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(ResonanceColors.text(for: scheme))
            Text("Design beautiful cards to share your healing journey")
                .font(.subheadline)
                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    // MARK: - Type Selector

    @ViewBuilder
    private func typeSelector(scheme: ColorScheme) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ShareCardType.allCases, id: \.rawValue) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                            populateDefaultContent()
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(
                                            selectedType == type
                                                ? ResonanceColors.goldPrimary.opacity(0.2)
                                                : ResonanceColors.surfaceSecondary(for: scheme)
                                        )
                                )
                                .foregroundStyle(
                                    selectedType == type
                                        ? ResonanceColors.goldPrimary
                                        : ResonanceColors.textSecondary(for: scheme)
                                )
                            Text(type.rawValue)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(
                                    selectedType == type
                                        ? ResonanceColors.goldPrimary
                                        : ResonanceColors.textSecondary(for: scheme)
                                )
                        }
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Card Preview

    @ViewBuilder
    private func cardPreview(scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ResonanceColors.goldPrimary)
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            shareCardView
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 16, y: 8)
        }
    }

    @ViewBuilder
    private var shareCardView: some View {
        ZStack {
            // Background
            selectedBackground.gradient

            // Content overlay
            VStack(spacing: 16) {
                Spacer()

                // Type badge
                HStack(spacing: 6) {
                    Image(systemName: selectedType.icon)
                        .font(.caption)
                    Text(selectedType.rawValue.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                }
                .foregroundStyle(selectedBackground.textColor.opacity(0.7))

                // Title
                if !cardTitle.isEmpty {
                    Text(cardTitle)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(selectedBackground.textColor)
                        .multilineTextAlignment(.center)
                }

                // Body
                Text(cardBody.isEmpty ? "Your message here..." : cardBody)
                    .font(.body.weight(.medium).leading(.loose))
                    .foregroundStyle(selectedBackground.textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                // Attribution
                HStack(spacing: 8) {
                    // Logo placeholder
                    ZStack {
                        Circle()
                            .fill(selectedBackground.textColor.opacity(0.2))
                            .frame(width: 24, height: 24)
                        Image(systemName: "leaf.fill")
                            .font(.caption2)
                            .foregroundStyle(selectedBackground.textColor)
                    }
                    Text("Luminous Attachment")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(selectedBackground.textColor.opacity(0.6))
                    Spacer()
                    Text("resonance-ux.com")
                        .font(.caption2)
                        .foregroundStyle(selectedBackground.textColor.opacity(0.4))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Background Selector

    @ViewBuilder
    private func backgroundSelector(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Background")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ResonanceColors.goldPrimary)
                .textCase(.uppercase)
                .tracking(1)

            HStack(spacing: 12) {
                ForEach(ShareCardBackground.allCases, id: \.rawValue) { bg in
                    Button {
                        withAnimation { selectedBackground = bg }
                    } label: {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(bg.gradient)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(
                                            selectedBackground == bg
                                                ? ResonanceColors.goldPrimary
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            Text(bg.rawValue)
                                .font(.caption2)
                                .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Content Editor

    @ViewBuilder
    private func contentEditor(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ResonanceColors.goldPrimary)
                .textCase(.uppercase)
                .tracking(1)

            TextField("Title (optional)", text: $cardTitle)
                .font(.headline)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ResonanceColors.surface(for: scheme))
                )

            TextEditor(text: $cardBody)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ResonanceColors.surface(for: scheme))
                )

            // Quick-fill suggestions
            if selectedType == .quote {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(quotes.prefix(4).enumerated()), id: \.offset) { _, quote in
                            Button {
                                cardBody = quote
                            } label: {
                                Text(String(quote.prefix(40)) + "...")
                                    .font(.caption2)
                                    .lineLimit(1)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(ResonanceColors.surfaceSecondary(for: scheme))
                                    )
                                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Share Actions

    @ViewBuilder
    private func shareActions(scheme: ColorScheme) -> some View {
        VStack(spacing: 12) {
            // Main share button
            Button {
                renderAndShare()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Card")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(ResonanceColors.green900)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [ResonanceColors.goldPrimary, ResonanceColors.goldLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(.plain)

            // Copy text button
            Button {
                UIPasteboard.general.string = "\(cardTitle.isEmpty ? "" : cardTitle + "\n\n")\(cardBody)\n\n— Luminous Attachment"
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Text")
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(ResonanceColors.goldPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(ResonanceColors.goldPrimary.opacity(0.1))
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Platform Buttons

    @ViewBuilder
    private func platformButtons(scheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share to")
                .font(.caption.weight(.semibold))
                .foregroundStyle(ResonanceColors.goldPrimary)
                .textCase(.uppercase)
                .tracking(1)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                PlatformShareButton(name: "Instagram", icon: "camera", color: Color(hex: "E1306C"), scheme: scheme) {
                    shareToInstagram()
                }
                PlatformShareButton(name: "Threads", icon: "at", color: Color(hex: "000000"), scheme: scheme) {
                    shareViaPlatform(scheme: "threads://")
                }
                PlatformShareButton(name: "X", icon: "bird", color: Color(hex: "1DA1F2"), scheme: scheme) {
                    shareToX()
                }
                PlatformShareButton(name: "WhatsApp", icon: "message", color: Color(hex: "25D366"), scheme: scheme) {
                    shareToWhatsApp()
                }
                PlatformShareButton(name: "Telegram", icon: "paperplane", color: Color(hex: "0088CC"), scheme: scheme) {
                    shareToTelegram()
                }
                PlatformShareButton(name: "Messages", icon: "bubble.left", color: .green, scheme: scheme) {
                    shareViaMessages()
                }
                PlatformShareButton(name: "Email", icon: "envelope", color: .blue, scheme: scheme) {
                    shareViaEmail()
                }
                PlatformShareButton(name: "More", icon: "ellipsis", color: ResonanceColors.goldPrimary, scheme: scheme) {
                    renderAndShare()
                }
            }
        }
    }

    // MARK: - Rendering & Sharing

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content: shareCardView.frame(width: 390, height: 320))
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            renderedImage = image
            showActivitySheet = true
        }
    }

    @MainActor
    private func renderImage() -> UIImage? {
        let renderer = ImageRenderer(content: shareCardView.frame(width: 390, height: 320))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }

    private func shareToInstagram() {
        // Instagram Stories sharing via URL scheme
        guard let url = URL(string: "instagram-stories://share"),
              UIApplication.shared.canOpenURL(url) else {
            renderAndShare()
            return
        }

        if let image = renderImage(),
           let imageData = image.pngData() {
            let pasteboardItems: [[String: Any]] = [[
                "com.instagram.sharedSticker.backgroundImage": imageData,
                "com.instagram.sharedSticker.backgroundTopColor": "#0A1C14",
                "com.instagram.sharedSticker.backgroundBottomColor": "#122E21"
            ]]
            let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
                .expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(url)
        }
    }

    private func shareToX() {
        let text = "\(cardBody)\n\n— Luminous Attachment\nhttps://luminousattachment.com"
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "twitter://post?message=\(encoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let webURL = URL(string: "https://twitter.com/intent/tweet?text=\(encoded)") {
            UIApplication.shared.open(webURL)
        }
    }

    private func shareToWhatsApp() {
        let text = "\(cardTitle.isEmpty ? "" : "*\(cardTitle)*\n\n")\(cardBody)\n\n_— Luminous Attachment_\nhttps://luminousattachment.com"
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "whatsapp://send?text=\(encoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            renderAndShare()
        }
    }

    private func shareToTelegram() {
        let text = "\(cardBody)\n\n— Luminous Attachment\nhttps://luminousattachment.com"
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "tg://msg?text=\(encoded)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            renderAndShare()
        }
    }

    private func shareViaMessages() {
        let text = "\(cardBody)\n\n— Luminous Attachment"
        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:&body=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }

    private func shareViaEmail() {
        let subject = cardTitle.isEmpty ? "From Luminous Attachment" : cardTitle
        let body = "\(cardBody)\n\n— Luminous Attachment by Resonance UX\nhttps://luminousattachment.com"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "mailto:?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }

    private func shareViaPlatform(scheme: String) {
        if let url = URL(string: scheme),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            renderAndShare()
        }
    }

    private func populateDefaultContent() {
        switch selectedType {
        case .quote:
            cardTitle = ""
            cardBody = quotes.randomElement() ?? quotes[0]
        case .insight:
            let insight = InsightsProvider.insightOfTheDay()
            cardTitle = "Daily Insight"
            cardBody = insight.text
        case .progress:
            cardTitle = "My Healing Journey"
            cardBody = "Day \(profile.currentStreak) of my attachment healing journey. \(profile.completedChapters.count) chapters explored, \(profile.totalJournalEntries) reflections written. Growth is quiet but persistent."
        case .journalExcerpt:
            cardTitle = "From My Journal"
            cardBody = "Share a meaningful excerpt from your journal here..."
        case .coachWisdom:
            cardTitle = "Wisdom from My Coach"
            cardBody = "Every attachment pattern you carry was once a brilliant adaptation. Now you have the power to choose new patterns."
        }
    }
}

// MARK: - Platform Share Button

struct PlatformShareButton: View {
    let name: String
    let icon: String
    let color: Color
    let scheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color)
                    )
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(ResonanceColors.textSecondary(for: scheme))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SocialShareView()
    }
    .environment(ThemeManager())
    .environment(UserProfile())
}
