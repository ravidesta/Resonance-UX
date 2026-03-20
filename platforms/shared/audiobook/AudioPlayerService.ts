/**
 * Luminous Cosmic Architecture™ — Audiobook Player Service
 * Cross-platform audiobook playback with sync, bookmarks, and sleep timer
 */

// ─── Types ────────────────────────────────────────────────────────

export interface AudioChapter {
  id: number;
  title: string;
  audioUrl: string;
  duration: number;       // seconds
  startOffset: number;    // offset in total audiobook
  sections?: AudioSection[];
}

export interface AudioSection {
  name: string;
  startOffset: number;    // offset within chapter
  duration: number;
}

export interface PlaybackState {
  isPlaying: boolean;
  currentChapterId: number;
  currentTime: number;      // seconds within current chapter
  totalTime: number;        // total chapter duration
  playbackRate: number;
  volume: number;
  isBuffering: boolean;
}

export interface Bookmark {
  id: string;
  chapterId: number;
  timestamp: number;
  note?: string;
  createdAt: number;
}

export interface SleepTimerState {
  isActive: boolean;
  remainingSeconds: number;
  mode: "timer" | "end_of_chapter";
}

export type PlaybackSpeed = 0.5 | 0.75 | 1.0 | 1.25 | 1.5 | 1.75 | 2.0 | 2.5 | 3.0;

// ─── Audio Player Service ─────────────────────────────────────────

export class AudioPlayerService {
  private chapters: AudioChapter[] = [];
  private state: PlaybackState = {
    isPlaying: false,
    currentChapterId: 0,
    currentTime: 0,
    totalTime: 0,
    playbackRate: 1.0,
    volume: 1.0,
    isBuffering: false,
  };
  private bookmarks: Bookmark[] = [];
  private sleepTimer: SleepTimerState = {
    isActive: false,
    remainingSeconds: 0,
    mode: "timer",
  };
  private listeners: Set<(state: PlaybackState) => void> = new Set();
  private sleepTimerInterval: ReturnType<typeof setInterval> | null = null;
  private audioElement: HTMLAudioElement | null = null;

  // ─── Initialization ───────────────────────────────────────────

  async initialize(chapters: AudioChapter[]): Promise<void> {
    this.chapters = chapters;
    this.loadSavedProgress();

    if (typeof Audio !== "undefined") {
      this.audioElement = new Audio();
      this.audioElement.addEventListener("timeupdate", () => {
        this.state.currentTime = this.audioElement?.currentTime ?? 0;
        this.notifyListeners();
      });
      this.audioElement.addEventListener("ended", () => this.onChapterEnded());
      this.audioElement.addEventListener("waiting", () => {
        this.state.isBuffering = true;
        this.notifyListeners();
      });
      this.audioElement.addEventListener("canplay", () => {
        this.state.isBuffering = false;
        this.notifyListeners();
      });
    }
  }

  // ─── Playback Controls ────────────────────────────────────────

  async play(): Promise<void> {
    if (!this.audioElement) return;

    const chapter = this.getCurrentChapter();
    if (!chapter) return;

    if (this.audioElement.src !== chapter.audioUrl) {
      this.audioElement.src = chapter.audioUrl;
      this.audioElement.currentTime = this.state.currentTime;
    }

    this.audioElement.playbackRate = this.state.playbackRate;
    await this.audioElement.play();
    this.state.isPlaying = true;
    this.state.totalTime = chapter.duration;
    this.notifyListeners();
    this.startProgressSync();
  }

  pause(): void {
    if (!this.audioElement) return;
    this.audioElement.pause();
    this.state.isPlaying = false;
    this.notifyListeners();
    this.saveProgress();
  }

  async togglePlayPause(): Promise<void> {
    if (this.state.isPlaying) {
      this.pause();
    } else {
      await this.play();
    }
  }

  seek(seconds: number): void {
    if (!this.audioElement) return;
    const clamped = Math.max(0, Math.min(seconds, this.state.totalTime));
    this.audioElement.currentTime = clamped;
    this.state.currentTime = clamped;
    this.notifyListeners();
  }

  seekRelative(deltaSeconds: number): void {
    this.seek(this.state.currentTime + deltaSeconds);
  }

  skipForward(seconds: number = 30): void {
    this.seekRelative(seconds);
  }

  skipBackward(seconds: number = 15): void {
    this.seekRelative(-seconds);
  }

  // ─── Chapter Navigation ───────────────────────────────────────

  async goToChapter(chapterId: number): Promise<void> {
    const chapter = this.chapters.find((c) => c.id === chapterId);
    if (!chapter) return;

    this.saveProgress();
    this.state.currentChapterId = chapterId;
    this.state.currentTime = 0;
    this.state.totalTime = chapter.duration;

    if (this.audioElement) {
      this.audioElement.src = chapter.audioUrl;
      this.audioElement.currentTime = 0;
    }

    if (this.state.isPlaying) {
      await this.play();
    } else {
      this.notifyListeners();
    }
  }

  async nextChapter(): Promise<void> {
    const currentIndex = this.chapters.findIndex((c) => c.id === this.state.currentChapterId);
    if (currentIndex < this.chapters.length - 1) {
      await this.goToChapter(this.chapters[currentIndex + 1].id);
    }
  }

  async previousChapter(): Promise<void> {
    // If more than 3 seconds into chapter, restart it
    if (this.state.currentTime > 3) {
      this.seek(0);
      return;
    }
    const currentIndex = this.chapters.findIndex((c) => c.id === this.state.currentChapterId);
    if (currentIndex > 0) {
      await this.goToChapter(this.chapters[currentIndex - 1].id);
    }
  }

  private async onChapterEnded(): Promise<void> {
    // Check sleep timer
    if (this.sleepTimer.isActive && this.sleepTimer.mode === "end_of_chapter") {
      this.pause();
      this.clearSleepTimer();
      return;
    }

    // Auto-advance to next chapter
    const currentIndex = this.chapters.findIndex((c) => c.id === this.state.currentChapterId);
    if (currentIndex < this.chapters.length - 1) {
      await this.goToChapter(this.chapters[currentIndex + 1].id);
    } else {
      // Book complete
      this.pause();
      this.state.currentTime = 0;
      this.notifyListeners();
    }
  }

  // ─── Playback Speed ───────────────────────────────────────────

  setPlaybackRate(rate: PlaybackSpeed): void {
    this.state.playbackRate = rate;
    if (this.audioElement) {
      this.audioElement.playbackRate = rate;
    }
    this.notifyListeners();
  }

  cyclePlaybackRate(): PlaybackSpeed {
    const rates: PlaybackSpeed[] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];
    const currentIndex = rates.indexOf(this.state.playbackRate as PlaybackSpeed);
    const nextRate = rates[(currentIndex + 1) % rates.length];
    this.setPlaybackRate(nextRate);
    return nextRate;
  }

  // ─── Volume ───────────────────────────────────────────────────

  setVolume(volume: number): void {
    this.state.volume = Math.max(0, Math.min(1, volume));
    if (this.audioElement) {
      this.audioElement.volume = this.state.volume;
    }
    this.notifyListeners();
  }

  // ─── Sleep Timer ──────────────────────────────────────────────

  setSleepTimer(minutes: number): void {
    this.clearSleepTimer();
    this.sleepTimer = {
      isActive: true,
      remainingSeconds: minutes * 60,
      mode: "timer",
    };
    this.sleepTimerInterval = setInterval(() => {
      this.sleepTimer.remainingSeconds -= 1;
      if (this.sleepTimer.remainingSeconds <= 0) {
        this.pause();
        this.clearSleepTimer();
      }
    }, 1000);
  }

  setSleepTimerEndOfChapter(): void {
    this.clearSleepTimer();
    this.sleepTimer = {
      isActive: true,
      remainingSeconds: Math.ceil(this.state.totalTime - this.state.currentTime),
      mode: "end_of_chapter",
    };
  }

  clearSleepTimer(): void {
    if (this.sleepTimerInterval) {
      clearInterval(this.sleepTimerInterval);
      this.sleepTimerInterval = null;
    }
    this.sleepTimer = { isActive: false, remainingSeconds: 0, mode: "timer" };
  }

  getSleepTimerState(): SleepTimerState {
    return { ...this.sleepTimer };
  }

  // ─── Bookmarks ────────────────────────────────────────────────

  addBookmark(note?: string): Bookmark {
    const bookmark: Bookmark = {
      id: `bm_${Date.now()}`,
      chapterId: this.state.currentChapterId,
      timestamp: this.state.currentTime,
      note,
      createdAt: Date.now(),
    };
    this.bookmarks.push(bookmark);
    this.saveBookmarks();
    return bookmark;
  }

  removeBookmark(bookmarkId: string): void {
    this.bookmarks = this.bookmarks.filter((b) => b.id !== bookmarkId);
    this.saveBookmarks();
  }

  getBookmarks(): Bookmark[] {
    return [...this.bookmarks];
  }

  getBookmarksForChapter(chapterId: number): Bookmark[] {
    return this.bookmarks.filter((b) => b.chapterId === chapterId);
  }

  async goToBookmark(bookmark: Bookmark): Promise<void> {
    await this.goToChapter(bookmark.chapterId);
    this.seek(bookmark.timestamp);
  }

  // ─── Progress ─────────────────────────────────────────────────

  getOverallProgress(): { chaptersCompleted: number; totalChapters: number; percentComplete: number } {
    const totalChapters = this.chapters.length;
    const currentIndex = this.chapters.findIndex((c) => c.id === this.state.currentChapterId);
    const chapterProgress = this.state.totalTime > 0 ? this.state.currentTime / this.state.totalTime : 0;
    const percentComplete = ((currentIndex + chapterProgress) / totalChapters) * 100;

    return {
      chaptersCompleted: currentIndex,
      totalChapters,
      percentComplete: Math.round(percentComplete * 10) / 10,
    };
  }

  getCurrentSection(): AudioSection | null {
    const chapter = this.getCurrentChapter();
    if (!chapter?.sections) return null;

    for (let i = chapter.sections.length - 1; i >= 0; i--) {
      if (this.state.currentTime >= chapter.sections[i].startOffset) {
        return chapter.sections[i];
      }
    }
    return chapter.sections[0] ?? null;
  }

  getTimeRemaining(): { chapter: number; total: number } {
    const chapterRemaining = this.state.totalTime - this.state.currentTime;
    const currentIndex = this.chapters.findIndex((c) => c.id === this.state.currentChapterId);
    let totalRemaining = chapterRemaining;
    for (let i = currentIndex + 1; i < this.chapters.length; i++) {
      totalRemaining += this.chapters[i].duration;
    }
    return { chapter: chapterRemaining, total: totalRemaining };
  }

  // ─── State ────────────────────────────────────────────────────

  getState(): PlaybackState {
    return { ...this.state };
  }

  getChapters(): AudioChapter[] {
    return [...this.chapters];
  }

  getCurrentChapter(): AudioChapter | undefined {
    return this.chapters.find((c) => c.id === this.state.currentChapterId);
  }

  onStateChange(listener: (state: PlaybackState) => void): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  // ─── Persistence ──────────────────────────────────────────────

  private saveProgress(): void {
    if (typeof localStorage === "undefined") return;
    localStorage.setItem("luminous_audiobook_progress", JSON.stringify({
      chapterId: this.state.currentChapterId,
      currentTime: this.state.currentTime,
      playbackRate: this.state.playbackRate,
      volume: this.state.volume,
      timestamp: Date.now(),
    }));
  }

  private loadSavedProgress(): void {
    if (typeof localStorage === "undefined") return;
    const saved = localStorage.getItem("luminous_audiobook_progress");
    if (saved) {
      const data = JSON.parse(saved);
      this.state.currentChapterId = data.chapterId ?? 0;
      this.state.currentTime = data.currentTime ?? 0;
      this.state.playbackRate = data.playbackRate ?? 1.0;
      this.state.volume = data.volume ?? 1.0;
    }
  }

  private saveBookmarks(): void {
    if (typeof localStorage === "undefined") return;
    localStorage.setItem("luminous_audiobook_bookmarks", JSON.stringify(this.bookmarks));
  }

  private startProgressSync(): void {
    // Auto-save progress every 30 seconds while playing
    const syncInterval = setInterval(() => {
      if (this.state.isPlaying) {
        this.saveProgress();
      } else {
        clearInterval(syncInterval);
      }
    }, 30000);
  }

  private notifyListeners(): void {
    this.listeners.forEach((listener) => listener({ ...this.state }));
  }

  // ─── Cleanup ──────────────────────────────────────────────────

  destroy(): void {
    this.saveProgress();
    this.clearSleepTimer();
    if (this.audioElement) {
      this.audioElement.pause();
      this.audioElement.src = "";
    }
    this.listeners.clear();
  }
}
