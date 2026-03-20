import React, { useState } from 'react';

const T = {
  green900: '#0A1C14', green800: '#122E21', green700: '#1B402E',
  gold: '#C5A059', goldLight: '#E6D0A1', goldDark: '#9A7A3A',
  serif: "'Cormorant Garamond', Georgia, serif",
  sans: "'Manrope', system-ui, sans-serif",
};

type AspectRatio = 'square' | 'story';
type CardType = 'daily-horoscope' | 'moon-phase' | 'compatibility' | 'affirmation' | 'transit-alert';

const SIGN_GLYPHS: Record<string, string> = {
  Aries:'\u2648',Taurus:'\u2649',Gemini:'\u264A',Cancer:'\u264B',Leo:'\u264C',Virgo:'\u264D',
  Libra:'\u264E',Scorpio:'\u264F',Sagittarius:'\u2650',Capricorn:'\u2651',Aquarius:'\u2652',Pisces:'\u2653',
};

function CardFrame({ ratio, children }: { ratio: AspectRatio; children: React.ReactNode }) {
  return (
    <div style={{
      width: ratio === 'square' ? 360 : 270, height: ratio === 'square' ? 360 : 480,
      borderRadius: 20, overflow: 'hidden', position: 'relative',
      background: `linear-gradient(145deg, ${T.green900} 0%, ${T.green800} 50%, ${T.green700} 100%)`,
      color: '#fff', fontFamily: T.sans, display: 'flex', flexDirection: 'column',
    }}>
      {[...Array(8)].map((_, i) => (
        <div key={i} style={{
          position: 'absolute', width: 3 + (i % 3), height: 3 + (i % 3), borderRadius: '50%',
          background: `rgba(197,160,89,${0.2 + (i % 4) * 0.1})`,
          top: `${10 + i * 11}%`, left: `${5 + (i * 13) % 90}%`,
        }} />
      ))}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: 24, position: 'relative', zIndex: 1 }}>
        {children}
      </div>
      <div style={{
        padding: '12px 24px', borderTop: '1px solid rgba(197,160,89,0.2)',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        fontSize: 10, color: T.goldLight, letterSpacing: 1, textTransform: 'uppercase',
      }}>
        <span>Luminous Cosmic</span><span style={{ opacity: 0.6 }}>{'\u2727'}</span>
      </div>
    </div>
  );
}

export function DailyHoroscopeCard({ sign, text, date, luckyNumber }: { sign: string; text: string; date: string; luckyNumber: number }) {
  return (<>
    <div style={{ textAlign: 'center', marginBottom: 16 }}>
      <div style={{ fontSize: 48, lineHeight: 1 }}>{SIGN_GLYPHS[sign] || '\u2609'}</div>
      <div style={{ fontFamily: T.serif, fontSize: 24, fontWeight: 600, marginTop: 8, color: T.goldLight }}>{sign}</div>
      <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', marginTop: 4 }}>{date}</div>
    </div>
    <p style={{ fontSize: 14, lineHeight: 1.7, textAlign: 'center', color: 'rgba(255,255,255,0.85)', margin: '0 0 16px' }}>{text}</p>
    <div style={{ textAlign: 'center', fontSize: 12, color: T.goldLight }}>Lucky Number: {luckyNumber}</div>
  </>);
}

export function MoonPhaseCard({ phase, illumination, sign, message }: { phase: string; illumination: number; sign: string; message: string }) {
  return (<>
    <div style={{ textAlign: 'center' }}>
      <div style={{
        width: 80, height: 80, borderRadius: '50%', margin: '0 auto 16px',
        background: `radial-gradient(circle at 60% 50%, ${T.goldLight} ${illumination}%, rgba(255,255,255,0.1) ${illumination}%)`,
        boxShadow: `0 0 30px rgba(197,160,89,${illumination / 250})`,
      }} />
      <div style={{ fontFamily: T.serif, fontSize: 26, fontWeight: 600, color: T.goldLight }}>{phase}</div>
      <div style={{ fontSize: 13, color: 'rgba(255,255,255,0.6)', marginTop: 4 }}>{illumination}% illuminated &middot; Moon in {sign}</div>
    </div>
    <p style={{ fontSize: 14, lineHeight: 1.7, textAlign: 'center', color: 'rgba(255,255,255,0.8)', marginTop: 16, fontStyle: 'italic' }}>{message}</p>
  </>);
}

export function CompatibilityCard({ sign1, sign2, score, strengths }: { sign1: string; sign2: string; score: number; strengths: string[] }) {
  return (<>
    <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 20, marginBottom: 20 }}>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: 36 }}>{SIGN_GLYPHS[sign1] || '\u2609'}</div>
        <div style={{ fontFamily: T.serif, fontSize: 16, color: T.goldLight, marginTop: 4 }}>{sign1}</div>
      </div>
      <div style={{ width: 40, height: 40, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', border: `2px solid ${T.gold}`, fontSize: 18 }}>{'\u2661'}</div>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: 36 }}>{SIGN_GLYPHS[sign2] || '\u2609'}</div>
        <div style={{ fontFamily: T.serif, fontSize: 16, color: T.goldLight, marginTop: 4 }}>{sign2}</div>
      </div>
    </div>
    <div style={{ textAlign: 'center', marginBottom: 16 }}>
      <div style={{ fontFamily: T.serif, fontSize: 42, fontWeight: 700, color: T.gold }}>{score}%</div>
      <div style={{ height: 4, borderRadius: 2, background: 'rgba(255,255,255,0.1)', margin: '8px 20px', overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${score}%`, background: T.gold, borderRadius: 2 }} />
      </div>
    </div>
    <div style={{ display: 'flex', gap: 6, justifyContent: 'center', flexWrap: 'wrap' }}>
      {strengths.map((s, i) => (
        <span key={i} style={{ fontSize: 11, padding: '3px 10px', borderRadius: 12, background: 'rgba(197,160,89,0.15)', color: T.goldLight }}>{s}</span>
      ))}
    </div>
  </>);
}

const AFFIRMATIONS = [
  'I am aligned with the cosmic flow. Abundance moves through me.',
  'The universe conspires in my favor. I trust the timing of my life.',
  'I release what no longer serves me and welcome transformation.',
  'My intuition is a compass. I trust the wisdom written in my stars.',
  'I am a vessel of light. My energy radiates healing to all I encounter.',
  'The moon illuminates my path. I walk in harmony with nature\u2019s cycles.',
];

export function AffirmationCard({ text }: { text?: string }) {
  const affirmation = text || AFFIRMATIONS[Math.floor(Math.random() * AFFIRMATIONS.length)];
  return (
    <div style={{ textAlign: 'center', padding: '12px 0' }}>
      <div style={{ fontSize: 24, color: T.gold, marginBottom: 20 }}>{'\u2727'}</div>
      <p style={{ fontFamily: T.serif, fontSize: 22, fontWeight: 300, lineHeight: 1.6, color: T.goldLight, fontStyle: 'italic' }}>
        &ldquo;{affirmation}&rdquo;
      </p>
      <div style={{ fontSize: 24, color: T.gold, marginTop: 20 }}>{'\u2727'}</div>
    </div>
  );
}

export function TransitAlertCard({ planet, aspect, target, message }: { planet: string; aspect: string; target: string; message: string }) {
  return (
    <div style={{ textAlign: 'center' }}>
      <div style={{ fontSize: 13, color: T.gold, textTransform: 'uppercase', letterSpacing: 2, marginBottom: 12 }}>Transit Alert</div>
      <div style={{ fontFamily: T.serif, fontSize: 28, fontWeight: 600, color: T.goldLight }}>{planet} {aspect} {target}</div>
      <div style={{ width: 40, height: 1, background: T.gold, margin: '16px auto', opacity: 0.5 }} />
      <p style={{ fontSize: 14, lineHeight: 1.7, color: 'rgba(255,255,255,0.8)' }}>{message}</p>
    </div>
  );
}

interface ShareableCardProps { type: CardType; data: Record<string, any> }

export default function ShareableCard({ type, data }: ShareableCardProps) {
  const [ratio, setRatio] = useState<AspectRatio>('square');

  const handleShare = () => {
    const text = `${data.title || type} - Shared from Luminous Cosmic Architecture`;
    if (navigator.clipboard) navigator.clipboard.writeText(text);
  };

  const renderCard = () => {
    switch (type) {
      case 'daily-horoscope': return <DailyHoroscopeCard sign={data.sign} text={data.text} date={data.date} luckyNumber={data.luckyNumber} />;
      case 'moon-phase': return <MoonPhaseCard phase={data.phase} illumination={data.illumination} sign={data.sign} message={data.message} />;
      case 'compatibility': return <CompatibilityCard sign1={data.sign1} sign2={data.sign2} score={data.score} strengths={data.strengths || []} />;
      case 'affirmation': return <AffirmationCard text={data.text} />;
      case 'transit-alert': return <TransitAlertCard planet={data.planet} aspect={data.aspect} target={data.target} message={data.message} />;
      default: return <AffirmationCard />;
    }
  };

  return (
    <div style={{ display: 'inline-flex', flexDirection: 'column', gap: 12 }}>
      <div style={{ display: 'flex', gap: 8 }}>
        {(['square', 'story'] as AspectRatio[]).map(r => (
          <button key={r} onClick={() => setRatio(r)} style={{
            padding: '6px 14px', borderRadius: 8, border: `1px solid ${ratio === r ? T.gold : '#D1E0D7'}`,
            background: ratio === r ? 'rgba(197,160,89,0.1)' : 'transparent',
            color: ratio === r ? T.goldDark : '#5C7065',
            fontFamily: T.sans, fontSize: 12, cursor: 'pointer', textTransform: 'capitalize',
          }}>{r === 'story' ? 'Story (9:16)' : 'Square (1:1)'}</button>
        ))}
      </div>
      <CardFrame ratio={ratio}>{renderCard()}</CardFrame>
      <div style={{ display: 'flex', gap: 8 }}>
        <button onClick={handleShare} style={{
          flex: 1, padding: 10, borderRadius: 10, border: 'none', cursor: 'pointer',
          background: T.green800, color: '#fff', fontFamily: T.sans, fontSize: 13,
        }}>Share</button>
        <button onClick={handleShare} style={{
          flex: 1, padding: 10, borderRadius: 10, border: `1px solid ${T.green800}`, cursor: 'pointer',
          background: 'transparent', color: T.green800, fontFamily: T.sans, fontSize: 13,
        }}>Copy Link</button>
      </div>
    </div>
  );
}
