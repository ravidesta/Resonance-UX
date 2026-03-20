import React from 'react';
import type { TransitEvent } from '../types/astrology';
import { PLANET_INFO } from '../types/astrology';
import GlassPanel from './GlassPanel';

interface TransitCardProps {
  transit: TransitEvent;
  index?: number;
}

/**
 * TransitCard - displays a single transit event with planet glyphs,
 * aspect type, and intensity indicator.
 */
const TransitCard: React.FC<TransitCardProps> = ({ transit, index = 0 }) => {
  const transitPlanetInfo = PLANET_INFO.find((p) => p.planet === transit.transitPlanet);
  const natalPlanetInfo = PLANET_INFO.find((p) => p.planet === transit.natalPlanet);

  const intensityColors: Record<string, string> = {
    mild: '#5B7B8A',
    moderate: '#C5A059',
    strong: '#C5523F',
  };

  const intensityColor = intensityColors[transit.intensity] || intensityColors.mild;

  const aspectLabels: Record<string, string> = {
    conjunction: 'Conjunction',
    opposition: 'Opposition',
    trine: 'Trine',
    square: 'Square',
    sextile: 'Sextile',
    quincunx: 'Quincunx',
  };

  return (
    <GlassPanel
      padding="1rem 1.25rem"
      borderRadius="0.75rem"
      style={{
        animation: `fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) ${index * 100}ms both`,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          gap: '1rem',
        }}
      >
        {/* Planet glyphs */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.35rem',
            fontSize: '1.5rem',
            flexShrink: 0,
          }}
        >
          <span style={{ color: transitPlanetInfo?.color || 'var(--text-accent)' }}>
            {transitPlanetInfo?.glyph || '?'}
          </span>
          <span
            style={{
              fontSize: '0.75rem',
              color: 'var(--text-tertiary)',
              fontFamily: "'Cormorant Garamond', serif",
            }}
          >
            {aspectLabels[transit.aspectType] || transit.aspectType}
          </span>
          <span style={{ color: natalPlanetInfo?.color || 'var(--text-accent)' }}>
            {natalPlanetInfo?.glyph || '?'}
          </span>
        </div>

        {/* Content */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              marginBottom: '0.25rem',
            }}
          >
            <span
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1rem',
                fontWeight: 600,
                color: 'var(--text-primary)',
              }}
            >
              {transit.transitPlanet} {aspectLabels[transit.aspectType]} {transit.natalPlanet}
            </span>
            <span
              style={{
                display: 'inline-block',
                width: '8px',
                height: '8px',
                borderRadius: '50%',
                backgroundColor: intensityColor,
                flexShrink: 0,
              }}
              title={`Intensity: ${transit.intensity}`}
            />
          </div>

          <p
            style={{
              fontSize: '0.85rem',
              lineHeight: 1.5,
              color: 'var(--text-secondary)',
              margin: 0,
            }}
          >
            {transit.description}
          </p>

          <div
            style={{
              marginTop: '0.5rem',
              fontSize: '0.75rem',
              color: 'var(--text-tertiary)',
              display: 'flex',
              gap: '1rem',
            }}
          >
            <span>Peak: {transit.peakDate}</span>
            <span
              style={{
                textTransform: 'capitalize',
                color: intensityColor,
                fontWeight: 500,
              }}
            >
              {transit.intensity}
            </span>
          </div>
        </div>
      </div>
    </GlassPanel>
  );
};

export default TransitCard;
