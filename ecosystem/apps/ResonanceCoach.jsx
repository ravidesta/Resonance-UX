import { useState, useEffect } from "react";
import { Home, MessageCircle, Mic, BookOpen, BarChart2, Send, Sparkles, Sun, Moon, ChevronRight, Star, Zap, Heart, Compass, Sunrise, Sunset } from "lucide-react";

const C = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", forest: "#1B402E",
  mist: "#D1E0D7", gold: "#C5A059", cream: "#E6D0A1", white: "#FAFAF8",
  goldLight: "rgba(197,160,89,0.15)", greenGlass: "rgba(18,46,33,0.55)",
  goldGlass: "rgba(197,160,89,0.18)", glassStroke: "rgba(209,224,215,0.18)",
};

const fonts = {
  head: "'Cormorant Garamond', Georgia, serif",
  body: "'Manrope', system-ui, sans-serif",
};

const glass = (bg = C.greenGlass, border = C.glassStroke) => ({
  background: bg, border: `1px solid ${border}`,
  backdropFilter: "blur(16px)", WebkitBackdropFilter: "blur(16px)",
  borderRadius: 16,
});

const blob = (top, left, size, color, opacity = 0.18) => ({
  position: "absolute", top, left, width: size, height: size,
  borderRadius: "50%", background: color, opacity,
  filter: `blur(${size * 0.45}px)`, pointerEvents: "none", zIndex: 0,
});

const CHAT = [
  { role: "coach", text: "Welcome back. What's feeling alive in you today — what's working well that you'd like to build on?" },
  { role: "user", text: "Honestly, I had a really strong conversation with my team this morning. I felt genuinely connected." },
  { role: "coach", text: "That connection you felt — what do you think you brought to that conversation that made it possible?" },
  { role: "user", text: "I think I was really present. I wasn't thinking about my agenda, just listening deeply." },
  { role: "coach", text: "Deep presence — that's a profound strength. When you're at your best as a leader, how often does that quality show up?" },
  { role: "user", text: "More than I give myself credit for, actually. I tend to focus on where I fall short." },
];

const SESSIONS = [
  { title: "Morning Intention", icon: Sunrise, duration: "8 min", desc: "Set a soul-aligned intention to anchor your day with purpose and clarity." },
  { title: "Evening Reflection", icon: Sunset, duration: "10 min", desc: "Harvest the wisdom from your day. What gifts did today offer?" },
  { title: "Strength Discovery", icon: Star, duration: "15 min", desc: "Uncover and name your core strengths through appreciative inquiry." },
  { title: "Values Exploration", icon: Compass, duration: "20 min", desc: "Reconnect with what matters most and how your values guide your growth." },
  { title: "Growth Edge Inquiry", icon: Zap, duration: "12 min", desc: "Explore your edge with curiosity rather than judgment. What wants to emerge?" },
  { title: "Appreciative Check-in", icon: Heart, duration: "5 min", desc: "A gentle, grounding pause to appreciate your journey so far." },
];

const QUESTIONS = [
  "What does ego development mean?", "How do I move to the next stage?",
  "What is the Strategist stage?", "How does shadow work relate?",
  "What strengths am I building?", "How do I develop more presence?",
  "What is vertical development?", "How can I lead from my values?",
];

const THEMES = [
  { label: "Presence", size: 22, weight: 700 }, { label: "Leadership", size: 18, weight: 600 },
  { label: "Strengths", size: 20, weight: 700 }, { label: "Values", size: 16, weight: 500 },
  { label: "Listening", size: 17, weight: 600 }, { label: "Connection", size: 19, weight: 600 },
  { label: "Growth Edge", size: 15, weight: 500 }, { label: "Authenticity", size: 21, weight: 700 },
  { label: "Curiosity", size: 16, weight: 500 }, { label: "Shadow Work", size: 14, weight: 400 },
  { label: "Integration", size: 18, weight: 600 }, { label: "Purpose", size: 17, weight: 600 },
];

const STRENGTHS = ["Deep Presence", "Empathic Listening", "Authentic Expression", "Reflective Inquiry", "Values Alignment"];

export default function ResonanceCoach() {
  const [tab, setTab] = useState("home");
  const [dark, setDark] = useState(true);
  const [msg, setMsg] = useState("");
  const [askQ, setAskQ] = useState("");
  const [answered, setAnswered] = useState(false);
  const [listening, setListening] = useState(false);
  const [breathPhase, setBreathPhase] = useState("inhale");

  useEffect(() => {
    if (tab !== "voice") return;
    const phases = ["inhale", "hold", "exhale", "rest"];
    let i = 0;
    const iv = setInterval(() => { i = (i + 1) % 4; setBreathPhase(phases[i]); }, 2200);
    return () => clearInterval(iv);
  }, [tab]);

  const bg = dark ? C.night : "#EEF4F0";
  const fg = dark ? C.white : C.dark;
  const subFg = dark ? C.mist : "#4a6b57";

  const Page = ({ children, style }) => (
    <div style={{ flex: 1, overflowY: "auto", padding: "0 0 80px", position: "relative", ...style }}>
      {children}
    </div>
  );

  const Section = ({ children, style }) => (
    <div style={{ padding: "0 20px", position: "relative", zIndex: 1, ...style }}>{children}</div>
  );

  // ── HOME ──────────────────────────────────────────────────────────────────
  const HomeScreen = () => (
    <Page>
      <div style={{ ...blob(40, -60, 220, C.forest, 0.7) }} />
      <div style={{ ...blob(180, 200, 160, C.gold, 0.12) }} />
      <Section style={{ paddingTop: 56 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 32 }}>
          <div>
            <p style={{ fontFamily: fonts.body, fontSize: 13, color: C.gold, letterSpacing: 2, textTransform: "uppercase", margin: 0 }}>Resonance Coach</p>
            <h1 style={{ fontFamily: fonts.head, fontSize: 34, color: fg, margin: "4px 0 0", fontWeight: 600 }}>Your Appreciative<br />Coach</h1>
          </div>
          <button onClick={() => setDark(d => !d)} style={{ background: C.greenGlass, border: `1px solid ${C.glassStroke}`, borderRadius: 50, width: 44, height: 44, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}>
            {dark ? <Sun size={18} color={C.gold} /> : <Moon size={18} color={C.forest} />}
          </button>
        </div>

        {/* Intention Card */}
        <div style={{ ...glass(C.greenGlass), padding: "22px 24px", marginBottom: 20 }}>
          <p style={{ fontFamily: fonts.body, fontSize: 11, color: C.gold, letterSpacing: 2, textTransform: "uppercase", margin: "0 0 10px" }}>Today's Intention</p>
          <p style={{ fontFamily: fonts.head, fontSize: 22, color: fg, margin: "0 0 14px", lineHeight: 1.4, fontStyle: "italic" }}>"What strength can I lean into fully today?"</p>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <Sparkles size={14} color={C.gold} />
            <span style={{ fontFamily: fonts.body, fontSize: 12, color: subFg }}>Tap to reflect on this intention</span>
          </div>
        </div>

        {/* Streak */}
        <div style={{ ...glass("rgba(197,160,89,0.1)", "rgba(197,160,89,0.25)"), padding: "16px 20px", marginBottom: 28, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: "rgba(197,160,89,0.2)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Zap size={20} color={C.gold} />
            </div>
            <div>
              <p style={{ fontFamily: fonts.body, fontWeight: 700, fontSize: 20, color: C.gold, margin: 0 }}>14 Day Streak</p>
              <p style={{ fontFamily: fonts.body, fontSize: 12, color: subFg, margin: 0 }}>Your longest yet — keep going</p>
            </div>
          </div>
          <ChevronRight size={16} color={subFg} />
        </div>

        <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, letterSpacing: 1, textTransform: "uppercase", marginBottom: 14 }}>Start a Session</p>
        {[{ label: "Chat with Coach", sub: "Appreciative conversation", action: () => setTab("chat"), color: C.greenGlass },
          { label: "Voice Session", sub: "Speak & be heard", action: () => setTab("voice"), color: "rgba(27,64,46,0.5)" },
          { label: "Guided Journey", sub: "Structured exploration", action: () => setTab("sessions"), color: C.goldGlass }
        ].map(b => (
          <button key={b.label} onClick={b.action} style={{ ...glass(b.color), display: "flex", alignItems: "center", justifyContent: "space-between", padding: "18px 20px", width: "100%", marginBottom: 12, cursor: "pointer", textAlign: "left", boxSizing: "border-box" }}>
            <div>
              <p style={{ fontFamily: fonts.body, fontWeight: 600, fontSize: 16, color: fg, margin: 0 }}>{b.label}</p>
              <p style={{ fontFamily: fonts.body, fontSize: 12, color: subFg, margin: "3px 0 0" }}>{b.sub}</p>
            </div>
            <ChevronRight size={16} color={subFg} />
          </button>
        ))}

        <div style={{ ...glass("rgba(197,160,89,0.08)", "rgba(197,160,89,0.2)"), padding: "14px 18px", marginTop: 8, display: "flex", alignItems: "center", gap: 10 }}>
          <BookOpen size={16} color={C.gold} />
          <span style={{ fontFamily: fonts.body, fontSize: 13, color: subFg }}>Explore deeper in <span style={{ color: C.gold, fontWeight: 600 }}>Resonance Learn</span></span>
        </div>
      </Section>
    </Page>
  );

  // ── CHAT ──────────────────────────────────────────────────────────────────
  const ChatScreen = () => (
    <Page>
      <div style={{ ...blob(-20, -40, 180, C.forest, 0.5) }} />
      <Section style={{ paddingTop: 52 }}>
        <h2 style={{ fontFamily: fonts.head, fontSize: 28, color: fg, margin: "0 0 6px" }}>Coaching Chat</h2>
        <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, margin: "0 0 24px" }}>Appreciative inquiry in conversation</p>
        <div style={{ display: "flex", flexDirection: "column", gap: 14, marginBottom: 20 }}>
          {CHAT.map((m, i) => (
            <div key={i} style={{ display: "flex", justifyContent: m.role === "user" ? "flex-end" : "flex-start" }}>
              <div style={{ ...glass(m.role === "coach" ? C.greenGlass : C.goldGlass, m.role === "coach" ? C.glassStroke : "rgba(197,160,89,0.3)"), padding: "14px 16px", maxWidth: "82%", borderRadius: m.role === "coach" ? "4px 16px 16px 16px" : "16px 4px 16px 16px" }}>
                {m.role === "coach" && <p style={{ fontFamily: fonts.body, fontSize: 10, color: C.gold, letterSpacing: 1.5, textTransform: "uppercase", margin: "0 0 6px" }}>Coach</p>}
                <p style={{ fontFamily: fonts.body, fontSize: 14, color: fg, margin: 0, lineHeight: 1.6 }}>{m.text}</p>
              </div>
            </div>
          ))}
        </div>

        <p style={{ fontFamily: fonts.body, fontSize: 12, color: subFg, margin: "0 0 10px" }}>Suggested questions</p>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 16 }}>
          {["What am I most proud of?", "Where do I feel most alive?", "What wants to emerge?"].map(q => (
            <button key={q} onClick={() => setMsg(q)} style={{ background: "rgba(197,160,89,0.12)", border: "1px solid rgba(197,160,89,0.3)", borderRadius: 20, padding: "7px 14px", fontFamily: fonts.body, fontSize: 12, color: C.gold, cursor: "pointer" }}>{q}</button>
          ))}
        </div>

        <div style={{ display: "flex", gap: 10, alignItems: "flex-end" }}>
          <input value={msg} onChange={e => setMsg(e.target.value)} placeholder="Share what's on your mind…" style={{ flex: 1, ...glass(C.greenGlass), padding: "14px 16px", fontFamily: fonts.body, fontSize: 14, color: fg, border: `1px solid ${C.glassStroke}`, outline: "none", borderRadius: 16 }} />
          <button style={{ width: 48, height: 48, borderRadius: 14, background: C.gold, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", flexShrink: 0 }}>
            <Send size={18} color={C.night} />
          </button>
        </div>

        <div style={{ ...glass("rgba(197,160,89,0.08)", "rgba(197,160,89,0.2)"), padding: "12px 16px", marginTop: 16, display: "flex", alignItems: "center", gap: 10 }}>
          <Heart size={14} color={C.gold} />
          <span style={{ fontFamily: fonts.body, fontSize: 12, color: subFg }}>Journal about this in <span style={{ color: C.gold, fontWeight: 600 }}>Resonance Journal</span></span>
        </div>
      </Section>
    </Page>
  );

  // ── VOICE ─────────────────────────────────────────────────────────────────
  const VoiceScreen = () => {
    const phaseLabel = { inhale: "Breathe In", hold: "Hold", exhale: "Breathe Out", rest: "Rest" }[breathPhase];
    const circleSize = { inhale: 200, hold: 200, exhale: 160, rest: 160 }[breathPhase];
    return (
      <Page style={{ display: "flex", flexDirection: "column" }}>
        <div style={{ ...blob(60, -80, 300, C.forest, 0.6) }} />
        <div style={{ ...blob(300, 180, 200, C.gold, 0.08) }} />
        <Section style={{ paddingTop: 52, flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center" }}>
          <h2 style={{ fontFamily: fonts.head, fontSize: 30, color: fg, margin: "0 0 6px" }}>Voice Session</h2>
          <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, margin: "0 0 48px" }}>Speak freely — your coach listens deeply</p>

          {/* Breathing circle */}
          <div style={{ position: "relative", width: 240, height: 240, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 32 }}>
            <div style={{ position: "absolute", width: circleSize, height: circleSize, borderRadius: "50%", background: "radial-gradient(circle, rgba(27,64,46,0.8) 0%, rgba(18,46,33,0.4) 100%)", border: `1px solid ${C.glassStroke}`, transition: "all 1.8s cubic-bezier(0.4,0,0.2,1)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <p style={{ fontFamily: fonts.head, fontSize: 18, color: C.mist, margin: 0, fontStyle: "italic" }}>{phaseLabel}</p>
            </div>
            {[220, 240].map((s, i) => (
              <div key={i} style={{ position: "absolute", width: s, height: s, borderRadius: "50%", border: `1px solid rgba(209,224,215,${0.1 - i * 0.04})`, animation: `pulse ${2 + i}s ease-in-out infinite`, pointerEvents: "none" }} />
            ))}
          </div>

          <button onClick={() => setListening(l => !l)} style={{ width: 80, height: 80, borderRadius: "50%", background: listening ? "rgba(197,160,89,0.9)" : C.greenGlass, border: `2px solid ${listening ? C.gold : C.glassStroke}`, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", marginBottom: 16, transition: "all 0.3s", position: "relative" }}>
            <Mic size={28} color={listening ? C.night : C.mist} />
            {listening && [1, 2, 3].map(r => (
              <div key={r} style={{ position: "absolute", width: 80 + r * 24, height: 80 + r * 24, borderRadius: "50%", border: `1px solid rgba(197,160,89,${0.4 - r * 0.1})`, animation: `ripple ${1 + r * 0.3}s ease-out infinite`, pointerEvents: "none" }} />
            ))}
          </button>

          <p style={{ fontFamily: fonts.body, fontSize: 14, color: listening ? C.gold : subFg, margin: "0 0 32px", transition: "color 0.3s" }}>
            {listening ? "Coach is listening…" : "Tap to begin speaking"}
          </p>

          {/* Waveform */}
          <div style={{ display: "flex", alignItems: "center", gap: 4, height: 40, marginBottom: 40 }}>
            {Array.from({ length: 20 }).map((_, i) => (
              <div key={i} style={{ width: 4, borderRadius: 2, background: C.gold, opacity: listening ? 0.7 : 0.2, height: listening ? `${20 + Math.sin(i * 0.8) * 16}px` : "8px", transition: "all 0.4s ease", animationDelay: `${i * 0.05}s` }} />
            ))}
          </div>
        </Section>
        <style>{`@keyframes pulse{0%,100%{transform:scale(1);opacity:0.6}50%{transform:scale(1.06);opacity:0.3}} @keyframes ripple{0%{transform:scale(1);opacity:0.6}100%{transform:scale(1.5);opacity:0}}`}</style>
      </Page>
    );
  };

  // ── SESSIONS ──────────────────────────────────────────────────────────────
  const SessionsScreen = () => (
    <Page>
      <div style={{ ...blob(0, 200, 200, C.forest, 0.45) }} />
      <Section style={{ paddingTop: 52 }}>
        <h2 style={{ fontFamily: fonts.head, fontSize: 28, color: fg, margin: "0 0 6px" }}>Guided Sessions</h2>
        <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, margin: "0 0 24px" }}>Structured journeys for deeper growth</p>
        {SESSIONS.map(s => (
          <div key={s.title} style={{ ...glass(C.greenGlass), padding: "18px 20px", marginBottom: 14, cursor: "pointer", display: "flex", gap: 16, alignItems: "flex-start" }}>
            <div style={{ width: 44, height: 44, borderRadius: 12, background: "rgba(197,160,89,0.15)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <s.icon size={20} color={C.gold} />
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 4 }}>
                <p style={{ fontFamily: fonts.body, fontWeight: 600, fontSize: 15, color: fg, margin: 0 }}>{s.title}</p>
                <span style={{ fontFamily: fonts.body, fontSize: 11, color: C.gold, background: "rgba(197,160,89,0.12)", padding: "3px 10px", borderRadius: 20 }}>{s.duration}</span>
              </div>
              <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, margin: 0, lineHeight: 1.5 }}>{s.desc}</p>
            </div>
          </div>
        ))}
      </Section>
    </Page>
  );

  // ── ASK ANYTHING ──────────────────────────────────────────────────────────
  const AskScreen = () => (
    <Page>
      <div style={{ ...blob(100, -60, 200, C.gold, 0.08) }} />
      <Section style={{ paddingTop: 52 }}>
        <h2 style={{ fontFamily: fonts.head, fontSize: 28, color: fg, margin: "0 0 6px" }}>Ask Anything</h2>
        <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, margin: "0 0 20px" }}>Explore ego development with your coach</p>
        <div style={{ display: "flex", gap: 10, marginBottom: 24 }}>
          <input value={askQ} onChange={e => setAskQ(e.target.value)} placeholder="Ask about ego development, growth, self-awareness…" style={{ flex: 1, ...glass(C.greenGlass), padding: "14px 16px", fontFamily: fonts.body, fontSize: 13, color: fg, border: `1px solid ${C.glassStroke}`, outline: "none", borderRadius: 16 }} />
          <button onClick={() => askQ && setAnswered(true)} style={{ width: 48, height: 48, borderRadius: 14, background: C.gold, border: "none", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", flexShrink: 0 }}>
            <Send size={18} color={C.night} />
          </button>
        </div>

        {answered ? (
          <div style={{ ...glass(C.greenGlass), padding: "20px 20px", marginBottom: 20 }}>
            <p style={{ fontFamily: fonts.body, fontSize: 11, color: C.gold, letterSpacing: 1.5, textTransform: "uppercase", margin: "0 0 10px" }}>Coach's Response</p>
            <p style={{ fontFamily: fonts.body, fontSize: 14, color: fg, lineHeight: 1.7, margin: "0 0 12px" }}>Ego development describes the journey through increasingly complex ways of making meaning of yourself and the world. At each stage, you develop greater capacity for nuance, self-reflection, and holding paradox. The path isn't linear — it's a spiral of expanding awareness.</p>
            <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, fontStyle: "italic" }}>What stage of this journey feels most alive for you right now?</p>
          </div>
        ) : (
          <>
            <p style={{ fontFamily: fonts.body, fontSize: 12, color: subFg, letterSpacing: 1, textTransform: "uppercase", marginBottom: 14 }}>Suggested Questions</p>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 10 }}>
              {QUESTIONS.map(q => (
                <button key={q} onClick={() => { setAskQ(q); setAnswered(true); }} style={{ background: C.greenGlass, border: `1px solid ${C.glassStroke}`, borderRadius: 24, padding: "9px 16px", fontFamily: fonts.body, fontSize: 13, color: fg, cursor: "pointer", backdropFilter: "blur(12px)" }}>{q}</button>
              ))}
            </div>
          </>
        )}

        <div style={{ ...glass("rgba(197,160,89,0.08)", "rgba(197,160,89,0.2)"), padding: "14px 18px", marginTop: 20, display: "flex", alignItems: "center", gap: 10 }}>
          <BookOpen size={16} color={C.gold} />
          <span style={{ fontFamily: fonts.body, fontSize: 13, color: subFg }}>Go deeper in <span style={{ color: C.gold, fontWeight: 600 }}>Resonance Learn</span></span>
        </div>
      </Section>
    </Page>
  );

  // ── INSIGHTS ──────────────────────────────────────────────────────────────
  const InsightsScreen = () => (
    <Page>
      <div style={{ ...blob(0, -50, 220, C.forest, 0.55) }} />
      <Section style={{ paddingTop: 52 }}>
        <h2 style={{ fontFamily: fonts.head, fontSize: 28, color: fg, margin: "0 0 6px" }}>Your Insights</h2>
        <p style={{ fontFamily: fonts.body, fontSize: 13, color: subFg, margin: "0 0 24px" }}>Patterns emerging from your coaching journey</p>

        <div style={{ display: "flex", gap: 12, marginBottom: 20 }}>
          {[{ n: "32", label: "Sessions" }, { n: "14", label: "Day Streak" }, { n: "8", label: "Themes" }].map(s => (
            <div key={s.label} style={{ ...glass(C.greenGlass), flex: 1, padding: "18px 14px", textAlign: "center" }}>
              <p style={{ fontFamily: fonts.head, fontSize: 32, color: C.gold, margin: 0, fontWeight: 700 }}>{s.n}</p>
              <p style={{ fontFamily: fonts.body, fontSize: 12, color: subFg, margin: "4px 0 0" }}>{s.label}</p>
            </div>
          ))}
        </div>

        <div style={{ ...glass(C.greenGlass), padding: "20px", marginBottom: 20 }}>
          <p style={{ fontFamily: fonts.body, fontSize: 11, color: C.gold, letterSpacing: 1.5, textTransform: "uppercase", margin: "0 0 16px" }}>Coaching Themes</p>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 10, alignItems: "center" }}>
            {THEMES.map(t => (
              <span key={t.label} style={{ fontFamily: fonts.head, fontSize: t.size, fontWeight: t.weight, color: t.size > 19 ? C.gold : t.size > 16 ? C.mist : subFg, fontStyle: t.size > 19 ? "italic" : "normal", lineHeight: 1.2 }}>{t.label}</span>
            ))}
          </div>
        </div>

        <div style={{ ...glass(C.greenGlass), padding: "20px" }}>
          <p style={{ fontFamily: fonts.body, fontSize: 11, color: C.gold, letterSpacing: 1.5, textTransform: "uppercase", margin: "0 0 16px" }}>Top Strengths Identified</p>
          {STRENGTHS.map((s, i) => (
            <div key={s} style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: i < 4 ? 14 : 0 }}>
              <div style={{ width: 28, height: 28, borderRadius: 8, background: "rgba(197,160,89,0.15)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <span style={{ fontFamily: fonts.body, fontSize: 12, fontWeight: 700, color: C.gold }}>{i + 1}</span>
              </div>
              <div style={{ flex: 1 }}>
                <p style={{ fontFamily: fonts.body, fontSize: 14, color: fg, margin: "0 0 4px", fontWeight: 500 }}>{s}</p>
                <div style={{ height: 4, borderRadius: 2, background: "rgba(209,224,215,0.1)", overflow: "hidden" }}>
                  <div style={{ height: "100%", width: `${90 - i * 12}%`, borderRadius: 2, background: `linear-gradient(90deg, ${C.gold}, rgba(197,160,89,0.4))` }} />
                </div>
              </div>
            </div>
          ))}
        </div>

        <div style={{ ...glass("rgba(197,160,89,0.08)", "rgba(197,160,89,0.2)"), padding: "14px 18px", marginTop: 16, display: "flex", alignItems: "center", gap: 10 }}>
          <Heart size={14} color={C.gold} />
          <span style={{ fontFamily: fonts.body, fontSize: 13, color: subFg }}>Journal these insights in <span style={{ color: C.gold, fontWeight: 600 }}>Resonance Journal</span></span>
        </div>
      </Section>
    </Page>
  );

  const TABS = [
    { id: "home", label: "Home", icon: Home },
    { id: "chat", label: "Chat", icon: MessageCircle },
    { id: "voice", label: "Voice", icon: Mic },
    { id: "sessions", label: "Sessions", icon: BookOpen },
    { id: "insights", label: "Insights", icon: BarChart2 },
  ];

  const screens = { home: HomeScreen, chat: ChatScreen, voice: VoiceScreen, sessions: SessionsScreen, insights: AskScreen };
  const ActiveScreen = tab === "insights" ? InsightsScreen : tab === "sessions" ? SessionsScreen : tab === "voice" ? VoiceScreen : tab === "chat" ? ChatScreen : HomeScreen;

  return (
    <div style={{ width: "100%", maxWidth: 430, margin: "0 auto", height: "100dvh", background: dark ? `linear-gradient(160deg, ${C.night} 0%, ${C.dark} 60%, ${C.mid} 100%)` : "linear-gradient(160deg, #EEF4F0 0%, #DDE9E3 100%)", display: "flex", flexDirection: "column", position: "relative", overflow: "hidden", fontFamily: fonts.body }}>
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,600;0,700;1,400;1,600&family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet" />

      <ActiveScreen />

      {/* Bottom Nav */}
      <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, ...glass(dark ? "rgba(5,16,11,0.85)" : "rgba(238,244,240,0.9)", C.glassStroke), borderRadius: "20px 20px 0 0", padding: "10px 0 16px", display: "flex", justifyContent: "space-around", zIndex: 100 }}>
        {TABS.map(t => (
          <button key={t.id} onClick={() => setTab(t.id)} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 4, background: "none", border: "none", cursor: "pointer", padding: "4px 12px" }}>
            <t.icon size={22} color={tab === t.id ? C.gold : subFg} strokeWidth={tab === t.id ? 2 : 1.5} />
            <span style={{ fontFamily: fonts.body, fontSize: 10, color: tab === t.id ? C.gold : subFg, fontWeight: tab === t.id ? 600 : 400 }}>{t.label}</span>
            {tab === t.id && <div style={{ width: 4, height: 4, borderRadius: "50%", background: C.gold, marginTop: -2 }} />}
          </button>
        ))}
      </div>
    </div>
  );
}
