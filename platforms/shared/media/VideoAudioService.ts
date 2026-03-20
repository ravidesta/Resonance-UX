/**
 * Luminous Cosmic Architecture™ — Video & Audio Service
 * Manages guided meditations, astrology lectures, ambient soundscapes, and video content
 */

// ─── Types ───────────────────────────────────────────────────────

export interface MediaItem {
  id: string;
  title: string;
  description: string;
  type: MediaType;
  category: MediaCategory;
  duration: number; // seconds
  thumbnailUrl: string;
  mediaUrl: string;
  artist: string;
  tags: string[];
  isFree: boolean;
  plays: number;
  rating: number;
  createdAt: string;
}

export type MediaType = 'audio' | 'video' | 'livestream';
export type MediaCategory =
  | 'guided-meditation'
  | 'sleep-story'
  | 'soundscape'
  | 'lecture'
  | 'workshop-recording'
  | 'ritual-guide'
  | 'breathwork'
  | 'affirmation';

export interface Playlist {
  id: string;
  title: string;
  description: string;
  coverUrl: string;
  items: MediaItem[];
  duration: number;
  cosmicTheme?: string;
  isUserCreated: boolean;
}

export interface PlaybackState {
  currentItem: MediaItem | null;
  isPlaying: boolean;
  currentTime: number;
  duration: number;
  volume: number;
  playbackRate: number;
  repeat: 'none' | 'one' | 'all';
  shuffle: boolean;
  queue: MediaItem[];
  history: MediaItem[];
}

export interface ListeningStats {
  totalMinutes: number;
  sessionsCompleted: number;
  currentStreak: number;
  favoriteCategory: MediaCategory;
  minutesByCategory: Record<string, number>;
  recentlyPlayed: MediaItem[];
}

// ─── Sample Content ──────────────────────────────────────────────

export const MEDIA_LIBRARY: MediaItem[] = [
  {
    id: 'med-moon-meditation',
    title: 'Moon Cycle Meditation',
    description: 'A guided meditation that attunes you to the current lunar phase, helping you align your intentions with the cosmic rhythm.',
    type: 'audio',
    category: 'guided-meditation',
    duration: 900,
    thumbnailUrl: '/media/thumbnails/moon-meditation.jpg',
    mediaUrl: '/media/audio/moon-meditation.mp3',
    artist: 'Luna Silveira',
    tags: ['moon', 'meditation', 'lunar-cycle', 'intention'],
    isFree: true,
    plays: 12450,
    rating: 4.9,
    createdAt: '2026-01-15',
  },
  {
    id: 'med-chakra-planets',
    title: 'Planetary Chakra Alignment',
    description: 'Journey through each chakra paired with its planetary ruler. Balance your energy centers with cosmic resonance.',
    type: 'audio',
    category: 'guided-meditation',
    duration: 1200,
    thumbnailUrl: '/media/thumbnails/chakra-planets.jpg',
    mediaUrl: '/media/audio/chakra-planets.mp3',
    artist: 'Atlas Rivera',
    tags: ['chakra', 'planets', 'energy', 'healing'],
    isFree: false,
    plays: 8920,
    rating: 4.8,
    createdAt: '2026-01-20',
  },
  {
    id: 'snd-cosmic-ocean',
    title: 'Cosmic Ocean Soundscape',
    description: 'Deep space ambient tones blended with ocean waves. Perfect for sleep, meditation, or focused work.',
    type: 'audio',
    category: 'soundscape',
    duration: 3600,
    thumbnailUrl: '/media/thumbnails/cosmic-ocean.jpg',
    mediaUrl: '/media/audio/cosmic-ocean.mp3',
    artist: 'Resonance Audio',
    tags: ['ambient', 'ocean', 'space', 'sleep'],
    isFree: true,
    plays: 25600,
    rating: 4.7,
    createdAt: '2026-02-01',
  },
  {
    id: 'snd-starfield',
    title: 'Starfield Frequencies',
    description: 'Binaural beats tuned to planetary frequencies. Enhances meditation and intuitive awareness.',
    type: 'audio',
    category: 'soundscape',
    duration: 2700,
    thumbnailUrl: '/media/thumbnails/starfield.jpg',
    mediaUrl: '/media/audio/starfield.mp3',
    artist: 'Resonance Audio',
    tags: ['binaural', 'frequencies', 'focus', 'intuition'],
    isFree: false,
    plays: 15300,
    rating: 4.6,
    createdAt: '2026-02-10',
  },
  {
    id: 'lec-natal-101',
    title: 'Understanding Your Natal Chart',
    description: 'A comprehensive introduction to reading your natal chart. Learn about planets, houses, and aspects.',
    type: 'video',
    category: 'lecture',
    duration: 2400,
    thumbnailUrl: '/media/thumbnails/natal-101.jpg',
    mediaUrl: '/media/video/natal-101.mp4',
    artist: 'Celeste Moonwater',
    tags: ['natal-chart', 'beginner', 'education', 'houses'],
    isFree: true,
    plays: 34200,
    rating: 4.9,
    createdAt: '2026-02-15',
  },
  {
    id: 'lec-transits-guide',
    title: 'Navigating Planetary Transits',
    description: 'Learn how to read and work with planetary transits in your daily life.',
    type: 'video',
    category: 'lecture',
    duration: 1800,
    thumbnailUrl: '/media/thumbnails/transits-guide.jpg',
    mediaUrl: '/media/video/transits-guide.mp4',
    artist: 'Orion Blackwell',
    tags: ['transits', 'intermediate', 'education', 'timing'],
    isFree: false,
    plays: 18700,
    rating: 4.8,
    createdAt: '2026-02-20',
  },
  {
    id: 'sleep-pisces-dreams',
    title: 'Pisces Dreamscape',
    description: 'A gentle sleep story guided by Neptune through the waters of Pisces. Drift into restorative sleep.',
    type: 'audio',
    category: 'sleep-story',
    duration: 1800,
    thumbnailUrl: '/media/thumbnails/pisces-dreams.jpg',
    mediaUrl: '/media/audio/pisces-dreams.mp3',
    artist: 'Luna Silveira',
    tags: ['sleep', 'pisces', 'neptune', 'dreams'],
    isFree: false,
    plays: 21400,
    rating: 4.9,
    createdAt: '2026-03-01',
  },
  {
    id: 'breath-mars-fire',
    title: 'Mars Fire Breathwork',
    description: 'Energizing breathwork channeling Mars energy. Ignite your inner fire and build courage.',
    type: 'audio',
    category: 'breathwork',
    duration: 600,
    thumbnailUrl: '/media/thumbnails/mars-fire.jpg',
    mediaUrl: '/media/audio/mars-fire.mp3',
    artist: 'Atlas Rivera',
    tags: ['breathwork', 'mars', 'fire', 'energy'],
    isFree: true,
    plays: 9800,
    rating: 4.7,
    createdAt: '2026-03-05',
  },
  {
    id: 'ritual-new-moon',
    title: 'New Moon Intention Ritual',
    description: 'A step-by-step guide for your new moon ritual. Set intentions aligned with cosmic potential.',
    type: 'video',
    category: 'ritual-guide',
    duration: 1500,
    thumbnailUrl: '/media/thumbnails/new-moon-ritual.jpg',
    mediaUrl: '/media/video/new-moon-ritual.mp4',
    artist: 'Celeste Moonwater',
    tags: ['ritual', 'new-moon', 'intention', 'ceremony'],
    isFree: true,
    plays: 28900,
    rating: 4.9,
    createdAt: '2026-03-10',
  },
  {
    id: 'affirm-abundance',
    title: 'Jupiter Abundance Affirmations',
    description: 'Powerful affirmations channeling Jupiter energy for prosperity and expansion.',
    type: 'audio',
    category: 'affirmation',
    duration: 480,
    thumbnailUrl: '/media/thumbnails/abundance.jpg',
    mediaUrl: '/media/audio/abundance.mp3',
    artist: 'Orion Blackwell',
    tags: ['affirmation', 'jupiter', 'abundance', 'prosperity'],
    isFree: true,
    plays: 16700,
    rating: 4.6,
    createdAt: '2026-03-15',
  },
];

export const CURATED_PLAYLISTS: Playlist[] = [
  {
    id: 'pl-sleep',
    title: 'Celestial Sleep',
    description: 'Drift into deep rest with cosmic soundscapes and sleep stories.',
    coverUrl: '/media/covers/celestial-sleep.jpg',
    items: MEDIA_LIBRARY.filter(m => ['soundscape', 'sleep-story'].includes(m.category)),
    duration: 8100,
    cosmicTheme: 'Neptune & Moon',
    isUserCreated: false,
  },
  {
    id: 'pl-beginner',
    title: 'Astrology Foundations',
    description: 'Everything you need to begin your astrological journey.',
    coverUrl: '/media/covers/foundations.jpg',
    items: MEDIA_LIBRARY.filter(m => m.tags.includes('beginner') || m.tags.includes('education')),
    duration: 4200,
    cosmicTheme: 'Mercury & Jupiter',
    isUserCreated: false,
  },
  {
    id: 'pl-morning',
    title: 'Morning Cosmic Ritual',
    description: 'Start your day aligned with planetary energies.',
    coverUrl: '/media/covers/morning-ritual.jpg',
    items: MEDIA_LIBRARY.filter(m => ['breathwork', 'affirmation', 'guided-meditation'].includes(m.category)),
    duration: 2880,
    cosmicTheme: 'Sun & Mars',
    isUserCreated: false,
  },
];

// ─── Service ─────────────────────────────────────────────────────

export class VideoAudioService {
  private playbackState: PlaybackState = {
    currentItem: null,
    isPlaying: false,
    currentTime: 0,
    duration: 0,
    volume: 0.8,
    playbackRate: 1,
    repeat: 'none',
    shuffle: false,
    queue: [],
    history: [],
  };

  getLibrary(filter?: {
    category?: MediaCategory;
    type?: MediaType;
    freeOnly?: boolean;
    searchQuery?: string;
  }): MediaItem[] {
    let items = [...MEDIA_LIBRARY];
    if (filter?.category) items = items.filter(i => i.category === filter.category);
    if (filter?.type) items = items.filter(i => i.type === filter.type);
    if (filter?.freeOnly) items = items.filter(i => i.isFree);
    if (filter?.searchQuery) {
      const q = filter.searchQuery.toLowerCase();
      items = items.filter(i =>
        i.title.toLowerCase().includes(q) ||
        i.description.toLowerCase().includes(q) ||
        i.tags.some(t => t.includes(q))
      );
    }
    return items;
  }

  getPlaylists(): Playlist[] {
    return CURATED_PLAYLISTS;
  }

  play(item: MediaItem): PlaybackState {
    if (this.playbackState.currentItem) {
      this.playbackState.history.push(this.playbackState.currentItem);
    }
    this.playbackState.currentItem = item;
    this.playbackState.isPlaying = true;
    this.playbackState.currentTime = 0;
    this.playbackState.duration = item.duration;
    return { ...this.playbackState };
  }

  pause(): PlaybackState {
    this.playbackState.isPlaying = false;
    return { ...this.playbackState };
  }

  resume(): PlaybackState {
    this.playbackState.isPlaying = true;
    return { ...this.playbackState };
  }

  seek(time: number): PlaybackState {
    this.playbackState.currentTime = Math.max(0, Math.min(time, this.playbackState.duration));
    return { ...this.playbackState };
  }

  setVolume(volume: number): void {
    this.playbackState.volume = Math.max(0, Math.min(1, volume));
  }

  addToQueue(items: MediaItem[]): void {
    this.playbackState.queue.push(...items);
  }

  playNext(): PlaybackState | null {
    const next = this.playbackState.queue.shift();
    if (next) return this.play(next);
    return null;
  }

  getState(): PlaybackState {
    return { ...this.playbackState };
  }

  getStats(): ListeningStats {
    return {
      totalMinutes: 247,
      sessionsCompleted: 42,
      currentStreak: 5,
      favoriteCategory: 'guided-meditation',
      minutesByCategory: {
        'guided-meditation': 98,
        soundscape: 67,
        lecture: 45,
        'sleep-story': 22,
        breathwork: 10,
        affirmation: 5,
      },
      recentlyPlayed: this.playbackState.history.slice(-5),
    };
  }

  formatDuration(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = seconds % 60;
    if (h > 0) return `${h}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    return `${m}:${s.toString().padStart(2, '0')}`;
  }
}
