import React, { useState, useCallback, type CSSProperties } from 'react';
import { useNavigate } from 'react-router-dom';
import GlassPanel from '../components/GlassPanel';
import type { BirthData } from '../types/astrology';

type OnboardingStep = 'welcome' | 'name' | 'birthdate' | 'birthtime' | 'birthplace' | 'calculating' | 'complete';

const STEPS: OnboardingStep[] = ['welcome', 'name', 'birthdate', 'birthtime', 'birthplace', 'calculating', 'complete'];

const OnboardingPage: React.FC = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState<OnboardingStep>('welcome');
  const [direction, setDirection] = useState<'forward' | 'back'>('forward');
  const [birthData, setBirthData] = useState<Partial<BirthData>>({
    name: '',
    birthDate: '',
    birthTime: '',
    birthPlace: '',
    latitude: 40.7128,
    longitude: -74.006,
    timezone: 'America/New_York',
  });

  const stepIndex = STEPS.indexOf(step);

  const goNext = useCallback(() => {
    if (stepIndex < STEPS.length - 1) {
      setDirection('forward');
      const nextStep = STEPS[stepIndex + 1];
      setStep(nextStep);

      if (nextStep === 'calculating') {
        setTimeout(() => {
          setDirection('forward');
          setStep('complete');
        }, 2500);
      }
    }
  }, [stepIndex]);

  const goBack = useCallback(() => {
    if (stepIndex > 0) {
      setDirection('back');
      setStep(STEPS[stepIndex - 1]);
    }
  }, [stepIndex]);

  const handleComplete = () => {
    const fullData: BirthData = {
      name: birthData.name || 'Cosmic Traveler',
      birthDate: birthData.birthDate || '1990-01-01',
      birthTime: birthData.birthTime || '12:00',
      birthPlace: birthData.birthPlace || 'New York, NY',
      latitude: birthData.latitude || 40.7128,
      longitude: birthData.longitude || -74.006,
      timezone: birthData.timezone || 'America/New_York',
    };
    localStorage.setItem('lca-birth-data', JSON.stringify(fullData));
    localStorage.setItem('lca-onboarding-complete', 'true');
    navigate('/dashboard');
  };

  const slideAnimation: CSSProperties = {
    animation: `${direction === 'forward' ? 'slideInRight' : 'slideInLeft'} 500ms cubic-bezier(0.34, 1.56, 0.64, 1) both`,
  };

  const containerStyle: CSSProperties = {
    minHeight: '100dvh',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    padding: '2rem 1.5rem',
    position: 'relative',
  };

  const headingStyle: CSSProperties = {
    fontFamily: "'Cormorant Garamond', serif",
    color: 'var(--text-primary)',
    textAlign: 'center',
    marginBottom: '0.5rem',
  };

  const subtextStyle: CSSProperties = {
    color: 'var(--text-secondary)',
    textAlign: 'center',
    fontSize: '0.95rem',
    lineHeight: 1.6,
    maxWidth: '380px',
    margin: '0 auto 2rem',
  };

  const inputStyle: CSSProperties = {
    width: '100%',
    maxWidth: '320px',
    display: 'block',
    margin: '0 auto 1.5rem',
  };

  const btnPrimary: CSSProperties = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '0.75rem 2rem',
    borderRadius: '9999px',
    background: 'linear-gradient(135deg, #C5A059, #9A7A3A)',
    color: '#FAFAF8',
    fontWeight: 600,
    fontSize: '0.95rem',
    letterSpacing: '0.05em',
    boxShadow: '0 4px 16px rgba(154, 122, 58, 0.3)',
    transition: 'transform 200ms cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 200ms ease',
    minWidth: '160px',
  };

  const btnSecondary: CSSProperties = {
    padding: '0.6rem 1.25rem',
    color: 'var(--text-tertiary)',
    fontSize: '0.85rem',
    fontWeight: 500,
  };

  // Progress dots
  const progressDots = (
    <div
      style={{
        display: 'flex',
        gap: '0.5rem',
        justifyContent: 'center',
        marginBottom: '2rem',
      }}
    >
      {STEPS.filter((s) => s !== 'calculating' && s !== 'complete').map((s, i) => (
        <div
          key={s}
          style={{
            width: '8px',
            height: '8px',
            borderRadius: '50%',
            background:
              i <= STEPS.indexOf(step)
                ? 'var(--gold-600, #C5A059)'
                : 'var(--sage-300, #A8B8AD)',
            transition: 'background 350ms ease, transform 350ms cubic-bezier(0.34, 1.56, 0.64, 1)',
            transform: STEPS.indexOf(step) === i ? 'scale(1.3)' : 'scale(1)',
          }}
        />
      ))}
    </div>
  );

  return (
    <div style={containerStyle}>
      {step !== 'welcome' && step !== 'calculating' && step !== 'complete' && progressDots}

      {/* Welcome */}
      {step === 'welcome' && (
        <div key="welcome" style={{ ...slideAnimation, textAlign: 'center', maxWidth: '440px' }}>
          <div
            style={{
              fontSize: '3rem',
              marginBottom: '1rem',
              animation: 'float 3s ease-in-out infinite',
            }}
          >
            &#10022;
          </div>
          <h1 style={{ ...headingStyle, fontSize: '2.25rem', marginBottom: '0.75rem' }}>
            Luminous Cosmic
            <br />
            Architecture&trade;
          </h1>
          <p style={subtextStyle}>
            Welcome to your personal astrology developmental map. Discover the
            celestial blueprint woven into the moment of your birth.
          </p>
          <button
            style={btnPrimary}
            onClick={goNext}
            onMouseEnter={(e) => {
              (e.target as HTMLElement).style.transform = 'scale(1.05)';
            }}
            onMouseLeave={(e) => {
              (e.target as HTMLElement).style.transform = 'scale(1)';
            }}
          >
            Begin Your Journey
          </button>
        </div>
      )}

      {/* Name */}
      {step === 'name' && (
        <div key="name" style={{ ...slideAnimation, textAlign: 'center', width: '100%', maxWidth: '440px' }}>
          <h2 style={{ ...headingStyle, fontSize: '1.75rem' }}>What shall we call you?</h2>
          <p style={subtextStyle}>Your name carries its own vibration in the cosmic tapestry.</p>
          <input
            type="text"
            placeholder="Your name"
            value={birthData.name || ''}
            onChange={(e) => setBirthData({ ...birthData, name: e.target.value })}
            style={inputStyle}
            autoFocus
          />
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <button style={btnSecondary} onClick={goBack}>Back</button>
            <button style={btnPrimary} onClick={goNext}>Continue</button>
          </div>
        </div>
      )}

      {/* Birth Date */}
      {step === 'birthdate' && (
        <div key="birthdate" style={{ ...slideAnimation, textAlign: 'center', width: '100%', maxWidth: '440px' }}>
          <h2 style={{ ...headingStyle, fontSize: '1.75rem' }}>When were you born?</h2>
          <p style={subtextStyle}>
            The position of the stars at your birth moment creates your unique celestial signature.
          </p>
          <input
            type="date"
            value={birthData.birthDate || ''}
            onChange={(e) => setBirthData({ ...birthData, birthDate: e.target.value })}
            style={inputStyle}
          />
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <button style={btnSecondary} onClick={goBack}>Back</button>
            <button style={btnPrimary} onClick={goNext}>Continue</button>
          </div>
        </div>
      )}

      {/* Birth Time */}
      {step === 'birthtime' && (
        <div key="birthtime" style={{ ...slideAnimation, textAlign: 'center', width: '100%', maxWidth: '440px' }}>
          <h2 style={{ ...headingStyle, fontSize: '1.75rem' }}>What time were you born?</h2>
          <p style={subtextStyle}>
            The exact time determines your Rising sign and house placements -- the framework of your chart.
          </p>
          <input
            type="time"
            value={birthData.birthTime || ''}
            onChange={(e) => setBirthData({ ...birthData, birthTime: e.target.value })}
            style={inputStyle}
          />
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <button style={btnSecondary} onClick={goBack}>Back</button>
            <button style={btnPrimary} onClick={goNext}>Continue</button>
          </div>
        </div>
      )}

      {/* Birth Place */}
      {step === 'birthplace' && (
        <div key="birthplace" style={{ ...slideAnimation, textAlign: 'center', width: '100%', maxWidth: '440px' }}>
          <h2 style={{ ...headingStyle, fontSize: '1.75rem' }}>Where were you born?</h2>
          <p style={subtextStyle}>
            Your birth location defines the horizon line, the rising and setting of constellations unique to your view.
          </p>
          <input
            type="text"
            placeholder="City, State or Country"
            value={birthData.birthPlace || ''}
            onChange={(e) => setBirthData({ ...birthData, birthPlace: e.target.value })}
            style={inputStyle}
            autoFocus
          />
          <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center' }}>
            <button style={btnSecondary} onClick={goBack}>Back</button>
            <button style={btnPrimary} onClick={goNext}>Calculate My Chart</button>
          </div>
        </div>
      )}

      {/* Calculating animation */}
      {step === 'calculating' && (
        <div
          key="calculating"
          style={{
            textAlign: 'center',
            animation: 'fadeInScale 600ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
          }}
        >
          <div
            style={{
              width: '80px',
              height: '80px',
              margin: '0 auto 1.5rem',
              border: '2px solid var(--sage-300, #A8B8AD)',
              borderTopColor: 'var(--gold-600, #C5A059)',
              borderRadius: '50%',
              animation: 'rotate 1.2s linear infinite',
            }}
          />
          <h2 style={{ ...headingStyle, fontSize: '1.5rem' }}>Reading the stars...</h2>
          <p style={{ ...subtextStyle, marginBottom: 0 }}>
            Calculating your celestial blueprint
          </p>
        </div>
      )}

      {/* Complete */}
      {step === 'complete' && (
        <div
          key="complete"
          style={{
            textAlign: 'center',
            maxWidth: '440px',
            animation: 'fadeInScale 600ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
          }}
        >
          <GlassPanel glow padding="2rem" borderRadius="1.5rem">
            <div style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>&#10022;</div>
            <h2 style={{ ...headingStyle, fontSize: '1.75rem' }}>
              Your chart is ready, {birthData.name || 'Cosmic Traveler'}
            </h2>
            <p style={{ ...subtextStyle, marginBottom: '1.5rem' }}>
              The cosmos has revealed your unique celestial architecture. Step inside and explore.
            </p>
            <button
              style={{
                ...btnPrimary,
                animation: 'glow 3s ease-in-out infinite',
              }}
              onClick={handleComplete}
              onMouseEnter={(e) => {
                (e.target as HTMLElement).style.transform = 'scale(1.05)';
              }}
              onMouseLeave={(e) => {
                (e.target as HTMLElement).style.transform = 'scale(1)';
              }}
            >
              Enter Your Cosmos
            </button>
          </GlassPanel>
        </div>
      )}
    </div>
  );
};

export default OnboardingPage;
