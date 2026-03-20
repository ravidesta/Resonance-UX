import React from 'react';
import { useTheme } from '../hooks/useTheme';

/**
 * CosmicBackground - animated organic blob background with paper noise overlay.
 * Renders behind all page content with breathing animation blobs and an SVG
 * feTurbulence noise texture.
 */
const CosmicBackground: React.FC = () => {
  const { isDark } = useTheme();

  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: -1,
        overflow: 'hidden',
        pointerEvents: 'none',
      }}
      aria-hidden="true"
    >
      {/* Organic blob 1 - top-right */}
      <div
        style={{
          position: 'absolute',
          top: '-15%',
          right: '-10%',
          width: '60vw',
          height: '60vw',
          maxWidth: '600px',
          maxHeight: '600px',
          borderRadius: '40% 60% 55% 45% / 50% 40% 60% 50%',
          background: isDark
            ? 'radial-gradient(ellipse, rgba(27, 64, 46, 0.5), rgba(10, 28, 20, 0) 70%)'
            : 'radial-gradient(ellipse, rgba(197, 160, 89, 0.15), rgba(250, 250, 248, 0) 70%)',
          filter: 'blur(60px)',
          animation: 'breathe 8s ease-in-out infinite',
        }}
      />

      {/* Organic blob 2 - bottom-left */}
      <div
        style={{
          position: 'absolute',
          bottom: '-20%',
          left: '-15%',
          width: '70vw',
          height: '70vw',
          maxWidth: '700px',
          maxHeight: '700px',
          borderRadius: '55% 45% 40% 60% / 45% 55% 45% 55%',
          background: isDark
            ? 'radial-gradient(ellipse, rgba(18, 46, 33, 0.6), rgba(5, 16, 11, 0) 70%)'
            : 'radial-gradient(ellipse, rgba(154, 122, 58, 0.1), rgba(250, 250, 248, 0) 70%)',
          filter: 'blur(60px)',
          animation: 'breathe-alt 10s ease-in-out infinite',
        }}
      />

      {/* Organic blob 3 - center accent */}
      <div
        style={{
          position: 'absolute',
          top: '30%',
          left: '40%',
          width: '40vw',
          height: '40vw',
          maxWidth: '400px',
          maxHeight: '400px',
          borderRadius: '50% 50% 45% 55% / 55% 45% 55% 45%',
          background: isDark
            ? 'radial-gradient(ellipse, rgba(197, 160, 89, 0.08), transparent 70%)'
            : 'radial-gradient(ellipse, rgba(27, 64, 46, 0.06), transparent 70%)',
          filter: 'blur(60px)',
          animation: 'breathe 12s ease-in-out infinite 2s',
        }}
      />

      {/* Paper noise texture overlay via SVG filter */}
      <svg
        style={{
          position: 'absolute',
          inset: 0,
          width: '100%',
          height: '100%',
          opacity: isDark ? 0.03 : 0.04,
          mixBlendMode: 'multiply',
        }}
      >
        <defs>
          <filter id="paperNoise">
            <feTurbulence
              type="fractalNoise"
              baseFrequency="0.65"
              numOctaves="4"
              stitchTiles="stitch"
              seed="2"
            />
            <feColorMatrix type="saturate" values="0" />
          </filter>
        </defs>
        <rect width="100%" height="100%" filter="url(#paperNoise)" />
      </svg>
    </div>
  );
};

export default CosmicBackground;
