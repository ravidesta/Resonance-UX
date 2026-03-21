import { BookOpen, Wind, BarChart2, Star, Trophy, Play, Share2, Clock, Flame, Brain, Heart } from "lucide-react";

const C = {
  bg: "#0A1C14", bg2: "#122E21", accent: "#D1E0D7",
  gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
  text: "#FAFAF8", muted: "rgba(250,250,248,0.55)",
};
const S = {
  sans: "'Manrope', sans-serif",
  serif: "'Cormorant Garamond', serif",
};

const quote = { text: "The cave you fear to enter holds the treasure you seek.", author: "Joseph Campbell" };
const weekData = [65, 80, 45, 90, 70, 55, 88];
const days = ["M", "T", "W", "T", "F", "S", "S"];

function WidgetFrame({ w, h, children, label }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 8 }}>
      <div style={{
        width: w, height: h, borderRadius: 22,
        background: `linear-gradient(145deg, ${C.bg2}, ${C.bg})`,
        boxShadow: "0 8px 32px rgba(0,0,0,0.55), 0 2px 8px rgba(197,160,89,0.08), inset 0 1px 0 rgba(250,250,248,0.06)",
        overflow: "hidden", position: "relative", flexShrink: 0,
      }}>{children}</div>
      {label && <span style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, letterSpacing: "0.04em" }}>{label}</span>}
    </div>
  );
}

function SmallQuote() {
  return (
    <WidgetFrame w={155} h={155} label="Small · Daily Quote">
      <div style={{
        width: "100%", height: "100%", padding: "16px 14px",
        background: `linear-gradient(160deg, ${C.bg2} 0%, #0D2419 60%, ${C.bg} 100%)`,
        display: "flex", flexDirection: "column", justifyContent: "space-between",
      }}>
        <BookOpen size={16} color={C.gold} strokeWidth={1.5} />
        <div>
          <p style={{ fontFamily: S.serif, fontSize: 13.5, color: C.cream, lineHeight: 1.45, margin: "0 0 8px", fontStyle: "italic" }}>
            "{quote.text.slice(0, 60)}…"
          </p>
          <p style={{ fontFamily: S.sans, fontSize: 10, color: C.gold, margin: 0, letterSpacing: "0.06em", textTransform: "uppercase" }}>
            {quote.author}
          </p>
        </div>
        <div style={{ width: 28, height: 2, background: `linear-gradient(90deg, ${C.gold}, transparent)`, borderRadius: 1 }} />
      </div>
    </WidgetFrame>
  );
}

function SmallBreathing() {
  return (
    <WidgetFrame w={155} h={155} label="Small · Breathing">
      <div style={{
        width: "100%", height: "100%", display: "flex", flexDirection: "column",
        alignItems: "center", justifyContent: "center", gap: 10,
        background: `radial-gradient(circle at 50% 60%, #1A3D28 0%, ${C.bg} 70%)`,
      }}>
        <div style={{ position: "relative", width: 72, height: 72, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <div style={{
            position: "absolute", width: 72, height: 72, borderRadius: "50%",
            background: "rgba(209,224,215,0.08)", border: "1px solid rgba(209,224,215,0.15)",
            animation: "pulse 4s ease-in-out infinite",
          }} />
          <div style={{
            position: "absolute", width: 52, height: 52, borderRadius: "50%",
            background: "rgba(197,160,89,0.12)", border: "1px solid rgba(197,160,89,0.25)",
            animation: "pulse 4s ease-in-out infinite 0.5s",
          }} />
          <Wind size={22} color={C.goldLight} strokeWidth={1.5} />
        </div>
        <div style={{ textAlign: "center" }}>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: "0 0 2px", letterSpacing: "0.05em" }}>BREATHE IN</p>
          <p style={{ fontFamily: S.serif, fontSize: 15, color: C.cream, margin: 0 }}>4 · 7 · 8</p>
        </div>
      </div>
    </WidgetFrame>
  );
}

function MediumJourney() {
  const stats = [
    { icon: <Wind size={14} color={C.gold} strokeWidth={1.5} />, val: "18", label: "min med." },
    { icon: <Flame size={14} color={C.gold} strokeWidth={1.5} />, val: "12", label: "day streak" },
    { icon: <Brain size={14} color={C.gold} strokeWidth={1.5} />, val: "67%", label: "course" },
    { icon: <Heart size={14} color={C.gold} strokeWidth={1.5} />, val: "3", label: "sessions" },
  ];
  return (
    <WidgetFrame w={329} h={155} label="Medium · Today's Journey">
      <div style={{ width: "100%", height: "100%", padding: "16px 20px", display: "flex", flexDirection: "column", justifyContent: "space-between" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: S.serif, fontSize: 17, color: C.cream, fontStyle: "italic" }}>Today's Journey</span>
          <span style={{ fontFamily: S.sans, fontSize: 10, color: C.gold, letterSpacing: "0.06em" }}>SAT, MAR 21</span>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 10 }}>
          {stats.map((s, i) => (
            <div key={i} style={{
              background: "rgba(255,255,255,0.04)", borderRadius: 12, padding: "10px 8px",
              display: "flex", flexDirection: "column", alignItems: "center", gap: 5,
              border: "1px solid rgba(209,224,215,0.08)",
            }}>
              {s.icon}
              <span style={{ fontFamily: S.sans, fontSize: 17, fontWeight: 700, color: C.cream }}>{s.val}</span>
              <span style={{ fontFamily: S.sans, fontSize: 9.5, color: C.muted, textAlign: "center", letterSpacing: "0.03em" }}>{s.label}</span>
            </div>
          ))}
        </div>
      </div>
    </WidgetFrame>
  );
}

function MediumWisdom() {
  return (
    <WidgetFrame w={329} h={155} label="Medium · Daily Wisdom">
      <div style={{
        width: "100%", height: "100%", padding: "18px 20px",
        background: `linear-gradient(135deg, ${C.bg2} 0%, #0E2218 100%)`,
        display: "flex", flexDirection: "column", justifyContent: "space-between",
      }}>
        <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
          <div style={{ width: 3, height: 52, background: `linear-gradient(180deg, ${C.gold}, transparent)`, borderRadius: 2, flexShrink: 0, marginTop: 2 }} />
          <p style={{ fontFamily: S.serif, fontSize: 16, color: C.cream, lineHeight: 1.5, margin: 0, fontStyle: "italic", flex: 1 }}>
            "{quote.text}"
          </p>
        </div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <span style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, letterSpacing: "0.06em" }}>— {quote.author}</span>
          <div style={{
            width: 30, height: 30, borderRadius: "50%", background: "rgba(197,160,89,0.12)",
            border: `1px solid rgba(197,160,89,0.3)`, display: "flex", alignItems: "center", justifyContent: "center",
          }}>
            <Share2 size={14} color={C.gold} strokeWidth={1.5} />
          </div>
        </div>
      </div>
    </WidgetFrame>
  );
}

function LargeWeekly() {
  const maxVal = Math.max(...weekData);
  return (
    <WidgetFrame w={329} h={345} label="Large · Weekly Overview">
      <div style={{ width: "100%", height: "100%", padding: "20px", display: "flex", flexDirection: "column", gap: 16 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
          <div>
            <p style={{ fontFamily: S.serif, fontSize: 20, color: C.cream, margin: "0 0 2px", fontStyle: "italic" }}>Weekly Overview</p>
            <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: 0 }}>Mar 15 – 21</p>
          </div>
          <div style={{ textAlign: "right" }}>
            <p style={{ fontFamily: S.sans, fontSize: 22, fontWeight: 700, color: C.cream, margin: 0 }}>47</p>
            <p style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, margin: 0 }}>entries</p>
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "flex-end", gap: 6, height: 110, padding: "0 4px" }}>
          {weekData.map((v, i) => (
            <div key={i} style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 5, height: "100%", justifyContent: "flex-end" }}>
              <div style={{
                width: "100%", borderRadius: "5px 5px 3px 3px",
                height: `${(v / maxVal) * 90}%`,
                background: i === 6
                  ? `linear-gradient(180deg, ${C.gold}, ${C.goldLight})`
                  : `linear-gradient(180deg, rgba(209,224,215,0.5), rgba(209,224,215,0.2))`,
                transition: "height 0.3s ease",
              }} />
              <span style={{ fontFamily: S.sans, fontSize: 9.5, color: i === 6 ? C.gold : C.muted }}>{days[i]}</span>
            </div>
          ))}
        </div>
        <div style={{ borderTop: "1px solid rgba(209,224,215,0.1)", paddingTop: 14 }}>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, margin: "0 0 10px", letterSpacing: "0.06em" }}>ACHIEVEMENTS</p>
          <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
            {[
              { label: "7-Day Streak", done: true },
              { label: "Deep Work Master", done: true },
              { label: "Reflection Scholar", done: false },
            ].map((a, i) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                <Trophy size={13} color={a.done ? C.gold : C.muted} strokeWidth={1.5} />
                <span style={{ fontFamily: S.sans, fontSize: 12, color: a.done ? C.cream : C.muted }}>{a.label}</span>
                {a.done && <div style={{ marginLeft: "auto", width: 6, height: 6, borderRadius: "50%", background: C.gold }} />}
              </div>
            ))}
          </div>
        </div>
      </div>
    </WidgetFrame>
  );
}

function LargeLearning() {
  const pct = 67;
  const r = 42, circ = 2 * Math.PI * r;
  return (
    <WidgetFrame w={329} h={345} label="Large · Learning Progress">
      <div style={{ width: "100%", height: "100%", padding: "20px", display: "flex", flexDirection: "column", gap: 16 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <p style={{ fontFamily: S.serif, fontSize: 20, color: C.cream, margin: 0, fontStyle: "italic" }}>Learning</p>
          <Star size={16} color={C.gold} strokeWidth={1.5} />
        </div>
        <div style={{ display: "flex", gap: 16, alignItems: "center", background: "rgba(255,255,255,0.04)", borderRadius: 16, padding: "16px", border: "1px solid rgba(209,224,215,0.08)" }}>
          <div style={{ position: "relative", width: 96, height: 96, flexShrink: 0 }}>
            <svg width={96} height={96} style={{ transform: "rotate(-90deg)" }}>
              <circle cx={48} cy={48} r={r} fill="none" stroke="rgba(209,224,215,0.1)" strokeWidth={7} />
              <circle cx={48} cy={48} r={r} fill="none" stroke={C.gold} strokeWidth={7}
                strokeDasharray={circ} strokeDashoffset={circ * (1 - pct / 100)}
                strokeLinecap="round" />
            </svg>
            <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
              <span style={{ fontFamily: S.sans, fontSize: 20, fontWeight: 700, color: C.cream }}>{pct}%</span>
              <span style={{ fontFamily: S.sans, fontSize: 9, color: C.muted }}>done</span>
            </div>
          </div>
          <div style={{ flex: 1 }}>
            <p style={{ fontFamily: S.sans, fontSize: 10, color: C.gold, margin: "0 0 5px", letterSpacing: "0.06em" }}>CURRENT COURSE</p>
            <p style={{ fontFamily: S.serif, fontSize: 15, color: C.cream, margin: "0 0 6px", lineHeight: 1.3 }}>Shadow Work & Integration</p>
            <p style={{ fontFamily: S.sans, fontSize: 10.5, color: C.muted, margin: 0 }}>Module 4 of 6</p>
          </div>
        </div>
        <div>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, margin: "0 0 10px", letterSpacing: "0.06em" }}>NEXT LESSON</p>
          <div style={{ display: "flex", alignItems: "center", gap: 12, background: "rgba(197,160,89,0.08)", borderRadius: 14, padding: "12px 14px", border: `1px solid rgba(197,160,89,0.18)` }}>
            <div style={{ width: 36, height: 36, borderRadius: "50%", background: `rgba(197,160,89,0.15)`, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Play size={15} color={C.gold} strokeWidth={1.5} style={{ marginLeft: 2 }} />
            </div>
            <div>
              <p style={{ fontFamily: S.sans, fontSize: 12.5, color: C.cream, margin: "0 0 2px", fontWeight: 600 }}>Meeting Your Inner Critic</p>
              <p style={{ fontFamily: S.sans, fontSize: 10.5, color: C.muted, margin: 0 }}>24 min · Video + Exercise</p>
            </div>
          </div>
        </div>
        <div style={{ display: "flex", gap: 8, marginTop: "auto" }}>
          {[{ label: "Lessons", val: "18/27" }, { label: "Exercises", val: "12" }, { label: "Hrs", val: "6.4" }].map((s, i) => (
            <div key={i} style={{ flex: 1, textAlign: "center", background: "rgba(255,255,255,0.03)", borderRadius: 10, padding: "8px 4px", border: "1px solid rgba(209,224,215,0.07)" }}>
              <p style={{ fontFamily: S.sans, fontSize: 14, fontWeight: 700, color: C.cream, margin: "0 0 2px" }}>{s.val}</p>
              <p style={{ fontFamily: S.sans, fontSize: 9.5, color: C.muted, margin: 0 }}>{s.label}</p>
            </div>
          ))}
        </div>
      </div>
    </WidgetFrame>
  );
}

function LockScreen() {
  const items = [
    { icon: <Wind size={14} color={C.goldLight} strokeWidth={1.5} />, label: "Breathe" },
    { icon: <Flame size={14} color={C.goldLight} strokeWidth={1.5} />, label: "12d" },
    { icon: <BookOpen size={14} color={C.goldLight} strokeWidth={1.5} />, label: "Quote" },
  ];
  return (
    <WidgetFrame w={329} h={64} label="Lock Screen · Circular Widgets">
      <div style={{ width: "100%", height: "100%", display: "flex", alignItems: "center", justifyContent: "center", gap: 24, background: "rgba(10,28,20,0.9)" }}>
        {items.map((it, i) => (
          <div key={i} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 5 }}>
            <div style={{ width: 36, height: 36, borderRadius: "50%", background: "rgba(197,160,89,0.15)", border: `1.5px solid rgba(197,160,89,0.35)`, display: "flex", alignItems: "center", justifyContent: "center" }}>
              {it.icon}
            </div>
            <span style={{ fontFamily: S.sans, fontSize: 9.5, color: C.muted, letterSpacing: "0.04em" }}>{it.label}</span>
          </div>
        ))}
        <div style={{ position: "absolute", right: 20, top: "50%", transform: "translateY(-50%)" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 6, background: "rgba(197,160,89,0.1)", borderRadius: 20, padding: "4px 12px", border: "1px solid rgba(197,160,89,0.2)" }}>
            <BarChart2 size={11} color={C.gold} strokeWidth={1.5} />
            <span style={{ fontFamily: S.sans, fontSize: 10, color: C.goldLight }}>67% complete</span>
          </div>
        </div>
      </div>
    </WidgetFrame>
  );
}

function StandBy() {
  return (
    <WidgetFrame w={329} h={345} label="StandBy Mode">
      <div style={{
        width: "100%", height: "100%", padding: "28px 24px",
        background: `radial-gradient(ellipse at 50% 30%, #1E4030 0%, ${C.bg} 65%)`,
        display: "flex", flexDirection: "column", justifyContent: "space-between", alignItems: "center",
      }}>
        <div style={{ textAlign: "center" }}>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, margin: "0 0 6px", letterSpacing: "0.1em" }}>LUMINOUS · RESONANCE</p>
          <div style={{ width: 36, height: 1, background: `linear-gradient(90deg, transparent, ${C.gold}, transparent)`, margin: "0 auto" }} />
        </div>
        <div style={{ textAlign: "center" }}>
          <div style={{ display: "flex", alignItems: "baseline", justifyContent: "center", gap: 6 }}>
            <Clock size={20} color={C.gold} strokeWidth={1} />
            <span style={{ fontFamily: S.sans, fontSize: 64, fontWeight: 200, color: C.cream, letterSpacing: "-2px", lineHeight: 1 }}>9:41</span>
          </div>
          <p style={{ fontFamily: S.sans, fontSize: 13, color: C.muted, margin: "6px 0 0" }}>Saturday, March 21</p>
        </div>
        <div style={{ textAlign: "center", maxWidth: 260 }}>
          <p style={{ fontFamily: S.serif, fontSize: 16.5, color: C.cream, lineHeight: 1.55, margin: "0 0 10px", fontStyle: "italic" }}>
            "{quote.text}"
          </p>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, margin: 0, letterSpacing: "0.06em" }}>— {quote.author}</p>
        </div>
        <div style={{ display: "flex", gap: 20 }}>
          {[{ icon: <Flame size={14} color={C.gold} strokeWidth={1.5} />, val: "12", label: "streak" },
            { icon: <Brain size={14} color={C.gold} strokeWidth={1.5} />, val: "67%", label: "progress" },
            { icon: <Wind size={14} color={C.gold} strokeWidth={1.5} />, val: "18m", label: "today" }].map((s, i) => (
            <div key={i} style={{ textAlign: "center" }}>
              <div style={{ display: "flex", justifyContent: "center", marginBottom: 3 }}>{s.icon}</div>
              <p style={{ fontFamily: S.sans, fontSize: 15, fontWeight: 700, color: C.cream, margin: "0 0 1px" }}>{s.val}</p>
              <p style={{ fontFamily: S.sans, fontSize: 9.5, color: C.muted, margin: 0 }}>{s.label}</p>
            </div>
          ))}
        </div>
      </div>
    </WidgetFrame>
  );
}

export default function ResonanceWidgets() {
  return (
    <div style={{ minHeight: "100vh", background: "#080F0A", padding: "48px 32px", fontFamily: S.sans }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Manrope:wght@300;400;500;600;700&family=Cormorant+Garamond:ital,wght@0,400;0,500;1,400;1,500&display=swap');
        @keyframes pulse { 0%,100%{transform:scale(1);opacity:0.7} 50%{transform:scale(1.18);opacity:1} }
        * { box-sizing: border-box; }
      `}</style>

      <div style={{ maxWidth: 760, margin: "0 auto" }}>
        <div style={{ marginBottom: 48, textAlign: "center" }}>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, letterSpacing: "0.12em", margin: "0 0 8px" }}>LUMINOUS · RESONANCE</p>
          <h1 style={{ fontFamily: S.serif, fontSize: 38, color: C.cream, margin: "0 0 8px", fontWeight: 400, fontStyle: "italic" }}>Widget Showcase</h1>
          <p style={{ fontFamily: S.sans, fontSize: 13, color: C.muted, margin: 0 }}>iOS Home Screen, Lock Screen & StandBy</p>
        </div>

        <div style={{ marginBottom: 36 }}>
          <p style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, letterSpacing: "0.1em", marginBottom: 20 }}>SMALL WIDGETS · 155×155</p>
          <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
            <SmallQuote />
            <SmallBreathing />
          </div>
        </div>

        <div style={{ marginBottom: 36 }}>
          <p style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, letterSpacing: "0.1em", marginBottom: 20 }}>MEDIUM WIDGETS · 329×155</p>
          <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
            <MediumJourney />
            <MediumWisdom />
          </div>
        </div>

        <div style={{ marginBottom: 36 }}>
          <p style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, letterSpacing: "0.1em", marginBottom: 20 }}>LARGE WIDGETS · 329×345</p>
          <div style={{ display: "flex", gap: 20, flexWrap: "wrap" }}>
            <LargeWeekly />
            <LargeLearning />
          </div>
        </div>

        <div style={{ marginBottom: 36 }}>
          <p style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, letterSpacing: "0.1em", marginBottom: 20 }}>LOCK SCREEN WIDGETS</p>
          <LockScreen />
        </div>

        <div>
          <p style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, letterSpacing: "0.1em", marginBottom: 20 }}>STANDBY MODE</p>
          <StandBy />
        </div>
      </div>
    </div>
  );
}
