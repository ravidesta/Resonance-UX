import { useState } from "react";
import {
  BookOpen, Headphones, Star, Sun, Moon, Play, Pause, SkipBack, SkipForward,
  Bookmark, Share2, Download, ChevronLeft, ChevronRight, Clock, Flame,
  BarChart2, Plus, Minus, AlignLeft, Calendar, Library, Highlighter
} from "lucide-react";

const C = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", forest: "#1B402E",
  mist: "#D1E0D7", gold: "#C5A059", cream: "#E6D0A1", page: "#FAFAF8",
  white: "#FFFFFF", text: "#1a1a1a"
};

const books = [
  { id: 1, title: "Luminous: Foundations of Ego Development", cover: "#1B402E", accent: "#C5A059", pages: 312, read: 187, genre: "Core Text" },
  { id: 2, title: "The Shadow's Gift", cover: "#2C1B47", accent: "#9B7EC8", pages: 248, read: 248, genre: "Shadow Work" },
  { id: 3, title: "Relational Intelligence", cover: "#1A3A4A", accent: "#6BAED6", pages: 276, read: 94, genre: "Relationships" },
  { id: 4, title: "Somatic Wisdom", cover: "#3D2B1F", accent: "#D4956A", pages: 198, read: 0, genre: "Body & Mind" },
  { id: 5, title: "Post-Traumatic Growth", cover: "#1C3A2A", accent: "#7EC8A0", pages: 290, read: 41, genre: "Healing" },
  { id: 6, title: "Daily Reflections (365 readings)", cover: "#3A1A2E", accent: "#E6A0C4", pages: 365, read: 82, genre: "Daily Practice" },
];

const highlights = [
  { id: 1, text: "The ego is not the enemy — it is the scaffolding through which the self learns to know itself.", book: "Luminous: Foundations", page: 47 },
  { id: 2, text: "Shadow integration is not about eliminating darkness, but illuminating it with the light of awareness.", book: "The Shadow's Gift", page: 112 },
  { id: 3, text: "Every relational wound carries within it the seed of relational healing.", book: "Relational Intelligence", page: 88 },
];

const chapters = [
  { n: 1, title: "The Architecture of Self", dur: "38:24", done: true },
  { n: 2, title: "Foundations of Growth", dur: "41:17", done: true },
  { n: 3, title: "The Witnessing Presence", dur: "35:52", done: false },
  { n: 4, title: "Shadow as Teacher", dur: "44:08", done: false },
  { n: 5, title: "Relational Mirrors", dur: "39:33", done: false },
  { n: 6, title: "Somatic Knowing", dur: "42:51", done: false },
  { n: 7, title: "Integration Practices", dur: "37:20", done: false },
  { n: 8, title: "The Luminous Self", dur: "50:14", done: false },
];

const passage = `The ego, in its most fundamental nature, is not an obstacle to transcendence — it is the very instrument through which consciousness learns to know itself. Like a lantern that illuminates the path while remaining distinct from the light it carries, the ego serves as the organizing principle of lived experience, the narrator of our interior life.

To develop the ego is not to fortify its walls or harden its edges. Rather, genuine ego development involves a paradoxical softening — a growing capacity to hold complexity, to tolerate ambiguity, to remain present with what is rather than contracting around what should be. The mature ego becomes permeable, relational, alive to the mystery it inhabits.

In this sense, Luminous development is less about achieving some fixed state of enlightenment and more about cultivating an ever-deepening intimacy with the full spectrum of human experience — the radiant and the shadowed, the certain and the trembling, the known and the perpetually unfolding.`;

const todayReflection = {
  day: 82,
  title: "On Meeting Yourself",
  text: "Each morning is an invitation. Before the mind rushes to its familiar territories — the plans, the worries, the rehearsed narratives — there is a brief, luminous gap. In that gap, something essential waits to be recognized. Not a stranger, but the most intimate presence you have never quite allowed yourself to fully meet.",
  prompt: "What part of yourself have you been most reluctant to meet lately? What might change if you turned toward it with gentle curiosity rather than avoidance?"
};

export default function ResonanceReader() {
  const [night, setNight] = useState(false);
  const [tab, setTab] = useState("library");
  const [fontSize, setFontSize] = useState(18);
  const [playing, setPlaying] = useState(false);
  const [speed, setSpeed] = useState("1x");
  const [progress, setProgress] = useState(34);
  const [timer, setTimer] = useState("Off");
  const [currentBook, setCurrentBook] = useState(books[0]);

  const bg = night ? C.night : C.page;
  const surface = night ? C.dark : C.white;
  const surfaceMid = night ? C.mid : "#EEF5F0";
  const textPrimary = night ? C.page : C.dark;
  const textSecondary = night ? C.mist : "#4A6357";
  const border = night ? "#1B402E" : "#D1E0D7";
  const goldTone = night ? C.cream : C.gold;

  const s = {
    wrap: { minHeight: "100vh", background: bg, color: textPrimary, fontFamily: "'Manrope', sans-serif", position: "relative", overflow: "hidden", paddingBottom: 72 },
    blob: (x, y, size, color) => ({ position: "fixed", left: x, top: y, width: size, height: size, borderRadius: "50%", background: color, filter: "blur(80px)", opacity: 0.18, pointerEvents: "none", zIndex: 0 }),
    glass: { background: night ? "rgba(18,46,33,0.55)" : "rgba(255,255,255,0.6)", backdropFilter: "blur(16px)", border: `1px solid ${border}`, borderRadius: 16 },
    serif: { fontFamily: "'Cormorant Garamond', Georgia, serif" },
    gold: { color: goldTone },
    badge: (color) => ({ background: color, color: C.white, borderRadius: 6, padding: "2px 8px", fontSize: 11, fontWeight: 600 }),
    nav: { position: "fixed", bottom: 0, left: 0, right: 0, background: night ? "rgba(5,16,11,0.95)" : "rgba(250,250,248,0.95)", backdropFilter: "blur(20px)", borderTop: `1px solid ${border}`, display: "flex", zIndex: 50 },
    navItem: (active) => ({ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", padding: "10px 4px 8px", gap: 3, cursor: "pointer", color: active ? C.gold : textSecondary, fontSize: 10, fontWeight: active ? 700 : 500, transition: "color 0.2s" }),
    header: { display: "flex", justifyContent: "space-between", alignItems: "center", padding: "20px 20px 0" },
    page: { padding: "0 20px", position: "relative", zIndex: 1 },
    h1: { ...{ fontFamily: "'Cormorant Garamond', Georgia, serif" }, fontSize: 28, fontWeight: 600, margin: "16px 0 4px", color: textPrimary },
    sub: { color: textSecondary, fontSize: 13, marginBottom: 20 },
    btn: (fill) => ({ background: fill || C.forest, color: C.page, border: "none", borderRadius: 10, padding: "10px 18px", cursor: "pointer", fontFamily: "'Manrope', sans-serif", fontWeight: 600, fontSize: 13, display: "flex", alignItems: "center", gap: 6 }),
    iconBtn: { background: "transparent", border: `1px solid ${border}`, borderRadius: 10, padding: 8, cursor: "pointer", color: textSecondary, display: "flex" },
    promo: { background: night ? "rgba(197,160,89,0.12)" : "rgba(197,160,89,0.1)", border: `1px solid ${goldTone}40`, borderRadius: 12, padding: "12px 16px", display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 12 },
  };

  const toggleNight = () => setNight(n => !n);

  const Header = ({ title, sub }) => (
    <div style={s.header}>
      <div>
        <h1 style={s.h1}>{title}</h1>
        {sub && <p style={s.sub}>{sub}</p>}
      </div>
      <button onClick={toggleNight} style={{ ...s.iconBtn, color: goldTone }}>
        {night ? <Sun size={18} /> : <Moon size={18} />}
      </button>
    </div>
  );

  const ProgressBar = ({ val, max, color }) => (
    <div style={{ height: 4, background: border, borderRadius: 2, overflow: "hidden" }}>
      <div style={{ width: `${(val / max) * 100}%`, height: "100%", background: color || C.gold, borderRadius: 2 }} />
    </div>
  );

  // --- LIBRARY ---
  const LibraryTab = () => (
    <div style={s.page}>
      <Header title="Your Library" sub="6 books · 3 in progress" />
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14, marginTop: 4 }}>
        {books.map(b => (
          <div key={b.id} style={{ ...s.glass, padding: 14, cursor: "pointer" }} onClick={() => { setCurrentBook(b); setTab("read"); }}>
            <div style={{ height: 90, background: b.cover, borderRadius: 10, marginBottom: 10, display: "flex", alignItems: "center", justifyContent: "center", position: "relative" }}>
              <BookOpen size={28} color={b.accent} opacity={0.8} />
              {b.read === b.pages && <div style={{ position: "absolute", top: 6, right: 6, ...s.badge(b.accent) }}>Done</div>}
            </div>
            <p style={{ fontSize: 12, fontWeight: 700, color: textPrimary, margin: "0 0 3px", lineHeight: 1.3 }}>{b.title}</p>
            <p style={{ fontSize: 10, color: textSecondary, margin: "0 0 8px" }}>{b.genre} · {b.pages}p</p>
            <ProgressBar val={b.read} max={b.pages} color={b.accent} />
            <p style={{ fontSize: 10, color: textSecondary, marginTop: 4 }}>{b.read}/{b.pages} pages</p>
          </div>
        ))}
      </div>
      <div style={s.promo}>
        <div>
          <p style={{ margin: 0, fontSize: 12, fontWeight: 700, color: goldTone }}>Explore in Resonance Learn</p>
          <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>Courses on ego development await</p>
        </div>
        <ChevronRight size={16} color={goldTone} />
      </div>
    </div>
  );

  // --- READER ---
  const ReaderTab = () => (
    <div style={{ ...s.page }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "20px 0 0" }}>
        <button style={s.iconBtn} onClick={() => setTab("library")}><ChevronLeft size={18} /></button>
        <p style={{ ...s.serif, fontSize: 13, color: textSecondary, margin: 0 }}>{currentBook.title.split(":")[0]}</p>
        <div style={{ display: "flex", gap: 8 }}>
          <button style={s.iconBtn}><Bookmark size={16} /></button>
          <button style={s.iconBtn}><Highlighter size={16} /></button>
        </div>
      </div>
      <div style={{ ...s.glass, marginTop: 16, padding: "28px 24px" }}>
        <p style={{ ...s.serif, fontSize: 11, color: goldTone, letterSpacing: 2, textTransform: "uppercase", margin: "0 0 20px" }}>Chapter 3 · The Witnessing Presence</p>
        {passage.split("\n\n").map((para, i) => (
          <p key={i} style={{ ...s.serif, fontSize: fontSize, lineHeight: 1.85, color: textPrimary, margin: "0 0 20px", textAlign: "justify" }}>{para}</p>
        ))}
      </div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginTop: 16 }}>
        <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
          <button style={s.iconBtn} onClick={() => setFontSize(f => Math.max(14, f - 1))}><Minus size={14} /></button>
          <span style={{ fontSize: 12, color: textSecondary }}>{fontSize}px</span>
          <button style={s.iconBtn} onClick={() => setFontSize(f => Math.min(26, f + 1))}><Plus size={14} /></button>
        </div>
        <p style={{ fontSize: 12, color: textSecondary, margin: 0 }}>Page 187 of 312</p>
        <div style={{ display: "flex", gap: 8 }}>
          <button style={s.iconBtn}><ChevronLeft size={14} /></button>
          <button style={s.iconBtn}><ChevronRight size={14} /></button>
        </div>
      </div>
      <div style={s.promo}>
        <div>
          <p style={{ margin: 0, fontSize: 12, fontWeight: 700, color: goldTone }}>Journal about this passage</p>
          <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>Open Resonance Journal to reflect</p>
        </div>
        <ChevronRight size={16} color={goldTone} />
      </div>
    </div>
  );

  // --- AUDIOBOOK ---
  const AudioTab = () => (
    <div style={s.page}>
      <Header title="Now Listening" sub="Luminous: Foundations" />
      <div style={{ ...s.glass, padding: 20, textAlign: "center", marginBottom: 16 }}>
        <div style={{ width: 80, height: 80, borderRadius: 16, background: C.forest, margin: "0 auto 12px", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Headphones size={36} color={C.gold} />
        </div>
        <p style={{ ...s.serif, fontSize: 16, fontWeight: 600, color: textPrimary, margin: "0 0 4px" }}>Ch. 3 · The Witnessing Presence</p>
        <p style={{ fontSize: 12, color: textSecondary, margin: "0 0 16px" }}>Narrated by the Author · 35:52</p>
        <div style={{ marginBottom: 8 }}>
          <ProgressBar val={progress} max={100} />
          <div style={{ display: "flex", justifyContent: "space-between", marginTop: 4 }}>
            <span style={{ fontSize: 11, color: textSecondary }}>12:10</span>
            <span style={{ fontSize: 11, color: textSecondary }}>35:52</span>
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 16, marginTop: 12 }}>
          <button style={s.iconBtn}><SkipBack size={18} /></button>
          <button onClick={() => setPlaying(p => !p)} style={{ background: C.gold, border: "none", borderRadius: "50%", width: 52, height: 52, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
            {playing ? <Pause size={22} color={C.dark} /> : <Play size={22} color={C.dark} />}
          </button>
          <button style={s.iconBtn}><SkipForward size={18} /></button>
        </div>
        <div style={{ display: "flex", justifyContent: "center", gap: 12, marginTop: 16 }}>
          {["0.5x","0.75x","1x","1.25x","1.5x","2x"].map(sp => (
            <button key={sp} onClick={() => setSpeed(sp)} style={{ ...s.iconBtn, fontSize: 11, fontWeight: 700, color: speed === sp ? C.gold : textSecondary, borderColor: speed === sp ? C.gold : border, padding: "5px 8px" }}>{sp}</button>
          ))}
        </div>
        <div style={{ display: "flex", justifyContent: "center", gap: 10, marginTop: 12, alignItems: "center" }}>
          <Clock size={13} color={textSecondary} />
          <select value={timer} onChange={e => setTimer(e.target.value)} style={{ background: surfaceMid, border: `1px solid ${border}`, borderRadius: 8, padding: "5px 10px", fontSize: 12, color: textPrimary, cursor: "pointer" }}>
            {["Off","5 min","10 min","20 min","30 min","45 min","1 hour"].map(t => <option key={t}>{t}</option>)}
          </select>
        </div>
      </div>
      <p style={{ fontSize: 12, fontWeight: 700, color: textSecondary, margin: "0 0 10px", letterSpacing: 1, textTransform: "uppercase" }}>Chapters</p>
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        {chapters.map(ch => (
          <div key={ch.n} style={{ ...s.glass, padding: "12px 16px", display: "flex", alignItems: "center", gap: 12, opacity: ch.done ? 0.6 : 1 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: ch.done ? C.gold : surfaceMid, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              {ch.done ? <BookOpen size={13} color={C.dark} /> : <span style={{ fontSize: 11, fontWeight: 700, color: textSecondary }}>{ch.n}</span>}
            </div>
            <div style={{ flex: 1 }}>
              <p style={{ margin: 0, fontSize: 13, fontWeight: 600, color: textPrimary }}>{ch.title}</p>
              <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>{ch.dur}</p>
            </div>
            <button style={{ background: "transparent", border: "none", cursor: "pointer", color: textSecondary }}><Bookmark size={14} /></button>
          </div>
        ))}
      </div>
    </div>
  );

  // --- HIGHLIGHTS ---
  const HighlightsTab = () => (
    <div style={s.page}>
      <Header title="Your Highlights" sub={`${highlights.length} saved passages`} />
      <div style={{ display: "flex", gap: 10, marginBottom: 16 }}>
        <button style={s.btn()}><Download size={14} />Export All</button>
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        {highlights.map(h => (
          <div key={h.id} style={{ ...s.glass, padding: 20 }}>
            <div style={{ width: 3, height: "100%", position: "absolute", left: 0, top: 0, background: C.gold, borderRadius: "16px 0 0 16px" }} />
            <p style={{ ...s.serif, fontSize: 17, lineHeight: 1.7, color: textPrimary, margin: "0 0 12px", fontStyle: "italic" }}>"{h.text}"</p>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <p style={{ margin: 0, fontSize: 11, fontWeight: 700, color: goldTone }}>{h.book}</p>
                <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>Page {h.page}</p>
              </div>
              <div style={{ display: "flex", gap: 8 }}>
                <button style={s.iconBtn}><Share2 size={14} /></button>
                <button style={s.iconBtn}><Bookmark size={14} /></button>
              </div>
            </div>
          </div>
        ))}
      </div>
      <div style={s.promo}>
        <div>
          <p style={{ margin: 0, fontSize: 12, fontWeight: 700, color: goldTone }}>Journal about this passage</p>
          <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>Deepen your insight in Resonance Journal</p>
        </div>
        <ChevronRight size={16} color={goldTone} />
      </div>
    </div>
  );

  // --- DAILY ---
  const DailyTab = () => (
    <div style={s.page}>
      <Header title="Daily Reflection" sub={`Day ${todayReflection.day} of 365`} />
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
        <Calendar size={14} color={goldTone} />
        <span style={{ fontSize: 12, color: textSecondary }}>March 21, 2026</span>
        <div style={{ flex: 1 }} />
        <div style={s.badge(C.forest)}>Daily Reflections</div>
      </div>
      <div style={{ ...s.glass, padding: 24, marginBottom: 16 }}>
        <p style={{ ...s.serif, fontSize: 13, color: goldTone, letterSpacing: 2, textTransform: "uppercase", margin: "0 0 10px" }}>{todayReflection.title}</p>
        <p style={{ ...s.serif, fontSize: 19, lineHeight: 1.8, color: textPrimary, margin: 0, fontStyle: "italic" }}>{todayReflection.text}</p>
      </div>
      <div style={{ background: night ? "rgba(197,160,89,0.08)" : "rgba(197,160,89,0.07)", border: `1px solid ${goldTone}30`, borderRadius: 14, padding: 20 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
          <AlignLeft size={14} color={goldTone} />
          <p style={{ margin: 0, fontSize: 12, fontWeight: 700, color: goldTone, letterSpacing: 1, textTransform: "uppercase" }}>Reflection Prompt</p>
        </div>
        <p style={{ ...s.serif, fontSize: 15, lineHeight: 1.75, color: textPrimary, margin: "0 0 14px" }}>{todayReflection.prompt}</p>
        <button style={s.btn()}><BookOpen size={14} />Write in Journal</button>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginTop: 16 }}>
        {[{ icon: <Flame size={18} color={C.gold} />, label: "Reading Streak", val: "12 days" }, { icon: <BarChart2 size={18} color={C.gold} />, label: "Completed", val: "82 / 365" }].map((stat, i) => (
          <div key={i} style={{ ...s.glass, padding: 14, textAlign: "center" }}>
            <div style={{ display: "flex", justifyContent: "center", marginBottom: 6 }}>{stat.icon}</div>
            <p style={{ margin: 0, fontSize: 16, fontWeight: 700, color: textPrimary }}>{stat.val}</p>
            <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>{stat.label}</p>
          </div>
        ))}
      </div>
      <div style={s.promo}>
        <div>
          <p style={{ margin: 0, fontSize: 12, fontWeight: 700, color: goldTone }}>Explore in Resonance Learn</p>
          <p style={{ margin: "2px 0 0", fontSize: 11, color: textSecondary }}>Guided course on this theme</p>
        </div>
        <ChevronRight size={16} color={goldTone} />
      </div>
    </div>
  );

  const tabs = [
    { id: "library", label: "Library", icon: Library },
    { id: "read", label: "Read", icon: BookOpen },
    { id: "listen", label: "Listen", icon: Headphones },
    { id: "highlights", label: "Highlights", icon: Star },
    { id: "daily", label: "Daily", icon: Sun },
  ];

  return (
    <>
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400;1,600&family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet" />
      <div style={s.wrap}>
        <div style={s.blob("−10%", "0%", 400, C.forest)} />
        <div style={s.blob("60%", "40%", 350, C.gold)} />
        <div style={s.blob("20%", "70%", 300, C.mid)} />

        {tab === "library" && <LibraryTab />}
        {tab === "read" && <ReaderTab />}
        {tab === "listen" && <AudioTab />}
        {tab === "highlights" && <HighlightsTab />}
        {tab === "daily" && <DailyTab />}

        <nav style={s.nav}>
          {tabs.map(({ id, label, icon: Icon }) => (
            <button key={id} style={{ ...s.navItem(tab === id), background: "none", border: "none", cursor: "pointer" }} onClick={() => setTab(id)}>
              <Icon size={20} />
              <span>{label}</span>
            </button>
          ))}
        </nav>
      </div>
    </>
  );
}
