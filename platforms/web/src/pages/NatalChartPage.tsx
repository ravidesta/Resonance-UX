import React, { useEffect, useState } from 'react';
import ZodiacWheel from '../components/ZodiacWheel';
import GlassPanel from '../components/GlassPanel';
import { useChartCalculator } from '../hooks/useChartCalculator';
import { PLANET_INFO, ZODIAC_SIGNS, ASPECT_INFO } from '../types/astrology';
import type { BirthData, NatalChart, AspectType } from '../types/astrology';

const NatalChartPage: React.FC = () => {
  const { chart, calculate, isCalculating } = useChartCalculator();
  const [activeTab, setActiveTab] = useState<'planets' | 'houses' | 'aspects'>('planets');

  useEffect(() => {
    const stored = localStorage.getItem('lca-birth-data');
    if (stored) {
      const data: BirthData = JSON.parse(stored);
      calculate(data);
    }
  }, [calculate]);

  const tabStyle = (isActive: boolean): React.CSSProperties => ({
    padding: '0.5rem 1rem',
    borderRadius: '9999px',
    fontSize: '0.8rem',
    fontWeight: isActive ? 600 : 400,
    letterSpacing: '0.05em',
    textTransform: 'uppercase',
    color: isActive ? 'var(--cream-100, #FAFAF8)' : 'var(--text-tertiary)',
    background: isActive ? 'linear-gradient(135deg, #C5A059, #9A7A3A)' : 'transparent',
    transition: 'all 250ms cubic-bezier(0.34, 1.56, 0.64, 1)',
  });

  const aspectLabel = (type: AspectType) => {
    const labels: Record<string, string> = {
      conjunction: 'Conjunction',
      opposition: 'Opposition',
      trine: 'Trine',
      square: 'Square',
      sextile: 'Sextile',
      quincunx: 'Quincunx',
    };
    return labels[type] || type;
  };

  if (isCalculating) {
    return (
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '80vh',
          flexDirection: 'column',
          gap: '1rem',
        }}
      >
        <div
          style={{
            width: '60px',
            height: '60px',
            border: '2px solid var(--sage-300, #A8B8AD)',
            borderTopColor: 'var(--gold-600, #C5A059)',
            borderRadius: '50%',
            animation: 'rotate 1.2s linear infinite',
          }}
        />
        <p style={{ color: 'var(--text-tertiary)', fontSize: '0.9rem' }}>Mapping the heavens...</p>
      </div>
    );
  }

  if (!chart) {
    return (
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '80vh',
          color: 'var(--text-tertiary)',
        }}
      >
        No chart data. Complete onboarding first.
      </div>
    );
  }

  return (
    <div
      style={{
        padding: '1.5rem 1rem 6rem',
        maxWidth: '720px',
        margin: '0 auto',
        width: '100%',
      }}
    >
      {/* Header */}
      <header
        style={{
          marginBottom: '1.5rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
        }}
      >
        <h1
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.75rem',
            fontWeight: 500,
            marginBottom: '0.25rem',
          }}
        >
          Your Natal Chart
        </h1>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-tertiary)', margin: 0 }}>
          {chart.sunSign} Sun &middot; {chart.moonSign} Moon &middot; {chart.ascendantSign} Rising
        </p>
      </header>

      {/* Zodiac Wheel */}
      <div
        style={{
          marginBottom: '2rem',
          animation: 'fadeInScale 600ms cubic-bezier(0.34, 1.56, 0.64, 1) 150ms both',
        }}
      >
        <ZodiacWheel chart={chart} size={500} interactive />
      </div>

      {/* Tab bar */}
      <div
        style={{
          display: 'flex',
          gap: '0.5rem',
          marginBottom: '1.25rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) 300ms both',
        }}
      >
        {(['planets', 'houses', 'aspects'] as const).map((tab) => (
          <button key={tab} style={tabStyle(activeTab === tab)} onClick={() => setActiveTab(tab)}>
            {tab}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      <div
        style={{
          animation: 'fadeIn 300ms ease both',
        }}
        key={activeTab}
      >
        {activeTab === 'planets' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
            {chart.positions
              .filter((p) => p.planet !== 'Ascendant' && p.planet !== 'Midheaven')
              .map((pos, i) => {
                const info = PLANET_INFO.find((p) => p.planet === pos.planet);
                const signInfo = ZODIAC_SIGNS.find((s) => s.sign === pos.sign);
                return (
                  <GlassPanel
                    key={pos.planet}
                    padding="1rem 1.25rem"
                    borderRadius="0.75rem"
                    style={{
                      animation: `fadeInUp 400ms cubic-bezier(0.34, 1.56, 0.64, 1) ${i * 60}ms both`,
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                      <div
                        style={{
                          fontSize: '1.5rem',
                          color: info?.color || 'var(--text-accent)',
                          width: '32px',
                          textAlign: 'center',
                          flexShrink: 0,
                        }}
                      >
                        {info?.glyph || '?'}
                      </div>
                      <div style={{ flex: 1 }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                          <span
                            style={{
                              fontFamily: "'Cormorant Garamond', serif",
                              fontSize: '1.05rem',
                              fontWeight: 600,
                              color: 'var(--text-primary)',
                            }}
                          >
                            {pos.planet}
                          </span>
                          {pos.retrograde && (
                            <span
                              style={{
                                fontSize: '0.65rem',
                                color: '#C5523F',
                                fontWeight: 700,
                                padding: '0.1rem 0.35rem',
                                borderRadius: '4px',
                                background: 'rgba(197, 82, 63, 0.1)',
                              }}
                            >
                              Rx
                            </span>
                          )}
                        </div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                          {info?.description}
                        </div>
                      </div>
                      <div style={{ textAlign: 'right', flexShrink: 0 }}>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '0.35rem',
                            justifyContent: 'flex-end',
                          }}
                        >
                          <span style={{ fontSize: '1.1rem', color: signInfo?.color }}>
                            {signInfo?.glyph}
                          </span>
                          <span
                            style={{
                              fontFamily: "'Cormorant Garamond', serif",
                              fontSize: '0.95rem',
                              color: 'var(--text-primary)',
                              fontWeight: 500,
                            }}
                          >
                            {pos.sign}
                          </span>
                        </div>
                        <div style={{ fontSize: '0.75rem', color: 'var(--text-tertiary)' }}>
                          {pos.signDegree.toFixed(1)}&deg; &middot; House {pos.house}
                        </div>
                      </div>
                    </div>
                  </GlassPanel>
                );
              })}
          </div>
        )}

        {activeTab === 'houses' && (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '0.5rem' }}>
            {chart.houses.map((house, i) => {
              const signInfo = ZODIAC_SIGNS.find((s) => s.sign === house.sign);
              return (
                <GlassPanel
                  key={house.house}
                  padding="1rem"
                  borderRadius="0.75rem"
                  style={{
                    animation: `fadeInUp 400ms cubic-bezier(0.34, 1.56, 0.64, 1) ${i * 50}ms both`,
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                    <div
                      style={{
                        fontSize: '1.25rem',
                        fontWeight: 600,
                        color: 'var(--text-accent)',
                        fontFamily: "'Cormorant Garamond', serif",
                        width: '28px',
                        textAlign: 'center',
                      }}
                    >
                      {house.house}
                    </div>
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                        <span style={{ color: signInfo?.color }}>{signInfo?.glyph}</span>
                        <span
                          style={{
                            fontSize: '0.9rem',
                            fontFamily: "'Cormorant Garamond', serif",
                            fontWeight: 500,
                            color: 'var(--text-primary)',
                          }}
                        >
                          {house.sign}
                        </span>
                      </div>
                      <div style={{ fontSize: '0.7rem', color: 'var(--text-tertiary)' }}>
                        {house.signDegree.toFixed(1)}&deg;
                      </div>
                    </div>
                  </div>
                </GlassPanel>
              );
            })}
          </div>
        )}

        {activeTab === 'aspects' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
            {chart.aspects.map((aspect, i) => {
              const p1Info = PLANET_INFO.find((p) => p.planet === aspect.planet1);
              const p2Info = PLANET_INFO.find((p) => p.planet === aspect.planet2);
              const aDef = ASPECT_INFO.find((a) => a.type === aspect.type);
              return (
                <GlassPanel
                  key={i}
                  padding="0.75rem 1rem"
                  borderRadius="0.75rem"
                  style={{
                    animation: `fadeInUp 400ms cubic-bezier(0.34, 1.56, 0.64, 1) ${i * 40}ms both`,
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
                    <span style={{ fontSize: '1.1rem', color: p1Info?.color }}>{p1Info?.glyph}</span>
                    <span
                      style={{
                        fontSize: '0.75rem',
                        color: aDef?.color || 'var(--text-tertiary)',
                        fontWeight: 500,
                        textTransform: 'uppercase',
                        letterSpacing: '0.05em',
                        minWidth: '80px',
                        textAlign: 'center',
                      }}
                    >
                      {aspectLabel(aspect.type)}
                    </span>
                    <span style={{ fontSize: '1.1rem', color: p2Info?.color }}>{p2Info?.glyph}</span>
                    <span
                      style={{
                        marginLeft: 'auto',
                        fontSize: '0.75rem',
                        color: 'var(--text-tertiary)',
                      }}
                    >
                      Orb: {aspect.orb.toFixed(1)}&deg;
                      {aspect.applying ? ' (applying)' : ' (separating)'}
                    </span>
                  </div>
                </GlassPanel>
              );
            })}
            {chart.aspects.length === 0 && (
              <p style={{ color: 'var(--text-tertiary)', textAlign: 'center', padding: '2rem 0' }}>
                No major aspects found.
              </p>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default NatalChartPage;
