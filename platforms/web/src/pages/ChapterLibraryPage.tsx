import React, { useState } from 'react';
import GlassPanel from '../components/GlassPanel';
import type { Chapter } from '../types/astrology';

const CHAPTERS: Chapter[] = [
  {
    id: 'ch-1',
    number: 1,
    title: 'The Celestial Blueprint',
    subtitle: 'Understanding Your Natal Chart',
    description:
      'An introduction to the language of the stars. Learn how the positions of celestial bodies at your birth create a unique map of your psyche, potential, and life path.',
    sections: [
      { id: 's-1-1', title: 'What Is a Natal Chart?', content: 'Your natal chart is a snapshot of the heavens at the exact moment you were born...', type: 'text' },
      { id: 's-1-2', title: 'The Zodiac Wheel', content: 'The zodiac is divided into twelve signs, each occupying 30 degrees...', type: 'text' },
      { id: 's-1-3', title: 'Reflection: Your First Impression', content: 'Look at your natal chart. Without analyzing, what catches your eye first?', type: 'reflection' },
    ],
    unlocked: true,
  },
  {
    id: 'ch-2',
    number: 2,
    title: 'The Luminaries',
    subtitle: 'Sun, Moon & Your Core Self',
    description:
      'The Sun and Moon are the two most significant bodies in your chart. Together they reveal the interplay between your conscious identity and your emotional inner world.',
    sections: [
      { id: 's-2-1', title: 'The Sun: Your Vital Essence', content: 'The Sun represents your core identity, your life force...', type: 'text' },
      { id: 's-2-2', title: 'The Moon: Your Emotional Landscape', content: 'The Moon governs your emotions, instincts, and unconscious patterns...', type: 'text' },
      { id: 's-2-3', title: 'Exercise: Sun-Moon Dialogue', content: 'Write a conversation between your Sun sign self and your Moon sign self...', type: 'exercise' },
    ],
    unlocked: true,
  },
  {
    id: 'ch-3',
    number: 3,
    title: 'The Personal Planets',
    subtitle: 'Mercury, Venus & Mars',
    description:
      'These swift-moving planets shape your communication style, your approach to love and beauty, and your drive and assertion in the world.',
    sections: [
      { id: 's-3-1', title: 'Mercury: The Messenger', content: 'Mercury rules how you think, communicate, and process information...', type: 'text' },
      { id: 's-3-2', title: 'Venus: The Heart\'s Desire', content: 'Venus reveals what you value, how you love, and what brings you pleasure...', type: 'text' },
      { id: 's-3-3', title: 'Mars: The Warrior Within', content: 'Mars shows how you assert yourself, pursue goals, and express anger...', type: 'text' },
    ],
    unlocked: true,
  },
  {
    id: 'ch-4',
    number: 4,
    title: 'The Social Planets',
    subtitle: 'Jupiter & Saturn',
    description:
      'Jupiter expands while Saturn contracts. Together they represent the tension between growth and discipline that shapes your journey through society.',
    sections: [
      { id: 's-4-1', title: 'Jupiter: The Great Benefic', content: 'Jupiter represents expansion, optimism, and your search for meaning...', type: 'text' },
      { id: 's-4-2', title: 'Saturn: The Great Teacher', content: 'Saturn represents structure, responsibility, and the lessons of time...', type: 'text' },
      { id: 's-4-3', title: 'Meditation: The Balance Point', content: 'Visualize Jupiter and Saturn as two guides standing on either side of you...', type: 'meditation' },
    ],
    unlocked: true,
  },
  {
    id: 'ch-5',
    number: 5,
    title: 'The Transpersonal Planets',
    subtitle: 'Uranus, Neptune & Pluto',
    description:
      'These distant worlds speak to generational themes and the deepest layers of transformation. Their influence unfolds over years, reshaping the foundations of your life.',
    sections: [
      { id: 's-5-1', title: 'Uranus: The Awakener', content: 'Uranus shatters old forms to make way for the new...', type: 'text' },
      { id: 's-5-2', title: 'Neptune: The Dreamer', content: 'Neptune dissolves boundaries between self and other, real and imagined...', type: 'text' },
      { id: 's-5-3', title: 'Pluto: The Transformer', content: 'Pluto takes you to the underworld and back, forever changed...', type: 'text' },
    ],
    unlocked: false,
  },
  {
    id: 'ch-6',
    number: 6,
    title: 'The Twelve Houses',
    subtitle: 'Domains of Experience',
    description:
      'The houses divide the sky into twelve areas of life -- from identity to career, from relationships to spiritual growth. They show where your planetary energies play out.',
    sections: [
      { id: 's-6-1', title: 'Angular Houses (1, 4, 7, 10)', content: 'The angular houses are points of action and initiative...', type: 'text' },
      { id: 's-6-2', title: 'Succedent Houses (2, 5, 8, 11)', content: 'Succedent houses stabilize and deepen what the angular houses initiate...', type: 'text' },
      { id: 's-6-3', title: 'Cadent Houses (3, 6, 9, 12)', content: 'Cadent houses are places of adaptation, learning, and preparation...', type: 'text' },
    ],
    unlocked: false,
  },
  {
    id: 'ch-7',
    number: 7,
    title: 'Aspects & Geometry',
    subtitle: 'The Conversations Between Planets',
    description:
      'Aspects are the angular relationships between planets. They reveal the conversations, tensions, and harmonies within your psyche.',
    sections: [
      { id: 's-7-1', title: 'Hard Aspects: Squares & Oppositions', content: 'Hard aspects create friction that drives growth...', type: 'text' },
      { id: 's-7-2', title: 'Soft Aspects: Trines & Sextiles', content: 'Soft aspects indicate natural talents and flowing energy...', type: 'text' },
      { id: 's-7-3', title: 'The Conjunction: Fusion of Forces', content: 'When planets conjoin, their energies merge into something new...', type: 'text' },
    ],
    unlocked: false,
  },
  {
    id: 'ch-8',
    number: 8,
    title: 'Transits & Timing',
    subtitle: 'The Living Sky',
    description:
      'The sky never stops moving. Transits show how the current positions of planets activate your natal chart, creating windows of opportunity and challenge.',
    sections: [
      { id: 's-8-1', title: 'Reading Transits', content: 'A transit occurs when a moving planet forms an aspect to a natal planet...', type: 'text' },
      { id: 's-8-2', title: 'Saturn Return', content: 'Around age 29, Saturn returns to its natal position, marking a pivotal threshold...', type: 'text' },
      { id: 's-8-3', title: 'Reflection: Your Current Transits', content: 'Review the transits active in your chart right now. Which one resonates most?', type: 'reflection' },
    ],
    unlocked: false,
  },
];

const sectionTypeIcons: Record<string, string> = {
  text: '\u00B6',
  exercise: '\u270E',
  meditation: '\u2727',
  reflection: '\u2728',
};

const ChapterLibraryPage: React.FC = () => {
  const [expandedChapter, setExpandedChapter] = useState<string | null>(null);

  return (
    <div
      style={{
        padding: '1.5rem 1rem 6rem',
        maxWidth: '640px',
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
          Chapter Library
        </h1>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-tertiary)', margin: 0 }}>
          Luminous Cosmic Architecture &middot; {CHAPTERS.length} chapters
        </p>
      </header>

      {/* Chapter list */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
        {CHAPTERS.map((chapter, i) => {
          const isExpanded = expandedChapter === chapter.id;

          return (
            <GlassPanel
              key={chapter.id}
              padding="0"
              borderRadius="1rem"
              style={{
                overflow: 'hidden',
                opacity: chapter.unlocked ? 1 : 0.6,
                animation: `fadeInUp 400ms cubic-bezier(0.34, 1.56, 0.64, 1) ${i * 70}ms both`,
              }}
            >
              {/* Chapter header (clickable) */}
              <button
                onClick={() => {
                  if (chapter.unlocked) {
                    setExpandedChapter(isExpanded ? null : chapter.id);
                  }
                }}
                style={{
                  width: '100%',
                  padding: '1.25rem 1.5rem',
                  textAlign: 'left',
                  display: 'flex',
                  alignItems: 'flex-start',
                  gap: '1rem',
                  cursor: chapter.unlocked ? 'pointer' : 'default',
                }}
              >
                {/* Chapter number */}
                <div
                  style={{
                    flexShrink: 0,
                    width: '40px',
                    height: '40px',
                    borderRadius: '50%',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    background: chapter.unlocked
                      ? 'linear-gradient(135deg, rgba(197, 160, 89, 0.2), rgba(154, 122, 58, 0.1))'
                      : 'rgba(138, 156, 145, 0.1)',
                    fontFamily: "'Cormorant Garamond', serif",
                    fontSize: '1.125rem',
                    fontWeight: 600,
                    color: chapter.unlocked ? 'var(--text-accent)' : 'var(--text-tertiary)',
                  }}
                >
                  {chapter.unlocked ? chapter.number : '\u{1F512}'}
                </div>

                <div style={{ flex: 1, minWidth: 0 }}>
                  <div
                    style={{
                      fontSize: '0.65rem',
                      color: 'var(--text-accent)',
                      textTransform: 'uppercase',
                      letterSpacing: '0.1em',
                      fontWeight: 600,
                      marginBottom: '0.15rem',
                    }}
                  >
                    Chapter {chapter.number}
                  </div>
                  <h3
                    style={{
                      fontFamily: "'Cormorant Garamond', serif",
                      fontSize: '1.2rem',
                      fontWeight: 600,
                      color: 'var(--text-primary)',
                      marginBottom: '0.15rem',
                      lineHeight: 1.3,
                    }}
                  >
                    {chapter.title}
                  </h3>
                  <div
                    style={{
                      fontSize: '0.8rem',
                      color: 'var(--text-secondary)',
                      fontStyle: 'italic',
                      fontFamily: "'Cormorant Garamond', serif",
                    }}
                  >
                    {chapter.subtitle}
                  </div>
                </div>

                {/* Expand indicator */}
                {chapter.unlocked && (
                  <div
                    style={{
                      flexShrink: 0,
                      fontSize: '0.85rem',
                      color: 'var(--text-tertiary)',
                      transform: isExpanded ? 'rotate(180deg)' : 'rotate(0)',
                      transition: 'transform 350ms cubic-bezier(0.34, 1.56, 0.64, 1)',
                    }}
                  >
                    &#9662;
                  </div>
                )}
              </button>

              {/* Expanded content */}
              {isExpanded && (
                <div
                  style={{
                    padding: '0 1.5rem 1.25rem',
                    animation: 'fadeIn 300ms ease both',
                  }}
                >
                  <p
                    style={{
                      fontSize: '0.875rem',
                      color: 'var(--text-secondary)',
                      lineHeight: 1.7,
                      marginBottom: '1rem',
                    }}
                  >
                    {chapter.description}
                  </p>

                  {/* Sections list */}
                  <div
                    style={{
                      display: 'flex',
                      flexDirection: 'column',
                      gap: '0.5rem',
                    }}
                  >
                    {chapter.sections.map((section) => (
                      <div
                        key={section.id}
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: '0.75rem',
                          padding: '0.75rem 1rem',
                          borderRadius: '0.5rem',
                          background: 'rgba(197, 160, 89, 0.05)',
                          border: '1px solid var(--border-subtle)',
                          cursor: 'pointer',
                          transition: 'background 200ms ease',
                        }}
                        onMouseEnter={(e) => {
                          (e.currentTarget as HTMLElement).style.background =
                            'rgba(197, 160, 89, 0.12)';
                        }}
                        onMouseLeave={(e) => {
                          (e.currentTarget as HTMLElement).style.background =
                            'rgba(197, 160, 89, 0.05)';
                        }}
                      >
                        <span
                          style={{
                            fontSize: '1rem',
                            color: 'var(--text-accent)',
                            width: '20px',
                            textAlign: 'center',
                          }}
                        >
                          {sectionTypeIcons[section.type] || '\u00B6'}
                        </span>
                        <span
                          style={{
                            fontSize: '0.85rem',
                            color: 'var(--text-primary)',
                            fontWeight: 500,
                          }}
                        >
                          {section.title}
                        </span>
                        <span
                          style={{
                            marginLeft: 'auto',
                            fontSize: '0.65rem',
                            color: 'var(--text-tertiary)',
                            textTransform: 'uppercase',
                            letterSpacing: '0.05em',
                          }}
                        >
                          {section.type}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </GlassPanel>
          );
        })}
      </div>
    </div>
  );
};

export default ChapterLibraryPage;
