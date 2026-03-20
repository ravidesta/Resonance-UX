import { useState, useEffect, useRef } from 'react'
import {
  Heart, Sparkles, BookOpen, Shield, Smartphone, Monitor,
  Moon, Sun, Download, ArrowRight, ChevronDown, Feather,
  Compass, Layers, Star, Leaf, Waves, Eye, Palette, Zap
} from 'lucide-react'

const features = [
  {
    icon: BookOpen,
    title: '13 Chapter Companions',
    desc: 'Guided reflection prompts for every chapter — first impressions, key insights, personal connections, and integration experiments.',
  },
  {
    icon: Compass,
    title: 'Opening Gateway',
    desc: 'Begin with clarity. Map your themes, intentions, reading rhythm, and pre-journey self-assessment.',
  },
  {
    icon: Layers,
    title: 'Integration Hubs',
    desc: 'Pause points between chapters for pattern recognition, growth evidence, and gentle next edges.',
  },
  {
    icon: Shield,
    title: 'Shadow & Depth Work',
    desc: 'Tender spaces for resistance dialogue, difficult gratitude, and naming pain with dignity.',
  },
  {
    icon: Feather,
    title: 'Future Self Letters',
    desc: 'Write to yourself at 1 month, 6 months, and 1 year — bless your future self with tenderness.',
  },
  {
    icon: Waves,
    title: 'Continuing Check-Ins',
    desc: 'Return at 1 week, 1 month, 3 months, 6 months, and 1 year to witness your evolution.',
  },
]

const flavors = [
  { icon: Eye, name: 'Witness', color: '#7B9E89' },
  { icon: Heart, name: 'Devotion', color: '#C5A059' },
  { icon: Palette, name: 'Play', color: '#B07BAC' },
  { icon: Zap, name: 'Clarity', color: '#6BA3BE' },
  { icon: Leaf, name: 'Embodiment', color: '#8B7355' },
]

const platforms = [
  { icon: Smartphone, label: 'iOS & Android' },
  { icon: Monitor, label: 'Web & Desktop' },
  { icon: Download, label: 'Install as App' },
]

function useInView(threshold = 0.15) {
  const ref = useRef(null)
  const [visible, setVisible] = useState(false)
  useEffect(() => {
    const el = ref.current
    if (!el) return
    const obs = new IntersectionObserver(
      ([e]) => { if (e.isIntersecting) { setVisible(true); obs.disconnect() } },
      { threshold }
    )
    obs.observe(el)
    return () => obs.disconnect()
  }, [threshold])
  return [ref, visible]
}

function FadeSection({ children, className = '', delay = 0 }) {
  const [ref, visible] = useInView()
  return (
    <div
      ref={ref}
      className={`transition-all duration-700 ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-8'} ${className}`}
      style={{ transitionDelay: `${delay}ms` }}
    >
      {children}
    </div>
  )
}

export function LandingPage({ onEnterJournal, isDark, setIsDark }) {
  const [scrollY, setScrollY] = useState(0)

  useEffect(() => {
    const handler = () => setScrollY(window.scrollY)
    window.addEventListener('scroll', handler, { passive: true })
    return () => window.removeEventListener('scroll', handler)
  }, [])

  return (
    <div className="min-h-dvh overflow-x-hidden">
      {/* Sticky Nav */}
      <nav
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 ${
          scrollY > 60 ? 'glass shadow-lg' : ''
        }`}
      >
        <div className="max-w-5xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles className="text-gold" size={20} />
            <span className="font-serif text-lg font-semibold text-text-main">Love Journal</span>
          </div>
          <div className="flex items-center gap-3">
            <button
              onClick={() => setIsDark(!isDark)}
              className="p-2 rounded-xl hover:bg-gold/10 transition-colors text-text-muted"
            >
              {isDark ? <Sun size={16} /> : <Moon size={16} />}
            </button>
            <button
              onClick={onEnterJournal}
              className="hidden sm:inline-flex items-center gap-2 px-5 py-2 rounded-xl bg-gradient-to-r from-gold to-gold-dark text-white text-sm font-medium shadow-md shadow-gold/20 hover:shadow-lg hover:shadow-gold/30 transition-all active:scale-[0.98]"
            >
              Open Journal
              <ArrowRight size={14} />
            </button>
          </div>
        </div>
      </nav>

      {/* ═══════════════ HERO ═══════════════ */}
      <section className="relative pt-28 pb-20 md:pt-40 md:pb-32 px-6 text-center overflow-hidden">
        {/* Parallax blobs */}
        <div
          className="absolute -top-20 -left-40 w-[500px] h-[500px] rounded-full animate-breathe pointer-events-none"
          style={{
            background: `radial-gradient(circle, ${isDark ? 'rgba(197,160,89,0.06)' : 'rgba(197,160,89,0.12)'}, transparent 70%)`,
            transform: `translate(0, ${scrollY * 0.08}px)`,
          }}
        />
        <div
          className="absolute -bottom-40 -right-40 w-[600px] h-[600px] rounded-full animate-breathe-slow pointer-events-none"
          style={{
            background: `radial-gradient(circle, ${isDark ? 'rgba(27,64,46,0.1)' : 'rgba(27,64,46,0.08)'}, transparent 70%)`,
            animationDelay: '-8s',
            transform: `translate(0, ${scrollY * -0.05}px)`,
          }}
        />

        <FadeSection>
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full glass text-xs font-medium text-gold mb-6">
            <Sparkles size={12} />
            Companion to The Universal Law of Love
          </div>
        </FadeSection>

        <FadeSection delay={100}>
          <h1 className="font-serif text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-semibold text-text-main leading-[1.1] max-w-3xl mx-auto tracking-tight">
            Your Living Wisdom
            <br />
            <span className="bg-gradient-to-r from-gold via-gold-dark to-gold bg-clip-text text-transparent">
              Journal Companion
            </span>
          </h1>
        </FadeSection>

        <FadeSection delay={200}>
          <p className="mt-6 text-text-muted text-base md:text-lg max-w-xl mx-auto leading-relaxed">
            A radically calm space to center your wisdom, your timing, and your nervous system — while gently deepening your partnership with the Law of Love.
          </p>
        </FadeSection>

        <FadeSection delay={300}>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <button
              onClick={onEnterJournal}
              className="inline-flex items-center gap-2.5 px-8 py-3.5 rounded-2xl bg-gradient-to-r from-gold to-gold-dark text-white font-medium shadow-xl shadow-gold/25 hover:shadow-2xl hover:shadow-gold/35 transition-all active:scale-[0.97] text-base"
            >
              <Heart size={18} />
              Begin Your Journey
            </button>
            <a
              href="#features"
              className="inline-flex items-center gap-2 px-6 py-3.5 rounded-2xl glass text-text-main font-medium text-sm hover:bg-gold/5 transition-all"
            >
              Explore Features
              <ChevronDown size={16} />
            </a>
          </div>
        </FadeSection>

        {/* Platform badges */}
        <FadeSection delay={400}>
          <div className="mt-12 flex items-center justify-center gap-6 text-text-light">
            {platforms.map(({ icon: Icon, label }) => (
              <div key={label} className="flex items-center gap-1.5 text-xs">
                <Icon size={14} />
                <span>{label}</span>
              </div>
            ))}
          </div>
        </FadeSection>

        {/* Scroll indicator */}
        <div className="mt-16 animate-bounce text-text-light">
          <ChevronDown size={20} className="mx-auto" />
        </div>
      </section>

      {/* ═══════════════ QUOTE BANNER ═══════════════ */}
      <section className="py-16 px-6">
        <FadeSection>
          <div className="max-w-3xl mx-auto text-center">
            <div className="glass rounded-3xl px-8 py-10 md:px-12 md:py-14">
              <div className="w-10 h-px bg-gold mx-auto mb-6" />
              <blockquote className="font-serif text-xl md:text-2xl text-text-main leading-relaxed italic">
                "This journal is not here to judge how 'good' you are at manifestation. It is here to notice how deeply loved you already are, and to help you practice partnering with that love in ways that feel kind, grounded, and real."
              </blockquote>
              <div className="w-10 h-px bg-gold mx-auto mt-6" />
            </div>
          </div>
        </FadeSection>
      </section>

      {/* ═══════════════ FEATURES ═══════════════ */}
      <section id="features" className="py-16 md:py-24 px-6">
        <FadeSection>
          <div className="text-center mb-14">
            <span className="text-gold text-sm font-medium tracking-wide uppercase">What's Inside</span>
            <h2 className="font-serif text-3xl md:text-4xl font-semibold text-text-main mt-3">
              Everything Your Journey Needs
            </h2>
            <p className="text-text-muted mt-3 max-w-md mx-auto text-sm leading-relaxed">
              A complete wisdom journal companion with structured reflection, integration practices, and gentle depth work.
            </p>
          </div>
        </FadeSection>

        <div className="max-w-5xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {features.map(({ icon: Icon, title, desc }, i) => (
            <FadeSection key={title} delay={i * 80}>
              <div className="glass rounded-2xl p-6 h-full hover:scale-[1.02] transition-transform duration-300 group">
                <div className="w-11 h-11 rounded-xl bg-gold/10 flex items-center justify-center mb-4 group-hover:bg-gold/20 transition-colors">
                  <Icon className="text-gold" size={20} />
                </div>
                <h3 className="font-serif text-lg font-semibold text-text-main mb-2">{title}</h3>
                <p className="text-text-muted text-sm leading-relaxed">{desc}</p>
              </div>
            </FadeSection>
          ))}
        </div>
      </section>

      {/* ═══════════════ LUMINOUS SAUCE FLAVORS ═══════════════ */}
      <section className="py-16 md:py-24 px-6">
        <FadeSection>
          <div className="max-w-4xl mx-auto">
            <div className="text-center mb-12">
              <span className="text-gold text-sm font-medium tracking-wide uppercase">The Luminous Sauce</span>
              <h2 className="font-serif text-3xl md:text-4xl font-semibold text-text-main mt-3">
                Discover Your Flavor
              </h2>
              <p className="text-text-muted mt-3 max-w-md mx-auto text-sm leading-relaxed">
                Five flavors of practice. Your home base, your stretch, your unique recipe for living as love.
              </p>
            </div>

            <div className="flex flex-wrap justify-center gap-4">
              {flavors.map(({ icon: Icon, name, color }, i) => (
                <FadeSection key={name} delay={i * 100}>
                  <div className="glass rounded-2xl px-6 py-5 text-center min-w-[140px] hover:scale-105 transition-transform duration-300">
                    <div
                      className="w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-3"
                      style={{ background: `${color}20` }}
                    >
                      <Icon size={22} style={{ color }} />
                    </div>
                    <p className="font-serif text-base font-semibold text-text-main">{name}</p>
                  </div>
                </FadeSection>
              ))}
            </div>
          </div>
        </FadeSection>
      </section>

      {/* ═══════════════ JOURNEY MAP ═══════════════ */}
      <section className="py-16 md:py-24 px-6">
        <FadeSection>
          <div className="text-center mb-14">
            <span className="text-gold text-sm font-medium tracking-wide uppercase">Your Path</span>
            <h2 className="font-serif text-3xl md:text-4xl font-semibold text-text-main mt-3">
              A Gentle Structure for Deep Work
            </h2>
          </div>
        </FadeSection>

        <div className="max-w-2xl mx-auto space-y-4">
          {[
            { step: 'I', title: 'Opening Gateway', desc: 'Locate yourself. Set intentions. Make a gentle agreement with your own pace.', icon: Compass },
            { step: 'II', title: 'Chapter Companions', desc: '13 chapters of structured prompts — insights, connections, resistance, integration.', icon: BookOpen },
            { step: 'III', title: 'Integration Hubs', desc: 'Pause every few chapters. Notice patterns. Celebrate growth. Ask living questions.', icon: Layers },
            { step: 'IV', title: 'Shadow & Depth', desc: 'Tender spaces for what you are avoiding, afraid of, and wisely protecting.', icon: Shield },
            { step: 'V', title: 'Closing & Continuation', desc: 'Journey review, wisdom distillation, future self letters, gratitude rituals.', icon: Star },
            { step: 'VI', title: 'Continuing Check-Ins', desc: 'Return at intervals from 1 week to 1 year. Witness your unfolding.', icon: Waves },
          ].map(({ step, title, desc, icon: Icon }, i) => (
            <FadeSection key={step} delay={i * 80}>
              <div className="glass rounded-2xl p-5 flex items-start gap-4 hover:scale-[1.01] transition-transform duration-300">
                <div className="w-10 h-10 rounded-xl bg-gold/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <span className="font-serif text-gold text-sm font-bold">{step}</span>
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <Icon className="text-gold" size={16} />
                    <h3 className="font-serif text-base font-semibold text-text-main">{title}</h3>
                  </div>
                  <p className="text-text-muted text-sm leading-relaxed">{desc}</p>
                </div>
              </div>
            </FadeSection>
          ))}
        </div>
      </section>

      {/* ═══════════════ DESIGN PHILOSOPHY ═══════════════ */}
      <section className="py-16 md:py-24 px-6">
        <FadeSection>
          <div className="max-w-4xl mx-auto glass rounded-3xl p-8 md:p-12">
            <div className="grid md:grid-cols-2 gap-8 items-center">
              <div>
                <span className="text-gold text-sm font-medium tracking-wide uppercase">Resonance UX</span>
                <h2 className="font-serif text-2xl md:text-3xl font-semibold text-text-main mt-3 mb-4">
                  Designed to Feel Like a Deep Breath
                </h2>
                <p className="text-text-muted text-sm leading-relaxed mb-4">
                  Built on the Resonance UX design system — radically calm, glass-morphism surfaces, organic breathing animations, and intentional typography that honors both beauty and readability.
                </p>
                <ul className="space-y-2.5 text-sm text-text-muted">
                  {[
                    'Paper texture & frosted glass panels',
                    'Cormorant Garamond + Manrope typography',
                    'Forest green & gold palette',
                    'Breathing ambient animations',
                    'Dark mode for evening reflection',
                  ].map((item) => (
                    <li key={item} className="flex items-center gap-2">
                      <div className="w-1.5 h-1.5 rounded-full bg-gold flex-shrink-0" />
                      {item}
                    </li>
                  ))}
                </ul>
              </div>
              <div className="flex justify-center">
                <div className="w-56 md:w-64 rounded-3xl border-4 border-bg-elevated/50 overflow-hidden shadow-2xl">
                  <div className="bg-bg-surface p-4 space-y-3">
                    <div className="flex items-center gap-2 mb-2">
                      <div className="w-6 h-6 rounded-full bg-gold/20 flex items-center justify-center">
                        <Sparkles className="text-gold" size={10} />
                      </div>
                      <div className="h-2 w-20 rounded bg-text-main/10" />
                    </div>
                    {[1, 2, 3].map((n) => (
                      <div key={n} className="glass rounded-xl p-3 space-y-2">
                        <div className="h-2 w-3/4 rounded bg-text-main/8" />
                        <div className="h-8 rounded-lg bg-bg-elevated/50" />
                      </div>
                    ))}
                    <div className="flex justify-around pt-2">
                      {[Heart, BookOpen, Layers].map((Icon, i) => (
                        <div key={i} className={`p-2 rounded-lg ${i === 0 ? 'bg-gold/10' : ''}`}>
                          <Icon size={14} className={i === 0 ? 'text-gold' : 'text-text-light'} />
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </FadeSection>
      </section>

      {/* ═══════════════ CROSS-PLATFORM ═══════════════ */}
      <section className="py-16 md:py-24 px-6">
        <FadeSection>
          <div className="text-center mb-12">
            <span className="text-gold text-sm font-medium tracking-wide uppercase">Everywhere You Are</span>
            <h2 className="font-serif text-3xl md:text-4xl font-semibold text-text-main mt-3">
              Cross-Platform, Cross-Device
            </h2>
            <p className="text-text-muted mt-3 max-w-md mx-auto text-sm leading-relaxed">
              Install as a native app on any device. Your reflections sync through export/import and stay private on your device.
            </p>
          </div>
        </FadeSection>

        <div className="max-w-3xl mx-auto grid grid-cols-1 sm:grid-cols-3 gap-4">
          {[
            { icon: Smartphone, title: 'Mobile', desc: 'Install on iOS & Android via your browser. Feels native.', detail: 'PWA' },
            { icon: Monitor, title: 'Desktop & Web', desc: 'Full experience on any screen size. Windows, Mac, Linux.', detail: 'Responsive' },
            { icon: Shield, title: 'Private & Offline', desc: 'All data stays on your device. Works without internet.', detail: 'Local-first' },
          ].map(({ icon: Icon, title, desc, detail }, i) => (
            <FadeSection key={title} delay={i * 100}>
              <div className="glass rounded-2xl p-6 text-center h-full">
                <div className="w-12 h-12 rounded-xl bg-gold/10 flex items-center justify-center mx-auto mb-4">
                  <Icon className="text-gold" size={22} />
                </div>
                <div className="inline-block px-2 py-0.5 rounded text-[10px] font-medium text-gold bg-gold/10 mb-2">{detail}</div>
                <h3 className="font-serif text-lg font-semibold text-text-main mb-1">{title}</h3>
                <p className="text-text-muted text-sm leading-relaxed">{desc}</p>
              </div>
            </FadeSection>
          ))}
        </div>
      </section>

      {/* ═══════════════ FINAL CTA ═══════════════ */}
      <section className="py-20 md:py-32 px-6 text-center">
        <FadeSection>
          <div className="max-w-2xl mx-auto">
            <div className="glass rounded-3xl px-8 py-12 md:px-12 md:py-16 relative overflow-hidden">
              {/* Background glow */}
              <div
                className="absolute inset-0 pointer-events-none"
                style={{
                  background: `radial-gradient(ellipse at center, ${isDark ? 'rgba(197,160,89,0.05)' : 'rgba(197,160,89,0.08)'}, transparent 70%)`,
                }}
              />

              <div className="relative">
                <div className="w-14 h-14 rounded-full bg-gradient-to-br from-gold/30 to-gold-light/20 flex items-center justify-center mx-auto mb-6">
                  <Heart className="text-gold" size={24} />
                </div>
                <h2 className="font-serif text-3xl md:text-4xl font-semibold text-text-main mb-4">
                  Begin Partnering<br />with Love
                </h2>
                <p className="text-text-muted text-sm md:text-base leading-relaxed max-w-md mx-auto mb-8">
                  You do not have to "keep up." You are allowed to pause, repeat, skip ahead, or return. Choose curiosity over perfection.
                </p>
                <button
                  onClick={onEnterJournal}
                  className="inline-flex items-center gap-2.5 px-8 py-4 rounded-2xl bg-gradient-to-r from-gold to-gold-dark text-white font-medium text-base shadow-xl shadow-gold/25 hover:shadow-2xl hover:shadow-gold/35 transition-all active:scale-[0.97]"
                >
                  <Sparkles size={18} />
                  Open Your Journal
                </button>
              </div>
            </div>
          </div>
        </FadeSection>
      </section>

      {/* ═══════════════ FOOTER ═══════════════ */}
      <footer className="py-10 px-6 text-center border-t border-glass-border">
        <div className="flex items-center justify-center gap-2 mb-3">
          <Sparkles className="text-gold" size={14} />
          <span className="font-serif text-sm font-medium text-text-main">Love Journal</span>
        </div>
        <p className="text-text-light text-xs leading-relaxed max-w-sm mx-auto">
          A Resonance UX companion to <em>The Universal Law of Love: A Guide to Transformation and Connection</em>.
          Built with tenderness.
        </p>
        <p className="text-text-light/50 text-[10px] mt-4">
          Your data stays on your device. Always.
        </p>
      </footer>
    </div>
  )
}
