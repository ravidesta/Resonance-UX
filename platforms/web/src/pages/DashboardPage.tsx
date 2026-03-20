import React, { useMemo, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import GlassPanel from '../components/GlassPanel';
import MoonPhase from '../components/MoonPhase';
import TransitCard from '../components/TransitCard';
import ZodiacWheel from '../components/ZodiacWheel';
import { useChartCalculator } from '../hooks/useChartCalculator';
import { useTheme } from '../hooks/useTheme';
import type { BirthData, MoonPhaseData, TransitEvent, DailyInsight } from '../types/astrology';

/** Generate a mock moon phase based on date */
function getCurrentMoonPhase(): MoonPhaseData {
  const now = new Date();
  const daysSinceNew = ((now.getTime() / 86400000) % 29.53);
  const illumination = (1 - Math.cos((daysSinceNew / 29.53) * 2 * Math.PI)) / 2 * 100;

  const phases: Array<{ name: MoonPhaseData['name']; min: number; max: number }> = [
    { name: 'New Moon', min: 0, max: 1.85 },
    { name: 'Waxing Crescent', min: 1.85, max: 7.38 },
    { name: 'First Quarter', min: 7.38, max: 11.07 },
    { name: 'Waxing Gibbous', min: 11.07, max: 14.76 },
    { name: 'Full Moon', min: 14.76, max: 16.61 },
    { name: 'Waning Gibbous', min: 16.61, max: 22.14 },
    { name: 'Last Quarter', min: 22.14, max: 25.83 },
    { name: 'Waning Crescent', min: 25.83, max: 29.53 },
  ];

  const phase = phases.find((p) => daysSinceNew >= p.min && daysSinceNew < p.max) || phases[0];

  return {
    name: phase.name,
    illumination: Math.round(illumination),
    age: Math.round(daysSinceNew * 10) / 10,
    emoji: '',
    description: `The Moon is in its ${phase.name} phase, inviting ${
      phase.name.includes('Waxing') ? 'growth and intention-setting' :
      phase.name.includes('Waning') ? 'release and reflection' :
      phase.name === 'Full Moon' ? 'culmination and gratitude' :
      'new beginnings and seed-planting'
    }.`,
  };
}

/** Generate mock daily transits */
function getDailyTransits(): TransitEvent[] {
  return [
    {
      transitPlanet: 'Moon',
      natalPlanet: 'Venus',
      aspectType: 'trine',
      description: 'Emotional warmth flows easily today. A beautiful time for creative expression and nurturing relationships.',
      startDate: new Date().toISOString().slice(0, 10),
      peakDate: new Date().toISOString().slice(0, 10),
      endDate: new Date().toISOString().slice(0, 10),
      intensity: 'mild',
    },
    {
      transitPlanet: 'Mercury',
      natalPlanet: 'Jupiter',
      aspectType: 'sextile',
      description: 'Your mind expands into philosophical territory. Excellent for learning, writing, or meaningful conversations.',
      startDate: new Date().toISOString().slice(0, 10),
      peakDate: new Date(Date.now() + 86400000).toISOString().slice(0, 10),
      endDate: new Date(Date.now() + 172800000).toISOString().slice(0, 10),
      intensity: 'moderate',
    },
    {
      transitPlanet: 'Saturn',
      natalPlanet: 'Sun',
      aspectType: 'square',
      description: 'A period of testing and strengthening. You may feel pressure to restructure parts of your life that no longer serve you.',
      startDate: new Date(Date.now() - 604800000).toISOString().slice(0, 10),
      peakDate: new Date(Date.now() + 259200000).toISOString().slice(0, 10),
      endDate: new Date(Date.now() + 1209600000).toISOString().slice(0, 10),
      intensity: 'strong',
    },
  ];
}

function getDailyInsight(moonPhase: MoonPhaseData): DailyInsight {
  return {
    date: new Date().toISOString().slice(0, 10),
    moonPhase: moonPhase.name,
    moonSign: 'Pisces',
    sunSign: 'Pisces',
    mainTheme: 'Inner Reflection & Creative Surrender',
    reflectionPrompt: 'What part of yourself is ready to emerge from the depths? Allow your intuition to speak through imagery today.',
    transits: getDailyTransits(),
    affirmation: 'I trust the wisdom of my inner cosmos. Each moment unfolds with purpose and grace.',
  };
}

const DashboardPage: React.FC = () => {
  const navigate = useNavigate();
  const { toggle, isDark } = useTheme();
  const { chart, calculate } = useChartCalculator();
  const [birthData, setBirthData] = useState<BirthData | null>(null);

  useEffect(() => {
    const stored = localStorage.getItem('lca-birth-data');
    if (stored) {
      const data: BirthData = JSON.parse(stored);
      setBirthData(data);
      calculate(data);
    }
  }, [calculate]);

  const moonPhase = useMemo(() => getCurrentMoonPhase(), []);
  const insight = useMemo(() => getDailyInsight(moonPhase), [moonPhase]);
  const transits = useMemo(() => getDailyTransits(), []);

  const greeting = useMemo(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }, []);

  return (
    <div
      style={{
        padding: '1.5rem 1rem 6rem',
        maxWidth: '680px',
        margin: '0 auto',
        width: '100%',
      }}
    >
      {/* Header */}
      <header
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'flex-start',
          marginBottom: '2rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
        }}
      >
        <div>
          <h1
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '1.75rem',
              fontWeight: 500,
              marginBottom: '0.25rem',
            }}
          >
            {greeting}, {birthData?.name || 'Cosmic Traveler'}
          </h1>
          <p style={{ fontSize: '0.875rem', color: 'var(--text-tertiary)', margin: 0 }}>
            {new Date().toLocaleDateString('en-US', {
              weekday: 'long',
              month: 'long',
              day: 'numeric',
            })}
          </p>
        </div>

        {/* Theme toggle */}
        <button
          onClick={toggle}
          style={{
            padding: '0.5rem',
            borderRadius: '50%',
            background: 'var(--glass-bg)',
            border: 'var(--glass-border)',
            fontSize: '1.25rem',
            lineHeight: 1,
            backdropFilter: 'blur(12px)',
            transition: 'transform 350ms cubic-bezier(0.34, 1.56, 0.64, 1)',
          }}
          aria-label="Toggle theme"
        >
          {isDark ? '\u2600' : '\u263E'}
        </button>
      </header>

      {/* Daily Theme Card */}
      <GlassPanel
        glow
        padding="1.5rem"
        borderRadius="1.25rem"
        style={{
          marginBottom: '1.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 100ms both',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.75rem' }}>
          <span style={{ color: 'var(--text-accent)', fontSize: '0.75rem', letterSpacing: '0.1em', textTransform: 'uppercase', fontWeight: 600 }}>
            Today&apos;s Theme
          </span>
        </div>
        <h2
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.5rem',
            fontWeight: 600,
            color: 'var(--text-primary)',
            marginBottom: '0.5rem',
          }}
        >
          {insight.mainTheme}
        </h2>
        <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)', lineHeight: 1.6, margin: 0 }}>
          {insight.affirmation}
        </p>
      </GlassPanel>

      {/* Moon Phase & Chart mini row */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '1rem',
          marginBottom: '1.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 200ms both',
        }}
      >
        <GlassPanel padding="1.25rem" borderRadius="1rem" onClick={() => {}}>
          <MoonPhase phase={moonPhase} size={64} />
        </GlassPanel>

        <GlassPanel
          padding="1rem"
          borderRadius="1rem"
          onClick={() => navigate('/chart')}
        >
          {chart ? (
            <div style={{ pointerEvents: 'none' }}>
              <ZodiacWheel chart={chart} size={200} interactive={false} />
            </div>
          ) : (
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                height: '100%',
                color: 'var(--text-tertiary)',
                fontSize: '0.85rem',
              }}
            >
              Loading chart...
            </div>
          )}
          <div
            style={{
              textAlign: 'center',
              fontSize: '0.75rem',
              color: 'var(--text-accent)',
              marginTop: '0.5rem',
              fontWeight: 500,
              letterSpacing: '0.05em',
            }}
          >
            View Full Chart &rarr;
          </div>
        </GlassPanel>
      </div>

      {/* Cosmic Overview Row */}
      {chart && (
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(3, 1fr)',
            gap: '0.75rem',
            marginBottom: '1.5rem',
            animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 300ms both',
          }}
        >
          {[
            { label: 'Sun', value: chart.sunSign, glyph: '\u2609' },
            { label: 'Moon', value: chart.moonSign, glyph: '\u263D' },
            { label: 'Rising', value: chart.ascendantSign, glyph: 'AC' },
          ].map((item) => (
            <GlassPanel key={item.label} padding="1rem" borderRadius="0.75rem">
              <div style={{ textAlign: 'center' }}>
                <div style={{ fontSize: '1.5rem', color: 'var(--text-accent)', marginBottom: '0.25rem' }}>
                  {item.glyph}
                </div>
                <div
                  style={{
                    fontSize: '0.65rem',
                    color: 'var(--text-tertiary)',
                    textTransform: 'uppercase',
                    letterSpacing: '0.1em',
                    marginBottom: '0.15rem',
                  }}
                >
                  {item.label}
                </div>
                <div
                  style={{
                    fontFamily: "'Cormorant Garamond', serif",
                    fontSize: '1rem',
                    fontWeight: 600,
                    color: 'var(--text-primary)',
                  }}
                >
                  {item.value}
                </div>
              </div>
            </GlassPanel>
          ))}
        </div>
      )}

      {/* Reflection Prompt */}
      <GlassPanel
        padding="1.25rem"
        borderRadius="1rem"
        onClick={() => navigate('/reflection')}
        style={{
          marginBottom: '1.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 400ms both',
        }}
      >
        <div
          style={{
            fontSize: '0.7rem',
            color: 'var(--text-accent)',
            textTransform: 'uppercase',
            letterSpacing: '0.1em',
            fontWeight: 600,
            marginBottom: '0.5rem',
          }}
        >
          Daily Reflection
        </div>
        <p
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.125rem',
            fontStyle: 'italic',
            color: 'var(--text-primary)',
            lineHeight: 1.5,
            margin: 0,
          }}
        >
          &ldquo;{insight.reflectionPrompt}&rdquo;
        </p>
        <div
          style={{
            marginTop: '0.75rem',
            fontSize: '0.8rem',
            color: 'var(--text-accent)',
            fontWeight: 500,
          }}
        >
          Begin journaling &rarr;
        </div>
      </GlassPanel>

      {/* Current Transits */}
      <div
        style={{
          marginBottom: '1.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 500ms both',
        }}
      >
        <h3
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.25rem',
            fontWeight: 500,
            marginBottom: '1rem',
          }}
        >
          Current Transits
        </h3>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
          {transits.map((t, i) => (
            <TransitCard key={i} transit={t} index={i} />
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr 1fr',
          gap: '0.75rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 600ms both',
        }}
      >
        <GlassPanel
          padding="1.25rem"
          borderRadius="1rem"
          onClick={() => navigate('/meditation')}
        >
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem', marginBottom: '0.5rem' }}>&#10023;</div>
            <div
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1rem',
                fontWeight: 500,
                color: 'var(--text-primary)',
              }}
            >
              Stargazer&apos;s Attunement
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)', marginTop: '0.25rem' }}>
              Guided meditation
            </div>
          </div>
        </GlassPanel>

        <GlassPanel
          padding="1.25rem"
          borderRadius="1rem"
          onClick={() => navigate('/library')}
        >
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem', marginBottom: '0.5rem' }}>&#9776;</div>
            <div
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1rem',
                fontWeight: 500,
                color: 'var(--text-primary)',
              }}
            >
              Chapter Library
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)', marginTop: '0.25rem' }}>
              Explore teachings
            </div>
          </div>
        </GlassPanel>
      </div>
    </div>
  );
};

export default DashboardPage;
