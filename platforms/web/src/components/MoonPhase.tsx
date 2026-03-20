import React from 'react';
import type { MoonPhaseData } from '../types/astrology';
import { useTheme } from '../hooks/useTheme';

interface MoonPhaseProps {
  phase: MoonPhaseData;
  size?: number;
}

/**
 * MoonPhase - renders an SVG moon at the given phase, with illumination
 * displayed as a crescent/full/new shape using ellipse clipping.
 */
const MoonPhase: React.FC<MoonPhaseProps> = ({ phase, size = 80 }) => {
  const { isDark } = useTheme();
  const r = size / 2 - 4;
  const cx = size / 2;
  const cy = size / 2;

  // Calculate the crescent shape based on illumination
  // illumination: 0 = new, 50 = quarter, 100 = full
  const pct = phase.illumination / 100;
  // Determine which side is lit and the curvature of the terminator
  const isWaxing = phase.name.includes('Waxing') || phase.name === 'First Quarter' || phase.name === 'Full Moon';

  // terminator x-radius: ranges from r (new/full) to 0 (quarter)
  // For new: pct=0, we want all dark
  // For full: pct=1, we want all lit
  // For quarters: pct=0.5, terminator is at center
  const terminatorRx = Math.abs(2 * pct - 1) * r;
  const terminatorDirection = pct > 0.5 ? 1 : -1;

  const litColor = isDark ? '#E6D0A1' : '#C5A059';
  const darkColor = isDark ? 'rgba(10, 28, 20, 0.8)' : 'rgba(138, 156, 145, 0.3)';
  const glowColor = isDark ? 'rgba(230, 208, 161, 0.3)' : 'rgba(197, 160, 89, 0.2)';

  return (
    <div style={{ textAlign: 'center' }}>
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        style={{
          filter: `drop-shadow(0 0 ${size / 6}px ${glowColor})`,
        }}
      >
        <defs>
          <radialGradient id={`moonGrad-${size}`} cx="40%" cy="40%">
            <stop offset="0%" stopColor={litColor} stopOpacity="1" />
            <stop offset="100%" stopColor={isDark ? '#9A7A3A' : '#B8924A'} stopOpacity="0.9" />
          </radialGradient>
          <clipPath id={`moonClip-${size}`}>
            <circle cx={cx} cy={cy} r={r} />
          </clipPath>
        </defs>

        {/* Moon base (dark side) */}
        <circle cx={cx} cy={cy} r={r} fill={darkColor} />

        {/* Lit portion */}
        <g clipPath={`url(#moonClip-${size})`}>
          {pct >= 0.99 ? (
            // Full moon
            <circle cx={cx} cy={cy} r={r} fill={`url(#moonGrad-${size})`} />
          ) : pct <= 0.01 ? (
            // New moon - nothing lit, just the subtle outline
            <></>
          ) : (
            // Crescent/gibbous path
            <path
              d={
                isWaxing
                  ? `M ${cx} ${cy - r} A ${r} ${r} 0 0 1 ${cx} ${cy + r} A ${terminatorRx} ${r} 0 0 ${terminatorDirection > 0 ? 0 : 1} ${cx} ${cy - r} Z`
                  : `M ${cx} ${cy - r} A ${r} ${r} 0 0 0 ${cx} ${cy + r} A ${terminatorRx} ${r} 0 0 ${terminatorDirection > 0 ? 1 : 0} ${cx} ${cy - r} Z`
              }
              fill={`url(#moonGrad-${size})`}
            />
          )}
        </g>

        {/* Subtle rim highlight */}
        <circle
          cx={cx}
          cy={cy}
          r={r}
          fill="none"
          stroke={isDark ? 'rgba(230, 208, 161, 0.2)' : 'rgba(197, 160, 89, 0.3)'}
          strokeWidth="1"
        />
      </svg>

      <div
        style={{
          marginTop: '0.5rem',
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: '0.875rem',
          color: 'var(--text-accent)',
          letterSpacing: '0.05em',
        }}
      >
        {phase.name}
      </div>
      <div
        style={{
          fontSize: '0.75rem',
          color: 'var(--text-tertiary)',
          marginTop: '0.125rem',
        }}
      >
        {Math.round(phase.illumination)}% illuminated
      </div>
    </div>
  );
};

export default MoonPhase;
