import React, { useMemo, useState } from 'react';
import type { NatalChart, Planet, AspectType } from '../types/astrology';
import { ZODIAC_SIGNS, PLANET_INFO, ASPECT_INFO } from '../types/astrology';
import { useTheme } from '../hooks/useTheme';

interface ZodiacWheelProps {
  chart: NatalChart;
  size?: number;
  interactive?: boolean;
}

/**
 * ZodiacWheel - SVG-based interactive natal chart wheel.
 * Renders 12 zodiac sign segments with colored fills and glyphs,
 * 12 house lines radiating from the center, planet symbols at their
 * ecliptic positions, and aspect lines connecting planets.
 */
const ZodiacWheel: React.FC<ZodiacWheelProps> = ({
  chart,
  size = 500,
  interactive = true,
}) => {
  const { isDark } = useTheme();
  const [hoveredPlanet, setHoveredPlanet] = useState<Planet | null>(null);
  const [selectedPlanet, setSelectedPlanet] = useState<Planet | null>(null);

  const center = size / 2;
  const outerR = size / 2 - 8;
  const signRingOuter = outerR;
  const signRingInner = outerR * 0.78;
  const houseRingInner = outerR * 0.35;
  const planetRing = outerR * 0.62;
  const aspectRing = outerR * 0.32;
  const glyphRing = (signRingOuter + signRingInner) / 2;

  // Ascendant offset: the Ascendant degree should point to the left (9 o'clock / 180 deg in SVG)
  const ascendantDeg = chart.positions.find((p) => p.planet === 'Ascendant')?.longitude ?? 0;
  const rotationOffset = 180 - ascendantDeg;

  /**
   * Convert ecliptic longitude to SVG angle (in degrees).
   * In SVG: 0 deg = 3 o'clock, going clockwise.
   * We place Ascendant at 9 o'clock (180 SVG degrees).
   * Zodiac goes counter-clockwise in traditional charts.
   */
  const toSvgAngle = (eclipticDeg: number): number => {
    return -(eclipticDeg + rotationOffset);
  };

  /** Polar to Cartesian */
  const polarToXY = (angleDeg: number, radius: number) => {
    const rad = (angleDeg * Math.PI) / 180;
    return {
      x: center + radius * Math.cos(rad),
      y: center + radius * Math.sin(rad),
    };
  };

  /** Build an SVG arc path for a zodiac segment */
  const arcPath = (
    startDeg: number,
    endDeg: number,
    innerRadius: number,
    outerRadius: number,
  ): string => {
    const s1 = polarToXY(startDeg, outerRadius);
    const e1 = polarToXY(endDeg, outerRadius);
    const s2 = polarToXY(endDeg, innerRadius);
    const e2 = polarToXY(startDeg, innerRadius);
    const largeArc = Math.abs(endDeg - startDeg) > 180 ? 1 : 0;
    return [
      `M ${s1.x} ${s1.y}`,
      `A ${outerRadius} ${outerRadius} 0 ${largeArc} 1 ${e1.x} ${e1.y}`,
      `L ${s2.x} ${s2.y}`,
      `A ${innerRadius} ${innerRadius} 0 ${largeArc} 0 ${e2.x} ${e2.y}`,
      'Z',
    ].join(' ');
  };

  // Filter planets for rendering (exclude Ascendant/MC from the planet ring)
  const displayPlanets = chart.positions.filter(
    (p) => p.planet !== 'Ascendant' && p.planet !== 'Midheaven'
  );

  // Resolve planet collisions: nudge close planets apart
  const planetPositions = useMemo(() => {
    const sorted = [...displayPlanets].sort((a, b) => a.longitude - b.longitude);
    const minSeparation = 8; // degrees in SVG space
    const positions = sorted.map((p) => ({
      ...p,
      displayAngle: toSvgAngle(p.longitude),
    }));

    // Simple collision resolution: push overlapping planets apart
    for (let pass = 0; pass < 3; pass++) {
      for (let i = 0; i < positions.length; i++) {
        for (let j = i + 1; j < positions.length; j++) {
          let diff = positions[j].displayAngle - positions[i].displayAngle;
          if (Math.abs(diff) < minSeparation) {
            const push = (minSeparation - Math.abs(diff)) / 2;
            positions[i].displayAngle -= push;
            positions[j].displayAngle += push;
          }
        }
      }
    }

    return positions;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [chart]);

  // Color palette
  const bgColor = isDark ? '#05100B' : '#FAFAF8';
  const lineColor = isDark ? 'rgba(138, 156, 145, 0.2)' : 'rgba(138, 156, 145, 0.3)';
  const textColor = isDark ? '#FAFAF8' : '#0A1C14';

  // Relevant aspects for hovered/selected planet
  const highlightedAspects = useMemo(() => {
    const target = selectedPlanet || hoveredPlanet;
    if (!target) return chart.aspects;
    return chart.aspects.filter(
      (a) => a.planet1 === target || a.planet2 === target
    );
  }, [chart.aspects, hoveredPlanet, selectedPlanet]);

  return (
    <svg
      viewBox={`0 0 ${size} ${size}`}
      width="100%"
      height="100%"
      style={{
        maxWidth: size,
        maxHeight: size,
        display: 'block',
        margin: '0 auto',
      }}
      role="img"
      aria-label="Natal chart zodiac wheel"
    >
      <defs>
        {/* Gold radial gradient for center */}
        <radialGradient id="centerGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stopColor={isDark ? 'rgba(197, 160, 89, 0.15)' : 'rgba(197, 160, 89, 0.1)'} />
          <stop offset="100%" stopColor="transparent" />
        </radialGradient>

        {/* Sign segment gradients */}
        {ZODIAC_SIGNS.map((sign, i) => {
          const baseColor = sign.color;
          return (
            <linearGradient
              key={`signGrad-${i}`}
              id={`signGrad-${i}`}
              x1="0%" y1="0%" x2="100%" y2="100%"
            >
              <stop
                offset="0%"
                stopColor={baseColor}
                stopOpacity={isDark ? '0.25' : '0.18'}
              />
              <stop
                offset="100%"
                stopColor={baseColor}
                stopOpacity={isDark ? '0.1' : '0.06'}
              />
            </linearGradient>
          );
        })}

        {/* Drop shadow for planets */}
        <filter id="planetShadow" x="-30%" y="-30%" width="160%" height="160%">
          <feDropShadow dx="0" dy="0" stdDeviation="2" floodColor="rgba(197, 160, 89, 0.4)" />
        </filter>
      </defs>

      {/* Background circle */}
      <circle cx={center} cy={center} r={outerR + 4} fill={bgColor} />

      {/* Center glow */}
      <circle cx={center} cy={center} r={houseRingInner * 1.5} fill="url(#centerGlow)" />

      {/* Zodiac sign segments */}
      {ZODIAC_SIGNS.map((sign, i) => {
        const startAngle = toSvgAngle(sign.startDegree + 30);
        const endAngle = toSvgAngle(sign.startDegree);
        const glyphAngle = toSvgAngle(sign.startDegree + 15);
        const glyphPos = polarToXY(glyphAngle, glyphRing);

        return (
          <g key={sign.sign}>
            {/* Segment fill */}
            <path
              d={arcPath(startAngle, endAngle, signRingInner, signRingOuter)}
              fill={`url(#signGrad-${i})`}
              stroke={lineColor}
              strokeWidth="0.5"
            />
            {/* Sign glyph */}
            <text
              x={glyphPos.x}
              y={glyphPos.y}
              textAnchor="middle"
              dominantBaseline="central"
              style={{
                fontSize: size * 0.038,
                fill: sign.color,
                fontWeight: 500,
                opacity: 0.9,
              }}
            >
              {sign.glyph}
            </text>
          </g>
        );
      })}

      {/* Inner ring border */}
      <circle
        cx={center}
        cy={center}
        r={signRingInner}
        fill="none"
        stroke={lineColor}
        strokeWidth="1"
      />

      {/* Outer ring border */}
      <circle
        cx={center}
        cy={center}
        r={signRingOuter}
        fill="none"
        stroke={lineColor}
        strokeWidth="1.5"
      />

      {/* House lines */}
      {chart.houses.map((house) => {
        const angle = toSvgAngle(house.longitude);
        const inner = polarToXY(angle, houseRingInner);
        const outer = polarToXY(angle, signRingInner);

        // House number label
        const midAngle = toSvgAngle(house.longitude + 15);
        const labelPos = polarToXY(midAngle, houseRingInner + (signRingInner - houseRingInner) * 0.2);

        return (
          <g key={`house-${house.house}`}>
            <line
              x1={inner.x}
              y1={inner.y}
              x2={outer.x}
              y2={outer.y}
              stroke={house.house === 1 || house.house === 10 ? 'var(--gold-600, #C5A059)' : lineColor}
              strokeWidth={house.house === 1 || house.house === 4 || house.house === 7 || house.house === 10 ? 1.5 : 0.75}
              opacity={0.7}
            />
            <text
              x={labelPos.x}
              y={labelPos.y}
              textAnchor="middle"
              dominantBaseline="central"
              style={{
                fontSize: size * 0.022,
                fill: isDark ? 'rgba(168, 184, 173, 0.5)' : 'rgba(92, 112, 101, 0.5)',
                fontFamily: "'Manrope', sans-serif",
                fontWeight: 500,
              }}
            >
              {house.house}
            </text>
          </g>
        );
      })}

      {/* Aspect lines */}
      {(selectedPlanet || hoveredPlanet ? highlightedAspects : chart.aspects).map(
        (aspect, i) => {
          const p1Pos = displayPlanets.find((p) => p.planet === aspect.planet1);
          const p2Pos = displayPlanets.find((p) => p.planet === aspect.planet2);
          if (!p1Pos || !p2Pos) return null;

          const angle1 = toSvgAngle(p1Pos.longitude);
          const angle2 = toSvgAngle(p2Pos.longitude);
          const pos1 = polarToXY(angle1, aspectRing);
          const pos2 = polarToXY(angle2, aspectRing);

          const aspectDef = ASPECT_INFO.find((a) => a.type === aspect.type);
          const isHighlighted =
            selectedPlanet === aspect.planet1 ||
            selectedPlanet === aspect.planet2 ||
            hoveredPlanet === aspect.planet1 ||
            hoveredPlanet === aspect.planet2;

          return (
            <line
              key={`aspect-${i}`}
              x1={pos1.x}
              y1={pos1.y}
              x2={pos2.x}
              y2={pos2.y}
              stroke={aspectDef?.color || lineColor}
              strokeWidth={isHighlighted ? 1.5 : 0.75}
              strokeDasharray={aspectDef?.dashArray || ''}
              opacity={
                (selectedPlanet || hoveredPlanet)
                  ? isHighlighted
                    ? 0.8
                    : 0.1
                  : 0.35
              }
              style={{
                transition: 'opacity 200ms ease, stroke-width 200ms ease',
              }}
            />
          );
        }
      )}

      {/* Planet symbols */}
      {planetPositions.map((pos) => {
        const info = PLANET_INFO.find((p) => p.planet === pos.planet);
        if (!info) return null;

        const svgAngle = pos.displayAngle;
        const point = polarToXY(svgAngle, planetRing);

        const isActive =
          hoveredPlanet === pos.planet || selectedPlanet === pos.planet;

        // Tick mark from inner ring to planet
        const tickAngle = toSvgAngle(pos.longitude);
        const tickInner = polarToXY(tickAngle, signRingInner);
        const tickOuter = polarToXY(tickAngle, signRingInner - 8);

        return (
          <g key={pos.planet}>
            {/* Tick mark on inner ring */}
            <line
              x1={tickInner.x}
              y1={tickInner.y}
              x2={tickOuter.x}
              y2={tickOuter.y}
              stroke={info.color}
              strokeWidth="1"
              opacity="0.5"
            />

            {/* Planet circle background */}
            <circle
              cx={point.x}
              cy={point.y}
              r={isActive ? size * 0.032 : size * 0.026}
              fill={isDark ? 'rgba(5, 16, 11, 0.9)' : 'rgba(250, 250, 248, 0.9)'}
              stroke={info.color}
              strokeWidth={isActive ? 2 : 1}
              filter={isActive ? 'url(#planetShadow)' : undefined}
              style={{
                transition: 'r 200ms cubic-bezier(0.34, 1.56, 0.64, 1), stroke-width 200ms ease',
                cursor: interactive ? 'pointer' : 'default',
              }}
              onMouseEnter={() => interactive && setHoveredPlanet(pos.planet)}
              onMouseLeave={() => interactive && setHoveredPlanet(null)}
              onClick={() =>
                interactive &&
                setSelectedPlanet(
                  selectedPlanet === pos.planet ? null : pos.planet
                )
              }
            />

            {/* Planet glyph */}
            <text
              x={point.x}
              y={point.y}
              textAnchor="middle"
              dominantBaseline="central"
              style={{
                fontSize: isActive ? size * 0.032 : size * 0.026,
                fill: info.color,
                fontWeight: 600,
                pointerEvents: 'none',
                transition: 'font-size 200ms ease',
              }}
            >
              {info.glyph}
            </text>

            {/* Retrograde indicator */}
            {pos.retrograde && (
              <text
                x={point.x + size * 0.028}
                y={point.y - size * 0.02}
                textAnchor="middle"
                dominantBaseline="central"
                style={{
                  fontSize: size * 0.016,
                  fill: '#C5523F',
                  fontWeight: 700,
                  pointerEvents: 'none',
                  fontFamily: "'Manrope', sans-serif",
                }}
              >
                R
              </text>
            )}
          </g>
        );
      })}

      {/* Ascendant marker arrow */}
      {(() => {
        const acAngle = toSvgAngle(ascendantDeg);
        const tip = polarToXY(acAngle, signRingOuter + 6);
        const base1 = polarToXY(acAngle + 3, signRingOuter - 4);
        const base2 = polarToXY(acAngle - 3, signRingOuter - 4);
        return (
          <polygon
            points={`${tip.x},${tip.y} ${base1.x},${base1.y} ${base2.x},${base2.y}`}
            fill={isDark ? '#E6D0A1' : '#C5A059'}
            opacity={0.9}
          />
        );
      })()}

      {/* Selected planet info tooltip */}
      {selectedPlanet && (() => {
        const pos = chart.positions.find((p) => p.planet === selectedPlanet);
        const info = PLANET_INFO.find((p) => p.planet === selectedPlanet);
        if (!pos || !info) return null;

        return (
          <g>
            <rect
              x={center - 75}
              y={center - 28}
              width={150}
              height={56}
              rx={8}
              fill={isDark ? 'rgba(10, 28, 20, 0.9)' : 'rgba(250, 250, 248, 0.95)'}
              stroke={info.color}
              strokeWidth="1"
            />
            <text
              x={center}
              y={center - 10}
              textAnchor="middle"
              style={{
                fontSize: size * 0.028,
                fill: info.color,
                fontFamily: "'Cormorant Garamond', serif",
                fontWeight: 600,
              }}
            >
              {info.glyph} {pos.planet}
            </text>
            <text
              x={center}
              y={center + 10}
              textAnchor="middle"
              style={{
                fontSize: size * 0.022,
                fill: textColor,
                fontFamily: "'Manrope', sans-serif",
              }}
            >
              {pos.signDegree.toFixed(1)}&deg; {pos.sign} (House {pos.house})
            </text>
          </g>
        );
      })()}
    </svg>
  );
};

export default ZodiacWheel;
