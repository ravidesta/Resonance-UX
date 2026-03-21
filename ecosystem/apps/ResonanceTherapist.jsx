import { useState, useEffect, useRef } from "react";
import {
  Calendar, Users, FileText, BookOpen, ClipboardList, Brain,
  Sun, Moon, Plus, Clock, AlertCircle, CheckCircle, ChevronRight,
  Play, Pause, RotateCcw, Send, Star, ArrowLeft, Shield
} from "lucide-react";

const C = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", forest: "#1B402E",
  mist: "#D1E0D7", gold: "#C5A059", cream: "#E6D0A1", white: "#FAFAF8",
  amber: "#D97706", red: "#DC2626", green: "#16A34A",
};

const clients = [
  { id: 1, code: "Client A", sessions: 18, focus: ["Anxiety", "Self-worth"], last: "Mar 18", risk: "low", age: 34, notes: 3 },
  { id: 2, code: "Client B", sessions: 7,  focus: ["Grief", "Identity"],     last: "Mar 19", risk: "amber", age: 28, notes: 1 },
  { id: 3, code: "Client C", sessions: 31, focus: ["Trauma", "Attachment"],  last: "Mar 17", risk: "low", age: 41, notes: 5 },
  { id: 4, code: "Client D", sessions: 4,  focus: ["Depression", "Ego dev"], last: "Mar 20", risk: "amber", age: 52, notes: 0 },
  { id: 5, code: "Client E", sessions: 12, focus: ["Boundaries", "Parts"],   last: "Mar 15", risk: "low", age: 37, notes: 2 },
];

const schedule = [
  { time: "9:00 AM",  client: "Client C", type: "Individual", duration: "50 min" },
  { time: "11:00 AM", client: "Client A", type: "Individual", duration: "50 min" },
  { time: "2:30 PM",  client: "Client E", type: "Individual", duration: "50 min" },
];

const interventions = ["CBT", "DBT", "IFS", "EMDR", "Somatic", "Attachment"];

const resources = [
  { title: "Values Clarification Worksheet",    type: "Worksheet",       tag: "ACT" },
  { title: "Window of Tolerance Diagram",        type: "Psychoeducation", tag: "Trauma" },
  { title: "Parts Mapping Exercise",             type: "Worksheet",       tag: "IFS" },
  { title: "Distress Tolerance Skills",          type: "Psychoeducation", tag: "DBT" },
  { title: "Resonance Grounding Meditation",     type: "Meditation",      tag: "Somatic" },
  { title: "Evening Reflection Journal Prompt",  type: "Journal",         tag: "Ego Dev" },
];

const phq9 = [
  "Little interest or pleasure in doing things",
  "Feeling down, hopeless, or depressed",
  "Trouble falling or staying asleep",
  "Feeling tired or having little energy",
  "Poor appetite or overeating",
];

const gad7 = [
  "Feeling nervous, anxious, or on edge",
  "Not being able to stop or control worrying",
  "Worrying too much about different things",
  "Trouble relaxing",
  "Being so restless it's hard to sit still",
];

const knowledgeQs = [
  "What distinguishes Conventional from Post-conventional ego stages?",
  "How does IFS relate to Luminous Ego Development?",
  "Somatic indicators of early developmental arrest",
  "Integrating EMDR with attachment-focused therapy",
];

const sampleAnswer = `Developmental trauma differs from single-incident trauma in its pervasive, relational nature. It occurs within the early caregiving system, disrupting the formation of secure attachment, self-regulation capacity, and coherent identity.

**Key clinical markers include:**
- Diffuse affect dysregulation rather than discrete trauma triggers
- Chronic shame vs. episodic fear responses
- Fragmented autobiographical memory and narrative discontinuity
- Relational schemas organized around threat and unpredictability

**Ego development implications:** Clients with developmental trauma often present at Loevinger's Self-Protective or Conformist stages, with limited access to autonomous functioning. Growth edges lie in building observer capacity, tolerating ambiguity, and integrating disowned parts.

**Integrative approach:** Somatic resourcing + IFS parts work + relational attunement provides the corrective experience needed before cognitive reprocessing is productive.`;

export default function ResonanceTherapist() {
  const [dark, setDark] = useState(true);
  const [tab, setTab] = useState("dashboard");
  const [selectedClient, setSelectedClient] = useState(null);
  const [soap, setSoap] = useState({ S: "", O: "", A: "", P: "" });
  const [activeInterventions, setActiveInterventions] = useState([]);
  const [timerRunning, setTimerRunning] = useState(false);
  const [timerSec, setTimerSec] = useState(0);
  const [mood, setMood] = useState(null);
  const [kbQuery, setKbQuery] = useState("");
  const [kbAnswer, setKbAnswer] = useState(false);
  const [phqAnswers, setPhqAnswers] = useState({});
  const [gadAnswers, setGadAnswers] = useState({});
  const timerRef = useRef(null);

  const bg = dark ? C.night : C.white;
  const surface = dark ? C.dark : "#F0F4F2";
  const card = dark ? C.mid : "#FFFFFF";
  const border = dark ? C.forest : "#C8D9D0";
  const text = dark ? C.white : C.dark;
  const sub = dark ? C.mist : "#4A6B5A";

  useEffect(() => {
    if (timerRunning) {
      timerRef.current = setInterval(() => setTimerSec(s => s + 1), 1000);
    } else {
      clearInterval(timerRef.current);
    }
    return () => clearInterval(timerRef.current);
  }, [timerRunning]);

  const fmt = s => `${String(Math.floor(s/60)).padStart(2,"0")}:${String(s%60).padStart(2,"0")}`;

  const glass = {
    background: dark ? "rgba(18,46,33,0.6)" : "rgba(255,255,255,0.7)",
    backdropFilter: "blur(16px)",
    border: `1px solid ${dark ? "rgba(197,160,89,0.2)" : "rgba(197,160,89,0.3)"}`,
    borderRadius: 16,
  };

  const goldBtn = {
    background: `linear-gradient(135deg, ${C.gold}, ${C.cream})`,
    color: C.dark, border: "none", borderRadius: 10,
    padding: "10px 18px", fontFamily: "Manrope, sans-serif",
    fontWeight: 700, fontSize: 13, cursor: "pointer",
  };

  const outlineBtn = {
    background: "transparent", border: `1px solid ${C.gold}`,
    color: C.gold, borderRadius: 10, padding: "8px 14px",
    fontFamily: "Manrope, sans-serif", fontWeight: 600, fontSize: 12, cursor: "pointer",
  };

  const inputStyle = {
    width: "100%", background: dark ? "rgba(5,16,11,0.6)" : "#F5F8F6",
    border: `1px solid ${border}`, borderRadius: 10, padding: "10px 14px",
    color: text, fontFamily: "Manrope, sans-serif", fontSize: 13,
    resize: "vertical", outline: "none", boxSizing: "border-box",
  };

  const cardStyle = { ...glass, padding: 20, marginBottom: 14 };

  const heading = { fontFamily: "Cormorant Garamond, Georgia, serif", color: text };
  const body = { fontFamily: "Manrope, sans-serif", color: text };

  const phqScore = Object.values(phqAnswers).reduce((a,b) => a+b, 0);
  const gadScore = Object.values(gadAnswers).reduce((a,b) => a+b, 0);

  const toggleIntervention = i =>
    setActiveInterventions(prev => prev.includes(i) ? prev.filter(x=>x!==i) : [...prev, i]);

  // --- Screens ---

  const Dashboard = () => (
    <div>
      <div style={{ ...cardStyle, background: `linear-gradient(135deg, ${C.forest}, ${C.mid})`, border: `1px solid ${C.gold}44` }}>
        <p style={{ ...body, fontSize: 12, color: C.cream, marginBottom: 4 }}>Saturday, March 21</p>
        <h2 style={{ ...heading, fontSize: 26, margin: "0 0 4px" }}>Good morning, Dr. Rivera</h2>
        <p style={{ ...body, fontSize: 13, color: C.mist, margin: 0 }}>3 sessions · 6 pending notes · 5 active clients</p>
      </div>

      <div style={{ ...cardStyle }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 14 }}>
          <Calendar size={16} color={C.gold} />
          <h3 style={{ ...heading, fontSize: 18, margin: 0 }}>Today's Schedule</h3>
        </div>
        {schedule.map((s, i) => (
          <div key={i} style={{ display: "flex", alignItems: "center", justifyContent: "space-between",
            padding: "12px 0", borderBottom: i < 2 ? `1px solid ${border}` : "none" }}>
            <div>
              <p style={{ ...body, fontWeight: 700, fontSize: 14, margin: 0 }}>{s.client}</p>
              <p style={{ ...body, fontSize: 12, color: sub, margin: "2px 0 0" }}>{s.type} · {s.duration}</p>
            </div>
            <div style={{ textAlign: "right" }}>
              <p style={{ ...body, fontSize: 13, color: C.gold, fontWeight: 700, margin: 0 }}>{s.time}</p>
            </div>
          </div>
        ))}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10, marginBottom: 14 }}>
        {[["New Session", Play], ["Add Client", Plus], ["Resources", BookOpen]].map(([label, Icon], i) => (
          <button key={i} style={{ ...goldBtn, display: "flex", flexDirection: "column", alignItems: "center",
            gap: 6, padding: "14px 8px", borderRadius: 12 }} onClick={() => i===2 && setTab("resources")}>
            <Icon size={18} />
            <span style={{ fontSize: 11 }}>{label}</span>
          </button>
        ))}
      </div>

      <div style={{ ...cardStyle, border: `1px solid ${C.amber}44`, background: dark ? "rgba(217,119,6,0.1)" : "#FFF8ED" }}>
        <div style={{ display: "flex", gap: 8, alignItems: "flex-start" }}>
          <Shield size={16} color={C.amber} style={{ marginTop: 2, flexShrink: 0 }} />
          <p style={{ ...body, fontSize: 12, color: C.amber, margin: 0, lineHeight: 1.6 }}>
            <strong>HIPAA Notice:</strong> This app is a prototype. All client data must be stored in your HIPAA-compliant EHR. Do not enter identifying information.
          </p>
        </div>
      </div>
    </div>
  );

  const Clients = () => selectedClient ? (
    <div>
      <button onClick={() => setSelectedClient(null)} style={{ ...outlineBtn, display: "flex", alignItems: "center", gap: 6, marginBottom: 16 }}>
        <ArrowLeft size={14} /> Back
      </button>
      <div style={cardStyle}>
        <h2 style={{ ...heading, fontSize: 24, margin: "0 0 4px" }}>{selectedClient.code}</h2>
        <p style={{ ...body, fontSize: 13, color: sub, margin: "0 0 16px" }}>Age {selectedClient.age} · {selectedClient.sessions} sessions</p>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginBottom: 16 }}>
          {selectedClient.focus.map(f => (
            <span key={f} style={{ background: `${C.gold}22`, color: C.gold, borderRadius: 20,
              padding: "4px 12px", fontSize: 12, fontFamily: "Manrope, sans-serif", fontWeight: 600 }}>{f}</span>
          ))}
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
          {[["Last Session", selectedClient.last], ["Pending Notes", selectedClient.notes], ["Risk Level", selectedClient.risk === "low" ? "Low" : "Monitor"], ["Total Sessions", selectedClient.sessions]].map(([k,v]) => (
            <div key={k} style={{ background: dark ? "rgba(5,16,11,0.5)" : "#F5F8F6", borderRadius: 10, padding: 12 }}>
              <p style={{ ...body, fontSize: 11, color: sub, margin: "0 0 2px" }}>{k}</p>
              <p style={{ ...body, fontSize: 15, fontWeight: 700, margin: 0 }}>{v}</p>
            </div>
          ))}
        </div>
      </div>
      <div style={cardStyle}>
        <h3 style={{ ...heading, fontSize: 18, margin: "0 0 12px" }}>Session History</h3>
        {["Mar 18 — Explored early attachment patterns via IFS", "Mar 11 — EMDR resourcing; installed safe place", "Mar 4 — Psychoeducation: ego stages and self-identity"].map((note, i) => (
          <div key={i} style={{ padding: "10px 0", borderBottom: i < 2 ? `1px solid ${border}` : "none" }}>
            <p style={{ ...body, fontSize: 13, margin: 0 }}>{note}</p>
          </div>
        ))}
      </div>
    </div>
  ) : (
    <div>
      <h2 style={{ ...heading, fontSize: 24, marginBottom: 16 }}>Clients</h2>
      {clients.map(c => (
        <div key={c.id} style={{ ...cardStyle, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "space-between" }}
          onClick={() => setSelectedClient(c)}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 10, height: 10, borderRadius: "50%", flexShrink: 0,
              background: c.risk === "low" ? C.green : C.amber }} />
            <div>
              <p style={{ ...body, fontWeight: 700, fontSize: 14, margin: 0 }}>{c.code}</p>
              <p style={{ ...body, fontSize: 12, color: sub, margin: "2px 0 0" }}>{c.focus.join(", ")} · Last: {c.last}</p>
            </div>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <span style={{ ...body, fontSize: 12, color: C.gold, fontWeight: 700 }}>{c.sessions}×</span>
            <ChevronRight size={16} color={sub} />
          </div>
        </div>
      ))}
    </div>
  );

  const SessionTools = () => (
    <div>
      <h2 style={{ ...heading, fontSize: 24, marginBottom: 16 }}>Session Tools</h2>

      <div style={cardStyle}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <Clock size={16} color={C.gold} />
            <h3 style={{ ...heading, fontSize: 18, margin: 0 }}>Session Timer</h3>
          </div>
          <span style={{ ...body, fontSize: 28, fontWeight: 800, color: C.gold, fontVariantNumeric: "tabular-nums" }}>{fmt(timerSec)}</span>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button style={goldBtn} onClick={() => setTimerRunning(r => !r)}>
            {timerRunning ? <Pause size={14} /> : <Play size={14} />}
          </button>
          <button style={outlineBtn} onClick={() => { setTimerRunning(false); setTimerSec(0); }}>
            <RotateCcw size={14} />
          </button>
        </div>
      </div>

      <div style={cardStyle}>
        <h3 style={{ ...heading, fontSize: 18, margin: "0 0 12px" }}>Interventions Used</h3>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
          {interventions.map(iv => (
            <button key={iv} onClick={() => toggleIntervention(iv)} style={{
              ...body, fontSize: 12, fontWeight: 600, borderRadius: 20, padding: "6px 14px", cursor: "pointer",
              background: activeInterventions.includes(iv) ? C.gold : "transparent",
              color: activeInterventions.includes(iv) ? C.dark : C.gold,
              border: `1px solid ${C.gold}`,
            }}>{iv}</button>
          ))}
        </div>
      </div>

      <div style={cardStyle}>
        <h3 style={{ ...heading, fontSize: 18, margin: "0 0 12px" }}>Mood Observation</h3>
        <div style={{ display: "flex", gap: 10 }}>
          {["😞","😐","🙂","😊","✨"].map((e,i) => (
            <button key={i} onClick={() => setMood(i)} style={{
              fontSize: 22, background: mood === i ? `${C.gold}33` : "transparent",
              border: `2px solid ${mood === i ? C.gold : "transparent"}`,
              borderRadius: 10, padding: "6px 10px", cursor: "pointer",
            }}>{e}</button>
          ))}
        </div>
      </div>

      <div style={cardStyle}>
        <h3 style={{ ...heading, fontSize: 18, margin: "0 0 14px" }}>SOAP Note</h3>
        {["S","O","A","P"].map(field => (
          <div key={field} style={{ marginBottom: 12 }}>
            <label style={{ ...body, fontSize: 11, fontWeight: 700, color: C.gold, display: "block", marginBottom: 4 }}>
              {field} — {field==="S"?"Subjective":field==="O"?"Objective":field==="A"?"Assessment":"Plan"}
            </label>
            <textarea rows={2} value={soap[field]} onChange={e => setSoap(s => ({...s,[field]:e.target.value}))}
              placeholder={`Enter ${field==="S"?"client's reported experience":field==="O"?"observable data":field==="A"?"clinical assessment":"treatment plan"}...`}
              style={inputStyle} />
          </div>
        ))}
        <button style={goldBtn}>Save Note</button>
      </div>
    </div>
  );

  const Resources = () => (
    <div>
      <h2 style={{ ...heading, fontSize: 24, marginBottom: 16 }}>Resource Library</h2>
      {resources.map((r, i) => (
        <div key={i} style={cardStyle}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 10 }}>
            <div>
              <p style={{ ...body, fontWeight: 700, fontSize: 14, margin: "0 0 4px" }}>{r.title}</p>
              <div style={{ display: "flex", gap: 6 }}>
                <span style={{ background: `${C.forest}`, color: C.mist, borderRadius: 6, padding: "2px 8px", fontSize: 11, fontFamily: "Manrope, sans-serif" }}>{r.type}</span>
                <span style={{ background: `${C.gold}22`, color: C.gold, borderRadius: 6, padding: "2px 8px", fontSize: 11, fontFamily: "Manrope, sans-serif" }}>{r.tag}</span>
              </div>
            </div>
          </div>
          <div style={{ display: "flex", gap: 8 }}>
            <button style={goldBtn}>Assign to Client</button>
            {(r.type === "Meditation" || r.type === "Journal") && (
              <button style={{ ...outlineBtn, fontSize: 11 }}>
                {r.type === "Meditation" ? "Open in Resonance Meditate" : "Open in Resonance Journal"}
              </button>
            )}
          </div>
        </div>
      ))}
    </div>
  );

  const Assessments = () => (
    <div>
      <h2 style={{ ...heading, fontSize: 24, marginBottom: 16 }}>Clinical Assessments</h2>

      {[{ title: "PHQ-9", subtitle: "Patient Health Questionnaire", items: phq9, answers: phqAnswers, setAnswers: setPhqAnswers, score: phqScore, max: 27, low: 5, high: 15 },
        { title: "GAD-7", subtitle: "Generalized Anxiety Disorder Scale", items: gad7, answers: gadAnswers, setAnswers: setGadAnswers, score: gadScore, max: 21, low: 5, high: 10 }
      ].map(({ title, subtitle, items, answers, setAnswers, score, max, low, high }) => (
        <div key={title} style={cardStyle}>
          <h3 style={{ ...heading, fontSize: 20, margin: "0 0 2px" }}>{title}</h3>
          <p style={{ ...body, fontSize: 12, color: sub, margin: "0 0 14px" }}>{subtitle}</p>
          {items.map((q, i) => (
            <div key={i} style={{ marginBottom: 14 }}>
              <p style={{ ...body, fontSize: 13, margin: "0 0 6px" }}>{i+1}. {q}</p>
              <div style={{ display: "flex", gap: 6 }}>
                {["Not at all","Several days","More than half","Nearly every day"].map((label, v) => (
                  <button key={v} onClick={() => setAnswers(a => ({...a,[i]:v}))} style={{
                    flex: 1, padding: "6px 4px", borderRadius: 8, cursor: "pointer", fontSize: 10,
                    fontFamily: "Manrope, sans-serif", fontWeight: 600,
                    background: answers[i] === v ? C.gold : "transparent",
                    color: answers[i] === v ? C.dark : sub,
                    border: `1px solid ${answers[i] === v ? C.gold : border}`,
                  }}>{v}</button>
                ))}
              </div>
            </div>
          ))}
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between",
            background: dark ? "rgba(5,16,11,0.5)" : "#F5F8F6", borderRadius: 10, padding: 12 }}>
            <span style={{ ...body, fontSize: 13, fontWeight: 700 }}>Score: {score}/{max}</span>
            <span style={{ ...body, fontSize: 12, color: score < low ? C.green : score < high ? C.amber : C.red, fontWeight: 700 }}>
              {score < low ? "Minimal" : score < high ? "Moderate" : "Severe"}
            </span>
          </div>
        </div>
      ))}
    </div>
  );

  const KnowledgeBase = () => (
    <div>
      <h2 style={{ ...heading, fontSize: 24, marginBottom: 6 }}>Knowledge Base</h2>
      <p style={{ ...body, fontSize: 13, color: sub, marginBottom: 16 }}>Ask anything about clinical practice</p>

      <div style={cardStyle}>
        <div style={{ display: "flex", gap: 8 }}>
          <input value={kbQuery} onChange={e => setKbQuery(e.target.value)}
            placeholder="e.g. How do I work with developmental trauma?"
            style={{ ...inputStyle, borderRadius: 10 }} />
          <button style={{ ...goldBtn, flexShrink: 0 }} onClick={() => kbQuery && setKbAnswer(true)}>
            <Send size={14} />
          </button>
        </div>
      </div>

      {!kbAnswer && (
        <div style={cardStyle}>
          <h3 style={{ ...heading, fontSize: 16, margin: "0 0 12px" }}>Suggested Questions</h3>
          {knowledgeQs.map((q, i) => (
            <button key={i} onClick={() => { setKbQuery(q); setKbAnswer(true); }} style={{
              display: "flex", alignItems: "center", justifyContent: "space-between",
              width: "100%", textAlign: "left", background: "transparent", border: "none",
              borderBottom: i < 3 ? `1px solid ${border}` : "none",
              padding: "10px 0", cursor: "pointer",
            }}>
              <span style={{ ...body, fontSize: 13, color: text }}>{q}</span>
              <ChevronRight size={14} color={C.gold} style={{ flexShrink: 0 }} />
            </button>
          ))}
        </div>
      )}

      {kbAnswer && (
        <div style={cardStyle}>
          <div style={{ display: "flex", gap: 8, alignItems: "flex-start", marginBottom: 12 }}>
            <Brain size={16} color={C.gold} style={{ marginTop: 2, flexShrink: 0 }} />
            <p style={{ ...body, fontSize: 12, color: C.gold, fontWeight: 700, margin: 0 }}>Clinical Insight</p>
          </div>
          <p style={{ ...body, fontSize: 12, color: sub, marginBottom: 12, fontStyle: "italic" }}>Re: {kbQuery || "Developmental Trauma in Clinical Practice"}</p>
          {sampleAnswer.split("\n\n").map((block, i) => (
            <p key={i} style={{ ...body, fontSize: 13, lineHeight: 1.7, margin: "0 0 12px",
              color: block.startsWith("**") ? text : sub,
              fontWeight: block.startsWith("**") ? 700 : 400,
            }}>{block.replace(/\*\*/g, "")}</p>
          ))}
          <div style={{ display: "flex", gap: 8, marginTop: 4 }}>
            <button style={goldBtn}>Save to Notes</button>
            <button style={outlineBtn} onClick={() => { setKbAnswer(false); setKbQuery(""); }}>New Question</button>
          </div>
        </div>
      )}
    </div>
  );

  const tabs = [
    { id: "dashboard", label: "Home",       Icon: Star },
    { id: "clients",   label: "Clients",    Icon: Users },
    { id: "session",   label: "Session",    Icon: FileText },
    { id: "resources", label: "Resources",  Icon: BookOpen },
    { id: "assess",    label: "Assess",     Icon: ClipboardList },
    { id: "kb",        label: "Knowledge",  Icon: Brain },
  ];

  const screens = { dashboard: Dashboard, clients: Clients, session: SessionTools, resources: Resources, assess: Assessments, kb: KnowledgeBase };
  const Screen = screens[tab];

  return (
    <div style={{ minHeight: "100vh", background: bg, fontFamily: "Manrope, sans-serif", position: "relative", overflow: "hidden" }}>
      {/* Blob background */}
      <div style={{ position: "fixed", top: -120, right: -80, width: 340, height: 340, borderRadius: "50%",
        background: `radial-gradient(circle, ${C.forest}88 0%, transparent 70%)`, pointerEvents: "none", zIndex: 0 }} />
      <div style={{ position: "fixed", bottom: -100, left: -60, width: 280, height: 280, borderRadius: "50%",
        background: `radial-gradient(circle, ${C.gold}18 0%, transparent 70%)`, pointerEvents: "none", zIndex: 0 }} />

      {/* Header */}
      <div style={{ position: "sticky", top: 0, zIndex: 50, ...glass, borderRadius: 0,
        borderBottom: `1px solid ${border}`, padding: "12px 20px",
        display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div>
          <h1 style={{ ...heading, fontSize: 18, margin: 0, letterSpacing: 0.3 }}>Resonance<span style={{ color: C.gold }}> Therapist</span></h1>
          <p style={{ ...body, fontSize: 10, color: sub, margin: 0 }}>Luminous Ego Development</p>
        </div>
        <button onClick={() => setDark(d => !d)} style={{ background: "transparent", border: `1px solid ${border}`,
          borderRadius: 20, padding: "6px 12px", cursor: "pointer", display: "flex", alignItems: "center", gap: 6 }}>
          {dark ? <Sun size={14} color={C.gold} /> : <Moon size={14} color={C.mid} />}
          <span style={{ ...body, fontSize: 12, color: dark ? C.gold : C.mid }}>{dark ? "Light" : "Dark"}</span>
        </button>
      </div>

      {/* Content */}
      <div style={{ maxWidth: 480, margin: "0 auto", padding: "20px 16px 100px", position: "relative", zIndex: 1 }}>
        <Screen />
      </div>

      {/* Bottom nav */}
      <div style={{ position: "fixed", bottom: 0, left: 0, right: 0, zIndex: 50, ...glass,
        borderRadius: "20px 20px 0 0", borderTop: `1px solid ${border}`, padding: "10px 4px 14px" }}>
        <div style={{ display: "flex", justifyContent: "space-around", maxWidth: 480, margin: "0 auto" }}>
          {tabs.map(({ id, label, Icon }) => (
            <button key={id} onClick={() => { setTab(id); setSelectedClient(null); }} style={{
              background: "transparent", border: "none", cursor: "pointer",
              display: "flex", flexDirection: "column", alignItems: "center", gap: 3, padding: "4px 8px",
            }}>
              <Icon size={20} color={tab === id ? C.gold : sub} strokeWidth={tab === id ? 2.5 : 1.5} />
              <span style={{ fontFamily: "Manrope, sans-serif", fontSize: 9, fontWeight: tab===id ? 700 : 500,
                color: tab === id ? C.gold : sub }}>{label}</span>
            </button>
          ))}
        </div>
      </div>

      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;600;700&family=Manrope:wght@400;500;600;700;800&display=swap');
        * { box-sizing: border-box; }
        textarea:focus, input:focus { outline: 1px solid ${C.gold} !important; }
        ::-webkit-scrollbar { width: 4px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: ${C.forest}; border-radius: 2px; }
      `}</style>
    </div>
  );
}
