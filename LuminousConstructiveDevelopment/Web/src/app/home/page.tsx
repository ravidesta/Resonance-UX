// MARK: - Luminous Journey™ Web App — Home Dashboard
// Next.js 14+ • Resonance-UX Design • Desktop + Mobile responsive

'use client';

import { useState } from 'react';
import Link from 'next/link';

const colors = {
  forest: { deepest: '#0A1C14', deep: '#122E21', base: '#1B402E' },
  gold: { primary: '#C5A059', muted: '#9A7A3A' },
  earth: { cream: '#FAFAF8', warm: '#F5F0E8' },
  text: { primary: '#1B402E', secondary: '#8A9C91', muted: '#A8B5AD' },
  seasons: {
    compression: '#8A5A4A', trembling: '#B07A5A', emptiness: '#A8B5AD',
    emergence: '#4A9A6A', integration: '#C5A059',
  },
};

type NavItem = { id: string; label: string; icon: string; href: string };

const navItems: NavItem[] = [
  { id: 'home', label: 'Home', icon: '🏠', href: '/home' },
  { id: 'learn', label: 'Read', icon: '📖', href: '/reader' },
  { id: 'listen', label: 'Listen', icon: '🎧', href: '/audiobook' },
  { id: 'practice', label: 'Practice', icon: '🧘', href: '/somatic' },
  { id: 'journal', label: 'Journal', icon: '📝', href: '/journal' },
  { id: 'guide', label: 'Guide', icon: '💬', href: '/guide' },
  { id: 'community', label: 'Community', icon: '🌐', href: '/community' },
];

export default function HomePage() {
  const [activeNav, setActiveNav] = useState('home');
  const [isDeepRest, setIsDeepRest] = useState(false);

  const bg = isDeepRest ? colors.forest.deepest : colors.earth.cream;
  const surface = isDeepRest ? colors.forest.deep : '#fff';
  const text = isDeepRest ? '#C8D4CC' : colors.text.primary;
  const textSec = isDeepRest ? '#8A9C91' : colors.text.secondary;

  return (
    <div style={{
      display: 'flex',
      minHeight: '100vh',
      backgroundColor: bg,
      fontFamily: "'Manrope', sans-serif",
      color: text,
      transition: 'background-color 0.5s ease, color 0.5s ease',
    }}>
      {/* ─── Sidebar (desktop) ─────────────────────────────────── */}
      <nav style={{
        width: 220,
        padding: '24px 16px',
        borderRight: `1px solid ${colors.gold.primary}0a`,
        display: 'flex',
        flexDirection: 'column',
        gap: 4,
      }}>
        <h1 style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: 24,
          fontWeight: 300,
          marginBottom: 32,
          paddingLeft: 12,
        }}>
          Luminous
        </h1>

        {navItems.map((item) => (
          <Link
            key={item.id}
            href={item.href}
            onClick={() => setActiveNav(item.id)}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              padding: '10px 12px',
              borderRadius: 10,
              textDecoration: 'none',
              color: activeNav === item.id ? colors.gold.primary : textSec,
              backgroundColor: activeNav === item.id ? `${colors.gold.primary}12` : 'transparent',
              fontSize: 14,
              fontWeight: activeNav === item.id ? 600 : 400,
              transition: 'all 0.2s',
            }}
          >
            <span style={{ fontSize: 18 }}>{item.icon}</span>
            {item.label}
          </Link>
        ))}

        <div style={{ flex: 1 }} />

        {/* Season indicator */}
        <div style={{
          padding: '12px',
          display: 'flex', alignItems: 'center', gap: 8,
        }}>
          <div style={{
            width: 10, height: 10, borderRadius: '50%',
            backgroundColor: colors.seasons.emergence,
          }} />
          <span style={{ fontSize: 12, color: textSec }}>Emergence</span>
        </div>

        {/* Deep Rest toggle */}
        <button
          onClick={() => setIsDeepRest(!isDeepRest)}
          style={{
            padding: '8px 12px',
            borderRadius: 8,
            border: 'none',
            backgroundColor: isDeepRest ? colors.gold.muted + '33' : colors.forest.base + '08',
            color: textSec,
            fontSize: 13,
            cursor: 'pointer',
            display: 'flex', alignItems: 'center', gap: 8,
          }}
        >
          {isDeepRest ? '☀️' : '🌙'} {isDeepRest ? 'Light Mode' : 'Deep Rest'}
        </button>
      </nav>

      {/* ─── Main Content ──────────────────────────────────────── */}
      <main style={{
        flex: 1,
        padding: 32,
        overflowY: 'auto',
        maxWidth: 900,
      }}>
        {/* Header */}
        <div style={{ textAlign: 'center', marginBottom: 40 }}>
          <h2 style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: 36,
            fontWeight: 300,
            marginBottom: 8,
          }}>
            Luminous Journey
          </h2>
          <p style={{ fontSize: 14, color: textSec }}>
            Season of Emergence
          </p>
        </div>

        {/* Cards Grid */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))',
          gap: 20,
        }}>
          {/* Somatic Check-In */}
          <Card surface={surface} isDeepRest={isDeepRest}>
            <SectionLabel text="SOMATIC CHECK-IN" />
            <p style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: 22,
              lineHeight: 1.4,
              margin: '12px 0',
            }}>
              What new sensations or patterns are you beginning to notice?
            </p>
            <Link href="/journal" style={{
              display: 'inline-block',
              padding: '10px 24px',
              backgroundColor: colors.forest.base,
              color: colors.earth.cream,
              borderRadius: 9999,
              fontSize: 14, fontWeight: 600,
              textDecoration: 'none',
            }}>
              Reflect
            </Link>
          </Card>

          {/* Continue */}
          <Card surface={surface} isDeepRest={isDeepRest}>
            <SectionLabel text="CONTINUE" />
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginTop: 8 }}>
              <Link href="/reader" style={{
                display: 'flex', alignItems: 'center', gap: 12,
                textDecoration: 'none', color: text,
              }}>
                <span>📖</span>
                <div>
                  <p style={{ fontSize: 15, fontWeight: 500 }}>Chapter 2: Subject-Object Dynamics</p>
                  <p style={{ fontSize: 13, color: textSec }}>42% complete</p>
                </div>
              </Link>
              <Link href="/audiobook" style={{
                display: 'flex', alignItems: 'center', gap: 12,
                textDecoration: 'none', color: text,
              }}>
                <span>🎧</span>
                <div>
                  <p style={{ fontSize: 15, fontWeight: 500 }}>Ch. 1: Theoretical Foundations</p>
                  <p style={{ fontSize: 13, color: textSec }}>1h 23m remaining</p>
                </div>
              </Link>
            </div>
          </Card>

          {/* Guide */}
          <Card surface={surface} isDeepRest={isDeepRest}>
            <Link href="/guide" style={{
              display: 'flex', alignItems: 'center', gap: 16,
              textDecoration: 'none', color: text,
            }}>
              <span style={{ fontSize: 28 }}>💬</span>
              <div>
                <p style={{
                  fontFamily: "'Cormorant Garamond', serif",
                  fontSize: 20,
                }}>
                  Talk with your Guide
                </p>
                <p style={{ fontSize: 14, color: textSec }}>
                  Explore what&#39;s alive in you right now
                </p>
              </div>
            </Link>
          </Card>

          {/* Today's Practice */}
          <Card surface={surface} isDeepRest={isDeepRest}>
            <SectionLabel text="TODAY'S PRACTICE" />
            <h3 style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: 20, marginTop: 8,
            }}>
              Body Listening
            </h3>
            <p style={{ fontSize: 13, color: textSec, marginTop: 4 }}>
              8 minutes · Body Scan · Season of Emergence
            </p>
            <p style={{ fontSize: 14, color: textSec, marginTop: 8, lineHeight: 1.5 }}>
              Tuning into the new patterns that are beginning to take shape in the body.
            </p>
          </Card>

          {/* Ecosystem */}
          <Card surface={surface} isDeepRest={isDeepRest}>
            <SectionLabel text="RESONANCE ECOSYSTEM" />
            <div style={{
              display: 'flex', gap: 24, marginTop: 12, justifyContent: 'center',
            }}>
              {[
                { name: 'Daily Flow', connected: true },
                { name: 'Resonance', connected: true },
                { name: 'Writer', connected: false },
                { name: 'Provider', connected: false },
              ].map((item) => (
                <div key={item.name} style={{ textAlign: 'center' }}>
                  <div style={{
                    width: 8, height: 8, borderRadius: '50%',
                    backgroundColor: item.connected ? colors.gold.primary : `${textSec}44`,
                    margin: '0 auto 4px',
                  }} />
                  <span style={{ fontSize: 11, color: textSec }}>{item.name}</span>
                </div>
              ))}
            </div>
          </Card>
        </div>
      </main>

      <style jsx global>{`
        @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;1,300;1,400&family=Manrope:wght@400;500;600;700&display=swap');
        * { margin: 0; padding: 0; box-sizing: border-box; }
        ::selection { background: ${colors.gold.primary}33; }
      `}</style>
    </div>
  );
}

// ─── Reusable Components ─────────────────────────────────────────────────

function Card({ children, surface, isDeepRest }: {
  children: React.ReactNode;
  surface: string;
  isDeepRest: boolean;
}) {
  return (
    <div style={{
      padding: 20,
      borderRadius: 16,
      backgroundColor: isDeepRest ? `${surface}99` : `${surface}b8`,
      backdropFilter: 'blur(12px)',
      border: `1px solid ${colors.gold.primary}0d`,
      boxShadow: '0 4px 8px rgba(10,28,20,0.06)',
      transition: 'background-color 0.5s ease',
    }}>
      {children}
    </div>
  );
}

function SectionLabel({ text }: { text: string }) {
  return (
    <p style={{
      fontSize: 12,
      fontWeight: 600,
      letterSpacing: 0.5,
      color: colors.gold.primary,
    }}>
      {text}
    </p>
  );
}
