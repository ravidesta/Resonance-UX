import React from 'react';

// ShareableTemplates.tsx — Beautiful shareable card components for Luminous Attachment
// These render as gorgeous cards with Resonance branding for social media sharing

const COLORS = {
  green900: '#0A1C14', green800: '#122E21', green700: '#1B402E',
  green200: '#D1E0D7', green100: '#E8F0EA',
  gold: '#C5A059', goldLight: '#E6D0A1', goldDark: '#9A7A3A',
  cream: '#FAFAF8', dark: '#05100B',
};

const BrandWatermark = () => (
  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: 16, borderTop: `1px solid rgba(197,160,89,0.3)`, marginTop: 20 }}>
    <div style={{ fontFamily: "'Manrope', sans-serif", fontSize: 11, color: 'rgba(255,255,255,0.5)', letterSpacing: '0.05em' }}>
      LUMINOUS ATTACHMENT by Resonance
    </div>
    <div style={{ fontFamily: "'Manrope', sans-serif", fontSize: 10, color: COLORS.gold, opacity: 0.6 }}>
      resonance.app
    </div>
  </div>
);

const cardBase: React.CSSProperties = {
  width: 400, minHeight: 300, borderRadius: 24, padding: 40, position: 'relative', overflow: 'hidden',
  background: `linear-gradient(145deg, ${COLORS.green900} 0%, ${COLORS.green800} 50%, ${COLORS.green700} 100%)`,
  color: COLORS.cream, fontFamily: "'Manrope', sans-serif",
};

const blobStyle = (top: string, left: string, size: number, color: string): React.CSSProperties => ({
  position: 'absolute', top, left, width: size, height: size, borderRadius: '50%',
  background: `radial-gradient(circle, ${color} 0%, transparent 70%)`,
  filter: 'blur(40px)', opacity: 0.3, pointerEvents: 'none',
});

export const QuoteCard: React.FC<{ quote: string; author?: string }> = ({ quote, author }) => (
  <div style={cardBase}>
    <div style={blobStyle('-20%', '-10%', 200, COLORS.gold)} />
    <div style={blobStyle('60%', '70%', 180, COLORS.green200)} />
    <div style={{ position: 'relative', zIndex: 1 }}>
      <div style={{ width: 40, height: 3, background: COLORS.gold, marginBottom: 24, borderRadius: 2 }} />
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 28, fontStyle: 'italic', lineHeight: 1.4, marginBottom: 16, fontWeight: 300 }}>
        "{quote}"
      </div>
      {author && <div style={{ fontSize: 14, color: COLORS.goldLight, marginBottom: 24 }}>— {author}</div>}
      <BrandWatermark />
    </div>
  </div>
);

export const InsightCard: React.FC<{ insight: string; date?: string }> = ({ insight, date }) => (
  <div style={{ ...cardBase, background: `linear-gradient(145deg, ${COLORS.green800} 0%, ${COLORS.dark} 100%)` }}>
    <div style={blobStyle('10%', '60%', 220, 'rgba(197,160,89,0.15)')} />
    <div style={{ position: 'relative', zIndex: 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 20 }}>
        <div style={{ width: 8, height: 8, borderRadius: '50%', background: COLORS.gold }} />
        <span style={{ fontSize: 12, textTransform: 'uppercase' as const, letterSpacing: '0.1em', color: COLORS.gold }}>
          Today's Insight
        </span>
      </div>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 24, lineHeight: 1.5, marginBottom: 12 }}>
        {insight}
      </div>
      {date && <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.4)' }}>{date}</div>}
      <BrandWatermark />
    </div>
  </div>
);

export const ProgressCard: React.FC<{ streak: number; entries: number; style: string }> = ({ streak, entries, style }) => (
  <div style={{ ...cardBase, background: `linear-gradient(145deg, ${COLORS.green700} 0%, ${COLORS.green900} 100%)` }}>
    <div style={blobStyle('50%', '-10%', 200, COLORS.goldLight)} />
    <div style={{ position: 'relative', zIndex: 1 }}>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 32, marginBottom: 24 }}>My Growth Journey</div>
      <div style={{ display: 'flex', gap: 20, marginBottom: 24 }}>
        {[{ label: 'Day Streak', value: streak }, { label: 'Entries', value: entries }].map((s, i) => (
          <div key={i} style={{ background: 'rgba(255,255,255,0.08)', borderRadius: 16, padding: '16px 20px', flex: 1, textAlign: 'center' as const, backdropFilter: 'blur(8px)' }}>
            <div style={{ fontSize: 32, fontWeight: 600, color: COLORS.gold, fontFamily: "'Cormorant Garamond', serif" }}>{s.value}</div>
            <div style={{ fontSize: 11, color: 'rgba(255,255,255,0.5)', marginTop: 4, textTransform: 'uppercase' as const, letterSpacing: '0.08em' }}>{s.label}</div>
          </div>
        ))}
      </div>
      <div style={{ fontSize: 14, color: COLORS.goldLight }}>Growing toward {style} attachment</div>
      <BrandWatermark />
    </div>
  </div>
);

export const JournalExcerptCard: React.FC<{ excerpt: string; mood?: string; date?: string }> = ({ excerpt, mood, date }) => (
  <div style={{ ...cardBase, background: `linear-gradient(160deg, ${COLORS.green900} 0%, #0D2419 100%)` }}>
    <div style={blobStyle('0%', '50%', 180, 'rgba(209,224,215,0.1)')} />
    <div style={{ position: 'relative', zIndex: 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 20 }}>
        <span style={{ fontSize: 20 }}>{mood || '🌿'}</span>
        <span style={{ fontSize: 12, color: 'rgba(255,255,255,0.4)' }}>{date || 'Today'}</span>
      </div>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 22, lineHeight: 1.5, fontStyle: 'italic', marginBottom: 8, WebkitMaskImage: 'linear-gradient(to bottom, black 60%, transparent 100%)' }}>
        "{excerpt}"
      </div>
      <div style={{ fontSize: 12, color: 'rgba(255,255,255,0.3)', marginBottom: 16 }}>— From my journal</div>
      <BrandWatermark />
    </div>
  </div>
);

export const MilestoneCard: React.FC<{ milestone: string; icon?: string }> = ({ milestone, icon }) => (
  <div style={{ ...cardBase, background: `linear-gradient(145deg, ${COLORS.goldDark} 0%, ${COLORS.green900} 60%, ${COLORS.dark} 100%)`, textAlign: 'center' as const }}>
    <div style={blobStyle('20%', '30%', 250, 'rgba(197,160,89,0.2)')} />
    <div style={{ position: 'relative', zIndex: 1 }}>
      <div style={{ fontSize: 48, marginBottom: 16 }}>{icon || '✨'}</div>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 20, textTransform: 'uppercase' as const, letterSpacing: '0.15em', color: COLORS.gold, marginBottom: 12 }}>
        Milestone
      </div>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 28, lineHeight: 1.4, marginBottom: 16 }}>{milestone}</div>
      <BrandWatermark />
    </div>
  </div>
);

export const GratitudeCard: React.FC<{ gratitude: string }> = ({ gratitude }) => (
  <div style={{ ...cardBase, background: `linear-gradient(145deg, ${COLORS.green800} 0%, ${COLORS.green700} 100%)` }}>
    <div style={blobStyle('-10%', '60%', 200, 'rgba(230,208,161,0.15)')} />
    <div style={{ position: 'relative', zIndex: 1 }}>
      <div style={{ fontSize: 12, textTransform: 'uppercase' as const, letterSpacing: '0.15em', color: COLORS.gold, marginBottom: 20 }}>
        Today I'm Grateful For
      </div>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 26, lineHeight: 1.5, marginBottom: 20 }}>{gratitude}</div>
      <BrandWatermark />
    </div>
  </div>
);

export default { QuoteCard, InsightCard, ProgressCard, JournalExcerptCard, MilestoneCard, GratitudeCard, BrandWatermark };
