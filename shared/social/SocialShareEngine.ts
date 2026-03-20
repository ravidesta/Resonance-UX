// SocialShareEngine.ts — Universal social sharing for Luminous Attachment by Resonance UX
// Supports sharing beautiful cards to all major social platforms as free advertising

export type ShareCardType = 'quote' | 'insight' | 'progress' | 'journal' | 'coach' | 'milestone' | 'gratitude';

export interface ShareCard {
  type: ShareCardType;
  title: string;
  body: string;
  attribution?: string;
  imageDataUrl?: string;
  tags: string[];
  brandingText: string;
  appUrl: string;
}

export interface ShareAnalytics {
  platform: string;
  cardType: ShareCardType;
  timestamp: number;
  success: boolean;
}

const BRANDING = {
  text: 'Luminous Attachment by Resonance',
  tagline: 'Illuminate Your Path to Secure Connection',
  appUrl: 'https://resonance.app/luminous-attachment',
  hashtags: ['LuminousAttachment', 'Resonance', 'AttachmentHealing', 'SecureAttachment', 'HealingJourney'],
  iosUrl: 'https://apps.apple.com/app/luminous-attachment',
  androidUrl: 'https://play.google.com/store/apps/details?id=com.resonance.luminous',
};

const DAILY_QUOTES = [
  { text: 'Your attachment style is not your destiny. It is your starting point.', author: 'Luminous Attachment' },
  { text: 'The wound is where the light enters you.', author: 'Rumi' },
  { text: 'Healing is not linear. Every step inward is a step forward.', author: 'Luminous Attachment' },
  { text: 'You are not broken. You are a nervous system that learned to protect itself brilliantly.', author: 'Luminous Attachment' },
  { text: 'Secure attachment is not the absence of fear. It is the presence of courage to stay.', author: 'Luminous Attachment' },
  { text: 'Your body remembers what your mind has forgotten. Listen to it with compassion.', author: 'Luminous Attachment' },
  { text: 'Every rupture repaired builds a stronger bridge than the one that broke.', author: 'Luminous Attachment' },
  { text: 'The first secure relationship you need is with yourself.', author: 'Luminous Attachment' },
  { text: 'Boundaries are not walls. They are the doors through which love enters safely.', author: 'Luminous Attachment' },
  { text: 'You can earn security at any age. Your brain is waiting to learn new patterns of love.', author: 'Luminous Attachment' },
];

// --- Share Card Generation ---

export function generateShareCard(type: ShareCardType, content: { title?: string; body: string; attribution?: string }): ShareCard {
  return {
    type,
    title: content.title || getDefaultTitle(type),
    body: content.body,
    attribution: content.attribution,
    tags: BRANDING.hashtags,
    brandingText: BRANDING.text,
    appUrl: BRANDING.appUrl,
  };
}

export function generateQuoteCard(quote?: string, author?: string): ShareCard {
  const selected = quote ? { text: quote, author: author || '' } : DAILY_QUOTES[Math.floor(Math.random() * DAILY_QUOTES.length)];
  return generateShareCard('quote', {
    title: 'Daily Insight',
    body: `"${selected.text}"`,
    attribution: selected.author ? `— ${selected.author}` : undefined,
  });
}

export function generateInsightCard(insight: string): ShareCard {
  return generateShareCard('insight', {
    title: "Today's Insight",
    body: insight,
    attribution: 'From my healing journey',
  });
}

export function generateProgressCard(data: { streak: number; entries: number; style: string }): ShareCard {
  return generateShareCard('progress', {
    title: 'My Growth Journey',
    body: `${data.streak} day streak · ${data.entries} journal entries · Moving toward ${data.style} attachment`,
  });
}

export function generateJournalExcerptCard(excerpt: string): ShareCard {
  const blurred = excerpt.length > 120 ? excerpt.substring(0, 120) + '...' : excerpt;
  return generateShareCard('journal', {
    title: 'A Moment of Reflection',
    body: blurred,
    attribution: 'From my journal',
  });
}

export function generateCoachWisdomCard(wisdom: string): ShareCard {
  return generateShareCard('coach', {
    title: 'Coach Wisdom',
    body: `"${wisdom}"`,
    attribution: '— Luminous Attachment Coach',
  });
}

export function generateMilestoneCard(milestone: string): ShareCard {
  return generateShareCard('milestone', {
    title: 'Milestone Reached',
    body: milestone,
  });
}

export function generateGratitudeCard(gratitude: string): ShareCard {
  return generateShareCard('gratitude', {
    title: "Today I'm Grateful For",
    body: gratitude,
  });
}

export function generateStoryTemplate(card: ShareCard): { width: number; height: number; card: ShareCard } {
  return { width: 1080, height: 1920, card };
}

// --- Platform-Specific Sharing ---

function formatShareText(card: ShareCard, maxLength?: number): string {
  const hashtags = card.tags.slice(0, 3).map(t => `#${t}`).join(' ');
  let text = `${card.body}\n\n${card.attribution || ''}\n\n${hashtags}\n\n${BRANDING.tagline}\n${card.appUrl}`;
  if (maxLength && text.length > maxLength) {
    const overflow = text.length - maxLength;
    const shortenedBody = card.body.substring(0, card.body.length - overflow - 3) + '...';
    text = `${shortenedBody}\n\n${hashtags}\n${card.appUrl}`;
  }
  return text.trim();
}

function getDefaultTitle(type: ShareCardType): string {
  const titles: Record<ShareCardType, string> = {
    quote: 'Daily Insight',
    insight: "Today's Reflection",
    progress: 'My Growth Journey',
    journal: 'A Moment of Reflection',
    coach: 'Coach Wisdom',
    milestone: 'Milestone Reached',
    gratitude: 'Gratitude',
  };
  return titles[type];
}

export function getShareUrl(platform: string, card: ShareCard): string {
  const text = encodeURIComponent(formatShareText(card));
  const url = encodeURIComponent(card.appUrl);
  const shortText = encodeURIComponent(formatShareText(card, 280));

  const urls: Record<string, string> = {
    twitter: `https://twitter.com/intent/tweet?text=${shortText}`,
    x: `https://twitter.com/intent/tweet?text=${shortText}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${url}&quote=${text}`,
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${url}&summary=${text}`,
    pinterest: `https://pinterest.com/pin/create/button/?url=${url}&description=${text}`,
    reddit: `https://www.reddit.com/submit?url=${url}&title=${encodeURIComponent(card.title)}`,
    whatsapp: `https://wa.me/?text=${text}`,
    telegram: `https://t.me/share/url?url=${url}&text=${text}`,
    threads: `https://threads.net/intent/post?text=${shortText}`,
    tumblr: `https://www.tumblr.com/widgets/share/tool?posttype=quote&tags=${encodeURIComponent(card.tags.join(','))}&content=${text}`,
    email: `mailto:?subject=${encodeURIComponent(`${card.title} — Luminous Attachment`)}&body=${text}`,
    sms: `sms:?body=${text}`,
    snapchat: `https://www.snapchat.com/scan?attachmentUrl=${url}`,
    tiktok: `https://www.tiktok.com/`,
    instagram: `https://www.instagram.com/`,
  };

  return urls[platform.toLowerCase()] || urls.twitter;
}

export function shareToTwitter(card: ShareCard): void { window.open(getShareUrl('twitter', card), '_blank', 'width=600,height=400'); }
export function shareToFacebook(card: ShareCard): void { window.open(getShareUrl('facebook', card), '_blank', 'width=600,height=400'); }
export function shareToLinkedIn(card: ShareCard): void { window.open(getShareUrl('linkedin', card), '_blank', 'width=600,height=400'); }
export function shareToPinterest(card: ShareCard): void { window.open(getShareUrl('pinterest', card), '_blank', 'width=600,height=400'); }
export function shareToReddit(card: ShareCard): void { window.open(getShareUrl('reddit', card), '_blank', 'width=600,height=400'); }
export function shareToWhatsApp(card: ShareCard): void { window.open(getShareUrl('whatsapp', card), '_blank'); }
export function shareToTelegram(card: ShareCard): void { window.open(getShareUrl('telegram', card), '_blank'); }
export function shareToThreads(card: ShareCard): void { window.open(getShareUrl('threads', card), '_blank'); }
export function shareToEmail(card: ShareCard): void { window.location.href = getShareUrl('email', card); }
export function shareToSMS(card: ShareCard): void { window.location.href = getShareUrl('sms', card); }
export function shareToSnapchat(card: ShareCard): void { window.open(getShareUrl('snapchat', card), '_blank'); }
export function shareToTikTok(card: ShareCard): void { window.open(getShareUrl('tiktok', card), '_blank'); }
export function shareToInstagram(card: ShareCard): void { window.open(getShareUrl('instagram', card), '_blank'); }

export async function shareWithWebShareAPI(card: ShareCard): Promise<boolean> {
  if (!navigator.share) return false;
  try {
    await navigator.share({
      title: `${card.title} — Luminous Attachment`,
      text: formatShareText(card),
      url: card.appUrl,
    });
    trackShareAnalytics('webshare', card.type, true);
    return true;
  } catch {
    return false;
  }
}

export function shareToAll(card: ShareCard, platform: string): void {
  const shareFns: Record<string, (c: ShareCard) => void> = {
    twitter: shareToTwitter, x: shareToTwitter, facebook: shareToFacebook,
    linkedin: shareToLinkedIn, pinterest: shareToPinterest, reddit: shareToReddit,
    whatsapp: shareToWhatsApp, telegram: shareToTelegram, threads: shareToThreads,
    email: shareToEmail, sms: shareToSMS, snapchat: shareToSnapchat,
    tiktok: shareToTikTok, instagram: shareToInstagram,
  };
  const fn = shareFns[platform.toLowerCase()];
  if (fn) {
    fn(card);
    trackShareAnalytics(platform, card.type, true);
  }
}

// --- Analytics ---

const shareLog: ShareAnalytics[] = [];

export function trackShareAnalytics(platform: string, cardType: ShareCardType, success: boolean): void {
  shareLog.push({ platform, cardType, timestamp: Date.now(), success });
  try { localStorage.setItem('resonance_share_log', JSON.stringify(shareLog)); } catch {}
}

export function getShareStats(): { total: number; byPlatform: Record<string, number>; byType: Record<string, number>; reach: number } {
  const byPlatform: Record<string, number> = {};
  const byType: Record<string, number> = {};
  shareLog.forEach(s => {
    byPlatform[s.platform] = (byPlatform[s.platform] || 0) + 1;
    byType[s.cardType] = (byType[s.cardType] || 0) + 1;
  });
  return { total: shareLog.length, byPlatform, byType, reach: shareLog.length * 147 };
}

export function loadShareLog(): void {
  try {
    const stored = localStorage.getItem('resonance_share_log');
    if (stored) shareLog.push(...JSON.parse(stored));
  } catch {}
}
