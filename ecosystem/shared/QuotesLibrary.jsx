import React, { useState, useMemo } from 'react';
import {
  Sun, Moon, Heart, Share2, Search, Filter, Star, BookOpen,
  Sparkles, ChevronRight, Copy, X
} from 'lucide-react';

// ═══════════════════════════════════════════════════════════
// RESONANCE QUOTES LIBRARY — Luminous Ego Development™
// 40+ curated quotes on ego development, growth, healing,
// awareness, and transformation. Filterable, shareable, saveable.
// ═══════════════════════════════════════════════════════════

const CATEGORIES = [
  { id: 'all', label: 'All', color: '#C5A059' },
  { id: 'growth', label: 'Growth', color: '#1B402E' },
  { id: 'awareness', label: 'Awareness', color: '#0E94BE' },
  { id: 'resilience', label: 'Resilience', color: '#9A7A3A' },
  { id: 'love', label: 'Love', color: '#C5A059' },
  { id: 'wisdom', label: 'Wisdom', color: '#122E21' },
  { id: 'healing', label: 'Healing', color: '#5C7065' },
  { id: 'presence', label: 'Presence', color: '#1B402E' },
  { id: 'courage', label: 'Courage', color: '#9A7A3A' },
  { id: 'authenticity', label: 'Authenticity', color: '#0E94BE' },
  { id: 'transformation', label: 'Transformation', color: '#C5A059' },
];

const QUOTES = [
  { text: 'The privilege of a lifetime is to become who you truly are.', author: 'Carl Jung', category: 'authenticity', image: 'Ancient oak tree at golden hour' },
  { text: 'The wound is the place where the Light enters you.', author: 'Rumi', category: 'healing', image: 'Sunlight through forest canopy' },
  { text: 'Vulnerability is the birthplace of innovation, creativity, and change.', author: 'Brene Brown', category: 'courage', image: 'Morning mist over calm lake' },
  { text: 'Between stimulus and response there is a space. In that space is our freedom and our power to choose.', author: 'Viktor Frankl', category: 'awareness', image: 'Vast sky between mountain peaks' },
  { text: 'The only journey is the one within.', author: 'Rainer Maria Rilke', category: 'growth', image: 'Winding forest path in autumn' },
  { text: 'Tell me, what is it you plan to do with your one wild and precious life?', author: 'Mary Oliver', category: 'authenticity', image: 'Wildflower meadow at sunrise' },
  { text: 'Your task is not to seek for love, but merely to seek and find all the barriers within yourself that you have built against it.', author: 'Rumi', category: 'love', image: 'River flowing through canyon' },
  { text: 'The curious paradox is that when I accept myself just as I am, then I can change.', author: 'Carl Rogers', category: 'growth', image: 'Butterfly emerging from chrysalis' },
  { text: 'Feelings are just visitors, let them come and go.', author: 'Thich Nhat Hanh', category: 'presence', image: 'Clouds passing over green valley' },
  { text: 'There is no greater agony than bearing an untold story inside you.', author: 'Maya Angelou', category: 'courage', image: 'Starlit sky over desert' },
  { text: 'You are the sky. Everything else is just the weather.', author: 'Pema Chodron', category: 'awareness', image: 'Expansive blue sky with wisps of cloud' },
  { text: 'The soul becomes dyed with the color of its thoughts.', author: 'Marcus Aurelius', category: 'wisdom', image: 'Sunset painting clouds in color' },
  { text: 'When you realize nothing is lacking, the whole world belongs to you.', author: 'Lao Tzu', category: 'presence', image: 'Still mountain lake reflection' },
  { text: 'Your children are not your children. They are the sons and daughters of Life longing for itself.', author: 'Khalil Gibran', category: 'wisdom', image: 'Dandelion seeds in wind' },
  { text: 'Knowing yourself is the beginning of all wisdom.', author: 'Aristotle', category: 'awareness', image: 'Clear water over smooth stones' },
  { text: 'Be patient toward all that is unsolved in your heart.', author: 'Rainer Maria Rilke', category: 'growth', image: 'Seeds sprouting through dark soil' },
  { text: 'The body keeps the score.', author: 'Bessel van der Kolk', category: 'healing', image: 'Waves smoothing stones on shore' },
  { text: 'What is not brought to consciousness comes to us as fate.', author: 'Carl Jung', category: 'awareness', image: 'Light breaking through storm clouds' },
  { text: 'In the middle of difficulty lies opportunity.', author: 'Albert Einstein', category: 'resilience', image: 'Flower growing through crack in rock' },
  { text: 'We do not see things as they are, we see them as we are.', author: 'Anais Nin', category: 'awareness', image: 'Kaleidoscope of autumn leaves' },
  { text: 'The most common way people give up their power is by thinking they do not have any.', author: 'Alice Walker', category: 'courage', image: 'Eagle soaring above mountains' },
  { text: 'Owning our story and loving ourselves through that process is the bravest thing we will ever do.', author: 'Brene Brown', category: 'authenticity', image: 'First light touching mountain peak' },
  { text: 'Everything that irritates us about others can lead us to an understanding of ourselves.', author: 'Carl Jung', category: 'wisdom', image: 'Mirror-still lake at dawn' },
  { text: 'Pain that is not transformed is transmitted.', author: 'Richard Rohr', category: 'healing', image: 'River finding new path around boulder' },
  { text: 'To love oneself is the beginning of a lifelong romance.', author: 'Oscar Wilde', category: 'love', image: 'Rose garden in morning dew' },
  { text: 'We are not meant to stay wounded. We are supposed to move through our tragedies.', author: 'Clarissa Pinkola Estes', category: 'resilience', image: 'Phoenix-colored sunset after rain' },
  { text: 'The only way out is through.', author: 'Robert Frost', category: 'resilience', image: 'Trail through dense forest' },
  { text: 'Real but not true.', author: 'Tara Brach', category: 'presence', image: 'Morning fog dissolving in sunshine' },
  { text: 'In today is already the seed of tomorrow.', author: 'Jack Kornfield', category: 'growth', image: 'Acorn beside mighty oak' },
  { text: 'Wholeness is not achieved by cutting off a portion of one\'s being, but by integration of the contraries.', author: 'Carl Jung', category: 'transformation', image: 'Rainbow spanning dark and light sky' },
  { text: 'When we are no longer able to change a situation, we are challenged to change ourselves.', author: 'Viktor Frankl', category: 'resilience', image: 'Bamboo bending in wind' },
  { text: 'The trauma is not what happens to you. It is what happens inside you as a result.', author: 'Gabor Mate', category: 'healing', image: 'Gentle rain on new green leaves' },
  { text: 'I am not what happened to me, I am what I choose to become.', author: 'Carl Jung', category: 'transformation', image: 'Caterpillar on luminous leaf' },
  { text: 'Love is what we are born with. Fear is what we learn.', author: 'Marianne Williamson', category: 'love', image: 'Child watching fireflies at dusk' },
  { text: 'The cave you fear to enter holds the treasure you seek.', author: 'Joseph Campbell', category: 'courage', image: 'Light streaming from cave entrance' },
  { text: 'Not everything that is faced can be changed, but nothing can be changed until it is faced.', author: 'James Baldwin', category: 'courage', image: 'Sunrise illuminating dark valley' },
  { text: 'Caring for myself is not self-indulgence, it is self-preservation.', author: 'Audre Lorde', category: 'love', image: 'Warm hearth in winter cabin' },
  { text: 'Before you tell your life what you intend to do with it, listen for what it intends to do with you.', author: 'Parker Palmer', category: 'wisdom', image: 'Seashell on quiet shore' },
  { text: 'We can be healers of each other.', author: 'bell hooks', category: 'healing', image: 'Hands cupping water in stream' },
  { text: 'The practice of peace and reconciliation is one of the most vital and artistic of human actions.', author: 'Thich Nhat Hanh', category: 'presence', image: 'Lotus blooming in still pond' },
  { text: 'What you are is what you have been. What you will be is what you do now.', author: 'Buddha', category: 'transformation', image: 'Path dividing at forest crossroads' },
  { text: 'Do I dare disturb the universe?', author: 'T.S. Eliot', category: 'transformation', image: 'Single star in vast cosmos' },
  { text: 'The world breaks everyone and afterward many are strong at the broken places.', author: 'Ernest Hemingway', category: 'resilience', image: 'Kintsugi bowl with gold repair' },
  { text: 'There is a crack in everything. That\'s how the light gets in.', author: 'Leonard Cohen', category: 'healing', image: 'Light through cracked wall' },
];

export default function QuotesLibrary() {
  const [dark, setDark] = useState(false);
  const [category, setCategory] = useState('all');
  const [search, setSearch] = useState('');
  const [favorites, setFavorites] = useState(new Set([0, 4, 11]));
  const [shareQuote, setShareQuote] = useState(null);
  const [copied, setCopied] = useState(false);

  const bg = dark ? '#05100B' : '#FAFAF8';
  const surface = dark ? 'rgba(10,28,20,0.65)' : 'rgba(255,255,255,0.65)';
  const text = dark ? '#FAFAF8' : '#122E21';
  const muted = dark ? '#8A9C91' : '#5C7065';
  const light = dark ? '#5C7065' : '#8A9C91';
  const border = dark ? 'rgba(27,64,46,0.7)' : 'rgba(138,156,145,0.25)';
  const gold = '#C5A059';
  const serif = "'Cormorant Garamond', serif";
  const sans = "'Manrope', sans-serif";

  const todayIndex = new Date().getDate() % QUOTES.length;
  const todayQuote = QUOTES[todayIndex];

  const filtered = useMemo(() => {
    return QUOTES.filter((q, i) => {
      const matchCat = category === 'all' || q.category === category;
      const matchSearch = !search || q.text.toLowerCase().includes(search.toLowerCase()) ||
        q.author.toLowerCase().includes(search.toLowerCase());
      return matchCat && matchSearch;
    });
  }, [category, search]);

  const toggleFav = (i) => {
    const idx = QUOTES.indexOf(filtered[i]);
    const next = new Set(favorites);
    next.has(idx) ? next.delete(idx) : next.add(idx);
    setFavorites(next);
  };

  const handleCopy = (q) => {
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  return (
    <div style={{
      minHeight: '100vh', background: bg, color: text,
      fontFamily: sans, transition: 'all 0.8s ease', position: 'relative', overflow: 'hidden',
    }}>
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;0,600;0,700;1,400&family=Manrope:wght@300;400;500;600&display=swap" rel="stylesheet" />
      <style>{`
        @keyframes breathe { 0% { transform: scale(1); } 100% { transform: scale(1.06) translate(10px,12px); } }
        @keyframes fadeIn { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
      `}</style>

      {/* Background */}
      <div style={{ position: 'fixed', inset: 0, pointerEvents: 'none', zIndex: 0 }}>
        <div style={{
          position: 'absolute', top: '-8%', left: '-12%', width: 350, height: 350,
          borderRadius: '50%', filter: 'blur(80px)', opacity: dark ? 0.2 : 0.5,
          background: 'radial-gradient(circle, #D1E0D7 0%, transparent 70%)',
          animation: 'breathe 16s infinite alternate ease-in-out',
        }} />
        <div style={{
          position: 'absolute', bottom: '15%', right: '-10%', width: 400, height: 400,
          borderRadius: '50%', filter: 'blur(80px)', opacity: dark ? 0.15 : 0.4,
          background: 'radial-gradient(circle, rgba(197,160,89,0.2) 0%, transparent 70%)',
          animation: 'breathe 20s infinite alternate ease-in-out', animationDelay: '-7s',
        }} />
      </div>

      <div style={{ position: 'relative', zIndex: 1, maxWidth: 800, margin: '0 auto', padding: '32px 20px 80px' }}>

        {/* Header */}
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 32,
        }}>
          <div>
            <h1 style={{ fontFamily: serif, fontSize: 32, fontWeight: 400, margin: 0 }}>
              Quotes Library
            </h1>
            <p style={{ fontSize: 13, color: muted, margin: '4px 0 0' }}>
              {QUOTES.length} curated wisdoms for your journey
            </p>
          </div>
          <button onClick={() => setDark(!dark)} style={{
            background: surface, backdropFilter: 'blur(12px)', border: `1px solid ${border}`,
            borderRadius: 12, padding: 10, cursor: 'pointer', color: gold,
          }}>
            {dark ? <Sun size={18} /> : <Moon size={18} />}
          </button>
        </div>

        {/* ── QUOTE OF THE DAY ── */}
        <div style={{
          background: `linear-gradient(135deg, ${dark ? '#0A1C14' : '#122E21'}, ${dark ? '#1B402E' : '#0A1C14'})`,
          borderRadius: 24, padding: 36, marginBottom: 32, position: 'relative', overflow: 'hidden',
          animation: 'fadeIn 0.6s ease-out',
        }}>
          <div style={{
            position: 'absolute', top: -20, right: -20, width: 200, height: 200,
            borderRadius: '50%', background: 'radial-gradient(circle, rgba(197,160,89,0.15) 0%, transparent 70%)',
          }} />
          <div style={{
            fontSize: 11, fontWeight: 600, letterSpacing: 2, textTransform: 'uppercase',
            color: gold, marginBottom: 16, display: 'flex', alignItems: 'center', gap: 6,
          }}>
            <Sparkles size={14} /> Quote of the Day
          </div>
          <p style={{
            fontFamily: serif, fontSize: 24, fontStyle: 'italic', lineHeight: 1.5,
            color: '#FAFAF8', margin: '0 0 20px', position: 'relative', zIndex: 1,
          }}>
            "{todayQuote.text}"
          </p>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ fontSize: 13, color: '#E6D0A1', fontWeight: 500 }}>— {todayQuote.author}</span>
            <div style={{ display: 'flex', gap: 8 }}>
              <button onClick={() => setShareQuote(todayQuote)} style={{
                background: 'rgba(255,255,255,0.1)', border: 'none', borderRadius: 8,
                padding: '6px 14px', color: '#FAFAF8', fontSize: 12, cursor: 'pointer',
                display: 'flex', alignItems: 'center', gap: 4,
              }}>
                <Share2 size={12} /> Share
              </button>
            </div>
          </div>
          <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.4)', marginTop: 12 }}>
            {todayQuote.image}
          </div>
        </div>

        {/* ── SEARCH ── */}
        <div style={{
          display: 'flex', alignItems: 'center', gap: 10,
          background: surface, backdropFilter: 'blur(12px)',
          border: `1px solid ${border}`, borderRadius: 14, padding: '10px 16px', marginBottom: 16,
        }}>
          <Search size={16} color={muted} />
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search quotes or authors..."
            style={{
              flex: 1, background: 'none', border: 'none', outline: 'none',
              color: text, fontFamily: sans, fontSize: 14,
            }}
          />
          {search && (
            <button onClick={() => setSearch('')} style={{
              background: 'none', border: 'none', cursor: 'pointer', color: muted, padding: 2,
            }}>
              <X size={14} />
            </button>
          )}
        </div>

        {/* ── CATEGORY FILTERS ── */}
        <div style={{
          display: 'flex', gap: 8, overflowX: 'auto', marginBottom: 24,
          paddingBottom: 4, scrollbarWidth: 'none',
        }}>
          {CATEGORIES.map(cat => (
            <button key={cat.id} onClick={() => setCategory(cat.id)} style={{
              background: category === cat.id ? `${cat.color}22` : 'transparent',
              border: `1px solid ${category === cat.id ? cat.color : border}`,
              borderRadius: 20, padding: '6px 16px', cursor: 'pointer',
              fontFamily: sans, fontSize: 12, color: category === cat.id ? cat.color : muted,
              whiteSpace: 'nowrap', fontWeight: category === cat.id ? 600 : 400,
              transition: 'all 0.2s ease',
            }}>
              {cat.label}
            </button>
          ))}
        </div>

        {/* ── RESULTS COUNT ── */}
        <div style={{ fontSize: 12, color: light, marginBottom: 16 }}>
          {filtered.length} quote{filtered.length !== 1 ? 's' : ''} found
        </div>

        {/* ── QUOTE GALLERY ── */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(340px, 1fr))', gap: 16, marginBottom: 48 }}>
          {filtered.map((q, i) => {
            const globalIdx = QUOTES.indexOf(q);
            const isFav = favorites.has(globalIdx);
            const catObj = CATEGORIES.find(c => c.id === q.category);
            return (
              <div key={i} style={{
                background: surface, backdropFilter: 'blur(12px)',
                borderRadius: 20, padding: 24, position: 'relative', overflow: 'hidden',
                border: `1px solid ${border}`,
                boxShadow: dark ? '0 8px 24px rgba(0,0,0,0.5)' : '0 8px 24px rgba(154,122,58,0.08)',
                animation: `fadeIn 0.4s ease-out ${i * 0.04}s both`,
              }}>
                {/* Category badge */}
                <div style={{
                  display: 'inline-block', fontSize: 10, fontWeight: 600, letterSpacing: 1,
                  textTransform: 'uppercase', color: catObj?.color || gold,
                  background: `${catObj?.color || gold}15`, borderRadius: 6,
                  padding: '3px 10px', marginBottom: 14,
                }}>
                  {q.category}
                </div>
                {/* Large quotation mark */}
                <div style={{
                  position: 'absolute', top: 8, right: 16, fontSize: 56,
                  fontFamily: serif, color: gold, opacity: 0.1, lineHeight: 1,
                }}>"</div>
                {/* Quote text */}
                <p style={{
                  fontFamily: serif, fontSize: 16, fontStyle: 'italic',
                  lineHeight: 1.6, margin: '0 0 16px', position: 'relative', zIndex: 1,
                }}>
                  {q.text}
                </p>
                {/* Author + actions */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontSize: 12, color: gold, fontWeight: 500 }}>— {q.author}</span>
                  <div style={{ display: 'flex', gap: 10 }}>
                    <button onClick={() => toggleFav(i)} style={{
                      background: 'none', border: 'none', cursor: 'pointer',
                      color: isFav ? '#E25555' : light, transition: 'color 0.2s',
                    }}>
                      <Heart size={15} fill={isFav ? '#E25555' : 'none'} />
                    </button>
                    <button onClick={() => setShareQuote(q)} style={{
                      background: 'none', border: 'none', cursor: 'pointer', color: light,
                    }}>
                      <Share2 size={15} />
                    </button>
                  </div>
                </div>
                {/* Image description */}
                <div style={{ fontSize: 10, color: light, marginTop: 10, fontStyle: 'italic' }}>
                  {q.image}
                </div>
              </div>
            );
          })}
        </div>

        {/* ── CROSS PROMO ── */}
        <div style={{
          background: surface, backdropFilter: 'blur(12px)', borderRadius: 16,
          padding: 20, border: `1px solid ${border}`, textAlign: 'center',
        }}>
          <BookOpen size={20} color={gold} style={{ marginBottom: 8 }} />
          <div style={{ fontFamily: serif, fontSize: 16, marginBottom: 4 }}>
            Explore deeper in the Resonance ecosystem
          </div>
          <div style={{ fontSize: 12, color: muted, marginBottom: 12 }}>
            Journal about your favorite quotes, discuss them with your AI coach, or discover related courses
          </div>
          <div style={{ display: 'flex', gap: 8, justifyContent: 'center', flexWrap: 'wrap' }}>
            {['Resonance Journal', 'Resonance Coach', 'Resonance Learn'].map(app => (
              <span key={app} style={{
                fontSize: 11, color: gold, background: `${gold}15`, borderRadius: 8,
                padding: '5px 12px', cursor: 'pointer',
              }}>
                {app} <ChevronRight size={10} style={{ verticalAlign: 'middle' }} />
              </span>
            ))}
          </div>
        </div>
      </div>

      {/* ── SHARE MODAL ── */}
      {shareQuote && (
        <div style={{
          position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100,
        }} onClick={() => setShareQuote(null)}>
          <div onClick={e => e.stopPropagation()} style={{
            background: dark ? '#0A1C14' : '#FAFAF8', borderRadius: 24,
            padding: 36, maxWidth: 420, width: '90%', position: 'relative',
            boxShadow: '0 24px 60px rgba(0,0,0,0.4)',
          }}>
            <button onClick={() => setShareQuote(null)} style={{
              position: 'absolute', top: 16, right: 16, background: 'none',
              border: 'none', cursor: 'pointer', color: muted,
            }}>
              <X size={18} />
            </button>
            <div style={{
              fontSize: 11, fontWeight: 600, letterSpacing: 2, textTransform: 'uppercase',
              color: gold, marginBottom: 16,
            }}>
              Share This Wisdom
            </div>
            {/* Shareable card preview */}
            <div style={{
              background: `linear-gradient(135deg, #122E21, #0A1C14)`,
              borderRadius: 16, padding: 28, marginBottom: 20,
            }}>
              <div style={{
                position: 'relative', fontSize: 48, fontFamily: serif,
                color: gold, opacity: 0.3, lineHeight: 0.8, marginBottom: 8,
              }}>"</div>
              <p style={{
                fontFamily: serif, fontSize: 18, fontStyle: 'italic',
                lineHeight: 1.5, color: '#FAFAF8', margin: '0 0 16px',
              }}>
                {shareQuote.text}
              </p>
              <div style={{ fontSize: 12, color: '#E6D0A1' }}>— {shareQuote.author}</div>
              <div style={{
                marginTop: 16, paddingTop: 12, borderTop: '1px solid rgba(255,255,255,0.1)',
                display: 'flex', alignItems: 'center', gap: 6,
              }}>
                <Sparkles size={12} color={gold} />
                <span style={{ fontSize: 10, color: 'rgba(255,255,255,0.4)', letterSpacing: 1 }}>
                  RESONANCE — Luminous Ego Development
                </span>
              </div>
            </div>
            {/* Actions */}
            <div style={{ display: 'flex', gap: 10 }}>
              <button onClick={() => handleCopy(shareQuote)} style={{
                flex: 1, background: `linear-gradient(135deg, ${gold}, #9A7A3A)`,
                color: '#FAFAF8', border: 'none', borderRadius: 12, padding: '12px 0',
                fontFamily: sans, fontSize: 13, fontWeight: 500, cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              }}>
                <Copy size={14} /> {copied ? 'Copied!' : 'Copy Quote'}
              </button>
              <button style={{
                flex: 1, background: 'transparent', color: gold,
                border: `1.5px solid ${gold}`, borderRadius: 12, padding: '12px 0',
                fontFamily: sans, fontSize: 13, cursor: 'pointer',
                display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6,
              }}>
                <Share2 size={14} /> Share Image
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
