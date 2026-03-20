/**
 * Luminous Cosmic Architecture™ — Social Sharing Service
 * Beautiful, branded sharing to all social media platforms (free advertising!)
 */

import { SOCIAL_PLATFORMS, SHARE_BRANDING, type SocialPlatform, type ShareableContentType } from "./EcosystemConfig";

// ─── Share Content Types ──────────────────────────────────────────

export interface ShareContent {
  type: ShareableContentType;
  title: string;
  description: string;
  imageUrl?: string;        // Generated share card image
  imageData?: string;       // Base64 encoded image for native share
  deepLink: string;         // Universal link back to the app
  hashtags: string[];
  attribution: string;      // "via Luminous Cosmic Architecture™"
}

export interface NatalChartShareData {
  sunSign: string;
  moonSign: string;
  risingSign: string;
  chartImageUrl: string;    // Beautifully rendered chart image
  userName?: string;
}

export interface DailyReflectionShareData {
  prompt: string;
  zodiacSeason: string;
  date: string;
  planetaryInfluence: string;
}

export interface MoonPhaseShareData {
  phase: string;
  illumination: number;
  zodiacSign: string;
  imageUrl: string;
}

export interface QuoteShareData {
  quote: string;
  chapter: string;
  author: string;
}

// ─── Share Card Generator ─────────────────────────────────────────

export class ShareCardGenerator {
  /**
   * Generate a beautiful share card image for social media.
   * Uses Canvas API (web) or platform-native graphics.
   * All share cards include Luminous branding for organic growth.
   */
  static async generateNatalChartCard(data: NatalChartShareData): Promise<string> {
    // Returns a branded image with:
    // - Deep forest green (#0A1C14) background
    // - Gold (#C5A059) accent border
    // - Miniature natal chart rendering
    // - Sun/Moon/Rising sign display
    // - Luminous Cosmic Architecture™ watermark
    // - App download QR code or link
    const canvas = this.createCanvas(1080, 1920); // Instagram Story size
    const ctx = canvas.getContext("2d");
    if (!ctx) return "";

    // Background gradient
    const gradient = ctx.createLinearGradient(0, 0, 0, 1920);
    gradient.addColorStop(0, "#05100B");
    gradient.addColorStop(0.5, "#0A1C14");
    gradient.addColorStop(1, "#122E21");
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 1080, 1920);

    // Gold border accent
    ctx.strokeStyle = "#C5A059";
    ctx.lineWidth = 2;
    ctx.strokeRect(40, 40, 1000, 1840);

    // Inner decorative border
    ctx.strokeStyle = "rgba(197, 160, 89, 0.3)";
    ctx.lineWidth = 1;
    ctx.strokeRect(56, 56, 968, 1808);

    // Title
    ctx.fillStyle = "#C5A059";
    ctx.font = "300 28px 'Cormorant Garamond', serif";
    ctx.textAlign = "center";
    ctx.fillText("LUMINOUS COSMIC ARCHITECTURE™", 540, 120);

    // Decorative star
    ctx.fillStyle = "#E6D0A1";
    ctx.font = "24px serif";
    ctx.fillText("✦", 540, 160);

    // Big Three display
    ctx.fillStyle = "#FAFAF8";
    ctx.font = "600 48px 'Cormorant Garamond', serif";
    ctx.fillText(`☉ ${data.sunSign}`, 540, 1500);

    ctx.font = "500 36px 'Cormorant Garamond', serif";
    ctx.fillStyle = "#E6D0A1";
    ctx.fillText(`☽ ${data.moonSign}  ⬆ ${data.risingSign}`, 540, 1560);

    // Attribution
    ctx.fillStyle = "#8A9C91";
    ctx.font = "400 20px 'Manrope', sans-serif";
    ctx.fillText("luminouscosmic.app", 540, 1800);

    // Tagline
    ctx.fillStyle = "#5C7065";
    ctx.font = "italic 300 22px 'Cormorant Garamond', serif";
    ctx.fillText("The cosmos provided the alphabet.", 540, 1840);

    return canvas.toDataURL("image/png");
  }

  static async generateReflectionCard(data: DailyReflectionShareData): Promise<string> {
    const canvas = this.createCanvas(1080, 1080); // Instagram square
    const ctx = canvas.getContext("2d");
    if (!ctx) return "";

    // Background
    const gradient = ctx.createRadialGradient(540, 540, 100, 540, 540, 600);
    gradient.addColorStop(0, "#122E21");
    gradient.addColorStop(1, "#05100B");
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 1080, 1080);

    // Gold border
    ctx.strokeStyle = "#C5A059";
    ctx.lineWidth = 2;
    ctx.strokeRect(48, 48, 984, 984);

    // Season label
    ctx.fillStyle = "#C5A059";
    ctx.font = "500 18px 'Manrope', sans-serif";
    ctx.textAlign = "center";
    ctx.fillText(`${data.zodiacSeason.toUpperCase()} SEASON`, 540, 140);

    // Decorative divider
    ctx.fillText("─── ✦ ───", 540, 180);

    // Date
    ctx.fillStyle = "#8A9C91";
    ctx.font = "400 16px 'Manrope', sans-serif";
    ctx.fillText(data.date, 540, 220);

    // Reflection prompt (word-wrapped)
    ctx.fillStyle = "#FAFAF8";
    ctx.font = "italic 300 36px 'Cormorant Garamond', serif";
    const lines = this.wrapText(ctx, `"${data.prompt}"`, 800);
    let y = 540 - (lines.length * 50) / 2;
    for (const line of lines) {
      ctx.fillText(line, 540, y);
      y += 50;
    }

    // Planetary influence
    ctx.fillStyle = "#E6D0A1";
    ctx.font = "400 16px 'Manrope', sans-serif";
    ctx.fillText(`${data.planetaryInfluence} Influence`, 540, 900);

    // Attribution
    ctx.fillStyle = "#5C7065";
    ctx.font = "400 16px 'Manrope', sans-serif";
    ctx.fillText("Luminous Cosmic Architecture™ · luminouscosmic.app", 540, 1000);

    return canvas.toDataURL("image/png");
  }

  static async generateQuoteCard(data: QuoteShareData): Promise<string> {
    const canvas = this.createCanvas(1080, 1350); // Instagram portrait
    const ctx = canvas.getContext("2d");
    if (!ctx) return "";

    // Background
    const gradient = ctx.createLinearGradient(0, 0, 1080, 1350);
    gradient.addColorStop(0, "#0A1C14");
    gradient.addColorStop(1, "#1B402E");
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, 1080, 1350);

    // Gold accent line (left)
    ctx.fillStyle = "#C5A059";
    ctx.fillRect(80, 200, 3, 950);

    // Chapter label
    ctx.fillStyle = "#C5A059";
    ctx.font = "500 16px 'Manrope', sans-serif";
    ctx.textAlign = "left";
    ctx.fillText(data.chapter.toUpperCase(), 120, 240);

    // Quote
    ctx.fillStyle = "#FAFAF8";
    ctx.font = "italic 300 40px 'Cormorant Garamond', serif";
    ctx.textAlign = "left";
    const lines = this.wrapText(ctx, `"${data.quote}"`, 860);
    let y = 400;
    for (const line of lines) {
      ctx.fillText(line, 120, y);
      y += 56;
    }

    // Author
    ctx.fillStyle = "#E6D0A1";
    ctx.font = "500 22px 'Manrope', sans-serif";
    ctx.fillText(`— ${data.author}`, 120, y + 40);

    // Attribution
    ctx.fillStyle = "#5C7065";
    ctx.font = "400 16px 'Manrope', sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("Luminous Cosmic Architecture™ · luminouscosmic.app", 540, 1290);

    return canvas.toDataURL("image/png");
  }

  static async generateMoonPhaseCard(data: MoonPhaseShareData): Promise<string> {
    const canvas = this.createCanvas(1080, 1080);
    const ctx = canvas.getContext("2d");
    if (!ctx) return "";

    // Background
    ctx.fillStyle = "#05100B";
    ctx.fillRect(0, 0, 1080, 1080);

    // Subtle star field
    ctx.fillStyle = "rgba(250, 250, 248, 0.3)";
    for (let i = 0; i < 100; i++) {
      const x = Math.random() * 1080;
      const y = Math.random() * 1080;
      const r = Math.random() * 1.5;
      ctx.beginPath();
      ctx.arc(x, y, r, 0, Math.PI * 2);
      ctx.fill();
    }

    // Moon circle
    ctx.beginPath();
    ctx.arc(540, 440, 180, 0, Math.PI * 2);
    ctx.fillStyle = "#E6D0A1";
    ctx.fill();

    // Moon shadow (simplified phase rendering)
    const shadowOffset = (1 - data.illumination) * 360 - 180;
    ctx.beginPath();
    ctx.arc(540 + shadowOffset * 0.5, 440, 180, 0, Math.PI * 2);
    ctx.fillStyle = "#05100B";
    ctx.fill();

    // Phase name
    ctx.fillStyle = "#FAFAF8";
    ctx.font = "600 42px 'Cormorant Garamond', serif";
    ctx.textAlign = "center";
    ctx.fillText(data.phase, 540, 720);

    // Zodiac sign
    ctx.fillStyle = "#C5A059";
    ctx.font = "400 24px 'Manrope', sans-serif";
    ctx.fillText(`Moon in ${data.zodiacSign}`, 540, 770);

    // Illumination
    ctx.fillStyle = "#8A9C91";
    ctx.font = "400 18px 'Manrope', sans-serif";
    ctx.fillText(`${Math.round(data.illumination * 100)}% illuminated`, 540, 810);

    // Attribution
    ctx.fillStyle = "#5C7065";
    ctx.font = "400 16px 'Manrope', sans-serif";
    ctx.fillText("Luminous Cosmic Architecture™ · luminouscosmic.app", 540, 1020);

    return canvas.toDataURL("image/png");
  }

  // ─── Utilities ────────────────────────────────────────────────

  private static createCanvas(width: number, height: number): HTMLCanvasElement {
    if (typeof document !== "undefined") {
      const canvas = document.createElement("canvas");
      canvas.width = width;
      canvas.height = height;
      return canvas;
    }
    // Fallback for non-browser environments
    return { width, height, getContext: () => null, toDataURL: () => "" } as unknown as HTMLCanvasElement;
  }

  private static wrapText(ctx: CanvasRenderingContext2D, text: string, maxWidth: number): string[] {
    const words = text.split(" ");
    const lines: string[] = [];
    let currentLine = "";

    for (const word of words) {
      const testLine = currentLine ? `${currentLine} ${word}` : word;
      const metrics = ctx.measureText(testLine);
      if (metrics.width > maxWidth && currentLine) {
        lines.push(currentLine);
        currentLine = word;
      } else {
        currentLine = testLine;
      }
    }
    if (currentLine) lines.push(currentLine);
    return lines;
  }
}

// ─── Social Sharing Service ───────────────────────────────────────

export class SocialSharingService {
  /**
   * Share content to a specific social platform.
   * Generates branded share card image + formatted text.
   */
  static async share(
    platform: SocialPlatform,
    content: ShareContent
  ): Promise<boolean> {
    const shareText = this.formatShareText(platform, content);

    // Use Web Share API if available (mobile browsers)
    if (typeof navigator !== "undefined" && navigator.share) {
      try {
        const shareData: ShareData = {
          title: content.title,
          text: shareText,
          url: content.deepLink,
        };

        // If image is available and platform supports it
        if (content.imageData && platform.supportsImage) {
          const blob = this.dataURLToBlob(content.imageData);
          const file = new File([blob], "luminous-cosmic-share.png", { type: "image/png" });
          shareData.files = [file];
        }

        await navigator.share(shareData);
        return true;
      } catch {
        // User cancelled or error — fall through to URL-based sharing
      }
    }

    // Platform-specific URL-based sharing
    const shareUrl = this.buildShareUrl(platform, content, shareText);
    if (shareUrl) {
      if (typeof window !== "undefined") {
        window.open(shareUrl, "_blank", "noopener,noreferrer");
      }
      return true;
    }

    return false;
  }

  /**
   * Share to system share sheet (iOS/Android native, or Web Share API)
   */
  static async shareToSystemSheet(content: ShareContent): Promise<boolean> {
    if (typeof navigator !== "undefined" && navigator.share) {
      const shareData: ShareData = {
        title: content.title,
        text: `${content.description}\n\n${content.hashtags.join(" ")}\n\n${content.deepLink}`,
        url: content.deepLink,
      };

      if (content.imageData) {
        const blob = this.dataURLToBlob(content.imageData);
        const file = new File([blob], "luminous-cosmic-share.png", { type: "image/png" });
        shareData.files = [file];
      }

      try {
        await navigator.share(shareData);
        return true;
      } catch {
        return false;
      }
    }
    return false;
  }

  /**
   * Copy shareable link to clipboard
   */
  static async copyLink(content: ShareContent): Promise<boolean> {
    const text = `${content.title}\n${content.description}\n\n${content.deepLink}`;
    if (typeof navigator !== "undefined" && navigator.clipboard) {
      await navigator.clipboard.writeText(text);
      return true;
    }
    return false;
  }

  /**
   * Save share card image to device
   */
  static async saveImage(imageData: string, filename: string = "luminous-cosmic"): Promise<boolean> {
    if (typeof document !== "undefined") {
      const link = document.createElement("a");
      link.download = `${filename}.png`;
      link.href = imageData;
      link.click();
      return true;
    }
    return false;
  }

  // ─── Content Builders ─────────────────────────────────────────

  static buildNatalChartShare(data: NatalChartShareData): ShareContent {
    return {
      type: "natal_chart_image",
      title: "My Cosmic Blueprint",
      description: `☉ ${data.sunSign} · ☽ ${data.moonSign} · ⬆ ${data.risingSign}\n\nDiscover your own cosmic architecture.`,
      imageUrl: data.chartImageUrl,
      deepLink: `https://luminouscosmic.app/chart`,
      hashtags: ["#LuminousCosmic", "#NatalChart", "#CosmicArchitecture", `#${data.sunSign}`],
      attribution: SHARE_BRANDING.tagline,
    };
  }

  static buildReflectionShare(data: DailyReflectionShareData): ShareContent {
    return {
      type: "daily_reflection",
      title: `${data.zodiacSeason} Season Reflection`,
      description: `"${data.prompt}"\n\n— Daily cosmic reflection`,
      deepLink: `https://luminouscosmic.app/reflection/${data.date}`,
      hashtags: ["#LuminousCosmic", "#CosmicReflection", "#DailyAstrology", `#${data.zodiacSeason}Season`],
      attribution: SHARE_BRANDING.tagline,
    };
  }

  static buildQuoteShare(data: QuoteShareData): ShareContent {
    return {
      type: "chapter_quote",
      title: "Luminous Wisdom",
      description: `"${data.quote}"\n\n— ${data.author}, ${data.chapter}`,
      deepLink: `https://luminouscosmic.app/book`,
      hashtags: ["#LuminousCosmic", "#CosmicWisdom", "#AstrologyAsMap"],
      attribution: SHARE_BRANDING.tagline,
    };
  }

  static buildMoonPhaseShare(data: MoonPhaseShareData): ShareContent {
    return {
      type: "moon_phase",
      title: `${data.phase} in ${data.zodiacSign}`,
      description: `Tonight's Moon: ${data.phase} in ${data.zodiacSign} (${Math.round(data.illumination * 100)}% illuminated)`,
      imageUrl: data.imageUrl,
      deepLink: `https://luminouscosmic.app/moon`,
      hashtags: ["#LuminousCosmic", "#MoonPhase", `#${data.phase.replace(/\s/g, "")}`, "#LunarWisdom"],
      attribution: SHARE_BRANDING.tagline,
    };
  }

  // ─── Formatting ───────────────────────────────────────────────

  private static formatShareText(platform: SocialPlatform, content: ShareContent): string {
    const parts = [content.description];

    if (content.attribution) {
      parts.push("");
      parts.push(content.attribution);
    }

    if (content.hashtags.length > 0) {
      parts.push("");
      parts.push(content.hashtags.join(" "));
    }

    parts.push("");
    parts.push(content.deepLink);

    let text = parts.join("\n");

    // Truncate for platform limits
    if (platform.maxTextLength > 0 && text.length > platform.maxTextLength) {
      text = text.substring(0, platform.maxTextLength - 3) + "...";
    }

    return text;
  }

  private static buildShareUrl(
    platform: SocialPlatform,
    content: ShareContent,
    text: string
  ): string | null {
    switch (platform.id) {
      case "twitter":
        return `${platform.shareUrl}?text=${encodeURIComponent(text)}&url=${encodeURIComponent(content.deepLink)}`;
      case "facebook":
        return `${platform.shareUrl}?u=${encodeURIComponent(content.deepLink)}&quote=${encodeURIComponent(text)}`;
      case "pinterest":
        return `${platform.shareUrl}?url=${encodeURIComponent(content.deepLink)}&description=${encodeURIComponent(text)}${content.imageUrl ? `&media=${encodeURIComponent(content.imageUrl)}` : ""}`;
      case "whatsapp":
        return `${platform.shareUrl}?text=${encodeURIComponent(text)}`;
      case "telegram":
        return `${platform.shareUrl}?url=${encodeURIComponent(content.deepLink)}&text=${encodeURIComponent(text)}`;
      case "email":
        return `${platform.shareUrl}?subject=${encodeURIComponent(content.title)}&body=${encodeURIComponent(text)}`;
      case "messages":
        return `${platform.shareUrl}?body=${encodeURIComponent(text)}`;
      default:
        return null;
    }
  }

  private static dataURLToBlob(dataURL: string): Blob {
    const parts = dataURL.split(",");
    const mime = parts[0].match(/:(.*?);/)?.[1] ?? "image/png";
    const binary = atob(parts[1]);
    const array = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      array[i] = binary.charCodeAt(i);
    }
    return new Blob([array], { type: mime });
  }

  /**
   * Get available platforms for the current device
   */
  static getAvailablePlatforms(): SocialPlatform[] {
    return SOCIAL_PLATFORMS;
  }
}
