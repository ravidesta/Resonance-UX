import React, { useState, useMemo, useCallback } from 'react';
import glossaryData from '../../../../shared/glossary/astrology_glossary.json';

/* ------------------------------------------------------------------ */
/*  Types                                                              */
/* ------------------------------------------------------------------ */

interface GlossaryTerm {
  id: string;
  term: string;
  definition: string;
  category: string;
  relatedTerms: string[];
  symbol: string;
}

interface Category {
  id: string;
  name: string;
  icon: string;
}

/* ------------------------------------------------------------------ */
/*  Theme tokens                                                       */
/* ------------------------------------------------------------------ */

const T = {
  bg: '#FAFAF8',
  darkGreen: '#0A1C14',
  green: '#122E21',
  gold: '#C5A059',
  glass: 'rgba(255,255,255,0.7)',
  glassBorder: 'rgba(255,255,255,0.35)',
  blur: 'blur(12px)',
  cardShadow: '0 2px 16px rgba(10,28,20,0.07)',
  headerFont: "'Cormorant Garamond', 'Cormorant', Georgia, serif",
  bodyFont:
    "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
  radius: 14,
  radiusSm: 10,
} as const;

/* ------------------------------------------------------------------ */
/*  Inline style helpers                                               */
/* ------------------------------------------------------------------ */

const styles: Record<string, React.CSSProperties> = {
  /* Page wrapper */
  page: {
    minHeight: '100vh',
    backgroundColor: T.bg,
    fontFamily: T.bodyFont,
    color: T.darkGreen,
    padding: '0 0 80px',
  },

  /* Hero / header area */
  hero: {
    textAlign: 'center',
    padding: '56px 24px 36px',
    background: `linear-gradient(168deg, ${T.green} 0%, ${T.darkGreen} 100%)`,
    color: '#fff',
  },
  heroTitle: {
    fontFamily: T.headerFont,
    fontSize: '2.75rem',
    fontWeight: 500,
    letterSpacing: '0.02em',
    margin: 0,
  },
  heroSub: {
    marginTop: 10,
    fontSize: '1.05rem',
    opacity: 0.75,
    fontWeight: 400,
  },

  /* Search bar */
  searchWrap: {
    maxWidth: 520,
    margin: '-22px auto 0',
    padding: '0 20px',
    position: 'relative' as const,
    zIndex: 2,
  },
  searchInput: {
    width: '100%',
    padding: '14px 20px 14px 46px',
    fontSize: '1rem',
    fontFamily: T.bodyFont,
    border: `1px solid ${T.glassBorder}`,
    borderRadius: T.radius,
    background: T.glass,
    backdropFilter: T.blur,
    WebkitBackdropFilter: T.blur,
    boxShadow: T.cardShadow,
    outline: 'none',
    color: T.darkGreen,
    boxSizing: 'border-box' as const,
  },
  searchIcon: {
    position: 'absolute' as const,
    left: 36,
    top: '50%',
    transform: 'translateY(-50%)',
    fontSize: '1.1rem',
    opacity: 0.45,
    pointerEvents: 'none' as const,
  },

  /* Category tabs */
  tabsRow: {
    display: 'flex',
    flexWrap: 'wrap' as const,
    justifyContent: 'center',
    gap: 8,
    padding: '28px 20px 8px',
    maxWidth: 820,
    margin: '0 auto',
  },
  tab: {
    padding: '7px 16px',
    fontSize: '0.88rem',
    borderRadius: 100,
    border: `1px solid ${T.glassBorder}`,
    background: T.glass,
    backdropFilter: T.blur,
    WebkitBackdropFilter: T.blur,
    cursor: 'pointer',
    fontFamily: T.bodyFont,
    color: T.green,
    transition: 'all 0.2s',
    whiteSpace: 'nowrap' as const,
  },
  tabActive: {
    background: T.green,
    color: '#fff',
    borderColor: T.green,
  },

  /* Alphabet jump bar */
  alphaBar: {
    display: 'flex',
    flexWrap: 'wrap' as const,
    justifyContent: 'center',
    gap: 4,
    padding: '18px 20px 4px',
    maxWidth: 720,
    margin: '0 auto',
  },
  alphaBtn: {
    width: 30,
    height: 30,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 8,
    fontSize: '0.82rem',
    fontWeight: 600,
    border: 'none',
    background: 'transparent',
    color: T.green,
    cursor: 'pointer',
    fontFamily: T.bodyFont,
    transition: 'all 0.15s',
  },
  alphaBtnActive: {
    background: T.gold,
    color: '#fff',
  },
  alphaBtnDisabled: {
    opacity: 0.25,
    cursor: 'default',
  },

  /* Term list */
  list: {
    maxWidth: 720,
    margin: '20px auto 0',
    padding: '0 20px',
    display: 'flex',
    flexDirection: 'column' as const,
    gap: 12,
  },
  letterHeader: {
    fontFamily: T.headerFont,
    fontSize: '1.6rem',
    fontWeight: 600,
    color: T.gold,
    margin: '28px 0 6px',
    paddingLeft: 4,
  },

  /* Card */
  card: {
    background: T.glass,
    backdropFilter: T.blur,
    WebkitBackdropFilter: T.blur,
    border: `1px solid ${T.glassBorder}`,
    borderRadius: T.radius,
    boxShadow: T.cardShadow,
    padding: '18px 22px',
    cursor: 'pointer',
    transition: 'box-shadow 0.2s, transform 0.15s',
  },
  cardExpanded: {
    boxShadow: '0 4px 24px rgba(10,28,20,0.11)',
    transform: 'scale(1.005)',
  },
  cardHeader: {
    display: 'flex',
    alignItems: 'center',
    gap: 12,
  },
  cardSymbol: {
    fontSize: '1.35rem',
    width: 38,
    height: 38,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 10,
    background: `linear-gradient(135deg, ${T.green}, ${T.darkGreen})`,
    color: T.gold,
    flexShrink: 0,
    fontWeight: 600,
  },
  cardTitle: {
    fontFamily: T.headerFont,
    fontSize: '1.25rem',
    fontWeight: 600,
    color: T.darkGreen,
    flex: 1,
  },
  cardChevron: {
    fontSize: '0.85rem',
    opacity: 0.35,
    transition: 'transform 0.2s',
    flexShrink: 0,
  },
  cardBody: {
    marginTop: 14,
    paddingLeft: 50,
  },
  cardDef: {
    fontSize: '0.97rem',
    lineHeight: 1.7,
    color: T.darkGreen,
    opacity: 0.85,
    margin: 0,
  },
  cardCat: {
    display: 'inline-block',
    marginTop: 12,
    padding: '3px 12px',
    fontSize: '0.78rem',
    borderRadius: 100,
    background: 'rgba(197,160,89,0.13)',
    color: T.gold,
    fontWeight: 600,
    letterSpacing: '0.03em',
  },
  relatedWrap: {
    marginTop: 12,
    display: 'flex',
    flexWrap: 'wrap' as const,
    gap: 6,
    alignItems: 'center',
  },
  relatedLabel: {
    fontSize: '0.8rem',
    opacity: 0.5,
    marginRight: 2,
  },
  relatedTag: {
    fontSize: '0.82rem',
    padding: '3px 11px',
    borderRadius: 100,
    border: `1px solid ${T.glassBorder}`,
    background: 'rgba(18,46,33,0.06)',
    color: T.green,
    cursor: 'pointer',
    fontFamily: T.bodyFont,
    transition: 'all 0.15s',
  },

  /* Count badge */
  count: {
    textAlign: 'center' as const,
    padding: '18px 20px 0',
    fontSize: '0.88rem',
    opacity: 0.45,
  },
};

/* ------------------------------------------------------------------ */
/*  Component                                                          */
/* ------------------------------------------------------------------ */

const GlossaryPage: React.FC = () => {
  const terms: GlossaryTerm[] = glossaryData.terms;
  const categories: Category[] = glossaryData.categories;

  const [search, setSearch] = useState('');
  const [activeCategory, setActiveCategory] = useState<string | null>(null);
  const [expandedId, setExpandedId] = useState<string | null>(null);

  /* ---- derived data ---- */

  const filtered = useMemo(() => {
    let list = terms;
    if (activeCategory) {
      list = list.filter((t) => t.category === activeCategory);
    }
    if (search.trim()) {
      const q = search.trim().toLowerCase();
      list = list.filter(
        (t) =>
          t.term.toLowerCase().includes(q) ||
          t.definition.toLowerCase().includes(q),
      );
    }
    return list.sort((a, b) => a.term.localeCompare(b.term));
  }, [terms, activeCategory, search]);

  const lettersAvailable = useMemo(
    () => new Set(filtered.map((t) => t.term[0].toUpperCase())),
    [filtered],
  );

  const grouped = useMemo(() => {
    const map: Record<string, GlossaryTerm[]> = {};
    filtered.forEach((t) => {
      const letter = t.term[0].toUpperCase();
      (map[letter] ??= []).push(t);
    });
    return Object.entries(map).sort(([a], [b]) => a.localeCompare(b));
  }, [filtered]);

  const categoryNameMap = useMemo(() => {
    const m: Record<string, string> = {};
    categories.forEach((c) => (m[c.id] = c.name));
    return m;
  }, [categories]);

  /* ---- helpers ---- */

  const scrollToLetter = useCallback((letter: string) => {
    const el = document.getElementById(`glossary-letter-${letter}`);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, []);

  const handleRelated = useCallback(
    (id: string) => {
      const target = terms.find((t) => t.id === id);
      if (target) {
        setSearch(target.term);
        setActiveCategory(null);
        setExpandedId(id);
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }
    },
    [terms],
  );

  const toggle = useCallback(
    (id: string) => setExpandedId((prev) => (prev === id ? null : id)),
    [],
  );

  /* ---- render ---- */

  const ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  return (
    <div style={styles.page}>
      {/* Hero */}
      <header style={styles.hero}>
        <h1 style={styles.heroTitle}>Astrology Glossary</h1>
        <p style={styles.heroSub}>
          Explore the language of the stars — from signs to synastry
        </p>
      </header>

      {/* Search */}
      <div style={styles.searchWrap}>
        <span style={styles.searchIcon}>&#x1F50D;</span>
        <input
          type="text"
          placeholder="Search terms or definitions..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          style={styles.searchInput}
        />
      </div>

      {/* Category Tabs */}
      <div style={styles.tabsRow}>
        <button
          style={{
            ...styles.tab,
            ...(activeCategory === null ? styles.tabActive : {}),
          }}
          onClick={() => setActiveCategory(null)}
        >
          All
        </button>
        {categories.map((cat) => (
          <button
            key={cat.id}
            style={{
              ...styles.tab,
              ...(activeCategory === cat.id ? styles.tabActive : {}),
            }}
            onClick={() =>
              setActiveCategory((prev) => (prev === cat.id ? null : cat.id))
            }
          >
            {cat.icon} {cat.name}
          </button>
        ))}
      </div>

      {/* Alphabet bar */}
      <nav style={styles.alphaBar}>
        {ALPHABET.map((l) => {
          const available = lettersAvailable.has(l);
          return (
            <button
              key={l}
              disabled={!available}
              style={{
                ...styles.alphaBtn,
                ...(available ? {} : styles.alphaBtnDisabled),
              }}
              onClick={() => available && scrollToLetter(l)}
              onMouseEnter={(e) => {
                if (available)
                  Object.assign(e.currentTarget.style, styles.alphaBtnActive);
              }}
              onMouseLeave={(e) => {
                Object.assign(e.currentTarget.style, {
                  background: 'transparent',
                  color: T.green,
                });
              }}
            >
              {l}
            </button>
          );
        })}
      </nav>

      {/* Count */}
      <p style={styles.count}>
        {filtered.length} term{filtered.length !== 1 ? 's' : ''}
      </p>

      {/* Term list */}
      <div style={styles.list}>
        {grouped.map(([letter, group]) => (
          <React.Fragment key={letter}>
            <div id={`glossary-letter-${letter}`} style={styles.letterHeader}>
              {letter}
            </div>
            {group.map((t) => {
              const open = expandedId === t.id;
              return (
                <div
                  key={t.id}
                  style={{
                    ...styles.card,
                    ...(open ? styles.cardExpanded : {}),
                  }}
                  onClick={() => toggle(t.id)}
                >
                  <div style={styles.cardHeader}>
                    <span style={styles.cardSymbol}>{t.symbol}</span>
                    <span style={styles.cardTitle}>{t.term}</span>
                    <span
                      style={{
                        ...styles.cardChevron,
                        transform: open ? 'rotate(180deg)' : 'rotate(0deg)',
                      }}
                    >
                      &#9662;
                    </span>
                  </div>

                  {open && (
                    <div style={styles.cardBody}>
                      <p style={styles.cardDef}>{t.definition}</p>
                      <span style={styles.cardCat}>
                        {categoryNameMap[t.category] ?? t.category}
                      </span>

                      {t.relatedTerms.length > 0 && (
                        <div style={styles.relatedWrap}>
                          <span style={styles.relatedLabel}>Related:</span>
                          {t.relatedTerms.map((rid) => {
                            const related = terms.find((x) => x.id === rid);
                            return (
                              <button
                                key={rid}
                                style={styles.relatedTag}
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleRelated(rid);
                                }}
                              >
                                {related ? related.term : rid}
                              </button>
                            );
                          })}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </React.Fragment>
        ))}

        {filtered.length === 0 && (
          <p style={{ textAlign: 'center', padding: 40, opacity: 0.5 }}>
            No terms match your search.
          </p>
        )}
      </div>
    </div>
  );
};

export default GlossaryPage;
