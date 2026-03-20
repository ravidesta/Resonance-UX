/**
 * SharingService — Resonance UX "Luminous Attachment"
 *
 * Handles sharing to every major social platform with platform-optimised
 * content, deep links, and analytics tracking.
 *
 * In production this module integrates with:
 *   - react-native-share (generic share sheet + image sharing)
 *   - react-native-view-shot (card → image capture)
 *   - @react-native-clipboard/clipboard
 *   - Platform deep-link schemes
 *   - Analytics SDK (Amplitude / Mixpanel / PostHog)
 */

import { Linking, Share, Platform, Alert } from 'react-native';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

export type SocialPlatform =
  | 'twitter'
  | 'instagram'
  | 'instagram_stories'
  | 'tiktok'
  | 'facebook'
  | 'whatsapp'
  | 'telegram'
  | 'pinterest'
  | 'linkedin'
  | 'threads'
  | 'snapchat'
  | 'reddit'
  | 'email'
  | 'sms'
  | 'copy'
  | 'more';

export interface ShareCardData {
  type: string;
  title: string;
  body: string;
  subtitle?: string;
  author?: string;
  stat?: string;
  emoji?: string;
}

interface ShareAnalyticsEvent {
  platform: SocialPlatform;
  cardType: string;
  timestamp: number;
  success: boolean;
}

// ---------------------------------------------------------------------------
// Platform metadata
// ---------------------------------------------------------------------------

const PLATFORM_META: Record<
  SocialPlatform,
  {
    scheme?: string;
    iosPackage?: string;
    androidPackage?: string;
    webFallback?: string;
    maxTextLength?: number;
    supportsImages: boolean;
    supportsStories: boolean;
  }
> = {
  twitter: {
    scheme: 'twitter://post?message=',
    androidPackage: 'com.twitter.android',
    iosPackage: 'com.atebits.Tweetie2',
    webFallback: 'https://twitter.com/intent/tweet?text=',
    maxTextLength: 280,
    supportsImages: true,
    supportsStories: false,
  },
  instagram: {
    scheme: 'instagram://library?AssetPath=',
    androidPackage: 'com.instagram.android',
    webFallback: 'https://www.instagram.com/',
    supportsImages: true,
    supportsStories: false,
  },
  instagram_stories: {
    scheme: 'instagram-stories://share',
    androidPackage: 'com.instagram.android',
    supportsImages: true,
    supportsStories: true,
  },
  tiktok: {
    scheme: 'snssdk1128://',
    androidPackage: 'com.zhiliaoapp.musically',
    webFallback: 'https://www.tiktok.com/',
    supportsImages: true,
    supportsStories: false,
  },
  facebook: {
    scheme: 'fb://publish/profile/me?text=',
    androidPackage: 'com.facebook.katana',
    webFallback: 'https://www.facebook.com/sharer/sharer.php?quote=',
    supportsImages: true,
    supportsStories: false,
  },
  whatsapp: {
    scheme: 'whatsapp://send?text=',
    androidPackage: 'com.whatsapp',
    webFallback: 'https://api.whatsapp.com/send?text=',
    supportsImages: true,
    supportsStories: false,
  },
  telegram: {
    scheme: 'tg://msg?text=',
    androidPackage: 'org.telegram.messenger',
    webFallback: 'https://t.me/share/url?text=',
    supportsImages: true,
    supportsStories: false,
  },
  pinterest: {
    scheme: 'pinterest://pin/create/button/',
    androidPackage: 'com.pinterest',
    webFallback: 'https://pinterest.com/pin/create/button/?description=',
    supportsImages: true,
    supportsStories: false,
  },
  linkedin: {
    scheme: 'linkedin://shareArticle?mini=true&summary=',
    androidPackage: 'com.linkedin.android',
    webFallback: 'https://www.linkedin.com/shareArticle?mini=true&summary=',
    supportsImages: false,
    supportsStories: false,
  },
  threads: {
    scheme: 'barcelona://create?text=',
    androidPackage: 'com.instagram.barcelona',
    webFallback: 'https://www.threads.net/intent/post?text=',
    maxTextLength: 500,
    supportsImages: true,
    supportsStories: false,
  },
  snapchat: {
    scheme: 'snapchat://',
    androidPackage: 'com.snapchat.android',
    supportsImages: true,
    supportsStories: true,
  },
  reddit: {
    scheme: 'reddit://submit?title=',
    androidPackage: 'com.reddit.frontpage',
    webFallback: 'https://www.reddit.com/submit?title=',
    supportsImages: false,
    supportsStories: false,
  },
  email: {
    scheme: 'mailto:?subject=',
    supportsImages: false,
    supportsStories: false,
  },
  sms: {
    scheme: 'sms:&body=',
    supportsImages: false,
    supportsStories: false,
  },
  copy: {
    supportsImages: false,
    supportsStories: false,
  },
  more: {
    supportsImages: true,
    supportsStories: false,
  },
};

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const APP_URL = 'https://resonance.app/luminous';
const APP_HASHTAGS = '#Resonance #LuminousAttachment #InnerWork';
const APP_NAME = 'Luminous Attachment by Resonance UX';

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

export class SharingService {
  private analyticsLog: ShareAnalyticsEvent[] = [];

  // -------------------------------------------------------------------------
  // Public share method
  // -------------------------------------------------------------------------

  async share(platform: SocialPlatform, card: ShareCardData): Promise<void> {
    const success = await this.dispatchShare(platform, card);
    this.trackAnalytics(platform, card.type, success);
  }

  // -------------------------------------------------------------------------
  // Dispatch to platform-specific handler
  // -------------------------------------------------------------------------

  private async dispatchShare(
    platform: SocialPlatform,
    card: ShareCardData,
  ): Promise<boolean> {
    try {
      switch (platform) {
        case 'twitter':
          return this.shareToTwitter(card);
        case 'instagram':
          return this.shareToInstagram(card);
        case 'instagram_stories':
          return this.shareToInstagramStories(card);
        case 'tiktok':
          return this.shareToTikTok(card);
        case 'facebook':
          return this.shareToFacebook(card);
        case 'whatsapp':
          return this.shareToWhatsApp(card);
        case 'telegram':
          return this.shareToTelegram(card);
        case 'pinterest':
          return this.shareToPinterest(card);
        case 'linkedin':
          return this.shareToLinkedIn(card);
        case 'threads':
          return this.shareToThreads(card);
        case 'snapchat':
          return this.shareToSnapchat(card);
        case 'reddit':
          return this.shareToReddit(card);
        case 'email':
          return this.shareViaEmail(card);
        case 'sms':
          return this.shareViaSMS(card);
        case 'copy':
          return this.copyToClipboard(card);
        case 'more':
        default:
          return this.shareViaSystemSheet(card);
      }
    } catch (err) {
      console.warn(`[SharingService] Error sharing to ${platform}:`, err);
      // Fallback to system share sheet
      return this.shareViaSystemSheet(card);
    }
  }

  // -------------------------------------------------------------------------
  // Platform implementations
  // -------------------------------------------------------------------------

  private async shareToTwitter(card: ShareCardData): Promise<boolean> {
    const text = this.buildTwitterText(card);
    const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`;

    // Try native app first
    const nativeUrl = `twitter://post?message=${encodeURIComponent(text)}`;
    if (await Linking.canOpenURL(nativeUrl)) {
      await Linking.openURL(nativeUrl);
      return true;
    }

    await Linking.openURL(url);
    return true;
  }

  private async shareToInstagram(card: ShareCardData): Promise<boolean> {
    // Instagram requires sharing an image via the share sheet.
    // In production, use react-native-view-shot to capture the card,
    // then use react-native-share with the Instagram package.
    // For now, open Instagram with a fallback.

    const nativeUrl = 'instagram://app';
    if (await Linking.canOpenURL(nativeUrl)) {
      // In production: Share.open({ url: cardImageUri, social: Share.Social.INSTAGRAM })
      await Linking.openURL(nativeUrl);
      return true;
    }

    await Linking.openURL('https://www.instagram.com/');
    return true;
  }

  private async shareToInstagramStories(card: ShareCardData): Promise<boolean> {
    // Instagram Stories sharing uses a custom URL scheme with an image asset.
    // Production flow:
    //   1. Capture card view as image via react-native-view-shot
    //   2. Use react-native-share: Share.open({
    //        social: Share.Social.INSTAGRAM_STORIES,
    //        backgroundImage: cardImageUri,
    //        stickerImage: logoUri,
    //        backgroundBottomColor: '#0A1C14',
    //        backgroundTopColor: '#1B402E',
    //        attributionURL: APP_URL,
    //      })

    const nativeUrl = 'instagram-stories://share';
    if (await Linking.canOpenURL(nativeUrl)) {
      // Placeholder: In production the image data is passed via pasteboard/intent
      await Linking.openURL(nativeUrl);
      return true;
    }

    return this.shareViaSystemSheet(card);
  }

  private async shareToTikTok(card: ShareCardData): Promise<boolean> {
    // TikTok sharing typically involves the TikTok SDK for native integration.
    // Fallback: open TikTok app or browser.

    const nativeUrl = 'snssdk1128://';
    if (await Linking.canOpenURL(nativeUrl)) {
      await Linking.openURL(nativeUrl);
      return true;
    }

    await Linking.openURL('https://www.tiktok.com/');
    return true;
  }

  private async shareToFacebook(card: ShareCardData): Promise<boolean> {
    const text = this.buildGenericText(card);
    const url = `https://www.facebook.com/sharer/sharer.php?quote=${encodeURIComponent(text)}&u=${encodeURIComponent(APP_URL)}`;

    const nativeUrl = `fb://publish/profile/me?text=${encodeURIComponent(text)}`;
    if (await Linking.canOpenURL(nativeUrl)) {
      await Linking.openURL(nativeUrl);
      return true;
    }

    await Linking.openURL(url);
    return true;
  }

  private async shareToWhatsApp(card: ShareCardData): Promise<boolean> {
    const text = this.buildGenericText(card);
    const url = `whatsapp://send?text=${encodeURIComponent(text)}`;

    if (await Linking.canOpenURL(url)) {
      await Linking.openURL(url);
      return true;
    }

    await Linking.openURL(`https://api.whatsapp.com/send?text=${encodeURIComponent(text)}`);
    return true;
  }

  private async shareToTelegram(card: ShareCardData): Promise<boolean> {
    const text = this.buildGenericText(card);
    const url = `tg://msg?text=${encodeURIComponent(text)}`;

    if (await Linking.canOpenURL(url)) {
      await Linking.openURL(url);
      return true;
    }

    await Linking.openURL(`https://t.me/share/url?url=${encodeURIComponent(APP_URL)}&text=${encodeURIComponent(text)}`);
    return true;
  }

  private async shareToPinterest(card: ShareCardData): Promise<boolean> {
    const description = this.buildGenericText(card);
    const url = `https://pinterest.com/pin/create/button/?url=${encodeURIComponent(APP_URL)}&description=${encodeURIComponent(description)}`;
    await Linking.openURL(url);
    return true;
  }

  private async shareToLinkedIn(card: ShareCardData): Promise<boolean> {
    const text = this.buildProfessionalText(card);
    const url = `https://www.linkedin.com/shareArticle?mini=true&url=${encodeURIComponent(APP_URL)}&summary=${encodeURIComponent(text)}`;
    await Linking.openURL(url);
    return true;
  }

  private async shareToThreads(card: ShareCardData): Promise<boolean> {
    const text = this.buildThreadsText(card);

    const nativeUrl = `barcelona://create?text=${encodeURIComponent(text)}`;
    if (await Linking.canOpenURL(nativeUrl)) {
      await Linking.openURL(nativeUrl);
      return true;
    }

    const webUrl = `https://www.threads.net/intent/post?text=${encodeURIComponent(text)}`;
    await Linking.openURL(webUrl);
    return true;
  }

  private async shareToSnapchat(card: ShareCardData): Promise<boolean> {
    // Snapchat requires the Snap Creative Kit SDK for full integration.
    // Fallback: open Snapchat.
    const nativeUrl = 'snapchat://';
    if (await Linking.canOpenURL(nativeUrl)) {
      await Linking.openURL(nativeUrl);
      return true;
    }

    return this.shareViaSystemSheet(card);
  }

  private async shareToReddit(card: ShareCardData): Promise<boolean> {
    const title = this.buildRedditTitle(card);
    const url = `https://www.reddit.com/submit?title=${encodeURIComponent(title)}&url=${encodeURIComponent(APP_URL)}`;
    await Linking.openURL(url);
    return true;
  }

  private async shareViaEmail(card: ShareCardData): Promise<boolean> {
    const subject = `From Luminous Attachment \u2014 ${card.title}`;
    const body = this.buildEmailBody(card);
    const url = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
    await Linking.openURL(url);
    return true;
  }

  private async shareViaSMS(card: ShareCardData): Promise<boolean> {
    const text = this.buildGenericText(card);
    const separator = Platform.OS === 'ios' ? '&' : '?';
    const url = `sms:${separator}body=${encodeURIComponent(text)}`;
    await Linking.openURL(url);
    return true;
  }

  private async copyToClipboard(card: ShareCardData): Promise<boolean> {
    const text = this.buildGenericText(card);
    // In production: Clipboard.setString(text)
    // Using Alert as a placeholder since Clipboard requires native module
    Alert.alert('Copied!', 'Card content copied to clipboard.');
    return true;
  }

  private async shareViaSystemSheet(card: ShareCardData): Promise<boolean> {
    const text = this.buildGenericText(card);
    const result = await Share.share(
      {
        message: text,
        title: card.title,
        url: APP_URL,
      },
      {
        dialogTitle: 'Share from Luminous Attachment',
        subject: card.title,
      },
    );
    return result.action === Share.sharedAction;
  }

  // -------------------------------------------------------------------------
  // Platform-optimised text builders
  // -------------------------------------------------------------------------

  private buildTwitterText(card: ShareCardData): string {
    let body: string;
    switch (card.type) {
      case 'quote':
        body = `\u201C${card.body}\u201D \u2014 ${card.author ?? ''}`;
        break;
      case 'progress':
        body = `${card.emoji ?? ''} ${card.body}`;
        break;
      case 'milestone':
        body = `${card.emoji ?? ''} ${card.body}`;
        break;
      default:
        body = card.body;
    }
    const hashtags = '\n\n#Resonance #LuminousAttachment #InnerWork #Growth';
    const link = `\n${APP_URL}`;
    const full = body + hashtags + link;

    // Trim to 280 chars
    if (full.length > 280) {
      const available = 280 - hashtags.length - link.length - 3;
      return body.substring(0, available) + '...' + hashtags + link;
    }
    return full;
  }

  private buildThreadsText(card: ShareCardData): string {
    const body = card.type === 'quote'
      ? `\u201C${card.body}\u201D \u2014 ${card.author ?? ''}`
      : card.body;

    return `${body}\n\n${APP_HASHTAGS}\n\nvia ${APP_NAME}\n${APP_URL}`;
  }

  private buildProfessionalText(card: ShareCardData): string {
    const body = card.type === 'quote'
      ? `\u201C${card.body}\u201D \u2014 ${card.author ?? ''}`
      : card.body;

    return `${body}\n\nFrom ${APP_NAME} \u2014 a companion app for inner work and personal growth.\n${APP_URL}`;
  }

  private buildRedditTitle(card: ShareCardData): string {
    switch (card.type) {
      case 'quote':
        return `\u201C${card.body}\u201D \u2014 ${card.author ?? ''} (from Luminous Attachment)`;
      case 'milestone':
        return `${card.emoji ?? ''} ${card.body} \u2014 sharing my inner work journey`;
      default:
        return `${card.title}: ${card.body.substring(0, 100)}`;
    }
  }

  private buildEmailBody(card: ShareCardData): string {
    let body: string;
    switch (card.type) {
      case 'quote':
        body = `\u201C${card.body}\u201D\n\u2014 ${card.author ?? ''}`;
        break;
      case 'progress':
        body = `${card.emoji ?? ''} ${card.body}\n\n${card.subtitle ?? ''}`;
        break;
      default:
        body = card.body;
    }

    return [
      body,
      '',
      card.subtitle ? card.subtitle : '',
      '',
      '---',
      '',
      'Shared from Luminous Attachment by Resonance UX',
      'A companion app for inner work and personal growth.',
      '',
      `Download: ${APP_URL}`,
      'Available on App Store and Google Play',
    ]
      .filter(Boolean)
      .join('\n');
  }

  private buildGenericText(card: ShareCardData): string {
    let body: string;
    switch (card.type) {
      case 'quote':
        body = `\u201C${card.body}\u201D\n\u2014 ${card.author ?? ''}`;
        break;
      case 'progress':
      case 'milestone':
        body = `${card.emoji ?? ''} ${card.body}`;
        break;
      default:
        body = card.body;
    }

    return [
      body,
      card.subtitle ?? '',
      '',
      `From ${APP_NAME}`,
      `Download: ${APP_URL}`,
    ]
      .filter(Boolean)
      .join('\n');
  }

  // -------------------------------------------------------------------------
  // Analytics
  // -------------------------------------------------------------------------

  private trackAnalytics(
    platform: SocialPlatform,
    cardType: string,
    success: boolean,
  ): void {
    const event: ShareAnalyticsEvent = {
      platform,
      cardType,
      timestamp: Date.now(),
      success,
    };

    this.analyticsLog.push(event);

    // In production, send to analytics SDK:
    // analytics.track('social_share', {
    //   platform,
    //   card_type: cardType,
    //   success,
    //   app_version: DeviceInfo.getVersion(),
    //   os: Platform.OS,
    // });

    console.log('[SharingService] Analytics:', event);
  }

  // -------------------------------------------------------------------------
  // Public analytics accessors
  // -------------------------------------------------------------------------

  getShareCount(): number {
    return this.analyticsLog.length;
  }

  getShareCountByPlatform(): Record<string, number> {
    return this.analyticsLog.reduce(
      (acc, e) => {
        acc[e.platform] = (acc[e.platform] ?? 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );
  }

  getMostSharedCardType(): string | null {
    const counts = this.analyticsLog.reduce(
      (acc, e) => {
        acc[e.cardType] = (acc[e.cardType] ?? 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    let max = 0;
    let result: string | null = null;
    for (const [type, count] of Object.entries(counts)) {
      if (count > max) {
        max = count;
        result = type;
      }
    }
    return result;
  }

  getSuccessRate(): number {
    if (this.analyticsLog.length === 0) return 0;
    const successful = this.analyticsLog.filter((e) => e.success).length;
    return successful / this.analyticsLog.length;
  }
}
