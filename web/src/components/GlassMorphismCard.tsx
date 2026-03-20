/**
 * Resonance UX Component Library
 *
 * GlassMorphismCard and companion components that embody
 * calm, intentional, spacious design.
 */

import React, {
  useRef,
  useEffect,
  useState,
  useCallback,
  useMemo,
  type CSSProperties,
  type ReactNode,
} from 'react';
import { IntentionalStatusType, EnergyLevel } from '../../shared/types';

// ---------------------------------------------------------------------------
// GlassMorphismCard
// ---------------------------------------------------------------------------

export interface GlassMorphismCardProps {
  children: ReactNode;
  className?: string;
  blur?: 'sm' | 'md' | 'lg' | 'xl';
  padding?: 'none' | 'sm' | 'md' | 'lg' | 'xl';
  radius?: 'md' | 'lg' | 'xl' | '2xl' | '3xl';
  elevation?: 'none' | 'sm' | 'md' | 'lg';
  border?: boolean;
  insetHighlight?: boolean;
  parallax?: boolean;
  tapGlow?: boolean;
  hoverLift?: boolean;
  onClick?: () => void;
  style?: CSSProperties;
}

const BLUR_MAP = { sm: 8, md: 16, lg: 24, xl: 40 };
const PADDING_MAP = { none: '0', sm: '12px', md: '20px', lg: '32px', xl: '48px' };
const RADIUS_MAP = { md: '8px', lg: '12px', xl: '16px', '2xl': '24px', '3xl': '32px' };

export const GlassMorphismCard: React.FC<GlassMorphismCardProps> = ({
  children,
  className = '',
  blur = 'md',
  padding = 'md',
  radius = '2xl',
  elevation = 'md',
  border = true,
  insetHighlight = true,
  parallax = true,
  tapGlow = true,
  hoverLift = true,
  onClick,
  style,
}) => {
  const cardRef = useRef<HTMLDivElement>(null);
  const [transform, setTransform] = useState('perspective(800px) rotateX(0deg) rotateY(0deg)');
  const [glowPosition, setGlowPosition] = useState({ x: 50, y: 50 });
  const [isPressed, setIsPressed] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const isTouchDevice = useRef(false);

  useEffect(() => {
    isTouchDevice.current = window.matchMedia('(hover: none) and (pointer: coarse)').matches;
  }, []);

  const handleMouseMove = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      if (!parallax || isTouchDevice.current || !cardRef.current) return;

      const rect = cardRef.current.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width;
      const y = (e.clientY - rect.top) / rect.height;

      const rotateY = (x - 0.5) * 8;
      const rotateX = (0.5 - y) * 6;

      setTransform(`perspective(800px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`);
      setGlowPosition({ x: x * 100, y: y * 100 });
    },
    [parallax],
  );

  const handleMouseLeave = useCallback(() => {
    setTransform('perspective(800px) rotateX(0deg) rotateY(0deg)');
    setIsHovered(false);
  }, []);

  const handleMouseEnter = useCallback(() => {
    setIsHovered(true);
  }, []);

  const handleTouchStart = useCallback(() => {
    if (tapGlow) setIsPressed(true);
  }, [tapGlow]);

  const handleTouchEnd = useCallback(() => {
    setIsPressed(false);
  }, []);

  const elevationShadows: Record<string, string> = {
    none: 'none',
    sm: '0 2px 4px rgba(10,28,20,0.06)',
    md: '0 4px 12px rgba(10,28,20,0.08)',
    lg: '0 8px 24px rgba(10,28,20,0.10)',
  };

  const shadows: string[] = [];
  if (insetHighlight) shadows.push('inset 0 1px 1px rgba(255,255,255,0.15)');
  if (border) shadows.push('0 0 0 1px var(--color-glass-border, rgba(255,255,255,0.12))');
  if (elevation !== 'none') shadows.push(elevationShadows[elevation]);
  if (isPressed) shadows.push('0 0 24px rgba(197,160,89,0.3)');

  const composedStyle: CSSProperties = {
    background: 'var(--color-glass, rgba(255,255,255,0.65))',
    backdropFilter: `blur(${BLUR_MAP[blur]}px) saturate(1.3)`,
    WebkitBackdropFilter: `blur(${BLUR_MAP[blur]}px) saturate(1.3)`,
    boxShadow: shadows.join(', '),
    borderRadius: RADIUS_MAP[radius],
    padding: PADDING_MAP[padding],
    transform: hoverLift && isHovered
      ? `${transform} translateY(-2px)`
      : transform,
    transition: 'transform 0.4s cubic-bezier(0.22,1,0.36,1), box-shadow 0.4s cubic-bezier(0.22,1,0.36,1)',
    position: 'relative',
    overflow: 'hidden',
    cursor: onClick ? 'pointer' : 'default',
    willChange: 'transform',
    ...style,
  };

  return (
    <div
      ref={cardRef}
      className={`resonance-glass-card ${className}`}
      style={composedStyle}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      onMouseEnter={handleMouseEnter}
      onTouchStart={handleTouchStart}
      onTouchEnd={handleTouchEnd}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
    >
      {/* Radial glow overlay following cursor */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `radial-gradient(600px circle at ${glowPosition.x}% ${glowPosition.y}%, rgba(197,160,89,0.06), transparent 50%)`,
          pointerEvents: 'none',
          opacity: isHovered ? 1 : 0,
          transition: 'opacity 0.4s ease',
        }}
      />
      {children}
    </div>
  );
};

// ---------------------------------------------------------------------------
// IntentionalStatusBadge
// ---------------------------------------------------------------------------

export interface IntentionalStatusBadgeProps {
  status: IntentionalStatusType;
  message?: string;
  size?: 'sm' | 'md' | 'lg';
  showLabel?: boolean;
  pulse?: boolean;
  className?: string;
}

const STATUS_CONFIG: Record<IntentionalStatusType, { color: string; label: string; icon: string }> = {
  [IntentionalStatusType.Available]: { color: '#5BA37B', label: 'Available', icon: '\u25CF' },
  [IntentionalStatusType.Focused]: { color: '#C5A059', label: 'Focused', icon: '\u25C9' },
  [IntentionalStatusType.Creating]: { color: '#EBD297', label: 'Creating', icon: '\u2726' },
  [IntentionalStatusType.Resting]: { color: '#78B392', label: 'Resting', icon: '\u263E' },
  [IntentionalStatusType.Away]: { color: '#9A9A90', label: 'Away', icon: '\u25CB' },
  [IntentionalStatusType.DoNotDisturb]: { color: '#C45D5D', label: 'Do Not Disturb', icon: '\u2298' },
};

const SIZE_MAP_BADGE = { sm: 8, md: 12, lg: 16 };

export const IntentionalStatusBadge: React.FC<IntentionalStatusBadgeProps> = ({
  status,
  message,
  size = 'md',
  showLabel = false,
  pulse = true,
  className = '',
}) => {
  const config = STATUS_CONFIG[status];
  const dotSize = SIZE_MAP_BADGE[size];

  const keyframes = pulse
    ? `@keyframes resonance-pulse-${status} {
        0%, 100% { box-shadow: 0 0 0 0 ${config.color}66; }
        50% { box-shadow: 0 0 0 ${dotSize / 2}px transparent; }
      }`
    : '';

  return (
    <>
      {pulse && <style>{keyframes}</style>}
      <span
        className={`resonance-status-badge ${className}`}
        style={{ display: 'inline-flex', alignItems: 'center', gap: '8px' }}
        title={message || config.label}
      >
        <span
          style={{
            width: dotSize,
            height: dotSize,
            borderRadius: '50%',
            backgroundColor: config.color,
            display: 'inline-block',
            flexShrink: 0,
            animation: pulse
              ? `resonance-pulse-${status} 3s cubic-bezier(0.45,0.05,0.55,0.95) infinite`
              : undefined,
          }}
        />
        {showLabel && (
          <span
            style={{
              fontFamily: "var(--font-sans, 'Manrope', sans-serif)",
              fontSize: size === 'sm' ? '0.75rem' : size === 'md' ? '0.875rem' : '1rem',
              color: 'var(--color-text-muted, #5C7065)',
              fontWeight: 500,
              letterSpacing: '0.02em',
            }}
          >
            {config.label}
          </span>
        )}
        {message && showLabel && (
          <span
            style={{
              fontSize: '0.75rem',
              color: 'var(--color-text-muted, #5C7065)',
              opacity: 0.7,
            }}
          >
            &mdash; {message}
          </span>
        )}
      </span>
    </>
  );
};

// ---------------------------------------------------------------------------
// EnergyLevelIndicator
// ---------------------------------------------------------------------------

export interface EnergyLevelIndicatorProps {
  level: EnergyLevel;
  showLabel?: boolean;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

const ENERGY_CONFIG: Record<EnergyLevel, { bars: number; color: string; label: string }> = {
  [EnergyLevel.Peak]: { bars: 5, color: '#C5A059', label: 'Peak Energy' },
  [EnergyLevel.High]: { bars: 4, color: '#5BA37B', label: 'High Energy' },
  [EnergyLevel.Moderate]: { bars: 3, color: '#78B392', label: 'Moderate' },
  [EnergyLevel.Low]: { bars: 2, color: '#9FC8B1', label: 'Low Energy' },
  [EnergyLevel.Rest]: { bars: 1, color: '#C5DDD0', label: 'Rest' },
};

const BAR_HEIGHTS = { sm: [4, 7, 10, 13, 16], md: [6, 10, 14, 18, 22], lg: [8, 14, 20, 26, 32] };
const BAR_WIDTH = { sm: 3, md: 4, lg: 6 };

export const EnergyLevelIndicator: React.FC<EnergyLevelIndicatorProps> = ({
  level,
  showLabel = false,
  size = 'md',
  className = '',
}) => {
  const config = ENERGY_CONFIG[level];
  const heights = BAR_HEIGHTS[size];
  const width = BAR_WIDTH[size];
  const gap = Math.max(2, width - 1);

  return (
    <span
      className={`resonance-energy ${className}`}
      style={{ display: 'inline-flex', alignItems: 'flex-end', gap: `${gap}px` }}
      title={config.label}
      role="img"
      aria-label={`Energy level: ${config.label}`}
    >
      {heights.map((h, i) => (
        <span
          key={i}
          style={{
            width,
            height: h,
            borderRadius: width / 2,
            backgroundColor: i < config.bars ? config.color : 'var(--color-border, rgba(10,28,20,0.08))',
            transition: 'background-color 0.4s ease, height 0.3s ease',
          }}
        />
      ))}
      {showLabel && (
        <span
          style={{
            marginLeft: 8,
            fontFamily: "var(--font-sans, 'Manrope', sans-serif)",
            fontSize: size === 'sm' ? '0.7rem' : '0.8rem',
            color: 'var(--color-text-muted, #5C7065)',
            fontWeight: 500,
          }}
        >
          {config.label}
        </span>
      )}
    </span>
  );
};

// ---------------------------------------------------------------------------
// WaveformVisualizer (Canvas API)
// ---------------------------------------------------------------------------

export interface WaveformVisualizerProps {
  /** Normalized amplitudes 0-1 */
  data: number[];
  width?: number;
  height?: number;
  color?: string;
  progressColor?: string;
  progress?: number; // 0-1
  barWidth?: number;
  gap?: number;
  radius?: number;
  className?: string;
  onClick?: (progress: number) => void;
}

export const WaveformVisualizer: React.FC<WaveformVisualizerProps> = ({
  data,
  width = 280,
  height = 48,
  color = 'var(--color-border, rgba(10,28,20,0.15))',
  progressColor = 'var(--color-accent, #C5A059)',
  progress = 0,
  barWidth = 3,
  gap = 2,
  radius = 1.5,
  className = '',
  onClick,
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const resolvedColor = useRef(color);
  const resolvedProgressColor = useRef(progressColor);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // Resolve CSS variables
    const computed = getComputedStyle(canvas);
    const resolveVar = (val: string): string => {
      if (val.startsWith('var(')) {
        const match = val.match(/var\(--([^,)]+)(?:,\s*(.+))?\)/);
        if (match) {
          const resolved = computed.getPropertyValue(`--${match[1]}`).trim();
          return resolved || match[2]?.trim() || '#888';
        }
      }
      return val;
    };

    resolvedColor.current = resolveVar(color);
    resolvedProgressColor.current = resolveVar(progressColor);

    const dpr = window.devicePixelRatio || 1;
    canvas.width = width * dpr;
    canvas.height = height * dpr;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.scale(dpr, dpr);
    ctx.clearRect(0, 0, width, height);

    const totalBars = Math.floor(width / (barWidth + gap));
    const step = data.length / totalBars;
    const minHeight = 2;
    const maxHeight = height - 4;
    const centerY = height / 2;

    for (let i = 0; i < totalBars; i++) {
      const sampleIndex = Math.floor(i * step);
      const amplitude = data[Math.min(sampleIndex, data.length - 1)] ?? 0;
      const barH = Math.max(minHeight, amplitude * maxHeight);
      const x = i * (barWidth + gap);
      const barProgress = i / totalBars;

      ctx.fillStyle =
        barProgress <= progress ? resolvedProgressColor.current : resolvedColor.current;

      // Rounded rectangle for each bar
      const y = centerY - barH / 2;
      ctx.beginPath();
      ctx.roundRect(x, y, barWidth, barH, radius);
      ctx.fill();
    }
  }, [data, width, height, color, progressColor, progress, barWidth, gap, radius]);

  const handleClick = useCallback(
    (e: React.MouseEvent<HTMLCanvasElement>) => {
      if (!onClick || !canvasRef.current) return;
      const rect = canvasRef.current.getBoundingClientRect();
      const x = e.clientX - rect.left;
      onClick(x / rect.width);
    },
    [onClick],
  );

  return (
    <canvas
      ref={canvasRef}
      className={`resonance-waveform ${className}`}
      style={{
        width,
        height,
        cursor: onClick ? 'pointer' : 'default',
        display: 'block',
      }}
      onClick={handleClick}
      role="img"
      aria-label="Audio waveform"
    />
  );
};

// ---------------------------------------------------------------------------
// OrganicBlob (CSS breathe animation)
// ---------------------------------------------------------------------------

export interface OrganicBlobProps {
  size?: number;
  color?: string;
  opacity?: number;
  speed?: 'slow' | 'normal' | 'fast';
  className?: string;
}

const BLOB_SPEED = { slow: '8s', normal: '5s', fast: '3s' };

export const OrganicBlob: React.FC<OrganicBlobProps> = ({
  size = 200,
  color = '#C5A059',
  opacity = 0.15,
  speed = 'normal',
  className = '',
}) => {
  const id = useMemo(() => `blob-${Math.random().toString(36).slice(2, 8)}`, []);

  const keyframes = `
    @keyframes ${id}-morph {
      0%, 100% {
        border-radius: 42% 58% 70% 30% / 45% 45% 55% 55%;
        transform: rotate(0deg) scale(1);
      }
      25% {
        border-radius: 73% 27% 38% 62% / 55% 68% 32% 45%;
        transform: rotate(90deg) scale(1.02);
      }
      50% {
        border-radius: 28% 72% 44% 56% / 65% 35% 65% 35%;
        transform: rotate(180deg) scale(0.98);
      }
      75% {
        border-radius: 60% 40% 30% 70% / 38% 62% 38% 62%;
        transform: rotate(270deg) scale(1.01);
      }
    }
  `;

  return (
    <>
      <style>{keyframes}</style>
      <div
        className={`resonance-blob ${className}`}
        style={{
          width: size,
          height: size,
          background: color,
          opacity,
          animation: `${id}-morph ${BLOB_SPEED[speed]} cubic-bezier(0.45,0.05,0.55,0.95) infinite`,
          willChange: 'border-radius, transform',
          filter: 'blur(1px)',
          flexShrink: 0,
        }}
        aria-hidden="true"
      />
    </>
  );
};

// ---------------------------------------------------------------------------
// SpaciousnessGauge (Circular SVG)
// ---------------------------------------------------------------------------

export interface SpaciousnessGaugeProps {
  /** 0 - 100 */
  value: number;
  size?: number;
  strokeWidth?: number;
  trackColor?: string;
  fillColor?: string;
  glowColor?: string;
  label?: string;
  showValue?: boolean;
  className?: string;
}

export const SpaciousnessGauge: React.FC<SpaciousnessGaugeProps> = ({
  value,
  size = 120,
  strokeWidth = 8,
  trackColor = 'var(--color-border, rgba(10,28,20,0.08))',
  fillColor = 'var(--color-accent, #C5A059)',
  glowColor = 'rgba(197,160,89,0.25)',
  label = 'Spaciousness',
  showValue = true,
  className = '',
}) => {
  const clampedValue = Math.max(0, Math.min(100, value));
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (clampedValue / 100) * circumference;
  const center = size / 2;

  return (
    <div
      className={`resonance-spaciousness ${className}`}
      style={{ display: 'inline-flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}
      role="progressbar"
      aria-valuenow={clampedValue}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-label={`${label}: ${clampedValue}%`}
    >
      <svg
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
        style={{ transform: 'rotate(-90deg)' }}
      >
        {/* Glow filter */}
        <defs>
          <filter id="spaciousness-glow" x="-20%" y="-20%" width="140%" height="140%">
            <feGaussianBlur stdDeviation="3" result="blur" />
            <feFlood floodColor={glowColor} result="color" />
            <feComposite in="color" in2="blur" operator="in" result="glow" />
            <feMerge>
              <feMergeNode in="glow" />
              <feMergeNode in="SourceGraphic" />
            </feMerge>
          </filter>
        </defs>

        {/* Track */}
        <circle
          cx={center}
          cy={center}
          r={radius}
          fill="none"
          stroke={trackColor}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
        />

        {/* Fill */}
        <circle
          cx={center}
          cy={center}
          r={radius}
          fill="none"
          stroke={fillColor}
          strokeWidth={strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          filter="url(#spaciousness-glow)"
          style={{
            transition: 'stroke-dashoffset 0.8s cubic-bezier(0.22,1,0.36,1)',
          }}
        />
      </svg>

      {/* Center text (positioned over the SVG) */}
      {showValue && (
        <div
          style={{
            marginTop: -size + (size - 24) / 2,
            marginBottom: (size - 24) / 2,
            textAlign: 'center',
            fontFamily: "var(--font-serif, 'Cormorant Garamond', serif)",
            fontSize: size > 100 ? '1.5rem' : '1.1rem',
            fontWeight: 300,
            color: 'var(--color-text, #0A1C14)',
            lineHeight: 1,
          }}
        >
          {clampedValue}
          <span style={{ fontSize: '0.6em', opacity: 0.6 }}>%</span>
        </div>
      )}

      <span
        style={{
          fontFamily: "var(--font-sans, 'Manrope', sans-serif)",
          fontSize: '0.7rem',
          fontWeight: 600,
          letterSpacing: '0.08em',
          textTransform: 'uppercase',
          color: 'var(--color-text-muted, #5C7065)',
        }}
      >
        {label}
      </span>
    </div>
  );
};

// ---------------------------------------------------------------------------
// Exports
// ---------------------------------------------------------------------------

export default {
  GlassMorphismCard,
  IntentionalStatusBadge,
  EnergyLevelIndicator,
  WaveformVisualizer,
  OrganicBlob,
  SpaciousnessGauge,
};
