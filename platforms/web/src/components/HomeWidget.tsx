import React, { useState, useEffect, useCallback } from 'react';

// ── Theme ──────────────────────────────────────────────────────────────────
const theme = {
  bg: '#FAFAF8',
  text: '#0A1C14',
  gold: '#C5A059',
  glass: 'rgba(255,255,255,0.7)',
  headerFont: "'Cormorant Garamond', Georgia, serif",
  bodyFont: "'Manrope', system-ui, sans-serif",
  radius: 16,
};

const glassPanel: React.CSSProperties = {
  background: theme.glass,
  backdropFilter: 'blur(12px)',
  WebkitBackdropFilter: 'blur(12px)',
  borderRadius: theme.radius,
  border: '1px solid rgba(255,255,255,0.4)',
  padding: 20,
};

// ── Zodiac Data ────────────────────────────────────────────────────────────
const SIGNS = [
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
] as const;

type ZodiacSign = (typeof SIGNS)[number];

// ── MoonPhaseWidget ────────────────────────────────────────────────────────
export const MoonPhaseWidget: React.FC = () => {
  const getMoonData = () => {
    const now = new Date();
    const synodicMonth = 29.53058867;
    const knownNewMoon = new Date('2024-01-11T11:57:00Z').getTime();
    const daysSince = (now.getTime() - knownNewMoon) / (1000 * 60 * 60 * 24);
    const phase = ((daysSince % synodicMonth) + synodicMonth) % synodicMonth;
    const illumination = Math.round((1 - Math.cos((2 * Math.PI * phase) / synodicMonth)) / 2 * 100);

    let name: string;
    if (phase < 1.85) name = 'New Moon';
    else if (phase < 7.38) name = 'Waxing Crescent';
    else if (phase < 9.23) name = 'First Quarter';
    else if (phase < 14.77) name = 'Waxing Gibbous';
    else if (phase < 16.61) name = 'Full Moon';
    else if (phase < 22.15) name = 'Waning Gibbous';
    else if (phase < 23.99) name = 'Last Quarter';
    else if (phase < 27.68) name = 'Waning Crescent';
    else name = 'New Moon';

    const signIndex = Math.floor((phase / synodicMonth) * 12) % 12;
    const sign = SIGNS[signIndex];

    const messages: Record<string, string> = {
      'New Moon': 'A time for setting intentions and planting seeds.',
      'Waxing Crescent': 'Build momentum and take your first steps.',
      'First Quarter': 'Face challenges head-on with determination.',
      'Waxing Gibbous': 'Refine your approach and stay committed.',
      'Full Moon': 'Celebrate culmination and release what no longer serves.',
      'Waning Gibbous': 'Share your wisdom and express gratitude.',
      'Last Quarter': 'Let go, forgive, and make space for the new.',
      'Waning Crescent': 'Rest, reflect, and surrender to stillness.',
    };

    return { name, illumination, sign, message: messages[name] || '' };
  };

  const moon = getMoonData();

  const isWaxing = moon.name.includes('Waxing') || moon.name === 'First Quarter' || moon.name === 'Full Moon';

  return (
    <div style={glassPanel}>
      <h3 style={{ fontFamily: theme.headerFont, fontSize: 22, fontWeight: 600, margin: '0 0 16px', color: theme.text }}>
        Moon Phase
      </h3>
      <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
        {/* Moon visual using CSS radial-gradient */}
        <div
          style={{
            width: 80,
            height: 80,
            borderRadius: '50%',
            background: `radial-gradient(circle at ${isWaxing ? '60%' : '40%'} 50%, #F5F0E1 ${moon.illumination * 0.6}%, #2A2A3A ${moon.illumination * 0.6 + 20}%)`,
            boxShadow: '0 0 20px rgba(197,160,89,0.3)',
            flexShrink: 0,
          }}
        />
        <div>
          <div style={{ fontFamily: theme.headerFont, fontSize: 20, fontWeight: 600, color: theme.text }}>
            {moon.name}
          </div>
          <div style={{ fontFamily: theme.bodyFont, fontSize: 13, color: '#888', marginTop: 2 }}>
            {moon.illumination}% illuminated &middot; Moon in {moon.sign}
          </div>
          <p style={{ fontFamily: theme.bodyFont, fontSize: 14, color: '#555', marginTop: 8, lineHeight: 1.5 }}>
            {moon.message}
          </p>
        </div>
      </div>
    </div>
  );
};

// ── DailyHoroscopeWidget ───────────────────────────────────────────────────
const horoscopeReadings: Record<ZodiacSign, { reading: string; luckyNumber: number; mood: string }> = {
  Aries: { reading: 'Bold energy flows through your day. Take initiative on projects that excite you, but pause before reacting to unexpected news.', luckyNumber: 7, mood: 'Energised' },
  Taurus: { reading: 'Grounding moments bring clarity. Financial matters deserve your attention today; trust your practical instincts.', luckyNumber: 4, mood: 'Steady' },
  Gemini: { reading: 'Conversations spark new ideas. Stay curious and let your social connections guide you toward a surprising opportunity.', luckyNumber: 11, mood: 'Curious' },
  Cancer: { reading: 'Home and heart align beautifully. Nurture close relationships and honour your need for emotional security.', luckyNumber: 2, mood: 'Nurturing' },
  Leo: { reading: 'Your creative fire burns bright. Express yourself boldly and let your natural charisma open new doors.', luckyNumber: 9, mood: 'Radiant' },
  Virgo: { reading: 'Details matter more than usual. Your analytical mind is sharp; use it to solve a problem others have overlooked.', luckyNumber: 6, mood: 'Focused' },
  Libra: { reading: 'Harmony is your superpower today. Mediate a conflict with grace and seek beauty in unexpected places.', luckyNumber: 3, mood: 'Balanced' },
  Scorpio: { reading: 'Transformation is in the air. Deep insights emerge when you embrace vulnerability rather than control.', luckyNumber: 8, mood: 'Intense' },
  Sagittarius: { reading: 'Adventure calls you forward. Expand your horizons through learning, travel, or a bold philosophical conversation.', luckyNumber: 5, mood: 'Adventurous' },
  Capricorn: { reading: 'Discipline meets opportunity. Long-term goals benefit from today\'s focused effort; keep climbing.', luckyNumber: 10, mood: 'Ambitious' },
  Aquarius: { reading: 'Innovation strikes in community settings. Your unique perspective is needed; don\'t hold back your ideas.', luckyNumber: 12, mood: 'Visionary' },
  Pisces: { reading: 'Intuition is your compass today. Dreams carry messages; journal them before they fade with the morning light.', luckyNumber: 1, mood: 'Dreamy' },
};

export const DailyHoroscopeWidget: React.FC = () => {
  const [sign, setSign] = useState<ZodiacSign>('Aries');
  const data = horoscopeReadings[sign];

  return (
    <div style={glassPanel}>
      <h3 style={{ fontFamily: theme.headerFont, fontSize: 22, fontWeight: 600, margin: '0 0 16px', color: theme.text }}>
        Daily Horoscope
      </h3>
      <select
        value={sign}
        onChange={(e) => setSign(e.target.value as ZodiacSign)}
        style={{
          width: '100%',
          padding: '10px 14px',
          borderRadius: 10,
          border: '1px solid rgba(0,0,0,0.1)',
          background: '#fff',
          fontFamily: theme.bodyFont,
          fontSize: 14,
          color: theme.text,
          marginBottom: 16,
          outline: 'none',
          cursor: 'pointer',
        }}
      >
        {SIGNS.map((s) => (
          <option key={s} value={s}>{s}</option>
        ))}
      </select>
      <p style={{ fontFamily: theme.bodyFont, fontSize: 14, color: '#444', lineHeight: 1.6, margin: '0 0 12px' }}>
        {data.reading}
      </p>
      <div style={{ display: 'flex', gap: 16, fontFamily: theme.bodyFont, fontSize: 13, color: '#777' }}>
        <span>Lucky Number: <strong style={{ color: theme.gold }}>{data.luckyNumber}</strong></span>
        <span>Mood: <strong style={{ color: theme.gold }}>{data.mood}</strong></span>
      </div>
    </div>
  );
};

// ── TransitAlertWidget ─────────────────────────────────────────────────────
interface Transit {
  id: string;
  name: string;
  description: string;
  significance: 'high' | 'medium' | 'low';
}

const activeTransits: Transit[] = [
  {
    id: 't1',
    name: 'Mercury conjunct Neptune',
    description: 'Heightened intuition but watch for miscommunication. Double-check important messages.',
    significance: 'high',
  },
  {
    id: 't2',
    name: 'Venus trine Jupiter',
    description: 'Expansive love and abundance energy. Great for social gatherings and creative pursuits.',
    significance: 'medium',
  },
  {
    id: 't3',
    name: 'Mars sextile Saturn',
    description: 'Disciplined action yields results. Channel energy into structured tasks.',
    significance: 'low',
  },
];

const significanceColors: Record<string, string> = {
  high: theme.gold,
  medium: '#6BA368',
  low: '#999',
};

export const TransitAlertWidget: React.FC = () => (
  <div style={glassPanel}>
    <h3 style={{ fontFamily: theme.headerFont, fontSize: 22, fontWeight: 600, margin: '0 0 16px', color: theme.text }}>
      Active Transits
    </h3>
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      {activeTransits.map((t) => (
        <div
          key={t.id}
          style={{
            padding: 12,
            borderRadius: 10,
            background: 'rgba(0,0,0,0.02)',
            borderLeft: `3px solid ${significanceColors[t.significance]}`,
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 4 }}>
            <span style={{ fontFamily: theme.bodyFont, fontSize: 14, fontWeight: 600, color: theme.text }}>
              {t.name}
            </span>
            <span
              style={{
                fontSize: 10,
                fontFamily: theme.bodyFont,
                fontWeight: 700,
                textTransform: 'uppercase',
                letterSpacing: 1,
                padding: '2px 8px',
                borderRadius: 8,
                background: `${significanceColors[t.significance]}22`,
                color: significanceColors[t.significance],
              }}
            >
              {t.significance}
            </span>
          </div>
          <p style={{ fontFamily: theme.bodyFont, fontSize: 13, color: '#666', margin: 0, lineHeight: 1.5 }}>
            {t.description}
          </p>
        </div>
      ))}
    </div>
  </div>
);

// ── JournalStreakWidget ─────────────────────────────────────────────────────
export const JournalStreakWidget: React.FC = () => {
  const streak = 12;
  const entriesThisWeek = 5;
  const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  const completedDays = [true, true, true, true, true, false, false];

  return (
    <div style={glassPanel}>
      <h3 style={{ fontFamily: theme.headerFont, fontSize: 22, fontWeight: 600, margin: '0 0 16px', color: theme.text }}>
        Journal Streak
      </h3>
      <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 16 }}>
        {/* Flame visual */}
        <div style={{ fontSize: 40, lineHeight: 1 }}>{'\uD83D\uDD25'}</div>
        <div>
          <div style={{ fontFamily: theme.headerFont, fontSize: 36, fontWeight: 700, color: theme.gold }}>
            {streak}
          </div>
          <div style={{ fontFamily: theme.bodyFont, fontSize: 13, color: '#888' }}>day streak</div>
        </div>
      </div>
      <div style={{ fontFamily: theme.bodyFont, fontSize: 13, color: '#666', marginBottom: 10 }}>
        {entriesThisWeek} of 7 entries this week
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        {weekDays.map((day, i) => (
          <div
            key={i}
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 4,
            }}
          >
            <div
              style={{
                width: 28,
                height: 28,
                borderRadius: '50%',
                background: completedDays[i] ? theme.gold : 'rgba(0,0,0,0.06)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: completedDays[i] ? '#fff' : '#bbb',
                fontSize: 11,
                fontFamily: theme.bodyFont,
                fontWeight: 600,
              }}
            >
              {completedDays[i] ? '\u2713' : ''}
            </div>
            <span style={{ fontSize: 10, color: '#999', fontFamily: theme.bodyFont }}>{day}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

// ── CompatibilityWidget ────────────────────────────────────────────────────
const elementGroups: Record<string, string> = {
  Aries: 'fire', Taurus: 'earth', Gemini: 'air', Cancer: 'water',
  Leo: 'fire', Virgo: 'earth', Libra: 'air', Scorpio: 'water',
  Sagittarius: 'fire', Capricorn: 'earth', Aquarius: 'air', Pisces: 'water',
};

const getCompatibility = (a: ZodiacSign, b: ZodiacSign): { score: number; description: string } => {
  if (a === b) return { score: 85, description: 'A mirror match! You understand each other deeply but must watch for amplified blind spots.' };
  const eA = elementGroups[a];
  const eB = elementGroups[b];
  if (eA === eB) return { score: 90, description: 'Same element energy creates natural harmony, effortless understanding, and shared values.' };
  const compatible: Record<string, string> = { fire: 'air', air: 'fire', earth: 'water', water: 'earth' };
  if (compatible[eA] === eB) return { score: 78, description: 'Complementary elements that fuel each other. A dynamic and stimulating connection.' };
  if ((eA === 'fire' && eB === 'water') || (eA === 'water' && eB === 'fire'))
    return { score: 52, description: 'Steam! Passionate but challenging. Requires patience, empathy, and emotional maturity.' };
  return { score: 60, description: 'Different rhythms create growth opportunities. Embrace what the other teaches you.' };
};

export const CompatibilityWidget: React.FC = () => {
  const [signA, setSignA] = useState<ZodiacSign>('Aries');
  const [signB, setSignB] = useState<ZodiacSign>('Libra');
  const [result, setResult] = useState<{ score: number; description: string } | null>(null);

  const selectStyle: React.CSSProperties = {
    flex: 1,
    padding: '10px 14px',
    borderRadius: 10,
    border: '1px solid rgba(0,0,0,0.1)',
    background: '#fff',
    fontFamily: theme.bodyFont,
    fontSize: 14,
    color: theme.text,
    outline: 'none',
    cursor: 'pointer',
  };

  return (
    <div style={glassPanel}>
      <h3 style={{ fontFamily: theme.headerFont, fontSize: 22, fontWeight: 600, margin: '0 0 16px', color: theme.text }}>
        Compatibility
      </h3>
      <div style={{ display: 'flex', gap: 10, marginBottom: 12 }}>
        <select value={signA} onChange={(e) => setSignA(e.target.value as ZodiacSign)} style={selectStyle}>
          {SIGNS.map((s) => <option key={s} value={s}>{s}</option>)}
        </select>
        <span style={{ fontFamily: theme.headerFont, fontSize: 20, color: theme.gold, alignSelf: 'center' }}>&amp;</span>
        <select value={signB} onChange={(e) => setSignB(e.target.value as ZodiacSign)} style={selectStyle}>
          {SIGNS.map((s) => <option key={s} value={s}>{s}</option>)}
        </select>
      </div>
      <button
        onClick={() => setResult(getCompatibility(signA, signB))}
        style={{
          width: '100%',
          padding: '10px 0',
          borderRadius: 10,
          border: 'none',
          background: theme.gold,
          color: '#fff',
          fontFamily: theme.bodyFont,
          fontSize: 14,
          fontWeight: 600,
          cursor: 'pointer',
          marginBottom: result ? 16 : 0,
        }}
      >
        Calculate Compatibility
      </button>
      {result && (
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 10 }}>
            <span style={{ fontFamily: theme.headerFont, fontSize: 32, fontWeight: 700, color: theme.gold }}>
              {result.score}%
            </span>
          </div>
          {/* Progress bar */}
          <div
            style={{
              height: 8,
              borderRadius: 4,
              background: 'rgba(0,0,0,0.06)',
              overflow: 'hidden',
              marginBottom: 12,
            }}
          >
            <div
              style={{
                height: '100%',
                width: `${result.score}%`,
                borderRadius: 4,
                background: `linear-gradient(90deg, ${theme.gold}, #E8D5A3)`,
                transition: 'width 0.5s ease',
              }}
            />
          </div>
          <p style={{ fontFamily: theme.bodyFont, fontSize: 14, color: '#555', lineHeight: 1.6, margin: 0 }}>
            {result.description}
          </p>
        </div>
      )}
    </div>
  );
};

// ── MeditationTimerWidget ──────────────────────────────────────────────────
export const MeditationTimerWidget: React.FC = () => {
  const presets = [5, 10, 15, 20];
  const [selectedMinutes, setSelectedMinutes] = useState(10);
  const [secondsLeft, setSecondsLeft] = useState(10 * 60);
  const [isRunning, setIsRunning] = useState(false);

  useEffect(() => {
    if (!isRunning) return;
    if (secondsLeft <= 0) {
      setIsRunning(false);
      return;
    }
    const timer = setInterval(() => {
      setSecondsLeft((s) => s - 1);
    }, 1000);
    return () => clearInterval(timer);
  }, [isRunning, secondsLeft]);

  const handlePreset = (min: number) => {
    setSelectedMinutes(min);
    setSecondsLeft(min * 60);
    setIsRunning(false);
  };

  const handleStart = () => {
    if (secondsLeft <= 0) {
      setSecondsLeft(selectedMinutes * 60);
    }
    setIsRunning((r) => !r);
  };

  const handleReset = () => {
    setIsRunning(false);
    setSecondsLeft(selectedMinutes * 60);
  };

  const minutes = Math.floor(secondsLeft / 60);
  const secs = secondsLeft % 60;
  const totalSeconds = selectedMinutes * 60;
  const progressPct = totalSeconds > 0 ? ((totalSeconds - secondsLeft) / totalSeconds) * 100 : 0;

  return (
    <div style={glassPanel}>
      <h3 style={{ fontFamily: theme.headerFont, fontSize: 22, fontWeight: 600, margin: '0 0 16px', color: theme.text }}>
        Meditation Timer
      </h3>
      {/* Presets */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
        {presets.map((min) => (
          <button
            key={min}
            onClick={() => handlePreset(min)}
            style={{
              flex: 1,
              padding: '8px 0',
              borderRadius: 10,
              border: selectedMinutes === min ? `2px solid ${theme.gold}` : '2px solid transparent',
              background: selectedMinutes === min ? `${theme.gold}15` : 'rgba(0,0,0,0.04)',
              color: selectedMinutes === min ? theme.gold : '#888',
              fontFamily: theme.bodyFont,
              fontSize: 14,
              fontWeight: 600,
              cursor: 'pointer',
            }}
          >
            {min}m
          </button>
        ))}
      </div>
      {/* Countdown */}
      <div style={{ textAlign: 'center', marginBottom: 16 }}>
        <div
          style={{
            fontFamily: theme.headerFont,
            fontSize: 56,
            fontWeight: 700,
            color: theme.text,
            letterSpacing: 2,
          }}
        >
          {String(minutes).padStart(2, '0')}:{String(secs).padStart(2, '0')}
        </div>
        {/* Progress bar */}
        <div
          style={{
            height: 4,
            borderRadius: 2,
            background: 'rgba(0,0,0,0.06)',
            margin: '12px auto',
            maxWidth: 200,
            overflow: 'hidden',
          }}
        >
          <div
            style={{
              height: '100%',
              width: `${progressPct}%`,
              borderRadius: 2,
              background: theme.gold,
              transition: 'width 1s linear',
            }}
          />
        </div>
      </div>
      {/* Controls */}
      <div style={{ display: 'flex', gap: 10, justifyContent: 'center' }}>
        <button
          onClick={handleStart}
          style={{
            padding: '10px 32px',
            borderRadius: 10,
            border: 'none',
            background: isRunning ? '#E57373' : theme.gold,
            color: '#fff',
            fontFamily: theme.bodyFont,
            fontSize: 14,
            fontWeight: 600,
            cursor: 'pointer',
          }}
        >
          {isRunning ? 'Pause' : secondsLeft < selectedMinutes * 60 && secondsLeft > 0 ? 'Resume' : 'Start'}
        </button>
        <button
          onClick={handleReset}
          style={{
            padding: '10px 24px',
            borderRadius: 10,
            border: '1px solid rgba(0,0,0,0.1)',
            background: 'transparent',
            color: '#888',
            fontFamily: theme.bodyFont,
            fontSize: 14,
            fontWeight: 500,
            cursor: 'pointer',
          }}
        >
          Reset
        </button>
      </div>
      {secondsLeft === 0 && (
        <div
          style={{
            textAlign: 'center',
            marginTop: 16,
            fontFamily: theme.bodyFont,
            fontSize: 15,
            color: theme.gold,
            fontWeight: 600,
          }}
        >
          Session complete. Namaste.
        </div>
      )}
    </div>
  );
};

// ── WidgetGrid ─────────────────────────────────────────────────────────────
const WidgetGrid: React.FC = () => (
  <div
    style={{
      minHeight: '100vh',
      background: theme.bg,
      padding: '32px 24px',
      fontFamily: theme.bodyFont,
    }}
  >
    <h1
      style={{
        fontFamily: theme.headerFont,
        fontSize: 36,
        fontWeight: 600,
        color: theme.text,
        margin: '0 0 28px',
        textAlign: 'center',
      }}
    >
      Your Cosmic Dashboard
    </h1>
    <div
      style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))',
        gap: 20,
        maxWidth: 1200,
        margin: '0 auto',
      }}
    >
      <MoonPhaseWidget />
      <DailyHoroscopeWidget />
      <TransitAlertWidget />
      <JournalStreakWidget />
      <CompatibilityWidget />
      <MeditationTimerWidget />
    </div>
  </div>
);

export default WidgetGrid;
