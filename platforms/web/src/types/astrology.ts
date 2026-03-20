/** Zodiac sign enumeration */
export type ZodiacSign =
  | 'Aries' | 'Taurus' | 'Gemini' | 'Cancer'
  | 'Leo' | 'Virgo' | 'Libra' | 'Scorpio'
  | 'Sagittarius' | 'Capricorn' | 'Aquarius' | 'Pisces';

/** Planet enumeration */
export type Planet =
  | 'Sun' | 'Moon' | 'Mercury' | 'Venus' | 'Mars'
  | 'Jupiter' | 'Saturn' | 'Uranus' | 'Neptune' | 'Pluto'
  | 'NorthNode' | 'SouthNode' | 'Chiron' | 'Ascendant' | 'Midheaven';

/** Element classification */
export type Element = 'Fire' | 'Earth' | 'Air' | 'Water';

/** Modality classification */
export type Modality = 'Cardinal' | 'Fixed' | 'Mutable';

/** Aspect type between two celestial bodies */
export type AspectType =
  | 'conjunction' | 'opposition' | 'trine'
  | 'square' | 'sextile' | 'quincunx';

/** Moon phase names */
export type MoonPhaseName =
  | 'New Moon' | 'Waxing Crescent' | 'First Quarter' | 'Waxing Gibbous'
  | 'Full Moon' | 'Waning Gibbous' | 'Last Quarter' | 'Waning Crescent';

/** Celestial position in degrees (0-360) */
export interface CelestialPosition {
  planet: Planet;
  longitude: number; // 0-360 ecliptic degrees
  sign: ZodiacSign;
  signDegree: number; // 0-30 within sign
  retrograde: boolean;
  house: number; // 1-12
}

/** House cusp position */
export interface HouseCusp {
  house: number; // 1-12
  longitude: number; // 0-360
  sign: ZodiacSign;
  signDegree: number;
}

/** Aspect between two celestial bodies */
export interface Aspect {
  planet1: Planet;
  planet2: Planet;
  type: AspectType;
  orb: number; // deviation in degrees
  applying: boolean; // true if aspect is tightening
}

/** Complete natal chart data */
export interface NatalChart {
  positions: CelestialPosition[];
  houses: HouseCusp[];
  aspects: Aspect[];
  ascendantSign: ZodiacSign;
  midheavenSign: ZodiacSign;
  sunSign: ZodiacSign;
  moonSign: ZodiacSign;
}

/** Birth data input */
export interface BirthData {
  name: string;
  birthDate: string; // ISO date string
  birthTime: string; // HH:MM format
  birthPlace: string;
  latitude: number;
  longitude: number;
  timezone: string;
}

/** Transit event */
export interface TransitEvent {
  transitPlanet: Planet;
  natalPlanet: Planet;
  aspectType: AspectType;
  description: string;
  startDate: string;
  peakDate: string;
  endDate: string;
  intensity: 'mild' | 'moderate' | 'strong';
}

/** Daily insight */
export interface DailyInsight {
  date: string;
  moonPhase: MoonPhaseName;
  moonSign: ZodiacSign;
  sunSign: ZodiacSign;
  mainTheme: string;
  reflectionPrompt: string;
  transits: TransitEvent[];
  affirmation: string;
}

/** Journal entry */
export interface JournalEntry {
  id: string;
  date: string;
  prompt: string;
  content: string;
  mood: string;
  tags: string[];
  createdAt: string;
  updatedAt: string;
}

/** Moon phase data */
export interface MoonPhaseData {
  name: MoonPhaseName;
  illumination: number; // 0-100
  age: number; // days since new moon
  emoji: string;
  description: string;
}

/** Chapter in the book library */
export interface Chapter {
  id: string;
  number: number;
  title: string;
  subtitle: string;
  description: string;
  sections: ChapterSection[];
  unlocked: boolean;
}

/** Section within a chapter */
export interface ChapterSection {
  id: string;
  title: string;
  content: string;
  type: 'text' | 'exercise' | 'meditation' | 'reflection';
}

/** User profile */
export interface UserProfile {
  birthData: BirthData;
  natalChart: NatalChart | null;
  journals: JournalEntry[];
  completedChapters: string[];
  onboardingComplete: boolean;
  themeMode: 'day' | 'night';
  createdAt: string;
}

/** Zodiac sign metadata */
export interface ZodiacSignInfo {
  sign: ZodiacSign;
  glyph: string;
  element: Element;
  modality: Modality;
  ruler: Planet;
  startDegree: number;
  color: string;
}

/** Planet metadata */
export interface PlanetInfo {
  planet: Planet;
  glyph: string;
  color: string;
  description: string;
}

/** Aspect metadata */
export interface AspectInfo {
  type: AspectType;
  angle: number;
  orb: number;
  color: string;
  dashArray: string;
  symbol: string;
}

/** All zodiac sign definitions */
export const ZODIAC_SIGNS: ZodiacSignInfo[] = [
  { sign: 'Aries', glyph: '\u2648', element: 'Fire', modality: 'Cardinal', ruler: 'Mars', startDegree: 0, color: '#C5523F' },
  { sign: 'Taurus', glyph: '\u2649', element: 'Earth', modality: 'Fixed', ruler: 'Venus', startDegree: 30, color: '#6B8E5E' },
  { sign: 'Gemini', glyph: '\u264A', element: 'Air', modality: 'Mutable', ruler: 'Mercury', startDegree: 60, color: '#C5A059' },
  { sign: 'Cancer', glyph: '\u264B', element: 'Water', modality: 'Cardinal', ruler: 'Moon', startDegree: 90, color: '#7BA3B0' },
  { sign: 'Leo', glyph: '\u264C', element: 'Fire', modality: 'Fixed', ruler: 'Sun', startDegree: 120, color: '#D4A843' },
  { sign: 'Virgo', glyph: '\u264D', element: 'Earth', modality: 'Mutable', ruler: 'Mercury', startDegree: 150, color: '#8A9C6E' },
  { sign: 'Libra', glyph: '\u264E', element: 'Air', modality: 'Cardinal', ruler: 'Venus', startDegree: 180, color: '#B08DAB' },
  { sign: 'Scorpio', glyph: '\u264F', element: 'Water', modality: 'Fixed', ruler: 'Pluto', startDegree: 210, color: '#8B4553' },
  { sign: 'Sagittarius', glyph: '\u2650', element: 'Fire', modality: 'Mutable', ruler: 'Jupiter', startDegree: 240, color: '#9A6B3A' },
  { sign: 'Capricorn', glyph: '\u2651', element: 'Earth', modality: 'Cardinal', ruler: 'Saturn', startDegree: 270, color: '#5C6B5E' },
  { sign: 'Aquarius', glyph: '\u2652', element: 'Air', modality: 'Fixed', ruler: 'Uranus', startDegree: 300, color: '#5B7B8A' },
  { sign: 'Pisces', glyph: '\u2653', element: 'Water', modality: 'Mutable', ruler: 'Neptune', startDegree: 330, color: '#7B6B8A' },
];

/** Planet glyph definitions */
export const PLANET_INFO: PlanetInfo[] = [
  { planet: 'Sun', glyph: '\u2609', color: '#D4A843', description: 'Core identity & vitality' },
  { planet: 'Moon', glyph: '\u263D', color: '#C4BFAA', description: 'Emotions & inner world' },
  { planet: 'Mercury', glyph: '\u263F', color: '#A8B87E', description: 'Communication & intellect' },
  { planet: 'Venus', glyph: '\u2640', color: '#B08DAB', description: 'Love, beauty & values' },
  { planet: 'Mars', glyph: '\u2642', color: '#C5523F', description: 'Drive, energy & action' },
  { planet: 'Jupiter', glyph: '\u2643', color: '#9A6B3A', description: 'Expansion & wisdom' },
  { planet: 'Saturn', glyph: '\u2644', color: '#5C6B5E', description: 'Structure & discipline' },
  { planet: 'Uranus', glyph: '\u2645', color: '#5B7B8A', description: 'Innovation & liberation' },
  { planet: 'Neptune', glyph: '\u2646', color: '#7B6B8A', description: 'Dreams & transcendence' },
  { planet: 'Pluto', glyph: '\u2647', color: '#8B4553', description: 'Transformation & power' },
  { planet: 'NorthNode', glyph: '\u260A', color: '#C5A059', description: 'Life direction & growth' },
  { planet: 'SouthNode', glyph: '\u260B', color: '#8A9C91', description: 'Past mastery & release' },
  { planet: 'Chiron', glyph: '\u26B7', color: '#7BA3B0', description: 'Wound & healing gift' },
  { planet: 'Ascendant', glyph: 'AC', color: '#E6D0A1', description: 'Rising sign & persona' },
  { planet: 'Midheaven', glyph: 'MC', color: '#E6D0A1', description: 'Career & public image' },
];

/** Aspect definitions */
export const ASPECT_INFO: AspectInfo[] = [
  { type: 'conjunction', angle: 0, orb: 8, color: '#C5A059', dashArray: '', symbol: '\u260C' },
  { type: 'opposition', angle: 180, orb: 8, color: '#C5523F', dashArray: '8,4', symbol: '\u260D' },
  { type: 'trine', angle: 120, orb: 7, color: '#6B8E5E', dashArray: '', symbol: '\u25B3' },
  { type: 'square', angle: 90, orb: 7, color: '#8B4553', dashArray: '4,4', symbol: '\u25A1' },
  { type: 'sextile', angle: 60, orb: 5, color: '#5B7B8A', dashArray: '2,4', symbol: '\u26B9' },
  { type: 'quincunx', angle: 150, orb: 3, color: '#7B6B8A', dashArray: '1,3', symbol: 'Qx' },
];
