import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Menu,
  X,
  Sun,
  Moon,
  ArrowLeft,
  ShoppingBag,
  Bell,
  User,
  ChevronDown,
} from 'lucide-react';

const NAV_LINKS = [
  { path: '/', label: 'Home' },
  { path: '/assess', label: 'Assessment' },
  { path: '/book', label: 'Book' },
  { path: '/coach', label: 'Coaching' },
  { path: '/profile', label: 'My Profile' },
];

const DIMENSION_COLORS = [
  '#4FC3F7', '#FFB74D', '#66BB6A', '#AB47BC',
  '#EF5350', '#26A69A', '#5C6BC0',
];

const Navigation = ({ darkMode, setDarkMode, cartCount = 0, notifications = [] }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);

  const isSubPage = location.pathname !== '/' && location.pathname.split('/').filter(Boolean).length > 1;
  const currentPath = location.pathname;

  const handleScroll = useCallback(() => {
    setScrolled(window.scrollY > 20);
  }, []);

  useEffect(() => {
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  useEffect(() => {
    setMobileOpen(false);
    setNotifOpen(false);
  }, [location.pathname]);

  useEffect(() => {
    if (mobileOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [mobileOpen]);

  const isActive = (path) => {
    if (path === '/') return currentPath === '/';
    return currentPath.startsWith(path);
  };

  const styles = {
    nav: {
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      zIndex: 1000,
      height: 'var(--nav-height)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 clamp(1rem, 3vw, 2rem)',
      transition: 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)',
      background: scrolled
        ? 'var(--glass-bg)'
        : 'transparent',
      backdropFilter: scrolled ? 'blur(var(--glass-blur))' : 'none',
      WebkitBackdropFilter: scrolled ? 'blur(var(--glass-blur))' : 'none',
      borderBottom: scrolled
        ? '1px solid var(--glass-border)'
        : '1px solid transparent',
      boxShadow: scrolled ? 'var(--shadow-sm)' : 'none',
    },
    logoContainer: {
      display: 'flex',
      alignItems: 'center',
      gap: '0.75rem',
      cursor: 'pointer',
      userSelect: 'none',
    },
    monogram: {
      width: 40,
      height: 40,
      borderRadius: '12px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: `linear-gradient(135deg, ${DIMENSION_COLORS.join(', ')})`,
      backgroundSize: '300% 300%',
      animation: 'gradientShift 8s ease infinite',
      fontFamily: "'Cormorant Garamond', serif",
      fontWeight: 700,
      fontSize: '1.125rem',
      color: '#FFFFFF',
      letterSpacing: '-0.02em',
      flexShrink: 0,
    },
    logoText: {
      fontFamily: "'Cormorant Garamond', serif",
      fontWeight: 600,
      fontSize: '1.2rem',
      color: 'var(--color-text)',
      letterSpacing: '-0.01em',
      whiteSpace: 'nowrap',
    },
    desktopNav: {
      display: 'flex',
      alignItems: 'center',
      gap: '0.25rem',
    },
    navLink: (active) => ({
      fontFamily: "'Manrope', sans-serif",
      fontSize: '0.875rem',
      fontWeight: active ? 600 : 500,
      color: active ? 'var(--color-accent)' : 'var(--color-text-secondary)',
      padding: '0.5rem 0.875rem',
      borderRadius: 'var(--radius-full)',
      transition: 'all 0.25s ease',
      cursor: 'pointer',
      position: 'relative',
      background: active ? 'rgba(197, 160, 89, 0.08)' : 'transparent',
      border: 'none',
      letterSpacing: '0.01em',
    }),
    activeIndicator: {
      position: 'absolute',
      bottom: '2px',
      left: '50%',
      transform: 'translateX(-50%)',
      width: '4px',
      height: '4px',
      borderRadius: '50%',
      background: 'var(--color-accent)',
    },
    rightGroup: {
      display: 'flex',
      alignItems: 'center',
      gap: '0.5rem',
    },
    iconBtn: {
      width: 40,
      height: 40,
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      transition: 'all 0.25s ease',
      background: 'transparent',
      border: 'none',
      color: 'var(--color-text-secondary)',
      position: 'relative',
    },
    badge: {
      position: 'absolute',
      top: '4px',
      right: '4px',
      width: '16px',
      height: '16px',
      borderRadius: '50%',
      background: 'var(--color-error)',
      color: '#FFFFFF',
      fontSize: '0.625rem',
      fontWeight: 700,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: "'Manrope', sans-serif",
    },
    signInBtn: {
      fontFamily: "'Manrope', sans-serif",
      fontSize: '0.875rem',
      fontWeight: 600,
      color: 'var(--color-text)',
      padding: '0.5rem 1.25rem',
      borderRadius: 'var(--radius-full)',
      border: '1.5px solid var(--color-border)',
      background: 'transparent',
      cursor: 'pointer',
      transition: 'all 0.25s ease',
      whiteSpace: 'nowrap',
    },
    signUpBtn: {
      fontFamily: "'Manrope', sans-serif",
      fontSize: '0.875rem',
      fontWeight: 600,
      color: '#FFFFFF',
      padding: '0.5rem 1.25rem',
      borderRadius: 'var(--radius-full)',
      border: 'none',
      background: 'linear-gradient(135deg, var(--color-gold-dark), var(--color-gold))',
      cursor: 'pointer',
      transition: 'all 0.25s ease',
      boxShadow: '0 2px 8px rgba(197, 160, 89, 0.3)',
      whiteSpace: 'nowrap',
    },
    hamburger: {
      width: 40,
      height: 40,
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      background: 'transparent',
      border: 'none',
      color: 'var(--color-text)',
      zIndex: 1002,
    },
    overlay: {
      position: 'fixed',
      inset: 0,
      zIndex: 999,
      background: 'var(--color-background)',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: '0.5rem',
    },
    mobileLink: (active) => ({
      fontFamily: "'Cormorant Garamond', serif",
      fontSize: '2.5rem',
      fontWeight: active ? 700 : 400,
      color: active ? 'var(--color-accent)' : 'var(--color-text)',
      cursor: 'pointer',
      padding: '0.5rem 2rem',
      transition: 'all 0.25s ease',
      border: 'none',
      background: 'transparent',
      textAlign: 'center',
    }),
    mobileFooter: {
      position: 'absolute',
      bottom: '2rem',
      display: 'flex',
      gap: '1rem',
      alignItems: 'center',
    },
    notifDropdown: {
      position: 'absolute',
      top: '100%',
      right: 0,
      marginTop: '0.5rem',
      width: '320px',
      maxHeight: '400px',
      overflowY: 'auto',
      background: 'var(--color-surface)',
      borderRadius: 'var(--radius-lg)',
      border: '1px solid var(--color-border)',
      boxShadow: 'var(--shadow-lg)',
      padding: '0.5rem',
      zIndex: 1001,
    },
    notifItem: {
      padding: '0.75rem 1rem',
      borderRadius: 'var(--radius-md)',
      cursor: 'pointer',
      transition: 'background 0.2s ease',
      fontFamily: "'Manrope', sans-serif",
      fontSize: '0.875rem',
      color: 'var(--color-text)',
      lineHeight: 1.5,
    },
    notifEmpty: {
      padding: '2rem 1rem',
      textAlign: 'center',
      fontFamily: "'Manrope', sans-serif",
      fontSize: '0.875rem',
      color: 'var(--color-text-muted)',
    },
    backBtn: {
      width: 36,
      height: 36,
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      cursor: 'pointer',
      background: 'var(--color-surface)',
      border: '1px solid var(--color-border)',
      color: 'var(--color-text)',
      transition: 'all 0.25s ease',
      marginRight: '0.5rem',
      flexShrink: 0,
    },
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  return (
    <>
      <nav style={styles.nav} className="no-print">
        {/* Left: Logo + Back */}
        <div style={styles.logoContainer} onClick={() => navigate('/')}>
          {isSubPage && (
            <motion.button
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              style={styles.backBtn}
              onClick={(e) => {
                e.stopPropagation();
                navigate(-1);
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.borderColor = 'var(--color-accent)';
                e.currentTarget.style.color = 'var(--color-accent)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.borderColor = 'var(--color-border)';
                e.currentTarget.style.color = 'var(--color-text)';
              }}
              aria-label="Go back"
            >
              <ArrowLeft size={16} />
            </motion.button>
          )}
          <div style={styles.monogram}>LCS</div>
          <span style={styles.logoText} className="u-hide-mobile">
            Luminous Cognitive Styles
          </span>
        </div>

        {/* Center: Nav Links (Desktop) */}
        <div style={styles.desktopNav} className="u-hide-mobile">
          {NAV_LINKS.map((link) => {
            const active = isActive(link.path);
            return (
              <button
                key={link.path}
                style={styles.navLink(active)}
                onClick={() => navigate(link.path)}
                onMouseEnter={(e) => {
                  if (!active) {
                    e.currentTarget.style.color = 'var(--color-text)';
                    e.currentTarget.style.background = 'var(--color-surface-hover)';
                  }
                }}
                onMouseLeave={(e) => {
                  if (!active) {
                    e.currentTarget.style.color = 'var(--color-text-secondary)';
                    e.currentTarget.style.background = 'transparent';
                  }
                }}
              >
                {link.label}
                {active && <span style={styles.activeIndicator} />}
              </button>
            );
          })}
        </div>

        {/* Right: Actions */}
        <div style={styles.rightGroup}>
          {/* Dark Mode Toggle */}
          <motion.button
            whileTap={{ scale: 0.9, rotate: 180 }}
            transition={{ duration: 0.3 }}
            style={styles.iconBtn}
            onClick={() => setDarkMode(!darkMode)}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'var(--color-surface-hover)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'transparent';
            }}
            aria-label={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
          >
            <AnimatePresence mode="wait">
              {darkMode ? (
                <motion.div
                  key="sun"
                  initial={{ opacity: 0, rotate: -90 }}
                  animate={{ opacity: 1, rotate: 0 }}
                  exit={{ opacity: 0, rotate: 90 }}
                  transition={{ duration: 0.2 }}
                >
                  <Sun size={18} />
                </motion.div>
              ) : (
                <motion.div
                  key="moon"
                  initial={{ opacity: 0, rotate: 90 }}
                  animate={{ opacity: 1, rotate: 0 }}
                  exit={{ opacity: 0, rotate: -90 }}
                  transition={{ duration: 0.2 }}
                >
                  <Moon size={18} />
                </motion.div>
              )}
            </AnimatePresence>
          </motion.button>

          {/* Notifications (Desktop) */}
          <div style={{ position: 'relative' }} className="u-hide-mobile">
            <button
              style={styles.iconBtn}
              onClick={() => setNotifOpen(!notifOpen)}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = 'var(--color-surface-hover)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = 'transparent';
              }}
              aria-label="Notifications"
            >
              <Bell size={18} />
              {unreadCount > 0 && (
                <span style={styles.badge}>{unreadCount > 9 ? '9+' : unreadCount}</span>
              )}
            </button>
            <AnimatePresence>
              {notifOpen && (
                <motion.div
                  initial={{ opacity: 0, y: -8, scale: 0.96 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0, y: -8, scale: 0.96 }}
                  transition={{ duration: 0.2 }}
                  style={styles.notifDropdown}
                >
                  {notifications.length === 0 ? (
                    <div style={styles.notifEmpty}>
                      No notifications yet
                    </div>
                  ) : (
                    notifications.map((notif, i) => (
                      <div
                        key={i}
                        style={{
                          ...styles.notifItem,
                          background: notif.read ? 'transparent' : 'rgba(197, 160, 89, 0.06)',
                          borderLeft: notif.read ? 'none' : '3px solid var(--color-accent)',
                        }}
                        onMouseEnter={(e) => {
                          e.currentTarget.style.background = 'var(--color-surface-hover)';
                        }}
                        onMouseLeave={(e) => {
                          e.currentTarget.style.background = notif.read
                            ? 'transparent'
                            : 'rgba(197, 160, 89, 0.06)';
                        }}
                      >
                        <div style={{ fontWeight: notif.read ? 400 : 600, marginBottom: '0.25rem' }}>
                          {notif.title}
                        </div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--color-text-muted)' }}>
                          {notif.message}
                        </div>
                      </div>
                    ))
                  )}
                </motion.div>
              )}
            </AnimatePresence>
          </div>

          {/* Cart (Desktop) */}
          <button
            style={styles.iconBtn}
            className="u-hide-mobile"
            onClick={() => navigate('/book')}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'var(--color-surface-hover)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'transparent';
            }}
            aria-label="Cart"
          >
            <ShoppingBag size={18} />
            {cartCount > 0 && (
              <span style={styles.badge}>{cartCount}</span>
            )}
          </button>

          {/* Auth Buttons (Desktop) */}
          <button
            style={styles.signInBtn}
            className="u-hide-mobile"
            onClick={() => navigate('/profile')}
            onMouseEnter={(e) => {
              e.currentTarget.style.borderColor = 'var(--color-accent)';
              e.currentTarget.style.color = 'var(--color-accent)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.borderColor = 'var(--color-border)';
              e.currentTarget.style.color = 'var(--color-text)';
            }}
          >
            Sign In
          </button>
          <button
            style={styles.signUpBtn}
            className="u-hide-mobile"
            onClick={() => navigate('/assess')}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'translateY(-1px)';
              e.currentTarget.style.boxShadow = '0 4px 12px rgba(197, 160, 89, 0.4)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = '0 2px 8px rgba(197, 160, 89, 0.3)';
            }}
          >
            Sign Up
          </button>

          {/* Hamburger (Mobile) */}
          <button
            style={styles.hamburger}
            className="u-hide-desktop"
            onClick={() => setMobileOpen(!mobileOpen)}
            aria-label={mobileOpen ? 'Close menu' : 'Open menu'}
          >
            <AnimatePresence mode="wait">
              {mobileOpen ? (
                <motion.div
                  key="close"
                  initial={{ opacity: 0, rotate: -90 }}
                  animate={{ opacity: 1, rotate: 0 }}
                  exit={{ opacity: 0, rotate: 90 }}
                >
                  <X size={22} />
                </motion.div>
              ) : (
                <motion.div
                  key="menu"
                  initial={{ opacity: 0, rotate: 90 }}
                  animate={{ opacity: 1, rotate: 0 }}
                  exit={{ opacity: 0, rotate: -90 }}
                >
                  <Menu size={22} />
                </motion.div>
              )}
            </AnimatePresence>
          </button>
        </div>
      </nav>

      {/* Mobile Overlay */}
      <AnimatePresence>
        {mobileOpen && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            style={styles.overlay}
          >
            {/* Decorative blobs in overlay */}
            <div style={{
              position: 'absolute', inset: 0, overflow: 'hidden', pointerEvents: 'none',
            }}>
              {DIMENSION_COLORS.map((color, i) => (
                <div
                  key={i}
                  style={{
                    position: 'absolute',
                    width: `${120 + i * 30}px`,
                    height: `${120 + i * 30}px`,
                    borderRadius: '50%',
                    background: color,
                    filter: 'blur(80px)',
                    opacity: 0.08,
                    top: `${10 + i * 12}%`,
                    left: `${5 + (i % 3) * 30}%`,
                    animation: `morphBlob ${18 + i * 2}s ease-in-out infinite`,
                    animationDelay: `${-i * 3}s`,
                  }}
                />
              ))}
            </div>

            {NAV_LINKS.map((link, i) => (
              <motion.button
                key={link.path}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.05 + i * 0.06, duration: 0.3 }}
                style={styles.mobileLink(isActive(link.path))}
                onClick={() => navigate(link.path)}
                onMouseEnter={(e) => {
                  e.currentTarget.style.color = 'var(--color-accent)';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.color = isActive(link.path)
                    ? 'var(--color-accent)'
                    : 'var(--color-text)';
                }}
              >
                {link.label}
              </motion.button>
            ))}

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4 }}
              style={styles.mobileFooter}
            >
              <button
                style={{
                  ...styles.signInBtn,
                  fontSize: '0.9375rem',
                  padding: '0.625rem 1.5rem',
                }}
                onClick={() => navigate('/profile')}
              >
                Sign In
              </button>
              <button
                style={{
                  ...styles.signUpBtn,
                  fontSize: '0.9375rem',
                  padding: '0.625rem 1.5rem',
                }}
                onClick={() => navigate('/assess')}
              >
                Sign Up
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Click-away for notifications */}
      {notifOpen && (
        <div
          style={{ position: 'fixed', inset: 0, zIndex: 998 }}
          onClick={() => setNotifOpen(false)}
        />
      )}
    </>
  );
};

export default Navigation;
