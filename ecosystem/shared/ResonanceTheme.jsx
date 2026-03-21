import React, { useState, useEffect } from 'react';
import {
  Sun, Moon, Share2, ChevronRight, Heart, Sparkles, BookOpen,
  MessageCircle, Wind, Feather, ExternalLink, ArrowRight
} from 'lucide-react';

// ═══════════════════════════════════════════════════════════
// RESONANCE DESIGN SYSTEM — Luminous Ego Development™
// The shared theme, components, and design tokens for the
// entire Resonance / Luminous ecosystem.
// ═══════════════════════════════════════════════════════════

const THEME = {
  light: {
    bgBase: '#FAFAF8', bgSurface: '#FFFFFF',
    bgGlass: 'rgba(255,255,255,0.65)', bgGlassHeavy: 'rgba(255,255,255,0.85)',
    textMain: '#122E21', textMuted: '#5C7065', textLight: '#8A9C91',
    borderLight: 'rgba(138,156,145,0.25)', borderFocus: 'rgba(197,160,89,0.6)',
    shadowCard: '0 8px 24px rgba(154,122,58,0.08)',
    shadowHover: '0 24px 48px rgba(154,122,58,0.18)',
    blobOpacity: 0.6,
  },
  dark: {
    bgBase: '#05100B', bgSurface: '#0A1C14',
    bgGlass: 'rgba(10,28,20,0.65)', bgGlassHeavy: 'rgba(10,28,20,0.85)',
    textMain: '#FAFAF8', textMuted: '#8A9C91', textLight: '#5C7065',
    borderLight: 'rgba(27,64,46,0.7)', borderFocus: 'rgba(197,160,89,0.5)',
    shadowCard: '0 8px 24px rgba(0,0,0,0.5)',
    shadowHover: '0 24px 48px rgba(0,0,0,0.9)',
    blobOpacity: 0.2,
  },
  colors: {
    green900: '#0A1C14', green800: '#122E21', green700: '#1B402E',
    green200: '#D1E0D7', green100: '#E8F0EA',
    goldPrimary: '#C5A059', goldLight: '#E6D0A1', goldDark: '#9A7A3A',
    teal: '#0E94BE',
  },
  fonts: {
    serif: "'Cormorant Garamond', serif",
    sans: "'Manrope', sans-serif",
  },
  easing: {
    spring: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
    smooth: 'cubic-bezier(0.165, 0.84, 0.44, 1)',
  },
};

const QUOTES = [
  { text: 'The privilege of a lifetime is to become who you truly are.', author: 'Carl Jung' },
  { text: 'The wound is the place where the Light enters you.', author: 'Rumi' },
  { text: 'Vulnerability is the birthplace of innovation, creativity, and change.', author: 'Brene Brown' },
  { text: 'Between stimulus and response there is a space. In that space is our freedom.', author: 'Viktor Frankl' },
];

const APPS = [
  { name: 'Resonance Learn', desc: 'Courses & Knowledge', icon: BookOpen, color: '#1B402E' },
  { name: 'Resonance Coach', desc: 'AI Appreciative Coaching', icon: MessageCircle, color: '#C5A059' },
  { name: 'Resonance Journal', desc: 'Interactive Workbook', icon: Feather, color: '#0E94BE' },
  { name: 'Resonance Meditate', desc: 'Meditations & Lectures', icon: Wind, color: '#9A7A3A' },
];

export default function ResonanceThemeShowcase() {
  const [dark, setDark] = useState(false);
  const [hoverCard, setHoverCard] = useState(null);
  const t = dark ? THEME.dark : THEME.light;
  const c = THEME.colors;
  const f = THEME.fonts;

  return (
    <div style={{
      minHeight: '100vh', background: t.bgBase, color: t.textMain,
      fontFamily: f.sans, transition: 'all 0.8s ease', position: 'relative', overflow: 'hidden',
    }}>
      {/* Google Fonts */}
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=Manrope:wght@300;400;500;600&display=swap" rel="stylesheet" />

      {/* Keyframe Animations */}
      <style>{`
        @keyframes breathe { 0% { transform: scale(1) translate(0,0); } 100% { transform: scale(1.08) translate(12px,18px); } }
        @keyframes ripple { 0% { box-shadow: 0 0 0 0 rgba(197,160,89,0.4); } 70% { box-shadow: 0 0 0 30px rgba(197,160,89,0); } 100% { box-shadow: 0 0 0 0 rgba(197,160,89,0); } }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(16px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes slideUp { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes shimmer { 0% { background-position: -200% center; } 100% { background-position: 200% center; } }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.6; } }
        @keyframes float { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
      `}</style>

      {/* === ORGANIC BACKGROUND === */}
      <div style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 0 }}>
        <div style={{
          position: 'absolute', top: '-10%', left: '-15%', width: 400, height: 400,
          borderRadius: '50%', filter: 'blur(80px)', opacity: t.blobOpacity,
          background: `radial-gradient(circle, ${c.green200} 0%, transparent 70%)`,
          animation: 'breathe 15s infinite alternate ease-in-out',
        }} />
        <div style={{
          position: 'absolute', bottom: '10%', right: '-15%', width: 500, height: 500,
          borderRadius: '50%', filter: 'blur(80px)', opacity: t.blobOpacity * 0.7,
          background: `radial-gradient(circle, rgba(197,160,89,0.15) 0%, transparent 70%)`,
          animation: 'breathe 18s infinite alternate ease-in-out', animationDelay: '-6s',
        }} />
        {/* Paper Texture */}
        <div style={{
          position: 'absolute', inset: 0, opacity: dark ? 0.08 : 0.03,
          backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.5'/%3E%3C/svg%3E")`,
        }} />
      </div>

      {/* === CONTENT === */}
      <div style={{ position: 'relative', zIndex: 1, maxWidth: 900, margin: '0 auto', padding: '40px 24px 80px' }}>

        {/* ── NAVIGATION BAR ── */}
        <nav style={{
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '14px 20px', borderRadius: 16,
          background: t.bgGlass, backdropFilter: 'blur(16px)', WebkitBackdropFilter: 'blur(16px)',
          border: `1px solid ${t.borderLight}`, marginBottom: 48,
          boxShadow: t.shadowCard, animation: 'fadeIn 0.6s ease-out',
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <Sparkles size={20} color={c.goldPrimary} />
            <span style={{ fontFamily: f.serif, fontSize: 22, fontWeight: 600, letterSpacing: 1 }}>
              Resonance
            </span>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, fontSize: 13, color: t.textMuted }}>
            <span>Ecosystem</span>
            <span>Book</span>
            <span>Pricing</span>
            <button onClick={() => setDark(!dark)} style={{
              background: 'none', border: 'none', cursor: 'pointer', color: c.goldPrimary,
              padding: 6, borderRadius: 8, display: 'flex',
            }}>
              {dark ? <Sun size={18} /> : <Moon size={18} />}
            </button>
          </div>
        </nav>

        {/* ── SECTION: DESIGN SYSTEM TITLE ── */}
        <div style={{ textAlign: 'center', marginBottom: 56, animation: 'slideUp 0.8s ease-out' }}>
          <h1 style={{
            fontFamily: f.serif, fontSize: 48, fontWeight: 300, margin: 0,
            lineHeight: 1.2, letterSpacing: -0.5,
          }}>
            Design System
          </h1>
          <div style={{
            width: 60, height: 2, margin: '16px auto',
            background: `linear-gradient(90deg, transparent, ${c.goldPrimary}, transparent)`,
          }} />
          <p style={{ color: t.textMuted, fontSize: 15, maxWidth: 500, margin: '0 auto' }}>
            The shared visual language for the Luminous Ego Development ecosystem
          </p>
        </div>

        {/* ── SECTION: COLOR PALETTE ── */}
        <SectionHeader title="Color Palette" subtitle="Forest greens, luminous golds, and organic neutrals" t={t} f={f} c={c} />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(100px, 1fr))', gap: 12, marginBottom: 48 }}>
          {[
            { name: 'Green 900', hex: c.green900 }, { name: 'Green 800', hex: c.green800 },
            { name: 'Green 700', hex: c.green700 }, { name: 'Green 200', hex: c.green200 },
            { name: 'Green 100', hex: c.green100 }, { name: 'Gold', hex: c.goldPrimary },
            { name: 'Gold Light', hex: c.goldLight }, { name: 'Gold Dark', hex: c.goldDark },
            { name: 'Cream', hex: '#FAFAF8' }, { name: 'Night', hex: '#05100B' },
            { name: 'Teal', hex: c.teal },
          ].map((col, i) => (
            <div key={i} style={{ textAlign: 'center', animation: `fadeIn 0.5s ease-out ${i * 0.05}s both` }}>
              <div style={{
                width: '100%', aspectRatio: '1', borderRadius: 12,
                background: col.hex, border: `1px solid ${t.borderLight}`,
                boxShadow: t.shadowCard,
              }} />
              <div style={{ fontSize: 11, color: t.textMuted, marginTop: 6 }}>{col.name}</div>
              <div style={{ fontSize: 10, color: t.textLight, fontFamily: 'monospace' }}>{col.hex}</div>
            </div>
          ))}
        </div>

        {/* ── SECTION: TYPOGRAPHY ── */}
        <SectionHeader title="Typography" subtitle="Cormorant Garamond for presence, Manrope for clarity" t={t} f={f} c={c} />
        <div style={{
          background: t.bgGlass, backdropFilter: 'blur(12px)', borderRadius: 20,
          padding: 32, border: `1px solid ${t.borderLight}`, marginBottom: 48,
          boxShadow: t.shadowCard,
        }}>
          <div style={{ fontFamily: f.serif, fontSize: 36, fontWeight: 300, marginBottom: 8 }}>
            Illuminate Your Inner World
          </div>
          <div style={{ fontFamily: f.serif, fontSize: 24, fontWeight: 600, color: t.textMuted, marginBottom: 16 }}>
            The journey of ego development
          </div>
          <div style={{ fontFamily: f.sans, fontSize: 15, lineHeight: 1.7, color: t.textMuted, marginBottom: 12 }}>
            Body text in Manrope — clean, modern, and deeply readable. Designed for extended reading
            and clear communication across all platforms and screen sizes.
          </div>
          <div style={{ fontFamily: f.sans, fontSize: 12, fontWeight: 600, letterSpacing: 2, textTransform: 'uppercase', color: c.goldPrimary }}>
            LABEL TEXT — MANROPE SEMIBOLD
          </div>
        </div>

        {/* ── SECTION: GLASS CARDS ── */}
        <SectionHeader title="Glass Cards" subtitle="Frosted glass surfaces with organic depth" t={t} f={f} c={c} />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 16, marginBottom: 48 }}>
          {['Default', 'Elevated', 'Interactive'].map((label, i) => (
            <div key={i}
              onMouseEnter={() => setHoverCard(i)}
              onMouseLeave={() => setHoverCard(null)}
              style={{
                background: i === 1 ? t.bgGlassHeavy : t.bgGlass,
                backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
                borderRadius: 20, padding: 24,
                border: `1px solid ${hoverCard === i && i === 2 ? c.goldPrimary : t.borderLight}`,
                boxShadow: hoverCard === i ? t.shadowHover : t.shadowCard,
                transform: hoverCard === i ? 'translateY(-4px)' : 'none',
                transition: `all 0.4s ${THEME.easing.spring}`,
                cursor: i === 2 ? 'pointer' : 'default',
                animation: `fadeIn 0.5s ease-out ${i * 0.1}s both`,
              }}>
              <div style={{ fontFamily: f.serif, fontSize: 20, marginBottom: 8 }}>{label} Card</div>
              <p style={{ fontSize: 13, color: t.textMuted, lineHeight: 1.6, margin: 0 }}>
                {i === 0 && 'Standard glass surface with subtle blur and border.'}
                {i === 1 && 'Elevated glass with heavier opacity for prominent content.'}
                {i === 2 && 'Interactive glass with hover lift, gold border focus, and spring animation.'}
              </p>
            </div>
          ))}
        </div>

        {/* ── SECTION: BUTTONS ── */}
        <SectionHeader title="Buttons" subtitle="Gold actions, outlined secondaries, ghost tertiaries" t={t} f={f} c={c} />
        <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap', marginBottom: 48, alignItems: 'center' }}>
          <button style={{
            background: `linear-gradient(135deg, ${c.goldPrimary}, ${c.goldDark})`,
            color: '#FAFAF8', border: 'none', borderRadius: 12, padding: '14px 28px',
            fontFamily: f.sans, fontSize: 14, fontWeight: 500, cursor: 'pointer',
            boxShadow: '0 4px 16px rgba(197,160,89,0.3)',
            transition: `all 0.3s ${THEME.easing.spring}`,
          }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              Start Your Journey <ArrowRight size={16} />
            </span>
          </button>
          <button style={{
            background: 'transparent', color: c.goldPrimary,
            border: `1.5px solid ${c.goldPrimary}`, borderRadius: 12, padding: '13px 28px',
            fontFamily: f.sans, fontSize: 14, fontWeight: 500, cursor: 'pointer',
          }}>
            Explore Ecosystem
          </button>
          <button style={{
            background: 'transparent', color: t.textMuted, border: 'none',
            padding: '13px 20px', fontFamily: f.sans, fontSize: 14, cursor: 'pointer',
            textDecoration: 'underline', textUnderlineOffset: 4,
          }}>
            Learn More
          </button>
        </div>

        {/* ── SECTION: QUOTE CARDS ── */}
        <SectionHeader title="Quote Cards" subtitle="Wisdom rendered in glass and gold" t={t} f={f} c={c} />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 16, marginBottom: 48 }}>
          {QUOTES.map((q, i) => (
            <div key={i} style={{
              background: t.bgGlass, backdropFilter: 'blur(12px)',
              borderRadius: 20, padding: 28, position: 'relative', overflow: 'hidden',
              border: `1px solid ${t.borderLight}`, boxShadow: t.shadowCard,
              animation: `fadeIn 0.6s ease-out ${i * 0.1}s both`,
            }}>
              <div style={{
                position: 'absolute', top: -8, left: 16, fontSize: 64,
                fontFamily: f.serif, color: c.goldPrimary, opacity: 0.2, lineHeight: 1,
              }}>"</div>
              <p style={{
                fontFamily: f.serif, fontSize: 17, fontStyle: 'italic',
                lineHeight: 1.6, margin: '0 0 16px', position: 'relative', zIndex: 1,
              }}>
                {q.text}
              </p>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: 12, color: c.goldPrimary, fontWeight: 600, letterSpacing: 1 }}>
                  — {q.author}
                </span>
                <div style={{ display: 'flex', gap: 8 }}>
                  <Heart size={14} color={t.textLight} style={{ cursor: 'pointer' }} />
                  <Share2 size={14} color={t.textLight} style={{ cursor: 'pointer' }} />
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* ── SECTION: APP PROMO CARDS ── */}
        <SectionHeader title="App Promo Cards" subtitle="Cross-promotion across the Luminous ecosystem" t={t} f={f} c={c} />
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 14, marginBottom: 48 }}>
          {APPS.map((app, i) => {
            const Icon = app.icon;
            return (
              <div key={i} style={{
                background: t.bgGlass, backdropFilter: 'blur(12px)',
                borderRadius: 16, padding: 20, cursor: 'pointer',
                border: `1px solid ${t.borderLight}`, boxShadow: t.shadowCard,
                transition: `all 0.3s ${THEME.easing.spring}`,
                animation: `fadeIn 0.5s ease-out ${i * 0.08}s both`,
              }}>
                <div style={{
                  width: 40, height: 40, borderRadius: 12,
                  background: `${app.color}22`, display: 'flex',
                  alignItems: 'center', justifyContent: 'center', marginBottom: 12,
                }}>
                  <Icon size={20} color={app.color} />
                </div>
                <div style={{ fontFamily: f.serif, fontSize: 16, marginBottom: 4 }}>{app.name}</div>
                <div style={{ fontSize: 12, color: t.textMuted }}>{app.desc}</div>
                <div style={{
                  display: 'flex', alignItems: 'center', gap: 4, marginTop: 12,
                  fontSize: 11, color: c.goldPrimary, fontWeight: 500,
                }}>
                  Open <ExternalLink size={11} />
                </div>
              </div>
            );
          })}
        </div>

        {/* ── SECTION: SHARE BUTTON ── */}
        <SectionHeader title="Sharing & Actions" subtitle="Easily share wisdom across the ecosystem" t={t} f={f} c={c} />
        <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap', marginBottom: 48 }}>
          {['Share Quote', 'Share to Instagram', 'Copy Link', 'Invite a Friend'].map((label, i) => (
            <button key={i} style={{
              display: 'flex', alignItems: 'center', gap: 8,
              background: i === 0 ? `${c.goldPrimary}18` : t.bgGlass,
              backdropFilter: 'blur(8px)', border: `1px solid ${i === 0 ? c.goldPrimary + '40' : t.borderLight}`,
              borderRadius: 12, padding: '10px 18px', cursor: 'pointer',
              fontFamily: f.sans, fontSize: 13, color: i === 0 ? c.goldPrimary : t.textMain,
            }}>
              <Share2 size={14} /> {label}
            </button>
          ))}
        </div>

        {/* ── SECTION: ANIMATIONS ── */}
        <SectionHeader title="Animations" subtitle="Breathe, ripple, float, shimmer — organic motion" t={t} f={f} c={c} />
        <div style={{ display: 'flex', gap: 24, flexWrap: 'wrap', marginBottom: 48, justifyContent: 'center' }}>
          {[
            { name: 'Breathe', anim: 'breathe 4s infinite alternate ease-in-out', bg: c.green200 },
            { name: 'Ripple', anim: 'ripple 2s infinite', bg: c.goldPrimary },
            { name: 'Float', anim: 'float 3s infinite ease-in-out', bg: c.teal },
            { name: 'Pulse', anim: 'pulse 2s infinite', bg: c.green700 },
          ].map((a, i) => (
            <div key={i} style={{ textAlign: 'center' }}>
              <div style={{
                width: 64, height: 64, borderRadius: '50%',
                background: a.bg, animation: a.anim, margin: '0 auto 8px',
                boxShadow: a.name === 'Ripple' ? undefined : `0 4px 20px ${a.bg}40`,
              }} />
              <div style={{ fontSize: 12, color: t.textMuted }}>{a.name}</div>
            </div>
          ))}
        </div>

        {/* ── SECTION: THEME TOKENS ── */}
        <SectionHeader title="Theme Tokens" subtitle="CSS custom properties for light and dark modes" t={t} f={f} c={c} />
        <div style={{
          background: dark ? 'rgba(10,28,20,0.8)' : 'rgba(18,46,33,0.95)',
          borderRadius: 16, padding: 24, fontFamily: 'monospace', fontSize: 12,
          color: '#E8F0EA', lineHeight: 2, marginBottom: 48, overflow: 'auto',
        }}>
          {`:root {\n`}
          {`  --bg-base: ${t.bgBase};\n`}
          {`  --bg-glass: ${t.bgGlass};\n`}
          {`  --text-main: ${t.textMain};\n`}
          {`  --text-muted: ${t.textMuted};\n`}
          {`  --gold-primary: ${c.goldPrimary};\n`}
          {`  --green-800: ${c.green800};\n`}
          {`  --border-light: ${t.borderLight};\n`}
          {`  --font-serif: ${f.serif};\n`}
          {`  --font-sans: ${f.sans};\n`}
          {`  --spring: ${THEME.easing.spring};\n`}
          {`}`}
        </div>

        {/* ── FOOTER ── */}
        <div style={{
          textAlign: 'center', padding: '40px 0 20px',
          borderTop: `1px solid ${t.borderLight}`,
        }}>
          <div style={{ fontFamily: f.serif, fontSize: 18, marginBottom: 4 }}>
            Luminous Ego Development™
          </div>
          <div style={{ fontSize: 12, color: t.textLight }}>
            Resonance Design System v1.0 — Shared across all platforms
          </div>
        </div>
      </div>
    </div>
  );
}

// ── SECTION HEADER COMPONENT ──
function SectionHeader({ title, subtitle, t, f, c }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <h2 style={{
        fontFamily: f.serif, fontSize: 28, fontWeight: 400, margin: 0,
        color: t.textMain,
      }}>
        {title}
      </h2>
      <div style={{
        width: 40, height: 2, margin: '8px 0',
        background: `linear-gradient(90deg, ${c.goldPrimary}, transparent)`,
      }} />
      <p style={{ fontSize: 13, color: t.textMuted, margin: 0 }}>{subtitle}</p>
    </div>
  );
}
