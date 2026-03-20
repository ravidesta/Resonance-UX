// MARK: - Social Sharing Service — "Wanton Sharing of Beautiful Things"
// Generates gorgeous, branded share cards for every platform.
// Free advertising through beauty.

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Share Targets

enum SocialPlatform: String, CaseIterable {
    case instagram       = "Instagram"
    case instagramStory  = "Instagram Story"
    case twitter         = "X / Twitter"
    case threads         = "Threads"
    case facebook        = "Facebook"
    case linkedin        = "LinkedIn"
    case pinterest       = "Pinterest"
    case tiktok          = "TikTok"
    case whatsapp        = "WhatsApp"
    case telegram        = "Telegram"
    case signal          = "Signal"
    case imessage        = "iMessage"
    case email           = "Email"
    case clipboard       = "Copy"
    case systemShare     = "More..."

    var supportsImage: Bool {
        switch self {
        case .instagram, .instagramStory, .twitter, .threads, .facebook,
             .linkedin, .pinterest, .tiktok:
            return true
        default:
            return true // All support image attachment
        }
    }

    var preferredAspectRatio: CGSize {
        switch self {
        case .instagramStory, .tiktok:  return CGSize(width: 1080, height: 1920) // 9:16
        case .instagram, .threads:       return CGSize(width: 1080, height: 1080) // 1:1
        case .twitter:                   return CGSize(width: 1200, height: 675)  // 16:9
        case .linkedin:                  return CGSize(width: 1200, height: 627)  // ~1.91:1
        case .pinterest:                 return CGSize(width: 1000, height: 1500) // 2:3
        case .facebook:                  return CGSize(width: 1200, height: 630)  // ~1.91:1
        default:                         return CGSize(width: 1080, height: 1080) // 1:1 default
        }
    }
}

// MARK: - Share Card Generator

struct ShareCardStyle {
    let backgroundStyle: ShareableContent.BackgroundStyle
    let typography: CardTypography
    let layout: CardLayout

    struct CardTypography {
        let quoteFont: String       // Cormorant Garamond
        let attributionFont: String // Manrope
        let quoteFontSize: CGFloat
        let attributionFontSize: CGFloat
    }

    struct CardLayout {
        let padding: CGFloat
        let quoteMaxWidth: CGFloat  // Percentage of card width
        let attributionPosition: AttributionPosition
        let logoPosition: LogoPosition

        enum AttributionPosition { case bottomLeft, bottomCenter, bottomRight }
        enum LogoPosition { case topRight, bottomRight, none }
    }

    // MARK: Preset Styles

    static let forestGold = ShareCardStyle(
        backgroundStyle: .forestGold,
        typography: .init(
            quoteFont: "Cormorant Garamond",
            attributionFont: "Manrope",
            quoteFontSize: 32,
            attributionFontSize: 14
        ),
        layout: .init(
            padding: 48,
            quoteMaxWidth: 0.8,
            attributionPosition: .bottomCenter,
            logoPosition: .topRight
        )
    )

    static let creamSerif = ShareCardStyle(
        backgroundStyle: .creamSerif,
        typography: .init(
            quoteFont: "Cormorant Garamond",
            attributionFont: "Manrope",
            quoteFontSize: 36,
            attributionFontSize: 13
        ),
        layout: .init(
            padding: 56,
            quoteMaxWidth: 0.75,
            attributionPosition: .bottomRight,
            logoPosition: .topRight
        )
    )

    static let deepRestGlow = ShareCardStyle(
        backgroundStyle: .deepRestGlow,
        typography: .init(
            quoteFont: "Cormorant Garamond",
            attributionFont: "Manrope",
            quoteFontSize: 30,
            attributionFontSize: 14
        ),
        layout: .init(
            padding: 48,
            quoteMaxWidth: 0.8,
            attributionPosition: .bottomCenter,
            logoPosition: .none
        )
    )

    static let somaticWave = ShareCardStyle(
        backgroundStyle: .somaticWave,
        typography: .init(
            quoteFont: "Cormorant Garamond",
            attributionFont: "Manrope",
            quoteFontSize: 28,
            attributionFontSize: 14
        ),
        layout: .init(
            padding: 52,
            quoteMaxWidth: 0.78,
            attributionPosition: .bottomLeft,
            logoPosition: .topRight
        )
    )

    static let spiralPattern = ShareCardStyle(
        backgroundStyle: .spiralPattern,
        typography: .init(
            quoteFont: "Cormorant Garamond",
            attributionFont: "Manrope",
            quoteFontSize: 34,
            attributionFontSize: 13
        ),
        layout: .init(
            padding: 50,
            quoteMaxWidth: 0.76,
            attributionPosition: .bottomCenter,
            logoPosition: .topRight
        )
    )
}

// MARK: - Share Service Protocol

protocol SocialShareService {
    /// Generate a shareable card from any content type
    func generateShareCard(
        content: ShareableContent,
        platform: SocialPlatform,
        style: ShareCardStyle?
    ) async throws -> ShareCard

    /// Share directly to a platform
    func share(
        card: ShareCard,
        to platform: SocialPlatform,
        caption: String?
    ) async throws

    /// Generate share text with deep link
    func generateShareText(content: ShareableContent) -> String

    /// Create shareable content from a highlight
    func createFromHighlight(_ highlight: EBook.Highlight, chapter: EBook.EBookChapter) -> ShareableContent

    /// Create shareable content from a journal reflection
    func createFromJournalEntry(_ entry: JournalEntry) -> ShareableContent?

    /// Create shareable content from a practice completion
    func createFromPracticeCompletion(_ practice: SomaticPractice) -> ShareableContent

    /// Create shareable content from a milestone
    func createFromMilestone(_ milestone: DevelopmentalMilestone) -> ShareableContent

    /// System share sheet (UIActivityViewController / Intent)
    func presentSystemShareSheet(card: ShareCard) async
}

struct ShareCard {
    let content: ShareableContent
    let imageData: Data          // PNG rendered card
    let shareText: String
    let deepLink: URL
    let hashtags: [String]
}

struct DevelopmentalMilestone: Codable {
    let type: MilestoneType
    let description: String
    let date: Date

    enum MilestoneType: String, Codable {
        case firstJournalEntry      = "First Reflection"
        case weekStreak             = "7-Day Practice Streak"
        case monthStreak            = "30-Day Practice Streak"
        case chapterCompleted       = "Chapter Completed"
        case bookCompleted          = "Book Completed"
        case assessmentCompleted    = "Assessment Completed"
        case seasonTransition       = "Season Transition"
        case communityContribution  = "Community Contribution"
        case practiceExplorer       = "Practice Explorer"
        case spiralMapper           = "Spiral Mapper"
    }
}

// MARK: - Implementation

final class LuminousSocialShareService: SocialShareService {

    private let deepLinkBase = "https://luminous.journey/share"

    func generateShareCard(
        content: ShareableContent,
        platform: SocialPlatform,
        style: ShareCardStyle? = nil
    ) async throws -> ShareCard {
        let resolvedStyle = style ?? resolveStyle(for: content.backgroundStyle)
        let size = platform.preferredAspectRatio

        // Render the card image
        let imageData = try renderCard(
            content: content,
            style: resolvedStyle,
            size: size
        )

        let shareText = generateShareText(content: content)
        let deepLink = URL(string: "\(deepLinkBase)/\(content.id)")!

        return ShareCard(
            content: content,
            imageData: imageData,
            shareText: shareText,
            deepLink: deepLink,
            hashtags: generateHashtags(for: content)
        )
    }

    func share(card: ShareCard, to platform: SocialPlatform, caption: String?) async throws {
        // Platform-specific sharing APIs
        // In production, this calls native share intents per platform
        switch platform {
        case .instagramStory:
            // Uses Instagram Stories URL scheme with background image
            break
        case .systemShare:
            await presentSystemShareSheet(card: card)
        default:
            // Uses UIActivityViewController with platform hint
            await presentSystemShareSheet(card: card)
        }
    }

    func generateShareText(content: ShareableContent) -> String {
        var text = "\"\(content.excerpt)\"\n\n"
        text += "— \(content.attributionLine)\n\n"
        text += "\(deepLinkBase)/\(content.id)\n\n"
        text += "#LuminousDevelopment #SubjectObject #MeaningMaking #Resonance"
        return text
    }

    func createFromHighlight(_ highlight: EBook.Highlight, chapter: EBook.EBookChapter) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .highlight,
            title: "From Chapter \(chapter.number): \(chapter.title)",
            excerpt: highlight.text,
            attributionLine: "Luminous Constructive Development™",
            backgroundStyle: highlightColorToBackground(highlight.color),
            sourceChapter: chapter.number,
            generatedImageKey: nil,
            deepLink: "\(deepLinkBase)/highlight/\(highlight.id)"
        )
    }

    func createFromJournalEntry(_ entry: JournalEntry) -> ShareableContent? {
        guard entry.isShareable, let excerpt = entry.shareExcerpt ?? extractBeautifulExcerpt(from: entry.content) else {
            return nil
        }

        return ShareableContent(
            id: UUID(),
            type: .reflection,
            title: "A Reflection",
            excerpt: excerpt,
            attributionLine: "From a Luminous Journey",
            backgroundStyle: .creamSerif,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "\(deepLinkBase)/reflection/\(entry.id)"
        )
    }

    func createFromPracticeCompletion(_ practice: SomaticPractice) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .practiceCompletion,
            title: practice.name,
            excerpt: practice.developmentalContext ?? practice.description,
            attributionLine: "Luminous Constructive Development™",
            backgroundStyle: .somaticWave,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "\(deepLinkBase)/practice/\(practice.id)"
        )
    }

    func createFromMilestone(_ milestone: DevelopmentalMilestone) -> ShareableContent {
        ShareableContent(
            id: UUID(),
            type: .milestone,
            title: milestone.type.rawValue,
            excerpt: milestone.description,
            attributionLine: "Luminous Journey",
            backgroundStyle: .spiralPattern,
            sourceChapter: nil,
            generatedImageKey: nil,
            deepLink: "\(deepLinkBase)/milestone"
        )
    }

    func presentSystemShareSheet(card: ShareCard) async {
        #if canImport(UIKit)
        await MainActor.run {
            let items: [Any] = [
                card.shareText,
                card.deepLink,
                card.imageData
            ]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            // Present from top view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        }
        #endif
    }

    // MARK: - Private Helpers

    private func resolveStyle(for background: ShareableContent.BackgroundStyle) -> ShareCardStyle {
        switch background {
        case .forestGold:    return .forestGold
        case .creamSerif:    return .creamSerif
        case .deepRestGlow:  return .deepRestGlow
        case .somaticWave:   return .somaticWave
        case .spiralPattern: return .spiralPattern
        }
    }

    private func renderCard(content: ShareableContent, style: ShareCardStyle, size: CGSize) throws -> Data {
        // In production: renders using Core Graphics (iOS/macOS) or Skia (cross-platform)
        // Creates a beautiful branded card with:
        // - Gradient/textured background per style
        // - Centered quote in Cormorant Garamond
        // - Attribution line in Manrope
        // - Subtle Luminous spiral watermark
        // - Paper texture overlay at 3.5% opacity
        // - Optional organic blob in background
        // Returns PNG data

        // Placeholder — actual rendering uses platform graphics APIs
        return Data()
    }

    private func generateHashtags(for content: ShareableContent) -> [String] {
        var tags = ["#LuminousDevelopment", "#MeaningMaking", "#Resonance"]

        switch content.type {
        case .quote, .highlight:
            tags.append(contentsOf: ["#SubjectObject", "#Wisdom", "#ConsciousGrowth"])
        case .reflection:
            tags.append(contentsOf: ["#Reflection", "#InnerWork", "#DevelopmentalJourney"])
        case .insight:
            tags.append(contentsOf: ["#Insight", "#Awareness", "#SpiralOfGrowth"])
        case .practiceCompletion:
            tags.append(contentsOf: ["#SomaticPractice", "#EmbodiedAwareness", "#BodyWisdom"])
        case .milestone:
            tags.append(contentsOf: ["#Milestone", "#Growth", "#LuminousJourney"])
        }

        if let chapter = content.sourceChapter {
            tags.append("#Chapter\(chapter)")
        }

        return tags
    }

    private func highlightColorToBackground(_ color: EBook.Highlight.HighlightColor) -> ShareableContent.BackgroundStyle {
        switch color {
        case .gold:        return .forestGold
        case .forest:      return .forestGold
        case .somatic:     return .somaticWave
        case .relational:  return .creamSerif
        case .integration: return .spiralPattern
        }
    }

    private func extractBeautifulExcerpt(from text: String) -> String? {
        // Extract a share-worthy excerpt from journal content
        // Picks the most poetic/insightful sentence(s), max 280 chars
        let sentences = text.components(separatedBy: ". ")
        guard !sentences.isEmpty else { return nil }

        // Find sentences with evocative language
        let evocativeWords = ["notice", "realize", "feel", "discover", "wonder",
                              "shift", "open", "soften", "breathe", "hold", "see"]
        let scored = sentences.map { sentence -> (String, Int) in
            let score = evocativeWords.reduce(0) { count, word in
                sentence.lowercased().contains(word) ? count + 1 : count
            }
            return (sentence, score)
        }.sorted { $0.1 > $1.1 }

        let best = scored.first?.0 ?? sentences.first!
        return best.count <= 280 ? best : String(best.prefix(277)) + "..."
    }
}
