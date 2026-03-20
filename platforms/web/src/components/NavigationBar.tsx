import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useTheme } from '../hooks/useTheme';

interface NavItem {
  path: string;
  label: string;
  icon: string;
}

const NAV_ITEMS: NavItem[] = [
  { path: '/dashboard', label: 'Home', icon: '\u2302' },
  { path: '/chart', label: 'Chart', icon: '\u2609' },
  { path: '/reflection', label: 'Reflect', icon: '\u270E' },
  { path: '/meditation', label: 'Meditate', icon: '\u2727' },
  { path: '/library', label: 'Library', icon: '\u2261' },
];

/**
 * NavigationBar - bottom navigation bar for mobile, side nav for desktop.
 * Uses glassmorphism background with spring-eased active indicator.
 */
const NavigationBar: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const { isDark } = useTheme();

  return (
    <nav
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        zIndex: 20,
        background: isDark
          ? 'rgba(5, 16, 11, 0.9)'
          : 'rgba(250, 250, 248, 0.85)',
        backdropFilter: 'blur(12px)',
        WebkitBackdropFilter: 'blur(12px)',
        borderTop: isDark
          ? '1px solid rgba(138, 156, 145, 0.15)'
          : '1px solid rgba(138, 156, 145, 0.25)',
        padding: '0.5rem 0 calc(0.5rem + env(safe-area-inset-bottom))',
        display: 'flex',
        justifyContent: 'space-around',
        alignItems: 'center',
      }}
    >
      {NAV_ITEMS.map((item) => {
        const isActive = location.pathname === item.path;

        return (
          <button
            key={item.path}
            onClick={() => navigate(item.path)}
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: '0.2rem',
              padding: '0.4rem 0.75rem',
              borderRadius: '0.75rem',
              minWidth: '56px',
              background: isActive
                ? isDark
                  ? 'rgba(197, 160, 89, 0.12)'
                  : 'rgba(197, 160, 89, 0.15)'
                : 'transparent',
              transition: `background 350ms cubic-bezier(0.34, 1.56, 0.64, 1),
                           transform 200ms cubic-bezier(0.34, 1.56, 0.64, 1)`,
              transform: isActive ? 'scale(1.05)' : 'scale(1)',
            }}
            aria-label={item.label}
            aria-current={isActive ? 'page' : undefined}
          >
            <span
              style={{
                fontSize: '1.25rem',
                lineHeight: 1,
                color: isActive ? 'var(--text-accent)' : 'var(--text-tertiary)',
                transition: 'color 200ms ease',
              }}
            >
              {item.icon}
            </span>
            <span
              style={{
                fontSize: '0.65rem',
                fontWeight: isActive ? 600 : 400,
                letterSpacing: '0.05em',
                textTransform: 'uppercase',
                color: isActive ? 'var(--text-accent)' : 'var(--text-tertiary)',
                transition: 'color 200ms ease',
              }}
            >
              {item.label}
            </span>
          </button>
        );
      })}
    </nav>
  );
};

export default NavigationBar;
