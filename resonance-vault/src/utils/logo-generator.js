/**
 * Resonance Vault — Dynamic Logo/Emblem Generator
 * Creates unique SVG logos for each portfolio based on language & name
 */

// Language → icon mapping with color associations
const LANGUAGE_ICONS = {
  JavaScript: { glyph: 'JS', color: '#F7DF1E', bg: '#323330' },
  TypeScript: { glyph: 'TS', color: '#3178C6', bg: '#1B2838' },
  Python: { glyph: 'Py', color: '#3776AB', bg: '#1A2332' },
  Rust: { glyph: 'Rs', color: '#DEA584', bg: '#1A1110' },
  Go: { glyph: 'Go', color: '#00ADD8', bg: '#0E1921' },
  Java: { glyph: 'Jv', color: '#ED8B00', bg: '#1A1207' },
  'C++': { glyph: 'C+', color: '#00599C', bg: '#0E1A28' },
  C: { glyph: 'C', color: '#A8B9CC', bg: '#15191E' },
  Ruby: { glyph: 'Rb', color: '#CC342D', bg: '#1A0A09' },
  PHP: { glyph: 'Ph', color: '#777BB4', bg: '#14142A' },
  Swift: { glyph: 'Sw', color: '#F05138', bg: '#1A0C09' },
  Kotlin: { glyph: 'Kt', color: '#7F52FF', bg: '#140E2A' },
  Dart: { glyph: 'Dt', color: '#0175C2', bg: '#0E1921' },
  Shell: { glyph: 'Sh', color: '#89E051', bg: '#111A0E' },
  HTML: { glyph: 'Ht', color: '#E34F26', bg: '#1A0D07' },
  CSS: { glyph: 'Cs', color: '#1572B6', bg: '#0E1928' },
  Markdown: { glyph: 'Md', color: '#083FA1', bg: '#0E1428' },
  default: { glyph: '◇', color: '#59C9A5', bg: '#0A1C14' },
};

function generatePortfolioLogo(name, language, color) {
  const lang = LANGUAGE_ICONS[language] || LANGUAGE_ICONS.default;
  const accentColor = color || lang.color;
  const initials = name.split(/[-_\s]/).map(w => w[0]).join('').toUpperCase().slice(0, 2);

  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" width="120" height="120">
  <defs>
    <radialGradient id="glow-${name}" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="${accentColor}" stop-opacity="0.3"/>
      <stop offset="70%" stop-color="${accentColor}" stop-opacity="0.05"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
    <filter id="bio-${name}">
      <feGaussianBlur in="SourceGraphic" stdDeviation="1.5"/>
    </filter>
  </defs>
  <!-- Bioluminescent glow background -->
  <rect width="120" height="120" rx="20" fill="${lang.bg}"/>
  <circle cx="60" cy="60" r="50" fill="url(#glow-${name})">
    <animate attributeName="r" values="45;52;45" dur="4s" repeatCount="indefinite"/>
    <animate attributeName="opacity" values="0.8;1;0.8" dur="4s" repeatCount="indefinite"/>
  </circle>
  <!-- Outer ring (bioluminescent membrane) -->
  <circle cx="60" cy="60" r="42" fill="none" stroke="${accentColor}" stroke-width="1" opacity="0.3">
    <animate attributeName="stroke-opacity" values="0.2;0.5;0.2" dur="6s" repeatCount="indefinite"/>
  </circle>
  <!-- Language glyph (small, top) -->
  <text x="60" y="38" text-anchor="middle" font-family="Manrope, sans-serif" font-size="11" font-weight="600" fill="${accentColor}" opacity="0.7">${lang.glyph}</text>
  <!-- Initials (large, center) -->
  <text x="60" y="72" text-anchor="middle" font-family="Cormorant Garamond, serif" font-size="32" font-weight="600" fill="#FAFAF8">${initials}</text>
  <!-- Bottom accent line -->
  <line x1="35" y1="85" x2="85" y2="85" stroke="${accentColor}" stroke-width="1" opacity="0.4"/>
</svg>`;
}

function generateCallsign(repoName) {
  const words = repoName.replace(/[-_]/g, ' ').split(/\s+/);
  const formatted = words.map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(' ');
  return `Operation: ${formatted}`;
}

export { generatePortfolioLogo, generateCallsign, LANGUAGE_ICONS };
