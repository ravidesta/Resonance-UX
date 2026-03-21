import { useState } from "react";
import {
  Home, BookOpen, BookMarked, ClipboardList, Quote,
  Play, CheckCircle, Circle, ChevronDown, ChevronUp,
  Search, Star, Flame, Sun, Moon, ArrowLeft, Lock
} from "lucide-react";

const COLORS = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", forest: "#1B402E",
  sage: "#D1E0D7", gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
};

const COURSES = [
  { id: 1, title: "Foundations of Ego Development", lessons: 7, duration: "3h 20m", progress: 85, color: "#1B402E" },
  { id: 2, title: "The Witness Within", lessons: 6, duration: "2h 45m", progress: 40, color: "#122E21" },
  { id: 3, title: "Shadow Integration", lessons: 8, duration: "4h 10m", progress: 20, color: "#0A1C14" },
  { id: 4, title: "Authentic Leadership", lessons: 6, duration: "2h 55m", progress: 0, color: "#1B402E" },
  { id: 5, title: "Relational Intelligence", lessons: 7, duration: "3h 30m", progress: 60, color: "#122E21" },
  { id: 6, title: "Somatic Awareness", lessons: 6, duration: "2h 20m", progress: 10, color: "#0A1C14" },
  { id: 7, title: "Meaning-Making", lessons: 8, duration: "3h 50m", progress: 0, color: "#1B402E" },
  { id: 8, title: "Post-Traumatic Growth", lessons: 7, duration: "3h 15m", progress: 0, color: "#122E21" },
];

const LESSONS = [
  { title: "Introduction & Orientation", type: "video", duration: "12m", done: true },
  { title: "Core Concepts Overview", type: "video", duration: "18m", done: true },
  { title: "Reflective Journaling Practice", type: "exercise", duration: "20m", done: false },
  { title: "Deep Dive: Theory & Research", type: "reading", duration: "25m", done: false },
  { title: "Guided Meditation", type: "audio", duration: "15m", done: false },
  { title: "Integration Exercise", type: "exercise", duration: "30m", done: false },
  { title: "Community Reflection", type: "discussion", duration: "10m", done: false },
  { title: "Module Assessment", type: "quiz", duration: "15m", done: false },
];

const GLOSSARY = [
  { term: "Ego", def: "The conscious mind's sense of self; the mediator between inner drives and outer reality." },
  { term: "Shadow", def: "The unconscious part of the psyche containing repressed ideas, weaknesses, and instincts." },
  { term: "Persona", def: "The social mask we wear in public; the image we present to the outside world." },
  { term: "Individuation", def: "Jung's process of integrating all aspects of the psyche to become a whole, unique individual." },
  { term: "Self-Actualization", def: "Maslow's concept of realizing one's fullest potential and living authentically." },
  { term: "Differentiation", def: "The ability to maintain a stable sense of self while remaining emotionally connected to others." },
  { term: "Integration", def: "Bringing unconscious material into conscious awareness to create psychological wholeness." },
  { term: "Projection", def: "Attributing one's own unacknowledged feelings or traits onto another person." },
  { term: "Attachment", def: "The deep emotional bond formed in early life that shapes relational patterns throughout adulthood." },
  { term: "Window of Tolerance", def: "The optimal zone of arousal where a person can function and process information effectively." },
  { term: "Anima/Animus", def: "The feminine aspect in a man's unconscious (anima) or masculine aspect in a woman's (animus)." },
  { term: "Archetype", def: "Universal symbolic patterns embedded in the collective unconscious, e.g. the Hero, the Shadow." },
  { term: "Collective Unconscious", def: "Jung's concept of a shared layer of the unconscious mind common to all humans." },
  { term: "Dissonance", def: "The psychological discomfort felt when holding two contradictory beliefs simultaneously." },
  { term: "Embodiment", def: "The practice of inhabiting and being present in one's physical body as a path to awareness." },
  { term: "Liminal Space", def: "A transitional state between what was and what is yet to come; a threshold of transformation." },
  { term: "Neuroplasticity", def: "The brain's ability to reorganize itself by forming new neural connections throughout life." },
  { term: "Post-Traumatic Growth", def: "Positive psychological change experienced as a result of struggling with highly challenging life circumstances." },
  { term: "Resilience", def: "The capacity to recover quickly from difficulties and adapt in the face of adversity." },
  { term: "Somatic", def: "Relating to the body, especially as distinct from the mind; body-centered awareness practices." },
  { term: "Vulnerability", def: "Brené Brown's concept of emotional exposure as the birthplace of connection and courage." },
  { term: "Witness Consciousness", def: "The capacity to observe one's own thoughts and feelings without identification or judgment." },
];

const QUOTES = [
  { text: "Until you make the unconscious conscious, it will direct your life and you will call it fate.", author: "Carl Jung" },
  { text: "Vulnerability is not winning or losing; it's having the courage to show up and be seen.", author: "Brené Brown" },
  { text: "When we are no longer able to change a situation, we are challenged to change ourselves.", author: "Viktor Frankl" },
  { text: "Out beyond ideas of wrongdoing and rightdoing, there is a field. I'll meet you there.", author: "Rumi" },
  { text: "The privilege of a lifetime is to become who you truly are.", author: "Carl Jung" },
  { text: "Owning our story and loving ourselves through that process is the bravest thing we will ever do.", author: "Brené Brown" },
  { text: "Between stimulus and response there is a space. In that space is our power to choose.", author: "Viktor Frankl" },
  { text: "Yesterday I was clever, so I wanted to change the world. Today I am wise, so I am changing myself.", author: "Rumi" },
];

const ASSESSMENTS = [
  { id: 1, title: "Ego Development Stage", desc: "Discover your current stage of ego development across Loevinger's spectrum.", questions: 5, time: "8 min" },
  { id: 2, title: "Attachment Style Quiz", desc: "Identify your core attachment style: Secure, Anxious, Avoidant, or Disorganized.", questions: 5, time: "6 min" },
  { id: 3, title: "Resilience Scale", desc: "Measure your psychological resilience and areas for strengthening.", questions: 5, time: "7 min" },
];

const LIKERT_QUESTIONS = [
  "I am able to observe my thoughts without being swept away by them.",
  "I feel comfortable sitting with uncertainty and ambiguity.",
  "I can name and express my emotions clearly.",
  "I take responsibility for my reactions rather than blaming others.",
  "I feel a sense of meaning and purpose in my daily life.",
];

const LIKERT_LABELS = ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"];

function ProgressRing({ pct, size = 64, stroke = 6, color = COLORS.gold }) {
  const r = (size - stroke) / 2;
  const circ = 2 * Math.PI * r;
  const offset = circ - (pct / 100) * circ;
  return (
    <svg width={size} height={size} style={{ transform: "rotate(-90deg)" }}>
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth={stroke} />
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={stroke}
        strokeDasharray={circ} strokeDashoffset={offset} strokeLinecap="round"
        style={{ transition: "stroke-dashoffset 0.6s ease" }} />
    </svg>
  );
}

export default function ResonanceLearn() {
  const [dark, setDark] = useState(true);
  const [tab, setTab] = useState("home");
  const [selectedCourse, setSelectedCourse] = useState(null);
  const [expandedLesson, setExpandedLesson] = useState(null);
  const [glossarySearch, setGlossarySearch] = useState("");
  const [activeAssessment, setActiveAssessment] = useState(null);
  const [answers, setAnswers] = useState({});
  const [showResults, setShowResults] = useState(false);

  const bg = dark ? COLORS.night : "#EEF3F0";
  const surface = dark ? "rgba(18,46,33,0.6)" : "rgba(255,255,255,0.65)";
  const surfaceSolid = dark ? COLORS.mid : "#fff";
  const text = dark ? COLORS.cream : COLORS.dark;
  const textSub = dark ? COLORS.sage : "#4a6358";
  const border = dark ? "rgba(209,224,215,0.12)" : "rgba(10,28,20,0.1)";

  const s = {
    wrap: { minHeight: "100vh", background: bg, color: text, fontFamily: "'Manrope', sans-serif", position: "relative", overflow: "hidden", paddingBottom: 80 },
    blob: (top, left, w, opacity) => ({ position: "fixed", top, left, width: w, height: w, borderRadius: "50%", background: `radial-gradient(circle, ${COLORS.forest} 0%, transparent 70%)`, opacity, filter: "blur(60px)", pointerEvents: "none", zIndex: 0 }),
    header: { display: "flex", alignItems: "center", justifyContent: "space-between", padding: "20px 20px 12px", position: "sticky", top: 0, zIndex: 10, backdropFilter: "blur(12px)", background: dark ? "rgba(5,16,11,0.8)" : "rgba(238,243,240,0.8)", borderBottom: `1px solid ${border}` },
    logo: { fontFamily: "'Cormorant Garamond', serif", fontSize: 20, fontWeight: 700, color: COLORS.gold, letterSpacing: "0.02em" },
    iconBtn: { background: "none", border: "none", cursor: "pointer", color: text, padding: 6, borderRadius: 8, display: "flex", alignItems: "center" },
    content: { padding: "20px 16px", position: "relative", zIndex: 1 },
    glass: { background: surface, backdropFilter: "blur(16px)", border: `1px solid ${border}`, borderRadius: 16, padding: 16, marginBottom: 14 },
    card: { background: surfaceSolid, border: `1px solid ${border}`, borderRadius: 16, padding: 16, marginBottom: 14 },
    h1: { fontFamily: "'Cormorant Garamond', serif", fontSize: 28, fontWeight: 700, margin: "0 0 4px", lineHeight: 1.2 },
    h2: { fontFamily: "'Cormorant Garamond', serif", fontSize: 22, fontWeight: 700, margin: "0 0 12px" },
    h3: { fontFamily: "'Cormorant Garamond', serif", fontSize: 17, fontWeight: 700, margin: 0 },
    sub: { fontSize: 13, color: textSub, margin: 0 },
    gold: { color: COLORS.gold },
    pill: (active) => ({ display: "inline-block", padding: "4px 12px", borderRadius: 20, fontSize: 12, fontWeight: 600, background: active ? COLORS.gold : "rgba(197,160,89,0.15)", color: active ? COLORS.dark : COLORS.gold, marginRight: 6 }),
    btn: { background: `linear-gradient(135deg, ${COLORS.gold}, #a07c3a)`, color: COLORS.dark, border: "none", borderRadius: 12, padding: "12px 24px", fontFamily: "'Manrope', sans-serif", fontWeight: 700, fontSize: 14, cursor: "pointer", width: "100%" },
    tabBar: { position: "fixed", bottom: 0, left: 0, right: 0, display: "flex", background: dark ? "rgba(5,16,11,0.95)" : "rgba(238,243,240,0.95)", backdropFilter: "blur(16px)", borderTop: `1px solid ${border}`, zIndex: 20, padding: "8px 0 12px" },
    tabBtn: (active) => ({ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", gap: 3, background: "none", border: "none", cursor: "pointer", color: active ? COLORS.gold : textSub, padding: "4px 0" }),
    tabLabel: { fontSize: 10, fontWeight: 600, letterSpacing: "0.03em" },
    input: { width: "100%", padding: "12px 16px 12px 40px", borderRadius: 12, border: `1px solid ${border}`, background: surface, backdropFilter: "blur(8px)", color: text, fontFamily: "'Manrope', sans-serif", fontSize: 14, outline: "none", boxSizing: "border-box" },
    banner: { background: `linear-gradient(135deg, ${COLORS.forest}, ${COLORS.mid})`, borderRadius: 16, padding: "14px 16px", marginBottom: 14, border: `1px solid ${COLORS.gold}44` },
  };

  const tabs = [
    { id: "home", icon: Home, label: "Home" },
    { id: "courses", icon: BookOpen, label: "Courses" },
    { id: "glossary", icon: BookMarked, label: "Glossary" },
    { id: "assessments", icon: ClipboardList, label: "Assess" },
    { id: "quotes", icon: Quote, label: "Quotes" },
  ];

  const lessonIcon = (type) => {
    const icons = { video: "▶", exercise: "✦", reading: "☰", audio: "♫", discussion: "◉", quiz: "?" };
    return icons[type] || "•";
  };

  const overallProgress = Math.round(COURSES.reduce((a, c) => a + c.progress, 0) / COURSES.length);

  // Dashboard
  const Dashboard = () => (
    <div style={s.content}>
      <div style={{ marginBottom: 20 }}>
        <p style={{ ...s.sub, marginBottom: 4 }}>Good morning,</p>
        <h1 style={s.h1}>Welcome back,<br /><span style={s.gold}>Seeker</span></h1>
      </div>

      <div style={{ ...s.glass, display: "flex", alignItems: "center", gap: 16 }}>
        <div style={{ position: "relative", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <ProgressRing pct={overallProgress} size={72} stroke={7} />
          <span style={{ position: "absolute", fontSize: 14, fontWeight: 700, color: COLORS.gold }}>{overallProgress}%</span>
        </div>
        <div style={{ flex: 1 }}>
          <p style={{ margin: "0 0 2px", fontWeight: 700, fontSize: 15 }}>Overall Progress</p>
          <p style={s.sub}>{COURSES.filter(c => c.progress > 0).length} of {COURSES.length} courses started</p>
          <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 8 }}>
            <Flame size={14} color="#ff6b35" />
            <span style={{ fontSize: 13, fontWeight: 700, color: "#ff6b35" }}>12-day streak</span>
          </div>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          {[{ label: "Done", val: COURSES.filter(c => c.progress === 100).length }, { label: "Active", val: COURSES.filter(c => c.progress > 0 && c.progress < 100).length }].map(m => (
            <div key={m.label} style={{ textAlign: "center" }}>
              <div style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 22, fontWeight: 700, color: COLORS.gold }}>{m.val}</div>
              <div style={{ fontSize: 10, color: textSub }}>{m.label}</div>
            </div>
          ))}
        </div>
      </div>

      <div style={s.banner}>
        <p style={{ ...s.sub, color: COLORS.goldLight, marginBottom: 4 }}>TODAY'S RECOMMENDATION</p>
        <p style={{ margin: "0 0 8px", fontFamily: "'Cormorant Garamond', serif", fontSize: 18, fontWeight: 700 }}>Continue: The Witness Within</p>
        <p style={s.sub}>Lesson 3 · Reflective Journaling Practice · 20 min</p>
        <button style={{ ...s.btn, marginTop: 12, width: "auto", padding: "9px 20px" }} onClick={() => { setSelectedCourse(COURSES[1]); setTab("courses"); }}>
          Resume Lesson →
        </button>
      </div>

      <h2 style={{ ...s.h2, fontSize: 18, marginBottom: 10 }}>Featured Courses</h2>
      {COURSES.slice(0, 3).map(course => (
        <div key={course.id} style={{ ...s.glass, display: "flex", alignItems: "center", gap: 14, cursor: "pointer" }}
          onClick={() => { setSelectedCourse(course); setTab("courses"); }}>
          <div style={{ width: 48, height: 48, borderRadius: 12, background: `linear-gradient(135deg, ${course.color}, ${COLORS.forest})`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
            <BookOpen size={20} color={COLORS.goldLight} />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <p style={{ margin: "0 0 3px", fontWeight: 700, fontSize: 14, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{course.title}</p>
            <p style={s.sub}>{course.lessons} lessons · {course.duration}</p>
            <div style={{ marginTop: 6, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.1)" }}>
              <div style={{ height: "100%", width: `${course.progress}%`, borderRadius: 2, background: COLORS.gold, transition: "width 0.5s ease" }} />
            </div>
          </div>
          <span style={{ fontSize: 13, fontWeight: 700, color: COLORS.gold, flexShrink: 0 }}>{course.progress}%</span>
        </div>
      ))}

      <div style={{ ...s.banner, cursor: "pointer" }} onClick={() => setTab("assessments")}>
        <p style={{ ...s.sub, color: COLORS.goldLight, marginBottom: 4 }}>FEATURED ASSESSMENT</p>
        <p style={{ margin: "0 0 4px", fontWeight: 700 }}>Discover Your Ego Development Stage</p>
        <p style={s.sub}>Takes 8 minutes · Free · Personalized results</p>
      </div>
    </div>
  );

  // Courses
  const CoursesScreen = () => {
    if (selectedCourse) return <CourseDetail course={selectedCourse} />;
    return (
      <div style={s.content}>
        <h2 style={s.h2}>Your Courses</h2>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {COURSES.map(course => (
            <div key={course.id} style={{ background: surface, backdropFilter: "blur(16px)", border: `1px solid ${border}`, borderRadius: 16, padding: 14, cursor: "pointer" }}
              onClick={() => setSelectedCourse(course)}>
              <div style={{ width: 40, height: 40, borderRadius: 10, background: `linear-gradient(135deg, ${course.color}, ${COLORS.forest})`, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 10 }}>
                <BookOpen size={18} color={COLORS.goldLight} />
              </div>
              <p style={{ margin: "0 0 4px", fontWeight: 700, fontSize: 13, lineHeight: 1.3 }}>{course.title}</p>
              <p style={{ ...s.sub, fontSize: 11, marginBottom: 8 }}>{course.lessons} lessons · {course.duration}</p>
              <div style={{ height: 3, borderRadius: 2, background: "rgba(255,255,255,0.1)", marginBottom: 6 }}>
                <div style={{ height: "100%", width: `${course.progress}%`, borderRadius: 2, background: course.progress === 100 ? "#4caf82" : COLORS.gold }} />
              </div>
              <p style={{ ...s.sub, fontSize: 11, color: course.progress === 100 ? "#4caf82" : COLORS.gold, fontWeight: 600 }}>
                {course.progress === 0 ? "Not started" : course.progress === 100 ? "Complete ✓" : `${course.progress}%`}
              </p>
            </div>
          ))}
        </div>
      </div>
    );
  };

  // Course Detail
  const CourseDetail = ({ course }) => (
    <div style={s.content}>
      <button style={{ ...s.iconBtn, marginBottom: 14, gap: 6, fontSize: 14, fontWeight: 600, color: COLORS.gold }} onClick={() => setSelectedCourse(null)}>
        <ArrowLeft size={16} /> Back to Courses
      </button>
      <div style={{ background: `linear-gradient(135deg, ${course.color}, ${COLORS.forest})`, borderRadius: 20, padding: 20, marginBottom: 16 }}>
        <p style={{ ...s.sub, color: COLORS.goldLight, marginBottom: 6 }}>{course.lessons} LESSONS · {course.duration}</p>
        <h2 style={{ ...s.h2, color: COLORS.cream, marginBottom: 12 }}>{course.title}</h2>
        <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
          <div style={{ position: "relative" }}>
            <ProgressRing pct={course.progress} size={56} stroke={5} />
            <span style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)", fontSize: 11, fontWeight: 700, color: COLORS.gold }}>{course.progress}%</span>
          </div>
          <button style={{ ...s.btn, width: "auto", padding: "10px 20px" }}>
            {course.progress === 0 ? "Start Course" : "Continue"}
          </button>
        </div>
      </div>

      <h3 style={{ ...s.h3, marginBottom: 12, fontFamily: "'Cormorant Garamond', serif", fontSize: 18 }}>Lessons</h3>
      {LESSONS.map((lesson, i) => (
        <div key={i} style={{ ...s.glass, cursor: "pointer", padding: "14px 16px" }} onClick={() => setExpandedLesson(expandedLesson === i ? null : i)}>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ width: 36, height: 36, borderRadius: 10, background: lesson.done ? `${COLORS.gold}22` : "rgba(255,255,255,0.06)", border: `1px solid ${lesson.done ? COLORS.gold : border}`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14, color: lesson.done ? COLORS.gold : textSub, flexShrink: 0 }}>
              {lessonIcon(lesson.type)}
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <p style={{ margin: "0 0 2px", fontWeight: 600, fontSize: 14 }}>{lesson.title}</p>
              <p style={s.sub}>{lesson.type} · {lesson.duration}</p>
            </div>
            {lesson.done ? <CheckCircle size={18} color="#4caf82" /> : i > 1 ? <Lock size={14} color={textSub} /> : <Circle size={18} color={textSub} />}
          </div>
          {expandedLesson === i && (
            <div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px solid ${border}` }}>
              <p style={{ ...s.sub, lineHeight: 1.6 }}>In this {lesson.type}, you will explore {lesson.title.toLowerCase()} through guided inquiry and experiential practices designed to deepen your self-awareness.</p>
              {!i || lesson.done ? <button style={{ ...s.btn, marginTop: 10 }}>{lesson.done ? "Review Lesson" : "Begin Lesson"}</button> : null}
            </div>
          )}
        </div>
      ))}
    </div>
  );

  // Glossary
  const GlossaryScreen = () => {
    const filtered = GLOSSARY.filter(g => g.term.toLowerCase().includes(glossarySearch.toLowerCase()) || g.def.toLowerCase().includes(glossarySearch.toLowerCase()));
    return (
      <div style={s.content}>
        <h2 style={s.h2}>Glossary</h2>
        <div style={{ position: "relative", marginBottom: 16 }}>
          <Search size={16} style={{ position: "absolute", left: 12, top: "50%", transform: "translateY(-50%)", color: textSub }} />
          <input style={s.input} placeholder="Search terms…" value={glossarySearch} onChange={e => setGlossarySearch(e.target.value)} />
        </div>
        <p style={{ ...s.sub, marginBottom: 12 }}>{filtered.length} terms</p>
        {filtered.map((g, i) => (
          <div key={i} style={s.glass}>
            <p style={{ margin: "0 0 6px", fontFamily: "'Cormorant Garamond', serif", fontSize: 17, fontWeight: 700, color: COLORS.gold }}>{g.term}</p>
            <p style={{ ...s.sub, lineHeight: 1.6, fontSize: 13 }}>{g.def}</p>
          </div>
        ))}
        {filtered.length === 0 && <p style={{ ...s.sub, textAlign: "center", padding: "40px 0" }}>No terms found for "{glossarySearch}"</p>}
      </div>
    );
  };

  // Assessments
  const AssessmentsScreen = () => {
    if (showResults) {
      const score = Object.values(answers).reduce((a, b) => a + b, 0);
      const max = LIKERT_QUESTIONS.length * 5;
      const pct = Math.round((score / max) * 100);
      return (
        <div style={s.content}>
          <button style={{ ...s.iconBtn, marginBottom: 14, gap: 6, fontSize: 14, fontWeight: 600, color: COLORS.gold }} onClick={() => { setShowResults(false); setActiveAssessment(null); setAnswers({}); }}>
            <ArrowLeft size={16} /> Back
          </button>
          <div style={{ ...s.glass, textAlign: "center", padding: 28 }}>
            <div style={{ display: "inline-flex", position: "relative", marginBottom: 16 }}>
              <ProgressRing pct={pct} size={96} stroke={8} />
              <span style={{ position: "absolute", top: "50%", left: "50%", transform: "translate(-50%,-50%)", fontSize: 20, fontWeight: 800, color: COLORS.gold }}>{pct}%</span>
            </div>
            <h2 style={{ ...s.h2, marginBottom: 6 }}>Your Results</h2>
            <p style={{ ...s.sub, marginBottom: 16 }}>{ASSESSMENTS[activeAssessment - 1]?.title}</p>
            <div style={{ ...s.banner, textAlign: "left", marginBottom: 14 }}>
              <p style={{ margin: "0 0 6px", fontWeight: 700 }}>{pct >= 70 ? "High Awareness" : pct >= 45 ? "Developing Awareness" : "Early Stage"}</p>
              <p style={s.sub}>Your responses indicate {pct >= 70 ? "a well-developed capacity for self-observation and emotional regulation" : pct >= 45 ? "growing self-awareness with opportunities for deeper integration" : "an emerging foundation for ego development work"}.</p>
            </div>
            <button style={s.btn} onClick={() => { setShowResults(false); setActiveAssessment(null); setAnswers({}); }}>Take Another Assessment</button>
          </div>
        </div>
      );
    }
    if (activeAssessment) {
      const assessment = ASSESSMENTS[activeAssessment - 1];
      const allAnswered = Object.keys(answers).length === LIKERT_QUESTIONS.length;
      return (
        <div style={s.content}>
          <button style={{ ...s.iconBtn, marginBottom: 14, gap: 6, fontSize: 14, fontWeight: 600, color: COLORS.gold }} onClick={() => { setActiveAssessment(null); setAnswers({}); }}>
            <ArrowLeft size={16} /> Back
          </button>
          <h2 style={s.h2}>{assessment.title}</h2>
          <p style={{ ...s.sub, marginBottom: 20 }}>{assessment.desc}</p>
          {LIKERT_QUESTIONS.map((q, qi) => (
            <div key={qi} style={{ ...s.glass, marginBottom: 14 }}>
              <p style={{ margin: "0 0 14px", fontWeight: 600, fontSize: 14, lineHeight: 1.5 }}>{qi + 1}. {q}</p>
              <div style={{ display: "flex", gap: 6 }}>
                {[1, 2, 3, 4, 5].map(v => (
                  <button key={v} style={{ flex: 1, padding: "8px 0", borderRadius: 10, border: `1px solid ${answers[qi] === v ? COLORS.gold : border}`, background: answers[qi] === v ? `${COLORS.gold}22` : "transparent", color: answers[qi] === v ? COLORS.gold : textSub, cursor: "pointer", fontSize: 12, fontWeight: 600, transition: "all 0.2s" }}
                    onClick={() => setAnswers(a => ({ ...a, [qi]: v }))}>
                    {v}
                  </button>
                ))}
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", marginTop: 6 }}>
                <span style={{ fontSize: 10, color: textSub }}>{LIKERT_LABELS[0]}</span>
                <span style={{ fontSize: 10, color: textSub }}>{LIKERT_LABELS[4]}</span>
              </div>
            </div>
          ))}
          <button style={{ ...s.btn, opacity: allAnswered ? 1 : 0.5 }} disabled={!allAnswered} onClick={() => setShowResults(true)}>
            {allAnswered ? "View My Results →" : `Answer all ${LIKERT_QUESTIONS.length} questions to continue`}
          </button>
        </div>
      );
    }
    return (
      <div style={s.content}>
        <h2 style={s.h2}>Assessments</h2>
        <p style={{ ...s.sub, marginBottom: 20 }}>Gain insight into your inner landscape through evidence-based assessments.</p>
        {ASSESSMENTS.map((a, i) => (
          <div key={a.id} style={{ ...s.glass, cursor: "pointer" }} onClick={() => setActiveAssessment(a.id)}>
            <div style={{ display: "flex", alignItems: "flex-start", gap: 12 }}>
              <div style={{ width: 44, height: 44, borderRadius: 12, background: `linear-gradient(135deg, ${COLORS.forest}, ${COLORS.mid})`, border: `1px solid ${COLORS.gold}44`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                <ClipboardList size={20} color={COLORS.gold} />
              </div>
              <div style={{ flex: 1 }}>
                <p style={{ margin: "0 0 4px", fontFamily: "'Cormorant Garamond', serif", fontSize: 17, fontWeight: 700 }}>{a.title}</p>
                <p style={{ ...s.sub, lineHeight: 1.5, marginBottom: 10 }}>{a.desc}</p>
                <div style={{ display: "flex", gap: 8 }}>
                  <span style={s.pill(false)}>{a.questions} questions</span>
                  <span style={s.pill(false)}>{a.time}</span>
                </div>
              </div>
            </div>
            <button style={{ ...s.btn, marginTop: 14 }}>Begin Assessment</button>
          </div>
        ))}
        <div style={{ ...s.banner, cursor: "pointer" }} onClick={() => setTab("courses")}>
          <p style={{ ...s.sub, color: COLORS.goldLight, marginBottom: 4 }}>AFTER YOUR ASSESSMENT</p>
          <p style={{ margin: "0 0 4px", fontWeight: 700 }}>Explore Recommended Courses</p>
          <p style={s.sub}>Get personalized course suggestions based on your results →</p>
        </div>
      </div>
    );
  };

  // Quotes
  const QuotesScreen = () => (
    <div style={s.content}>
      <h2 style={s.h2}>Wisdom</h2>
      <p style={{ ...s.sub, marginBottom: 20 }}>Words that illuminate the path inward.</p>
      {QUOTES.map((q, i) => (
        <div key={i} style={{ ...s.glass, padding: 20 }}>
          <p style={{ fontFamily: "'Cormorant Garamond', serif", fontSize: 18, fontStyle: "italic", lineHeight: 1.6, margin: "0 0 14px", color: dark ? COLORS.cream : COLORS.dark }}>
            "{q.text}"
          </p>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <div style={{ width: 2, height: 28, borderRadius: 2, background: COLORS.gold }} />
            <p style={{ margin: 0, fontWeight: 700, fontSize: 13, color: COLORS.gold }}>{q.author}</p>
          </div>
          <div style={{ display: "flex", gap: 3, marginTop: 12 }}>
            {[...Array(5)].map((_, si) => <Star key={si} size={12} fill={COLORS.gold} color={COLORS.gold} />)}
          </div>
        </div>
      ))}
      <div style={{ ...s.banner, cursor: "pointer" }} onClick={() => setTab("glossary")}>
        <p style={{ ...s.sub, color: COLORS.goldLight, marginBottom: 4 }}>DEEPEN YOUR UNDERSTANDING</p>
        <p style={{ margin: "0 0 4px", fontWeight: 700 }}>Explore the Glossary</p>
        <p style={s.sub}>22 key concepts from ego development theory →</p>
      </div>
    </div>
  );

  const screens = { home: <Dashboard />, courses: <CoursesScreen />, glossary: <GlossaryScreen />, assessments: <AssessmentsScreen />, quotes: <QuotesScreen /> };

  return (
    <div style={s.wrap}>
      <div style={s.blob("10%", "-10%", "300px", 0.15)} />
      <div style={s.blob("50%", "60%", "250px", 0.1)} />
      <div style={s.blob("80%", "20%", "200px", 0.08)} />

      <div style={s.header}>
        <span style={s.logo}>Resonance Learn</span>
        <button style={s.iconBtn} onClick={() => setDark(d => !d)}>
          {dark ? <Sun size={18} /> : <Moon size={18} />}
        </button>
      </div>

      {screens[tab]}

      <nav style={s.tabBar}>
        {tabs.map(({ id, icon: Icon, label }) => (
          <button key={id} style={s.tabBtn(tab === id)} onClick={() => { setTab(id); if (id !== "courses") setSelectedCourse(null); }}>
            <Icon size={20} />
            <span style={s.tabLabel}>{label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}
