import { useState, useRef, useCallback } from 'react'
import { Share2, X, Copy, Check, Image, Twitter, Facebook, MessageCircle, Send, Link } from 'lucide-react'

const APP_NAME = 'Love Journal'
const APP_TAGLINE = 'The Universal Law of Love — Wisdom Journal Companion'
const APP_HASHTAGS = '#LoveJournal #UniversalLawOfLove #Manifestation #WisdomJournal #Resonance'

// Generate a beautiful shareable card as a canvas image
function generateShareCard(text, label, isDark) {
  const canvas = document.createElement('canvas')
  const w = 1080
  const h = 1080
  canvas.width = w
  canvas.height = h
  const ctx = canvas.getContext('2d')

  // Background
  const bg = isDark ? '#05100B' : '#FAFAF8'
  const surface = isDark ? '#0A1C14' : '#FFFFFF'
  const gold = '#C5A059'
  const goldLight = '#E6D0A1'
  const textColor = isDark ? '#E8EDE9' : '#122E21'
  const mutedColor = isDark ? '#8A9C91' : '#5C7065'

  // Fill background
  ctx.fillStyle = bg
  ctx.fillRect(0, 0, w, h)

  // Decorative blobs
  const gradient1 = ctx.createRadialGradient(120, 120, 0, 120, 120, 300)
  gradient1.addColorStop(0, isDark ? 'rgba(197,160,89,0.08)' : 'rgba(197,160,89,0.15)')
  gradient1.addColorStop(1, 'transparent')
  ctx.fillStyle = gradient1
  ctx.fillRect(0, 0, 500, 500)

  const gradient2 = ctx.createRadialGradient(w - 100, h - 100, 0, w - 100, h - 100, 350)
  gradient2.addColorStop(0, isDark ? 'rgba(27,64,46,0.1)' : 'rgba(27,64,46,0.08)')
  gradient2.addColorStop(1, 'transparent')
  ctx.fillStyle = gradient2
  ctx.fillRect(w - 450, h - 450, 450, 450)

  // Card background
  const cardX = 80
  const cardY = 140
  const cardW = w - 160
  const cardH = h - 280
  const radius = 32

  ctx.fillStyle = surface
  ctx.beginPath()
  ctx.moveTo(cardX + radius, cardY)
  ctx.lineTo(cardX + cardW - radius, cardY)
  ctx.quadraticCurveTo(cardX + cardW, cardY, cardX + cardW, cardY + radius)
  ctx.lineTo(cardX + cardW, cardY + cardH - radius)
  ctx.quadraticCurveTo(cardX + cardW, cardY + cardH, cardX + cardW - radius, cardY + cardH)
  ctx.lineTo(cardX + radius, cardY + cardH)
  ctx.quadraticCurveTo(cardX, cardY + cardH, cardX, cardY + cardH - radius)
  ctx.lineTo(cardX, cardY + radius)
  ctx.quadraticCurveTo(cardX, cardY, cardX + radius, cardY)
  ctx.closePath()
  ctx.fill()

  // Card border
  ctx.strokeStyle = isDark ? 'rgba(197,160,89,0.12)' : 'rgba(18,46,33,0.08)'
  ctx.lineWidth = 2
  ctx.stroke()

  // Gold accent line top
  const lineY = cardY + 60
  ctx.strokeStyle = gold
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(w / 2 - 40, lineY)
  ctx.lineTo(w / 2 + 40, lineY)
  ctx.stroke()

  // Decorative star
  ctx.fillStyle = gold
  ctx.font = '28px serif'
  ctx.textAlign = 'center'
  ctx.fillText('\u2726', w / 2, lineY - 20)

  // Label
  if (label) {
    ctx.fillStyle = mutedColor
    ctx.font = 'italic 24px "Cormorant Garamond", Georgia, serif'
    ctx.textAlign = 'center'
    ctx.fillText(label, w / 2, lineY + 36)
  }

  // Main text - word wrap
  ctx.fillStyle = textColor
  ctx.font = '32px "Cormorant Garamond", Georgia, serif'
  ctx.textAlign = 'center'

  const maxWidth = cardW - 120
  const lineHeight = 46
  const words = text.split(' ')
  const lines = []
  let currentLine = ''

  for (const word of words) {
    const testLine = currentLine ? `${currentLine} ${word}` : word
    const metrics = ctx.measureText(testLine)
    if (metrics.width > maxWidth && currentLine) {
      lines.push(currentLine)
      currentLine = word
    } else {
      currentLine = testLine
    }
  }
  if (currentLine) lines.push(currentLine)

  // Limit to ~12 lines
  const displayLines = lines.slice(0, 12)
  if (lines.length > 12) displayLines.push('...')

  const textStartY = lineY + 80
  displayLines.forEach((line, i) => {
    ctx.fillText(line, w / 2, textStartY + i * lineHeight)
  })

  // Gold accent line bottom
  const bottomLineY = Math.min(textStartY + displayLines.length * lineHeight + 30, cardY + cardH - 60)
  ctx.strokeStyle = gold
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(w / 2 - 40, bottomLineY)
  ctx.lineTo(w / 2 + 40, bottomLineY)
  ctx.stroke()

  // App name at bottom of card
  ctx.fillStyle = gold
  ctx.font = '500 20px "Manrope", sans-serif'
  ctx.textAlign = 'center'
  ctx.fillText('\u2728 Love Journal', w / 2, cardY + cardH - 28)

  // Footer outside card
  ctx.fillStyle = mutedColor
  ctx.font = '18px "Manrope", sans-serif'
  ctx.textAlign = 'center'
  ctx.fillText('The Universal Law of Love \u2014 Wisdom Journal Companion', w / 2, h - 50)

  return canvas
}

// Share utility functions
function getShareText(text, label) {
  const quote = text.length > 200 ? text.slice(0, 197) + '...' : text
  const parts = []
  if (label) parts.push(label)
  parts.push(`"${quote}"`)
  parts.push('')
  parts.push(`\u2014 from my ${APP_NAME}`)
  parts.push(APP_HASHTAGS)
  return parts.join('\n')
}

async function canvasToBlob(canvas) {
  return new Promise((resolve) => canvas.toBlob(resolve, 'image/png'))
}

// Share overlay / bottom sheet
function ShareSheet({ isOpen, onClose, text, label, isDark }) {
  const [copied, setCopied] = useState(false)
  const [cardGenerated, setCardGenerated] = useState(false)
  const canvasRef = useRef(null)

  const shareText = getShareText(text, label)

  const handleCopyText = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(shareText)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // fallback
      const ta = document.createElement('textarea')
      ta.value = shareText
      document.body.appendChild(ta)
      ta.select()
      document.execCommand('copy')
      document.body.removeChild(ta)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }, [shareText])

  const handleDownloadCard = useCallback(() => {
    const canvas = generateShareCard(text, label, isDark)
    canvasRef.current = canvas
    setCardGenerated(true)
    const link = document.createElement('a')
    link.download = `love-journal-${Date.now()}.png`
    link.href = canvas.toDataURL('image/png')
    link.click()
  }, [text, label, isDark])

  const handleNativeShare = useCallback(async (includeImage) => {
    try {
      if (includeImage && navigator.canShare) {
        const canvas = generateShareCard(text, label, isDark)
        const blob = await canvasToBlob(canvas)
        const file = new File([blob], 'love-journal.png', { type: 'image/png' })
        const shareData = { text: shareText, files: [file] }
        if (navigator.canShare(shareData)) {
          await navigator.share(shareData)
          return
        }
      }
      await navigator.share({ text: shareText })
    } catch (err) {
      if (err.name !== 'AbortError') {
        handleCopyText()
      }
    }
  }, [text, label, isDark, shareText, handleCopyText])

  const handleShareToTwitter = useCallback(() => {
    const tweetText = text.length > 240
      ? `"${text.slice(0, 200)}..." \u2014 from my Love Journal\n${APP_HASHTAGS}`
      : `"${text}" \u2014 from my Love Journal\n${APP_HASHTAGS}`
    const encoded = encodeURIComponent(tweetText)
    window.open(`https://twitter.com/intent/tweet?text=${encoded}`, '_blank', 'noopener')
  }, [text])

  const handleShareToFacebook = useCallback(() => {
    const encoded = encodeURIComponent(shareText)
    window.open(`https://www.facebook.com/sharer/sharer.php?quote=${encoded}`, '_blank', 'noopener')
  }, [shareText])

  const handleShareToWhatsApp = useCallback(() => {
    const encoded = encodeURIComponent(shareText)
    window.open(`https://wa.me/?text=${encoded}`, '_blank', 'noopener')
  }, [shareText])

  const handleShareToTelegram = useCallback(() => {
    const encoded = encodeURIComponent(shareText)
    window.open(`https://t.me/share/url?text=${encoded}`, '_blank', 'noopener')
  }, [shareText])

  if (!isOpen) return null

  const hasNativeShare = typeof navigator !== 'undefined' && !!navigator.share

  return (
    <>
      {/* Backdrop */}
      <div
        className="fixed inset-0 z-[100] bg-black/40 transition-opacity duration-300"
        onClick={onClose}
      />

      {/* Sheet */}
      <div className="fixed bottom-0 left-0 right-0 z-[101] animate-slide-up">
        <div className="max-w-lg mx-auto">
          <div className="glass rounded-t-3xl px-5 pt-4 pb-6 safe-bottom shadow-2xl">
            {/* Handle */}
            <div className="w-10 h-1 rounded-full bg-text-light/30 mx-auto mb-4" />

            {/* Header */}
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-serif text-lg font-semibold text-text-main">Share This Reflection</h3>
              <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-gold/10 text-text-muted">
                <X size={18} />
              </button>
            </div>

            {/* Preview */}
            <div className="glass rounded-xl p-3 mb-5 max-h-28 overflow-y-auto">
              {label && <p className="text-text-muted text-xs italic mb-1">{label}</p>}
              <p className="font-serif text-sm text-text-main leading-relaxed line-clamp-3">
                "{text}"
              </p>
            </div>

            {/* Social buttons */}
            <div className="grid grid-cols-4 gap-3 mb-5">
              <button
                onClick={handleShareToTwitter}
                className="flex flex-col items-center gap-1.5 p-3 rounded-xl hover:bg-gold/5 transition-colors"
              >
                <div className="w-11 h-11 rounded-full bg-[#1DA1F2]/10 flex items-center justify-center">
                  <Twitter size={18} className="text-[#1DA1F2]" />
                </div>
                <span className="text-[10px] text-text-muted">X / Twitter</span>
              </button>

              <button
                onClick={handleShareToFacebook}
                className="flex flex-col items-center gap-1.5 p-3 rounded-xl hover:bg-gold/5 transition-colors"
              >
                <div className="w-11 h-11 rounded-full bg-[#1877F2]/10 flex items-center justify-center">
                  <Facebook size={18} className="text-[#1877F2]" />
                </div>
                <span className="text-[10px] text-text-muted">Facebook</span>
              </button>

              <button
                onClick={handleShareToWhatsApp}
                className="flex flex-col items-center gap-1.5 p-3 rounded-xl hover:bg-gold/5 transition-colors"
              >
                <div className="w-11 h-11 rounded-full bg-[#25D366]/10 flex items-center justify-center">
                  <MessageCircle size={18} className="text-[#25D366]" />
                </div>
                <span className="text-[10px] text-text-muted">WhatsApp</span>
              </button>

              <button
                onClick={handleShareToTelegram}
                className="flex flex-col items-center gap-1.5 p-3 rounded-xl hover:bg-gold/5 transition-colors"
              >
                <div className="w-11 h-11 rounded-full bg-[#0088CC]/10 flex items-center justify-center">
                  <Send size={18} className="text-[#0088CC]" />
                </div>
                <span className="text-[10px] text-text-muted">Telegram</span>
              </button>
            </div>

            {/* Action buttons */}
            <div className="space-y-2">
              {hasNativeShare && (
                <button
                  onClick={() => handleNativeShare(true)}
                  className="w-full flex items-center gap-3 p-3 rounded-xl glass hover:bg-gold/5 transition-colors"
                >
                  <div className="w-9 h-9 rounded-lg bg-gold/10 flex items-center justify-center">
                    <Share2 size={16} className="text-gold" />
                  </div>
                  <div className="text-left">
                    <p className="text-sm font-medium text-text-main">Share with Image</p>
                    <p className="text-[10px] text-text-muted">Beautiful card + text via your device</p>
                  </div>
                </button>
              )}

              <button
                onClick={handleDownloadCard}
                className="w-full flex items-center gap-3 p-3 rounded-xl glass hover:bg-gold/5 transition-colors"
              >
                <div className="w-9 h-9 rounded-lg bg-gold/10 flex items-center justify-center">
                  <Image size={16} className="text-gold" />
                </div>
                <div className="text-left">
                  <p className="text-sm font-medium text-text-main">Download Card</p>
                  <p className="text-[10px] text-text-muted">Save as beautiful image for Instagram, Stories, etc.</p>
                </div>
              </button>

              <button
                onClick={handleCopyText}
                className="w-full flex items-center gap-3 p-3 rounded-xl glass hover:bg-gold/5 transition-colors"
              >
                <div className="w-9 h-9 rounded-lg bg-gold/10 flex items-center justify-center">
                  {copied ? <Check size={16} className="text-green-500" /> : <Copy size={16} className="text-gold" />}
                </div>
                <div className="text-left">
                  <p className="text-sm font-medium text-text-main">{copied ? 'Copied!' : 'Copy Text'}</p>
                  <p className="text-[10px] text-text-muted">Copy formatted quote to clipboard</p>
                </div>
              </button>

              {hasNativeShare && (
                <button
                  onClick={() => handleNativeShare(false)}
                  className="w-full flex items-center gap-3 p-3 rounded-xl glass hover:bg-gold/5 transition-colors"
                >
                  <div className="w-9 h-9 rounded-lg bg-gold/10 flex items-center justify-center">
                    <Link size={16} className="text-gold" />
                  </div>
                  <div className="text-left">
                    <p className="text-sm font-medium text-text-main">More Options</p>
                    <p className="text-[10px] text-text-muted">Share via any app on your device</p>
                  </div>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  )
}

// Inline share button for journal prompts
export function ShareButton({ text, label, isDark, size = 'sm' }) {
  const [open, setOpen] = useState(false)

  if (!text || text.trim().length === 0) return null

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className={`inline-flex items-center gap-1 rounded-lg transition-all duration-300 text-text-light hover:text-gold hover:bg-gold/10 ${
          size === 'sm' ? 'px-2 py-1 text-xs' : 'px-3 py-1.5 text-sm'
        }`}
        title="Share this reflection"
      >
        <Share2 size={size === 'sm' ? 12 : 14} />
        <span>Share</span>
      </button>
      <ShareSheet
        isOpen={open}
        onClose={() => setOpen(false)}
        text={text}
        label={label}
        isDark={isDark}
      />
    </>
  )
}

// Floating share button for sections
export function ShareFab({ text, label, isDark }) {
  const [open, setOpen] = useState(false)

  if (!text || text.trim().length === 0) return null

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="fixed bottom-20 right-4 z-40 w-12 h-12 rounded-full bg-gradient-to-r from-gold to-gold-dark text-white shadow-lg shadow-gold/25 flex items-center justify-center hover:shadow-xl hover:shadow-gold/35 transition-all active:scale-95"
        title="Share"
      >
        <Share2 size={20} />
      </button>
      <ShareSheet
        isOpen={open}
        onClose={() => setOpen(false)}
        text={text}
        label={label}
        isDark={isDark}
      />
    </>
  )
}

// Pre-made shareable quotes from the book's philosophy
export const shareableQuotes = [
  { text: 'This journal is not here to judge how "good" you are at manifestation. It is here to notice how deeply loved you already are.', label: 'The Universal Law of Love' },
  { text: 'I agree to move through this book and journal at the pace my body and life can genuinely hold. I choose curiosity over perfection.', label: 'Self-Agreement' },
  { text: 'You do not have to "keep up." You are allowed to pause, repeat, skip ahead, or return.', label: 'A Gentle Invitation' },
  { text: 'What if manifestation were not a demand but a dance? What if you treated life as a partner, not an adversary?', label: 'Manifestation as Partnership' },
  { text: 'Your resistance is not your enemy. It is sacred intelligence, wisely protecting something tender in you.', label: 'Resistance as Sacred Intelligence' },
  { text: 'The pain you have lived through has grown your capacity for empathy, boundaries, discernment, and depth.', label: 'Compost Consciousness' },
  { text: 'If I approached my ordinary day as a field where the Law of Love is constantly moving, everything would shimmer.', label: 'The Miraculous Ordinary' },
]

export { ShareSheet, generateShareCard }
