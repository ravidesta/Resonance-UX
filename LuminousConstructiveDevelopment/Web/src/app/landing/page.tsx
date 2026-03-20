// MARK: - Luminous Journey™ Landing Page
// Next.js 14+ App Router • Resonance-UX Design System
// "Design for the exhale." — The first breath a visitor takes.

'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

// ─── Resonance-UX Design Tokens ─────────────────────────────────────────

const colors = {
  forest: { deepest: '#0A1C14', deep: '#122E21', base: '#1B402E', muted: '#2A5A42' },
  gold: { primary: '#C5A059', muted: '#9A7A3A', light: '#D4B878' },
  earth: { cream: '#FAFAF8', warm: '#F5F0E8', sand: '#E8DFD0' },
  text: { primary: '#1B402E', secondary: '#8A9C91', muted: '#A8B5AD' },
  orders: {
    impulsive: '#E8A87C', imperial: '#D4956B', socialized: '#5A8AB0',
    selfAuthoring: '#4A9A6A', selfTransforming: '#8B6BB0',
  },
};

// ─── Landing Page ────────────────────────────────────────────────────────

export default function LandingPage() {
  const [breathScale, setBreathScale] = useState(1);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
    // Breathing animation via CSS (see styles below)
  }, []);

  return (
    <main style={{
      backgroundColor: colors.earth.cream,
      minHeight: '100vh',
      fontFamily: "'Manrope', sans-serif",
      color: colors.text.primary,
    }}>
      {/* ─── Paper Texture Overlay ──────────────────────────────── */}
      <div style={{
        position: 'fixed', inset: 0,
        background: 'url("data:image/svg+xml,...") repeat',
        opacity: 0.035, pointerEvents: 'none', zIndex: 1,
        mixBlendMode: 'overlay',
      }} />

      {/* ─── Hero Section ──────────────────────────────────────── */}
      <section style={{
        minHeight: '100vh',
        display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
        textAlign: 'center',
        padding: '0 24px',
        position: 'relative',
        overflow: 'hidden',
      }}>
        {/* Breathing Blob */}
        <div style={{
          position: 'absolute',
          width: 400, height: 400,
          borderRadius: '50%',
          background: `radial-gradient(circle, ${colors.gold.primary}22 0%, ${colors.forest.base}08 50%, transparent 70%)`,
          animation: 'breathe 18s ease-in-out infinite',
          filter: 'blur(60px)',
        }} />

        <div style={{
          position: 'relative', zIndex: 2,
          opacity: isVisible ? 1 : 0,
          transform: isVisible ? 'translateY(0)' : 'translateY(20px)',
          transition: 'all 1.2s cubic-bezier(0.34, 1.56, 0.64, 1)',
        }}>
          <p style={{
            fontFamily: "'Manrope', sans-serif",
            fontSize: 13, fontWeight: 600,
            letterSpacing: 2, textTransform: 'uppercase',
            color: colors.gold.primary,
            marginBottom: 24,
          }}>
            A Resonance-UX Experience
          </p>

          <h1 style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: 'clamp(36px, 6vw, 72px)',
            fontWeight: 300,
            lineHeight: 1.1,
            color: colors.forest.base,
            marginBottom: 24,
            maxWidth: 800,
          }}>
            Luminous Constructive<br />Development™
          </h1>

          <p style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: 'clamp(18px, 2.5vw, 28px)',
            fontWeight: 400,
            color: colors.text.secondary,
            lineHeight: 1.4,
            maxWidth: 600,
            marginBottom: 48,
          }}>
            Subject-Object and the Evolution of Meaning
          </p>

          <p style={{
            fontSize: 17,
            color: colors.text.secondary,
            lineHeight: 1.6,
            maxWidth: 560,
            marginBottom: 48,
          }}>
            A transformative journey through the landscape of human development.
            Read, listen, practice, reflect — with an AI guide that honors
            every stage of your becoming.
          </p>

          {/* CTA Buttons */}
          <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap', justifyContent: 'center' }}>
            <Link href="/home" style={{
              display: 'inline-flex', alignItems: 'center', gap: 8,
              padding: '14px 32px',
              backgroundColor: colors.forest.base,
              color: colors.earth.cream,
              borderRadius: 9999,
              fontWeight: 600, fontSize: 15,
              textDecoration: 'none',
              transition: 'transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s',
              boxShadow: `0 4px 16px ${colors.forest.base}33`,
            }}>
              Begin Your Journey
            </Link>

            <Link href="/learn" style={{
              display: 'inline-flex', alignItems: 'center', gap: 8,
              padding: '14px 32px',
              backgroundColor: 'transparent',
              color: colors.forest.base,
              borderRadius: 9999,
              fontWeight: 600, fontSize: 15,
              textDecoration: 'none',
              border: `1.5px solid ${colors.forest.base}22`,
              transition: 'all 0.3s',
            }}>
              Read Chapter 1 Free
            </Link>
          </div>
        </div>

        {/* Scroll indicator */}
        <div style={{
          position: 'absolute', bottom: 40,
          animation: 'float 3s ease-in-out infinite',
        }}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke={colors.text.muted} strokeWidth="1.5">
            <path d="M12 5v14M5 12l7 7 7-7" />
          </svg>
        </div>
      </section>

      {/* ─── The Question Section ──────────────────────────────── */}
      <section style={{
        padding: '120px 24px',
        maxWidth: 760,
        margin: '0 auto',
        textAlign: 'center',
      }}>
        <p style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: 'clamp(24px, 4vw, 42px)',
          fontWeight: 400,
          lineHeight: 1.3,
          color: colors.forest.base,
        }}>
          "Who is the one making meaning —<br />
          and what are they making meaning of?"
        </p>
        <p style={{
          marginTop: 24,
          fontSize: 15,
          color: colors.text.secondary,
          lineHeight: 1.6,
        }}>
          This is the subject-object question. It is the beating heart of
          Luminous Constructive Development™ — and it is alive in every
          moment of your waking life.
        </p>
      </section>

      {/* ─── Five Orders Section ───────────────────────────────── */}
      <section style={{
        padding: '80px 24px',
        backgroundColor: colors.forest.deepest,
        color: colors.earth.cream,
      }}>
        <div style={{ maxWidth: 1000, margin: '0 auto' }}>
          <p style={{
            fontFamily: "'Manrope', sans-serif",
            fontSize: 13, fontWeight: 600,
            letterSpacing: 2, textTransform: 'uppercase',
            color: colors.gold.primary,
            textAlign: 'center',
            marginBottom: 16,
          }}>
            Kegan's Five Orders of Consciousness
          </p>

          <h2 style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: 'clamp(28px, 4vw, 44px)',
            fontWeight: 300,
            textAlign: 'center',
            marginBottom: 64,
          }}>
            The Spiral of Becoming
          </h2>

          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
            gap: 24,
          }}>
            {[
              { name: 'Impulsive Mind', color: colors.orders.impulsive, gift: 'Radical presence', order: '1st' },
              { name: 'Imperial Mind', color: colors.orders.imperial, gift: 'Purposeful action', order: '2nd' },
              { name: 'Socialized Mind', color: colors.orders.socialized, gift: 'Deep empathy', order: '3rd' },
              { name: 'Self-Authoring Mind', color: colors.orders.selfAuthoring, gift: 'Principled autonomy', order: '4th' },
              { name: 'Self-Transforming Mind', color: colors.orders.selfTransforming, gift: 'Paradox-friendliness', order: '5th' },
            ].map((order) => (
              <div key={order.name} style={{
                padding: 24,
                borderRadius: 16,
                backgroundColor: `${colors.forest.deep}`,
                border: `1px solid ${order.color}22`,
                textAlign: 'center',
              }}>
                <div style={{
                  width: 48, height: 48, borderRadius: '50%',
                  backgroundColor: `${order.color}33`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  margin: '0 auto 16px',
                  fontFamily: "'Cormorant Garamond', serif",
                  fontSize: 20, fontWeight: 300,
                  color: order.color,
                }}>
                  {order.order}
                </div>
                <h3 style={{
                  fontFamily: "'Cormorant Garamond', serif",
                  fontSize: 20, fontWeight: 400,
                  marginBottom: 8,
                }}>
                  {order.name}
                </h3>
                <p style={{
                  fontSize: 14, color: `${colors.earth.cream}aa`,
                  fontStyle: 'italic',
                }}>
                  Gift: {order.gift}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── Features Section ──────────────────────────────────── */}
      <section style={{ padding: '120px 24px', maxWidth: 1000, margin: '0 auto' }}>
        <h2 style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: 'clamp(28px, 4vw, 44px)',
          fontWeight: 300, textAlign: 'center',
          marginBottom: 16,
        }}>
          Your Luminous Journey
        </h2>
        <p style={{
          fontSize: 16, color: colors.text.secondary,
          textAlign: 'center', marginBottom: 64,
          maxWidth: 600, margin: '0 auto 64px',
        }}>
          Read, listen, practice, reflect, and grow — with a compassionate AI guide
          and a community that honors every stage.
        </p>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: 24,
        }}>
          {[
            { icon: '📖', title: 'Read', desc: 'A sanctuary reading experience with highlights, annotations, and seamless audiobook switching.' },
            { icon: '🎧', title: 'Listen', desc: 'Audiobook narrated with presence and warmth. Sleep timer, speed control, bookmark anywhere.' },
            { icon: '🧘', title: 'Practice', desc: 'Somatic practices matched to your developmental season. Body scans, breathwork, movement, grounding.' },
            { icon: '📝', title: 'Journal', desc: 'Eight reflection types: Subject Scan, Relational Mirror, Somatic Witness, Spiral Mapping, and more.' },
            { icon: '💬', title: 'Guide', desc: 'An AI companion grounded in Luminous principles. Never ranking. Always honoring. Somatically aware.' },
            { icon: '🌐', title: 'Community', desc: 'Peer groups, shared insights, resonances. Intentional status, not surveillance. Connection as consent.' },
            { icon: '📊', title: 'Assessment', desc: 'Understand your meaning-making landscape across six life domains. Snapshots, not verdicts.' },
            { icon: '🔗', title: 'Ecosystem', desc: 'Connects to Daily Flow, Resonance Comms, Writer, and Provider — the full Resonance-UX experience.' },
            { icon: '📤', title: 'Share', desc: 'Beautiful share cards for every platform. Quotes, highlights, milestones — gorgeous free advertising.' },
          ].map((feature) => (
            <div key={feature.title} style={{
              padding: 24,
              borderRadius: 16,
              backgroundColor: 'rgba(255,255,255,0.72)',
              backdropFilter: 'blur(12px)',
              border: `1px solid ${colors.gold.primary}12`,
              boxShadow: '0 4px 8px rgba(10,28,20,0.06)',
            }}>
              <div style={{ fontSize: 28, marginBottom: 12 }}>{feature.icon}</div>
              <h3 style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: 22, fontWeight: 400,
                marginBottom: 8,
              }}>
                {feature.title}
              </h3>
              <p style={{
                fontSize: 14, color: colors.text.secondary,
                lineHeight: 1.6,
              }}>
                {feature.desc}
              </p>
            </div>
          ))}
        </div>
      </section>

      {/* ─── Platforms Section ──────────────────────────────────── */}
      <section style={{
        padding: '80px 24px',
        backgroundColor: colors.earth.warm,
        textAlign: 'center',
      }}>
        <p style={{
          fontFamily: "'Manrope', sans-serif",
          fontSize: 13, fontWeight: 600,
          letterSpacing: 2, textTransform: 'uppercase',
          color: colors.gold.primary,
          marginBottom: 16,
        }}>
          Every Platform. Native Code.
        </p>
        <h2 style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: 'clamp(28px, 4vw, 44px)',
          fontWeight: 300,
          marginBottom: 48,
        }}>
          Your Journey, Everywhere
        </h2>

        <div style={{
          display: 'flex', flexWrap: 'wrap', gap: 32,
          justifyContent: 'center', maxWidth: 800, margin: '0 auto',
        }}>
          {[
            { platform: 'iPhone', tech: 'SwiftUI' },
            { platform: 'iPad', tech: 'SwiftUI' },
            { platform: 'Mac', tech: 'SwiftUI' },
            { platform: 'Apple Watch', tech: 'SwiftUI' },
            { platform: 'Android', tech: 'Jetpack Compose' },
            { platform: 'Web', tech: 'Next.js + React' },
          ].map((p) => (
            <div key={p.platform} style={{ textAlign: 'center' }}>
              <div style={{
                width: 72, height: 72, borderRadius: 16,
                backgroundColor: colors.forest.base,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                margin: '0 auto 8px',
                color: colors.gold.primary,
                fontSize: 24,
              }}>
                {p.platform[0]}
              </div>
              <p style={{ fontSize: 14, fontWeight: 600 }}>{p.platform}</p>
              <p style={{ fontSize: 12, color: colors.text.secondary }}>{p.tech}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ─── CTA Section ───────────────────────────────────────── */}
      <section style={{
        padding: '120px 24px',
        textAlign: 'center',
      }}>
        <p style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: 'clamp(20px, 3vw, 32px)',
          fontWeight: 400,
          color: colors.text.secondary,
          lineHeight: 1.4,
          maxWidth: 600,
          margin: '0 auto 48px',
          fontStyle: 'italic',
        }}>
          "The very act of turning attention toward how you make meaning
          is itself a developmental act. It is, in the most precise sense
          of the word, luminous."
        </p>

        <Link href="/home" style={{
          display: 'inline-flex', alignItems: 'center', gap: 8,
          padding: '16px 40px',
          backgroundColor: colors.forest.base,
          color: colors.earth.cream,
          borderRadius: 9999,
          fontWeight: 600, fontSize: 16,
          textDecoration: 'none',
          boxShadow: `0 8px 24px ${colors.forest.base}33`,
          transition: 'transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
        }}>
          Begin Your Luminous Journey
        </Link>

        <p style={{
          marginTop: 24,
          fontSize: 13,
          color: colors.text.muted,
        }}>
          Part of the Resonance-UX ecosystem by Luminous Prosperity
        </p>
      </section>

      {/* ─── Footer ────────────────────────────────────────────── */}
      <footer style={{
        padding: '40px 24px',
        textAlign: 'center',
        borderTop: `1px solid ${colors.forest.base}0a`,
      }}>
        <p style={{ fontSize: 13, color: colors.text.muted }}>
          Luminous Constructive Development™ · A Luminous Prosperity Framework
        </p>
        <p style={{ fontSize: 12, color: colors.text.muted, marginTop: 8 }}>
          Development is not a competition. Every stage has its own dignity.
        </p>
      </footer>

      {/* ─── Global Styles ─────────────────────────────────────── */}
      <style jsx global>{`
        @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400&family=Manrope:wght@400;500;600;700&display=swap');

        @keyframes breathe {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.15); }
        }

        @keyframes float {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(8px); }
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        ::selection {
          background: ${colors.gold.primary}33;
          color: ${colors.forest.base};
        }
      `}</style>
    </main>
  );
}
