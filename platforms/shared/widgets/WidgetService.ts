/**
 * Luminous Cosmic Architecture™ — Widget Service
 * Dashboard widgets providing at-a-glance cosmic insights
 */

export interface Widget {
  id: string;
  type: WidgetType;
  title: string;
  size: 'small' | 'medium' | 'large';
  position: number;
  isVisible: boolean;
  refreshInterval: number;
  lastRefreshed?: string;
}

export type WidgetType =
  | 'moon-phase'
  | 'daily-horoscope'
  | 'transit-alert'
  | 'meditation-timer'
  | 'journal-streak'
  | 'compatibility'
  | 'retrograde-tracker'
  | 'element-balance';

export interface MoonPhaseData {
  phase: string;
  illumination: number;
  emoji: string;
  sign: string;
  nextPhase: { name: string; date: string };
  message: string;
}

export interface DailyHoroscopeData {
  sign: string;
  date: string;
  summary: string;
  luckyNumber: number;
  luckyColor: string;
  mood: string;
  compatibility: string;
}

export interface TransitAlertData {
  transits: Array<{
    planet: string;
    sign: string;
    aspect: string;
    targetPlanet?: string;
    significance: 'high' | 'medium' | 'low';
    message: string;
  }>;
}

export interface CompatibilityData {
  sign1: string;
  sign2: string;
  score: number;
  strengths: string[];
  challenges: string[];
  advice: string;
}

export interface RetrogradeTrackerData {
  retrogrades: Array<{
    planet: string;
    isRetrograde: boolean;
    startDate?: string;
    endDate?: string;
    sign: string;
    advice: string;
  }>;
}

export interface ElementBalanceData {
  fire: number;
  earth: number;
  air: number;
  water: number;
  dominant: string;
  message: string;
}

// ─── Moon Phase Calculator ───────────────────────────────────────

const MOON_PHASES = [
  { name: 'New Moon', emoji: '\u{1F311}', range: [0, 1.85] },
  { name: 'Waxing Crescent', emoji: '\u{1F312}', range: [1.85, 5.53] },
  { name: 'First Quarter', emoji: '\u{1F313}', range: [5.53, 9.22] },
  { name: 'Waxing Gibbous', emoji: '\u{1F314}', range: [9.22, 12.91] },
  { name: 'Full Moon', emoji: '\u{1F315}', range: [12.91, 16.61] },
  { name: 'Waning Gibbous', emoji: '\u{1F316}', range: [16.61, 20.29] },
  { name: 'Last Quarter', emoji: '\u{1F317}', range: [20.29, 23.99] },
  { name: 'Waning Crescent', emoji: '\u{1F318}', range: [23.99, 29.53] },
];

const ZODIAC_SIGNS = [
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

const ELEMENT_MAP: Record<string, string> = {
  Aries: 'fire', Leo: 'fire', Sagittarius: 'fire',
  Taurus: 'earth', Virgo: 'earth', Capricorn: 'earth',
  Gemini: 'air', Libra: 'air', Aquarius: 'air',
  Cancer: 'water', Scorpio: 'water', Pisces: 'water',
};

export function getMoonPhase(date: Date = new Date()): MoonPhaseData {
  const knownNewMoon = new Date('2000-01-06T18:14:00Z').getTime();
  const synodicMonth = 29.53058770576;
  const daysSinceKnown = (date.getTime() - knownNewMoon) / 86400000;
  const moonAge = ((daysSinceKnown % synodicMonth) + synodicMonth) % synodicMonth;

  const phase = MOON_PHASES.find(p => moonAge >= p.range[0] && moonAge < p.range[1]) || MOON_PHASES[0];
  const illumination = Math.round(50 * (1 - Math.cos((moonAge / synodicMonth) * 2 * Math.PI)));

  const signIndex = Math.floor((moonAge / synodicMonth) * 12) % 12;
  const moonSign = ZODIAC_SIGNS[signIndex];

  const currentPhaseIndex = MOON_PHASES.indexOf(phase);
  const nextPhaseIndex = (currentPhaseIndex + 1) % MOON_PHASES.length;
  const daysToNext = MOON_PHASES[nextPhaseIndex].range[0] - moonAge;
  const nextDate = new Date(date.getTime() + (daysToNext > 0 ? daysToNext : daysToNext + synodicMonth) * 86400000);

  const messages: Record<string, string> = {
    'New Moon': 'A time for new beginnings and setting intentions.',
    'Waxing Crescent': 'Your intentions are taking root. Nurture your goals.',
    'First Quarter': 'Decision time. Push through challenges and commit.',
    'Waxing Gibbous': 'Refine and adjust. Trust the process.',
    'Full Moon': 'Illumination and culmination. Celebrate and release.',
    'Waning Gibbous': 'Share your wisdom. Express gratitude.',
    'Last Quarter': 'Let go and forgive. Clear space for renewal.',
    'Waning Crescent': 'Rest and reflect. Surrender before renewal.',
  };

  return {
    phase: phase.name, illumination, emoji: phase.emoji, sign: moonSign,
    nextPhase: { name: MOON_PHASES[nextPhaseIndex].name, date: nextDate.toISOString() },
    message: messages[phase.name] || '',
  };
}

export function calculateCompatibility(sign1: string, sign2: string): CompatibilityData {
  const el1 = ELEMENT_MAP[sign1] || 'fire';
  const el2 = ELEMENT_MAP[sign2] || 'fire';

  let score: number;
  let strengths: string[];
  let challenges: string[];
  let advice: string;

  if (el1 === el2) {
    score = 85 + Math.floor(Math.random() * 10);
    strengths = ['Deep understanding', 'Shared values', 'Natural harmony'];
    challenges = ['Can become too comfortable', 'Similar blind spots'];
    advice = 'Your shared element creates an easy bond. Challenge each other to grow.';
  } else if (
    (el1 === 'fire' && el2 === 'air') || (el1 === 'air' && el2 === 'fire') ||
    (el1 === 'earth' && el2 === 'water') || (el1 === 'water' && el2 === 'earth')
  ) {
    score = 75 + Math.floor(Math.random() * 15);
    strengths = ['Complementary energies', 'Mutual inspiration', 'Dynamic balance'];
    challenges = ['Different paces', 'Communication styles differ'];
    advice = 'Your elements naturally support each other. Embrace the differences.';
  } else {
    score = 55 + Math.floor(Math.random() * 20);
    strengths = ['Growth through challenge', 'Expanded perspective', 'Transformative potential'];
    challenges = ['Fundamental differences', 'Requires patience', 'Different needs'];
    advice = 'This pairing requires effort but offers profound growth opportunities.';
  }

  return { sign1, sign2, score, strengths, challenges, advice };
}

// ─── Service ─────────────────────────────────────────────────────

export class WidgetService {
  private widgets: Widget[] = [
    { id: 'w-moon', type: 'moon-phase', title: 'Moon Phase', size: 'medium', position: 0, isVisible: true, refreshInterval: 3600000 },
    { id: 'w-horoscope', type: 'daily-horoscope', title: 'Daily Insight', size: 'large', position: 1, isVisible: true, refreshInterval: 86400000 },
    { id: 'w-transit', type: 'transit-alert', title: 'Active Transits', size: 'medium', position: 2, isVisible: true, refreshInterval: 3600000 },
    { id: 'w-meditation', type: 'meditation-timer', title: 'Meditation', size: 'small', position: 3, isVisible: true, refreshInterval: 60000 },
    { id: 'w-journal', type: 'journal-streak', title: 'Journal Streak', size: 'small', position: 4, isVisible: true, refreshInterval: 60000 },
    { id: 'w-compat', type: 'compatibility', title: 'Compatibility', size: 'medium', position: 5, isVisible: true, refreshInterval: 86400000 },
    { id: 'w-retro', type: 'retrograde-tracker', title: 'Retrograde Watch', size: 'medium', position: 6, isVisible: true, refreshInterval: 86400000 },
    { id: 'w-elements', type: 'element-balance', title: 'Element Balance', size: 'small', position: 7, isVisible: true, refreshInterval: 86400000 },
  ];

  getWidgets(): Widget[] {
    return this.widgets.filter(w => w.isVisible).sort((a, b) => a.position - b.position);
  }

  toggleWidget(id: string): void {
    const w = this.widgets.find(w => w.id === id);
    if (w) w.isVisible = !w.isVisible;
  }

  reorderWidgets(orderedIds: string[]): void {
    orderedIds.forEach((id, i) => {
      const w = this.widgets.find(w => w.id === id);
      if (w) w.position = i;
    });
  }

  getMoonPhaseData(): MoonPhaseData {
    return getMoonPhase();
  }

  getDailyHoroscope(sign: string): DailyHoroscopeData {
    const summaries: Record<string, string> = {
      Aries: 'Bold energy flows today. Trust your instincts and take initiative.',
      Taurus: 'Grounding energy surrounds you. Focus on stability and comfort.',
      Gemini: 'Your curiosity is amplified. Engage in stimulating conversations.',
      Cancer: 'Emotional depth guides your day. Nurture close relationships.',
      Leo: 'Creative fire is ignited. Express yourself boldly.',
      Virgo: 'Precision serves you well. Organize and refine the details.',
      Libra: 'Harmony is your guiding star. Seek balance in all things.',
      Scorpio: 'Transformative power is at your fingertips. Dive deep.',
      Sagittarius: 'Adventure calls. Expand your horizons through exploration.',
      Capricorn: 'Steady progress builds toward lasting achievement.',
      Aquarius: 'Innovation sparks. Your unique perspective inspires change.',
      Pisces: 'The veil is thin. Trust your dreams and creative visions.',
    };
    return {
      sign,
      date: new Date().toISOString().split('T')[0],
      summary: summaries[sign] || 'The cosmos align in your favor today.',
      luckyNumber: Math.floor(Math.random() * 99) + 1,
      luckyColor: ['Gold', 'Silver', 'Emerald', 'Sapphire', 'Ruby', 'Amethyst'][Math.floor(Math.random() * 6)],
      mood: ['Energized', 'Reflective', 'Inspired', 'Peaceful', 'Passionate'][Math.floor(Math.random() * 5)],
      compatibility: ZODIAC_SIGNS[Math.floor(Math.random() * 12)],
    };
  }

  getTransitAlerts(): TransitAlertData {
    return {
      transits: [
        { planet: 'Sun', sign: 'Pisces', aspect: 'Conjunction', targetPlanet: 'Neptune', significance: 'high', message: 'Heightened intuition and creative vision.' },
        { planet: 'Venus', sign: 'Aries', aspect: 'Square', targetPlanet: 'Mars', significance: 'medium', message: 'Tension between desire and action.' },
        { planet: 'Mercury', sign: 'Pisces', aspect: 'Sextile', targetPlanet: 'Jupiter', significance: 'medium', message: 'Communication flows easily. Good for learning.' },
      ],
    };
  }

  getRetrogradeData(): RetrogradeTrackerData {
    return {
      retrogrades: [
        { planet: 'Mercury', isRetrograde: false, sign: 'Pisces', startDate: '2026-04-01', endDate: '2026-04-25', advice: 'Pre-retrograde shadow begins soon. Back up data.' },
        { planet: 'Venus', isRetrograde: false, sign: 'Aries', advice: 'Venus direct. Good for relationship initiatives.' },
        { planet: 'Mars', isRetrograde: false, sign: 'Cancer', advice: 'Mars direct. Channel energy into meaningful action.' },
        { planet: 'Jupiter', isRetrograde: false, sign: 'Cancer', advice: 'Jupiter direct. Embrace expansion opportunities.' },
        { planet: 'Saturn', isRetrograde: false, sign: 'Aries', advice: 'Saturn direct. Build lasting structures.' },
      ],
    };
  }

  getElementBalance(birthSigns: { sun: string; moon: string; rising: string }): ElementBalanceData {
    const counts = { fire: 0, earth: 0, air: 0, water: 0 };
    for (const sign of [birthSigns.sun, birthSigns.moon, birthSigns.rising]) {
      const el = ELEMENT_MAP[sign];
      if (el) counts[el as keyof typeof counts]++;
    }
    const dominant = Object.entries(counts).sort((a, b) => b[1] - a[1])[0][0];
    const messages: Record<string, string> = {
      fire: 'Your chart burns bright with fire. You lead with passion and courage.',
      earth: 'Earth grounds your chart. You build with patience and practicality.',
      air: 'Air lifts your chart. You process through intellect and connection.',
      water: 'Water flows through your chart. You navigate through emotion and intuition.',
    };
    return { ...counts, dominant, message: messages[dominant] || '' };
  }
}
