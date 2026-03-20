// MARK: - Social Media Shareable Templates
// Pre-designed templates for every platform: stories, reels, posts, carousels.
// "Wanton sharing of beautiful things" — every share is free advertising.

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Template Library

enum ShareTemplate: String, CaseIterable {
    // Instagram
    case instagramQuoteCard     = "Instagram Quote Card"        // 1:1 1080x1080
    case instagramStoryQuote    = "Instagram Story Quote"       // 9:16 1080x1920
    case instagramCarousel      = "Instagram Carousel"          // 1:1 multi-slide
    case instagramReelCover     = "Instagram Reel Cover"        // 9:16

    // X / Twitter
    case twitterQuoteCard       = "X Quote Card"                // 16:9 1200x675
    case twitterThread          = "X Thread Cards"              // Multi-card series

    // Threads
    case threadsQuoteCard       = "Threads Quote"               // 1:1

    // LinkedIn
    case linkedinInsight         = "LinkedIn Insight"            // 1.91:1 1200x627
    case linkedinDocument        = "LinkedIn Document"           // PDF carousel

    // Pinterest
    case pinterestPin            = "Pinterest Pin"              // 2:3 1000x1500

    // TikTok
    case tiktokTextOverlay       = "TikTok Text Overlay"        // 9:16

    // Universal
    case universalWidescreen     = "Widescreen"                 // 16:9
    case universalSquare         = "Square"                     // 1:1

    var size: CGSize {
        switch self {
        case .instagramQuoteCard, .instagramCarousel, .threadsQuoteCard, .universalSquare:
            return CGSize(width: 1080, height: 1080)
        case .instagramStoryQuote, .instagramReelCover, .tiktokTextOverlay:
            return CGSize(width: 1080, height: 1920)
        case .twitterQuoteCard, .universalWidescreen:
            return CGSize(width: 1200, height: 675)
        case .twitterThread:
            return CGSize(width: 1200, height: 675)
        case .linkedinInsight:
            return CGSize(width: 1200, height: 627)
        case .linkedinDocument:
            return CGSize(width: 1080, height: 1350)
        case .pinterestPin:
            return CGSize(width: 1000, height: 1500)
        }
    }
}

// MARK: - Template Styles

struct ShareTemplateStyle {
    let template: ShareTemplate
    let backgroundStyle: TemplateBackground
    let quoteStyle: QuoteStyle
    let decorations: [Decoration]

    struct QuoteStyle {
        let fontFamily: String        // "Cormorant Garamond" or "Manrope"
        let fontSizeRatio: CGFloat    // Relative to card width
        let color: String             // Hex
        let alignment: Alignment
        let maxWidthRatio: CGFloat    // 0.0-1.0 of card width
        let lineSpacing: CGFloat

        enum Alignment { case center, leading, trailing }
    }

    enum TemplateBackground {
        case solidColor(hex: String)
        case gradient(colors: [String], angle: Double)
        case image(assetKey: String, overlay: String?, overlayOpacity: Double)
        case pattern(type: PatternType, color: String, opacity: Double)

        enum PatternType {
            case spirals, dots, organicBlobs, paperTexture, waveforms
        }
    }

    enum Decoration {
        case logo(position: Position, opacity: Double)
        case divider(style: DividerStyle, color: String, opacity: Double)
        case attributionLine(text: String, position: Position)
        case seasonBadge(season: String, position: Position)
        case orderIndicator(order: Int, position: Position)
        case organicBlob(color: String, position: Position, size: CGFloat, blur: CGFloat)
        case paperTexture(opacity: Double)
        case borderGlow(color: String, width: CGFloat)
        case hashtags(tags: [String], position: Position)

        enum Position { case topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight, center }
        enum DividerStyle { case line, dots, wave }
    }
}

// MARK: - Pre-Built Template Presets

enum TemplatePresets {

    // ─── Forest Gold (Hero style) ────────────────────────────────

    static let forestGoldSquare = ShareTemplateStyle(
        template: .instagramQuoteCard,
        backgroundStyle: .gradient(colors: ["#0A1C14", "#1B402E"], angle: 135),
        quoteStyle: .init(
            fontFamily: "Cormorant Garamond",
            fontSizeRatio: 0.045,
            color: "#FAFAF8",
            alignment: .center,
            maxWidthRatio: 0.75,
            lineSpacing: 8
        ),
        decorations: [
            .paperTexture(opacity: 0.04),
            .organicBlob(color: "#C5A059", position: .topRight, size: 300, blur: 60),
            .logo(position: .topRight, opacity: 0.4),
            .attributionLine(text: "Luminous Constructive Development™", position: .bottomCenter),
            .divider(style: .line, color: "#C5A059", opacity: 0.2),
        ]
    )

    static let forestGoldStory = ShareTemplateStyle(
        template: .instagramStoryQuote,
        backgroundStyle: .gradient(colors: ["#0A1C14", "#122E21", "#1B402E"], angle: 180),
        quoteStyle: .init(
            fontFamily: "Cormorant Garamond",
            fontSizeRatio: 0.04,
            color: "#FAFAF8",
            alignment: .center,
            maxWidthRatio: 0.8,
            lineSpacing: 10
        ),
        decorations: [
            .paperTexture(opacity: 0.03),
            .organicBlob(color: "#C5A059", position: .topCenter, size: 400, blur: 80),
            .organicBlob(color: "#1B402E", position: .bottomLeft, size: 300, blur: 60),
            .logo(position: .topRight, opacity: 0.3),
            .attributionLine(text: "luminous.journey", position: .bottomCenter),
            .seasonBadge(season: "Emergence", position: .topLeft),
        ]
    )

    // ─── Cream Serif (Elegant, literary) ─────────────────────────

    static let creamSerifSquare = ShareTemplateStyle(
        template: .instagramQuoteCard,
        backgroundStyle: .solidColor(hex: "#FAFAF8"),
        quoteStyle: .init(
            fontFamily: "Cormorant Garamond",
            fontSizeRatio: 0.05,
            color: "#1B402E",
            alignment: .center,
            maxWidthRatio: 0.7,
            lineSpacing: 8
        ),
        decorations: [
            .paperTexture(opacity: 0.05),
            .divider(style: .dots, color: "#C5A059", opacity: 0.3),
            .attributionLine(text: "Luminous Constructive Development™", position: .bottomCenter),
            .borderGlow(color: "#C5A059", width: 1),
        ]
    )

    // ─── Deep Rest Glow (Night mode) ─────────────────────────────

    static let deepRestSquare = ShareTemplateStyle(
        template: .instagramQuoteCard,
        backgroundStyle: .gradient(colors: ["#050E09", "#0A1C14"], angle: 180),
        quoteStyle: .init(
            fontFamily: "Cormorant Garamond",
            fontSizeRatio: 0.042,
            color: "#C8D4CC",
            alignment: .center,
            maxWidthRatio: 0.78,
            lineSpacing: 8
        ),
        decorations: [
            .organicBlob(color: "#C5A059", position: .center, size: 250, blur: 100),
            .attributionLine(text: "Luminous Constructive Development™", position: .bottomCenter),
        ]
    )

    // ─── Somatic Wave (Purple/blue tones) ────────────────────────

    static let somaticWaveSquare = ShareTemplateStyle(
        template: .instagramQuoteCard,
        backgroundStyle: .gradient(colors: ["#1A1A2E", "#16213E", "#0F3460"], angle: 160),
        quoteStyle: .init(
            fontFamily: "Cormorant Garamond",
            fontSizeRatio: 0.042,
            color: "#E8DFD0",
            alignment: .center,
            maxWidthRatio: 0.78,
            lineSpacing: 8
        ),
        decorations: [
            .organicBlob(color: "#8B6BB0", position: .topRight, size: 250, blur: 70),
            .organicBlob(color: "#5A8AB0", position: .bottomLeft, size: 200, blur: 60),
            .attributionLine(text: "Luminous Constructive Development™", position: .bottomCenter),
        ]
    )

    // ─── Spiral Pattern (Developmental theme) ────────────────────

    static let spiralSquare = ShareTemplateStyle(
        template: .instagramQuoteCard,
        backgroundStyle: .gradient(colors: ["#1B402E", "#2A5A42"], angle: 135),
        quoteStyle: .init(
            fontFamily: "Cormorant Garamond",
            fontSizeRatio: 0.044,
            color: "#FAFAF8",
            alignment: .center,
            maxWidthRatio: 0.75,
            lineSpacing: 8
        ),
        decorations: [
            .pattern(type: .spirals, color: "#C5A059", opacity: 0.06),
            .logo(position: .topRight, opacity: 0.3),
            .attributionLine(text: "Luminous Constructive Development™", position: .bottomCenter),
            .borderGlow(color: "#C5A059", width: 2),
        ]
    )

    // ─── Carousel: Five Orders ───────────────────────────────────

    static func fiveOrdersCarousel() -> [ShareTemplateStyle] {
        let orders: [(String, String, String, String)] = [
            ("Impulsive Mind", "#E8A87C", "Radical presence", "1st Order"),
            ("Imperial Mind", "#D4956B", "Purposeful action", "2nd Order"),
            ("Socialized Mind", "#5A8AB0", "Deep empathy", "3rd Order"),
            ("Self-Authoring Mind", "#4A9A6A", "Principled autonomy", "4th Order"),
            ("Self-Transforming Mind", "#8B6BB0", "Paradox-friendliness", "5th Order"),
        ]

        return orders.map { name, color, gift, label in
            ShareTemplateStyle(
                template: .instagramCarousel,
                backgroundStyle: .gradient(colors: ["#0A1C14", "#1B402E"], angle: 135),
                quoteStyle: .init(
                    fontFamily: "Cormorant Garamond",
                    fontSizeRatio: 0.05,
                    color: "#FAFAF8",
                    alignment: .center,
                    maxWidthRatio: 0.75,
                    lineSpacing: 6
                ),
                decorations: [
                    .organicBlob(color: color, position: .center, size: 300, blur: 80),
                    .orderIndicator(order: orders.firstIndex(where: { $0.0 == name })! + 1, position: .topLeft),
                    .attributionLine(text: "Gift: \(gift)", position: .bottomCenter),
                ]
            )
        }
    }

    // ─── Milestone Cards ─────────────────────────────────────────

    static func milestoneCard(type: String) -> ShareTemplateStyle {
        ShareTemplateStyle(
            template: .instagramQuoteCard,
            backgroundStyle: .gradient(colors: ["#1B402E", "#C5A059"], angle: 135),
            quoteStyle: .init(
                fontFamily: "Manrope",
                fontSizeRatio: 0.035,
                color: "#FAFAF8",
                alignment: .center,
                maxWidthRatio: 0.8,
                lineSpacing: 6
            ),
            decorations: [
                .pattern(type: .spirals, color: "#FAFAF8", opacity: 0.04),
                .logo(position: .topCenter, opacity: 0.5),
                .attributionLine(text: "Luminous Journey", position: .bottomCenter),
            ]
        )
    }

    // ─── All Presets ─────────────────────────────────────────────

    static let allSquarePresets: [ShareTemplateStyle] = [
        forestGoldSquare,
        creamSerifSquare,
        deepRestSquare,
        somaticWaveSquare,
        spiralSquare,
    ]

    static let allStoryPresets: [ShareTemplateStyle] = [
        forestGoldStory,
    ]
}

// MARK: - Shareable Content Generator

struct ShareableContentGenerator {

    /// Generate a shareable quote card from a book highlight
    static func fromHighlight(text: String, chapter: Int, style: ShareTemplate = .instagramQuoteCard) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .highlight,
            title: "Chapter \(chapter)",
            excerpt: text,
            attributionLine: "Luminous Constructive Development™",
            backgroundStyle: .forestGold,
            sourceChapter: chapter,
            generatedImageKey: nil,
            deepLink: "https://luminous.journey/share/highlight"
        )
    }

    /// Generate a practice completion shareable
    static func fromPracticeCompletion(practiceName: String, duration: String, streak: Int) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .practiceCompletion,
            title: practiceName,
            excerpt: "Completed \(practiceName) (\(duration)) — \(streak)-day practice streak",
            attributionLine: "Luminous Journey",
            backgroundStyle: .somaticWave,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "https://luminous.journey/share/practice"
        )
    }

    /// Generate a season transition shareable
    static func fromSeasonTransition(from: String, to: String) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .milestone,
            title: "Season Transition",
            excerpt: "Moving from \(from) into \(to). The body knows before the mind.",
            attributionLine: "Luminous Journey",
            backgroundStyle: .spiralPattern,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "https://luminous.journey/share/season"
        )
    }

    /// Generate a reflection shareable from journal
    static func fromReflection(excerpt: String, mood: String?) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .reflection,
            title: "A Reflection",
            excerpt: excerpt,
            attributionLine: "From a Luminous Journey",
            backgroundStyle: .creamSerif,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "https://luminous.journey/share/reflection"
        )
    }

    /// Generate an assessment milestone shareable
    static func fromAssessmentComplete(primaryOrder: String, season: String) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .milestone,
            title: "Developmental Assessment Complete",
            excerpt: "Mapped my meaning-making landscape. Primary resonance: \(primaryOrder). Season: \(season). These are snapshots, not verdicts.",
            attributionLine: "Luminous Constructive Development™",
            backgroundStyle: .forestGold,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "https://luminous.journey/share/assessment"
        )
    }

    /// Generate a glossary term shareable
    static func fromGlossaryTerm(term: String, definition: String) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .quote,
            title: term,
            excerpt: "\(term) — \(definition)",
            attributionLine: "Luminous Constructive Development™ Glossary",
            backgroundStyle: .creamSerif,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "https://luminous.journey/share/glossary"
        )
    }
}
