import { useState } from 'react'
import { Share2 } from 'lucide-react'
import { ShareModal } from './ShareModal'
import type { ShareableContent } from '@/shared/types/share'
import { nativeShare } from '@/shared/services/shareService'

interface ShareButtonProps {
  content: ShareableContent
  /** Compact mode: just the icon */
  compact?: boolean
  /** Custom label */
  label?: string
  /** Custom class */
  className?: string
}

export function ShareButton({ content, compact = false, label, className = '' }: ShareButtonProps) {
  const [showModal, setShowModal] = useState(false)

  const handleClick = async () => {
    // Try native share on mobile first
    const shared = await nativeShare(content)
    if (!shared) {
      setShowModal(true)
    }
  }

  if (compact) {
    return (
      <>
        <button
          onClick={handleClick}
          className={`p-1.5 rounded-lg hover:bg-[var(--color-bg-glass)] transition-all group ${className}`}
          title="Share this"
        >
          <Share2
            size={14}
            className="transition-colors"
            style={{ color: 'var(--color-text-light)' }}
          />
        </button>
        {showModal && <ShareModal content={content} onClose={() => setShowModal(false)} />}
      </>
    )
  }

  return (
    <>
      <button
        onClick={handleClick}
        className={`flex items-center gap-2 px-3 py-2 rounded-xl
          hover:bg-[var(--color-bg-glass)] transition-all
          border border-[var(--color-border-light)]
          hover:border-[var(--color-gold-primary)] hover:shadow-[var(--shadow-card)]
          group ${className}`}
      >
        <Share2
          size={14}
          className="transition-colors group-hover:text-[var(--color-gold-primary)]"
          style={{ color: 'var(--color-text-muted)' }}
        />
        <span
          className="font-sans text-xs font-medium transition-colors group-hover:text-[var(--color-gold-primary)]"
          style={{ color: 'var(--color-text-muted)' }}
        >
          {label || 'Share'}
        </span>
      </button>
      {showModal && <ShareModal content={content} onClose={() => setShowModal(false)} />}
    </>
  )
}
