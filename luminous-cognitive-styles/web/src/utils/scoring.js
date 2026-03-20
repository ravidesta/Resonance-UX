import { dimensions } from '../data/dimensions';

/**
 * Calculate a dimension score from DSR (Dimensional Self-Report) answers.
 * Each dimension has 5 questions rated 1-7.
 * Some questions are reversed (high agreement = low score on the dimension).
 * Final score is normalized to 1-10 scale.
 */
export const calculateDimensionScore = (dimensionId, answers) => {
  const dim = dimensions.find((d) => d.id === dimensionId);
  if (!dim) return 5;

  const questionIds = dim.questions.map((q) => q.id);
  const relevantAnswers = questionIds
    .map((qId) => {
      const question = dim.questions.find((q) => q.id === qId);
      const rawAnswer = answers[qId];
      if (rawAnswer === undefined) return null;
      if (question.reversed) {
        return 8 - rawAnswer;
      }
      return rawAnswer;
    })
    .filter((a) => a !== null);

  if (relevantAnswers.length === 0) return 5;

  const sum = relevantAnswers.reduce((acc, val) => acc + val, 0);
  const avg = sum / relevantAnswers.length;
  const normalized = ((avg - 1) / 6) * 9 + 1;
  return Math.round(normalized * 10) / 10;
};

/**
 * Calculate all dimension scores from DSR answers.
 */
export const calculateAllScores = (answers) => {
  const scores = {};
  dimensions.forEach((dim) => {
    scores[dim.id] = calculateDimensionScore(dim.id, answers);
  });
  return scores;
};

/**
 * Generate cognitive signature from Quick Profile slider values (already 1-10).
 */
export const generateSignatureFromSliders = (sliderValues) => {
  const scores = {};
  dimensions.forEach((dim) => {
    scores[dim.id] = sliderValues[dim.id] !== undefined ? sliderValues[dim.id] : 5;
  });
  return scores;
};

/**
 * Compute Adaptive Range for a score — typically ±2 from the home score,
 * clamped to 1-10.
 */
export const computeAdaptiveRange = (score, flexibility = 2) => {
  return {
    low: Math.max(1, Math.round((score - flexibility) * 10) / 10),
    high: Math.min(10, Math.round((score + flexibility) * 10) / 10),
    center: score,
  };
};

/**
 * Compute all adaptive ranges for a full set of scores.
 */
export const computeAllAdaptiveRanges = (scores) => {
  const ranges = {};
  Object.entries(scores).forEach(([dimId, score]) => {
    ranges[dimId] = computeAdaptiveRange(score);
  });
  return ranges;
};

/**
 * Determine Developmental Edge — the dimensions where you score most
 * extremely (closest to 1 or 10), indicating less cognitive flexibility.
 * Returns dimensions sorted by extremity.
 */
export const determineDevelopmentalEdge = (scores) => {
  const extremity = Object.entries(scores).map(([dimId, score]) => ({
    dimensionId: dimId,
    score,
    distanceFromCenter: Math.abs(score - 5.5),
    edgeDirection: score < 5.5 ? 'low' : 'high',
  }));

  extremity.sort((a, b) => b.distanceFromCenter - a.distanceFromCenter);
  return extremity;
};

/**
 * Determine Growth Areas — dimensions closest to center (most balanced)
 * where development could go either direction.
 */
export const determineGrowthAreas = (scores) => {
  const edges = determineDevelopmentalEdge(scores);
  return edges.reverse().slice(0, 3);
};

/**
 * Generate a profile type name based on the combination of scores.
 * Uses the top 2 most extreme dimensions to create a compound name.
 */
export const generateProfileTypeName = (scores) => {
  const edges = determineDevelopmentalEdge(scores);
  if (edges.length < 2) return 'The Explorer';

  const primary = edges[0];
  const secondary = edges[1];

  const dimNames = {
    'perceptual-mode': { low: 'Analytic', high: 'Holistic' },
    'processing-rhythm': { low: 'Deliberative', high: 'Spontaneous' },
    'generative-orientation': { low: 'Convergent', high: 'Divergent' },
    'representational-channel': { low: 'Verbal', high: 'Imagistic' },
    'relational-orientation': { low: 'Autonomous', high: 'Connected' },
    'somatic-integration': { low: 'Cerebral', high: 'Embodied' },
    'complexity-tolerance': { low: 'Resolute', high: 'Emergent' },
  };

  const archetypes = {
    'Analytic-Deliberative': 'The Architect',
    'Analytic-Spontaneous': 'The Tactician',
    'Analytic-Convergent': 'The Optimizer',
    'Analytic-Divergent': 'The Inventor',
    'Analytic-Verbal': 'The Logician',
    'Analytic-Imagistic': 'The Engineer',
    'Analytic-Autonomous': 'The Scholar',
    'Analytic-Connected': 'The Analyst',
    'Analytic-Cerebral': 'The Theorist',
    'Analytic-Embodied': 'The Craftsperson',
    'Analytic-Resolute': 'The Systematizer',
    'Analytic-Emergent': 'The Researcher',
    'Holistic-Deliberative': 'The Sage',
    'Holistic-Spontaneous': 'The Visionary',
    'Holistic-Convergent': 'The Strategist',
    'Holistic-Divergent': 'The Dreamer',
    'Holistic-Verbal': 'The Philosopher',
    'Holistic-Imagistic': 'The Artist',
    'Holistic-Autonomous': 'The Mystic',
    'Holistic-Connected': 'The Empath',
    'Holistic-Cerebral': 'The Contemplative',
    'Holistic-Embodied': 'The Healer',
    'Holistic-Resolute': 'The Commander',
    'Holistic-Emergent': 'The Oracle',
    'Deliberative-Convergent': 'The Perfectionist',
    'Deliberative-Divergent': 'The Incubator',
    'Deliberative-Verbal': 'The Writer',
    'Deliberative-Imagistic': 'The Designer',
    'Deliberative-Autonomous': 'The Hermit',
    'Deliberative-Connected': 'The Counselor',
    'Deliberative-Cerebral': 'The Thinker',
    'Deliberative-Embodied': 'The Practitioner',
    'Deliberative-Resolute': 'The Planner',
    'Deliberative-Emergent': 'The Philosopher',
    'Spontaneous-Convergent': 'The Closer',
    'Spontaneous-Divergent': 'The Improviser',
    'Spontaneous-Verbal': 'The Orator',
    'Spontaneous-Imagistic': 'The Performer',
    'Spontaneous-Autonomous': 'The Maverick',
    'Spontaneous-Connected': 'The Catalyst',
    'Spontaneous-Cerebral': 'The Debater',
    'Spontaneous-Embodied': 'The Athlete',
    'Spontaneous-Resolute': 'The Executor',
    'Spontaneous-Emergent': 'The Adventurer',
    'Convergent-Verbal': 'The Editor',
    'Convergent-Imagistic': 'The Sculptor',
    'Convergent-Autonomous': 'The Specialist',
    'Convergent-Connected': 'The Director',
    'Convergent-Cerebral': 'The Analyst',
    'Convergent-Embodied': 'The Artisan',
    'Convergent-Resolute': 'The Finisher',
    'Convergent-Emergent': 'The Refiner',
    'Divergent-Verbal': 'The Storyteller',
    'Divergent-Imagistic': 'The Visionary Artist',
    'Divergent-Autonomous': 'The Inventor',
    'Divergent-Connected': 'The Brainstormer',
    'Divergent-Cerebral': 'The Theorist',
    'Divergent-Embodied': 'The Dancer',
    'Divergent-Resolute': 'The Innovator',
    'Divergent-Emergent': 'The Alchemist',
    'Verbal-Autonomous': 'The Author',
    'Verbal-Connected': 'The Teacher',
    'Verbal-Cerebral': 'The Intellectual',
    'Verbal-Embodied': 'The Poet',
    'Verbal-Resolute': 'The Advocate',
    'Verbal-Emergent': 'The Essayist',
    'Imagistic-Autonomous': 'The Painter',
    'Imagistic-Connected': 'The Filmmaker',
    'Imagistic-Cerebral': 'The Architect',
    'Imagistic-Embodied': 'The Sculptor',
    'Imagistic-Resolute': 'The Builder',
    'Imagistic-Emergent': 'The Surrealist',
    'Autonomous-Cerebral': 'The Monk',
    'Autonomous-Embodied': 'The Ranger',
    'Autonomous-Resolute': 'The Pioneer',
    'Autonomous-Emergent': 'The Wanderer',
    'Connected-Cerebral': 'The Mentor',
    'Connected-Embodied': 'The Guide',
    'Connected-Resolute': 'The Organizer',
    'Connected-Emergent': 'The Facilitator',
    'Cerebral-Resolute': 'The Rationalist',
    'Cerebral-Emergent': 'The Philosopher',
    'Embodied-Resolute': 'The Warrior',
    'Embodied-Emergent': 'The Shaman',
  };

  const primaryLabel =
    dimNames[primary.dimensionId]?.[primary.edgeDirection] || 'Dynamic';
  const secondaryLabel =
    dimNames[secondary.dimensionId]?.[secondary.edgeDirection] || 'Versatile';

  const key1 = `${primaryLabel}-${secondaryLabel}`;
  const key2 = `${secondaryLabel}-${primaryLabel}`;

  return archetypes[key1] || archetypes[key2] || 'The Explorer';
};

/**
 * Generate a full cognitive profile from scores.
 */
export const generateFullProfile = (scores) => {
  return {
    scores,
    adaptiveRanges: computeAllAdaptiveRanges(scores),
    developmentalEdge: determineDevelopmentalEdge(scores),
    growthAreas: determineGrowthAreas(scores),
    profileType: generateProfileTypeName(scores),
  };
};

/**
 * Get top N most distinctive dimensions (farthest from center).
 */
export const getDistinctiveDimensions = (scores, n = 3) => {
  return determineDevelopmentalEdge(scores)
    .slice(0, n)
    .map((edge) => {
      const dim = dimensions.find((d) => d.id === edge.dimensionId);
      return {
        ...edge,
        name: dim?.name,
        label: edge.score <= 5 ? dim?.lowLabel : dim?.highLabel,
        color: dim?.color,
      };
    });
};

/**
 * Save profile to localStorage.
 */
export const saveProfile = (profile) => {
  try {
    localStorage.setItem('lcs-profile', JSON.stringify(profile));
    return true;
  } catch {
    return false;
  }
};

/**
 * Load profile from localStorage.
 */
export const loadProfile = () => {
  try {
    const stored = localStorage.getItem('lcs-profile');
    return stored ? JSON.parse(stored) : null;
  } catch {
    return null;
  }
};

/**
 * Save DSR progress to localStorage.
 */
export const saveDSRProgress = (answers) => {
  try {
    localStorage.setItem('lcs-dsr-progress', JSON.stringify(answers));
    return true;
  } catch {
    return false;
  }
};

/**
 * Load DSR progress from localStorage.
 */
export const loadDSRProgress = () => {
  try {
    const stored = localStorage.getItem('lcs-dsr-progress');
    return stored ? JSON.parse(stored) : {};
  } catch {
    return {};
  }
};
