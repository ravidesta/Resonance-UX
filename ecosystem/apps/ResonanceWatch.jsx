import React, { useState, useEffect, useRef } from 'react';
import {
  Sun, CloudRain, Cloud, Star, Droplets,
  Wind, Heart, Clock, Quote, Bell,
  Play, Pause, RotateCcw, Share2, ChevronRight,
  Sparkles, Moon, Timer, Brain, Flower2
} from 'lucide-react';

// ─── Design Tokens ───────────────────────────────────────────────
const C = {
  forest: { 900: '#0A1C14', 800: '#122E21', 700: '#1B402E', 200: '#D1E0D7', 100: '#E8F0EA' },
  gold:   { 500: '#C5A059', 300: '#E6D0A1', 700: '#9A7A3A' },
  cream:  '#FAFAF8',
  night:  '#05100B',
  watchBg:'#000000',
  watchGrey: '#1C1C1E',
  watchDimText: 'rgba(255,255,255,0.45)',
};

const font = {
  serif: "'Cormorant Garamond', Georgia, serif",
  sans:  "'Manrope', system-ui, sans-serif",
};

// ─── Helpers ─────────────────────────────────────────────────────
const quotes = [
  { text: "The privilege of a lifetime is to become who you truly are.", author: "C.G. Jung" },
  { text: "Between stimulus and response there is a space. In that space is our freedom.", author: "Viktor Frankl" },
  { text: "What you are aware of you are in control of; what you are not aware of is in control of you.", author: "Anthony de Mello" },
];

const coachingPrompts = [
  "What strength served you today?",
  "What are you grateful for right now?",
  "What would make this moment more meaningful?",
  "What pattern are you noticing in yourself lately?",
  "What part of you is asking to be heard?",
];

const breathingPatterns = {
  '4-7-8':      { inhale: 4, hold: 7, exhale: 8, label: '4-7-8 Relaxation' },
  box:          { inhale: 4, hold: 4, exhale: 4, holdAfter: 4, label: 'Box Breathing' },
  coherence:    { inhale: 5, exhale: 5, label: 'Coherence' },
};

const moodOptions = [
  { icon: Sun,      label: 'Sunrise',       sub: 'Energized',   color: '#F5C842' },
  { icon: Droplets, label: 'Gentle Stream', sub: 'Calm',        color: '#7EC8E3' },
  { icon: Cloud,    label: 'Cloudy Sky',    sub: 'Uncertain',   color: '#A0A4A8' },
  { icon: CloudRain,label: 'Storm',         sub: 'Overwhelmed', color: '#6B7B8D' },
  { icon: Star,     label: 'Starlit Night', sub: 'Reflective',  color: '#C5A059' },
];

// ─── Watch Bezel Component ───────────────────────────────────────
function WatchBezel({ children, title }) {
  return (
    <div style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10,
    }}>
      {title && (
        <span style={{
          fontFamily: font.sans, fontSize: 11, letterSpacing: 1.5,
          color: C.gold[500], textTransform: 'uppercase', fontWeight: 600,
        }}>{title}</span>
      )}
      {/* Outer bezel */}
      <div style={{
        width: 210, height: 256, borderRadius: 52,
        background: 'linear-gradient(145deg, #2A2A2E 0%, #1A1A1C 40%, #0F0F10 100%)',
        padding: 6, boxShadow: '0 8px 32px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.08)',
        position: 'relative',
      }}>
        {/* Digital crown */}
        <div style={{
          position: 'absolute', right: -6, top: 70, width: 6, height: 28,
          borderRadius: '0 3px 3px 0',
          background: 'linear-gradient(180deg, #3A3A3C, #2A2A2C)',
          boxShadow: '1px 0 4px rgba(0,0,0,0.4)',
        }} />
        {/* Side button */}
        <div style={{
          position: 'absolute', right: -5, top: 110, width: 5, height: 16,
          borderRadius: '0 2px 2px 0',
          background: 'linear-gradient(180deg, #3A3A3C, #2A2A2C)',
        }} />
        {/* Inner screen */}
        <div style={{
          width: '100%', height: '100%', borderRadius: 48,
          background: C.watchBg, overflow: 'hidden', position: 'relative',
        }}>
          {children}
        </div>
      </div>
    </div>
  );
}

// ─── Screen 1: Watch Face Complication ───────────────────────────
function WatchFaceComplication() {
  const [time, setTime] = useState(new Date());
  useEffect(() => {
    const id = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(id);
  }, []);

  const hrs = time.getHours().toString().padStart(2, '0');
  const mins = time.getMinutes().toString().padStart(2, '0');

  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      justifyContent: 'center', alignItems: 'center', padding: 14, boxSizing: 'border-box',
      background: `radial-gradient(ellipse at 30% 20%, ${C.forest[800]}44 0%, transparent 60%)`,
    }}>
      {/* Time */}
      <div style={{
        fontFamily: font.sans, fontSize: 48, fontWeight: 200,
        color: '#FFFFFF', letterSpacing: -2, lineHeight: 1,
      }}>
        {hrs}<span style={{ color: C.gold[500] }}>:</span>{mins}
      </div>

      {/* Current Intention */}
      <div style={{
        marginTop: 8, padding: '4px 10px', borderRadius: 10,
        background: `${C.forest[700]}66`,
        border: `1px solid ${C.forest[700]}44`,
      }}>
        <span style={{
          fontFamily: font.serif, fontSize: 10, color: C.gold[300],
          fontStyle: 'italic',
        }}>
          "Practice presence today"
        </span>
      </div>

      {/* Complications row */}
      <div style={{
        marginTop: 12, display: 'flex', gap: 14, width: '100%', justifyContent: 'center',
      }}>
        {/* Mindfulness minutes */}
        <div style={{ textAlign: 'center' }}>
          <div style={{ position: 'relative', width: 40, height: 40 }}>
            <svg width={40} height={40} viewBox="0 0 40 40">
              <circle cx={20} cy={20} r={16} fill="none" stroke={C.forest[700]}
                strokeWidth={3} opacity={0.3} />
              <circle cx={20} cy={20} r={16} fill="none" stroke={C.gold[500]}
                strokeWidth={3} strokeDasharray={`${100 * 0.65} 100`}
                strokeLinecap="round"
                transform="rotate(-90 20 20)" />
            </svg>
            <div style={{
              position: 'absolute', inset: 0, display: 'flex',
              alignItems: 'center', justifyContent: 'center',
              fontFamily: font.sans, fontSize: 11, fontWeight: 700, color: '#FFF',
            }}>26</div>
          </div>
          <div style={{
            fontFamily: font.sans, fontSize: 7, color: C.watchDimText,
            marginTop: 2, textTransform: 'uppercase', letterSpacing: 0.5,
          }}>min</div>
        </div>

        {/* Next meditation */}
        <div style={{ textAlign: 'center' }}>
          <div style={{
            width: 40, height: 40, borderRadius: 20,
            background: `${C.forest[700]}55`, display: 'flex',
            alignItems: 'center', justifyContent: 'center',
          }}>
            <Bell size={16} color={C.gold[500]} />
          </div>
          <div style={{
            fontFamily: font.sans, fontSize: 7, color: C.watchDimText,
            marginTop: 2, textTransform: 'uppercase', letterSpacing: 0.5,
          }}>2:30 PM</div>
        </div>

        {/* Streak */}
        <div style={{ textAlign: 'center' }}>
          <div style={{
            width: 40, height: 40, borderRadius: 20,
            background: `${C.forest[700]}55`, display: 'flex',
            alignItems: 'center', justifyContent: 'center',
            flexDirection: 'column',
          }}>
            <Flower2 size={14} color={C.gold[500]} />
            <span style={{ fontFamily: font.sans, fontSize: 9, color: '#FFF', fontWeight: 700 }}>12</span>
          </div>
          <div style={{
            fontFamily: font.sans, fontSize: 7, color: C.watchDimText,
            marginTop: 2, textTransform: 'uppercase', letterSpacing: 0.5,
          }}>days</div>
        </div>
      </div>
    </div>
  );
}

// ─── Screen 2: Glance View ──────────────────────────────────────
function GlanceView() {
  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      padding: 14, boxSizing: 'border-box', gap: 8,
      background: `linear-gradient(170deg, ${C.forest[900]}CC 0%, ${C.watchBg} 50%)`,
    }}>
      {/* Daily quote snippet */}
      <div style={{
        padding: '8px 10px', borderRadius: 12,
        background: `${C.forest[800]}88`,
        border: `1px solid ${C.forest[700]}33`,
      }}>
        <Quote size={10} color={C.gold[500]} style={{ marginBottom: 3 }} />
        <div style={{
          fontFamily: font.serif, fontSize: 10, color: C.cream,
          lineHeight: 1.4, fontStyle: 'italic',
        }}>
          "The privilege of a lifetime is to become who you truly are."
        </div>
        <div style={{
          fontFamily: font.sans, fontSize: 7, color: C.gold[700],
          marginTop: 3, textAlign: 'right',
        }}>— C.G. Jung</div>
      </div>

      {/* Breathing shortcut */}
      <button style={{
        display: 'flex', alignItems: 'center', gap: 8,
        padding: '8px 10px', borderRadius: 12,
        background: `${C.forest[700]}66`, border: `1px solid ${C.gold[500]}22`,
        cursor: 'pointer', width: '100%',
      }}>
        <div style={{
          width: 28, height: 28, borderRadius: 14,
          background: `radial-gradient(circle, ${C.gold[500]}44, ${C.forest[700]}66)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Wind size={13} color={C.gold[300]} />
        </div>
        <div style={{ textAlign: 'left' }}>
          <div style={{ fontFamily: font.sans, fontSize: 10, color: '#FFF', fontWeight: 600 }}>
            Breathe
          </div>
          <div style={{ fontFamily: font.sans, fontSize: 7, color: C.watchDimText }}>
            1 min coherence
          </div>
        </div>
      </button>

      {/* Mood check-in */}
      <button style={{
        display: 'flex', alignItems: 'center', gap: 8,
        padding: '8px 10px', borderRadius: 12,
        background: `${C.forest[700]}66`, border: `1px solid ${C.gold[500]}22`,
        cursor: 'pointer', width: '100%',
      }}>
        <div style={{
          width: 28, height: 28, borderRadius: 14,
          background: `radial-gradient(circle, ${C.gold[500]}44, ${C.forest[700]}66)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <Heart size={13} color={C.gold[300]} />
        </div>
        <div style={{ textAlign: 'left' }}>
          <div style={{ fontFamily: font.sans, fontSize: 10, color: '#FFF', fontWeight: 600 }}>
            Check In
          </div>
          <div style={{ fontFamily: font.sans, fontSize: 7, color: C.watchDimText }}>
            How are you right now?
          </div>
        </div>
      </button>
    </div>
  );
}

// ─── Screen 3: Breathing Exercise ───────────────────────────────
function BreathingExercise() {
  const [pattern, setPattern] = useState('4-7-8');
  const [phase, setPhase] = useState('idle'); // idle | inhale | hold | exhale | holdAfter
  const [progress, setProgress] = useState(0);
  const [isActive, setIsActive] = useState(false);
  const animRef = useRef(null);
  const startRef = useRef(0);

  const pat = breathingPatterns[pattern];

  useEffect(() => {
    if (!isActive) { setPhase('idle'); setProgress(0); return; }
    const phases = [];
    phases.push({ name: 'inhale', dur: pat.inhale });
    if (pat.hold) phases.push({ name: 'hold', dur: pat.hold });
    phases.push({ name: 'exhale', dur: pat.exhale });
    if (pat.holdAfter) phases.push({ name: 'holdAfter', dur: pat.holdAfter });
    const totalCycle = phases.reduce((s, p) => s + p.dur, 0);

    const tick = () => {
      const elapsed = (Date.now() - startRef.current) / 1000;
      const inCycle = elapsed % totalCycle;
      let acc = 0;
      for (const p of phases) {
        if (inCycle < acc + p.dur) {
          setPhase(p.name);
          setProgress((inCycle - acc) / p.dur);
          break;
        }
        acc += p.dur;
      }
      animRef.current = requestAnimationFrame(tick);
    };
    startRef.current = Date.now();
    animRef.current = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(animRef.current);
  }, [isActive, pattern]);

  const circleScale = phase === 'inhale' ? 0.5 + progress * 0.5
    : phase === 'exhale' ? 1.0 - progress * 0.5
    : phase === 'hold' || phase === 'holdAfter' ? (phase === 'hold' ? 1.0 : 0.5)
    : 0.65;

  const phaseLabel = phase === 'idle' ? 'Ready'
    : phase === 'inhale' ? 'Breathe In'
    : phase === 'hold' ? 'Hold'
    : phase === 'exhale' ? 'Breathe Out'
    : 'Hold';

  const pats = Object.keys(breathingPatterns);
  const patIdx = pats.indexOf(pattern);

  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', padding: 10, boxSizing: 'border-box',
      background: `radial-gradient(ellipse at 50% 50%, ${C.forest[800]}66 0%, ${C.watchBg} 70%)`,
    }}>
      {/* Pattern selector */}
      <div style={{
        display: 'flex', gap: 4, marginBottom: 8,
      }}>
        {pats.map((p, i) => (
          <button key={p} onClick={() => { setPattern(p); setIsActive(false); }} style={{
            padding: '2px 6px', borderRadius: 6, border: 'none', cursor: 'pointer',
            background: pattern === p ? C.gold[500] + '44' : 'transparent',
            color: pattern === p ? C.gold[300] : C.watchDimText,
            fontFamily: font.sans, fontSize: 7, fontWeight: 600,
          }}>
            {breathingPatterns[p].label}
          </button>
        ))}
      </div>

      {/* Breathing circle */}
      <div style={{ position: 'relative', width: 100, height: 100 }}>
        {/* Glow rings */}
        {[0.9, 0.75, 0.6].map((op, i) => (
          <div key={i} style={{
            position: 'absolute',
            inset: `${50 - 50 * circleScale - (i + 1) * 6}px`,
            borderRadius: '50%',
            border: `1px solid ${C.gold[500]}`,
            opacity: op * 0.15,
            transition: 'all 0.3s ease',
          }} />
        ))}
        <div style={{
          position: 'absolute',
          inset: `${50 - 50 * circleScale}px`,
          borderRadius: '50%',
          background: `radial-gradient(circle at 40% 35%,
            ${C.gold[500]}55 0%, ${C.forest[700]}88 50%, ${C.forest[900]}CC 100%)`,
          boxShadow: `0 0 ${30 * circleScale}px ${C.gold[500]}33`,
          transition: 'all 0.3s ease',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          {/* Haptic dots around edge */}
          {isActive && Array.from({ length: 8 }).map((_, i) => {
            const angle = (i / 8) * Math.PI * 2 - Math.PI / 2;
            const r = 50 * circleScale - 4;
            return (
              <div key={i} style={{
                position: 'absolute',
                left: 50 * circleScale + Math.cos(angle) * r - 2,
                top: 50 * circleScale + Math.sin(angle) * r - 2,
                width: 4, height: 4, borderRadius: 2,
                background: C.gold[500],
                opacity: (i / 8 <= progress && isActive) ? 0.8 : 0.15,
                transition: 'opacity 0.2s',
              }} />
            );
          })}
        </div>
      </div>

      {/* Phase label */}
      <div style={{
        fontFamily: font.serif, fontSize: 13, color: C.gold[300],
        marginTop: 8, fontStyle: 'italic',
      }}>{phaseLabel}</div>

      {/* Play/Pause */}
      <button onClick={() => setIsActive(!isActive)} style={{
        marginTop: 8, width: 32, height: 32, borderRadius: 16,
        background: C.gold[500] + '33', border: `1px solid ${C.gold[500]}55`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer',
      }}>
        {isActive ? <Pause size={14} color={C.gold[300]} /> : <Play size={14} color={C.gold[300]} />}
      </button>
    </div>
  );
}

// ─── Screen 4: Quick Check-in ───────────────────────────────────
function QuickCheckIn() {
  const [selected, setSelected] = useState(null);

  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      alignItems: 'center', padding: '12px 10px', boxSizing: 'border-box',
      background: `radial-gradient(ellipse at 50% 0%, ${C.forest[800]}44 0%, ${C.watchBg} 60%)`,
    }}>
      <div style={{
        fontFamily: font.serif, fontSize: 11, color: C.cream,
        marginBottom: 6, textAlign: 'center', fontStyle: 'italic',
      }}>How are you right now?</div>

      <div style={{
        display: 'flex', flexDirection: 'column', gap: 5, width: '100%',
        overflowY: 'auto', flex: 1,
      }}>
        {moodOptions.map((m, i) => {
          const Icon = m.icon;
          const isSel = selected === i;
          return (
            <button key={i} onClick={() => setSelected(i)} style={{
              display: 'flex', alignItems: 'center', gap: 8,
              padding: '5px 8px', borderRadius: 10,
              background: isSel ? `${m.color}22` : `${C.forest[800]}88`,
              border: isSel ? `1px solid ${m.color}66` : `1px solid ${C.forest[700]}33`,
              cursor: 'pointer', width: '100%',
              transition: 'all 0.2s',
            }}>
              <Icon size={14} color={m.color} />
              <div style={{ textAlign: 'left' }}>
                <div style={{
                  fontFamily: font.sans, fontSize: 9, color: '#FFF', fontWeight: 600,
                }}>{m.label}</div>
                <div style={{
                  fontFamily: font.sans, fontSize: 7, color: C.watchDimText,
                }}>{m.sub}</div>
              </div>
            </button>
          );
        })}
      </div>

      {selected !== null && (
        <div style={{
          fontFamily: font.sans, fontSize: 7, color: C.gold[500],
          marginTop: 4, display: 'flex', alignItems: 'center', gap: 3,
        }}>
          <Sparkles size={8} /> Synced to Journal
        </div>
      )}
    </div>
  );
}

// ─── Screen 5: Coaching Nudge ───────────────────────────────────
function CoachingNudge() {
  const [idx, setIdx] = useState(0);
  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', padding: 16, boxSizing: 'border-box',
      background: `radial-gradient(ellipse at 50% 30%, ${C.gold[500]}11 0%, ${C.watchBg} 60%)`,
    }}>
      <Brain size={20} color={C.gold[500]} style={{ marginBottom: 10 }} />

      <div style={{
        fontFamily: font.serif, fontSize: 13, color: C.cream,
        textAlign: 'center', lineHeight: 1.5, fontStyle: 'italic',
        minHeight: 50, display: 'flex', alignItems: 'center',
      }}>
        "{coachingPrompts[idx]}"
      </div>

      <div style={{
        fontFamily: font.sans, fontSize: 7, color: C.gold[700],
        marginTop: 6, textTransform: 'uppercase', letterSpacing: 1,
      }}>Appreciative Inquiry</div>

      <button onClick={() => setIdx((idx + 1) % coachingPrompts.length)} style={{
        marginTop: 10, padding: '4px 12px', borderRadius: 10,
        background: C.gold[500] + '22', border: `1px solid ${C.gold[500]}44`,
        cursor: 'pointer',
        fontFamily: font.sans, fontSize: 8, color: C.gold[300], fontWeight: 600,
        display: 'flex', alignItems: 'center', gap: 4,
      }}>
        Next <ChevronRight size={10} />
      </button>
    </div>
  );
}

// ─── Screen 6: Meditation Timer ─────────────────────────────────
function MeditationTimer() {
  const [duration, setDuration] = useState(300);
  const [remaining, setRemaining] = useState(300);
  const [isRunning, setIsRunning] = useState(false);
  const [sessions, setSessions] = useState(47);

  useEffect(() => {
    if (!isRunning || remaining <= 0) return;
    const id = setInterval(() => setRemaining(r => r - 1), 1000);
    return () => clearInterval(id);
  }, [isRunning, remaining]);

  const mins = Math.floor(remaining / 60).toString().padStart(2, '0');
  const secs = (remaining % 60).toString().padStart(2, '0');
  const pct = 1 - remaining / duration;

  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', padding: 14, boxSizing: 'border-box',
      background: C.watchBg,
    }}>
      {/* Timer ring */}
      <div style={{ position: 'relative', width: 110, height: 110 }}>
        <svg width={110} height={110} viewBox="0 0 110 110">
          <circle cx={55} cy={55} r={48} fill="none" stroke={C.forest[700]}
            strokeWidth={4} opacity={0.3} />
          <circle cx={55} cy={55} r={48} fill="none" stroke={C.gold[500]}
            strokeWidth={4}
            strokeDasharray={`${301.6 * pct} 301.6`}
            strokeLinecap="round"
            transform="rotate(-90 55 55)"
            style={{ transition: 'stroke-dasharray 1s linear' }} />
        </svg>
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{
            fontFamily: font.sans, fontSize: 28, fontWeight: 300,
            color: '#FFF', letterSpacing: -1,
          }}>{mins}:{secs}</div>
          <div style={{
            fontFamily: font.sans, fontSize: 7, color: C.watchDimText,
            textTransform: 'uppercase', letterSpacing: 1,
          }}>
            {isRunning ? 'meditating' : 'ready'}
          </div>
        </div>
      </div>

      {/* Controls */}
      <div style={{ display: 'flex', gap: 12, marginTop: 10 }}>
        <button onClick={() => { setRemaining(duration); setIsRunning(false); }} style={{
          width: 28, height: 28, borderRadius: 14,
          background: `${C.forest[700]}66`, border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <RotateCcw size={12} color={C.watchDimText} />
        </button>
        <button onClick={() => setIsRunning(!isRunning)} style={{
          width: 36, height: 36, borderRadius: 18,
          background: C.gold[500] + '33', border: `1px solid ${C.gold[500]}55`,
          cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          {isRunning ? <Pause size={16} color={C.gold[300]} /> : <Play size={16} color={C.gold[300]} />}
        </button>
      </div>

      {/* Session count */}
      <div style={{
        marginTop: 8, fontFamily: font.sans, fontSize: 7,
        color: C.watchDimText, display: 'flex', alignItems: 'center', gap: 3,
      }}>
        <Timer size={8} /> {sessions} sessions this month
      </div>
    </div>
  );
}

// ─── Screen 7: Daily Quote ──────────────────────────────────────
function DailyQuote() {
  const today = new Date().getDate() % quotes.length;
  const q = quotes[today];

  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', padding: 16, boxSizing: 'border-box',
      background: `radial-gradient(ellipse at 50% 40%, ${C.forest[800]}55 0%, ${C.watchBg} 70%)`,
    }}>
      <Quote size={16} color={C.gold[500]} style={{ marginBottom: 8, opacity: 0.7 }} />

      <div style={{
        fontFamily: font.serif, fontSize: 12, color: C.cream,
        textAlign: 'center', lineHeight: 1.6, fontStyle: 'italic',
      }}>
        "{q.text}"
      </div>

      <div style={{
        fontFamily: font.sans, fontSize: 8, color: C.gold[700],
        marginTop: 8,
      }}>— {q.author}</div>

      <button style={{
        marginTop: 12, padding: '4px 10px', borderRadius: 8,
        background: `${C.forest[700]}66`, border: `1px solid ${C.gold[500]}22`,
        cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4,
        fontFamily: font.sans, fontSize: 7, color: C.gold[300],
      }}>
        <Share2 size={8} /> Share
      </button>
    </div>
  );
}

// ─── Screen 8: Notification Previews ────────────────────────────
function NotificationPreviews() {
  const notifications = [
    { icon: Wind, title: 'Mindfulness Reminder', body: 'Take 3 conscious breaths', time: '2m ago', color: C.gold[500] },
    { icon: Brain, title: 'Coaching Prompt', body: 'What are you grateful for right now?', time: '1h ago', color: C.gold[300] },
    { icon: Moon, title: 'Evening Meditation', body: 'Your 10-min session is ready', time: '3h ago', color: C.forest[200] },
    { icon: Sparkles, title: 'Streak Milestone', body: '12 days of practice!', time: '5h ago', color: '#F5C842' },
  ];

  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', flexDirection: 'column',
      padding: '10px 8px', boxSizing: 'border-box', gap: 5,
      overflowY: 'auto',
    }}>
      <div style={{
        fontFamily: font.sans, fontSize: 8, color: C.watchDimText,
        textTransform: 'uppercase', letterSpacing: 1, marginBottom: 2,
        textAlign: 'center',
      }}>Notifications</div>

      {notifications.map((n, i) => {
        const Icon = n.icon;
        return (
          <div key={i} style={{
            display: 'flex', gap: 6, padding: '6px 7px', borderRadius: 10,
            background: `${C.forest[800]}88`,
            border: `1px solid ${C.forest[700]}22`,
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: 6,
              background: `${C.forest[700]}88`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0,
            }}>
              <Icon size={11} color={n.color} />
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{
                display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
              }}>
                <span style={{
                  fontFamily: font.sans, fontSize: 8, color: '#FFF', fontWeight: 600,
                }}>{n.title}</span>
                <span style={{
                  fontFamily: font.sans, fontSize: 6, color: C.watchDimText,
                }}>{n.time}</span>
              </div>
              <div style={{
                fontFamily: font.sans, fontSize: 7, color: C.watchDimText,
                marginTop: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis',
              }}>{n.body}</div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

// ─── Main Export ─────────────────────────────────────────────────
export default function ResonanceWatch() {
  const screens = [
    { component: WatchFaceComplication, title: 'Watch Face' },
    { component: GlanceView, title: 'Glance' },
    { component: BreathingExercise, title: 'Breathing' },
    { component: QuickCheckIn, title: 'Quick Check-In' },
    { component: CoachingNudge, title: 'Coaching Nudge' },
    { component: MeditationTimer, title: 'Meditation Timer' },
    { component: DailyQuote, title: 'Daily Quote' },
    { component: NotificationPreviews, title: 'Notifications' },
  ];

  return (
    <div style={{
      minHeight: '100vh',
      background: `linear-gradient(170deg, ${C.night} 0%, #0A1510 40%, ${C.night} 100%)`,
      padding: '48px 24px',
      boxSizing: 'border-box',
    }}>
      {/* Header */}
      <div style={{ textAlign: 'center', marginBottom: 48 }}>
        <div style={{
          fontFamily: font.sans, fontSize: 11, letterSpacing: 4,
          color: C.gold[500], textTransform: 'uppercase', marginBottom: 8,
          fontWeight: 600,
        }}>
          Resonance
        </div>
        <h1 style={{
          fontFamily: font.serif, fontSize: 36, fontWeight: 300,
          color: C.cream, margin: 0, lineHeight: 1.2,
        }}>
          Apple Watch
        </h1>
        <p style={{
          fontFamily: font.sans, fontSize: 13, color: C.watchDimText,
          marginTop: 8, maxWidth: 420, marginLeft: 'auto', marginRight: 'auto',
        }}>
          Mindfulness on your wrist. Breathing exercises, coaching nudges,
          and meditation — always within reach.
        </p>
      </div>

      {/* Watch grid */}
      <div style={{
        display: 'flex', flexWrap: 'wrap', justifyContent: 'center',
        gap: 40, maxWidth: 1100, margin: '0 auto',
      }}>
        {screens.map((s, i) => {
          const Screen = s.component;
          return (
            <WatchBezel key={i} title={s.title}>
              <Screen />
            </WatchBezel>
          );
        })}
      </div>

      {/* Footer */}
      <div style={{
        textAlign: 'center', marginTop: 56,
        fontFamily: font.sans, fontSize: 10, color: C.watchDimText,
        letterSpacing: 1,
      }}>
        LUMINOUS EGO DEVELOPMENT &middot; watchOS
      </div>
    </div>
  );
}
