// SocialStudioView.swift
// Haute Lumière — Branded Social Media Studio
//
// A luxurious creative studio for crafting postable content.
// Every piece carries the Haute Lumière brand in the lower left.
// Selfies, profound questions, weekly highlights — all designed
// to be immediately shareable on Pinterest, Instagram, and Facebook.
// This is a status symbol. The posts should make people ask "what app is that?"

import SwiftUI

struct SocialStudioView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine

    @State private var selectedFormat: StudioFormat = .instagramStory
    @State private var selectedTemplate: StudioTemplate = .profoundQuestion
    @State private var customText = ""
    @State private var showExportSheet = false

    private var palette: HLColorPalette { appState.selectedColorPalette }

    var body: some View {
        ZStack {
            DarkLaceBackground(palette: palette)

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Header
                    studioHeader

                    // Format selector (Story / Square / Pinterest)
                    formatSelector

                    // Live Preview
                    livePreview
                        .hlBrandWatermark(palette: palette)

                    // Template selector
                    templateSelector

                    // Export buttons
                    exportSection

                    // Recent creations
                    recentCreations

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, HLSpacing.lg)
                .padding(.top, HLSpacing.md)
            }
        }
        .navigationTitle("Studio")
    }

    // MARK: - Header
    private var studioHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Studio")
                .font(HLTypography.serifMedium(28))
                .foregroundColor(palette.textPrimary)
            Text("Create something worth sharing")
                .font(HLTypography.caption)
                .foregroundColor(palette.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Format Selector
    private var formatSelector: some View {
        HStack(spacing: HLSpacing.sm) {
            ForEach(StudioFormat.allCases, id: \.self) { format in
                Button(action: { selectedFormat = format }) {
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedFormat == format ? palette.accentPrimary : palette.cardFill)
                            .frame(width: format.previewWidth, height: format.previewHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(selectedFormat == format ? palette.accentPrimary : palette.textSecondary.opacity(0.3), lineWidth: 1)
                            )

                        Text(format.rawValue)
                            .font(HLTypography.caption)
                            .foregroundColor(selectedFormat == format ? palette.accentPrimary : palette.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Live Preview
    private var livePreview: some View {
        ZStack {
            // Background based on template
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [palette.bgDeep, palette.bgMid, palette.bgSurface.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Decorative lace overlay
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .fill(palette.diaryLaceOverlay)

            // Content
            VStack(spacing: HLSpacing.lg) {
                Spacer()

                switch selectedTemplate {
                case .profoundQuestion:
                    profoundQuestionContent
                case .weeklyHighlight:
                    weeklyHighlightContent
                case .selfieQuote:
                    selfieQuoteContent
                case .journalExcerpt:
                    journalExcerptContent
                case .coachWisdom:
                    coachWisdomContent
                }

                Spacer()

                // Brand watermark — always lower-left
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "light.max")
                            .font(.system(size: 10, weight: .ultraLight))
                        Text("Haute Lumière")
                            .font(HLTypography.serifLight(12))
                    }
                    .foregroundColor(palette.accentPrimary.opacity(0.6))

                    Spacer()
                }
                .padding(.horizontal, HLSpacing.md)
                .padding(.bottom, HLSpacing.md)
            }
        }
        .frame(height: selectedFormat.canvasHeight)
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .stroke(palette.accentPrimary.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HLRadius.xl))
    }

    // MARK: - Template Content

    private var profoundQuestionContent: some View {
        VStack(spacing: HLSpacing.md) {
            Image(systemName: "quote.opening")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(palette.accentPrimary.opacity(0.5))

            Text("What cage are you decorating instead of leaving?")
                .font(HLTypography.serifMedium(22))
                .foregroundColor(palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, HLSpacing.xl)
        }
    }

    private var weeklyHighlightContent: some View {
        VStack(spacing: HLSpacing.md) {
            Text("This Week")
                .font(HLTypography.serifLight(14))
                .foregroundColor(palette.accentPrimary)

            Text("7")
                .font(HLTypography.serifLight(64))
                .foregroundColor(palette.textPrimary)

            Text("days of presence")
                .font(HLTypography.serifLight(18))
                .foregroundColor(palette.textSecondary)

            Rectangle()
                .fill(palette.accentPrimary.opacity(0.3))
                .frame(width: 40, height: 0.5)

            Text("240 minutes of practice")
                .font(HLTypography.caption)
                .foregroundColor(palette.textSecondary)
        }
    }

    private var selfieQuoteContent: some View {
        VStack(spacing: HLSpacing.md) {
            // Selfie placeholder
            ZStack {
                Circle()
                    .fill(palette.cardFill)
                    .frame(width: 120, height: 120)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(palette.textSecondary.opacity(0.3))
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: [palette.accentPrimary, palette.accentLight, palette.accentPrimary], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 2
                    )
            )

            Text("\"The soul becomes dyed with the color of its thoughts.\"")
                .font(HLTypography.serifItalic(16))
                .foregroundColor(palette.textPrimary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.lg)

            Text("— Marcus Aurelius")
                .font(HLTypography.caption)
                .foregroundColor(palette.textSecondary)
        }
    }

    private var journalExcerptContent: some View {
        VStack(spacing: HLSpacing.md) {
            Rectangle()
                .fill(palette.accentPrimary.opacity(0.3))
                .frame(width: 30, height: 0.5)

            Text("Growth sometimes means letting the shape of things change.")
                .font(HLTypography.serifRegular(20))
                .foregroundColor(palette.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, HLSpacing.xl)

            Rectangle()
                .fill(palette.accentPrimary.opacity(0.3))
                .frame(width: 30, height: 0.5)

            Text("from my journal")
                .font(HLTypography.sansLight(11))
                .foregroundColor(palette.textSecondary)
        }
    }

    private var coachWisdomContent: some View {
        VStack(spacing: HLSpacing.md) {
            // Coach avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: appState.selectedCoach.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: appState.selectedCoach.avatarSymbol)
                    .foregroundColor(.white)
                    .font(.system(size: 18))
            }

            Text(appState.selectedCoach.displayName)
                .font(HLTypography.caption)
                .foregroundColor(palette.accentPrimary)

            Text("\"Your consistency is building something beautiful — and the fact that you can't see it yet doesn't mean it isn't real.\"")
                .font(HLTypography.serifItalic(16))
                .foregroundColor(palette.textPrimary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, HLSpacing.lg)
        }
    }

    // MARK: - Template Selector
    private var templateSelector: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Template")
                .font(HLTypography.label)
                .foregroundColor(palette.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(StudioTemplate.allCases, id: \.self) { template in
                        Button(action: { selectedTemplate = template }) {
                            VStack(spacing: 6) {
                                Image(systemName: template.icon)
                                    .font(.system(size: 18))
                                Text(template.rawValue)
                                    .font(HLTypography.caption)
                            }
                            .foregroundColor(selectedTemplate == template ? palette.accentPrimary : palette.textSecondary)
                            .frame(width: 80, height: 64)
                            .background(
                                RoundedRectangle(cornerRadius: HLRadius.md)
                                    .fill(selectedTemplate == template ? palette.accentPrimary.opacity(0.1) : palette.cardFill)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: HLRadius.md)
                                    .stroke(selectedTemplate == template ? palette.accentPrimary.opacity(0.4) : .clear, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Export Section
    private var exportSection: some View {
        VStack(spacing: HLSpacing.sm) {
            // Primary share button
            Button(action: { showExportSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .font(HLTypography.sansMedium(15))
                }
                .foregroundColor(palette.bgDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(palette.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
            }

            // Platform-specific buttons
            HStack(spacing: HLSpacing.sm) {
                platformButton(name: "Instagram", icon: "camera.circle.fill")
                platformButton(name: "Pinterest", icon: "pin.circle.fill")
                platformButton(name: "Facebook", icon: "person.2.circle.fill")
            }
        }
    }

    private func platformButton(name: String, icon: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(name)
                    .font(HLTypography.caption)
            }
            .foregroundColor(palette.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(palette.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.md))
        }
    }

    // MARK: - Recent Creations
    private var recentCreations: some View {
        VStack(alignment: .leading, spacing: HLSpacing.sm) {
            Text("Recent Creations")
                .font(HLTypography.label)
                .foregroundColor(palette.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: HLRadius.md)
                            .fill(
                                LinearGradient(
                                    colors: [palette.bgDeep, palette.bgMid],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 140)
                            .overlay(
                                VStack {
                                    Image(systemName: "quote.opening")
                                        .font(.system(size: 12, weight: .ultraLight))
                                        .foregroundColor(palette.accentPrimary.opacity(0.5))
                                    Spacer()
                                    HStack {
                                        Text("HL")
                                            .font(.system(size: 8, weight: .light))
                                            .foregroundColor(palette.accentPrimary.opacity(0.4))
                                        Spacer()
                                    }
                                }
                                .padding(8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: HLRadius.md)
                                    .stroke(palette.accentPrimary.opacity(0.15), lineWidth: 0.5)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - Studio Models

enum StudioFormat: String, CaseIterable {
    case instagramStory = "Story"
    case instagramSquare = "Square"
    case pinterestPin = "Pin"

    var previewWidth: CGFloat {
        switch self {
        case .instagramStory: return 18
        case .instagramSquare: return 24
        case .pinterestPin: return 16
        }
    }

    var previewHeight: CGFloat {
        switch self {
        case .instagramStory: return 32
        case .instagramSquare: return 24
        case .pinterestPin: return 28
        }
    }

    var canvasHeight: CGFloat {
        switch self {
        case .instagramStory: return 520
        case .instagramSquare: return 340
        case .pinterestPin: return 460
        }
    }

    var exportSize: CGSize {
        switch self {
        case .instagramStory: return CGSize(width: 1080, height: 1920)
        case .instagramSquare: return CGSize(width: 1080, height: 1080)
        case .pinterestPin: return CGSize(width: 1000, height: 1500)
        }
    }
}

enum StudioTemplate: String, CaseIterable {
    case profoundQuestion = "Question"
    case weeklyHighlight = "Weekly"
    case selfieQuote = "Selfie"
    case journalExcerpt = "Journal"
    case coachWisdom = "Coach"

    var icon: String {
        switch self {
        case .profoundQuestion: return "questionmark.circle"
        case .weeklyHighlight: return "chart.bar.fill"
        case .selfieQuote: return "camera.fill"
        case .journalExcerpt: return "text.quote"
        case .coachWisdom: return "sparkles"
        }
    }
}
