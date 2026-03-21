import { useState, useEffect } from "react";
import { Wind, BookOpen, MessageCircle, Sun, Waves, Star, Mountain, Mic, ChevronRight, Play, Pause, Home, Brain, Layers, User } from "lucide-react";

const G = {
  bg: "#0A0A0F",
  green0: "#0A1C14",
  green1: "#122E21",
  green2: "#1B402E",
  greenLight: "#D1E0D7",
  gold: "#C5A059",
  goldLight: "#E6D0A1",
};

const glass = {
  background: "rgba(255,255,255,0.08)",
  backdropFilter: "blur(40px)",
  WebkitBackdropFilter: "blur(40px)",
  border: "1px solid rgba(255,255,255,0.12)",
  borderRadius: 28,
  boxShadow: "0 8px 64px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.1)",
};

const glassDeep = {
  ...glass,
  background: "rgba(26,64,46,0.18)",
  border: "1px solid rgba(193,160,89,0.18)",
};

const fonts = {
  serif: "'Cormorant Garamond', Georgia, serif",
  sans: "'Manrope', system-ui, sans-serif",
};

const SCREENS = ["home", "meditation", "learning", "layers", "coaching"];

const NavBar = ({ screen, setScreen }) => {
  const items = [
    { id: "home", icon: Home, label: "Home" },
    { id: "meditation", icon: Wind, label: "Breathe" },
    { id: "learning", icon: BookOpen, label: "Learn" },
    { id: "layers", icon: Layers, label: "Self" },
    { id: "coaching", icon: MessageCircle, label: "Coach" },
  ];
  return (
    <div style={{ position: "fixed", bottom: 32, left: "50%", transform: "translateX(-50%)", zIndex: 100, ...glass, padding: "10px 20px", display: "flex", gap: 8 }}>
      {items.map(({ id, icon: Icon, label }) => (
        <button key={id} onClick={() => setScreen(id)} style={{ background: screen === id ? "rgba(197,160,89,0.22)" : "transparent", border: screen === id ? "1px solid rgba(197,160,89,0.4)" : "1px solid transparent", borderRadius: 16, padding: "10px 18px", cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 4, transition: "all 0.3s ease" }}>
          <Icon size={18} color={screen === id ? G.gold : "rgba(255,255,255,0.5)"} />
          <span style={{ fontFamily: fonts.sans, fontSize: 10, color: screen === id ? G.goldLight : "rgba(255,255,255,0.4)", fontWeight: 600, letterSpacing: 0.5 }}>{label}</span>
        </button>
      ))}
    </div>
  );
};

const WindowChrome = ({ title, children, style = {} }) => (
  <div style={{ ...glassDeep, ...style, overflow: "hidden" }}>
    <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "14px 20px", borderBottom: "1px solid rgba(255,255,255,0.07)" }}>
      {["#FF5F57","#FEBC2E","#28C840"].map(c => <div key={c} style={{ width: 10, height: 10, borderRadius: "50%", background: c, opacity: 0.85 }} />)}
      <span style={{ fontFamily: fonts.sans, fontSize: 12, color: "rgba(255,255,255,0.4)", marginLeft: 8, letterSpacing: 0.6 }}>{title}</span>
    </div>
    {children}
  </div>
);

const SpatialHome = () => {
  const quote = "The privilege of a lifetime is to become who you truly are.";
  return (
    <div style={{ minHeight: "100vh", background: G.bg, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "80px 40px 120px", perspective: "1200px" }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse 60% 50% at 30% 40%, rgba(27,64,46,0.3) 0%, transparent 70%)", pointerEvents: "none" }} />
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse 40% 40% at 75% 65%, rgba(197,160,89,0.08) 0%, transparent 60%)", pointerEvents: "none" }} />
      <h1 style={{ fontFamily: fonts.serif, fontSize: 38, color: G.goldLight, fontWeight: 300, letterSpacing: 2, marginBottom: 40, textAlign: "center", textShadow: "0 0 40px rgba(197,160,89,0.4)" }}>Luminous Ego Development</h1>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 280px", gridTemplateRows: "auto auto", gap: 20, width: "100%", maxWidth: 900, transformStyle: "preserve-3d" }}>
        <WindowChrome title="Daily Reflection" style={{ gridColumn: "1", gridRow: "1", transform: "translateZ(20px) rotateY(-2deg)", transition: "transform 0.4s ease" }}>
          <div style={{ padding: "28px 32px" }}>
            <div style={{ fontFamily: fonts.sans, fontSize: 10, color: G.gold, letterSpacing: 2, textTransform: "uppercase", marginBottom: 16 }}>March 21, 2026</div>
            <p style={{ fontFamily: fonts.serif, fontSize: 26, color: "rgba(255,255,255,0.9)", lineHeight: 1.5, fontStyle: "italic", margin: 0 }}>"{quote}"</p>
            <p style={{ fontFamily: fonts.sans, fontSize: 12, color: "rgba(255,255,255,0.4)", marginTop: 16 }}>— Carl Jung</p>
            <div style={{ marginTop: 24, display: "flex", gap: 12 }}>
              {["Journal","Reflect","Share"].map(l => (
                <button key={l} style={{ ...glass, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)", borderRadius: 12, padding: "8px 16px", fontFamily: fonts.sans, fontSize: 12, color: G.greenLight, cursor: "pointer" }}>{l}</button>
              ))}
            </div>
          </div>
        </WindowChrome>
        <div style={{ gridColumn: "2", gridRow: "1 / 3", display: "flex", flexDirection: "column", gap: 16 }}>
          <WindowChrome title="Meditation Orb" style={{ transform: "translateZ(40px) rotateY(3deg)" }}>
            <div style={{ padding: 24, display: "flex", flexDirection: "column", alignItems: "center" }}>
              <div style={{ width: 100, height: 100, borderRadius: "50%", background: "radial-gradient(circle at 35% 35%, rgba(27,64,46,0.9), rgba(10,28,20,0.95))", boxShadow: "0 0 40px rgba(27,64,46,0.6), 0 0 80px rgba(27,64,46,0.3), inset 0 0 30px rgba(197,160,89,0.1)", display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 14 }}>
                <Wind size={32} color={G.goldLight} />
              </div>
              <div style={{ fontFamily: fonts.sans, fontSize: 13, color: G.greenLight, fontWeight: 600 }}>7-min Breath</div>
              <div style={{ fontFamily: fonts.sans, fontSize: 11, color: "rgba(255,255,255,0.4)", marginTop: 4 }}>Forest environment</div>
            </div>
          </WindowChrome>
          <WindowChrome title="Coaching Space" style={{ transform: "translateZ(30px) rotateY(2deg)", flex: 1 }}>
            <div style={{ padding: "16px 20px" }}>
              <div style={{ display: "flex", gap: 10, marginBottom: 12 }}>
                <div style={{ width: 36, height: 36, borderRadius: "50%", background: `linear-gradient(135deg, ${G.green2}, ${G.green1})`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                  <User size={16} color={G.goldLight} />
                </div>
                <div style={{ ...glass, background: "rgba(255,255,255,0.05)", borderRadius: 12, padding: "8px 14px", fontFamily: fonts.sans, fontSize: 12, color: "rgba(255,255,255,0.7)", lineHeight: 1.5 }}>How are you feeling with your shadow work today?</div>
              </div>
              <button style={{ width: "100%", background: `linear-gradient(135deg, rgba(27,64,46,0.5), rgba(18,46,33,0.5))`, border: `1px solid rgba(197,160,89,0.3)`, borderRadius: 14, padding: "10px", fontFamily: fonts.sans, fontSize: 12, color: G.goldLight, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
                <Mic size={14} /> Speak to coach
              </button>
            </div>
          </WindowChrome>
        </div>
        <WindowChrome title="Learning Modules" style={{ gridColumn: "1", gridRow: "2", transform: "translateZ(10px) rotateY(-1deg)" }}>
          <div style={{ padding: "16px 24px" }}>
            {[{ title: "The Ego & Its Defenses", prog: 68, tag: "In Progress" }, { title: "Shadow Integration", prog: 32, tag: "Active" }, { title: "Self-Actualization Practices", prog: 10, tag: "New" }].map(m => (
              <div key={m.title} style={{ display: "flex", alignItems: "center", gap: 16, padding: "12px 0", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
                <div style={{ flex: 1 }}>
                  <div style={{ fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.85)", fontWeight: 600 }}>{m.title}</div>
                  <div style={{ height: 4, background: "rgba(255,255,255,0.08)", borderRadius: 4, marginTop: 8 }}>
                    <div style={{ height: "100%", width: `${m.prog}%`, background: `linear-gradient(90deg, ${G.green2}, ${G.gold})`, borderRadius: 4 }} />
                  </div>
                </div>
                <span style={{ fontFamily: fonts.sans, fontSize: 10, color: G.gold, letterSpacing: 0.5, background: "rgba(197,160,89,0.12)", padding: "3px 8px", borderRadius: 8 }}>{m.tag}</span>
                <ChevronRight size={16} color="rgba(255,255,255,0.3)" />
              </div>
            ))}
          </div>
        </WindowChrome>
      </div>
    </div>
  );
};

const ImmersiveMeditation = () => {
  const [env, setEnv] = useState("Forest");
  const [playing, setPlaying] = useState(false);
  const [time, setTime] = useState(420);
  const envs = [{ name: "Forest", icon: Sun, color: "#1B402E" }, { name: "Ocean", icon: Waves, color: "#0D2B3E" }, { name: "Stars", icon: Star, color: "#1A1040" }, { name: "Mountain", icon: Mountain, color: "#2A2218" }];
  const active = envs.find(e => e.name === env);
  useEffect(() => {
    if (!playing) return;
    const id = setInterval(() => setTime(t => Math.max(0, t - 1)), 1000);
    return () => clearInterval(id);
  }, [playing]);
  const mm = String(Math.floor(time / 60)).padStart(2, "0");
  const ss = String(time % 60).padStart(2, "0");
  return (
    <div style={{ minHeight: "100vh", background: `radial-gradient(ellipse at center, ${active.color} 0%, ${G.bg} 70%)`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "40px 40px 120px", position: "relative" }}>
      <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse 80% 60% at 50% 50%, rgba(197,160,89,0.04) 0%, transparent 70%)`, pointerEvents: "none" }} />
      <div style={{ display: "flex", gap: 12, marginBottom: 48 }}>
        {envs.map(({ name, icon: Icon }) => (
          <button key={name} onClick={() => setEnv(name)} style={{ ...glass, background: env === name ? "rgba(197,160,89,0.18)" : "rgba(255,255,255,0.05)", border: env === name ? `1px solid rgba(197,160,89,0.5)` : "1px solid rgba(255,255,255,0.08)", borderRadius: 18, padding: "10px 20px", cursor: "pointer", display: "flex", alignItems: "center", gap: 8, transition: "all 0.3s" }}>
            <Icon size={16} color={env === name ? G.gold : "rgba(255,255,255,0.5)"} />
            <span style={{ fontFamily: fonts.sans, fontSize: 13, color: env === name ? G.goldLight : "rgba(255,255,255,0.5)", fontWeight: 600 }}>{name}</span>
          </button>
        ))}
      </div>
      <div style={{ position: "relative", marginBottom: 40 }}>
        <div style={{ position: "absolute", inset: -40, borderRadius: "50%", background: `radial-gradient(circle, rgba(27,64,46,0.3) 0%, transparent 70%)`, animation: playing ? "pulse 4s ease-in-out infinite" : "none" }} />
        <div style={{ width: 220, height: 220, borderRadius: "50%", background: `radial-gradient(circle at 35% 30%, rgba(27,64,46,0.95), rgba(10,28,20,0.98))`, boxShadow: playing ? `0 0 60px rgba(27,64,46,0.8), 0 0 120px rgba(27,64,46,0.4), 0 0 200px rgba(197,160,89,0.1), inset 0 0 60px rgba(197,160,89,0.08)` : `0 0 30px rgba(27,64,46,0.4), inset 0 0 30px rgba(197,160,89,0.05)`, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", cursor: "pointer", transition: "box-shadow 0.8s ease", position: "relative" }} onClick={() => setPlaying(p => !p)}>
          <div style={{ width: 140, height: 140, borderRadius: "50%", background: "radial-gradient(circle at 40% 35%, rgba(209,224,215,0.06), transparent)", border: "1px solid rgba(209,224,215,0.1)", display: "flex", alignItems: "center", justifyContent: "center" }}>
            {playing ? <Pause size={36} color={G.goldLight} /> : <Play size={36} color={G.goldLight} />}
          </div>
        </div>
      </div>
      <div style={{ fontFamily: fonts.serif, fontSize: 52, color: "rgba(255,255,255,0.9)", fontWeight: 300, letterSpacing: 4, marginBottom: 8 }}>{mm}:{ss}</div>
      <div style={{ fontFamily: fonts.sans, fontSize: 14, color: "rgba(255,255,255,0.4)", letterSpacing: 2, textTransform: "uppercase", marginBottom: 32 }}>Gaze to focus · {env} Environment</div>
      <WindowChrome title="Breath Guide" style={{ maxWidth: 360, width: "100%" }}>
        <div style={{ padding: "16px 24px", display: "flex", gap: 16, justifyContent: "center" }}>
          {["Inhale 4s", "Hold 4s", "Exhale 6s"].map((p, i) => (
            <div key={p} style={{ textAlign: "center" }}>
              <div style={{ fontFamily: fonts.sans, fontSize: 11, color: G.gold, fontWeight: 700, marginBottom: 4 }}>{p}</div>
              <div style={{ width: 60, height: 4, background: "rgba(255,255,255,0.08)", borderRadius: 4 }}>
                <div style={{ height: "100%", width: playing ? "100%" : "0%", background: `linear-gradient(90deg, ${G.green2}, ${G.gold})`, borderRadius: 4, transition: `width ${[4,4,6][i]}s linear` }} />
              </div>
            </div>
          ))}
        </div>
      </WindowChrome>
      <style>{`@keyframes pulse { 0%,100%{transform:scale(1);opacity:0.6} 50%{transform:scale(1.15);opacity:1} }`}</style>
    </div>
  );
};

const SpatialLearning = () => {
  const stages = [
    { id: 1, label: "Impulsive", x: 50, y: 20 }, { id: 2, label: "Self-Protective", x: 20, y: 45 },
    { id: 3, label: "Conformist", x: 80, y: 45 }, { id: 4, label: "Self-Aware", x: 35, y: 72 },
    { id: 5, label: "Conscientious", x: 65, y: 72 }, { id: 6, label: "Autonomous", x: 50, y: 90 },
  ];
  const links = [[1,2],[1,3],[2,4],[3,5],[4,6],[5,6]];
  return (
    <div style={{ minHeight: "100vh", background: G.bg, display: "flex", gap: 24, padding: "80px 40px 120px", alignItems: "flex-start" }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse 50% 60% at 20% 50%, rgba(18,46,33,0.25) 0%, transparent 70%)", pointerEvents: "none" }} />
      <WindowChrome title="Shadow Integration · Module 2" style={{ width: 340, flexShrink: 0, position: "relative", zIndex: 2 }}>
        <div style={{ padding: "24px 28px" }}>
          <div style={{ fontFamily: fonts.sans, fontSize: 10, color: G.gold, letterSpacing: 2, textTransform: "uppercase", marginBottom: 8 }}>Current Lesson</div>
          <h2 style={{ fontFamily: fonts.serif, fontSize: 24, color: "rgba(255,255,255,0.92)", fontWeight: 400, margin: "0 0 16px", lineHeight: 1.3 }}>Recognizing the Shadow in Daily Life</h2>
          <p style={{ fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.55)", lineHeight: 1.7, margin: "0 0 24px" }}>The shadow contains repressed ideas, weaknesses, desires, instincts, and shortcomings. Learning to recognize its projections is the first step toward integration.</p>
          <div style={{ height: 4, background: "rgba(255,255,255,0.06)", borderRadius: 4, marginBottom: 24 }}>
            <div style={{ height: "100%", width: "38%", background: `linear-gradient(90deg, ${G.green2}, ${G.gold})`, borderRadius: 4 }} />
          </div>
          {["What is Projection?", "Inner Critic Work", "Dream Analysis Intro"].map((t, i) => (
            <div key={t} style={{ display: "flex", alignItems: "center", gap: 12, padding: "10px 0", borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
              <div style={{ width: 24, height: 24, borderRadius: "50%", background: i === 0 ? `linear-gradient(135deg,${G.green2},${G.green1})` : "rgba(255,255,255,0.06)", border: i === 0 ? `1px solid ${G.gold}` : "1px solid rgba(255,255,255,0.1)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <span style={{ fontFamily: fonts.sans, fontSize: 10, color: i === 0 ? G.gold : "rgba(255,255,255,0.3)", fontWeight: 700 }}>{i+1}</span>
              </div>
              <span style={{ fontFamily: fonts.sans, fontSize: 13, color: i === 0 ? "rgba(255,255,255,0.85)" : "rgba(255,255,255,0.4)" }}>{t}</span>
              {i === 0 && <ChevronRight size={14} color={G.gold} style={{ marginLeft: "auto" }} />}
            </div>
          ))}
        </div>
      </WindowChrome>
      <WindowChrome title="Ego Development · Concept Map" style={{ flex: 1, position: "relative", zIndex: 2 }}>
        <div style={{ padding: 24 }}>
          <div style={{ fontFamily: fonts.sans, fontSize: 11, color: "rgba(255,255,255,0.4)", marginBottom: 20, letterSpacing: 0.5 }}>Loevinger's Stages of Ego Development — interact to explore</div>
          <div style={{ position: "relative", height: 380 }}>
            <svg style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }}>
              {links.map(([a,b]) => {
                const na = stages.find(s => s.id === a), nb = stages.find(s => s.id === b);
                return <line key={`${a}-${b}`} x1={`${na.x}%`} y1={`${na.y}%`} x2={`${nb.x}%`} y2={`${nb.y}%`} stroke="rgba(197,160,89,0.2)" strokeWidth={1.5} strokeDasharray="4 4" />;
              })}
            </svg>
            {stages.map(s => (
              <div key={s.id} style={{ position: "absolute", left: `${s.x}%`, top: `${s.y}%`, transform: "translate(-50%,-50%)", ...glass, background: "rgba(27,64,46,0.25)", border: `1px solid rgba(197,160,89,0.25)`, borderRadius: 16, padding: "10px 16px", cursor: "pointer", transition: "all 0.3s", textAlign: "center", minWidth: 110 }}>
                <div style={{ fontFamily: fonts.sans, fontSize: 11, color: G.gold, fontWeight: 700, marginBottom: 2 }}>Stage {s.id}</div>
                <div style={{ fontFamily: fonts.serif, fontSize: 14, color: "rgba(255,255,255,0.85)" }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>
      </WindowChrome>
    </div>
  );
};

const LayersOfSelf = () => {
  const [hovered, setHovered] = useState(null);
  const layers = [
    { id: "Self", size: 380, color: "rgba(197,160,89,0.08)", border: "rgba(197,160,89,0.35)", desc: "The archetype of wholeness and the regulating center of the psyche." },
    { id: "Shadow", size: 280, color: "rgba(18,46,33,0.25)", border: "rgba(27,64,46,0.7)", desc: "The unconscious part of the personality — repressed, denied aspects of the self." },
    { id: "Ego", size: 190, color: "rgba(27,64,46,0.3)", border: "rgba(209,224,215,0.3)", desc: "The conscious mind — the center of our field of consciousness and personal identity." },
    { id: "Persona", size: 110, color: "rgba(197,160,89,0.12)", border: "rgba(197,160,89,0.6)", desc: "The social mask we wear — the face presented to the outside world." },
  ];
  return (
    <div style={{ minHeight: "100vh", background: G.bg, display: "flex", alignItems: "center", justifyContent: "center", padding: "80px 40px 120px", gap: 48 }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse 60% 60% at 35% 50%, rgba(18,46,33,0.2) 0%, transparent 70%)", pointerEvents: "none" }} />
      <div style={{ position: "relative", width: 400, height: 400, flexShrink: 0 }}>
        {layers.map(l => (
          <div key={l.id} onMouseEnter={() => setHovered(l.id)} onMouseLeave={() => setHovered(null)} style={{ position: "absolute", width: l.size, height: l.size, borderRadius: "50%", background: hovered === l.id ? l.color.replace(/[\d.]+\)$/, s => `${Math.min(parseFloat(s)*2.5, 0.5)})`) : l.color, border: `1.5px solid ${l.border}`, boxShadow: hovered === l.id ? `0 0 40px ${l.border}, 0 0 80px ${l.color}` : `0 0 20px ${l.color}`, top: "50%", left: "50%", transform: "translate(-50%,-50%)", display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer", transition: "all 0.4s ease", backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)" }}>
            {l.id === "Persona" && <span style={{ fontFamily: fonts.serif, fontSize: 14, color: G.goldLight, fontWeight: 500 }}>Persona</span>}
          </div>
        ))}
        {layers.filter(l => l.id !== "Persona").map(l => (
          <div key={l.id + "-label"} style={{ position: "absolute", top: "50%", left: "50%", transform: `translate(${l.size/2 + 12}px, ${-l.size/2 + 10}px)`, pointerEvents: "none", opacity: hovered === l.id ? 1 : 0.6, transition: "opacity 0.3s" }}>
            <span style={{ fontFamily: fonts.serif, fontSize: 13, color: "rgba(255,255,255,0.7)", fontStyle: "italic" }}>{l.id}</span>
          </div>
        ))}
      </div>
      <div style={{ flex: 1, maxWidth: 360, position: "relative", zIndex: 2 }}>
        <h2 style={{ fontFamily: fonts.serif, fontSize: 32, color: G.goldLight, fontWeight: 300, margin: "0 0 8px", letterSpacing: 1 }}>Jungian Layers</h2>
        <p style={{ fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.4)", margin: "0 0 28px", lineHeight: 1.6 }}>Hover a layer to illuminate it. Each ring represents a dimension of the psyche.</p>
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {layers.map(l => (
            <div key={l.id} onMouseEnter={() => setHovered(l.id)} onMouseLeave={() => setHovered(null)} style={{ ...glass, background: hovered === l.id ? "rgba(197,160,89,0.1)" : "rgba(255,255,255,0.04)", border: `1px solid ${hovered === l.id ? "rgba(197,160,89,0.4)" : "rgba(255,255,255,0.07)"}`, borderRadius: 18, padding: "16px 20px", cursor: "pointer", transition: "all 0.3s" }}>
              <div style={{ fontFamily: fonts.serif, fontSize: 17, color: hovered === l.id ? G.goldLight : "rgba(255,255,255,0.8)", marginBottom: 6 }}>{l.id}</div>
              <div style={{ fontFamily: fonts.sans, fontSize: 12, color: "rgba(255,255,255,0.45)", lineHeight: 1.6 }}>{l.desc}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

const CoachingSpace = () => {
  const [active, setActive] = useState(false);
  const messages = [
    { role: "coach", text: "Welcome back. I sensed some resistance in your last journal entry around vulnerability. Shall we explore that together?" },
    { role: "user", text: "Yes, I think I've been avoiding it." },
    { role: "coach", text: "That avoidance is wisdom trying to protect you. What would it feel like to let that guard down, just 10%?" },
  ];
  return (
    <div style={{ minHeight: "100vh", background: G.bg, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "80px 40px 120px" }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse 50% 50% at 50% 50%, rgba(18,46,33,0.22) 0%, transparent 70%)", pointerEvents: "none" }} />
      <div style={{ position: "absolute", inset: 0, background: `radial-gradient(ellipse 30% 30% at 50% ${active ? "55%" : "50%"}, rgba(197,160,89,0.06) 0%, transparent 60%)`, pointerEvents: "none", transition: "all 0.8s ease" }} />
      <div style={{ fontFamily: fonts.serif, fontSize: 36, color: G.goldLight, fontWeight: 300, marginBottom: 6, letterSpacing: 1.5 }}>Coaching Space</div>
      <div style={{ fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.35)", marginBottom: 40, letterSpacing: 1 }}>Voice-first · Spatial Audio · Presence Mode</div>
      <div style={{ display: "flex", alignItems: "flex-end", gap: 8, marginBottom: 32 }}>
        {[6,10,14,10,18,10,14,8,12,6].map((h, i) => (
          <div key={i} style={{ width: 3, height: active ? h * 2.5 : h, background: active ? G.gold : "rgba(255,255,255,0.15)", borderRadius: 4, transition: `height ${0.2 + i*0.05}s ease`, boxShadow: active ? `0 0 8px rgba(197,160,89,0.6)` : "none" }} />
        ))}
      </div>
      <WindowChrome title="Resonance Coach · AI" style={{ width: "100%", maxWidth: 560, marginBottom: 24 }}>
        <div style={{ padding: "20px 24px", display: "flex", flexDirection: "column", gap: 16, maxHeight: 280, overflowY: "auto" }}>
          {messages.map((m, i) => (
            <div key={i} style={{ display: "flex", gap: 12, flexDirection: m.role === "user" ? "row-reverse" : "row" }}>
              <div style={{ width: 32, height: 32, borderRadius: "50%", background: m.role === "coach" ? `linear-gradient(135deg,${G.green2},${G.green1})` : "rgba(197,160,89,0.2)", border: m.role === "coach" ? `1px solid ${G.gold}` : "1px solid rgba(197,160,89,0.3)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                {m.role === "coach" ? <Brain size={14} color={G.gold} /> : <User size={14} color={G.goldLight} />}
              </div>
              <div style={{ ...glass, background: m.role === "coach" ? "rgba(27,64,46,0.2)" : "rgba(197,160,89,0.1)", border: `1px solid ${m.role === "coach" ? "rgba(27,64,46,0.4)" : "rgba(197,160,89,0.2)"}`, borderRadius: m.role === "coach" ? "4px 18px 18px 18px" : "18px 4px 18px 18px", padding: "12px 16px", maxWidth: "75%" }}>
                <p style={{ fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.8)", lineHeight: 1.6, margin: 0 }}>{m.text}</p>
              </div>
            </div>
          ))}
        </div>
      </WindowChrome>
      <button onClick={() => setActive(a => !a)} style={{ width: 72, height: 72, borderRadius: "50%", background: active ? `linear-gradient(135deg, ${G.gold}, #A07030)` : `linear-gradient(135deg, ${G.green2}, ${G.green1})`, border: `2px solid ${active ? G.goldLight : "rgba(209,224,215,0.3)"}`, boxShadow: active ? `0 0 40px rgba(197,160,89,0.5), 0 0 80px rgba(197,160,89,0.2)` : `0 0 20px rgba(27,64,46,0.4)`, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", transition: "all 0.4s ease", marginBottom: 14 }}>
        <Mic size={26} color="white" />
      </button>
      <div style={{ fontFamily: fonts.sans, fontSize: 12, color: active ? G.gold : "rgba(255,255,255,0.35)", letterSpacing: 1.5, textTransform: "uppercase", transition: "color 0.3s" }}>{active ? "Listening..." : "Speak to your coach"}</div>
    </div>
  );
};

export default function ResonanceVision() {
  const [screen, setScreen] = useState("home");
  const screens = { home: SpatialHome, meditation: ImmersiveMeditation, learning: SpatialLearning, layers: LayersOfSelf, coaching: CoachingSpace };
  const Screen = screens[screen];
  return (
    <div style={{ fontFamily: fonts.sans, background: G.bg, minHeight: "100vh", position: "relative", overflow: "hidden" }}>
      <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,500;1,300;1,400&family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet" />
      <Screen />
      <NavBar screen={screen} setScreen={setScreen} />
    </div>
  );
}
