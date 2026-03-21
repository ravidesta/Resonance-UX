import { useState, useEffect, useRef } from "react";
import { BookOpen, PenLine, BarChart2, Archive, Home, Sun, Moon, Search, Clock, Flame, Share2, ChevronRight, Star, Wind, Droplets, Cloud, Zap } from "lucide-react";

const C = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", deep: "#1B402E",
  muted: "#D1E0D7", gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
};

const quotes = [
  { text: "The privilege of a lifetime is to become who you truly are.", author: "C.G. Jung" },
  { text: "Between stimulus and response there is a space. In that space is our power to choose our response.", author: "Viktor Frankl" },
  { text: "What we don't need in the midst of struggle is shame for being human.", author: "Brené Brown" },
  { text: "The curious paradox is that when I accept myself just as I am, then I can change.", author: "Carl Rogers" },
  { text: "Your task is not to seek for love, but merely to seek and find all the barriers within yourself.", author: "Rumi" },
];

const moods = [
  { id: "sunshine", label: "Sunshine", sub: "Energized & bright", icon: Sun, color: "#C5A059", bg: "rgba(197,160,89,0.15)" },
  { id: "breeze", label: "Gentle Breeze", sub: "Calm & spacious", icon: Wind, color: "#7BB8A4", bg: "rgba(123,184,164,0.15)" },
  { id: "river", label: "Flowing River", sub: "In motion & engaged", icon: Droplets, color: "#5B9BB5", bg: "rgba(91,155,181,0.15)" },
  { id: "cloudy", label: "Cloudy Sky", sub: "Uncertain & reflective", icon: Cloud, color: "#9BA8A3", bg: "rgba(155,168,163,0.15)" },
  { id: "storm", label: "Storm Clearing", sub: "Processing & releasing", icon: Zap, color: "#8B7BAD", bg: "rgba(139,123,173,0.15)" },
];

const exercises = [
  { title: "Who Am I Beyond My Roles?", cat: "Identity", time: "15 min", color: C.gold },
  { title: "Inner Critic & Inner Champion", cat: "Self-Compassion", time: "20 min", color: "#7BB8A4" },
  { title: "Gratitude & Growth Inventory", cat: "Gratitude", time: "10 min", color: "#C5A059" },
  { title: "Shadow Integration Reflection", cat: "Shadow Work", time: "25 min", color: "#8B7BAD" },
  { title: "My Attachment Map", cat: "Relationships", time: "20 min", color: "#5B9BB5" },
  { title: "Window of Tolerance Check-in", cat: "Nervous System", time: "12 min", color: "#7BB8A4" },
  { title: "Values in Action Review", cat: "Values", time: "15 min", color: C.gold },
  { title: "Letter to My Future Self", cat: "Vision", time: "30 min", color: "#D4826A" },
];

const sampleEntries = [
  { id: 1, date: "Mar 20", preview: "Today I noticed how quickly I shifted into 'helper mode' before even checking in with myself. There's something about being needed that...", mood: "river", words: 312 },
  { id: 2, date: "Mar 18", preview: "The shadow work exercise brought up memories I hadn't touched in years. Sitting with discomfort without running felt like a small victory...", mood: "storm", words: 487 },
  { id: 3, date: "Mar 15", preview: "Gratitude practice landed differently today. Instead of listing things, I felt into them. My chest opened. Something released...", mood: "sunshine", words: 205 },
];

const weekDays = ["M", "T", "W", "T", "F", "S", "S"];
const streakData = [true, true, true, false, true, true, false];
const weekMoods = ["sunshine", "river", "breeze", null, "cloudy", "storm", null];

export default function ResonanceJournal() {
  const [tab, setTab] = useState("home");
  const [dark, setDark] = useState(true);
  const [quote] = useState(quotes[Math.floor(Math.random() * quotes.length)]);
  const [selectedMood, setSelectedMood] = useState(null);
  const [writeText, setWriteText] = useState("");
  const [timer, setTimer] = useState(0);
  const [timerOn, setTimerOn] = useState(false);
  const [search, setSearch] = useState("");
  const [sharedEntry, setSharedEntry] = useState(null);
  const timerRef = useRef(null);

  useEffect(() => {
    if (timerOn) { timerRef.current = setInterval(() => setTimer(t => t + 1), 1000); }
    else clearInterval(timerRef.current);
    return () => clearInterval(timerRef.current);
  }, [timerOn]);

  const bg = dark ? C.night : "#EFF5F2";
  const surface = dark ? `rgba(18,46,33,0.7)` : `rgba(255,255,255,0.7)`;
  const surfaceSolid = dark ? C.mid : "#fff";
  const text = dark ? C.cream : C.dark;
  const textSub = dark ? C.muted : "#4A6358";
  const border = dark ? "rgba(209,224,215,0.12)" : "rgba(10,28,20,0.1)";

  const fmt = s => `${String(Math.floor(s / 60)).padStart(2, "0")}:${String(s % 60).padStart(2, "0")}`;
  const wordCount = writeText.trim() ? writeText.trim().split(/\s+/).length : 0;
  const moodObj = m => moods.find(x => x.id === m);
  const filtered = sampleEntries.filter(e => e.preview.toLowerCase().includes(search.toLowerCase()));

  const shell = {
    minHeight: "100vh", background: bg, color: text, fontFamily: "'Manrope', sans-serif",
    display: "flex", flexDirection: "column", position: "relative", overflow: "hidden", transition: "background 0.4s",
  };
  const blob = (top, left, clr, size = 320) => ({
    position: "absolute", top, left, width: size, height: size, borderRadius: "50%",
    background: clr, filter: "blur(80px)", opacity: dark ? 0.18 : 0.12, pointerEvents: "none", zIndex: 0,
  });
  const glass = (extra = {}) => ({
    background: surface, backdropFilter: "blur(16px)", WebkitBackdropFilter: "blur(16px)",
    border: `1px solid ${border}`, borderRadius: 16, ...extra,
  });
  const card = (extra = {}) => ({ ...glass({ padding: "18px 20px", marginBottom: 14, ...extra }) });

  const tabs = [
    { id: "home", label: "Home", icon: Home },
    { id: "workbook", label: "Workbook", icon: BookOpen },
    { id: "write", label: "Write", icon: PenLine },
    { id: "mood", label: "Mood", icon: BarChart2 },
    { id: "reflections", label: "Reflections", icon: Archive },
  ];

  // ── HOME ──
  const HomeScreen = () => (
    <div style={{ padding: "24px 20px 0" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
        <div>
          <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 26, fontWeight: 600, lineHeight: 1.2 }}>Good evening,</div>
          <div style={{ color: C.gold, fontFamily: "'Cormorant Garamond', serif", fontSize: 20, fontStyle: "italic" }}>your journal awaits</div>
        </div>
        <button onClick={() => setDark(d => !d)} style={{ background: surface, border: `1px solid ${border}`, borderRadius: 40, padding: "8px 14px", color: text, cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
          {dark ? <Sun size={15} color={C.gold} /> : <Moon size={15} />}
          <span style={{ fontSize: 12 }}>{dark ? "Day" : "Night"}</span>
        </button>
      </div>

      {/* Streak */}
      <div style={card()}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 14 }}>
          <Flame size={16} color={C.gold} />
          <span style={{ fontWeight: 600, fontSize: 14 }}>5-Day Streak</span>
        </div>
        <div style={{ display: "flex", gap: 8, justifyContent: "space-between" }}>
          {weekDays.map((d, i) => (
            <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
              <div style={{ width: 32, height: 32, borderRadius: "50%", background: streakData[i] ? C.gold : border, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 11, color: streakData[i] ? C.night : textSub, fontWeight: 700 }}>
                {streakData[i] ? "✓" : ""}
              </div>
              <span style={{ fontSize: 11, color: textSub }}>{d}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Daily Prompt */}
      <div style={card({ background: `linear-gradient(135deg, rgba(197,160,89,0.18), rgba(27,64,46,0.4))`, borderColor: "rgba(197,160,89,0.3)" })}>
        <div style={{ fontSize: 11, color: C.gold, fontWeight: 700, letterSpacing: 1, marginBottom: 8 }}>TODAY'S PROMPT</div>
        <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 20, lineHeight: 1.4, marginBottom: 14 }}>What would it mean to fully trust yourself today?</div>
        <button onClick={() => setTab("write")} style={{ background: C.gold, color: C.night, border: "none", borderRadius: 10, padding: "9px 18px", fontFamily: "'Manrope', sans-serif", fontWeight: 700, fontSize: 13, cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
          <PenLine size={14} /> Begin Writing
        </button>
      </div>

      {/* Quote */}
      <div style={{ ...card(), textAlign: "center" }}>
        <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 17, fontStyle: "italic", lineHeight: 1.6, marginBottom: 8, color: dark ? C.goldLight : C.deep }}>"{quote.text}"</div>
        <div style={{ fontSize: 12, color: textSub }}>— {quote.author}</div>
      </div>

      {/* Recent Entries */}
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 20, fontWeight: 600, marginBottom: 12 }}>Recent Entries</div>
      {sampleEntries.map(e => {
        const m = moodObj(e.mood);
        return (
          <div key={e.id} style={card({ cursor: "pointer" })}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6 }}>
              <span style={{ fontSize: 12, color: textSub }}>{e.date}</span>
              <div style={{ display: "flex", alignItems: "center", gap: 5, background: m.bg, borderRadius: 20, padding: "3px 10px" }}>
                <m.icon size={11} color={m.color} />
                <span style={{ fontSize: 11, color: m.color, fontWeight: 600 }}>{m.label}</span>
              </div>
            </div>
            <div style={{ fontSize: 13, color: textSub, lineHeight: 1.6 }}>{e.preview.slice(0, 90)}…</div>
          </div>
        );
      })}

      {/* Cross-promo */}
      <div style={card({ background: dark ? "rgba(91,155,181,0.1)" : "rgba(91,155,181,0.08)", borderColor: "rgba(91,155,181,0.25)", marginTop: 8 })}>
        <div style={{ fontSize: 12, color: "#5B9BB5", fontWeight: 700, marginBottom: 4 }}>EXPLORE THE ECOSYSTEM</div>
        <div style={{ fontSize: 13, color: textSub, marginBottom: 10 }}>Ready to go deeper on a theme from your journal?</div>
        <div style={{ display: "flex", gap: 8 }}>
          <button style={{ flex: 1, background: "rgba(91,155,181,0.2)", border: "1px solid rgba(91,155,181,0.3)", borderRadius: 10, padding: "8px 6px", color: "#5B9BB5", fontSize: 11, fontWeight: 700, cursor: "pointer" }}>💬 Resonance Coach</button>
          <button style={{ flex: 1, background: "rgba(197,160,89,0.15)", border: "1px solid rgba(197,160,89,0.3)", borderRadius: 10, padding: "8px 6px", color: C.gold, fontSize: 11, fontWeight: 700, cursor: "pointer" }}>📚 Resonance Learn</button>
        </div>
      </div>
      <div style={{ height: 20 }} />
    </div>
  );

  // ── WORKBOOK ──
  const WorkbookScreen = () => (
    <div style={{ padding: "24px 20px 0" }}>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 28, fontWeight: 600, marginBottom: 4 }}>Guided Workbook</div>
      <div style={{ fontSize: 13, color: textSub, marginBottom: 20 }}>Structured exercises for deeper self-inquiry</div>
      {exercises.map((ex, i) => (
        <div key={i} style={card({ display: "flex", alignItems: "center", gap: 14, cursor: "pointer" })}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: `${ex.color}22`, border: `1px solid ${ex.color}44`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            <Star size={18} color={ex.color} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 600, fontSize: 14, marginBottom: 4 }}>{ex.title}</div>
            <div style={{ display: "flex", gap: 8 }}>
              <span style={{ fontSize: 11, background: `${ex.color}22`, color: ex.color, borderRadius: 20, padding: "2px 9px", fontWeight: 600 }}>{ex.cat}</span>
              <span style={{ fontSize: 11, color: textSub, display: "flex", alignItems: "center", gap: 3 }}><Clock size={10} />{ex.time}</span>
            </div>
          </div>
          <ChevronRight size={16} color={textSub} />
        </div>
      ))}
      <div style={{ height: 20 }} />
    </div>
  );

  // ── WRITE ──
  const WriteScreen = () => (
    <div style={{ padding: "24px 20px 0", display: "flex", flexDirection: "column", height: "calc(100vh - 80px)" }}>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 22, fontWeight: 600, marginBottom: 4 }}>Free Write</div>
      <div style={{ ...glass({ padding: "12px 16px", marginBottom: 14 }), fontSize: 13, color: dark ? C.goldLight : C.deep, fontFamily: "'Cormorant Garamond', serif", fontStyle: "italic", lineHeight: 1.5 }}>
        "What would it mean to fully trust yourself today?"
      </div>
      <textarea
        value={writeText}
        onChange={e => setWriteText(e.target.value)}
        placeholder="Begin writing… let thoughts flow without judgment."
        style={{ flex: 1, background: surface, backdropFilter: "blur(16px)", border: `1px solid ${border}`, borderRadius: 16, padding: 18, color: text, fontFamily: "'Manrope', sans-serif", fontSize: 15, lineHeight: 1.8, resize: "none", outline: "none", marginBottom: 14 }}
      />
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
        <div style={{ ...glass({ padding: "10px 16px", display: "flex", gap: 14, flex: 1 }) }}>
          <span style={{ fontSize: 12, color: textSub }}><span style={{ color: C.gold, fontWeight: 700 }}>{wordCount}</span> words</span>
          <span style={{ fontSize: 12, color: textSub }}><span style={{ color: C.gold, fontWeight: 700 }}>{fmt(timer)}</span></span>
          <button onClick={() => setTimerOn(t => !t)} style={{ fontSize: 12, color: timerOn ? "#D4826A" : C.gold, background: "none", border: "none", cursor: "pointer", fontWeight: 700 }}>{timerOn ? "⏸ Pause" : "▶ Start"}</button>
        </div>
        <button style={{ background: C.gold, color: C.night, border: "none", borderRadius: 12, padding: "11px 20px", fontWeight: 700, fontSize: 13, cursor: "pointer" }}>Save</button>
      </div>
      <div style={{ ...glass({ padding: "12px 16px", marginBottom: 8 }), fontSize: 12, color: textSub, textAlign: "center" }}>
        Want to process this further? <span style={{ color: "#5B9BB5", fontWeight: 700, cursor: "pointer" }}>Chat with Resonance Coach →</span>
      </div>
    </div>
  );

  // ── MOOD ──
  const MoodScreen = () => (
    <div style={{ padding: "24px 20px 0" }}>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 28, fontWeight: 600, marginBottom: 4 }}>Mood Tracker</div>
      <div style={{ fontSize: 13, color: textSub, marginBottom: 20 }}>How are you showing up today?</div>
      {moods.map(m => (
        <div key={m.id} onClick={() => setSelectedMood(m.id)} style={card({ display: "flex", alignItems: "center", gap: 14, cursor: "pointer", borderColor: selectedMood === m.id ? m.color : border, background: selectedMood === m.id ? m.bg : surface })}>
          <div style={{ width: 46, height: 46, borderRadius: "50%", background: m.bg, display: "flex", alignItems: "center", justifyContent: "center" }}>
            <m.icon size={22} color={m.color} />
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 2 }}>{m.label}</div>
            <div style={{ fontSize: 12, color: textSub }}>{m.sub}</div>
          </div>
          {selectedMood === m.id && <div style={{ width: 10, height: 10, borderRadius: "50%", background: m.color }} />}
        </div>
      ))}

      {/* Weekly chart */}
      <div style={card({ marginTop: 8 })}>
        <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 18, fontWeight: 600, marginBottom: 14 }}>This Week</div>
        <div style={{ display: "flex", gap: 6, justifyContent: "space-between" }}>
          {weekDays.map((d, i) => {
            const m = weekMoods[i] ? moodObj(weekMoods[i]) : null;
            return (
              <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
                <div style={{ width: 34, height: 34, borderRadius: "50%", background: m ? m.bg : border, border: `1px solid ${m ? m.color + "44" : "transparent"}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
                  {m && <m.icon size={14} color={m.color} />}
                </div>
                <span style={{ fontSize: 10, color: textSub }}>{d}</span>
              </div>
            );
          })}
        </div>
      </div>

      {selectedMood && (
        <div style={card({ background: `${moodObj(selectedMood).bg}`, borderColor: moodObj(selectedMood).color + "44" })}>
          <div style={{ fontSize: 13, color: textSub, marginBottom: 10 }}>Log this mood with today's entry or explore what's underneath it.</div>
          <div style={{ display: "flex", gap: 8 }}>
            <button onClick={() => setTab("write")} style={{ flex: 1, background: C.gold, color: C.night, border: "none", borderRadius: 10, padding: "9px 0", fontWeight: 700, fontSize: 13, cursor: "pointer" }}>Write About It</button>
            <button style={{ flex: 1, background: "rgba(91,155,181,0.2)", border: "1px solid rgba(91,155,181,0.3)", borderRadius: 10, padding: "9px 0", color: "#5B9BB5", fontWeight: 700, fontSize: 13, cursor: "pointer" }}>Coach Chat</button>
          </div>
        </div>
      )}
      <div style={{ height: 20 }} />
    </div>
  );

  // ── REFLECTIONS ──
  const ReflectionsScreen = () => (
    <div style={{ padding: "24px 20px 0" }}>
      <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 28, fontWeight: 600, marginBottom: 14 }}>Reflections</div>
      <div style={{ ...glass({ padding: "10px 14px", marginBottom: 18, display: "flex", alignItems: "center", gap: 10 }) }}>
        <Search size={15} color={textSub} />
        <input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search your entries…" style={{ border: "none", background: "none", color: text, fontFamily: "'Manrope', sans-serif", fontSize: 14, flex: 1, outline: "none" }} />
      </div>

      {filtered.map(e => {
        const m = moodObj(e.mood);
        return (
          <div key={e.id} style={card({ cursor: "pointer" })}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8 }}>
              <span style={{ fontSize: 12, color: textSub, fontWeight: 600 }}>{e.date}</span>
              <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 4, background: m.bg, borderRadius: 20, padding: "3px 9px" }}>
                  <m.icon size={10} color={m.color} />
                  <span style={{ fontSize: 10, color: m.color, fontWeight: 700 }}>{m.label}</span>
                </div>
                <span style={{ fontSize: 11, color: textSub }}>{e.words}w</span>
              </div>
            </div>
            <div style={{ fontSize: 13, color: textSub, lineHeight: 1.7, marginBottom: 12 }}>{e.preview.slice(0, 120)}…</div>
            <button onClick={() => setSharedEntry(e)} style={{ display: "flex", alignItems: "center", gap: 6, background: "none", border: `1px solid ${border}`, borderRadius: 8, padding: "6px 12px", color: textSub, fontSize: 11, cursor: "pointer", fontFamily: "'Manrope', sans-serif" }}>
              <Share2 size={11} /> Create Quote Card
            </button>
          </div>
        );
      })}

      {sharedEntry && (
        <div style={{ position: "fixed", inset: 0, background: "rgba(5,16,11,0.85)", backdropFilter: "blur(8px)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 50, padding: 20 }}>
          <div style={{ background: `linear-gradient(135deg, ${C.mid}, ${C.deep})`, border: `1px solid rgba(197,160,89,0.4)`, borderRadius: 20, padding: 28, maxWidth: 340, width: "100%", textAlign: "center" }}>
            <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 16, fontStyle: "italic", lineHeight: 1.7, color: C.goldLight, marginBottom: 16 }}>"{sharedEntry.preview.slice(0, 100)}…"</div>
            <div style={{ fontSize: 12, color: C.muted, marginBottom: 20 }}>— My Resonance Journal, {sharedEntry.date}</div>
            <div style={{ display: "flex", gap: 10, justifyContent: "center" }}>
              <button style={{ background: C.gold, color: C.night, border: "none", borderRadius: 10, padding: "9px 20px", fontWeight: 700, fontSize: 13, cursor: "pointer" }}>Share</button>
              <button onClick={() => setSharedEntry(null)} style={{ background: "transparent", color: C.muted, border: `1px solid ${border}`, borderRadius: 10, padding: "9px 20px", fontSize: 13, cursor: "pointer" }}>Close</button>
            </div>
          </div>
        </div>
      )}

      {/* Cross-promo */}
      <div style={card({ background: dark ? "rgba(139,123,173,0.1)" : "rgba(139,123,173,0.06)", borderColor: "rgba(139,123,173,0.25)", marginTop: 4 })}>
        <div style={{ fontSize: 12, color: "#8B7BAD", fontWeight: 700, marginBottom: 4 }}>DISCOVER PATTERNS</div>
        <div style={{ fontSize: 13, color: textSub, marginBottom: 10 }}>Find lessons in Resonance Learn that match your recurring themes.</div>
        <button style={{ background: "rgba(139,123,173,0.2)", border: "1px solid rgba(139,123,173,0.3)", borderRadius: 10, padding: "8px 16px", color: "#8B7BAD", fontWeight: 700, fontSize: 12, cursor: "pointer", width: "100%" }}>📚 Browse Related Lessons</button>
      </div>
      <div style={{ height: 20 }} />
    </div>
  );

  const screens = { home: HomeScreen, workbook: WorkbookScreen, write: WriteScreen, mood: MoodScreen, reflections: ReflectionsScreen };
  const ActiveScreen = screens[tab];

  return (
    <>
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;1,400;1,600&family=Manrope:wght@400;600;700&display=swap" rel="stylesheet" />
      <div style={shell}>
        {/* Blobs */}
        <div style={blob("-60px", "-80px", C.deep, 360)} />
        <div style={blob("30%", "60%", C.gold, 280)} />
        <div style={blob("65%", "-40px", "#5B9BB5", 260)} />

        {/* Scroll area */}
        <div style={{ flex: 1, overflowY: "auto", position: "relative", zIndex: 1 }}>
          <ActiveScreen />
        </div>

        {/* Bottom Nav */}
        <div style={{ ...glass({ borderRadius: "20px 20px 0 0", padding: "10px 8px 14px", position: "relative", zIndex: 10 }), display: "flex", justifyContent: "space-around" }}>
          {tabs.map(t => (
            <button key={t.id} onClick={() => setTab(t.id)} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, background: "none", border: "none", cursor: "pointer", padding: "4px 10px", borderRadius: 12, transition: "background 0.2s" }}>
              <t.icon size={20} color={tab === t.id ? C.gold : textSub} strokeWidth={tab === t.id ? 2.2 : 1.6} />
              <span style={{ fontSize: 10, color: tab === t.id ? C.gold : textSub, fontWeight: tab === t.id ? 700 : 400 }}>{t.label}</span>
            </button>
          ))}
        </div>
      </div>
    </>
  );
}
