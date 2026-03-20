import React, { useState, useMemo } from 'react';

const T = {
  bg: '#FAFAF8', surface: '#F5F4EE', glass: 'rgba(255,255,255,0.7)',
  border: 'rgba(209,224,215,0.5)', green900: '#0A1C14', green800: '#122E21',
  green700: '#1B402E', green200: '#D1E0D7', green100: '#E8F0EA',
  gold: '#C5A059', goldLight: '#E6D0A1', goldDark: '#9A7A3A',
  textMain: '#122E21', textMuted: '#5C7065', textLight: '#8A9C91',
  serif: "'Cormorant Garamond', Georgia, serif",
  sans: "'Manrope', system-ui, sans-serif",
};

const glassCard: React.CSSProperties = {
  background: T.glass, backdropFilter: 'blur(12px)',
  WebkitBackdropFilter: 'blur(12px)', border: `1px solid ${T.border}`,
  borderRadius: 16, overflow: 'hidden',
};

type Category = 'all' | 'guided-meditation' | 'soundscape' | 'lecture' | 'sleep-story' | 'breathwork' | 'affirmation' | 'ritual-guide';

interface MediaItem {
  id: string; title: string; description: string; type: 'audio' | 'video';
  category: Category; duration: number; artist: string; isFree: boolean; rating: number; color: string;
}

interface Playlist { id: string; title: string; description: string; theme: string; items: string[]; color1: string; color2: string }

const MEDIA: MediaItem[] = [
  { id: 'm1', title: 'Moon Cycle Meditation', description: 'Align your intentions with the current lunar phase.', type: 'audio', category: 'guided-meditation', duration: 900, artist: 'Luna Silveira', isFree: true, rating: 4.9, color: '#1B402E' },
  { id: 'm2', title: 'Planetary Chakra Alignment', description: 'Balance energy centers with cosmic resonance.', type: 'audio', category: 'guided-meditation', duration: 1200, artist: 'Atlas Rivera', isFree: false, rating: 4.8, color: '#2D5A3F' },
  { id: 'm3', title: 'Cosmic Ocean Soundscape', description: 'Deep space tones blended with ocean waves.', type: 'audio', category: 'soundscape', duration: 3600, artist: 'Resonance Audio', isFree: true, rating: 4.7, color: '#0A1C14' },
  { id: 'm4', title: 'Starfield Frequencies', description: 'Binaural beats tuned to planetary frequencies.', type: 'audio', category: 'soundscape', duration: 2700, artist: 'Resonance Audio', isFree: false, rating: 4.6, color: '#122E21' },
  { id: 'm5', title: 'Understanding Your Natal Chart', description: 'A comprehensive intro to reading your birth chart.', type: 'video', category: 'lecture', duration: 2400, artist: 'Celeste Moonwater', isFree: true, rating: 4.9, color: '#9A7A3A' },
  { id: 'm6', title: 'Navigating Planetary Transits', description: 'Learn to work with transits in daily life.', type: 'video', category: 'lecture', duration: 1800, artist: 'Orion Blackwell', isFree: false, rating: 4.8, color: '#C5A059' },
  { id: 'm7', title: 'Pisces Dreamscape', description: 'Drift into restorative sleep guided by Neptune.', type: 'audio', category: 'sleep-story', duration: 1800, artist: 'Luna Silveira', isFree: false, rating: 4.9, color: '#1B402E' },
  { id: 'm8', title: 'Mars Fire Breathwork', description: 'Energizing breathwork channeling Mars energy.', type: 'audio', category: 'breathwork', duration: 600, artist: 'Atlas Rivera', isFree: true, rating: 4.7, color: '#8B4513' },
  { id: 'm9', title: 'New Moon Intention Ritual', description: 'Step-by-step guide for your new moon ritual.', type: 'video', category: 'ritual-guide', duration: 1500, artist: 'Celeste Moonwater', isFree: true, rating: 4.9, color: '#0A1C14' },
  { id: 'm10', title: 'Jupiter Abundance Affirmations', description: 'Affirmations channeling Jupiter energy for prosperity.', type: 'audio', category: 'affirmation', duration: 480, artist: 'Orion Blackwell', isFree: true, rating: 4.6, color: '#C5A059' },
];

const PLAYLISTS: Playlist[] = [
  { id: 'p1', title: 'Celestial Sleep', description: 'Drift into deep rest with cosmic soundscapes.', theme: 'Neptune & Moon', items: ['m3', 'm7', 'm4'], color1: '#0A1C14', color2: '#1B402E' },
  { id: 'p2', title: 'Astrology Foundations', description: 'Begin your astrological journey.', theme: 'Mercury & Jupiter', items: ['m5', 'm6'], color1: '#9A7A3A', color2: '#C5A059' },
  { id: 'p3', title: 'Morning Cosmic Ritual', description: 'Start aligned with planetary energies.', theme: 'Sun & Mars', items: ['m8', 'm10', 'm1'], color1: '#122E21', color2: '#2D5A3F' },
];

const CATEGORIES: { id: Category; label: string }[] = [
  { id: 'all', label: 'All' }, { id: 'guided-meditation', label: 'Meditation' },
  { id: 'soundscape', label: 'Soundscape' }, { id: 'lecture', label: 'Lecture' },
  { id: 'sleep-story', label: 'Sleep Story' }, { id: 'breathwork', label: 'Breathwork' },
  { id: 'affirmation', label: 'Affirmation' }, { id: 'ritual-guide', label: 'Ritual Guide' },
];

function fmtDur(s: number) {
  const m = Math.floor(s / 60), sec = s % 60;
  return m >= 60 ? `${Math.floor(m/60)}:${(m%60).toString().padStart(2,'0')}:${sec.toString().padStart(2,'0')}` : `${m}:${sec.toString().padStart(2,'0')}`;
}

export default function MediaPage() {
  const [category, setCategory] = useState<Category>('all');
  const [search, setSearch] = useState('');
  const [playing, setPlaying] = useState<MediaItem | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [progress, setProgress] = useState(0);

  const filtered = useMemo(() => {
    let items = [...MEDIA];
    if (category !== 'all') items = items.filter(i => i.category === category);
    if (search) { const q = search.toLowerCase(); items = items.filter(i => i.title.toLowerCase().includes(q) || i.artist.toLowerCase().includes(q)); }
    return items;
  }, [category, search]);

  const handlePlay = (item: MediaItem) => { setPlaying(item); setIsPlaying(true); setProgress(0); };

  return (
    <div style={{ minHeight: '100vh', background: T.bg, fontFamily: T.sans }}>
      <div style={{ background: `linear-gradient(135deg, ${T.green900}, ${T.green800})`, padding: '48px 24px 32px', color: '#fff' }}>
        <div style={{ maxWidth: 1200, margin: '0 auto' }}>
          <h1 style={{ fontFamily: T.serif, fontSize: 34, fontWeight: 300, margin: 0 }}>Sound & Vision</h1>
          <p style={{ fontSize: 14, color: 'rgba(255,255,255,0.6)', marginTop: 8 }}>Meditations, lectures, soundscapes & more</p>
        </div>
      </div>

      <div style={{ maxWidth: 1200, margin: '0 auto', padding: 24 }}>
        <input type="text" placeholder="Search meditations, lectures, soundscapes..." value={search} onChange={e => setSearch(e.target.value)}
          style={{ width: '100%', padding: '14px 20px', borderRadius: 12, border: `1px solid ${T.green200}`, fontFamily: T.sans, fontSize: 15, color: T.green900, background: '#fff', outline: 'none', boxSizing: 'border-box', marginBottom: 16 }} />

        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 24 }}>
          {CATEGORIES.map(c => (
            <button key={c.id} onClick={() => setCategory(c.id)} style={{
              padding: '8px 16px', borderRadius: 20, border: `1px solid ${category === c.id ? T.gold : T.green200}`,
              background: category === c.id ? 'rgba(197,160,89,0.12)' : 'transparent',
              color: category === c.id ? T.goldDark : T.textMuted, fontFamily: T.sans, fontSize: 13, cursor: 'pointer',
              fontWeight: category === c.id ? 600 : 400,
            }}>{c.label}</button>
          ))}
        </div>

        <h2 style={{ fontFamily: T.serif, fontSize: 22, color: T.green900, margin: '0 0 16px' }}>Curated Playlists</h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: 16, marginBottom: 32 }}>
          {PLAYLISTS.map(pl => (
            <div key={pl.id} onClick={() => { const first = MEDIA.find(m => m.id === pl.items[0]); if (first) handlePlay(first); }}
              style={{ ...glassCard, cursor: 'pointer', padding: 0, background: `linear-gradient(135deg, ${pl.color1}, ${pl.color2})` }}>
              <div style={{ padding: 24 }}>
                <div style={{ fontFamily: T.serif, fontSize: 20, fontWeight: 600, color: '#fff' }}>{pl.title}</div>
                <p style={{ fontSize: 13, color: 'rgba(255,255,255,0.7)', margin: '6px 0 0', lineHeight: 1.5 }}>{pl.description}</p>
                <div style={{ fontSize: 11, color: T.goldLight, marginTop: 8 }}>{pl.theme} &middot; {pl.items.length} tracks</div>
              </div>
            </div>
          ))}
        </div>

        <h2 style={{ fontFamily: T.serif, fontSize: 22, color: T.green900, margin: '0 0 16px' }}>
          {category === 'all' ? 'All Content' : CATEGORIES.find(c => c.id === category)?.label}
          <span style={{ fontFamily: T.sans, fontSize: 14, color: T.textMuted, fontWeight: 400, marginLeft: 8 }}>({filtered.length})</span>
        </h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: 16, marginBottom: playing ? 100 : 32 }}>
          {filtered.map(item => (
            <div key={item.id} onClick={() => handlePlay(item)} style={{ ...glassCard, cursor: 'pointer' }}>
              <div style={{ height: 120, background: `linear-gradient(135deg, ${item.color}, ${T.green900})`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <span style={{ fontSize: 28, color: 'rgba(255,255,255,0.8)' }}>{item.type === 'video' ? '\u25B6' : '\u266B'}</span>
              </div>
              <div style={{ padding: 14 }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
                  <div style={{ fontFamily: T.serif, fontSize: 16, fontWeight: 500, color: T.green900, lineHeight: 1.3 }}>{item.title}</div>
                  <span style={{ fontSize: 10, padding: '2px 8px', borderRadius: 10, whiteSpace: 'nowrap',
                    background: item.isFree ? T.green100 : 'rgba(197,160,89,0.15)',
                    color: item.isFree ? T.green700 : T.goldDark }}>{item.isFree ? 'Free' : 'Premium'}</span>
                </div>
                <div style={{ fontSize: 12, color: T.textMuted, marginTop: 4 }}>{item.artist}</div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 8 }}>
                  <span style={{ fontSize: 12, color: T.textLight }}>{fmtDur(item.duration)}</span>
                  <span style={{ fontSize: 12, color: T.gold }}>{'\u2605'.repeat(Math.floor(item.rating))} {item.rating}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {playing && (
        <div style={{ position: 'fixed', bottom: 0, left: 0, right: 0, zIndex: 100, background: T.green900, color: '#fff', boxShadow: '0 -4px 20px rgba(0,0,0,0.2)' }}>
          <div style={{ height: 3, background: 'rgba(255,255,255,0.1)' }}>
            <div style={{ height: '100%', width: `${progress}%`, background: T.gold, transition: 'width 0.3s' }} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, padding: '12px 24px', maxWidth: 1200, margin: '0 auto' }}>
            <div style={{ width: 44, height: 44, borderRadius: 8, flexShrink: 0, background: `linear-gradient(135deg, ${playing.color}, ${T.green800})`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16 }}>
              {playing.type === 'video' ? '\u25B6' : '\u266B'}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 14, fontWeight: 500, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{playing.title}</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.5)' }}>{playing.artist}</div>
            </div>
            <button onClick={() => { setIsPlaying(!isPlaying); if (!isPlaying) setProgress(p => Math.min(p + 10, 100)); }} style={{
              width: 40, height: 40, borderRadius: '50%', border: 'none', cursor: 'pointer',
              background: T.gold, color: T.green900, fontSize: 16, display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>{isPlaying ? '\u275A\u275A' : '\u25B6'}</button>
            <button onClick={() => { setPlaying(null); setIsPlaying(false); setProgress(0); }} style={{
              background: 'none', border: 'none', color: 'rgba(255,255,255,0.5)', cursor: 'pointer', fontSize: 18, padding: 4,
            }}>{'\u2715'}</button>
          </div>
        </div>
      )}
    </div>
  );
}
