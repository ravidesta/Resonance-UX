import React, { type CSSProperties, type ReactNode } from 'react';
import { useTheme } from '../hooks/useTheme';

interface GlassPanelProps {
  children: ReactNode;
  className?: string;
  style?: CSSProperties;
  padding?: string;
  borderRadius?: string;
  glow?: boolean;
  onClick?: () => void;
  as?: 'div' | 'section' | 'article' | 'aside';
}

/**
 * GlassPanel - a reusable glassmorphism card component with translucent
 * backdrop-blur background, subtle border, and gold-tinted shadow.
 */
const GlassPanel: React.FC<GlassPanelProps> = ({
  children,
  className,
  style,
  padding = '1.5rem',
  borderRadius = '1rem',
  glow = false,
  onClick,
  as: Tag = 'div',
}) => {
  const { isDark } = useTheme();

  const panelStyle: CSSProperties = {
    background: isDark
      ? 'rgba(10, 28, 20, 0.6)'
      : 'rgba(250, 250, 248, 0.7)',
    backdropFilter: 'blur(12px)',
    WebkitBackdropFilter: 'blur(12px)',
    border: isDark
      ? '1px solid rgba(138, 156, 145, 0.15)'
      : '1px solid rgba(138, 156, 145, 0.25)',
    borderRadius,
    padding,
    boxShadow: glow
      ? '0 8px 24px rgba(154, 122, 58, 0.12), 0 0 20px rgba(197, 160, 89, 0.1)'
      : '0 4px 12px rgba(154, 122, 58, 0.12)',
    transition: `box-shadow 350ms cubic-bezier(0.4, 0, 0.2, 1),
                 transform 350ms cubic-bezier(0.34, 1.56, 0.64, 1),
                 border-color 350ms cubic-bezier(0.4, 0, 0.2, 1)`,
    cursor: onClick ? 'pointer' : undefined,
    ...style,
  };

  const handleMouseEnter = (e: React.MouseEvent<HTMLElement>) => {
    if (onClick) {
      (e.currentTarget as HTMLElement).style.transform = 'translateY(-2px)';
      (e.currentTarget as HTMLElement).style.boxShadow =
        '0 12px 32px rgba(154, 122, 58, 0.18), 0 0 24px rgba(197, 160, 89, 0.12)';
    }
  };

  const handleMouseLeave = (e: React.MouseEvent<HTMLElement>) => {
    if (onClick) {
      (e.currentTarget as HTMLElement).style.transform = 'translateY(0)';
      (e.currentTarget as HTMLElement).style.boxShadow = glow
        ? '0 8px 24px rgba(154, 122, 58, 0.12), 0 0 20px rgba(197, 160, 89, 0.1)'
        : '0 4px 12px rgba(154, 122, 58, 0.12)';
    }
  };

  return (
    <Tag
      className={className}
      style={panelStyle}
      onClick={onClick}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
    >
      {children}
    </Tag>
  );
};

export default GlassPanel;
