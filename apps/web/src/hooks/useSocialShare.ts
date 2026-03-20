/**
 * ════════════════════════════════════════════════════════════════════════════════
 * Luminous Attachment — Social Sharing Hooks
 * Resonance UX
 *
 * React hooks for effortless social sharing across web, mobile, and desktop.
 * Every beautiful moment is designed to be shared — wanton sharing as free
 * advertising for the journey toward secure connection.
 * ════════════════════════════════════════════════════════════════════════════════
 */

import { useState, useCallback, useEffect, useRef, useMemo } from 'react';
import {
  type ShareContent,
  type ShareCardData,
  type SocialPlatform,
  type PlatformShareConfig,
  type ShareContentType,
  buildShareUrl,
  formatShareText,
  generateShareLink,
  generateShareCardHtml,
  buildQuizResultCard,
  buildInsightCard,
  buildMilestoneCard,
  buildChapterQuoteCard,
  getAvailablePlatforms,
  getPopularPlatforms,
  detectPlatform,
  isMobile,
  supportsNativeShare,
  supportsClipboard,
  addUtmParams,
  generateReferralCode,
} from '../utils/shareUtils';

// ─── Types ──────────────────────────────────────────────────────────────────────

interface ShareResult {
  success: boolean;
  platform: SocialPlatform;
  error?: string;
  timestamp: number;
}

interface ShareAnalyticsEvent {
  eventType: 'share_initiated' | 'share_completed' | 'share_failed' | 'share_card_generated' | 'share_link_copied';
  platform: SocialPlatform;
  contentType: ShareContentType;
  timestamp: number;
  metadata?: Record<string, string>;
}

interface ShareCardOptions {
  style?: 'light' | 'dark' | 'gold';
  width?: number;
  height?: number;
  format?: 'png' | 'jpeg' | 'webp';
  quality?: number;
}

// ─── useShareCard ──────────────────────────────────────────────────────────────

/**
 * Generates beautiful shareable card images from content.
 * Creates Instagram-ready 1080x1080 cards, Twitter cards, etc.
 */
export function useShareCard() {
  const [isGenerating, setIsGenerating] = useState(false);
  const [lastCard, setLastCard] = useState<string | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  const ensureCanvas = useCallback(() => {
    if (!canvasRef.current) {
      canvasRef.current = document.createElement('canvas');
    }
    return canvasRef.current;
  }, []);

  const generateCard = useCallback(async (
    data: ShareCardData,
    options: ShareCardOptions = {}
  ): Promise<string> => {
    setIsGenerating(true);
    try {
      const {
        width = 1080,
        height = 1080,
        format = 'png',
        quality = 0.92,
      } = options;

      const canvas = ensureCanvas();
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext('2d');
      if (!ctx) throw new Error('Canvas context unavailable');

      // Background
      const colors = {
        light: { bg: '#FAFAF8', text: '#0A1C14', accent: '#C5A059', subtle: '#D1E0D7' },
        dark: { bg: '#05100B', text: '#E8F0EA', accent: '#C5A059', subtle: '#1B402E' },
        gold: { bg: '#0A1C14', text: '#E8F0EA', accent: '#E6D0A1', subtle: '#122E21' },
      };
      const c = colors[data.style];

      // Fill background
      if (data.style === 'gold') {
        const gradient = ctx.createLinearGradient(0, 0, width, height);
        gradient.addColorStop(0, '#0A1C14');
        gradient.addColorStop(1, '#122E21');
        ctx.fillStyle = gradient;
      } else {
        ctx.fillStyle = c.bg;
      }
      ctx.fillRect(0, 0, width, height);

      // Paper texture noise
      const imageData = ctx.getImageData(0, 0, width, height);
      const pixels = imageData.data;
      for (let i = 0; i < pixels.length; i += 4) {
        const noise = (Math.random() - 0.5) * 6;
        pixels[i] = Math.min(255, Math.max(0, pixels[i] + noise));
        pixels[i + 1] = Math.min(255, Math.max(0, pixels[i + 1] + noise));
        pixels[i + 2] = Math.min(255, Math.max(0, pixels[i + 2] + noise));
      }
      ctx.putImageData(imageData, 0, 0);

      // Organic blob decoration
      ctx.save();
      ctx.globalAlpha = 0.08;
      ctx.fillStyle = c.accent;
      ctx.beginPath();
      const blobX = width * 0.8;
      const blobY = height * 0.15;
      const blobR = 200;
      for (let angle = 0; angle < Math.PI * 2; angle += 0.01) {
        const r = blobR + Math.sin(angle * 3) * 40 + Math.cos(angle * 5) * 30;
        const x = blobX + Math.cos(angle) * r;
        const y = blobY + Math.sin(angle) * r;
        if (angle === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.fill();
      ctx.restore();

      // Second blob bottom-left
      ctx.save();
      ctx.globalAlpha = 0.05;
      ctx.fillStyle = c.accent;
      ctx.beginPath();
      const blob2X = width * 0.15;
      const blob2Y = height * 0.85;
      const blob2R = 150;
      for (let angle = 0; angle < Math.PI * 2; angle += 0.01) {
        const r = blob2R + Math.sin(angle * 4) * 35 + Math.cos(angle * 2) * 25;
        const x = blob2X + Math.cos(angle) * r;
        const y = blob2Y + Math.sin(angle) * r;
        if (angle === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
      }
      ctx.closePath();
      ctx.fill();
      ctx.restore();

      const padding = 80;
      const contentWidth = width - padding * 2;

      // Accent text (category label)
      if (data.accentText) {
        ctx.font = '600 18px Manrope, sans-serif';
        ctx.fillStyle = c.accent;
        ctx.letterSpacing = '3px';
        ctx.fillText(data.accentText.toUpperCase(), padding, padding + 60);
      }

      // Headline (Cormorant Garamond)
      ctx.font = '600 52px "Cormorant Garamond", serif';
      ctx.fillStyle = c.text;
      const headlineY = padding + (data.accentText ? 130 : 80);
      wrapText(ctx, data.headline, padding, headlineY, contentWidth, 66);

      // Body text
      const headlineLines = Math.ceil(ctx.measureText(data.headline).width / contentWidth) + 1;
      const bodyY = headlineY + headlineLines * 66 + 32;
      ctx.font = '400 24px Manrope, sans-serif';
      ctx.fillStyle = c.text;
      ctx.globalAlpha = 0.75;
      wrapText(ctx, data.body, padding, bodyY, contentWidth, 38);
      ctx.globalAlpha = 1;

      // Footer divider
      const footerY = height - padding - 40;
      ctx.strokeStyle = c.subtle;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(padding, footerY - 24);
      ctx.lineTo(width - padding, footerY - 24);
      ctx.stroke();

      // Footer branding
      ctx.font = '700 22px "Cormorant Garamond", serif';
      ctx.fillStyle = c.accent;
      ctx.fillText('Luminous Attachment', padding, footerY + 6);

      ctx.font = '400 16px Manrope, sans-serif';
      ctx.fillStyle = c.text;
      ctx.globalAlpha = 0.5;
      const brandWidth = ctx.measureText('Luminous Attachment').width;
      ctx.font = '400 16px Manrope, sans-serif';
      ctx.fillText(' by Resonance UX', padding + brandWidth + 8, footerY + 6);
      ctx.globalAlpha = 1;

      if (data.footerText) {
        ctx.font = '400 14px Manrope, sans-serif';
        ctx.fillStyle = c.text;
        ctx.globalAlpha = 0.4;
        const ftWidth = ctx.measureText(data.footerText).width;
        ctx.fillText(data.footerText, width - padding - ftWidth, footerY + 6);
        ctx.globalAlpha = 1;
      }

      // Border
      ctx.strokeStyle = c.subtle;
      ctx.lineWidth = 2;
      ctx.strokeRect(1, 1, width - 2, height - 2);

      const mimeType = format === 'jpeg' ? 'image/jpeg' : format === 'webp' ? 'image/webp' : 'image/png';
      const dataUrl = canvas.toDataURL(mimeType, quality);
      setLastCard(dataUrl);
      return dataUrl;
    } finally {
      setIsGenerating(false);
    }
  }, [ensureCanvas]);

  const generateQuizResultCard = useCallback(async (
    style: string,
    description: string,
    options?: ShareCardOptions
  ) => {
    const data = buildQuizResultCard(style, description, options?.style === 'dark');
    return generateCard(data, options);
  }, [generateCard]);

  const generateInsightCard = useCallback(async (
    quote: string,
    source?: string,
    options?: ShareCardOptions
  ) => {
    const data = buildInsightCard(quote, source, options?.style === 'dark');
    return generateCard(data, options);
  }, [generateCard]);

  const generateMilestoneCard = useCallback(async (
    milestone: string,
    description: string,
    options?: ShareCardOptions
  ) => {
    const data = buildMilestoneCard(milestone, description, options?.style === 'dark');
    return generateCard(data, options);
  }, [generateCard]);

  const generateChapterQuoteCard = useCallback(async (
    quote: string,
    chapter: string,
    options?: ShareCardOptions
  ) => {
    const data = buildChapterQuoteCard(quote, chapter, options?.style === 'dark');
    return generateCard(data, options);
  }, [generateCard]);

  const downloadCard = useCallback(async (dataUrl?: string) => {
    const url = dataUrl || lastCard;
    if (!url) return;
    const link = document.createElement('a');
    link.download = `luminous-attachment-${Date.now()}.png`;
    link.href = url;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }, [lastCard]);

  return {
    generateCard,
    generateQuizResultCard,
    generateInsightCard,
    generateMilestoneCard,
    generateChapterQuoteCard,
    downloadCard,
    isGenerating,
    lastCard,
  };
}

function wrapText(
  ctx: CanvasRenderingContext2D,
  text: string,
  x: number,
  y: number,
  maxWidth: number,
  lineHeight: number
): void {
  const words = text.split(' ');
  let line = '';
  let currentY = y;

  for (const word of words) {
    const testLine = line + word + ' ';
    const metrics = ctx.measureText(testLine);
    if (metrics.width > maxWidth && line !== '') {
      ctx.fillText(line.trim(), x, currentY);
      line = word + ' ';
      currentY += lineHeight;
    } else {
      line = testLine;
    }
  }
  ctx.fillText(line.trim(), x, currentY);
}

// ─── usePlatformShare ──────────────────────────────────────────────────────────

/**
 * Share content to a specific social platform.
 * Handles URL construction, window opening, and mobile deep links.
 */
export function usePlatformShare() {
  const [isSharing, setIsSharing] = useState(false);
  const [lastResult, setLastResult] = useState<ShareResult | null>(null);
  const { trackShare } = useShareAnalytics();

  const shareTo = useCallback(async (
    platform: SocialPlatform,
    content: ShareContent
  ): Promise<ShareResult> => {
    setIsSharing(true);
    const timestamp = Date.now();

    try {
      trackShare('share_initiated', platform, content.type);

      if (platform === 'copy') {
        return await handleCopyShare(content, timestamp);
      }

      if (platform === 'native') {
        return await handleNativeShare(content, timestamp);
      }

      const url = buildShareUrl(platform, content);

      // On mobile, try to open native app first
      if (isMobile()) {
        window.location.href = url;
      } else {
        // Desktop: open in popup window
        const windowFeatures = getPopupFeatures(platform);
        const popup = window.open(url, `share_${platform}`, windowFeatures);

        if (!popup || popup.closed) {
          // Fallback: open in new tab
          window.open(url, '_blank', 'noopener,noreferrer');
        }
      }

      const result: ShareResult = { success: true, platform, timestamp };
      setLastResult(result);
      trackShare('share_completed', platform, content.type);
      return result;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Share failed';
      const result: ShareResult = { success: false, platform, error: message, timestamp };
      setLastResult(result);
      trackShare('share_failed', platform, content.type, { error: message });
      return result;
    } finally {
      setIsSharing(false);
    }
  }, [trackShare]);

  const getShareUrl = useCallback((platform: SocialPlatform, content: ShareContent): string => {
    return buildShareUrl(platform, content);
  }, []);

  const availablePlatforms = useMemo(() => getAvailablePlatforms(), []);
  const popularPlatforms = useMemo(() => getPopularPlatforms(), []);

  return {
    shareTo,
    getShareUrl,
    isSharing,
    lastResult,
    availablePlatforms,
    popularPlatforms,
  };
}

async function handleCopyShare(content: ShareContent, timestamp: number): Promise<ShareResult> {
  const shareLink = content.url || generateShareLink(content);
  const text = `${content.title}\n\n${content.text}\n\n${shareLink}`;

  if (supportsClipboard()) {
    await navigator.clipboard.writeText(text);
  } else {
    // Fallback for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    textarea.style.opacity = '0';
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
  }

  return { success: true, platform: 'copy', timestamp };
}

async function handleNativeShare(content: ShareContent, timestamp: number): Promise<ShareResult> {
  if (!supportsNativeShare()) {
    return { success: false, platform: 'native', error: 'Web Share API not supported', timestamp };
  }

  const shareLink = content.url || generateShareLink(content);

  const shareData: ShareData = {
    title: content.title,
    text: content.text,
    url: shareLink,
  };

  // Add image file if available
  if (content.imageDataUrl) {
    try {
      const response = await fetch(content.imageDataUrl);
      const blob = await response.blob();
      const file = new File([blob], 'luminous-attachment.png', { type: 'image/png' });
      if (navigator.canShare && navigator.canShare({ files: [file] })) {
        shareData.files = [file];
      }
    } catch {
      // Proceed without image
    }
  }

  try {
    await navigator.share(shareData);
    return { success: true, platform: 'native', timestamp };
  } catch (error) {
    if (error instanceof Error && error.name === 'AbortError') {
      return { success: false, platform: 'native', error: 'User cancelled', timestamp };
    }
    throw error;
  }
}

function getPopupFeatures(platform: SocialPlatform): string {
  const sizes: Record<string, [number, number]> = {
    twitter: [600, 450],
    facebook: [626, 436],
    linkedin: [600, 500],
    pinterest: [750, 550],
    reddit: [660, 460],
    tumblr: [540, 600],
  };
  const [w, h] = sizes[platform] || [600, 500];
  const left = Math.round((screen.width - w) / 2);
  const top = Math.round((screen.height - h) / 2);
  return `width=${w},height=${h},left=${left},top=${top},toolbar=no,menubar=no,scrollbars=yes,resizable=yes`;
}

// ─── useWebShare ───────────────────────────────────────────────────────────────

/**
 * Uses the Web Share API with intelligent fallback to a custom share modal.
 * Automatically detects platform capabilities and optimizes accordingly.
 */
export function useWebShare() {
  const [isSupported, setIsSupported] = useState(false);
  const [isOpen, setIsOpen] = useState(false);
  const [pendingContent, setPendingContent] = useState<ShareContent | null>(null);
  const { shareTo } = usePlatformShare();
  const { generateCard } = useShareCard();

  useEffect(() => {
    setIsSupported(supportsNativeShare());
  }, []);

  const share = useCallback(async (
    content: ShareContent,
    options?: { preferNative?: boolean; includeImage?: boolean }
  ): Promise<ShareResult> => {
    const { preferNative = true, includeImage = true } = options || {};

    // Generate a card image if needed
    if (includeImage && !content.imageDataUrl) {
      try {
        const cardData: ShareCardData = {
          headline: content.title,
          body: content.text,
          accentText: content.type.replace(/-/g, ' ').toUpperCase(),
          style: 'gold',
          contentType: content.type,
        };
        const imageDataUrl = await generateCard(cardData);
        content = { ...content, imageDataUrl };
      } catch {
        // Proceed without card
      }
    }

    // Try native share first on mobile
    if (preferNative && isSupported && isMobile()) {
      const result = await shareTo('native', content);
      if (result.success || result.error === 'User cancelled') {
        return result;
      }
    }

    // Fall back to showing platform picker
    setPendingContent(content);
    setIsOpen(true);

    return {
      success: true,
      platform: 'native',
      timestamp: Date.now(),
    };
  }, [isSupported, shareTo, generateCard]);

  const shareToSelected = useCallback(async (platform: SocialPlatform): Promise<ShareResult> => {
    if (!pendingContent) {
      return { success: false, platform, error: 'No content to share', timestamp: Date.now() };
    }
    setIsOpen(false);
    const result = await shareTo(platform, pendingContent);
    setPendingContent(null);
    return result;
  }, [pendingContent, shareTo]);

  const close = useCallback(() => {
    setIsOpen(false);
    setPendingContent(null);
  }, []);

  return {
    share,
    shareToSelected,
    close,
    isSupported,
    isOpen,
    pendingContent,
  };
}

// ─── useShareAnalytics ─────────────────────────────────────────────────────────

/**
 * Tracks sharing events for viral metrics and growth analytics.
 * Measures share rates, platform preferences, and conversion.
 */
export function useShareAnalytics() {
  const [events, setEvents] = useState<ShareAnalyticsEvent[]>([]);
  const [shareCount, setShareCount] = useState(0);

  const trackShare = useCallback((
    eventType: ShareAnalyticsEvent['eventType'],
    platform: SocialPlatform,
    contentType: ShareContentType,
    metadata?: Record<string, string>
  ) => {
    const event: ShareAnalyticsEvent = {
      eventType,
      platform,
      contentType,
      timestamp: Date.now(),
      metadata,
    };

    setEvents(prev => [...prev.slice(-99), event]);

    if (eventType === 'share_completed') {
      setShareCount(prev => prev + 1);
    }

    // Send to analytics endpoint
    sendAnalyticsEvent(event).catch(() => {
      // Silently fail — never block sharing on analytics
    });
  }, []);

  const getShareStats = useCallback(() => {
    const completed = events.filter(e => e.eventType === 'share_completed');
    const failed = events.filter(e => e.eventType === 'share_failed');
    const initiated = events.filter(e => e.eventType === 'share_initiated');

    const platformBreakdown: Record<string, number> = {};
    const contentBreakdown: Record<string, number> = {};

    completed.forEach(e => {
      platformBreakdown[e.platform] = (platformBreakdown[e.platform] || 0) + 1;
      contentBreakdown[e.contentType] = (contentBreakdown[e.contentType] || 0) + 1;
    });

    const conversionRate = initiated.length > 0
      ? (completed.length / initiated.length) * 100
      : 0;

    return {
      totalShares: completed.length,
      totalAttempts: initiated.length,
      totalFailed: failed.length,
      conversionRate: Math.round(conversionRate * 10) / 10,
      platformBreakdown,
      contentBreakdown,
      mostSharedPlatform: Object.entries(platformBreakdown)
        .sort(([, a], [, b]) => b - a)[0]?.[0] || null,
      mostSharedContent: Object.entries(contentBreakdown)
        .sort(([, a], [, b]) => b - a)[0]?.[0] || null,
    };
  }, [events]);

  const getViralCoefficient = useCallback(() => {
    // Simplified viral coefficient: shares per user session
    // Real implementation would track referral conversions
    const sessionDuration = events.length > 0
      ? Date.now() - events[0].timestamp
      : 0;
    const sessionsEstimate = Math.max(1, Math.floor(sessionDuration / (30 * 60 * 1000)));
    return {
      sharesPerSession: shareCount / sessionsEstimate,
      totalShares: shareCount,
      estimatedReach: shareCount * 150, // Average social reach multiplier
    };
  }, [events, shareCount]);

  return {
    trackShare,
    getShareStats,
    getViralCoefficient,
    shareCount,
    events,
  };
}

async function sendAnalyticsEvent(event: ShareAnalyticsEvent): Promise<void> {
  if (typeof window === 'undefined') return;

  // Queue event for batch sending
  const queue = JSON.parse(sessionStorage.getItem('la_share_queue') || '[]');
  queue.push(event);
  sessionStorage.setItem('la_share_queue', JSON.stringify(queue));

  // Batch send when queue reaches threshold
  if (queue.length >= 5) {
    try {
      const endpoint = '/api/analytics/shares';
      await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ events: queue }),
        keepalive: true,
      });
      sessionStorage.setItem('la_share_queue', '[]');
    } catch {
      // Will retry on next batch
    }
  }
}

// ─── Composite Hook: useShare ──────────────────────────────────────────────────

/**
 * All-in-one sharing hook combining card generation, platform sharing,
 * web share API, and analytics. The single entry point for sharing.
 */
export function useShare() {
  const card = useShareCard();
  const platform = usePlatformShare();
  const web = useWebShare();
  const analytics = useShareAnalytics();

  const shareWithCard = useCallback(async (
    content: ShareContent,
    targetPlatform?: SocialPlatform,
    cardStyle: 'light' | 'dark' | 'gold' = 'gold'
  ) => {
    // Generate the card
    const cardData: ShareCardData = {
      headline: content.title,
      body: content.text,
      accentText: content.type.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
      footerText: 'luminousattachment.com',
      style: cardStyle,
      contentType: content.type,
    };

    const imageDataUrl = await card.generateCard(cardData);
    const enrichedContent = { ...content, imageDataUrl };

    analytics.trackShare('share_card_generated', targetPlatform || 'native', content.type);

    if (targetPlatform) {
      return platform.shareTo(targetPlatform, enrichedContent);
    } else {
      return web.share(enrichedContent);
    }
  }, [card, platform, web, analytics]);

  const quickShare = useCallback(async (content: ShareContent) => {
    return web.share(content, { preferNative: true, includeImage: true });
  }, [web]);

  return {
    // Card generation
    generateCard: card.generateCard,
    generateQuizResultCard: card.generateQuizResultCard,
    generateInsightCard: card.generateInsightCard,
    generateMilestoneCard: card.generateMilestoneCard,
    generateChapterQuoteCard: card.generateChapterQuoteCard,
    downloadCard: card.downloadCard,
    isGeneratingCard: card.isGenerating,
    lastCard: card.lastCard,

    // Platform sharing
    shareTo: platform.shareTo,
    getShareUrl: platform.getShareUrl,
    isSharing: platform.isSharing,
    availablePlatforms: platform.availablePlatforms,
    popularPlatforms: platform.popularPlatforms,

    // Web Share API
    shareNative: web.share,
    isWebShareSupported: web.isSupported,
    isShareModalOpen: web.isOpen,
    closeShareModal: web.close,
    shareToSelected: web.shareToSelected,

    // Composite
    shareWithCard,
    quickShare,

    // Analytics
    trackShare: analytics.trackShare,
    getShareStats: analytics.getShareStats,
    getViralCoefficient: analytics.getViralCoefficient,
    shareCount: analytics.shareCount,
  };
}

export default useShare;
