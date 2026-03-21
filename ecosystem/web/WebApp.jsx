import { useState } from "react";
import {
  Home, BookOpen, MessageCircle, PenLine, Wind, Library,
  Quote, User, ChevronLeft, ChevronRight, Search, Play, Pause,
  Star, Share2, Heart, Plus, Send, Sun, Moon, Menu, X,
  TrendingUp, Clock, Flame, Award, ChevronDown, ChevronUp
} from "lucide-react";

const C = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", forest: "#1B402E",
  mist: "#D1E0D7", gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
  glass: "rgba(18,46,33,0.55)", glassBorder: "rgba(197,160,89,0.18)",
};

const font = {
  head: "'Cormorant Garamond', Georgia, serif",
  body: "'Manrope', system-ui, sans-serif",
};

const s = {
  app: { display: "flex", height: "100vh", background: C.dark, fontFamily: font.body, color: C.cream, overflow: "hidden" },
  sidebar: (open) => ({
    width: open ? 220 : 64, minWidth: open ? 220 : 64, background: C.night,
    borderRight: `1px solid ${C.glassBorder}`, display: "flex", flexDirection: "column",
    transition: "width 0.28s cubic-bezier(.4,0,.2,1)", overflow: "hidden",
  }),
  sideItem: (active) => ({
    display: "flex", alignItems: "center", gap: 12, padding: "11px 18px",
    cursor: "pointer", borderRadius: 10, margin: "2px 8px",
    background: active ? "rgba(197,160,89,0.13)" : "transparent",
    color: active ? C.gold : C.mist, fontWeight: active ? 700 : 400,
    borderLeft: active ? `3px solid ${C.gold}` : "3px solid transparent",
    transition: "all 0.18s", whiteSpace: "nowrap", fontSize: 14,
  }),
  main: { flex: 1, display: "flex", flexDirection: "column", overflow: "hidden" },
  topbar: {
    height: 56, background: C.night, borderBottom: `1px solid ${C.glassBorder}`,
    display: "flex", alignItems: "center", gap: 12, padding: "0 22px",
  },
  searchBox: {
    flex: 1, maxWidth: 380, background: C.glass, border: `1px solid ${C.glassBorder}`,
    borderRadius: 24, display: "flex", alignItems: "center", gap: 8,
    padding: "7px 16px", color: C.cream,
  },
  searchInput: {
    background: "none", border: "none", outline: "none", color: C.cream,
    fontFamily: font.body, fontSize: 14, width: "100%",
  },
  content: { flex: 1, overflowY: "auto", padding: 24 },
  glass: (extra = {}) => ({
    background: C.glass, border: `1px solid ${C.glassBorder}`,
    borderRadius: 16, backdropFilter: "blur(12px)", ...extra,
  }),
  h1: { fontFamily: font.head, fontSize: 28, fontWeight: 700, color: C.cream, margin: 0 },
  h2: { fontFamily: font.head, fontSize: 20, fontWeight: 600, color: C.goldLight, margin: "0 0 14px" },
  grid: (cols) => ({ display: "grid", gridTemplateColumns: `repeat(${cols}, 1fr)`, gap: 16 }),
  btn: (variant = "gold") => ({
    padding: "8px 18px", borderRadius: 24, border: "none", cursor: "pointer", fontFamily: font.body,
    fontSize: 13, fontWeight: 600, transition: "all 0.18s",
    background: variant === "gold" ? C.gold : variant === "ghost" ? "transparent" : C.forest,
    color: variant === "gold" ? C.night : C.cream,
    border: variant === "ghost" ? `1px solid ${C.glassBorder}` : "none",
  }),
  tag: (active) => ({
    padding: "5px 14px", borderRadius: 20, fontSize: 12, fontWeight: 600, cursor: "pointer",
    background: active ? C.gold : C.glass, color: active ? C.night : C.mist,
    border: `1px solid ${active ? C.gold : C.glassBorder}`, transition: "all 0.18s",
  }),
  bar: (pct) => ({
    height: 6, borderRadius: 3, background: `linear-gradient(90deg, ${C.gold} ${pct}%, ${C.forest} ${pct}%)`,
  }),
  bubble: (isCoach) => ({
    maxWidth: "72%", padding: "10px 16px", borderRadius: isCoach ? "4px 16px 16px 16px" : "16px 4px 16px 16px",
    background: isCoach ? C.forest : `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
    color: isCoach ? C.cream : C.night, fontSize: 14, lineHeight: 1.55,
    alignSelf: isCoach ? "flex-start" : "flex-end",
  }),
};

const NAV = [
  { id: "home", label: "Home", icon: Home },
  { id: "learn", label: "Learn", icon: BookOpen },
  { id: "coach", label: "Coach", icon: MessageCircle },
  { id: "journal", label: "Journal", icon: PenLine },
  { id: "meditate", label: "Meditate", icon: Wind },
  { id: "read", label: "Read", icon: Library },
  { id: "quotes", label: "Quotes", icon: Quote },
  { id: "profile", label: "Profile", icon: User },
];

const COURSES = [
  { title: "Stoic Foundations", author: "Marcus Aurelius Path", pct: 72, tag: "Philosophy" },
  { title: "Deep Focus", author: "Cal Newport Method", pct: 38, tag: "Productivity" },
  { title: "Emotional Intelligence", author: "Dr. Sarah Chen", pct: 91, tag: "Psychology" },
  { title: "Ancient Wisdom", author: "Eastern Traditions", pct: 14, tag: "Spirituality" },
];

const MEDITATIONS = [
  { title: "Morning Clarity", duration: "10 min", type: "Breathwork" },
  { title: "Deep Rest", duration: "20 min", type: "Sleep" },
  { title: "Focus Flow", duration: "15 min", type: "Concentration" },
  { title: "Evening Unwind", duration: "12 min", type: "Relaxation" },
];

const QUOTES = [
  { text: "The impediment to action advances action. What stands in the way becomes the way.", author: "Marcus Aurelius", cat: "Stoicism" },
  { text: "You have power over your mind, not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius", cat: "Stoicism" },
  { text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein", cat: "Wisdom" },
  { text: "The only way to do great work is to love what you do.", author: "Steve Jobs", cat: "Purpose" },
  { text: "Knowing yourself is the beginning of all wisdom.", author: "Aristotle", cat: "Philosophy" },
  { text: "He who has a why to live can bear almost any how.", author: "Nietzsche", cat: "Philosophy" },
  { text: "Be the change you wish to see in the world.", author: "Mahatma Gandhi", cat: "Wisdom" },
  { text: "Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.", author: "Rumi", cat: "Spirituality" },
];

const CHAT = [
  { role: "coach", text: "Good morning! I reviewed your journal entries this week. You're showing real growth in self-awareness. How are you feeling today?" },
  { role: "user", text: "Honestly, a bit overwhelmed with everything. Work deadlines, personal goals — it's a lot." },
  { role: "coach", text: "That's completely understandable. Let's apply the Stoic dichotomy: what in your current situation is actually within your control, and what isn't?" },
  { role: "user", text: "My responses and how I use my time, I guess. Not the deadlines themselves." },
];

function StatCard({ icon: Icon, label, value, sub }) {
  return (
    <div style={{ ...s.glass({ padding: 18 }), display: "flex", flexDirection: "column", gap: 6 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, color: C.gold }}>
        <Icon size={16} /><span style={{ fontSize: 12, color: C.mist }}>{label}</span>
      </div>
      <div style={{ fontFamily: font.head, fontSize: 32, fontWeight: 700, color: C.cream }}>{value}</div>
      <div style={{ fontSize: 11, color: C.mist }}>{sub}</div>
    </div>
  );
}

function HomeView({ navigate }) {
  const activity = [
    { icon: BookOpen, text: "Completed Module 3 of Stoic Foundations", time: "2h ago" },
    { icon: PenLine, text: "Journal entry — Morning reflection", time: "8h ago" },
    { icon: Wind, text: "10-min Morning Clarity meditation", time: "9h ago" },
    { icon: MessageCircle, text: "Coach session — Goal alignment", time: "Yesterday" },
    { icon: Quote, text: 'Saved quote by Marcus Aurelius', time: "2d ago" },
  ];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
      <div style={s.glass({ padding: "24px 28px", background: `linear-gradient(135deg, ${C.mid}, ${C.forest})` })}>
        <div style={{ fontSize: 13, color: C.goldLight, marginBottom: 4 }}>Welcome back</div>
        <h1 style={{ ...s.h1, fontSize: 34 }}>Alex Rivera</h1>
        <div style={{ fontSize: 14, color: C.mist, marginTop: 6 }}>Day 47 of your growth journey · Keep going.</div>
      </div>
      <div style={s.glass({ padding: 20 })}>
        <div style={{ fontSize: 11, color: C.gold, letterSpacing: 1, marginBottom: 10 }}>DAILY QUOTE</div>
        <div style={{ fontFamily: font.head, fontSize: 18, color: C.cream, lineHeight: 1.55 }}>
          "The impediment to action advances action. What stands in the way becomes the way."
        </div>
        <div style={{ fontSize: 13, color: C.goldLight, marginTop: 8 }}>— Marcus Aurelius</div>
      </div>
      <div style={s.grid(4)}>
        <StatCard icon={BookOpen} label="Courses" value="4" sub="2 in progress" />
        <StatCard icon={Wind} label="Sessions" value="28" sub="This month" />
        <StatCard icon={PenLine} label="Entries" value="47" sub="All time" />
        <StatCard icon={Clock} label="Minutes" value="340" sub="This week" />
      </div>
      <div style={{ display: "flex", gap: 16 }}>
        <div style={{ ...s.glass({ padding: 20 }), flex: 2 }}>
          <h2 style={s.h2}>Recent Activity</h2>
          {activity.map((a, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, padding: "9px 0", borderBottom: i < activity.length - 1 ? `1px solid ${C.glassBorder}` : "none" }}>
              <a.icon size={15} color={C.gold} />
              <span style={{ flex: 1, fontSize: 13, color: C.cream }}>{a.text}</span>
              <span style={{ fontSize: 11, color: C.mist }}>{a.time}</span>
            </div>
          ))}
        </div>
        <div style={{ ...s.glass({ padding: 20 }), flex: 1 }}>
          <h2 style={s.h2}>Recommended</h2>
          {[{ label: "Stoic Exercises", go: "learn" }, { label: "Evening Journal", go: "journal" }, { label: "Sleep Meditation", go: "meditate" }].map((r, i) => (
            <div key={i} onClick={() => navigate(r.go)} style={{ padding: "9px 0", borderBottom: i < 2 ? `1px solid ${C.glassBorder}` : "none", cursor: "pointer", fontSize: 13, color: C.goldLight }}>
              → {r.label}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function LearnView() {
  const [q, setQ] = useState("");
  const filtered = COURSES.filter(c => c.title.toLowerCase().includes(q.toLowerCase()));
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={s.h1}>Learn</h1>
        <div style={{ ...s.searchBox, maxWidth: 240 }}>
          <Search size={14} color={C.mist} />
          <input placeholder="Search courses…" value={q} onChange={e => setQ(e.target.value)} style={s.searchInput} />
        </div>
      </div>
      <div style={s.grid(2)}>
        {filtered.map((c, i) => (
          <div key={i} style={s.glass({ padding: 22 })}>
            <div style={{ fontSize: 11, color: C.gold, letterSpacing: 1, marginBottom: 6 }}>{c.tag.toUpperCase()}</div>
            <div style={{ fontFamily: font.head, fontSize: 20, color: C.cream, marginBottom: 4 }}>{c.title}</div>
            <div style={{ fontSize: 12, color: C.mist, marginBottom: 14 }}>{c.author}</div>
            <div style={s.bar(c.pct)} />
            <div style={{ fontSize: 11, color: C.goldLight, marginTop: 6 }}>{c.pct}% complete</div>
            <button style={{ ...s.btn("ghost"), marginTop: 14, width: "100%" }}>Continue →</button>
          </div>
        ))}
      </div>
    </div>
  );
}

function CoachView() {
  const [msgs, setMsgs] = useState(CHAT);
  const [input, setInput] = useState("");
  const suggested = ["Tell me about Stoicism", "Help me set a weekly goal", "What should I focus on?"];
  const send = () => {
    if (!input.trim()) return;
    setMsgs(m => [...m, { role: "user", text: input }]);
    const reply = "That's a thoughtful perspective. Let's explore this further — what would the ideal version of yourself do in this situation?";
    setTimeout(() => setMsgs(m => [...m, { role: "coach", text: reply }]), 700);
    setInput("");
  };
  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", gap: 16 }}>
      <h1 style={s.h1}>Coach</h1>
      <div style={{ ...s.glass({ padding: 0, overflow: "hidden" }), flex: 1, display: "flex", flexDirection: "column" }}>
        <div style={{ padding: "14px 20px", borderBottom: `1px solid ${C.glassBorder}`, display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{ width: 32, height: 32, borderRadius: "50%", background: `linear-gradient(135deg,${C.gold},${C.forest})`, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <MessageCircle size={16} color={C.night} />
          </div>
          <div>
            <div style={{ fontSize: 14, fontWeight: 600 }}>Resonance Coach</div>
            <div style={{ fontSize: 11, color: C.gold }}>● Online</div>
          </div>
        </div>
        <div style={{ flex: 1, overflowY: "auto", padding: 20, display: "flex", flexDirection: "column", gap: 12 }}>
          {msgs.map((m, i) => <div key={i} style={s.bubble(m.role === "coach")}>{m.text}</div>)}
        </div>
        <div style={{ padding: 12, borderTop: `1px solid ${C.glassBorder}` }}>
          <div style={{ display: "flex", gap: 8, marginBottom: 10, flexWrap: "wrap" }}>
            {suggested.map((q, i) => (
              <button key={i} onClick={() => setInput(q)} style={s.tag(false)}>{q}</button>
            ))}
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <input value={input} onChange={e => setInput(e.target.value)} onKeyDown={e => e.key === "Enter" && send()}
              placeholder="Ask your coach…" style={{ ...s.searchInput, ...s.glass({ padding: "10px 16px", flex: 1, borderRadius: 24 }) }} />
            <button onClick={send} style={{ ...s.btn("gold"), borderRadius: "50%", width: 40, height: 40, padding: 0, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Send size={15} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function JournalView() {
  const [text, setText] = useState("");
  const entries = ["March 20 — On patience", "March 19 — Gratitude practice", "March 18 — Focus & intention", "March 17 — Evening reflection"];
  return (
    <div style={{ display: "flex", gap: 20, height: "100%" }}>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 16 }}>
        <h1 style={s.h1}>Journal</h1>
        <div style={s.glass({ padding: 18 })}>
          <div style={{ fontSize: 11, color: C.gold, letterSpacing: 1 }}>TODAY'S PROMPT</div>
          <div style={{ fontFamily: font.head, fontSize: 17, color: C.cream, marginTop: 8 }}>
            What is one thing you're resisting right now, and what would happen if you leaned into it?
          </div>
        </div>
        <textarea value={text} onChange={e => setText(e.target.value)} placeholder="Begin writing…"
          style={{ flex: 1, background: C.glass, border: `1px solid ${C.glassBorder}`, borderRadius: 16, padding: 20, color: C.cream, fontFamily: font.body, fontSize: 14, lineHeight: 1.7, outline: "none", resize: "none" }} />
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <span style={{ fontSize: 12, color: C.mist }}>{text.split(/\s+/).filter(Boolean).length} words</span>
          <button style={s.btn("gold")}>Save Entry</button>
        </div>
      </div>
      <div style={{ width: 220, display: "flex", flexDirection: "column", gap: 12 }}>
        <h2 style={{ ...s.h2, marginTop: 48 }}>Past Entries</h2>
        {entries.map((e, i) => (
          <div key={i} style={s.glass({ padding: "12px 16px", cursor: "pointer", fontSize: 13, color: C.goldLight })}>
            {e}
          </div>
        ))}
        <button style={{ ...s.btn("ghost"), width: "100%" }}><Plus size={13} /> New Entry</button>
      </div>
    </div>
  );
}

function MeditateView() {
  const [playing, setPlaying] = useState(false);
  const [secs, setSecs] = useState(600);
  const pct = ((600 - secs) / 600) * 100;
  const fmt = (s) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}`;
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
      <h1 style={s.h1}>Meditate</h1>
      <div style={{ display: "flex", gap: 20 }}>
        <div style={{ ...s.glass({ padding: 32, flex: 1, textAlign: "center" }) }}>
          <div style={{ fontFamily: font.head, fontSize: 20, color: C.goldLight, marginBottom: 22 }}>Morning Clarity</div>
          <div style={{ position: "relative", width: 140, height: 140, margin: "0 auto 24px" }}>
            <svg viewBox="0 0 140 140" style={{ position: "absolute", inset: 0, transform: "rotate(-90deg)" }}>
              <circle cx="70" cy="70" r="62" fill="none" stroke={C.forest} strokeWidth="8" />
              <circle cx="70" cy="70" r="62" fill="none" stroke={C.gold} strokeWidth="8"
                strokeDasharray={`${2 * Math.PI * 62}`} strokeDashoffset={`${2 * Math.PI * 62 * (1 - pct / 100)}`}
                strokeLinecap="round" style={{ transition: "stroke-dashoffset 1s" }} />
            </svg>
            <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: font.head, fontSize: 28, color: C.cream }}>
              {fmt(secs)}
            </div>
          </div>
          <button onClick={() => setPlaying(p => !p)} style={{ ...s.btn("gold"), borderRadius: "50%", width: 52, height: 52, display: "inline-flex", alignItems: "center", justifyContent: "center", padding: 0 }}>
            {playing ? <Pause size={20} /> : <Play size={20} />}
          </button>
          <div style={{ fontSize: 12, color: C.mist, marginTop: 14 }}>Breathwork · 10 min</div>
        </div>
      </div>
      <h2 style={s.h2}>Library</h2>
      <div style={s.grid(4)}>
        {MEDITATIONS.map((m, i) => (
          <div key={i} style={{ ...s.glass({ padding: 18, cursor: "pointer", textAlign: "center" }) }}>
            <div style={{ fontSize: 11, color: C.gold, marginBottom: 6 }}>{m.type.toUpperCase()}</div>
            <div style={{ fontFamily: font.head, fontSize: 16, color: C.cream, marginBottom: 4 }}>{m.title}</div>
            <div style={{ fontSize: 12, color: C.mist }}>{m.duration}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ReadView() {
  const [fontSize, setFontSize] = useState(16);
  const toc = ["I. The Inner Citadel", "II. On Obstacles", "III. Memento Mori", "IV. The View From Above"];
  return (
    <div style={{ display: "flex", gap: 20, height: "100%" }}>
      <div style={{ width: 200, display: "flex", flexDirection: "column", gap: 8 }}>
        <h2 style={{ ...s.h2, marginTop: 0 }}>Contents</h2>
        {toc.map((t, i) => (
          <div key={i} style={{ ...s.glass({ padding: "10px 14px", cursor: "pointer", fontSize: 13, color: i === 1 ? C.gold : C.mist, borderLeft: i === 1 ? `3px solid ${C.gold}` : "3px solid transparent" }) }}>
            {t}
          </div>
        ))}
      </div>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 14 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <h1 style={s.h1}>Meditations</h1>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <button onClick={() => setFontSize(f => Math.max(13, f - 1))} style={s.btn("ghost")}>A-</button>
            <span style={{ fontSize: 12, color: C.mist }}>{fontSize}px</span>
            <button onClick={() => setFontSize(f => Math.min(22, f + 1))} style={s.btn("ghost")}>A+</button>
          </div>
        </div>
        <div style={{ ...s.glass({ padding: 28, flex: 1, overflowY: "auto" }) }}>
          <h2 style={{ fontFamily: font.head, fontSize: 22, color: C.goldLight, marginTop: 0 }}>II. On Obstacles</h2>
          <p style={{ fontSize, lineHeight: 1.8, color: C.cream }}>
            Begin at once to live, and count each separate day as a separate life. The man who postpones, one who lives in his own future tense, shall find that life keeps slipping away, a river that flows and does not return.
          </p>
          <p style={{ fontSize, lineHeight: 1.8, color: C.cream }}>
            Our life is what our thoughts make it. The soul is dyed the color of its thoughts. Think only on those things that are in line with your principles and can bear the light of day. The content of your character is your choice.
          </p>
          <p style={{ fontSize, lineHeight: 1.8, color: C.mist }}>
            Day by day, what you do is who you become. Your integrity is your destiny — it is the light that guides your way. Take heed: if you pursue leisure above all, you lose not a day but your entire nature.
          </p>
        </div>
      </div>
    </div>
  );
}

function QuotesView() {
  const cats = ["All", "Stoicism", "Wisdom", "Philosophy", "Purpose", "Spirituality"];
  const [active, setActive] = useState("All");
  const [favs, setFavs] = useState([]);
  const filtered = QUOTES.filter(q => active === "All" || q.cat === active);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
      <h1 style={s.h1}>Quotes</h1>
      <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
        {cats.map(c => <button key={c} onClick={() => setActive(c)} style={s.tag(active === c)}>{c}</button>)}
      </div>
      <div style={s.grid(2)}>
        {filtered.map((q, i) => (
          <div key={i} style={s.glass({ padding: 22 })}>
            <div style={{ fontSize: 11, color: C.gold, letterSpacing: 1, marginBottom: 10 }}>{q.cat.toUpperCase()}</div>
            <div style={{ fontFamily: font.head, fontSize: 17, color: C.cream, lineHeight: 1.6, marginBottom: 12 }}>"{q.text}"</div>
            <div style={{ fontSize: 13, color: C.goldLight, marginBottom: 14 }}>— {q.author}</div>
            <div style={{ display: "flex", gap: 8 }}>
              <button onClick={() => setFavs(f => f.includes(i) ? f.filter(x => x !== i) : [...f, i])}
                style={{ ...s.btn("ghost"), display: "flex", alignItems: "center", gap: 5, color: favs.includes(i) ? C.gold : C.mist }}>
                <Heart size={13} fill={favs.includes(i) ? C.gold : "none"} /> {favs.includes(i) ? "Saved" : "Save"}
              </button>
              <button style={{ ...s.btn("ghost"), display: "flex", alignItems: "center", gap: 5 }}>
                <Share2 size={13} /> Share
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function ProfileView({ night, setNight }) {
  const apps = ["Apple Health", "Notion", "Spotify", "Google Calendar"];
  const stats = [{ label: "Current Streak", value: "47 days", icon: Flame }, { label: "Best Streak", value: "63 days", icon: Award }, { label: "Total Sessions", value: "284", icon: TrendingUp }];
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 22 }}>
      <h1 style={s.h1}>Profile</h1>
      <div style={{ display: "flex", gap: 20 }}>
        <div style={{ ...s.glass({ padding: 24 }), flex: 1 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 20 }}>
            <div style={{ width: 56, height: 56, borderRadius: "50%", background: `linear-gradient(135deg,${C.gold},${C.forest})`, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <User size={24} color={C.night} />
            </div>
            <div>
              <div style={{ fontFamily: font.head, fontSize: 22, color: C.cream }}>Alex Rivera</div>
              <div style={{ fontSize: 13, color: C.mist }}>alex@resonance.app</div>
            </div>
          </div>
          <div style={s.grid(3)}>
            {stats.map((st, i) => (
              <div key={i} style={s.glass({ padding: 14, textAlign: "center" })}>
                <st.icon size={18} color={C.gold} style={{ margin: "0 auto 6px" }} />
                <div style={{ fontFamily: font.head, fontSize: 20, color: C.cream }}>{st.value}</div>
                <div style={{ fontSize: 11, color: C.mist }}>{st.label}</div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 16, width: 260 }}>
          <div style={s.glass({ padding: 20 })}>
            <h2 style={s.h2}>Preferences</h2>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", fontSize: 13 }}>
              <span style={{ color: C.cream }}>Theme</span>
              <button onClick={() => setNight(n => !n)} style={{ ...s.btn("ghost"), display: "flex", alignItems: "center", gap: 6 }}>
                {night ? <Moon size={14} /> : <Sun size={14} />} {night ? "Night" : "Day"}
              </button>
            </div>
          </div>
          <div style={s.glass({ padding: 20 })}>
            <h2 style={s.h2}>Connected Apps</h2>
            {apps.map((a, i) => (
              <div key={i} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "7px 0", borderBottom: i < apps.length - 1 ? `1px solid ${C.glassBorder}` : "none", fontSize: 13 }}>
                <span style={{ color: C.cream }}>{a}</span>
                <span style={{ color: C.gold, fontSize: 11 }}>Connected</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

const VIEWS = { home: HomeView, learn: LearnView, coach: CoachView, journal: JournalView, meditate: MeditateView, read: ReadView, quotes: QuotesView, profile: ProfileView };

export default function WebApp() {
  const [view, setView] = useState("home");
  const [open, setOpen] = useState(true);
  const [night, setNight] = useState(true);
  const [search, setSearch] = useState("");
  const View = VIEWS[view];

  return (
    <div style={{ ...s.app, background: night ? C.dark : "#1e3a2e" }}>
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Manrope:wght@400;600;700&display=swap" rel="stylesheet" />
      <div style={s.sidebar(open)}>
        <div style={{ padding: "18px 14px 10px", display: "flex", alignItems: "center", gap: 10, borderBottom: `1px solid ${C.glassBorder}`, marginBottom: 8 }}>
          {open && <span style={{ fontFamily: font.head, fontSize: 20, color: C.gold, whiteSpace: "nowrap" }}>Resonance</span>}
          {!open && <span style={{ fontFamily: font.head, fontSize: 18, color: C.gold }}>R</span>}
        </div>
        {NAV.map(({ id, label, icon: Icon }) => (
          <div key={id} onClick={() => setView(id)} style={s.sideItem(view === id)}>
            <Icon size={18} style={{ minWidth: 18 }} />
            {open && <span>{label}</span>}
          </div>
        ))}
        <div style={{ flex: 1 }} />
        <div onClick={() => setOpen(o => !o)} style={{ ...s.sideItem(false), margin: "8px 8px 16px", justifyContent: open ? "flex-end" : "center" }}>
          {open ? <><span style={{ fontSize: 12 }}>Collapse</span><ChevronLeft size={16} /></> : <ChevronRight size={16} />}
        </div>
      </div>
      <div style={s.main}>
        <div style={s.topbar}>
          <div style={s.searchBox}>
            <Search size={14} color={C.mist} />
            <input placeholder="Search everything…" value={search} onChange={e => setSearch(e.target.value)} style={s.searchInput} />
          </div>
          <div style={{ flex: 1 }} />
          <button onClick={() => setNight(n => !n)} style={{ ...s.btn("ghost"), display: "flex", alignItems: "center", gap: 6, padding: "6px 12px" }}>
            {night ? <Moon size={15} /> : <Sun size={15} />}
          </button>
          <div onClick={() => setView("profile")} style={{ width: 34, height: 34, borderRadius: "50%", background: `linear-gradient(135deg,${C.gold},${C.forest})`, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
            <User size={16} color={C.night} />
          </div>
        </div>
        <div style={s.content}>
          <View navigate={setView} night={night} setNight={setNight} />
        </div>
      </div>
    </div>
  );
}
