import { useState, useCallback, useMemo } from 'react';
import type {
  BirthData,
  NatalChart,
  CelestialPosition,
  HouseCusp,
  Aspect,
  ZodiacSign,
  Planet,
  AspectType,
} from '../types/astrology';
import { ASPECT_INFO } from '../types/astrology';

/**
 * Deterministic pseudo-random number generator from a seed string.
 * Produces a number between 0 and 1 for a given seed + index.
 */
function seededRandom(seed: string, index: number): number {
  let hash = 0;
  const str = seed + String(index);
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32-bit integer
  }
  // Normalize to 0-1
  return Math.abs((Math.sin(hash) * 43758.5453123) % 1);
}

const SIGN_NAMES: ZodiacSign[] = [
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

const PLANET_NAMES: Planet[] = [
  'Sun', 'Moon', 'Mercury', 'Venus', 'Mars',
  'Jupiter', 'Saturn', 'Uranus', 'Neptune', 'Pluto',
  'NorthNode', 'Chiron',
];

function getSignFromDegree(degree: number): ZodiacSign {
  const normalised = ((degree % 360) + 360) % 360;
  const signIndex = Math.floor(normalised / 30);
  return SIGN_NAMES[signIndex];
}

function getSignDegree(degree: number): number {
  const normalised = ((degree % 360) + 360) % 360;
  return normalised % 30;
}

function getHouseForDegree(degree: number, houses: HouseCusp[]): number {
  const normalised = ((degree % 360) + 360) % 360;
  for (let i = 0; i < 12; i++) {
    const current = houses[i].longitude;
    const next = houses[(i + 1) % 12].longitude;
    if (next > current) {
      if (normalised >= current && normalised < next) return i + 1;
    } else {
      // Wrap-around
      if (normalised >= current || normalised < next) return i + 1;
    }
  }
  return 1;
}

/**
 * Generate a realistic-looking natal chart from birth data.
 * NOTE: This is a demonstration calculator that produces deterministic
 * but astrologically-plausible positions based on the birth date seed.
 * A production app would use Swiss Ephemeris or a comparable library.
 */
function calculateChart(birthData: BirthData): NatalChart {
  const seed = `${birthData.birthDate}${birthData.birthTime}${birthData.latitude}${birthData.longitude}`;

  // Calculate approximate sun longitude from date
  const date = new Date(birthData.birthDate);
  const dayOfYear = Math.floor(
    (date.getTime() - new Date(date.getFullYear(), 0, 0).getTime()) / 86400000
  );
  const sunLongitude = ((dayOfYear - 80) * (360 / 365.25) + 360) % 360;

  // Generate Ascendant from birth time + longitude
  const timeParts = birthData.birthTime.split(':').map(Number);
  const timeDecimal = (timeParts[0] || 0) + (timeParts[1] || 0) / 60;
  const ascendantLongitude = (sunLongitude + timeDecimal * 15 + birthData.longitude + 360) % 360;

  // Generate house cusps (Placidus approximation using equal house as base)
  const houses: HouseCusp[] = [];
  for (let i = 0; i < 12; i++) {
    // Apply slight variation to each house for realism
    const variation = (i > 0 && i < 12) ? (seededRandom(seed, i + 100) - 0.5) * 6 : 0;
    const longitude = (ascendantLongitude + i * 30 + variation + 360) % 360;
    houses.push({
      house: i + 1,
      longitude,
      sign: getSignFromDegree(longitude),
      signDegree: Math.round(getSignDegree(longitude) * 100) / 100,
    });
  }

  // Generate planet positions
  const moonLongitude = (sunLongitude + seededRandom(seed, 0) * 360) % 360;

  // Mercury and Venus stay close to Sun
  const mercuryLongitude = (sunLongitude + (seededRandom(seed, 1) - 0.5) * 56) % 360;
  const venusLongitude = (sunLongitude + (seededRandom(seed, 2) - 0.5) * 94) % 360;

  // Mars through Pluto distributed
  const marsLongitude = seededRandom(seed, 3) * 360;
  const jupiterLongitude = seededRandom(seed, 4) * 360;
  const saturnLongitude = seededRandom(seed, 5) * 360;
  const uranusLongitude = seededRandom(seed, 6) * 360;
  const neptuneLongitude = seededRandom(seed, 7) * 360;
  const plutoLongitude = seededRandom(seed, 8) * 360;
  const northNodeLongitude = seededRandom(seed, 9) * 360;
  const chironLongitude = seededRandom(seed, 10) * 360;

  const longitudes: number[] = [
    sunLongitude, moonLongitude, mercuryLongitude, venusLongitude,
    marsLongitude, jupiterLongitude, saturnLongitude, uranusLongitude,
    neptuneLongitude, plutoLongitude, northNodeLongitude, chironLongitude,
  ];

  const positions: CelestialPosition[] = PLANET_NAMES.map((planet, i) => {
    const lng = ((longitudes[i] % 360) + 360) % 360;
    return {
      planet,
      longitude: Math.round(lng * 100) / 100,
      sign: getSignFromDegree(lng),
      signDegree: Math.round(getSignDegree(lng) * 100) / 100,
      retrograde: planet !== 'Sun' && planet !== 'Moon' && seededRandom(seed, i + 20) > 0.7,
      house: getHouseForDegree(lng, houses),
    };
  });

  // Add Ascendant and Midheaven as positions
  const mcLongitude = (ascendantLongitude + 270) % 360;
  positions.push({
    planet: 'Ascendant',
    longitude: Math.round(ascendantLongitude * 100) / 100,
    sign: getSignFromDegree(ascendantLongitude),
    signDegree: Math.round(getSignDegree(ascendantLongitude) * 100) / 100,
    retrograde: false,
    house: 1,
  });
  positions.push({
    planet: 'Midheaven',
    longitude: Math.round(mcLongitude * 100) / 100,
    sign: getSignFromDegree(mcLongitude),
    signDegree: Math.round(getSignDegree(mcLongitude) * 100) / 100,
    retrograde: false,
    house: 10,
  });

  // Calculate aspects between planets
  const aspects: Aspect[] = [];
  const mainPlanets = positions.filter(
    (p) => p.planet !== 'Ascendant' && p.planet !== 'Midheaven'
  );

  for (let i = 0; i < mainPlanets.length; i++) {
    for (let j = i + 1; j < mainPlanets.length; j++) {
      const p1 = mainPlanets[i];
      const p2 = mainPlanets[j];
      let diff = Math.abs(p1.longitude - p2.longitude);
      if (diff > 180) diff = 360 - diff;

      for (const aspectDef of ASPECT_INFO) {
        const orb = Math.abs(diff - aspectDef.angle);
        if (orb <= aspectDef.orb) {
          aspects.push({
            planet1: p1.planet,
            planet2: p2.planet,
            type: aspectDef.type as AspectType,
            orb: Math.round(orb * 100) / 100,
            applying: seededRandom(seed, i * 100 + j) > 0.5,
          });
          break; // Only strongest aspect between two planets
        }
      }
    }
  }

  return {
    positions,
    houses,
    aspects,
    ascendantSign: getSignFromDegree(ascendantLongitude),
    midheavenSign: getSignFromDegree(mcLongitude),
    sunSign: getSignFromDegree(sunLongitude),
    moonSign: getSignFromDegree(moonLongitude),
  };
}

interface UseChartCalculatorReturn {
  chart: NatalChart | null;
  isCalculating: boolean;
  error: string | null;
  calculate: (birthData: BirthData) => void;
  reset: () => void;
}

export function useChartCalculator(): UseChartCalculatorReturn {
  const [chart, setChart] = useState<NatalChart | null>(null);
  const [isCalculating, setIsCalculating] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const calculate = useCallback((birthData: BirthData) => {
    setIsCalculating(true);
    setError(null);

    // Simulate async calculation
    setTimeout(() => {
      try {
        const result = calculateChart(birthData);
        setChart(result);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Chart calculation failed');
      } finally {
        setIsCalculating(false);
      }
    }, 800);
  }, []);

  const reset = useCallback(() => {
    setChart(null);
    setError(null);
    setIsCalculating(false);
  }, []);

  return useMemo(
    () => ({ chart, isCalculating, error, calculate, reset }),
    [chart, isCalculating, error, calculate, reset]
  );
}

export default useChartCalculator;
