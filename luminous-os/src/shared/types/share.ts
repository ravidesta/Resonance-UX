export type SharePlatform =
  | 'twitter'
  | 'linkedin'
  | 'facebook'
  | 'pinterest'
  | 'whatsapp'
  | 'threads'
  | 'bluesky'
  | 'telegram'
  | 'email'
  | 'copy-link'

export type ShareableType =
  | 'node'
  | 'room-vibe'
  | 'golden-hour'
  | 'activity-card'
  | 'portfolio-item'
  | 'milestone'
  | 'mind-map'

export interface ShareableContent {
  type: ShareableType
  title: string
  description: string
  tags: string[]
  /** The accent color for the share card */
  accentColor: string
  /** Optional image URL for the share card */
  imageUrl?: string
  /** Deep link back to the app */
  appUrl?: string
  /** Extra metadata for generating the share card */
  meta?: Record<string, string>
}

export interface SharePlatformConfig {
  id: SharePlatform
  label: string
  icon: string
  color: string
  buildUrl: (content: ShareableContent, text: string) => string
}

const APP_URL = 'https://luminous.app'

function encode(s: string) { return encodeURIComponent(s) }

export const sharePlatforms: SharePlatformConfig[] = [
  {
    id: 'twitter',
    label: 'X / Twitter',
    icon: 'Twitter',
    color: '#000000',
    buildUrl: (c, text) =>
      `https://twitter.com/intent/tweet?text=${encode(text)}&url=${encode(c.appUrl || APP_URL)}&hashtags=${c.tags.join(',')}`,
  },
  {
    id: 'linkedin',
    label: 'LinkedIn',
    icon: 'Linkedin',
    color: '#0A66C2',
    buildUrl: (c, text) =>
      `https://www.linkedin.com/sharing/share-offsite/?url=${encode(c.appUrl || APP_URL)}&title=${encode(c.title)}&summary=${encode(text)}`,
  },
  {
    id: 'facebook',
    label: 'Facebook',
    icon: 'Facebook',
    color: '#1877F2',
    buildUrl: (c, text) =>
      `https://www.facebook.com/sharer/sharer.php?u=${encode(c.appUrl || APP_URL)}&quote=${encode(text)}`,
  },
  {
    id: 'pinterest',
    label: 'Pinterest',
    icon: 'Image',
    color: '#E60023',
    buildUrl: (c, text) =>
      `https://pinterest.com/pin/create/button/?url=${encode(c.appUrl || APP_URL)}&description=${encode(text)}${c.imageUrl ? `&media=${encode(c.imageUrl)}` : ''}`,
  },
  {
    id: 'whatsapp',
    label: 'WhatsApp',
    icon: 'MessageCircle',
    color: '#25D366',
    buildUrl: (_c, text) =>
      `https://api.whatsapp.com/send?text=${encode(text)}`,
  },
  {
    id: 'threads',
    label: 'Threads',
    icon: 'AtSign',
    color: '#000000',
    buildUrl: (c, text) =>
      `https://www.threads.net/intent/post?text=${encode(text + '\n' + (c.appUrl || APP_URL))}`,
  },
  {
    id: 'bluesky',
    label: 'Bluesky',
    icon: 'Cloud',
    color: '#0085FF',
    buildUrl: (c, text) =>
      `https://bsky.app/intent/compose?text=${encode(text + '\n' + (c.appUrl || APP_URL))}`,
  },
  {
    id: 'telegram',
    label: 'Telegram',
    icon: 'Send',
    color: '#26A5E4',
    buildUrl: (c, text) =>
      `https://t.me/share/url?url=${encode(c.appUrl || APP_URL)}&text=${encode(text)}`,
  },
  {
    id: 'email',
    label: 'Email',
    icon: 'Mail',
    color: '#5C7065',
    buildUrl: (c, text) =>
      `mailto:?subject=${encode(c.title + ' — Luminous')}&body=${encode(text + '\n\n' + (c.appUrl || APP_URL))}`,
  },
  {
    id: 'copy-link',
    label: 'Copy Link',
    icon: 'Link',
    color: '#8A9C91',
    buildUrl: (c) => c.appUrl || APP_URL,
  },
]
