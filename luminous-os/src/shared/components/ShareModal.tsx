import { useState } from 'react'
import { X, Check, ExternalLink } from 'lucide-react'
import * as Icons from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import type { ShareableContent, SharePlatform } from '@/shared/types/share'
import { sharePlatforms } from '@/shared/types/share'
import {
  generateShareText,
  openShareUrl,
  copyToClipboard,
} from '@/shared/services/shareService'

interface ShareModalProps {
  content: ShareableContent
  onClose: () => void
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function getIcon(name: string): React.FC<any> {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return (Icons as any)[name] || Icons.Share2
}

export function ShareModal({ content, onClose }: ShareModalProps) {
  const [copied, setCopied] = useState(false)
  const [editedText, setEditedText] = useState(generateShareText(content))

  const handleShare = (platformId: SharePlatform) => {
    const platform = sharePlatforms.find(p => p.id === platformId)
    if (!platform) return

    if (platformId === 'copy-link') {
      copyToClipboard(editedText + '\n\n' + (content.appUrl || 'https://luminous.app')).then(ok => {
        if (ok) {
          setCopied(true)
          setTimeout(() => setCopied(false), 2000)
        }
      })
      return
    }

    const url = platform.buildUrl(content, editedText)
    openShareUrl(url)
  }

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-[100] flex items-center justify-center" onClick={onClose}>
        {/* Backdrop */}
        <motion.div
          className="absolute inset-0 bg-black/30 backdrop-blur-sm"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        />

        {/* Modal */}
        <motion.div
          className="relative glass-panel rounded-2xl overflow-hidden max-w-md w-full mx-4"
          style={{ boxShadow: 'var(--shadow-glass)' }}
          initial={{ opacity: 0, scale: 0.9, y: 20 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.9, y: 20 }}
          transition={{ type: 'spring', damping: 25, stiffness: 300 }}
          onClick={e => e.stopPropagation()}
        >
          {/* Share card preview */}
          <div
            className="relative p-5 overflow-hidden"
            style={{
              background: `linear-gradient(135deg, ${content.accentColor}15, ${content.accentColor}05)`,
            }}
          >
            {/* Decorative accent line */}
            <div
              className="absolute top-0 left-0 right-0 h-1"
              style={{ background: `linear-gradient(90deg, ${content.accentColor}, transparent)` }}
            />

            {/* Close button */}
            <button
              onClick={onClose}
              className="absolute top-3 right-3 p-1.5 rounded-full hover:bg-[var(--color-bg-glass)] transition-colors"
            >
              <X size={16} style={{ color: 'var(--color-text-muted)' }} />
            </button>

            {/* Content preview */}
            <div className="flex items-start gap-3">
              <div
                className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                style={{ background: `${content.accentColor}20` }}
              >
                <span className="font-serif text-lg" style={{ color: content.accentColor }}>
                  {content.type === 'golden-hour' ? '☀' :
                   content.type === 'milestone' ? '✦' :
                   content.type === 'mind-map' ? '◎' :
                   content.type === 'activity-card' ? '◆' :
                   content.type === 'room-vibe' ? '◇' :
                   '○'}
                </span>
              </div>
              <div className="min-w-0">
                <h3
                  className="font-serif text-base font-semibold leading-tight"
                  style={{ color: 'var(--color-text-main)' }}
                >
                  {content.title}
                </h3>
                <p
                  className="font-sans text-xs mt-1 leading-relaxed line-clamp-2"
                  style={{ color: 'var(--color-text-muted)' }}
                >
                  {content.description}
                </p>
              </div>
            </div>

            {/* Tags */}
            <div className="flex flex-wrap gap-1 mt-3">
              {content.tags.map(tag => (
                <span
                  key={tag}
                  className="font-sans text-[9px] px-2 py-0.5 rounded-full"
                  style={{
                    background: `${content.accentColor}12`,
                    color: content.accentColor,
                    border: `1px solid ${content.accentColor}25`,
                  }}
                >
                  #{tag}
                </span>
              ))}
            </div>

            {/* Luminous branding watermark */}
            <div className="flex items-center gap-1.5 mt-3 pt-3 border-t" style={{ borderColor: 'var(--color-border-light)' }}>
              <div className="w-4 h-4 rounded-full" style={{ background: 'var(--color-gold-primary)' }} />
              <span className="font-serif text-[10px] font-medium" style={{ color: 'var(--color-text-light)' }}>
                Made with Luminous
              </span>
              <ExternalLink size={8} style={{ color: 'var(--color-text-light)' }} />
            </div>
          </div>

          {/* Editable text */}
          <div className="px-5 pt-3">
            <label className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
              Edit your message
            </label>
            <textarea
              value={editedText}
              onChange={e => setEditedText(e.target.value)}
              className="w-full mt-1.5 p-3 rounded-xl font-sans text-xs leading-relaxed resize-none outline-none hide-scrollbar"
              style={{
                background: 'var(--color-bg-glass)',
                border: '1px solid var(--color-border-light)',
                color: 'var(--color-text-main)',
                minHeight: 80,
                maxHeight: 140,
              }}
            />
          </div>

          {/* Platform grid */}
          <div className="px-5 py-4">
            <label className="font-sans text-[9px] uppercase tracking-widest" style={{ color: 'var(--color-text-light)' }}>
              Share to
            </label>
            <div className="grid grid-cols-5 gap-2 mt-2">
              {sharePlatforms.map(platform => {
                const PlatformIcon = getIcon(platform.icon)
                const isCopyLink = platform.id === 'copy-link'

                return (
                  <button
                    key={platform.id}
                    onClick={() => handleShare(platform.id)}
                    className="flex flex-col items-center gap-1 p-2 rounded-xl hover:bg-[var(--color-bg-glass)] transition-all group"
                  >
                    <div
                      className="w-10 h-10 rounded-full flex items-center justify-center transition-all group-hover:scale-110"
                      style={{
                        background: `${platform.color}15`,
                        border: `1px solid ${platform.color}25`,
                      }}
                    >
                      {isCopyLink && copied ? (
                        <Check size={16} style={{ color: '#5C9C78' }} />
                      ) : (
                        <PlatformIcon size={16} style={{ color: platform.color }} />
                      )}
                    </div>
                    <span className="font-sans text-[8px] text-center leading-tight" style={{ color: 'var(--color-text-light)' }}>
                      {isCopyLink && copied ? 'Copied!' : platform.label}
                    </span>
                  </button>
                )
              })}
            </div>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  )
}
