import React, { useState, useEffect, useRef, useCallback } from 'react';
import GlassPanel from '../components/GlassPanel';
import { useTheme } from '../hooks/useTheme';

interface MeditationStep {
  id: number;
  title: string;
  instruction: string;
  duration: number; // seconds
  breathPattern?: { inhale: number; hold: number; exhale: number; pause: number };
}

const STARGAZER_STEPS: MeditationStep[] = [
  {
    id: 1,
    title: 'Grounding',
    instruction:
      'Find a comfortable position. Close your eyes and feel the earth beneath you, solid and ancient. Imagine roots extending from the base of your spine deep into the ground, anchoring you.',
    duration: 60,
    breathPattern: { inhale: 4, hold: 2, exhale: 6, pause: 2 },
  },
  {
    id: 2,
    title: 'Opening the Inner Eye',
    instruction:
      'Bring your awareness to the space between your eyebrows. Imagine a soft golden light beginning to glow there, warm and inviting. With each breath, this light grows brighter.',
    duration: 90,
    breathPattern: { inhale: 4, hold: 4, exhale: 4, pause: 4 },
  },
  {
    id: 3,
    title: 'Ascending to the Stars',
    instruction:
      'Feel yourself rising upward, carried by the golden light. You pass through layers of sky -- dawn pinks, twilight purples, into the deep velvet of space. Stars surround you, each one singing a silent note.',
    duration: 120,
    breathPattern: { inhale: 5, hold: 3, exhale: 7, pause: 3 },
  },
  {
    id: 4,
    title: 'Meeting Your Celestial Blueprint',
    instruction:
      'Before you, a great mandala of light appears -- your natal chart, alive and pulsing. Each planet glows with its own color. The lines between them shimmer like threads of cosmic silk. Simply observe. What draws your attention?',
    duration: 120,
  },
  {
    id: 5,
    title: 'Receiving the Message',
    instruction:
      'One planet glows brighter than the rest, calling to you. Move toward it. As you approach, you feel its energy and hear its whisper. What does it have to tell you? Listen without judgment. Accept whatever arises.',
    duration: 90,
  },
  {
    id: 6,
    title: 'Integration',
    instruction:
      'The mandala begins to fold inward, its light streaming into your heart center. You carry this celestial wisdom within you. Feel the warmth of the stars in your chest, a gentle reminder that you are part of the cosmos.',
    duration: 60,
    breathPattern: { inhale: 4, hold: 2, exhale: 6, pause: 2 },
  },
  {
    id: 7,
    title: 'Return',
    instruction:
      'Gently descend back through the layers of sky. Feel the earth beneath you once more. Wiggle your fingers and toes. When you are ready, open your eyes, bringing the starlight back with you.',
    duration: 45,
    breathPattern: { inhale: 4, hold: 2, exhale: 4, pause: 2 },
  },
];

type SessionState = 'idle' | 'playing' | 'paused' | 'complete';

const MeditationPage: React.FC = () => {
  const { isDark } = useTheme();
  const [sessionState, setSessionState] = useState<SessionState>('idle');
  const [currentStepIndex, setCurrentStepIndex] = useState(0);
  const [timeRemaining, setTimeRemaining] = useState(0);
  const [breathPhase, setBreathPhase] = useState<'inhale' | 'hold' | 'exhale' | 'pause'>('inhale');
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const breathTimerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const currentStep = STARGAZER_STEPS[currentStepIndex];
  const totalDuration = STARGAZER_STEPS.reduce((sum, s) => sum + s.duration, 0);
  const elapsed = STARGAZER_STEPS.slice(0, currentStepIndex).reduce(
    (sum, s) => sum + s.duration,
    0
  ) + (currentStep ? currentStep.duration - timeRemaining : 0);
  const progressPercent = (elapsed / totalDuration) * 100;

  const clearTimers = useCallback(() => {
    if (timerRef.current) clearInterval(timerRef.current);
    if (breathTimerRef.current) clearInterval(breathTimerRef.current);
    timerRef.current = null;
    breathTimerRef.current = null;
  }, []);

  const startBreathCycle = useCallback((pattern: MeditationStep['breathPattern']) => {
    if (!pattern) return;
    if (breathTimerRef.current) clearInterval(breathTimerRef.current);

    const phases: Array<{ phase: typeof breathPhase; duration: number }> = [
      { phase: 'inhale', duration: pattern.inhale },
      { phase: 'hold', duration: pattern.hold },
      { phase: 'exhale', duration: pattern.exhale },
      { phase: 'pause', duration: pattern.pause },
    ];

    let phaseIndex = 0;
    let phaseTime = 0;

    setBreathPhase(phases[0].phase);

    breathTimerRef.current = setInterval(() => {
      phaseTime++;
      if (phaseTime >= phases[phaseIndex].duration) {
        phaseTime = 0;
        phaseIndex = (phaseIndex + 1) % phases.length;
        setBreathPhase(phases[phaseIndex].phase);
      }
    }, 1000);
  }, []);

  const startSession = useCallback(() => {
    setSessionState('playing');
    setCurrentStepIndex(0);
    setTimeRemaining(STARGAZER_STEPS[0].duration);

    if (STARGAZER_STEPS[0].breathPattern) {
      startBreathCycle(STARGAZER_STEPS[0].breathPattern);
    }
  }, [startBreathCycle]);

  // Main timer
  useEffect(() => {
    if (sessionState !== 'playing') {
      clearTimers();
      return;
    }

    timerRef.current = setInterval(() => {
      setTimeRemaining((prev) => {
        if (prev <= 1) {
          // Move to next step
          const nextIndex = currentStepIndex + 1;
          if (nextIndex >= STARGAZER_STEPS.length) {
            clearTimers();
            setSessionState('complete');
            return 0;
          }
          setCurrentStepIndex(nextIndex);
          const nextStep = STARGAZER_STEPS[nextIndex];
          if (nextStep.breathPattern) {
            startBreathCycle(nextStep.breathPattern);
          } else if (breathTimerRef.current) {
            clearInterval(breathTimerRef.current);
            breathTimerRef.current = null;
          }
          return nextStep.duration;
        }
        return prev - 1;
      });
    }, 1000);

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [sessionState, currentStepIndex, clearTimers, startBreathCycle]);

  const togglePause = () => {
    setSessionState((s) => (s === 'playing' ? 'paused' : 'playing'));
  };

  const resetSession = () => {
    clearTimers();
    setSessionState('idle');
    setCurrentStepIndex(0);
    setTimeRemaining(0);
  };

  const formatTime = (s: number) => {
    const min = Math.floor(s / 60);
    const sec = s % 60;
    return `${min}:${sec.toString().padStart(2, '0')}`;
  };

  const breathLabel: Record<string, string> = {
    inhale: 'Breathe In',
    hold: 'Hold',
    exhale: 'Breathe Out',
    pause: 'Rest',
  };

  return (
    <div
      style={{
        padding: '1.5rem 1rem 6rem',
        maxWidth: '600px',
        margin: '0 auto',
        width: '100%',
      }}
    >
      {/* Header */}
      <header
        style={{
          marginBottom: '2rem',
          animation: 'fadeInUp 500ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
        }}
      >
        <h1
          style={{
            fontFamily: "'Cormorant Garamond', serif",
            fontSize: '1.75rem',
            fontWeight: 500,
            marginBottom: '0.25rem',
          }}
        >
          Stargazer&apos;s Attunement
        </h1>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-tertiary)', margin: 0 }}>
          A guided cosmic meditation &middot; {Math.ceil(totalDuration / 60)} minutes
        </p>
      </header>

      {/* Idle / Start screen */}
      {sessionState === 'idle' && (
        <div
          style={{
            textAlign: 'center',
            animation: 'fadeInScale 600ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
          }}
        >
          <GlassPanel glow padding="2.5rem 2rem" borderRadius="1.5rem">
            {/* Breathing orb preview */}
            <div
              style={{
                width: '120px',
                height: '120px',
                margin: '0 auto 2rem',
                borderRadius: '50%',
                background: `radial-gradient(circle, ${
                  isDark ? 'rgba(197, 160, 89, 0.3)' : 'rgba(197, 160, 89, 0.2)'
                }, ${isDark ? 'rgba(27, 64, 46, 0.2)' : 'rgba(27, 64, 46, 0.1)'})`,
                animation: 'breathe 8s ease-in-out infinite',
                boxShadow: '0 0 40px rgba(197, 160, 89, 0.15)',
              }}
            />

            <h2
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1.5rem',
                fontWeight: 500,
                marginBottom: '1rem',
              }}
            >
              Journey to Your Stars
            </h2>
            <p
              style={{
                fontSize: '0.9rem',
                color: 'var(--text-secondary)',
                lineHeight: 1.7,
                marginBottom: '2rem',
                maxWidth: '360px',
                margin: '0 auto 2rem',
              }}
            >
              This guided meditation will lead you through a visualization of ascending to the stars
              and meeting your natal chart as a living mandala of light.
            </p>

            {/* Steps preview */}
            <div
              style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '0.5rem',
                justifyContent: 'center',
                marginBottom: '2rem',
              }}
            >
              {STARGAZER_STEPS.map((s) => (
                <span
                  key={s.id}
                  style={{
                    fontSize: '0.7rem',
                    color: 'var(--text-tertiary)',
                    padding: '0.25rem 0.5rem',
                    borderRadius: '9999px',
                    border: '1px solid var(--border-subtle)',
                  }}
                >
                  {s.title}
                </span>
              ))}
            </div>

            <button
              onClick={startSession}
              style={{
                padding: '0.85rem 2.5rem',
                borderRadius: '9999px',
                background: 'linear-gradient(135deg, #C5A059, #9A7A3A)',
                color: '#FAFAF8',
                fontWeight: 600,
                fontSize: '1rem',
                letterSpacing: '0.05em',
                boxShadow: '0 4px 20px rgba(154, 122, 58, 0.35)',
                transition: 'transform 200ms cubic-bezier(0.34, 1.56, 0.64, 1)',
              }}
              onMouseEnter={(e) => {
                (e.target as HTMLElement).style.transform = 'scale(1.05)';
              }}
              onMouseLeave={(e) => {
                (e.target as HTMLElement).style.transform = 'scale(1)';
              }}
            >
              Begin Meditation
            </button>
          </GlassPanel>
        </div>
      )}

      {/* Playing / Paused state */}
      {(sessionState === 'playing' || sessionState === 'paused') && currentStep && (
        <div style={{ animation: 'fadeIn 500ms ease both' }}>
          {/* Progress bar */}
          <div
            style={{
              width: '100%',
              height: '3px',
              background: 'var(--border-subtle)',
              borderRadius: '2px',
              marginBottom: '2rem',
              overflow: 'hidden',
            }}
          >
            <div
              style={{
                width: `${progressPercent}%`,
                height: '100%',
                background: 'linear-gradient(90deg, #9A7A3A, #C5A059)',
                borderRadius: '2px',
                transition: 'width 1s linear',
              }}
            />
          </div>

          {/* Step indicator */}
          <div
            style={{
              display: 'flex',
              gap: '0.35rem',
              marginBottom: '2rem',
              justifyContent: 'center',
            }}
          >
            {STARGAZER_STEPS.map((_, i) => (
              <div
                key={i}
                style={{
                  width: i === currentStepIndex ? '24px' : '8px',
                  height: '8px',
                  borderRadius: '4px',
                  background:
                    i < currentStepIndex
                      ? 'var(--gold-600, #C5A059)'
                      : i === currentStepIndex
                      ? 'var(--gold-400, #E6D0A1)'
                      : 'var(--sage-300, #A8B8AD)',
                  transition: 'all 500ms cubic-bezier(0.34, 1.56, 0.64, 1)',
                }}
              />
            ))}
          </div>

          {/* Main content */}
          <GlassPanel
            glow
            padding="2rem"
            borderRadius="1.5rem"
            style={{ textAlign: 'center', marginBottom: '1.5rem' }}
          >
            {/* Breathing orb (only if breath pattern active) */}
            {currentStep.breathPattern && (
              <div style={{ marginBottom: '1.5rem' }}>
                <div
                  style={{
                    width: '100px',
                    height: '100px',
                    margin: '0 auto',
                    borderRadius: '50%',
                    background: `radial-gradient(circle, ${
                      isDark ? 'rgba(197, 160, 89, 0.35)' : 'rgba(197, 160, 89, 0.25)'
                    }, transparent)`,
                    transform:
                      breathPhase === 'inhale' || breathPhase === 'hold'
                        ? 'scale(1.2)'
                        : 'scale(0.85)',
                    transition: `transform ${
                      breathPhase === 'inhale'
                        ? currentStep.breathPattern.inhale
                        : breathPhase === 'exhale'
                        ? currentStep.breathPattern.exhale
                        : 0.5
                    }s ease-in-out`,
                    boxShadow: '0 0 30px rgba(197, 160, 89, 0.2)',
                  }}
                />
                <div
                  style={{
                    marginTop: '1rem',
                    fontSize: '1rem',
                    fontWeight: 500,
                    color: 'var(--text-accent)',
                    letterSpacing: '0.1em',
                    textTransform: 'uppercase',
                    fontFamily: "'Cormorant Garamond', serif",
                  }}
                >
                  {breathLabel[breathPhase]}
                </div>
              </div>
            )}

            {/* Step title */}
            <div
              style={{
                fontSize: '0.7rem',
                color: 'var(--text-accent)',
                textTransform: 'uppercase',
                letterSpacing: '0.15em',
                fontWeight: 600,
                marginBottom: '0.5rem',
              }}
            >
              Step {currentStep.id} of {STARGAZER_STEPS.length}
            </div>
            <h2
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1.5rem',
                fontWeight: 500,
                marginBottom: '1rem',
              }}
            >
              {currentStep.title}
            </h2>
            <p
              style={{
                fontSize: '0.95rem',
                color: 'var(--text-secondary)',
                lineHeight: 1.8,
                margin: 0,
              }}
            >
              {currentStep.instruction}
            </p>
          </GlassPanel>

          {/* Timer & controls */}
          <div style={{ textAlign: 'center' }}>
            <div
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '2rem',
                fontWeight: 300,
                color: 'var(--text-accent)',
                marginBottom: '1rem',
                letterSpacing: '0.1em',
              }}
            >
              {formatTime(timeRemaining)}
            </div>
            <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
              <button
                onClick={togglePause}
                style={{
                  padding: '0.65rem 1.75rem',
                  borderRadius: '9999px',
                  background: 'linear-gradient(135deg, #C5A059, #9A7A3A)',
                  color: '#FAFAF8',
                  fontWeight: 600,
                  fontSize: '0.9rem',
                  boxShadow: '0 4px 16px rgba(154, 122, 58, 0.3)',
                }}
              >
                {sessionState === 'playing' ? 'Pause' : 'Resume'}
              </button>
              <button
                onClick={resetSession}
                style={{
                  padding: '0.65rem 1.25rem',
                  borderRadius: '9999px',
                  color: 'var(--text-tertiary)',
                  fontSize: '0.85rem',
                  fontWeight: 500,
                  border: '1px solid var(--border-subtle)',
                }}
              >
                End
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Complete state */}
      {sessionState === 'complete' && (
        <div
          style={{
            textAlign: 'center',
            animation: 'fadeInScale 600ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
          }}
        >
          <GlassPanel glow padding="2.5rem 2rem" borderRadius="1.5rem">
            <div
              style={{
                fontSize: '3rem',
                marginBottom: '1rem',
                animation: 'float 3s ease-in-out infinite',
              }}
            >
              &#10022;
            </div>
            <h2
              style={{
                fontFamily: "'Cormorant Garamond', serif",
                fontSize: '1.75rem',
                fontWeight: 500,
                marginBottom: '0.75rem',
              }}
            >
              Meditation Complete
            </h2>
            <p
              style={{
                fontSize: '0.95rem',
                color: 'var(--text-secondary)',
                lineHeight: 1.7,
                marginBottom: '2rem',
                maxWidth: '360px',
                margin: '0 auto 2rem',
              }}
            >
              You have journeyed to the stars and returned with their wisdom.
              Carry this celestial light with you throughout your day.
            </p>
            <button
              onClick={resetSession}
              style={{
                padding: '0.75rem 2rem',
                borderRadius: '9999px',
                background: 'linear-gradient(135deg, #C5A059, #9A7A3A)',
                color: '#FAFAF8',
                fontWeight: 600,
                fontSize: '0.95rem',
                boxShadow: '0 4px 16px rgba(154, 122, 58, 0.3)',
              }}
            >
              Return Home
            </button>
          </GlassPanel>
        </div>
      )}
    </div>
  );
};

export default MeditationPage;
