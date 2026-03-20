// CoachService.ts — Astrology coaching service for Resonance UX

export interface Coach {
  id: string;
  name: string;
  specialties: string[];
  bio: string;
  avatarUrl: string;
  rating: number;
  availability: { day: string; slots: string[] }[];
  pricePerSession: number;
  zodiacExpertise: string[];
}

export type SessionType =
  | 'natal-reading'
  | 'transit-guidance'
  | 'relationship-synastry'
  | 'career-astrology'
  | 'spiritual-growth';

export type SessionStatus =
  | 'scheduled'
  | 'in-progress'
  | 'completed'
  | 'cancelled';

export interface CoachSession {
  id: string;
  coachId: string;
  userId: string;
  scheduledAt: string; // ISO date-time
  duration: number; // minutes
  type: SessionType;
  status: SessionStatus;
  notes: string;
}

export interface CoachMessage {
  id: string;
  sessionId: string;
  sender: 'coach' | 'user';
  content: string;
  timestamp: string; // ISO date-time
}

export interface CoachRating {
  coachId: string;
  userId: string;
  score: number; // 1-5
  review?: string;
}

// ---------------------------------------------------------------------------
// Sample coaches
// ---------------------------------------------------------------------------

const sampleCoaches: Coach[] = [
  {
    id: 'coach-1',
    name: 'Selene Moreau',
    specialties: ['Natal Charts', 'Lunar Cycles', 'Intuitive Guidance'],
    bio: 'With over 15 years of astrological practice, Selene specialises in natal chart interpretation and lunar cycle alignment. She blends traditional Hellenistic techniques with modern psychological astrology to help clients understand their deepest patterns and potentials.',
    avatarUrl: '/avatars/selene.png',
    rating: 4.9,
    availability: [
      { day: 'Monday', slots: ['10:00', '14:00', '16:00'] },
      { day: 'Wednesday', slots: ['09:00', '11:00', '15:00'] },
      { day: 'Friday', slots: ['10:00', '13:00'] },
    ],
    pricePerSession: 95,
    zodiacExpertise: ['Cancer', 'Pisces', 'Scorpio'],
  },
  {
    id: 'coach-2',
    name: 'Orion Blake',
    specialties: ['Transit Forecasting', 'Career Astrology', 'Electional Astrology'],
    bio: 'Orion is a Vedic and Western hybrid astrologer focused on timing and career strategy. He helps professionals align major life decisions — job changes, launches, relocations — with favourable planetary transits.',
    avatarUrl: '/avatars/orion.png',
    rating: 4.7,
    availability: [
      { day: 'Tuesday', slots: ['09:00', '12:00', '17:00'] },
      { day: 'Thursday', slots: ['10:00', '14:00'] },
      { day: 'Saturday', slots: ['11:00', '13:00', '15:00'] },
    ],
    pricePerSession: 110,
    zodiacExpertise: ['Capricorn', 'Aries', 'Leo'],
  },
  {
    id: 'coach-3',
    name: 'Luna Ashworth',
    specialties: ['Relationship Synastry', 'Composite Charts', 'Venus Returns'],
    bio: 'Luna has dedicated her practice to the astrology of relationships. Whether you are navigating a new romance, deepening an existing partnership, or understanding family dynamics, Luna brings warmth and precision to every synastry reading.',
    avatarUrl: '/avatars/luna.png',
    rating: 4.8,
    availability: [
      { day: 'Monday', slots: ['11:00', '15:00'] },
      { day: 'Wednesday', slots: ['10:00', '14:00', '17:00'] },
      { day: 'Saturday', slots: ['09:00', '12:00'] },
    ],
    pricePerSession: 100,
    zodiacExpertise: ['Libra', 'Taurus', 'Pisces'],
  },
  {
    id: 'coach-4',
    name: 'Atlas Reyes',
    specialties: ['Spiritual Growth', 'Evolutionary Astrology', 'Nodal Axis'],
    bio: 'Atlas practises evolutionary astrology, exploring the soul-level intentions encoded in your chart. His sessions are contemplative and transformative, guiding clients toward their North Node purpose and karmic healing.',
    avatarUrl: '/avatars/atlas.png',
    rating: 4.6,
    availability: [
      { day: 'Tuesday', slots: ['10:00', '13:00'] },
      { day: 'Thursday', slots: ['09:00', '11:00', '16:00'] },
      { day: 'Friday', slots: ['14:00', '17:00'] },
    ],
    pricePerSession: 85,
    zodiacExpertise: ['Sagittarius', 'Aquarius', 'Scorpio'],
  },
  {
    id: 'coach-5',
    name: 'Iris Tanaka',
    specialties: ['Medical Astrology', 'Natal Charts', 'Herbalism Integration'],
    bio: 'Iris merges astrological analysis with holistic wellness. She reads natal charts through the lens of mind-body balance and suggests personalised wellness rituals aligned with planetary rulers and transits.',
    avatarUrl: '/avatars/iris.png',
    rating: 4.8,
    availability: [
      { day: 'Monday', slots: ['09:00', '12:00', '16:00'] },
      { day: 'Wednesday', slots: ['11:00', '15:00'] },
      { day: 'Friday', slots: ['10:00', '13:00', '16:00'] },
    ],
    pricePerSession: 90,
    zodiacExpertise: ['Virgo', 'Cancer', 'Taurus'],
  },
  {
    id: 'coach-6',
    name: 'Cassius Oduya',
    specialties: ['Mundane Astrology', 'Career Astrology', 'Financial Cycles'],
    bio: 'Cassius brings an analytical edge to astrology, specialising in mundane (world-event) astrology and financial timing. Entrepreneurs and investors seek him out to understand macro cycles and personal wealth transits.',
    avatarUrl: '/avatars/cassius.png',
    rating: 4.5,
    availability: [
      { day: 'Tuesday', slots: ['11:00', '14:00', '17:00'] },
      { day: 'Thursday', slots: ['10:00', '13:00'] },
      { day: 'Saturday', slots: ['09:00', '12:00', '15:00'] },
    ],
    pricePerSession: 120,
    zodiacExpertise: ['Capricorn', 'Scorpio', 'Gemini'],
  },
];

// ---------------------------------------------------------------------------
// In-memory stores (replace with real persistence in production)
// ---------------------------------------------------------------------------

let sessions: CoachSession[] = [];
let messages: CoachMessage[] = [];
let ratings: CoachRating[] = [];

function generateId(prefix: string): string {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}

// ---------------------------------------------------------------------------
// CoachService
// ---------------------------------------------------------------------------

export class CoachService {
  // ---- Coaches ----------------------------------------------------------

  async getCoaches(filters?: {
    specialty?: string;
    maxPrice?: number;
    zodiacSign?: string;
  }): Promise<Coach[]> {
    let result = [...sampleCoaches];

    if (filters?.specialty) {
      const s = filters.specialty.toLowerCase();
      result = result.filter((c) =>
        c.specialties.some((sp) => sp.toLowerCase().includes(s)),
      );
    }
    if (filters?.maxPrice !== undefined) {
      result = result.filter((c) => c.pricePerSession <= filters.maxPrice!);
    }
    if (filters?.zodiacSign) {
      const z = filters.zodiacSign.toLowerCase();
      result = result.filter((c) =>
        c.zodiacExpertise.some((ze) => ze.toLowerCase() === z),
      );
    }

    return result;
  }

  async getCoachById(coachId: string): Promise<Coach | undefined> {
    return sampleCoaches.find((c) => c.id === coachId);
  }

  // ---- Sessions ---------------------------------------------------------

  async bookSession(params: {
    coachId: string;
    userId: string;
    scheduledAt: string;
    duration: number;
    type: SessionType;
    notes?: string;
  }): Promise<CoachSession> {
    const session: CoachSession = {
      id: generateId('session'),
      coachId: params.coachId,
      userId: params.userId,
      scheduledAt: params.scheduledAt,
      duration: params.duration,
      type: params.type,
      status: 'scheduled',
      notes: params.notes ?? '',
    };
    sessions.push(session);
    return session;
  }

  async cancelSession(sessionId: string): Promise<CoachSession | undefined> {
    const session = sessions.find((s) => s.id === sessionId);
    if (session) {
      session.status = 'cancelled';
    }
    return session;
  }

  async getUpcomingSessions(userId: string): Promise<CoachSession[]> {
    const now = new Date().toISOString();
    return sessions.filter(
      (s) =>
        s.userId === userId &&
        s.status === 'scheduled' &&
        s.scheduledAt >= now,
    );
  }

  async getPastSessions(userId: string): Promise<CoachSession[]> {
    const now = new Date().toISOString();
    return sessions.filter(
      (s) =>
        s.userId === userId &&
        (s.status === 'completed' || s.scheduledAt < now),
    );
  }

  // ---- Messages ---------------------------------------------------------

  async sendMessage(params: {
    sessionId: string;
    sender: 'coach' | 'user';
    content: string;
  }): Promise<CoachMessage> {
    const msg: CoachMessage = {
      id: generateId('msg'),
      sessionId: params.sessionId,
      sender: params.sender,
      content: params.content,
      timestamp: new Date().toISOString(),
    };
    messages.push(msg);
    return msg;
  }

  async getSessionMessages(sessionId: string): Promise<CoachMessage[]> {
    return messages
      .filter((m) => m.sessionId === sessionId)
      .sort((a, b) => a.timestamp.localeCompare(b.timestamp));
  }

  // ---- Ratings ----------------------------------------------------------

  async rateCoach(params: {
    coachId: string;
    userId: string;
    score: number;
    review?: string;
  }): Promise<CoachRating> {
    const rating: CoachRating = {
      coachId: params.coachId,
      userId: params.userId,
      score: Math.max(1, Math.min(5, params.score)),
      review: params.review,
    };
    ratings.push(rating);

    // Recalculate average rating on the coach object
    const coach = sampleCoaches.find((c) => c.id === params.coachId);
    if (coach) {
      const coachRatings = ratings.filter((r) => r.coachId === params.coachId);
      coach.rating =
        Math.round(
          (coachRatings.reduce((sum, r) => sum + r.score, 0) /
            coachRatings.length) *
            10,
        ) / 10;
    }
    return rating;
  }
}

export default new CoachService();
