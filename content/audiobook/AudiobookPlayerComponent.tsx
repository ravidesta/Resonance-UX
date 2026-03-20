import React, { useState, useRef, useEffect, useCallback } from 'react';

// ─── Types ───────────────────────────────────────────────────────────────────

interface Chapter {
  id: number;
  title: string;
  subtitle: string;
  startTime: number; // seconds
  duration: number;  // seconds
}

interface Quote {
  text: string;
  chapter: string;
}

// ─── Data ────────────────────────────────────────────────────────────────────

const CHAPTERS: Chapter[] = [
  { id: 1, title: 'The Roots of Connection', subtitle: 'Understanding attachment theory', startTime: 0, duration: 1920 },
  { id: 2, title: 'Your Attachment Story', subtitle: 'Identifying your style', startTime: 1920, duration: 1800 },
  { id: 3, title: 'The Anxious Heart', subtitle: 'Hyperactivation and protest', startTime: 3720, duration: 2040 },
  { id: 4, title: 'The Distant Shore', subtitle: 'Avoidant attachment', startTime: 5760, duration: 1980 },
  { id: 5, title: 'The Storm Within', subtitle: 'Disorganized attachment', startTime: 7740, duration: 1860 },
  { id: 6, title: 'Earned Security', subtitle: 'Neuroplasticity and hope', startTime: 9600, duration: 2100 },
  { id: 7, title: 'Rewiring the Response', subtitle: 'Somatic exercises', startTime: 11700, duration: 1920 },
  { id: 8, title: 'The Language of Needs', subtitle: 'Communicating with clarity', startTime: 13620, duration: 1800 },
  { id: 9, title: 'Boundaries as Love', subtitle: 'Healthy limits', startTime: 15420, duration: 1740 },
  { id: 10, title: 'Rupture and Repair', subtitle: 'Conflict and reconnection', startTime: 17160, duration: 2040 },
  { id: 11, title: 'The Luminous Thread', subtitle: 'Inner child work', startTime: 19200, duration: 1980 },
  { id: 12, title: 'Becoming Home', subtitle: 'Integration and continuation', startTime: 21180, duration: 1620 },
];

const SHAREABLE_QUOTES: Quote[] = [
  { text: 'Your attachment style is not your destiny. It is your starting point.', chapter: 'Chapter 1' },
  { text: 'The anxious heart does not love too much. It fears too much.', chapter: 'Chapter 3' },
  { text: 'The avoidant person is not someone who doesn\'t need love. They are someone who learned that needing love was the most dangerous thing in the world.', chapter: 'Chapter 4' },
  { text: 'It is not what happened to you that determines your security. It is how you have come to understand what happened to you.', chapter: 'Chapter 6' },
  { text: 'Behind every criticism is an unspoken wish. Behind every demand is an unmet need.', chapter: 'Chapter 8' },
  { text: 'A boundary is not a rejection of the other person. It is a declaration of the self.', chapter: 'Chapter 9' },
  { text: 'The places where we have broken and been repaired are not weaknesses but the strongest, most luminous seams.', chapter: 'Chapter 10' },
  { text: 'Home is not a place you find. It is a quality of presence you cultivate.', chapter: 'Chapter 12' },
];

const SLEEP_TIMER_OPTIONS = [
  { label: 'Off', minutes: 0 },
  { label: '15 min', minutes: 15 },
  { label: '30 min', minutes: 30 },
  { label: '45 min', minutes: 45 },
  { label: '60 min', minutes: 60 },
  { label: '90 min', minutes: 90 },
];

const SPEED_OPTIONS = [0.5, 0.75, 1, 1.25, 1.5, 1.75, 2];

// ─── Styles ──────────────────────────────────────────────────────────────────

const colors = {
  green: '#122E21',
  greenLight: '#1a3f2f',
  greenDark: '#0d2118',
  gold: '#C5A059',
  goldLight: '#d4b574',
  goldMuted: 'rgba(197, 160, 89, 0.15)',
  goldSubtle: 'rgba(197, 160, 89, 0.08)',
  cream: '#FAFAF8',
  creamDark: '#f0efe8',
  white: '#ffffff',
  whiteAlpha60: 'rgba(255,255,255,0.6)',
  whiteAlpha20: 'rgba(255,255,255,0.2)',
  whiteAlpha10: 'rgba(255,255,255,0.1)',
  whiteAlpha05: 'rgba(255,255,255,0.05)',
};

const styles: Record<string, React.CSSProperties> = {
  // ── Container ──
  container: {
    fontFamily: "'Manrope', -apple-system, BlinkMacSystemFont, sans-serif",
    color: colors.cream,
    minHeight: '100vh',
    background: `linear-gradient(165deg, ${colors.greenDark} 0%, ${colors.green} 40%, ${colors.greenLight} 100%)`,
    display: 'flex',
    flexDirection: 'column',
    position: 'relative',
  },

  // ── Album Art Area ──
  artArea: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '3rem 2rem 2rem',
    flex: '0 0 auto',
  },
  albumArt: {
    width: 240,
    height: 240,
    borderRadius: 20,
    background: `linear-gradient(135deg, ${colors.goldMuted} 0%, ${colors.whiteAlpha05} 50%, ${colors.goldMuted} 100%)`,
    border: `1px solid ${colors.whiteAlpha20}`,
    backdropFilter: 'blur(20px)',
    WebkitBackdropFilter: 'blur(20px)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    boxShadow: `0 20px 60px rgba(0,0,0,0.3), inset 0 1px 0 ${colors.whiteAlpha10}`,
    marginBottom: '1.5rem',
  },
  albumIcon: {
    fontSize: '3.5rem',
    marginBottom: '0.75rem',
    opacity: 0.8,
  },
  albumTitle: {
    fontFamily: "'Cormorant Garamond', Georgia, serif",
    fontSize: '1.35rem',
    fontWeight: 600,
    color: colors.gold,
    textAlign: 'center' as const,
    lineHeight: 1.3,
  },
  albumSubtitle: {
    fontSize: '0.75rem',
    fontWeight: 400,
    color: colors.whiteAlpha60,
    letterSpacing: '0.15em',
    textTransform: 'uppercase' as const,
    marginTop: '0.35rem',
  },

  // ── Now Playing ──
  nowPlaying: {
    textAlign: 'center' as const,
    marginBottom: '0.25rem',
  },
  chapterLabel: {
    fontSize: '0.7rem',
    fontWeight: 600,
    letterSpacing: '0.2em',
    textTransform: 'uppercase' as const,
    color: colors.gold,
    marginBottom: '0.35rem',
  },
  chapterTitle: {
    fontFamily: "'Cormorant Garamond', Georgia, serif",
    fontSize: '1.5rem',
    fontWeight: 600,
    color: colors.cream,
    lineHeight: 1.3,
    marginBottom: '0.2rem',
  },
  chapterSubtitle: {
    fontSize: '0.85rem',
    fontWeight: 300,
    color: colors.whiteAlpha60,
  },

  // ── Progress Bar ──
  progressSection: {
    padding: '1.5rem 2rem 0.5rem',
  },
  progressTrack: {
    width: '100%',
    height: 4,
    background: colors.whiteAlpha10,
    borderRadius: 2,
    position: 'relative' as const,
    cursor: 'pointer',
    marginBottom: '0.5rem',
  },
  progressFill: {
    height: '100%',
    background: `linear-gradient(90deg, ${colors.gold}, ${colors.goldLight})`,
    borderRadius: 2,
    transition: 'width 0.1s linear',
    position: 'relative' as const,
  },
  progressThumb: {
    position: 'absolute' as const,
    right: -6,
    top: -4,
    width: 12,
    height: 12,
    borderRadius: '50%',
    background: colors.gold,
    boxShadow: `0 0 8px rgba(197, 160, 89, 0.5)`,
  },
  chapterMarker: {
    position: 'absolute' as const,
    top: -1,
    width: 2,
    height: 6,
    background: colors.whiteAlpha20,
    borderRadius: 1,
  },
  timeRow: {
    display: 'flex',
    justifyContent: 'space-between',
    fontSize: '0.75rem',
    fontWeight: 400,
    color: colors.whiteAlpha60,
    fontVariantNumeric: 'tabular-nums',
  },

  // ── Controls ──
  controls: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '1.5rem',
    padding: '1.25rem 2rem',
  },
  controlBtn: {
    background: 'none',
    border: 'none',
    color: colors.cream,
    cursor: 'pointer',
    padding: '0.5rem',
    borderRadius: '50%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    transition: 'all 0.2s',
    fontSize: '1.25rem',
    opacity: 0.8,
  },
  playBtn: {
    width: 64,
    height: 64,
    borderRadius: '50%',
    background: `linear-gradient(135deg, ${colors.gold}, ${colors.goldLight})`,
    border: 'none',
    color: colors.green,
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '1.5rem',
    boxShadow: `0 4px 20px rgba(197, 160, 89, 0.35)`,
    transition: 'all 0.2s',
  },

  // ── Speed & Sleep Row ──
  secondaryControls: {
    display: 'flex',
    justifyContent: 'center',
    gap: '1.5rem',
    padding: '0 2rem 1rem',
  },
  pillBtn: {
    background: colors.whiteAlpha10,
    border: `1px solid ${colors.whiteAlpha20}`,
    borderRadius: 20,
    padding: '0.4rem 0.85rem',
    color: colors.cream,
    fontSize: '0.75rem',
    fontWeight: 500,
    cursor: 'pointer',
    fontFamily: "'Manrope', sans-serif",
    transition: 'all 0.2s',
    backdropFilter: 'blur(10px)',
    WebkitBackdropFilter: 'blur(10px)',
  },
  pillBtnActive: {
    background: colors.goldMuted,
    borderColor: colors.gold,
    color: colors.gold,
  },

  // ── Chapter List ──
  chapterListToggle: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '0.85rem 2rem',
    borderTop: `1px solid ${colors.whiteAlpha10}`,
    cursor: 'pointer',
    background: 'none',
    border: 'none',
    borderTopStyle: 'solid' as const,
    borderTopWidth: 1,
    borderTopColor: colors.whiteAlpha10,
    color: colors.cream,
    width: '100%',
    fontFamily: "'Manrope', sans-serif",
  },
  chapterListLabel: {
    fontSize: '0.8rem',
    fontWeight: 600,
    letterSpacing: '0.1em',
    textTransform: 'uppercase' as const,
    color: colors.gold,
  },
  chapterList: {
    flex: 1,
    overflowY: 'auto' as const,
    padding: '0 0 6rem',
  },
  chapterItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '1rem',
    padding: '0.85rem 2rem',
    cursor: 'pointer',
    transition: 'background 0.15s',
    borderBottom: `1px solid ${colors.whiteAlpha05}`,
  },
  chapterItemActive: {
    background: colors.goldSubtle,
  },
  chapterNum: {
    fontFamily: "'Cormorant Garamond', Georgia, serif",
    fontSize: '1.1rem',
    fontWeight: 700,
    color: colors.gold,
    minWidth: 28,
    textAlign: 'center' as const,
  },
  chapterInfo: {
    flex: 1,
  },
  chapterItemTitle: {
    fontSize: '0.95rem',
    fontWeight: 500,
    color: colors.cream,
    lineHeight: 1.3,
  },
  chapterItemSub: {
    fontSize: '0.75rem',
    fontWeight: 300,
    color: colors.whiteAlpha60,
    marginTop: 2,
  },
  chapterItemDuration: {
    fontSize: '0.75rem',
    fontWeight: 400,
    color: colors.whiteAlpha60,
    fontVariantNumeric: 'tabular-nums',
  },

  // ── Mini Player ──
  miniPlayer: {
    position: 'fixed' as const,
    bottom: 0,
    left: 0,
    right: 0,
    height: 72,
    background: `linear-gradient(180deg, rgba(18,46,33,0.95) 0%, rgba(13,33,24,0.98) 100%)`,
    backdropFilter: 'blur(20px)',
    WebkitBackdropFilter: 'blur(20px)',
    borderTop: `1px solid ${colors.whiteAlpha10}`,
    display: 'flex',
    alignItems: 'center',
    padding: '0 1rem',
    gap: '0.75rem',
    zIndex: 100,
  },
  miniArt: {
    width: 48,
    height: 48,
    borderRadius: 10,
    background: colors.goldMuted,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '1.25rem',
    flexShrink: 0,
  },
  miniInfo: {
    flex: 1,
    minWidth: 0,
  },
  miniTitle: {
    fontSize: '0.85rem',
    fontWeight: 500,
    color: colors.cream,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap' as const,
  },
  miniSub: {
    fontSize: '0.7rem',
    color: colors.whiteAlpha60,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap' as const,
  },
  miniProgress: {
    position: 'absolute' as const,
    top: 0,
    left: 0,
    right: 0,
    height: 2,
    background: colors.whiteAlpha10,
  },
  miniProgressFill: {
    height: '100%',
    background: colors.gold,
    transition: 'width 0.3s linear',
  },
  miniBtn: {
    background: 'none',
    border: 'none',
    color: colors.cream,
    cursor: 'pointer',
    padding: '0.5rem',
    fontSize: '1.25rem',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },

  // ── Share Quote Modal ──
  overlay: {
    position: 'fixed' as const,
    inset: 0,
    background: 'rgba(0,0,0,0.6)',
    backdropFilter: 'blur(8px)',
    WebkitBackdropFilter: 'blur(8px)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 200,
    padding: '2rem',
  },
  quoteCard: {
    background: `linear-gradient(135deg, ${colors.green} 0%, ${colors.greenLight} 100%)`,
    border: `1px solid ${colors.whiteAlpha20}`,
    borderRadius: 16,
    padding: '2.5rem 2rem',
    maxWidth: 380,
    width: '100%',
    textAlign: 'center' as const,
    boxShadow: '0 20px 60px rgba(0,0,0,0.4)',
  },
  quoteText: {
    fontFamily: "'Cormorant Garamond', Georgia, serif",
    fontSize: '1.25rem',
    fontStyle: 'italic' as const,
    color: colors.cream,
    lineHeight: 1.6,
    marginBottom: '1rem',
  },
  quoteAttribution: {
    fontSize: '0.75rem',
    fontWeight: 600,
    letterSpacing: '0.1em',
    textTransform: 'uppercase' as const,
    color: colors.gold,
    marginBottom: '1.5rem',
  },
  shareActions: {
    display: 'flex',
    gap: '0.75rem',
    justifyContent: 'center',
  },
  shareBtn: {
    background: colors.goldMuted,
    border: `1px solid ${colors.gold}`,
    borderRadius: 8,
    padding: '0.6rem 1.25rem',
    color: colors.gold,
    fontSize: '0.8rem',
    fontWeight: 600,
    cursor: 'pointer',
    fontFamily: "'Manrope', sans-serif",
    transition: 'all 0.2s',
  },
  closeBtnOverlay: {
    position: 'absolute' as const,
    top: '1rem',
    right: '1rem',
    background: 'none',
    border: 'none',
    color: colors.whiteAlpha60,
    fontSize: '1.5rem',
    cursor: 'pointer',
  },

  // ── Sleep Timer Badge ──
  sleepBadge: {
    position: 'absolute' as const,
    top: -4,
    right: -4,
    width: 8,
    height: 8,
    borderRadius: '50%',
    background: colors.gold,
  },

  // ── Dropdown ──
  dropdown: {
    position: 'absolute' as const,
    bottom: '100%',
    left: '50%',
    transform: 'translateX(-50%)',
    background: colors.greenDark,
    border: `1px solid ${colors.whiteAlpha20}`,
    borderRadius: 12,
    padding: '0.5rem',
    marginBottom: '0.5rem',
    minWidth: 120,
    boxShadow: '0 8px 32px rgba(0,0,0,0.4)',
    backdropFilter: 'blur(20px)',
    WebkitBackdropFilter: 'blur(20px)',
    zIndex: 50,
  },
  dropdownItem: {
    display: 'block',
    width: '100%',
    padding: '0.5rem 1rem',
    background: 'none',
    border: 'none',
    color: colors.cream,
    fontSize: '0.85rem',
    fontFamily: "'Manrope', sans-serif",
    cursor: 'pointer',
    borderRadius: 8,
    textAlign: 'center' as const,
    transition: 'background 0.15s',
  },
  dropdownItemActive: {
    background: colors.goldMuted,
    color: colors.gold,
    fontWeight: 600,
  },
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = Math.floor(seconds % 60);
  return `${m}:${s.toString().padStart(2, '0')}`;
}

function formatDuration(seconds: number): string {
  const m = Math.floor(seconds / 60);
  return `${m} min`;
}

function getTotalDuration(): number {
  const last = CHAPTERS[CHAPTERS.length - 1];
  return last.startTime + last.duration;
}

// ─── Component ───────────────────────────────────────────────────────────────

const AudiobookPlayerComponent: React.FC = () => {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const sleepTimerRef = useRef<NodeJS.Timeout | null>(null);

  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration] = useState(getTotalDuration());
  const [playbackSpeed, setPlaybackSpeed] = useState(1);
  const [showChapterList, setShowChapterList] = useState(false);
  const [showMiniPlayer, setShowMiniPlayer] = useState(false);
  const [showSpeedDropdown, setShowSpeedDropdown] = useState(false);
  const [showSleepDropdown, setShowSleepDropdown] = useState(false);
  const [sleepMinutes, setSleepMinutes] = useState(0);
  const [sleepRemaining, setSleepRemaining] = useState(0);
  const [showShareModal, setShowShareModal] = useState(false);
  const [currentQuote, setCurrentQuote] = useState<Quote | null>(null);
  const [copied, setCopied] = useState(false);

  const currentChapter = CHAPTERS.reduce((acc, ch) => {
    if (currentTime >= ch.startTime) return ch;
    return acc;
  }, CHAPTERS[0]);

  const chapterProgress = currentChapter
    ? ((currentTime - currentChapter.startTime) / currentChapter.duration) * 100
    : 0;

  const overallProgress = (currentTime / duration) * 100;

  // ── Scroll-based mini player ──
  useEffect(() => {
    const handleScroll = () => {
      setShowMiniPlayer(window.scrollY > 400);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // ── Sleep timer ──
  useEffect(() => {
    if (sleepMinutes > 0) {
      setSleepRemaining(sleepMinutes * 60);
      const interval = setInterval(() => {
        setSleepRemaining(prev => {
          if (prev <= 1) {
            clearInterval(interval);
            setIsPlaying(false);
            setSleepMinutes(0);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      sleepTimerRef.current = interval;
      return () => clearInterval(interval);
    } else {
      setSleepRemaining(0);
      if (sleepTimerRef.current) clearInterval(sleepTimerRef.current);
    }
  }, [sleepMinutes]);

  // ── Simulated playback ──
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isPlaying) {
      interval = setInterval(() => {
        setCurrentTime(prev => {
          const next = prev + playbackSpeed;
          if (next >= duration) {
            setIsPlaying(false);
            return duration;
          }
          return next;
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isPlaying, playbackSpeed, duration]);

  const togglePlay = useCallback(() => setIsPlaying(p => !p), []);

  const skipForward = useCallback(() => {
    setCurrentTime(prev => Math.min(prev + 30, duration));
  }, [duration]);

  const skipBackward = useCallback(() => {
    setCurrentTime(prev => Math.max(prev - 15, 0));
  }, []);

  const seekToChapter = useCallback((chapter: Chapter) => {
    setCurrentTime(chapter.startTime);
    setIsPlaying(true);
    setShowChapterList(false);
  }, []);

  const handleProgressClick = useCallback((e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const pct = (e.clientX - rect.left) / rect.width;
    setCurrentTime(Math.max(0, Math.min(pct * duration, duration)));
  }, [duration]);

  const handleShareQuote = useCallback(() => {
    const q = SHAREABLE_QUOTES[Math.floor(Math.random() * SHAREABLE_QUOTES.length)];
    setCurrentQuote(q);
    setShowShareModal(true);
    setCopied(false);
  }, []);

  const copyQuote = useCallback(async () => {
    if (!currentQuote) return;
    try {
      await navigator.clipboard.writeText(
        `"${currentQuote.text}"\n\n— Luminous Attachment, ${currentQuote.chapter}`
      );
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // fallback
    }
  }, [currentQuote]);

  // ── Render: Full Player ──
  if (showChapterList) {
    return (
      <div style={styles.container}>
        <button
          style={{
            ...styles.chapterListToggle,
            borderTop: 'none',
            padding: '1.25rem 2rem',
          }}
          onClick={() => setShowChapterList(false)}
        >
          <span style={styles.chapterListLabel}>Chapters</span>
          <span style={{ color: colors.whiteAlpha60, fontSize: '0.85rem' }}>Close</span>
        </button>

        <div style={styles.chapterList}>
          {CHAPTERS.map(ch => (
            <div
              key={ch.id}
              style={{
                ...styles.chapterItem,
                ...(ch.id === currentChapter.id ? styles.chapterItemActive : {}),
              }}
              onClick={() => seekToChapter(ch)}
            >
              <span style={styles.chapterNum}>{ch.id}</span>
              <div style={styles.chapterInfo}>
                <div style={styles.chapterItemTitle}>{ch.title}</div>
                <div style={styles.chapterItemSub}>{ch.subtitle}</div>
              </div>
              <span style={styles.chapterItemDuration}>{formatDuration(ch.duration)}</span>
            </div>
          ))}
        </div>

        {/* Mini Player at bottom */}
        <div style={styles.miniPlayer}>
          <div style={styles.miniProgress}>
            <div style={{ ...styles.miniProgressFill, width: `${overallProgress}%` }} />
          </div>
          <div style={styles.miniArt}>
            <span role="img" aria-label="book">&#x1F4D6;</span>
          </div>
          <div style={styles.miniInfo}>
            <div style={styles.miniTitle}>Ch. {currentChapter.id}: {currentChapter.title}</div>
            <div style={styles.miniSub}>{formatTime(currentTime)}</div>
          </div>
          <button style={styles.miniBtn} onClick={togglePlay}>
            {isPlaying ? '\u23F8' : '\u25B6'}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      {/* ── Album Art ── */}
      <div style={styles.artArea}>
        <div style={styles.albumArt}>
          <div style={styles.albumIcon}>&#x2728;</div>
          <div style={styles.albumTitle}>Luminous<br />Attachment</div>
          <div style={styles.albumSubtitle}>An Audiobook</div>
        </div>

        {/* ── Now Playing ── */}
        <div style={styles.nowPlaying}>
          <div style={styles.chapterLabel}>Chapter {currentChapter.id} of {CHAPTERS.length}</div>
          <div style={styles.chapterTitle}>{currentChapter.title}</div>
          <div style={styles.chapterSubtitle}>{currentChapter.subtitle}</div>
        </div>
      </div>

      {/* ── Progress Bar ── */}
      <div style={styles.progressSection}>
        <div style={styles.progressTrack} onClick={handleProgressClick}>
          {/* Chapter markers */}
          {CHAPTERS.map(ch => (
            <div
              key={ch.id}
              style={{
                ...styles.chapterMarker,
                left: `${(ch.startTime / duration) * 100}%`,
              }}
            />
          ))}
          <div style={{ ...styles.progressFill, width: `${overallProgress}%` }}>
            <div style={styles.progressThumb} />
          </div>
        </div>
        <div style={styles.timeRow}>
          <span>{formatTime(currentTime)}</span>
          <span>-{formatTime(duration - currentTime)}</span>
        </div>
      </div>

      {/* ── Main Controls ── */}
      <div style={styles.controls}>
        <button
          style={styles.controlBtn}
          onClick={() => {
            const idx = CHAPTERS.findIndex(c => c.id === currentChapter.id);
            if (idx > 0) seekToChapter(CHAPTERS[idx - 1]);
          }}
          title="Previous chapter"
        >
          &#x23EE;
        </button>

        <button style={styles.controlBtn} onClick={skipBackward} title="Rewind 15s">
          <span style={{ fontSize: '0.65rem', fontWeight: 700 }}>15</span>
          <span style={{ marginLeft: 2 }}>&#x21BA;</span>
        </button>

        <button style={styles.playBtn} onClick={togglePlay}>
          {isPlaying ? '\u23F8' : '\u25B6\uFE0E'}
        </button>

        <button style={styles.controlBtn} onClick={skipForward} title="Forward 30s">
          <span style={{ marginRight: 2 }}>&#x21BB;</span>
          <span style={{ fontSize: '0.65rem', fontWeight: 700 }}>30</span>
        </button>

        <button
          style={styles.controlBtn}
          onClick={() => {
            const idx = CHAPTERS.findIndex(c => c.id === currentChapter.id);
            if (idx < CHAPTERS.length - 1) seekToChapter(CHAPTERS[idx + 1]);
          }}
          title="Next chapter"
        >
          &#x23ED;
        </button>
      </div>

      {/* ── Speed, Sleep, Share ── */}
      <div style={styles.secondaryControls}>
        <div style={{ position: 'relative' as const }}>
          <button
            style={{
              ...styles.pillBtn,
              ...(playbackSpeed !== 1 ? styles.pillBtnActive : {}),
            }}
            onClick={() => {
              setShowSpeedDropdown(p => !p);
              setShowSleepDropdown(false);
            }}
          >
            {playbackSpeed}x Speed
          </button>
          {showSpeedDropdown && (
            <div style={styles.dropdown}>
              {SPEED_OPTIONS.map(s => (
                <button
                  key={s}
                  style={{
                    ...styles.dropdownItem,
                    ...(s === playbackSpeed ? styles.dropdownItemActive : {}),
                  }}
                  onClick={() => {
                    setPlaybackSpeed(s);
                    setShowSpeedDropdown(false);
                  }}
                >
                  {s}x
                </button>
              ))}
            </div>
          )}
        </div>

        <div style={{ position: 'relative' as const }}>
          <button
            style={{
              ...styles.pillBtn,
              ...(sleepMinutes > 0 ? styles.pillBtnActive : {}),
            }}
            onClick={() => {
              setShowSleepDropdown(p => !p);
              setShowSpeedDropdown(false);
            }}
          >
            {sleepMinutes > 0
              ? `Sleep ${Math.ceil(sleepRemaining / 60)}m`
              : 'Sleep Timer'}
          </button>
          {sleepMinutes > 0 && <div style={styles.sleepBadge} />}
          {showSleepDropdown && (
            <div style={styles.dropdown}>
              {SLEEP_TIMER_OPTIONS.map(opt => (
                <button
                  key={opt.minutes}
                  style={{
                    ...styles.dropdownItem,
                    ...(opt.minutes === sleepMinutes ? styles.dropdownItemActive : {}),
                  }}
                  onClick={() => {
                    setSleepMinutes(opt.minutes);
                    setShowSleepDropdown(false);
                  }}
                >
                  {opt.label}
                </button>
              ))}
            </div>
          )}
        </div>

        <button style={styles.pillBtn} onClick={handleShareQuote}>
          Share Quote
        </button>
      </div>

      {/* ── Chapter List Toggle ── */}
      <button style={styles.chapterListToggle} onClick={() => setShowChapterList(true)}>
        <span style={styles.chapterListLabel}>
          {CHAPTERS.length} Chapters
        </span>
        <span style={{ color: colors.whiteAlpha60, fontSize: '0.85rem' }}>
          View All &rsaquo;
        </span>
      </button>

      {/* ── Chapter Progress Summary ── */}
      <div style={{ padding: '1rem 2rem 7rem' }}>
        <div
          style={{
            background: colors.whiteAlpha05,
            borderRadius: 12,
            padding: '1.25rem',
            border: `1px solid ${colors.whiteAlpha10}`,
          }}
        >
          <div
            style={{
              fontSize: '0.7rem',
              fontWeight: 600,
              letterSpacing: '0.15em',
              textTransform: 'uppercase' as const,
              color: colors.gold,
              marginBottom: '0.75rem',
            }}
          >
            Chapter Progress
          </div>
          <div style={{ display: 'flex', gap: 4, height: 4 }}>
            {CHAPTERS.map(ch => {
              let pct = 0;
              if (currentTime >= ch.startTime + ch.duration) pct = 100;
              else if (currentTime > ch.startTime)
                pct = ((currentTime - ch.startTime) / ch.duration) * 100;
              return (
                <div
                  key={ch.id}
                  style={{
                    flex: 1,
                    background: colors.whiteAlpha10,
                    borderRadius: 2,
                    overflow: 'hidden',
                  }}
                >
                  <div
                    style={{
                      height: '100%',
                      width: `${pct}%`,
                      background: pct === 100 ? colors.gold : colors.goldLight,
                      borderRadius: 2,
                      transition: 'width 0.3s',
                    }}
                  />
                </div>
              );
            })}
          </div>
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              marginTop: '0.5rem',
              fontSize: '0.7rem',
              color: colors.whiteAlpha60,
            }}
          >
            <span>Ch 1</span>
            <span>Ch 12</span>
          </div>
        </div>
      </div>

      {/* ── Sticky Mini Player ── */}
      {showMiniPlayer && (
        <div style={styles.miniPlayer}>
          <div style={styles.miniProgress}>
            <div style={{ ...styles.miniProgressFill, width: `${overallProgress}%` }} />
          </div>
          <div style={styles.miniArt}>
            <span>&#x2728;</span>
          </div>
          <div style={styles.miniInfo}>
            <div style={styles.miniTitle}>Ch. {currentChapter.id}: {currentChapter.title}</div>
            <div style={styles.miniSub}>
              {formatTime(currentTime)} &middot; {playbackSpeed}x
            </div>
          </div>
          <button style={styles.miniBtn} onClick={skipBackward}>&#x21BA;</button>
          <button style={styles.miniBtn} onClick={togglePlay}>
            {isPlaying ? '\u23F8' : '\u25B6'}
          </button>
          <button style={styles.miniBtn} onClick={skipForward}>&#x21BB;</button>
        </div>
      )}

      {/* ── Share Quote Modal ── */}
      {showShareModal && currentQuote && (
        <div style={styles.overlay} onClick={() => setShowShareModal(false)}>
          <div style={styles.quoteCard} onClick={e => e.stopPropagation()}>
            <button
              style={styles.closeBtnOverlay}
              onClick={() => setShowShareModal(false)}
            >
              &times;
            </button>
            <div style={styles.quoteText}>
              &ldquo;{currentQuote.text}&rdquo;
            </div>
            <div style={styles.quoteAttribution}>
              Luminous Attachment &middot; {currentQuote.chapter}
            </div>
            <div style={styles.shareActions}>
              <button style={styles.shareBtn} onClick={copyQuote}>
                {copied ? 'Copied!' : 'Copy Quote'}
              </button>
              <button
                style={styles.shareBtn}
                onClick={() => {
                  const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(
                    `"${currentQuote.text}"\n\n— Luminous Attachment`
                  )}`;
                  window.open(url, '_blank');
                }}
              >
                Share
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default AudiobookPlayerComponent;
