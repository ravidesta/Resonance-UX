import { useState, useEffect, useRef } from "react";
import {
  BookOpen, MessageCircle, Feather, Wind, Book, Stethoscope,
  Sun, Moon, ChevronLeft, ChevronRight, Sparkles, ArrowRight
} from "lucide-react";

const C = {
  night: "#05100B", dark: "#0A1C14", mid: "#122E21", green: "#1B402E",
  muted: "#D1E0D7", gold: "#C5A059", goldLight: "#E6D0A1", cream: "#FAFAF8",
};

const fonts = `@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=Manrope:wght@300;400;500;600&display=swap');`;

const apps = [
  { icon: BookOpen, name: "Learn", desc: "Structured ego-development courses and guided lessons", platforms: "iOS · Android · Web" },
  { icon: MessageCircle, name: "Coach", desc: "AI-powered coaching conversations tailored to your stage", platforms: "iOS · Android · Web" },
  { icon: Feather, name: "Journal", desc: "Reflective prompts and shadow-work journaling", platforms: "iOS · Android" },
  { icon: Wind, name: "Meditate", desc: "Breathwork, somatic practices, and guided meditation", platforms: "iOS · Android · Web" },
  { icon: Book, name: "Reader", desc: "Curated library of transformational texts and audiobooks", platforms: "iOS · Android · Web" },
  { icon: Stethoscope, name: "Therapist", desc: "Connect with therapists trained in vertical development", platforms: "Web · Telehealth" },
];

const quotes = [
  { text: "Out beyond ideas of wrongdoing and rightdoing, there is a field. I'll meet you there.", author: "Rumi" },
  { text: "Until you make the unconscious conscious, it will direct your life and you will call it fate.", author: "Carl Jung" },
  { text: "Vulnerability is not winning or losing; it's having the courage to show up when you can't control the outcome.", author: "Brené Brown" },
];

const steps = [
  { icon: Sparkles, title: "Discover", desc: "Take your developmental assessment and understand where you are on the journey of consciousness." },
  { icon: BookOpen, title: "Practice", desc: "Engage daily with personalized tools — journal, meditate, learn, and converse with your AI coach." },
  { icon: ArrowRight, title: "Grow", desc: "Track your evolution, celebrate breakthroughs, and integrate higher stages of awareness into everyday life." },
];

const plans = [
  { name: "Free", price: "$0", period: "", features: ["Developmental assessment", "3 journal prompts/week", "Basic meditation library", "Community access"], cta: "Get Started", outlined: false },
  { name: "Premium", price: "$9.99", period: "/mo", features: ["Everything in Free", "Unlimited journaling", "Full meditation library", "AI Coach (50 msgs/mo)", "Reader full access"], cta: "Start Free Trial", outlined: false, highlight: true },
  { name: "Professional", price: "$19.99", period: "/mo", features: ["Everything in Premium", "Unlimited AI Coach", "Therapist matching", "Group cohort access", "Priority support"], cta: "Go Professional", outlined: true },
];

export default function LandingPage() {
  const [dark, setDark] = useState(true);
  const [quoteIdx, setQuoteIdx] = useState(0);
  const [email, setEmail] = useState("");
  const [subscribed, setSubscribed] = useState(false);
  const blobRef = useRef(null);

  const bg = dark ? C.night : C.cream;
  const fg = dark ? C.cream : C.dark;
  const cardBg = dark ? "rgba(18,46,33,0.55)" : "rgba(209,224,215,0.45)";
  const border = dark ? "rgba(197,160,89,0.18)" : "rgba(27,64,46,0.15)";

  useEffect(() => {
    const id = setInterval(() => setQuoteIdx(i => (i + 1) % quotes.length), 6000);
    return () => clearInterval(id);
  }, []);

  useEffect(() => {
    let frame, angle = 0;
    const animate = () => {
      angle += 0.003;
      if (blobRef.current) {
        const x = 50 + 8 * Math.sin(angle);
        const y = 50 + 8 * Math.cos(angle * 0.7);
        blobRef.current.style.transform = `translate(${x - 50}%, ${y - 50}%) scale(${1 + 0.04 * Math.sin(angle * 1.3)})`;
      }
      frame = requestAnimationFrame(animate);
    };
    frame = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(frame);
  }, []);

  const s = {
    root: { fontFamily: "'Manrope', sans-serif", background: bg, color: fg, minHeight: "100vh", transition: "background 0.4s, color 0.4s", overflowX: "hidden" },
    nav: { position: "sticky", top: 0, zIndex: 100, display: "flex", alignItems: "center", justifyContent: "space-between", padding: "0 5vw", height: 64, backdropFilter: "blur(18px)", background: dark ? "rgba(5,16,11,0.82)" : "rgba(250,250,248,0.82)", borderBottom: `1px solid ${border}` },
    logo: { fontFamily: "'Cormorant Garamond', serif", fontSize: 22, fontWeight: 600, color: C.gold, letterSpacing: 1.5, cursor: "pointer" },
    navLinks: { display: "flex", gap: 32, listStyle: "none", margin: 0, padding: 0 },
    navLink: { fontSize: 13, fontWeight: 500, color: fg, opacity: 0.75, cursor: "pointer", letterSpacing: 0.4, transition: "opacity 0.2s" },
    toggle: { background: dark ? C.mid : C.muted, border: "none", borderRadius: 20, padding: "6px 10px", cursor: "pointer", color: fg, display: "flex", alignItems: "center", gap: 6, fontSize: 13 },
    hero: { position: "relative", minHeight: "92vh", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center", padding: "80px 6vw 60px", overflow: "hidden" },
    blob: { position: "absolute", width: 680, height: 680, borderRadius: "50%", background: dark ? "radial-gradient(ellipse, rgba(197,160,89,0.13) 0%, rgba(27,64,46,0.22) 45%, transparent 70%)" : "radial-gradient(ellipse, rgba(197,160,89,0.18) 0%, rgba(209,224,215,0.35) 50%, transparent 70%)", top: "50%", left: "50%", transform: "translate(-50%,-50%)", pointerEvents: "none", willChange: "transform" },
    eyebrow: { fontSize: 11, letterSpacing: 3, fontWeight: 600, color: C.gold, textTransform: "uppercase", marginBottom: 20 },
    heroH1: { fontFamily: "'Cormorant Garamond', serif", fontSize: "clamp(42px, 7vw, 86px)", fontWeight: 300, lineHeight: 1.1, letterSpacing: -1, marginBottom: 24, color: fg },
    heroItalic: { fontStyle: "italic", color: C.gold },
    heroSub: { fontSize: "clamp(15px, 2vw, 18px)", fontWeight: 300, opacity: 0.75, maxWidth: 560, lineHeight: 1.75, marginBottom: 44 },
    ctaRow: { display: "flex", gap: 16, flexWrap: "wrap", justifyContent: "center" },
    btnGold: { background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`, color: C.dark, border: "none", borderRadius: 50, padding: "14px 36px", fontSize: 14, fontWeight: 600, cursor: "pointer", letterSpacing: 0.5, transition: "opacity 0.2s, transform 0.2s" },
    btnOutline: { background: "transparent", color: fg, border: `1.5px solid ${C.gold}`, borderRadius: 50, padding: "13px 34px", fontSize: 14, fontWeight: 500, cursor: "pointer", letterSpacing: 0.5, transition: "background 0.2s" },
    section: { padding: "90px 6vw", maxWidth: 1140, margin: "0 auto" },
    sectionLabel: { textAlign: "center", fontSize: 11, letterSpacing: 3, fontWeight: 600, color: C.gold, textTransform: "uppercase", marginBottom: 14 },
    sectionH2: { fontFamily: "'Cormorant Garamond', serif", fontSize: "clamp(32px, 4vw, 52px)", fontWeight: 300, textAlign: "center", marginBottom: 12, letterSpacing: -0.5 },
    sectionSub: { textAlign: "center", opacity: 0.65, fontSize: 15, maxWidth: 520, margin: "0 auto 56px", lineHeight: 1.7 },
    grid: { display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: 20 },
    card: { background: cardBg, border: `1px solid ${border}`, borderRadius: 20, padding: "32px 28px", backdropFilter: "blur(14px)", transition: "transform 0.25s, box-shadow 0.25s", cursor: "default" },
    cardIcon: { width: 44, height: 44, borderRadius: 12, background: dark ? "rgba(197,160,89,0.12)" : "rgba(197,160,89,0.18)", display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 18, color: C.gold },
    cardName: { fontFamily: "'Cormorant Garamond', serif", fontSize: 22, fontWeight: 600, marginBottom: 8 },
    cardDesc: { fontSize: 13.5, opacity: 0.7, lineHeight: 1.65, marginBottom: 14 },
    cardBadge: { fontSize: 11, letterSpacing: 1, fontWeight: 600, color: C.gold, opacity: 0.85 },
    quoteSection: { padding: "70px 6vw", background: dark ? `linear-gradient(180deg, ${C.night} 0%, ${C.dark} 100%)` : `linear-gradient(180deg, ${C.cream} 0%, #EEF4F0 100%)` },
    quoteInner: { maxWidth: 760, margin: "0 auto", textAlign: "center" },
    quoteCard: { background: cardBg, border: `1px solid ${border}`, borderRadius: 24, padding: "52px 48px", backdropFilter: "blur(18px)", minHeight: 200, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" },
    quoteText: { fontFamily: "'Cormorant Garamond', serif", fontSize: "clamp(20px, 3vw, 28px)", fontStyle: "italic", fontWeight: 300, lineHeight: 1.6, marginBottom: 24 },
    quoteAuthor: { fontSize: 12, letterSpacing: 2, fontWeight: 600, color: C.gold, textTransform: "uppercase" },
    quoteDots: { display: "flex", gap: 8, justifyContent: "center", marginTop: 28 },
    stepsGrid: { display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", gap: 32, marginTop: 0 },
    stepCard: { textAlign: "center", padding: "36px 24px" },
    stepNum: { width: 52, height: 52, borderRadius: "50%", background: `linear-gradient(135deg, ${C.gold}22, ${C.gold}44)`, border: `1.5px solid ${C.gold}55`, display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 20px", color: C.gold },
    stepTitle: { fontFamily: "'Cormorant Garamond', serif", fontSize: 24, fontWeight: 600, marginBottom: 12 },
    stepDesc: { fontSize: 14, opacity: 0.68, lineHeight: 1.75 },
    bookSection: { padding: "80px 6vw", background: dark ? `linear-gradient(135deg, ${C.dark} 0%, ${C.mid} 100%)` : `linear-gradient(135deg, #EEF4F0 0%, #D8EBE2 100%)` },
    bookCard: { maxWidth: 780, margin: "0 auto", background: cardBg, border: `1.5px solid ${C.gold}55`, borderRadius: 28, padding: "56px 52px", backdropFilter: "blur(18px)", textAlign: "center" },
    bookTitle: { fontFamily: "'Cormorant Garamond', serif", fontSize: "clamp(28px, 4vw, 46px)", fontWeight: 300, marginBottom: 18, letterSpacing: -0.5 },
    bookSub: { fontSize: 15, opacity: 0.7, lineHeight: 1.75, maxWidth: 480, margin: "0 auto 28px" },
    bookFormats: { fontSize: 12, letterSpacing: 2, fontWeight: 600, color: C.gold, textTransform: "uppercase", marginBottom: 32 },
    pricingGrid: { display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))", gap: 20, marginTop: 0 },
    priceCard: { background: cardBg, border: `1px solid ${border}`, borderRadius: 24, padding: "40px 32px", backdropFilter: "blur(14px)", display: "flex", flexDirection: "column" },
    priceCardHL: { border: `1.5px solid ${C.gold}88`, background: dark ? "rgba(197,160,89,0.08)" : "rgba(197,160,89,0.12)" },
    planName: { fontSize: 13, letterSpacing: 2, fontWeight: 600, color: C.gold, textTransform: "uppercase", marginBottom: 16 },
    planPrice: { fontFamily: "'Cormorant Garamond', serif", fontSize: 48, fontWeight: 300, lineHeight: 1, marginBottom: 4 },
    planPeriod: { fontSize: 14, opacity: 0.55, marginBottom: 28 },
    planFeatures: { listStyle: "none", padding: 0, margin: "0 0 32px", flexGrow: 1 },
    planFeature: { fontSize: 13.5, opacity: 0.78, padding: "7px 0", borderBottom: `1px solid ${border}`, display: "flex", alignItems: "center", gap: 8 },
    newsletterSection: { padding: "80px 6vw", textAlign: "center", background: dark ? C.dark : "#EEF4F0" },
    newsletterCard: { maxWidth: 560, margin: "0 auto", background: cardBg, border: `1px solid ${border}`, borderRadius: 24, padding: "52px 40px", backdropFilter: "blur(14px)" },
    inputRow: { display: "flex", gap: 12, marginTop: 28, flexWrap: "wrap", justifyContent: "center" },
    input: { flex: 1, minWidth: 220, padding: "13px 20px", borderRadius: 50, border: `1px solid ${border}`, background: dark ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.05)", color: fg, fontSize: 14, outline: "none", fontFamily: "'Manrope', sans-serif" },
    footer: { padding: "48px 6vw 32px", borderTop: `1px solid ${border}`, display: "flex", flexWrap: "wrap", alignItems: "center", justifyContent: "space-between", gap: 24 },
    footerLinks: { display: "flex", gap: 24, flexWrap: "wrap" },
    footerLink: { fontSize: 13, opacity: 0.55, cursor: "pointer", transition: "opacity 0.2s" },
    footerNote: { fontSize: 12, opacity: 0.4, textAlign: "center", flexBasis: "100%", marginTop: 8 },
  };

  return (
    <>
      <style>{fonts}</style>
      <div style={s.root}>
        {/* NAV */}
        <nav style={s.nav}>
          <span style={s.logo}>Resonance</span>
          <ul style={s.navLinks}>
            {["Ecosystem", "Book", "Pricing", "Sign In"].map(l => (
              <li key={l} style={s.navLink}>{l}</li>
            ))}
          </ul>
          <button style={s.toggle} onClick={() => setDark(d => !d)}>
            {dark ? <Sun size={15} /> : <Moon size={15} />}
            {dark ? "Light" : "Dark"}
          </button>
        </nav>

        {/* HERO */}
        <section style={s.hero}>
          <div ref={blobRef} style={s.blob} />
          <p style={s.eyebrow}>Ego Development &amp; Inner Transformation</p>
          <h1 style={s.heroH1}>
            Illuminate Your<br />
            <span style={s.heroItalic}>Inner World</span>
          </h1>
          <p style={s.heroSub}>
            An integrated ecosystem of tools designed to support your ego development journey — from self-discovery to expanded awareness, one mindful step at a time.
          </p>
          <div style={s.ctaRow}>
            <button style={s.btnGold}>Start Journey</button>
            <button style={s.btnOutline}>Explore Ecosystem</button>
          </div>
        </section>

        {/* ECOSYSTEM GRID */}
        <div style={{ background: dark ? C.dark : "#F2F8F4", padding: "2px 0" }}>
          <div style={s.section}>
            <p style={s.sectionLabel}>The Ecosystem</p>
            <h2 style={s.sectionH2}>Six Apps. One Journey.</h2>
            <p style={s.sectionSub}>Every tool in the Resonance ecosystem is built around the science and wisdom of vertical development.</p>
            <div style={s.grid}>
              {apps.map(({ icon: Icon, name, desc, platforms }) => (
                <div key={name} style={s.card}
                  onMouseEnter={e => { e.currentTarget.style.transform = "translateY(-4px)"; e.currentTarget.style.boxShadow = `0 16px 48px ${C.gold}18`; }}
                  onMouseLeave={e => { e.currentTarget.style.transform = "none"; e.currentTarget.style.boxShadow = "none"; }}>
                  <div style={s.cardIcon}><Icon size={20} /></div>
                  <div style={s.cardName}>{name}</div>
                  <div style={s.cardDesc}>{desc}</div>
                  <div style={s.cardBadge}>{platforms}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* QUOTE CAROUSEL */}
        <div style={s.quoteSection}>
          <div style={s.quoteInner}>
            <p style={{ ...s.sectionLabel, marginBottom: 36 }}>Wisdom</p>
            <div style={s.quoteCard}>
              <p style={s.quoteText}>&ldquo;{quotes[quoteIdx].text}&rdquo;</p>
              <p style={s.quoteAuthor}>— {quotes[quoteIdx].author}</p>
            </div>
            <div style={s.quoteDots}>
              {quotes.map((_, i) => (
                <div key={i} onClick={() => setQuoteIdx(i)} style={{ width: i === quoteIdx ? 22 : 7, height: 7, borderRadius: 4, background: i === quoteIdx ? C.gold : (dark ? C.green : C.muted), cursor: "pointer", transition: "all 0.3s" }} />
              ))}
            </div>
          </div>
        </div>

        {/* HOW IT WORKS */}
        <div style={{ background: dark ? C.night : C.cream }}>
          <div style={s.section}>
            <p style={s.sectionLabel}>How It Works</p>
            <h2 style={s.sectionH2}>Your Path to Growth</h2>
            <p style={s.sectionSub}>Three phases that meet you where you are and guide you toward where you're becoming.</p>
            <div style={s.stepsGrid}>
              {steps.map(({ icon: Icon, title, desc }, i) => (
                <div key={title} style={s.stepCard}>
                  <div style={s.stepNum}><Icon size={22} /></div>
                  <div style={{ fontSize: 11, letterSpacing: 2, fontWeight: 600, color: C.gold, marginBottom: 10, textTransform: "uppercase" }}>Step {i + 1}</div>
                  <div style={s.stepTitle}>{title}</div>
                  <div style={s.stepDesc}>{desc}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* BOOK SECTION */}
        <div style={s.bookSection}>
          <div style={s.bookCard}>
            <p style={{ fontSize: 11, letterSpacing: 3, fontWeight: 600, color: C.gold, textTransform: "uppercase", marginBottom: 20 }}>Featured</p>
            <h2 style={s.bookTitle}>The Luminous Book</h2>
            <p style={s.bookSub}>A comprehensive guide to ego development stages, shadow integration, and the journey toward a more expansive, luminous self.</p>
            <p style={s.bookFormats}>Available as book · audiobook · course</p>
            <button style={s.btnGold}>Explore the Book</button>
          </div>
        </div>

        {/* PRICING */}
        <div style={{ background: dark ? C.dark : "#F2F8F4", padding: "2px 0" }}>
          <div style={s.section}>
            <p style={s.sectionLabel}>Pricing</p>
            <h2 style={s.sectionH2}>Invest in Your Growth</h2>
            <p style={s.sectionSub}>Flexible plans to support every stage of the journey. Cancel anytime.</p>
            <div style={s.pricingGrid}>
              {plans.map(({ name, price, period, features, cta, highlight, outlined }) => (
                <div key={name} style={{ ...s.priceCard, ...(highlight ? s.priceCardHL : {}) }}>
                  {highlight && <div style={{ fontSize: 10, letterSpacing: 2, fontWeight: 700, color: C.dark, background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`, borderRadius: 20, padding: "4px 14px", alignSelf: "flex-start", marginBottom: 16, textTransform: "uppercase" }}>Most Popular</div>}
                  <div style={s.planName}>{name}</div>
                  <div style={s.planPrice}>{price}<span style={{ fontSize: 16 }}>{period}</span></div>
                  <div style={s.planPeriod}>{period ? "billed monthly" : "forever free"}</div>
                  <ul style={s.planFeatures}>
                    {features.map(f => (
                      <li key={f} style={s.planFeature}>
                        <span style={{ color: C.gold, fontSize: 16, lineHeight: 1 }}>·</span> {f}
                      </li>
                    ))}
                  </ul>
                  <button style={outlined ? s.btnOutline : s.btnGold}>{cta}</button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* NEWSLETTER */}
        <div style={s.newsletterSection}>
          <div style={s.newsletterCard}>
            <p style={s.sectionLabel}>Community</p>
            <h2 style={{ ...s.sectionH2, marginBottom: 12 }}>Join the Luminous Community</h2>
            <p style={{ fontSize: 14, opacity: 0.65, lineHeight: 1.75 }}>Weekly insights on ego development, inner growth, and the latest from the Resonance ecosystem.</p>
            {subscribed ? (
              <p style={{ marginTop: 28, color: C.gold, fontFamily: "'Cormorant Garamond', serif", fontSize: 20, fontStyle: "italic" }}>Welcome to the community.</p>
            ) : (
              <div style={s.inputRow}>
                <input style={s.input} type="email" placeholder="your@email.com" value={email} onChange={e => setEmail(e.target.value)} />
                <button style={s.btnGold} onClick={() => email && setSubscribed(true)}>Subscribe</button>
              </div>
            )}
          </div>
        </div>

        {/* FOOTER */}
        <footer style={s.footer}>
          <span style={{ ...s.logo, fontSize: 18 }}>Resonance</span>
          <div style={s.footerLinks}>
            {["About", "Ecosystem", "Book", "Privacy", "Terms", "Contact"].map(l => (
              <span key={l} style={s.footerLink}
                onMouseEnter={e => e.currentTarget.style.opacity = "0.9"}
                onMouseLeave={e => e.currentTarget.style.opacity = "0.55"}>{l}</span>
            ))}
          </div>
          <div style={s.footerNote}>Part of the Luminous Network · &copy; {new Date().getFullYear()} Resonance. All rights reserved.</div>
        </footer>
      </div>
    </>
  );
}
