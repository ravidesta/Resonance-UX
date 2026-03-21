import { useState, useEffect } from "react";
import {
  Home, Music2, BookOpen, BarChart2, Play, Pause, SkipBack, SkipForward,
  Moon, Sun, Droplets, Wind, Flame, TreePine, Bookmark, Clock, Award,
  ChevronRight, Star, Zap, Heart, Headphones
} from "lucide-react";

const C = {
  night: "#05100B", darkest: "#0A1C14", dark: "#122E21", mid: "#1B402E",
  muted: "#D1E0D7", gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
};

const MEDITATIONS = [
  { id:1, title:"Morning Ground", duration:"10 min", instructor:"Sera Voss", difficulty:1, category:"Grounding", desc:"Root into the present moment." },
  { id:2, title:"Self-Compassion Wave", duration:"15 min", instructor:"Kai Lumen", difficulty:2, category:"Self-Compassion", desc:"Open the heart gently inward." },
  { id:3, title:"Body Scan Release", duration:"20 min", instructor:"Nora Delane", difficulty:1, category:"Body Scan", desc:"Dissolve tension layer by layer." },
  { id:4, title:"Loving-Kindness Core", duration:"12 min", instructor:"Sera Voss", difficulty:2, category:"Loving-Kindness", desc:"Radiate warmth to all beings." },
  { id:5, title:"Breath as Anchor", duration:"8 min", instructor:"Kai Lumen", difficulty:1, category:"Breath", desc:"Find stillness in each exhale." },
  { id:6, title:"Deep Sleep Descent", duration:"25 min", instructor:"Nora Delane", difficulty:1, category:"Sleep", desc:"Drift into restorative sleep." },
  { id:7, title:"Ego Observer", duration:"18 min", instructor:"Sera Voss", difficulty:3, category:"Grounding", desc:"Watch the watcher with clarity." },
  { id:8, title:"Tender Self-Meeting", duration:"14 min", instructor:"Kai Lumen", difficulty:2, category:"Self-Compassion", desc:"Meet yourself without judgment." },
];

const LECTURES = [
  { id:1, ep:"Ep 01", title:"What Is the Ego?", duration:"38 min", desc:"A philosophical and psychological introduction to the structures of self." },
  { id:2, ep:"Ep 02", title:"Stages of Development", duration:"44 min", desc:"From impulsive to integrated — mapping the journey inward." },
  { id:3, ep:"Ep 03", title:"Shadow & the Unlived Life", duration:"52 min", desc:"How disowned parts shape our reality and relationships." },
  { id:4, ep:"Ep 04", title:"Luminous Witnessing", duration:"41 min", desc:"The practice of observing thought without identification." },
  { id:5, ep:"Ep 05", title:"Integration & Embodiment", duration:"49 min", desc:"Bringing higher awareness into daily, embodied living." },
];

const CHAPTERS = [
  { id:1, title:"The Mirror Self", duration:"32 min", progress:100 },
  { id:2, title:"Layers of Identity", duration:"28 min", progress:100 },
  { id:3, title:"The Witnessing Presence", duration:"35 min", progress:60 },
  { id:4, title:"Shadow Ecology", duration:"31 min", progress:0 },
  { id:5, title:"Grief as Gateway", duration:"27 min", progress:0 },
  { id:6, title:"The Integrated Heart", duration:"33 min", progress:0 },
  { id:7, title:"Beyond the Story", duration:"29 min", progress:0 },
  { id:8, title:"Living Luminously", duration:"38 min", progress:0 },
];

const DAYS = ["M","T","W","T","F","S","S"];
const MINUTES = [12, 20, 8, 25, 15, 30, 18];

const glass = (extra = {}) => ({
  background: "rgba(27,64,46,0.45)",
  backdropFilter: "blur(18px)",
  WebkitBackdropFilter: "blur(18px)",
  border: "1px solid rgba(197,160,89,0.18)",
  borderRadius: 16,
  ...extra,
});

const DiffDot = ({ level }) => (
  <span style={{ display:"flex", gap:3 }}>
    {[1,2,3].map(i => (
      <span key={i} style={{ width:6, height:6, borderRadius:"50%",
        background: i <= level ? C.gold : "rgba(209,224,215,0.3)" }} />
    ))}
  </span>
);

export default function ResonanceMeditate() {
  const [tab, setTab] = useState("home");
  const [dark, setDark] = useState(true);
  const [playing, setPlaying] = useState(null);
  const [screen, setScreen] = useState("main");
  const [catFilter, setCatFilter] = useState("All");
  const [isPlaying, setIsPlaying] = useState(false);
  const [sound, setSound] = useState("rain");
  const [speed, setSpeed] = useState("1x");
  const [lectPlaying, setLectPlaying] = useState(null);
  const [breathPhase, setBreathPhase] = useState("inhale");

  useEffect(() => {
    if (screen !== "player") return;
    const phases = ["inhale","hold","exhale","rest"];
    const durations = [4000,2000,4000,2000];
    let idx = 0;
    const cycle = () => { idx = (idx+1)%4; setBreathPhase(phases[idx]); };
    const t = setInterval(cycle, durations[idx]);
    return () => clearInterval(t);
  }, [screen]);

  const bg = dark
    ? `radial-gradient(ellipse 80% 60% at 20% 10%, #1B402E 0%, #05100B 60%),
       radial-gradient(ellipse 60% 50% at 80% 80%, #122E21 0%, #05100B 70%)`
    : `radial-gradient(ellipse 80% 60% at 20% 10%, #D1E0D7 0%, #FAFAF8 60%),
       radial-gradient(ellipse 60% 50% at 80% 80%, #E6D0A1 0%, #FAFAF8 70%)`;

  const txt = dark ? C.cream : C.darkest;
  const subtxt = dark ? C.muted : C.mid;

  const playMed = (m) => { setPlaying(m); setScreen("player"); setIsPlaying(true); };

  if (screen === "player" && playing) {
    const breathScale = breathPhase === "inhale" ? 1.22 : breathPhase === "hold" ? 1.22 : breathPhase === "exhale" ? 1 : 1;
    const breathLabel = { inhale:"Breathe In", hold:"Hold", exhale:"Breathe Out", rest:"Rest" }[breathPhase];
    return (
      <div style={{ minHeight:"100vh", background:bg, display:"flex", flexDirection:"column",
        alignItems:"center", fontFamily:"'Manrope', sans-serif", color:txt, padding:"0 0 32px" }}>
        <div style={{ width:"100%", maxWidth:420, padding:"24px 24px 0", display:"flex", justifyContent:"space-between", alignItems:"center" }}>
          <button onClick={() => setScreen("main")} style={{ background:"none", border:"none", color:txt, fontSize:22, cursor:"pointer" }}>←</button>
          <span style={{ fontFamily:"'Cormorant Garamond', serif", fontSize:18, fontWeight:600 }}>Now Playing</span>
          <button style={{ background:"none", border:"none", color:C.gold, cursor:"pointer" }}><Bookmark size={18}/></button>
        </div>
        <div style={{ flex:1, width:"100%", maxWidth:420, display:"flex", flexDirection:"column", alignItems:"center", padding:"0 24px", gap:24 }}>
          <div style={{ marginTop:32, display:"flex", flexDirection:"column", alignItems:"center", gap:8 }}>
            <div style={{ position:"relative", width:200, height:200, display:"flex", alignItems:"center", justifyContent:"center" }}>
              <div style={{ position:"absolute", width:200, height:200, borderRadius:"50%",
                background:`radial-gradient(circle, rgba(197,160,89,0.15) 0%, rgba(27,64,46,0.4) 70%)`,
                border:`1.5px solid rgba(197,160,89,0.3)`,
                transform:`scale(${breathScale})`, transition:`transform ${breathPhase === "inhale" ? 4 : breathPhase === "exhale" ? 4 : 2}s ease-in-out` }} />
              <div style={{ position:"absolute", width:140, height:140, borderRadius:"50%",
                background:`radial-gradient(circle, rgba(197,160,89,0.25) 0%, rgba(18,46,33,0.6) 80%)`,
                transform:`scale(${breathScale * 0.92})`, transition:`transform ${breathPhase === "inhale" ? 4 : breathPhase === "exhale" ? 4 : 2}s ease-in-out` }} />
              <div style={{ position:"relative", zIndex:2, textAlign:"center" }}>
                <div style={{ fontFamily:"'Cormorant Garamond', serif", fontSize:15, color:C.goldLight }}>{breathLabel}</div>
              </div>
            </div>
            <h2 style={{ fontFamily:"'Cormorant Garamond', serif", fontSize:26, fontWeight:600, margin:0, textAlign:"center" }}>{playing.title}</h2>
            <p style={{ margin:0, color:subtxt, fontSize:13 }}>{playing.instructor} · {playing.duration}</p>
          </div>
          <div style={{ width:"100%", ...glass({ padding:"10px 16px", borderRadius:12 }) }}>
            <div style={{ height:4, background:"rgba(209,224,215,0.2)", borderRadius:4, overflow:"hidden" }}>
              <div style={{ height:"100%", width:"35%", background:`linear-gradient(90deg, ${C.gold}, ${C.goldLight})`, borderRadius:4 }} />
            </div>
            <div style={{ display:"flex", justifyContent:"space-between", fontSize:11, color:subtxt, marginTop:6 }}>
              <span>3:30</span><span>{playing.duration}</span>
            </div>
          </div>
          <div style={{ display:"flex", alignItems:"center", gap:28 }}>
            <button style={{ background:"none", border:"none", color:subtxt, cursor:"pointer" }}><SkipBack size={22}/></button>
            <button onClick={() => setIsPlaying(p => !p)} style={{ width:62, height:62, borderRadius:"50%",
              background:`linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
              border:"none", cursor:"pointer", display:"flex", alignItems:"center", justifyContent:"center",
              boxShadow:`0 0 28px rgba(197,160,89,0.4)` }}>
              {isPlaying ? <Pause size={26} color={C.darkest}/> : <Play size={26} color={C.darkest}/>}
            </button>
            <button style={{ background:"none", border:"none", color:subtxt, cursor:"pointer" }}><SkipForward size={22}/></button>
          </div>
          <div style={{ width:"100%", ...glass({ padding:"14px 16px" }) }}>
            <p style={{ margin:"0 0 10px", fontSize:12, color:subtxt, letterSpacing:1, textTransform:"uppercase" }}>Nature Sounds</p>
            <div style={{ display:"flex", gap:12, justifyContent:"space-around" }}>
              {[["rain",Droplets],["ocean",Wind],["forest",TreePine],["fire",Flame]].map(([k,Icon]) => (
                <button key={k} onClick={() => setSound(k)} style={{ background: sound===k ? `rgba(197,160,89,0.25)` : "rgba(27,64,46,0.4)",
                  border: `1px solid ${sound===k ? C.gold : "rgba(209,224,215,0.15)"}`,
                  borderRadius:10, padding:"8px 12px", cursor:"pointer", color: sound===k ? C.gold : subtxt,
                  display:"flex", flexDirection:"column", alignItems:"center", gap:4, fontSize:10, textTransform:"capitalize" }}>
                  <Icon size={16}/>{k}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  const cats = ["All","Grounding","Self-Compassion","Body Scan","Loving-Kindness","Breath","Sleep"];
  const filtered = catFilter === "All" ? MEDITATIONS : MEDITATIONS.filter(m => m.category === catFilter);

  return (
    <div style={{ minHeight:"100vh", background:bg, fontFamily:"'Manrope', sans-serif", color:txt, display:"flex", flexDirection:"column" }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600;700&family=Manrope:wght@300;400;500;600&display=swap');
        * { box-sizing: border-box; } ::-webkit-scrollbar { display: none; }
        button { font-family: 'Manrope', sans-serif; }
      `}</style>

      {/* Header */}
      <div style={{ padding:"20px 20px 0", display:"flex", justifyContent:"space-between", alignItems:"center", maxWidth:480, margin:"0 auto", width:"100%" }}>
        <div>
          <p style={{ margin:0, fontSize:11, letterSpacing:2, color:C.gold, textTransform:"uppercase" }}>Resonance</p>
          <h1 style={{ margin:0, fontFamily:"'Cormorant Garamond', serif", fontSize:24, fontWeight:600 }}>Meditate</h1>
        </div>
        <button onClick={() => setDark(d => !d)} style={{ ...glass({ padding:"8px 12px", borderRadius:20 }), border:"none", cursor:"pointer", color:C.gold, display:"flex", alignItems:"center", gap:6 }}>
          {dark ? <Sun size={15}/> : <Moon size={15}/>}
          <span style={{ fontSize:12 }}>{dark ? "Light" : "Dark"}</span>
        </button>
      </div>

      {/* Body */}
      <div style={{ flex:1, overflowY:"auto", padding:"16px 20px 80px", maxWidth:480, margin:"0 auto", width:"100%" }}>

        {/* HOME */}
        {tab === "home" && (
          <div style={{ display:"flex", flexDirection:"column", gap:20 }}>
            <div style={{ ...glass({ padding:"22px 20px", borderRadius:20 }), background:"linear-gradient(135deg, rgba(27,64,46,0.7) 0%, rgba(18,46,33,0.8) 100%)", position:"relative", overflow:"hidden" }}>
              <div style={{ position:"absolute", top:-30, right:-30, width:120, height:120, borderRadius:"50%", background:"rgba(197,160,89,0.1)" }} />
              <p style={{ margin:"0 0 4px", fontSize:11, letterSpacing:2, color:C.gold, textTransform:"uppercase" }}>Featured</p>
              <h2 style={{ margin:"0 0 6px", fontFamily:"'Cormorant Garamond', serif", fontSize:22, fontWeight:600 }}>Morning Ground</h2>
              <p style={{ margin:"0 0 16px", fontSize:13, color:subtxt }}>Start your day rooted and present</p>
              <div style={{ display:"flex", alignItems:"center", gap:12 }}>
                <button onClick={() => playMed(MEDITATIONS[0])} style={{ background:`linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
                  border:"none", borderRadius:24, padding:"10px 22px", cursor:"pointer", fontWeight:600, fontSize:13, color:C.darkest,
                  display:"flex", alignItems:"center", gap:8 }}>
                  <Play size={14} fill={C.darkest}/>Begin · 10 min
                </button>
                <DiffDot level={1}/>
              </div>
            </div>

            <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:10 }}>
              {[["128","Min This Week",Zap],["9","Day Streak",Flame],["34","Sessions",Star]].map(([val,label,Icon]) => (
                <div key={label} style={{ ...glass({ padding:"14px 10px", borderRadius:14, textAlign:"center" }) }}>
                  <Icon size={16} color={C.gold} style={{ marginBottom:6 }}/>
                  <p style={{ margin:"0 0 2px", fontFamily:"'Cormorant Garamond', serif", fontSize:22, fontWeight:600, color:C.goldLight }}>{val}</p>
                  <p style={{ margin:0, fontSize:10, color:subtxt }}>{label}</p>
                </div>
              ))}
            </div>

            <div>
              <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:12 }}>
                <h3 style={{ margin:0, fontFamily:"'Cormorant Garamond', serif", fontSize:18, fontWeight:600 }}>Recommended</h3>
                <button onClick={() => setTab("meditate")} style={{ background:"none", border:"none", color:C.gold, cursor:"pointer", fontSize:12, display:"flex", alignItems:"center", gap:4 }}>
                  See all <ChevronRight size={14}/>
                </button>
              </div>
              <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
                {MEDITATIONS.slice(1,4).map(m => (
                  <div key={m.id} onClick={() => playMed(m)} style={{ ...glass({ padding:"14px 16px", borderRadius:14 }), display:"flex", alignItems:"center", gap:14, cursor:"pointer" }}>
                    <div style={{ width:44, height:44, borderRadius:12, background:`linear-gradient(135deg, rgba(197,160,89,0.2), rgba(27,64,46,0.6))`,
                      display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0 }}>
                      <Play size={16} color={C.gold} fill={C.gold}/>
                    </div>
                    <div style={{ flex:1 }}>
                      <p style={{ margin:"0 0 2px", fontSize:14, fontWeight:500 }}>{m.title}</p>
                      <p style={{ margin:0, fontSize:11, color:subtxt }}>{m.instructor} · {m.duration}</p>
                    </div>
                    <DiffDot level={m.difficulty}/>
                  </div>
                ))}
              </div>
            </div>

            <div style={{ ...glass({ padding:"16px", borderRadius:16 }), background:"rgba(197,160,89,0.08)", borderColor:"rgba(197,160,89,0.25)" }}>
              <div style={{ display:"flex", gap:12, alignItems:"center" }}>
                <Headphones size={22} color={C.gold}/>
                <div style={{ flex:1 }}>
                  <p style={{ margin:"0 0 2px", fontSize:13, fontWeight:600, color:C.goldLight }}>New Lecture Available</p>
                  <p style={{ margin:0, fontSize:11, color:subtxt }}>Ep 05 · Integration & Embodiment</p>
                </div>
                <button onClick={() => setTab("lectures")} style={{ background:`rgba(197,160,89,0.2)`, border:"none", borderRadius:8, padding:"6px 12px", color:C.gold, fontSize:12, cursor:"pointer" }}>
                  Listen
                </button>
              </div>
            </div>
          </div>
        )}

        {/* MEDITATE */}
        {tab === "meditate" && (
          <div style={{ display:"flex", flexDirection:"column", gap:16 }}>
            <h2 style={{ margin:0, fontFamily:"'Cormorant Garamond', serif", fontSize:22, fontWeight:600 }}>Meditations</h2>
            <div style={{ display:"flex", gap:8, overflowX:"auto", paddingBottom:4 }}>
              {cats.map(c => (
                <button key={c} onClick={() => setCatFilter(c)} style={{ flexShrink:0, background: catFilter===c ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "rgba(27,64,46,0.5)",
                  border:"none", borderRadius:20, padding:"7px 14px", fontSize:12, fontWeight:500,
                  color: catFilter===c ? C.darkest : subtxt, cursor:"pointer" }}>
                  {c}
                </button>
              ))}
            </div>
            <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:12 }}>
              {filtered.map(m => (
                <div key={m.id} onClick={() => playMed(m)} style={{ ...glass({ padding:"16px", borderRadius:16 }), cursor:"pointer" }}>
                  <div style={{ width:36, height:36, borderRadius:10, background:`linear-gradient(135deg, rgba(197,160,89,0.25), rgba(27,64,46,0.5))`,
                    display:"flex", alignItems:"center", justifyContent:"center", marginBottom:10 }}>
                    <Play size={14} color={C.gold} fill={C.gold}/>
                  </div>
                  <p style={{ margin:"0 0 3px", fontSize:13, fontWeight:600, lineHeight:1.3 }}>{m.title}</p>
                  <p style={{ margin:"0 0 8px", fontSize:11, color:subtxt }}>{m.instructor}</p>
                  <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                    <span style={{ fontSize:11, color:C.gold }}>{m.duration}</span>
                    <DiffDot level={m.difficulty}/>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* LECTURES */}
        {tab === "lectures" && (
          <div style={{ display:"flex", flexDirection:"column", gap:16 }}>
            <div>
              <p style={{ margin:"0 0 2px", fontSize:11, letterSpacing:2, color:C.gold, textTransform:"uppercase" }}>Audio Series</p>
              <h2 style={{ margin:0, fontFamily:"'Cormorant Garamond', serif", fontSize:22, fontWeight:600 }}>Ego Development</h2>
            </div>
            <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
              {LECTURES.map(l => (
                <div key={l.id} style={{ ...glass({ padding:"16px", borderRadius:16 }), display:"flex", gap:14, cursor:"pointer" }}
                  onClick={() => setLectPlaying(lectPlaying === l.id ? null : l.id)}>
                  <div style={{ width:48, height:48, borderRadius:12, background:`linear-gradient(135deg, rgba(197,160,89,0.2), rgba(18,46,33,0.7))`,
                    display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0,
                    border:`1px solid ${lectPlaying===l.id ? C.gold : "transparent"}` }}>
                    {lectPlaying === l.id ? <Pause size={18} color={C.gold}/> : <Play size={18} color={C.gold} fill={C.gold}/>}
                  </div>
                  <div style={{ flex:1 }}>
                    <p style={{ margin:"0 0 1px", fontSize:11, color:C.gold }}>{l.ep}</p>
                    <p style={{ margin:"0 0 4px", fontSize:14, fontWeight:600 }}>{l.title}</p>
                    <p style={{ margin:"0 0 6px", fontSize:11, color:subtxt, lineHeight:1.4 }}>{l.desc}</p>
                    <div style={{ display:"flex", alignItems:"center", gap:6 }}>
                      <Clock size={11} color={subtxt}/>
                      <span style={{ fontSize:11, color:subtxt }}>{l.duration}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            <div style={{ ...glass({ padding:"14px 16px", borderRadius:14 }), background:"rgba(27,64,46,0.5)", display:"flex", alignItems:"center", gap:12 }}>
              <BookOpen size={18} color={C.gold}/>
              <p style={{ margin:0, fontSize:12, color:subtxt, flex:1 }}>Explore the full audiobook for deeper study</p>
              <button onClick={() => setTab("book")} style={{ background:`rgba(197,160,89,0.2)`, border:"none", borderRadius:8, padding:"6px 12px", color:C.gold, fontSize:12, cursor:"pointer" }}>
                Open
              </button>
            </div>
          </div>
        )}

        {/* AUDIOBOOK */}
        {tab === "book" && (
          <div style={{ display:"flex", flexDirection:"column", gap:16 }}>
            <div style={{ ...glass({ padding:"20px", borderRadius:20 }), display:"flex", gap:16 }}>
              <div style={{ width:80, height:110, borderRadius:10, background:`linear-gradient(160deg, ${C.gold}, ${C.mid})`,
                display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0, fontSize:30 }}>✦</div>
              <div>
                <p style={{ margin:"0 0 4px", fontFamily:"'Cormorant Garamond', serif", fontSize:18, fontWeight:600, lineHeight:1.2 }}>Luminous: A Guide to Ego Development</p>
                <p style={{ margin:"0 0 10px", fontSize:12, color:subtxt }}>Sera Voss · 8 Chapters · 4h 13m</p>
                <div style={{ display:"flex", gap:8 }}>
                  {["0.5x","0.75x","1x","1.25x","1.5x","2x"].map(s => (
                    <button key={s} onClick={() => setSpeed(s)} style={{ background: speed===s ? `rgba(197,160,89,0.25)` : "rgba(27,64,46,0.5)",
                      border:`1px solid ${speed===s ? C.gold : "transparent"}`, borderRadius:6, padding:"3px 8px",
                      fontSize:10, color: speed===s ? C.gold : subtxt, cursor:"pointer" }}>{s}</button>
                  ))}
                </div>
              </div>
            </div>
            <div style={{ ...glass({ padding:"14px 16px", borderRadius:14 }) }}>
              <div style={{ display:"flex", justifyContent:"space-between", fontSize:12, color:subtxt, marginBottom:6 }}>
                <span>Overall Progress</span><span>25%</span>
              </div>
              <div style={{ height:5, background:"rgba(209,224,215,0.2)", borderRadius:4 }}>
                <div style={{ height:"100%", width:"25%", background:`linear-gradient(90deg, ${C.gold}, ${C.goldLight})`, borderRadius:4 }} />
              </div>
            </div>
            <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
              {CHAPTERS.map((ch, i) => (
                <div key={ch.id} style={{ ...glass({ padding:"14px 16px", borderRadius:14 }), display:"flex", alignItems:"center", gap:14,
                  opacity: ch.progress === 0 && i > 2 ? 0.7 : 1 }}>
                  <div style={{ width:32, height:32, borderRadius:"50%", flexShrink:0,
                    background: ch.progress === 100 ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : ch.progress > 0 ? `conic-gradient(${C.gold} ${ch.progress}%, rgba(27,64,46,0.6) 0%)` : "rgba(27,64,46,0.6)",
                    display:"flex", alignItems:"center", justifyContent:"center", fontSize:11, fontWeight:600,
                    color: ch.progress === 100 ? C.darkest : subtxt }}>
                    {ch.progress === 100 ? "✓" : ch.id}
                  </div>
                  <div style={{ flex:1 }}>
                    <p style={{ margin:"0 0 2px", fontSize:13, fontWeight:500 }}>{ch.title}</p>
                    <p style={{ margin:0, fontSize:11, color:subtxt }}>{ch.duration}</p>
                  </div>
                  <button style={{ background:"none", border:"none", color: ch.progress > 0 ? C.gold : subtxt, cursor:"pointer" }}>
                    {ch.progress > 0 ? <Play size={16} fill={C.gold}/> : <Play size={16}/>}
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* PROGRESS */}
        {tab === "progress" && (
          <div style={{ display:"flex", flexDirection:"column", gap:20 }}>
            <h2 style={{ margin:0, fontFamily:"'Cormorant Garamond', serif", fontSize:22, fontWeight:600 }}>Your Progress</h2>
            <div style={{ ...glass({ padding:"20px", borderRadius:18 }) }}>
              <p style={{ margin:"0 0 16px", fontSize:13, fontWeight:500 }}>Minutes This Week</p>
              <div style={{ display:"flex", align:"flex-end", gap:8, height:80, alignItems:"flex-end" }}>
                {DAYS.map((d, i) => (
                  <div key={i} style={{ flex:1, display:"flex", flexDirection:"column", alignItems:"center", gap:6 }}>
                    <div style={{ width:"100%", height: `${(MINUTES[i]/30)*70}px`, minHeight:6,
                      background: i === 6 ? `linear-gradient(180deg, ${C.goldLight}, ${C.gold})` : "rgba(197,160,89,0.35)",
                      borderRadius:"4px 4px 0 0", transition:"height 0.4s" }} />
                    <span style={{ fontSize:10, color:subtxt }}>{d}</span>
                  </div>
                ))}
              </div>
            </div>
            <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:10 }}>
              {[["9","Day Streak",Flame],["128","Min Total",Zap],["34","Sessions",Star]].map(([val,label,Icon]) => (
                <div key={label} style={{ ...glass({ padding:"14px 10px", borderRadius:14, textAlign:"center" }) }}>
                  <Icon size={16} color={C.gold} style={{ marginBottom:4 }}/>
                  <p style={{ margin:"0 0 2px", fontFamily:"'Cormorant Garamond', serif", fontSize:20, fontWeight:600, color:C.goldLight }}>{val}</p>
                  <p style={{ margin:0, fontSize:10, color:subtxt }}>{label}</p>
                </div>
              ))}
            </div>
            <div>
              <h3 style={{ margin:"0 0 12px", fontFamily:"'Cormorant Garamond', serif", fontSize:18, fontWeight:600 }}>Achievements</h3>
              <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
                {[
                  [Award,"First Light","Completed your first meditation","gold"],
                  [Heart,"Compassion Bloom","7 consecutive self-compassion sessions","gold"],
                  [Zap,"10-Day Streak","Meditated 10 days in a row","muted"],
                ].map(([Icon, title, desc, state]) => (
                  <div key={title} style={{ ...glass({ padding:"14px 16px", borderRadius:14 }), display:"flex", gap:14, alignItems:"center",
                    opacity: state === "muted" ? 0.55 : 1 }}>
                    <div style={{ width:44, height:44, borderRadius:12, background: state==="gold" ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "rgba(27,64,46,0.6)",
                      display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0 }}>
                      <Icon size={20} color={state==="gold" ? C.darkest : subtxt}/>
                    </div>
                    <div>
                      <p style={{ margin:"0 0 2px", fontSize:13, fontWeight:600 }}>{title}</p>
                      <p style={{ margin:0, fontSize:11, color:subtxt }}>{desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Nav */}
      <div style={{ position:"fixed", bottom:0, left:"50%", transform:"translateX(-50%)", width:"100%", maxWidth:480,
        ...glass({ borderRadius:"20px 20px 0 0", padding:"10px 0 16px" }), display:"flex", justifyContent:"space-around" }}>
        {[
          ["home", Home, "Home"],
          ["meditate", Music2, "Meditate"],
          ["lectures", Headphones, "Lectures"],
          ["book", BookOpen, "Book"],
          ["progress", BarChart2, "Progress"],
        ].map(([key, Icon, label]) => (
          <button key={key} onClick={() => { setTab(key); setScreen("main"); }}
            style={{ background:"none", border:"none", cursor:"pointer", display:"flex", flexDirection:"column",
              alignItems:"center", gap:4, color: tab===key ? C.gold : subtxt, padding:"4px 10px" }}>
            <Icon size={20}/>
            <span style={{ fontSize:10 }}>{label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
