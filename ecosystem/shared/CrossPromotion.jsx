import { X, ExternalLink, BookOpen, Wind, Brain, Heart, Star, Share2, Users, Zap, ArrowRight, Link, BarChart2, Layers, CheckSquare, PenTool, Sun } from "lucide-react";
import { useState } from "react";

const C = {
  bg: "#0A1C14", bg2: "#122E21", accent: "#D1E0D7",
  gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
  muted: "rgba(250,250,248,0.5)", muted2: "rgba(250,250,248,0.08)",
  border: "rgba(209,224,215,0.1)", goldBorder: "rgba(197,160,89,0.2)",
};
const S = { sans: "'Manrope', sans-serif", serif: "'Cormorant Garamond', serif" };

const resonanceApps = [
  { name: "Learn", icon: <BookOpen size={18} strokeWidth={1.5} />, color: "#C5A059", active: true },
  { name: "Coach", icon: <Brain size={18} strokeWidth={1.5} />, color: "#7EB89A", active: true },
  { name: "Meditate", icon: <Wind size={18} strokeWidth={1.5} />, color: "#6BA8C4", active: true },
  { name: "Journal", icon: <PenTool size={18} strokeWidth={1.5} />, color: "#C47E9A", active: true },
  { name: "Reflect", icon: <Star size={18} strokeWidth={1.5} />, color: "#A07EC4", active: false },
  { name: "Rituals", icon: <Sun size={18} strokeWidth={1.5} />, color: "#C4A07E", active: false },
  { name: "Connect", icon: <Users size={18} strokeWidth={1.5} />, color: "#7EC4B8", active: false },
  { name: "Insights", icon: <BarChart2 size={18} strokeWidth={1.5} />, color: "#C4C47E", active: false },
];
const luminousApps = [
  { name: "Daily Flow", icon: <Zap size={18} strokeWidth={1.5} />, color: "#E6D0A1" },
  { name: "Writer", icon: <PenTool size={18} strokeWidth={1.5} />, color: "#D1A0C4" },
  { name: "To Do", icon: <CheckSquare size={18} strokeWidth={1.5} />, color: "#A0C4D1" },
];

const promos = [
  { from: "Learn", to: "Journal", icon: <PenTool size={16} strokeWidth={1.5} />, color: "#C47E9A", title: "Capture Your Insights", body: "You just finished a lesson. Reflect on what resonated in your Journal.", cta: "Open Journal" },
  { from: "Coach", to: "Meditate", icon: <Wind size={16} strokeWidth={1.5} />, color: "#6BA8C4", title: "Ground After Your Session", body: "A short meditation integrates coaching breakthroughs at a deeper level.", cta: "Meditate Now" },
  { from: "Journal", to: "Learn", icon: <BookOpen size={16} strokeWidth={1.5} />, color: "#C5A059", title: "Deepen What You Wrote", body: "Your reflection touches on shadow work. There's a course for that.", cta: "View Course" },
  { from: "Meditate", to: "Rituals", icon: <Sun size={16} strokeWidth={1.5} />, color: "#C4A07E", title: "Build Your Morning Ritual", body: "Stack your meditation into a full morning practice with Rituals.", cta: "Try Rituals" },
  { from: "Learn", to: "Daily Flow", icon: <Zap size={16} strokeWidth={1.5} />, color: "#E6D0A1", title: "Plan Around Your Growth", body: "Integrate your learning goals with Daily Flow for Luminous.", cta: "Open Daily Flow" },
];

const deepLinks = [
  { scheme: "resonance://learn/course/shadow-work", desc: "Open specific course" },
  { scheme: "resonance://coach/session/new", desc: "Start coaching session" },
  { scheme: "resonance://journal/entry/new", desc: "New journal entry" },
  { scheme: "resonance://meditate/breathing/478", desc: "Launch 4-7-8 exercise" },
  { scheme: "resonance://insights/weekly", desc: "Weekly progress view" },
];

const crossStats = [
  { label: "Total Sessions", val: "247", sub: "across all apps", icon: <Layers size={16} strokeWidth={1.5} color={C.gold} /> },
  { label: "Active Streak", val: "12d", sub: "longest: 21 days", icon: <Zap size={16} strokeWidth={1.5} color="#7EB89A" /> },
  { label: "Hours Invested", val: "38h", sub: "this month", icon: <BarChart2 size={16} strokeWidth={1.5} color="#6BA8C4" /> },
  { label: "Insights Saved", val: "64", sub: "across journal & learn", icon: <Star size={16} strokeWidth={1.5} color={C.goldLight} /> },
];

function SectionHeader({ label, title }) {
  return (
    <div style={{ marginBottom: 20 }}>
      <p style={{ fontFamily: S.sans, fontSize: 10, color: C.gold, letterSpacing: "0.1em", margin: "0 0 6px" }}>{label}</p>
      <h2 style={{ fontFamily: S.serif, fontSize: 24, color: C.cream, margin: 0, fontWeight: 400, fontStyle: "italic" }}>{title}</h2>
    </div>
  );
}

function Card({ children, style = {} }) {
  return (
    <div style={{
      background: "rgba(255,255,255,0.03)", border: `1px solid ${C.border}`,
      borderRadius: 18, padding: "20px", ...style,
    }}>{children}</div>
  );
}

function AppNetworkMap() {
  return (
    <Card style={{ marginBottom: 32 }}>
      <SectionHeader label="01 · APP NETWORK" title="Resonance Ecosystem" />
      <div style={{ marginBottom: 16 }}>
        <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: "0 0 12px", letterSpacing: "0.06em" }}>RESONANCE APPS</p>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 10 }}>
          {resonanceApps.map((app, i) => (
            <div key={i} style={{
              background: app.active ? `rgba(${app.color === "#C5A059" ? "197,160,89" : "255,255,255"},0.07)` : C.muted2,
              border: `1px solid ${app.active ? "rgba(209,224,215,0.18)" : C.border}`,
              borderRadius: 14, padding: "12px 8px", display: "flex", flexDirection: "column",
              alignItems: "center", gap: 7, cursor: "pointer", transition: "all 0.2s",
              opacity: app.active ? 1 : 0.5,
            }}>
              <div style={{ color: app.active ? app.color : C.muted }}>{app.icon}</div>
              <span style={{ fontFamily: S.sans, fontSize: 10.5, color: app.active ? C.cream : C.muted, fontWeight: app.active ? 600 : 400 }}>{app.name}</span>
              {app.active && <div style={{ width: 5, height: 5, borderRadius: "50%", background: app.color }} />}
            </div>
          ))}
        </div>
      </div>
      <div style={{ borderTop: `1px solid ${C.border}`, paddingTop: 14 }}>
        <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: "0 0 12px", letterSpacing: "0.06em" }}>LUMINOUS APPS</p>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 10 }}>
          {luminousApps.map((app, i) => (
            <div key={i} style={{
              background: "rgba(230,208,161,0.06)", border: `1px solid ${C.goldBorder}`,
              borderRadius: 14, padding: "12px 8px", display: "flex", flexDirection: "column",
              alignItems: "center", gap: 7,
            }}>
              <div style={{ color: app.color }}>{app.icon}</div>
              <span style={{ fontFamily: S.sans, fontSize: 10.5, color: C.cream }}>{app.name}</span>
              <div style={{ width: 5, height: 5, borderRadius: "50%", background: C.gold, opacity: 0.6 }} />
            </div>
          ))}
        </div>
      </div>
    </Card>
  );
}

function SmartPromoCards() {
  const [dismissed, setDismissed] = useState([]);
  const visible = promos.filter((_, i) => !dismissed.includes(i));
  return (
    <Card style={{ marginBottom: 32 }}>
      <SectionHeader label="02 · SMART PROMOTIONS" title="Contextual Nudges" />
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {visible.length === 0 && (
          <div style={{ textAlign: "center", padding: "24px 0" }}>
            <p style={{ fontFamily: S.sans, fontSize: 13, color: C.muted }}>All promotions dismissed.</p>
          </div>
        )}
        {promos.map((p, i) => dismissed.includes(i) ? null : (
          <div key={i} style={{
            background: "rgba(255,255,255,0.03)", border: `1px solid rgba(209,224,215,0.12)`,
            borderRadius: 14, padding: "14px 16px", display: "flex", alignItems: "center", gap: 14,
            borderLeft: `3px solid ${p.color}`,
          }}>
            <div style={{ width: 38, height: 38, borderRadius: 12, background: `${p.color}18`, display: "flex", alignItems: "center", justifyContent: "center", color: p.color, flexShrink: 0 }}>
              {p.icon}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 3 }}>
                <span style={{ fontFamily: S.sans, fontSize: 10, color: C.muted, letterSpacing: "0.05em" }}>After {p.from}</span>
                <ArrowRight size={10} color={C.muted} />
                <span style={{ fontFamily: S.sans, fontSize: 10, color: p.color, letterSpacing: "0.05em" }}>{p.to}</span>
              </div>
              <p style={{ fontFamily: S.sans, fontSize: 12.5, color: C.cream, margin: "0 0 3px", fontWeight: 600 }}>{p.title}</p>
              <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: 0, lineHeight: 1.4 }}>{p.body}</p>
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 8, alignItems: "flex-end", flexShrink: 0 }}>
              <button onClick={() => setDismissed(d => [...d, i])} style={{ background: "none", border: "none", cursor: "pointer", padding: 0, color: C.muted }}>
                <X size={14} />
              </button>
              <button style={{
                background: `${p.color}18`, border: `1px solid ${p.color}40`,
                borderRadius: 20, padding: "5px 12px", fontFamily: S.sans, fontSize: 10.5,
                color: p.color, cursor: "pointer", whiteSpace: "nowrap", letterSpacing: "0.03em",
              }}>{p.cta}</button>
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}

function DeepLinks() {
  const [copied, setCopied] = useState(null);
  return (
    <Card style={{ marginBottom: 32 }}>
      <SectionHeader label="03 · DEEP LINKS" title="URL Scheme" />
      <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
        {deepLinks.map((dl, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, background: C.muted2, borderRadius: 12, padding: "10px 14px", cursor: "pointer" }}
            onClick={() => { setCopied(i); setTimeout(() => setCopied(null), 1500); }}>
            <Link size={13} color={C.gold} strokeWidth={1.5} style={{ flexShrink: 0 }} />
            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{ fontFamily: "'SF Mono', 'Fira Code', monospace", fontSize: 11.5, color: C.goldLight, margin: "0 0 2px", wordBreak: "break-all" }}>{dl.scheme}</p>
              <p style={{ fontFamily: S.sans, fontSize: 10.5, color: C.muted, margin: 0 }}>{dl.desc}</p>
            </div>
            <span style={{ fontFamily: S.sans, fontSize: 10, color: copied === i ? "#7EB89A" : C.muted, flexShrink: 0 }}>
              {copied === i ? "Copied!" : "Copy"}
            </span>
          </div>
        ))}
      </div>
    </Card>
  );
}

function UnifiedProgress() {
  return (
    <Card style={{ marginBottom: 32 }}>
      <SectionHeader label="04 · UNIFIED PROGRESS" title="Cross-App Dashboard" />
      <div style={{ display: "grid", gridTemplateColumns: "repeat(2, 1fr)", gap: 12 }}>
        {crossStats.map((s, i) => (
          <div key={i} style={{
            background: "rgba(255,255,255,0.04)", borderRadius: 14, padding: "16px",
            border: `1px solid ${C.border}`,
            backdropFilter: "blur(8px)",
          }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
              {s.icon}
              <span style={{ fontFamily: S.sans, fontSize: 10.5, color: C.muted, letterSpacing: "0.04em" }}>{s.label}</span>
            </div>
            <p style={{ fontFamily: S.sans, fontSize: 28, fontWeight: 700, color: C.cream, margin: "0 0 3px", lineHeight: 1 }}>{s.val}</p>
            <p style={{ fontFamily: S.sans, fontSize: 10.5, color: C.muted, margin: 0 }}>{s.sub}</p>
          </div>
        ))}
      </div>
      <div style={{ marginTop: 14, background: "rgba(197,160,89,0.06)", borderRadius: 14, padding: "14px 16px", border: `1px solid ${C.goldBorder}` }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 8 }}>
          <span style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, letterSpacing: "0.06em" }}>OVERALL GROWTH SCORE</span>
          <span style={{ fontFamily: S.sans, fontSize: 18, fontWeight: 700, color: C.cream }}>84</span>
        </div>
        <div style={{ height: 6, background: "rgba(255,255,255,0.07)", borderRadius: 3, overflow: "hidden" }}>
          <div style={{ height: "100%", width: "84%", background: `linear-gradient(90deg, ${C.bg2}, ${C.gold})`, borderRadius: 3 }} />
        </div>
      </div>
    </Card>
  );
}

function LuminousNetwork() {
  return (
    <Card style={{ marginBottom: 32 }}>
      <SectionHeader label="05 · LUMINOUS NETWORK" title="More from Luminous" />
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {luminousApps.map((app, i) => (
          <div key={i} style={{
            display: "flex", alignItems: "center", gap: 14, padding: "14px 16px",
            background: "rgba(230,208,161,0.05)", border: `1px solid ${C.goldBorder}`,
            borderRadius: 14, cursor: "pointer",
          }}>
            <div style={{ width: 44, height: 44, borderRadius: 13, background: `${app.color}18`, border: `1px solid ${app.color}30`, display: "flex", alignItems: "center", justifyContent: "center", color: app.color }}>
              {app.icon}
            </div>
            <div style={{ flex: 1 }}>
              <p style={{ fontFamily: S.sans, fontSize: 13, color: C.cream, margin: "0 0 3px", fontWeight: 600 }}>{app.name}</p>
              <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: 0 }}>By Luminous · Free with Premium</p>
            </div>
            <ExternalLink size={15} color={C.gold} strokeWidth={1.5} />
          </div>
        ))}
      </div>
    </Card>
  );
}

function SharingHub() {
  const templates = [
    { label: "Share Quote", icon: <BookOpen size={14} strokeWidth={1.5} />, preview: '"The cave you fear…" — J. Campbell | Resonance' },
    { label: "Share Milestone", icon: <Star size={14} strokeWidth={1.5} />, preview: "12-day streak on Resonance! Growing every day." },
    { label: "Invite Friend", icon: <Users size={14} strokeWidth={1.5} />, preview: "Join me on Resonance — link inside" },
  ];
  return (
    <Card>
      <SectionHeader label="06 · SHARING HUB" title="Share & Invite" />
      <div style={{ display: "flex", flexDirection: "column", gap: 10, marginBottom: 16 }}>
        {templates.map((t, i) => (
          <div key={i} style={{ background: C.muted2, borderRadius: 14, padding: "14px 16px", border: `1px solid ${C.border}` }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 7 }}>
              <span style={{ color: C.gold }}>{t.icon}</span>
              <span style={{ fontFamily: S.sans, fontSize: 11.5, color: C.cream, fontWeight: 600 }}>{t.label}</span>
            </div>
            <p style={{ fontFamily: S.sans, fontSize: 11, color: C.muted, margin: "0 0 10px", lineHeight: 1.4 }}>{t.preview}</p>
            <div style={{ display: "flex", gap: 8 }}>
              {["Messages", "Instagram", "Copy Link"].map((ch, j) => (
                <button key={j} style={{
                  background: j === 0 ? `rgba(197,160,89,0.12)` : C.muted2,
                  border: `1px solid ${j === 0 ? C.goldBorder : C.border}`,
                  borderRadius: 20, padding: "5px 12px", fontFamily: S.sans, fontSize: 10.5,
                  color: j === 0 ? C.gold : C.muted, cursor: "pointer", letterSpacing: "0.03em",
                }}>{ch}</button>
              ))}
            </div>
          </div>
        ))}
      </div>
      <div style={{ background: `linear-gradient(135deg, rgba(197,160,89,0.1), rgba(197,160,89,0.03))`, borderRadius: 16, padding: "18px 20px", border: `1px solid ${C.goldBorder}`, display: "flex", alignItems: "center", gap: 16 }}>
        <div style={{ flex: 1 }}>
          <p style={{ fontFamily: S.serif, fontSize: 17, color: C.cream, margin: "0 0 4px", fontStyle: "italic" }}>Invite a Friend</p>
          <p style={{ fontFamily: S.sans, fontSize: 11.5, color: C.muted, margin: "0 0 12px", lineHeight: 1.4 }}>Give them 30 days free. You get an extra month of Premium.</p>
          <button style={{
            background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`, border: "none",
            borderRadius: 22, padding: "9px 22px", fontFamily: S.sans, fontSize: 12,
            color: C.bg, cursor: "pointer", fontWeight: 700, letterSpacing: "0.04em", display: "flex", alignItems: "center", gap: 6,
          }}>
            <Share2 size={13} strokeWidth={2} /> Send Invite
          </button>
        </div>
        <div style={{ width: 60, height: 60, borderRadius: "50%", background: "rgba(197,160,89,0.15)", border: `1.5px solid ${C.goldBorder}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Users size={24} color={C.gold} strokeWidth={1.5} />
        </div>
      </div>
    </Card>
  );
}

export default function CrossPromotion() {
  return (
    <div style={{ minHeight: "100vh", background: "#080F0A", padding: "48px 32px", fontFamily: S.sans }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Manrope:wght@300;400;500;600;700&family=Cormorant+Garamond:ital,wght@0,400;0,500;1,400;1,500&display=swap');
        * { box-sizing: border-box; }
        button { transition: opacity 0.15s; }
        button:hover { opacity: 0.8; }
      `}</style>

      <div style={{ maxWidth: 680, margin: "0 auto" }}>
        <div style={{ marginBottom: 48, textAlign: "center" }}>
          <p style={{ fontFamily: S.sans, fontSize: 11, color: C.gold, letterSpacing: "0.12em", margin: "0 0 8px" }}>LUMINOUS · RESONANCE</p>
          <h1 style={{ fontFamily: S.serif, fontSize: 38, color: C.cream, margin: "0 0 8px", fontWeight: 400, fontStyle: "italic" }}>Cross-Promotion Engine</h1>
          <p style={{ fontFamily: S.sans, fontSize: 13, color: C.muted, margin: 0 }}>Ecosystem connectivity & intelligent promotion</p>
        </div>

        <AppNetworkMap />
        <SmartPromoCards />
        <DeepLinks />
        <UnifiedProgress />
        <LuminousNetwork />
        <SharingHub />
      </div>
    </div>
  );
}
