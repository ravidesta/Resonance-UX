/**
 * ════════════════════════════════════════════════════════════════════════════════
 * Luminous Attachment — Share Utilities
 * Resonance UX
 *
 * Generate share URLs, deep links, and beautifully formatted content for every
 * social platform. Designed so sharing feels effortless — wanton sharing of
 * beautiful moments as free advertising.
 * ════════════════════════════════════════════════════════════════════════════════
 */

// ─── Types ──────────────────────────────────────────────────────────────────────

export type SocialPlatform =
  | 'twitter'
  | 'facebook'
  | 'instagram'
  | 'threads'
  | 'bluesky'
  | 'mastodon'
  | 'linkedin'
  | 'pinterest'
  | 'whatsapp'
  | 'telegram'
  | 'signal'
  | 'reddit'
  | 'tumblr'
  | 'email'
  | 'sms'
  | 'copy'
  | 'native';

export type ShareContentType =
  | 'insight'
  | 'quiz-result'
  | 'journal-reflection'
  | 'chapter-quote'
  | 'coach-moment'
  | 'growth-milestone'
  | 'audiobook-clip'
  | 'daily-prompt'
  | 'attachment-style';

export interface ShareContent {
  type: ShareContentType;
  title: string;
  text: string;
  quote?: string;
  author?: string;
  imageUrl?: string;
  imageDataUrl?: string;
  chapter?: string;
  attachmentStyle?: string;
  milestone?: string;
  hashtags?: string[];
  url?: string;
}

export interface ShareCardData {
  headline: string;
  body: string;
  accentText?: string;
  footerText?: string;
  style: 'light' | 'dark' | 'gold';
  contentType: ShareContentType;
}

export interface DeepLinkParams {
  screen?: string;
  chapter?: string;
  journalId?: string;
  quizResult?: string;
  referrer?: string;
  campaign?: string;
}

export interface PlatformShareConfig {
  platform: SocialPlatform;
  url: string;
  text: string;
  canShare: boolean;
  iconName: string;
  label: string;
  color: string;
  supportsImages: boolean;
  maxTextLength: number;
}

// ─── Constants ──────────────────────────────────────────────────────────────────

const BASE_URL = 'https://luminousattachment.com';
const SHARE_URL = 'https://share.luminousattachment.com';
const APP_DEEP_LINK = 'luminous://';
const APP_STORE_URL = 'https://apps.apple.com/app/luminous-attachment/id0000000000';
const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.resonanceux.luminousattachment';

const DEFAULT_HASHTAGS = ['LuminousAttachment', 'SecureConnection', 'AttachmentTheory', 'ResonanceUX'];

const PLATFORM_CONFIGS: Record<SocialPlatform, Omit<PlatformShareConfig, 'url' | 'text' | 'canShare'>> = {
  twitter: {
    platform: 'twitter',
    iconName: 'twitter',
    label: 'X (Twitter)',
    color: '#000000',
    supportsImages: true,
    maxTextLength: 280,
  },
  facebook: {
    platform: 'facebook',
    iconName: 'facebook',
    label: 'Facebook',
    color: '#1877F2',
    supportsImages: true,
    maxTextLength: 63206,
  },
  instagram: {
    platform: 'instagram',
    iconName: 'instagram',
    label: 'Instagram Stories',
    color: '#E4405F',
    supportsImages: true,
    maxTextLength: 2200,
  },
  threads: {
    platform: 'threads',
    iconName: 'at-sign',
    label: 'Threads',
    color: '#000000',
    supportsImages: true,
    maxTextLength: 500,
  },
  bluesky: {
    platform: 'bluesky',
    iconName: 'cloud',
    label: 'Bluesky',
    color: '#0085FF',
    supportsImages: true,
    maxTextLength: 300,
  },
  mastodon: {
    platform: 'mastodon',
    iconName: 'message-circle',
    label: 'Mastodon',
    color: '#6364FF',
    supportsImages: true,
    maxTextLength: 500,
  },
  linkedin: {
    platform: 'linkedin',
    iconName: 'linkedin',
    label: 'LinkedIn',
    color: '#0A66C2',
    supportsImages: true,
    maxTextLength: 3000,
  },
  pinterest: {
    platform: 'pinterest',
    iconName: 'bookmark',
    label: 'Pinterest',
    color: '#BD081C',
    supportsImages: true,
    maxTextLength: 500,
  },
  whatsapp: {
    platform: 'whatsapp',
    iconName: 'message-circle',
    label: 'WhatsApp',
    color: '#25D366',
    supportsImages: true,
    maxTextLength: 65536,
  },
  telegram: {
    platform: 'telegram',
    iconName: 'send',
    label: 'Telegram',
    color: '#26A5E4',
    supportsImages: true,
    maxTextLength: 4096,
  },
  signal: {
    platform: 'signal',
    iconName: 'shield',
    label: 'Signal',
    color: '#3A76F0',
    supportsImages: true,
    maxTextLength: 65536,
  },
  reddit: {
    platform: 'reddit',
    iconName: 'message-square',
    label: 'Reddit',
    color: '#FF4500',
    supportsImages: false,
    maxTextLength: 40000,
  },
  tumblr: {
    platform: 'tumblr',
    iconName: 'pen-tool',
    label: 'Tumblr',
    color: '#36465D',
    supportsImages: true,
    maxTextLength: 65536,
  },
  email: {
    platform: 'email',
    iconName: 'mail',
    label: 'Email',
    color: '#6B7280',
    supportsImages: false,
    maxTextLength: 999999,
  },
  sms: {
    platform: 'sms',
    iconName: 'smartphone',
    label: 'Text Message',
    color: '#34C759',
    supportsImages: true,
    maxTextLength: 1600,
  },
  copy: {
    platform: 'copy',
    iconName: 'copy',
    label: 'Copy Link',
    color: '#9A7A3A',
    supportsImages: false,
    maxTextLength: 999999,
  },
  native: {
    platform: 'native',
    iconName: 'share-2',
    label: 'Share',
    color: '#C5A059',
    supportsImages: true,
    maxTextLength: 999999,
  },
};

// ─── Deep Link Generation ──────────────────────────────────────────────────────

export function generateDeepLink(params: DeepLinkParams): string {
  const searchParams = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value) searchParams.set(key, value);
  });
  return `${APP_DEEP_LINK}open?${searchParams.toString()}`;
}

export function generateUniversalLink(params: DeepLinkParams): string {
  const searchParams = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value) searchParams.set(key, value);
  });
  return `${BASE_URL}/link?${searchParams.toString()}`;
}

export function generateShareLink(content: ShareContent, referrer?: string): string {
  const slug = generateShareSlug(content);
  const params = new URLSearchParams();
  if (referrer) params.set('ref', referrer);
  params.set('utm_source', 'share');
  params.set('utm_medium', 'social');
  params.set('utm_campaign', content.type);
  return `${SHARE_URL}/${slug}?${params.toString()}`;
}

function generateShareSlug(content: ShareContent): string {
  const prefix = content.type.replace(/-/g, '');
  const slug = content.title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 60);
  const hash = simpleHash(content.title + content.text).toString(36).slice(0, 6);
  return `${prefix}/${slug}-${hash}`;
}

function simpleHash(str: string): number {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash |= 0;
  }
  return Math.abs(hash);
}

// ─── Platform-Specific Share URL Builders ───────────────────────────────────────

export function buildShareUrl(platform: SocialPlatform, content: ShareContent): string {
  const shareLink = content.url || generateShareLink(content);
  const text = formatShareText(platform, content);

  switch (platform) {
    case 'twitter':
      return buildTwitterUrl(text, shareLink, content.hashtags);
    case 'facebook':
      return buildFacebookUrl(shareLink, text);
    case 'linkedin':
      return buildLinkedInUrl(shareLink, content.title, text);
    case 'pinterest':
      return buildPinterestUrl(shareLink, content.imageUrl || '', text);
    case 'whatsapp':
      return buildWhatsAppUrl(text, shareLink);
    case 'telegram':
      return buildTelegramUrl(text, shareLink);
    case 'reddit':
      return buildRedditUrl(content.title, shareLink);
    case 'tumblr':
      return buildTumblrUrl(shareLink, content.title, text, content.hashtags);
    case 'threads':
      return buildThreadsUrl(text, shareLink);
    case 'bluesky':
      return buildBlueskyUrl(text, shareLink);
    case 'mastodon':
      return buildMastodonUrl(text, shareLink);
    case 'email':
      return buildEmailUrl(content.title, text, shareLink);
    case 'sms':
      return buildSmsUrl(text, shareLink);
    default:
      return shareLink;
  }
}

function buildTwitterUrl(text: string, url: string, hashtags?: string[]): string {
  const params = new URLSearchParams({ text, url });
  if (hashtags?.length) {
    params.set('hashtags', hashtags.join(','));
  }
  return `https://twitter.com/intent/tweet?${params.toString()}`;
}

function buildFacebookUrl(url: string, quote: string): string {
  const params = new URLSearchParams({ u: url, quote });
  return `https://www.facebook.com/sharer/sharer.php?${params.toString()}`;
}

function buildLinkedInUrl(url: string, title: string, summary: string): string {
  const params = new URLSearchParams({
    mini: 'true',
    url,
    title,
    summary,
    source: 'Luminous Attachment',
  });
  return `https://www.linkedin.com/shareArticle?${params.toString()}`;
}

function buildPinterestUrl(url: string, media: string, description: string): string {
  const params = new URLSearchParams({ url, media, description });
  return `https://pinterest.com/pin/create/button/?${params.toString()}`;
}

function buildWhatsAppUrl(text: string, url: string): string {
  const fullText = `${text}\n\n${url}`;
  return `https://api.whatsapp.com/send?text=${encodeURIComponent(fullText)}`;
}

function buildTelegramUrl(text: string, url: string): string {
  const params = new URLSearchParams({ url, text });
  return `https://t.me/share/url?${params.toString()}`;
}

function buildRedditUrl(title: string, url: string): string {
  const params = new URLSearchParams({ title, url });
  return `https://reddit.com/submit?${params.toString()}`;
}

function buildTumblrUrl(url: string, title: string, description: string, tags?: string[]): string {
  const params = new URLSearchParams({
    canonicalUrl: url,
    title,
    caption: description,
    posttype: 'link',
  });
  if (tags?.length) params.set('tags', tags.join(','));
  return `https://www.tumblr.com/widgets/share/tool?${params.toString()}`;
}

function buildThreadsUrl(text: string, url: string): string {
  return `https://www.threads.net/intent/post?text=${encodeURIComponent(`${text}\n\n${url}`)}`;
}

function buildBlueskyUrl(text: string, url: string): string {
  return `https://bsky.app/intent/compose?text=${encodeURIComponent(`${text}\n\n${url}`)}`;
}

function buildMastodonUrl(text: string, url: string): string {
  return `https://mastodon.social/share?text=${encodeURIComponent(`${text}\n\n${url}`)}`;
}

function buildEmailUrl(subject: string, body: string, url: string): string {
  const fullBody = `${body}\n\n${url}\n\n---\nSent from Luminous Attachment by Resonance UX\nIlluminate Your Path to Secure Connection`;
  return `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(fullBody)}`;
}

function buildSmsUrl(text: string, url: string): string {
  const body = `${text}\n${url}`;
  const separator = /iPhone|iPad|iPod/i.test(navigator.userAgent) ? '&' : '?';
  return `sms:${separator}body=${encodeURIComponent(body)}`;
}

// ─── Content Formatting ────────────────────────────────────────────────────────

export function formatShareText(platform: SocialPlatform, content: ShareContent): string {
  const config = PLATFORM_CONFIGS[platform];
  const maxLen = config.maxTextLength;

  let text: string;

  switch (content.type) {
    case 'quiz-result':
      text = formatQuizResult(content);
      break;
    case 'insight':
      text = formatInsight(content);
      break;
    case 'chapter-quote':
      text = formatChapterQuote(content);
      break;
    case 'journal-reflection':
      text = formatJournalReflection(content);
      break;
    case 'coach-moment':
      text = formatCoachMoment(content);
      break;
    case 'growth-milestone':
      text = formatGrowthMilestone(content);
      break;
    case 'attachment-style':
      text = formatAttachmentStyle(content);
      break;
    case 'audiobook-clip':
      text = formatAudiobookClip(content);
      break;
    case 'daily-prompt':
      text = formatDailyPrompt(content);
      break;
    default:
      text = content.text;
  }

  // Platform-specific adjustments
  if (platform === 'twitter' || platform === 'bluesky' || platform === 'threads') {
    const hashtagStr = (content.hashtags || DEFAULT_HASHTAGS.slice(0, 2))
      .map(t => `#${t}`)
      .join(' ');
    const withTags = `${text}\n\n${hashtagStr}`;
    text = withTags.length <= maxLen ? withTags : text;
  }

  if (platform === 'linkedin') {
    text = `${text}\n\n#AttachmentTheory #PersonalGrowth #MentalHealth #ResonanceUX`;
  }

  return truncateText(text, maxLen);
}

function formatQuizResult(content: ShareContent): string {
  const style = content.attachmentStyle || 'Secure';
  return `I just discovered my attachment style is "${style}" through Luminous Attachment. Understanding how we connect changes everything.`;
}

function formatInsight(content: ShareContent): string {
  return `"${content.quote || content.text}"\n\n-- from Luminous Attachment`;
}

function formatChapterQuote(content: ShareContent): string {
  const chapter = content.chapter ? `, Chapter: ${content.chapter}` : '';
  return `"${content.quote || content.text}"\n\n-- Luminous Attachment${chapter}`;
}

function formatJournalReflection(content: ShareContent): string {
  return `A reflection on my journey toward secure connection:\n\n"${content.text}"\n\n-- journaling with Luminous Attachment`;
}

function formatCoachMoment(content: ShareContent): string {
  return `My coach in Luminous Attachment shared something profound:\n\n"${content.text}"`;
}

function formatGrowthMilestone(content: ShareContent): string {
  const milestone = content.milestone || 'growth milestone';
  return `I just reached a ${milestone} on my attachment journey with Luminous Attachment. Every step toward secure connection matters.`;
}

function formatAttachmentStyle(content: ShareContent): string {
  const style = content.attachmentStyle || 'Secure';
  return `Understanding your attachment style is the first step to deeper connection. Mine is "${style}". What is yours?\n\nDiscover yours with Luminous Attachment.`;
}

function formatAudiobookClip(content: ShareContent): string {
  return `Listening to Luminous Attachment:\n\n"${content.quote || content.text}"\n\nThe audiobook that illuminates your path to secure connection.`;
}

function formatDailyPrompt(content: ShareContent): string {
  return `Today's reflection from Luminous Attachment:\n\n"${content.text}"\n\nWhat does this bring up for you?`;
}

function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength - 3) + '...';
}

// ─── Share Card Generation (Canvas-based) ──────────────────────────────────────

export function generateShareCardHtml(data: ShareCardData): string {
  const colors = {
    light: {
      bg: '#FAFAF8',
      text: '#0A1C14',
      accent: '#C5A059',
      subtle: '#D1E0D7',
      border: '#E8F0EA',
    },
    dark: {
      bg: '#05100B',
      text: '#E8F0EA',
      accent: '#C5A059',
      subtle: '#1B402E',
      border: '#122E21',
    },
    gold: {
      bg: 'linear-gradient(135deg, #0A1C14, #122E21)',
      text: '#E8F0EA',
      accent: '#E6D0A1',
      subtle: '#1B402E',
      border: '#C5A059',
    },
  };

  const c = colors[data.style];
  const bgStyle = data.style === 'gold'
    ? `background: ${c.bg};`
    : `background-color: ${c.bg};`;

  return `
    <div style="
      ${bgStyle}
      width: 1080px;
      height: 1080px;
      padding: 80px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      font-family: 'Manrope', sans-serif;
      position: relative;
      overflow: hidden;
      border: 2px solid ${c.border};
    ">
      <!-- Paper texture overlay -->
      <div style="
        position: absolute;
        inset: 0;
        opacity: 0.03;
        background-image: url('data:image/svg+xml,...');
        pointer-events: none;
      "></div>

      <!-- Organic blob -->
      <div style="
        position: absolute;
        top: -100px;
        right: -100px;
        width: 400px;
        height: 400px;
        border-radius: 60% 40% 30% 70% / 60% 30% 70% 40%;
        background: ${c.accent};
        opacity: 0.08;
      "></div>

      <!-- Content -->
      <div style="position: relative; z-index: 1;">
        ${data.accentText ? `
          <p style="
            color: ${c.accent};
            font-family: 'Manrope', sans-serif;
            font-size: 18px;
            letter-spacing: 3px;
            text-transform: uppercase;
            margin-bottom: 32px;
            font-weight: 600;
          ">${data.accentText}</p>
        ` : ''}

        <h2 style="
          color: ${c.text};
          font-family: 'Cormorant Garamond', serif;
          font-size: 56px;
          font-weight: 600;
          line-height: 1.2;
          margin-bottom: 32px;
        ">${data.headline}</h2>

        <p style="
          color: ${c.text};
          opacity: 0.8;
          font-size: 24px;
          line-height: 1.6;
          margin-bottom: 48px;
        ">${data.body}</p>
      </div>

      <!-- Footer -->
      <div style="
        position: absolute;
        bottom: 60px;
        left: 80px;
        right: 80px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top: 1px solid ${c.border};
        padding-top: 24px;
      ">
        <div>
          <span style="
            color: ${c.accent};
            font-family: 'Cormorant Garamond', serif;
            font-size: 22px;
            font-weight: 700;
          ">Luminous Attachment</span>
          <span style="
            color: ${c.text};
            opacity: 0.5;
            font-size: 16px;
            margin-left: 12px;
          ">by Resonance UX</span>
        </div>
        ${data.footerText ? `
          <span style="
            color: ${c.text};
            opacity: 0.5;
            font-size: 14px;
          ">${data.footerText}</span>
        ` : ''}
      </div>
    </div>
  `;
}

// ─── Share Card Data Builders ──────────────────────────────────────────────────

export function buildQuizResultCard(
  attachmentStyle: string,
  description: string,
  isDark: boolean = false
): ShareCardData {
  return {
    headline: `My Attachment Style: ${attachmentStyle}`,
    body: description,
    accentText: 'Attachment Quiz Result',
    footerText: 'luminousattachment.com/quiz',
    style: isDark ? 'dark' : 'gold',
    contentType: 'quiz-result',
  };
}

export function buildInsightCard(
  quote: string,
  source?: string,
  isDark: boolean = false
): ShareCardData {
  return {
    headline: `"${quote}"`,
    body: source ? `-- ${source}` : '',
    accentText: 'Daily Insight',
    footerText: 'luminousattachment.com',
    style: isDark ? 'dark' : 'light',
    contentType: 'insight',
  };
}

export function buildMilestoneCard(
  milestone: string,
  description: string,
  isDark: boolean = false
): ShareCardData {
  return {
    headline: milestone,
    body: description,
    accentText: 'Growth Milestone',
    footerText: 'luminousattachment.com',
    style: 'gold',
    contentType: 'growth-milestone',
  };
}

export function buildChapterQuoteCard(
  quote: string,
  chapter: string,
  isDark: boolean = false
): ShareCardData {
  return {
    headline: `"${quote}"`,
    body: `-- Chapter: ${chapter}`,
    accentText: 'From the Book',
    footerText: 'luminousattachment.com/book',
    style: isDark ? 'dark' : 'light',
    contentType: 'chapter-quote',
  };
}

// ─── Platform Detection ────────────────────────────────────────────────────────

export type RuntimePlatform = 'ios' | 'android' | 'macos' | 'windows' | 'linux' | 'web';

export function detectPlatform(): RuntimePlatform {
  const ua = navigator.userAgent;
  if (/iPad|iPhone|iPod/.test(ua)) return 'ios';
  if (/Android/.test(ua)) return 'android';
  if (/Macintosh/.test(ua)) return 'macos';
  if (/Windows/.test(ua)) return 'windows';
  if (/Linux/.test(ua)) return 'linux';
  return 'web';
}

export function isMobile(): boolean {
  const platform = detectPlatform();
  return platform === 'ios' || platform === 'android';
}

export function supportsNativeShare(): boolean {
  return typeof navigator !== 'undefined' && !!navigator.share;
}

export function supportsClipboard(): boolean {
  return typeof navigator !== 'undefined' && !!navigator.clipboard;
}

// ─── Available Platforms ───────────────────────────────────────────────────────

export function getAvailablePlatforms(): PlatformShareConfig[] {
  const mobile = isMobile();
  const all = Object.values(PLATFORM_CONFIGS).map(config => ({
    ...config,
    url: '',
    text: '',
    canShare: true,
  }));

  // Filter out platforms that only work on mobile
  return all.filter(p => {
    if (p.platform === 'instagram' && !mobile) return false;
    if (p.platform === 'sms' && !mobile) return false;
    if (p.platform === 'native' && !supportsNativeShare()) return false;
    return true;
  });
}

export function getPopularPlatforms(): SocialPlatform[] {
  const platform = detectPlatform();
  if (platform === 'ios' || platform === 'android') {
    return ['native', 'whatsapp', 'instagram', 'twitter', 'facebook', 'sms'];
  }
  return ['twitter', 'facebook', 'linkedin', 'whatsapp', 'reddit', 'email', 'copy'];
}

// ─── Open Graph Meta Tags ──────────────────────────────────────────────────────

export interface OGMetaTags {
  title: string;
  description: string;
  image: string;
  url: string;
  type: string;
  siteName: string;
  twitterCard: 'summary' | 'summary_large_image' | 'player';
  twitterSite: string;
}

export function generateOGTags(content: ShareContent): OGMetaTags {
  const url = content.url || generateShareLink(content);
  return {
    title: content.title || 'Luminous Attachment',
    description: content.text.slice(0, 200),
    image: content.imageUrl || `${BASE_URL}/og/default.jpg`,
    url,
    type: 'article',
    siteName: 'Luminous Attachment by Resonance UX',
    twitterCard: content.imageUrl ? 'summary_large_image' : 'summary',
    twitterSite: '@LuminousAttach',
  };
}

// ─── Download Links ────────────────────────────────────────────────────────────

export function getDownloadUrl(): string {
  const platform = detectPlatform();
  switch (platform) {
    case 'ios':
    case 'macos':
      return APP_STORE_URL;
    case 'android':
      return PLAY_STORE_URL;
    default:
      return `${BASE_URL}/download`;
  }
}

export function getSmartBannerConfig() {
  return {
    title: 'Luminous Attachment',
    author: 'Resonance UX',
    iconUrl: `${BASE_URL}/icon-512.png`,
    appStoreUrl: APP_STORE_URL,
    playStoreUrl: PLAY_STORE_URL,
    price: 'Free',
    priceSuffix: ' - In App Purchases',
  };
}

// ─── UTM & Tracking Helpers ────────────────────────────────────────────────────

export function addUtmParams(
  url: string,
  source: string,
  medium: string = 'social',
  campaign: string = 'share'
): string {
  const urlObj = new URL(url);
  urlObj.searchParams.set('utm_source', source);
  urlObj.searchParams.set('utm_medium', medium);
  urlObj.searchParams.set('utm_campaign', campaign);
  return urlObj.toString();
}

export function generateReferralCode(): string {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let code = 'LA-';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}

export function buildReferralLink(referralCode: string): string {
  return `${BASE_URL}/invite/${referralCode}`;
}
