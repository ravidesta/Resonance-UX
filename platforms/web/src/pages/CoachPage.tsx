import React, { useEffect, useState } from 'react';
import CoachService, {
  Coach,
  CoachSession,
  SessionType,
} from '../../../shared/coach/CoachService';

// ---------------------------------------------------------------------------
// Theme tokens
// ---------------------------------------------------------------------------
const T = {
  bg: '#FAFAF8',
  darkGreen: '#0A1C14',
  green: '#122E21',
  gold: '#C5A059',
  goldLight: '#D4B877',
  glass: 'rgba(255,255,255,0.7)',
  glassBorder: 'rgba(255,255,255,0.45)',
  blur: 'blur(12px)',
  radius: 16,
  radiusSm: 10,
  shadow: '0 4px 24px rgba(10,28,20,0.08)',
  font: "'Inter', 'SF Pro Display', system-ui, sans-serif",
} as const;

// ---------------------------------------------------------------------------
// Inline-style helpers
// ---------------------------------------------------------------------------
const glassCard: React.CSSProperties = {
  background: T.glass,
  backdropFilter: T.blur,
  WebkitBackdropFilter: T.blur,
  border: `1px solid ${T.glassBorder}`,
  borderRadius: T.radius,
  boxShadow: T.shadow,
};

const SESSION_TYPES: { value: SessionType; label: string; icon: string }[] = [
  { value: 'natal-reading', label: 'Natal Reading', icon: '\u2609' },
  { value: 'transit-guidance', label: 'Transit Guidance', icon: '\u21BB' },
  { value: 'relationship-synastry', label: 'Relationship Synastry', icon: '\u2661' },
  { value: 'career-astrology', label: 'Career Astrology', icon: '\u2606' },
  { value: 'spiritual-growth', label: 'Spiritual Growth', icon: '\u2726' },
];

// ---------------------------------------------------------------------------
// Sub-components
// ---------------------------------------------------------------------------

function StarRating({ rating }: { rating: number }) {
  const full = Math.floor(rating);
  const partial = rating - full;
  return (
    <span style={{ color: T.gold, fontSize: 14, letterSpacing: 2 }}>
      {Array.from({ length: 5 }, (_, i) => {
        if (i < full) return '\u2605';
        if (i === full && partial >= 0.5) return '\u2605';
        return '\u2606';
      }).join('')}
      <span style={{ color: T.darkGreen, marginLeft: 6, fontSize: 13, letterSpacing: 0 }}>
        {rating.toFixed(1)}
      </span>
    </span>
  );
}

function AvatarPlaceholder({ name, size = 72 }: { name: string; size?: number }) {
  const initials = name
    .split(' ')
    .map((w) => w[0])
    .join('')
    .slice(0, 2);
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: '50%',
        background: `linear-gradient(135deg, ${T.green}, ${T.darkGreen})`,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: T.gold,
        fontWeight: 700,
        fontSize: size * 0.36,
        flexShrink: 0,
      }}
    >
      {initials}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Coach Card
// ---------------------------------------------------------------------------

function CoachCard({
  coach,
  onSelect,
}: {
  coach: Coach;
  onSelect: (c: Coach) => void;
}) {
  return (
    <div
      onClick={() => onSelect(coach)}
      style={{
        ...glassCard,
        padding: 24,
        cursor: 'pointer',
        transition: 'transform 0.2s, box-shadow 0.2s',
        display: 'flex',
        flexDirection: 'column',
        gap: 14,
      }}
      onMouseEnter={(e) => {
        (e.currentTarget as HTMLDivElement).style.transform = 'translateY(-4px)';
        (e.currentTarget as HTMLDivElement).style.boxShadow =
          '0 8px 32px rgba(10,28,20,0.14)';
      }}
      onMouseLeave={(e) => {
        (e.currentTarget as HTMLDivElement).style.transform = 'translateY(0)';
        (e.currentTarget as HTMLDivElement).style.boxShadow = T.shadow;
      }}
    >
      <div style={{ display: 'flex', gap: 16, alignItems: 'center' }}>
        <AvatarPlaceholder name={coach.name} />
        <div>
          <h3 style={{ margin: 0, color: T.darkGreen, fontSize: 18 }}>{coach.name}</h3>
          <StarRating rating={coach.rating} />
        </div>
      </div>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
        {coach.specialties.map((s) => (
          <span
            key={s}
            style={{
              background: `${T.green}12`,
              color: T.green,
              fontSize: 12,
              padding: '4px 10px',
              borderRadius: 20,
              fontWeight: 500,
            }}
          >
            {s}
          </span>
        ))}
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ fontSize: 13, color: '#666' }}>
          Zodiac focus: {coach.zodiacExpertise.join(', ')}
        </span>
        <span style={{ fontWeight: 700, color: T.gold, fontSize: 16 }}>
          ${coach.pricePerSession}
        </span>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Coach Detail
// ---------------------------------------------------------------------------

function CoachDetail({
  coach,
  onBack,
  onBook,
}: {
  coach: Coach;
  onBack: () => void;
  onBook: (coach: Coach, type: SessionType, slot: string) => void;
}) {
  const [selectedType, setSelectedType] = useState<SessionType>('natal-reading');
  const [selectedDay, setSelectedDay] = useState<string>(
    coach.availability[0]?.day ?? '',
  );
  const [selectedSlot, setSelectedSlot] = useState<string>('');

  const daySlots =
    coach.availability.find((a) => a.day === selectedDay)?.slots ?? [];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      {/* Back button */}
      <button
        onClick={onBack}
        style={{
          alignSelf: 'flex-start',
          background: 'none',
          border: 'none',
          color: T.gold,
          fontSize: 14,
          fontWeight: 600,
          cursor: 'pointer',
          padding: 0,
        }}
      >
        &larr; Back to coaches
      </button>

      {/* Profile card */}
      <div style={{ ...glassCard, padding: 32 }}>
        <div style={{ display: 'flex', gap: 24, alignItems: 'flex-start', flexWrap: 'wrap' }}>
          <AvatarPlaceholder name={coach.name} size={100} />
          <div style={{ flex: 1, minWidth: 240 }}>
            <h2 style={{ margin: 0, color: T.darkGreen }}>{coach.name}</h2>
            <div style={{ margin: '6px 0 12px' }}>
              <StarRating rating={coach.rating} />
            </div>
            <p style={{ color: '#444', lineHeight: 1.7, margin: 0 }}>{coach.bio}</p>
            <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, marginTop: 16 }}>
              {coach.specialties.map((s) => (
                <span
                  key={s}
                  style={{
                    background: `${T.green}16`,
                    color: T.green,
                    fontSize: 13,
                    padding: '5px 14px',
                    borderRadius: 20,
                    fontWeight: 500,
                  }}
                >
                  {s}
                </span>
              ))}
            </div>
            <p style={{ color: '#888', fontSize: 13, marginTop: 12 }}>
              Zodiac expertise: {coach.zodiacExpertise.join(', ')}
            </p>
          </div>
          <div
            style={{
              textAlign: 'center',
              background: `linear-gradient(135deg, ${T.darkGreen}, ${T.green})`,
              borderRadius: T.radius,
              padding: '20px 28px',
              color: '#fff',
              minWidth: 140,
            }}
          >
            <div style={{ fontSize: 28, fontWeight: 700, color: T.gold }}>
              ${coach.pricePerSession}
            </div>
            <div style={{ fontSize: 13, opacity: 0.8, marginTop: 4 }}>per session</div>
          </div>
        </div>
      </div>

      {/* Session type selector */}
      <div style={{ ...glassCard, padding: 28 }}>
        <h3 style={{ margin: '0 0 16px', color: T.darkGreen }}>Choose session type</h3>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10 }}>
          {SESSION_TYPES.map((st) => {
            const active = st.value === selectedType;
            return (
              <button
                key={st.value}
                onClick={() => setSelectedType(st.value)}
                style={{
                  padding: '10px 18px',
                  borderRadius: T.radiusSm,
                  border: active ? `2px solid ${T.gold}` : `1px solid ${T.glassBorder}`,
                  background: active ? `${T.gold}18` : 'transparent',
                  color: active ? T.darkGreen : '#555',
                  fontWeight: active ? 700 : 500,
                  cursor: 'pointer',
                  fontSize: 14,
                  transition: 'all 0.15s',
                }}
              >
                {st.icon} {st.label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Availability & booking */}
      <div style={{ ...glassCard, padding: 28 }}>
        <h3 style={{ margin: '0 0 16px', color: T.darkGreen }}>Select a time</h3>

        {/* Day pills */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
          {coach.availability.map((a) => {
            const active = a.day === selectedDay;
            return (
              <button
                key={a.day}
                onClick={() => {
                  setSelectedDay(a.day);
                  setSelectedSlot('');
                }}
                style={{
                  padding: '8px 16px',
                  borderRadius: 20,
                  border: 'none',
                  background: active ? T.green : `${T.green}0D`,
                  color: active ? '#fff' : T.green,
                  fontWeight: 600,
                  cursor: 'pointer',
                  fontSize: 13,
                }}
              >
                {a.day}
              </button>
            );
          })}
        </div>

        {/* Slot pills */}
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
          {daySlots.map((slot) => {
            const active = slot === selectedSlot;
            return (
              <button
                key={slot}
                onClick={() => setSelectedSlot(slot)}
                style={{
                  padding: '10px 20px',
                  borderRadius: T.radiusSm,
                  border: active ? `2px solid ${T.gold}` : `1px solid #ddd`,
                  background: active ? `${T.gold}18` : '#fff',
                  color: active ? T.darkGreen : '#444',
                  fontWeight: active ? 700 : 500,
                  cursor: 'pointer',
                  fontSize: 14,
                }}
              >
                {slot}
              </button>
            );
          })}
        </div>

        {/* Book button */}
        <button
          disabled={!selectedSlot}
          onClick={() => onBook(coach, selectedType, selectedSlot)}
          style={{
            marginTop: 24,
            width: '100%',
            padding: '14px 0',
            borderRadius: T.radiusSm,
            border: 'none',
            background: selectedSlot
              ? `linear-gradient(135deg, ${T.gold}, ${T.goldLight})`
              : '#ccc',
            color: selectedSlot ? T.darkGreen : '#888',
            fontWeight: 700,
            fontSize: 16,
            cursor: selectedSlot ? 'pointer' : 'not-allowed',
            transition: 'opacity 0.2s',
          }}
        >
          Book Session &mdash; ${coach.pricePerSession}
        </button>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Booking Confirmation Modal
// ---------------------------------------------------------------------------

function BookingConfirmation({
  coach,
  sessionType,
  slot,
  onConfirm,
  onCancel,
}: {
  coach: Coach;
  sessionType: SessionType;
  slot: string;
  onConfirm: () => void;
  onCancel: () => void;
}) {
  const label = SESSION_TYPES.find((s) => s.value === sessionType)?.label ?? sessionType;
  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        background: 'rgba(10,28,20,0.45)',
        backdropFilter: 'blur(6px)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 1000,
      }}
    >
      <div
        style={{
          ...glassCard,
          background: '#fff',
          padding: 36,
          maxWidth: 420,
          width: '90%',
          textAlign: 'center',
        }}
      >
        <AvatarPlaceholder name={coach.name} size={64} />
        <h3 style={{ color: T.darkGreen, marginTop: 16 }}>Confirm Booking</h3>
        <p style={{ color: '#555', lineHeight: 1.6 }}>
          <strong>{label}</strong> with <strong>{coach.name}</strong>
          <br />
          Time: <strong>{slot}</strong>
          <br />
          Price: <strong>${coach.pricePerSession}</strong>
        </p>
        <div style={{ display: 'flex', gap: 12, marginTop: 24 }}>
          <button
            onClick={onCancel}
            style={{
              flex: 1,
              padding: '12px 0',
              borderRadius: T.radiusSm,
              border: `1px solid #ddd`,
              background: '#fff',
              color: '#666',
              fontWeight: 600,
              cursor: 'pointer',
              fontSize: 14,
            }}
          >
            Cancel
          </button>
          <button
            onClick={onConfirm}
            style={{
              flex: 1,
              padding: '12px 0',
              borderRadius: T.radiusSm,
              border: 'none',
              background: `linear-gradient(135deg, ${T.gold}, ${T.goldLight})`,
              color: T.darkGreen,
              fontWeight: 700,
              cursor: 'pointer',
              fontSize: 14,
            }}
          >
            Confirm
          </button>
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Upcoming Sessions Panel
// ---------------------------------------------------------------------------

function UpcomingSessionsPanel({
  sessions,
  coaches,
  onCancel,
}: {
  sessions: CoachSession[];
  coaches: Coach[];
  onCancel: (id: string) => void;
}) {
  if (sessions.length === 0) return null;
  return (
    <div style={{ ...glassCard, padding: 28 }}>
      <h3 style={{ margin: '0 0 16px', color: T.darkGreen }}>Upcoming Sessions</h3>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {sessions.map((s) => {
          const coach = coaches.find((c) => c.id === s.coachId);
          const label = SESSION_TYPES.find((st) => st.value === s.type)?.label ?? s.type;
          return (
            <div
              key={s.id}
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '14px 18px',
                background: '#fff',
                borderRadius: T.radiusSm,
                border: '1px solid #eee',
              }}
            >
              <div>
                <div style={{ fontWeight: 600, color: T.darkGreen }}>
                  {coach?.name ?? 'Unknown'} &mdash; {label}
                </div>
                <div style={{ fontSize: 13, color: '#888', marginTop: 4 }}>
                  {new Date(s.scheduledAt).toLocaleString()} &middot; {s.duration} min
                </div>
              </div>
              <button
                onClick={() => onCancel(s.id)}
                style={{
                  background: 'none',
                  border: `1px solid #e55`,
                  color: '#e55',
                  padding: '6px 14px',
                  borderRadius: T.radiusSm,
                  cursor: 'pointer',
                  fontWeight: 600,
                  fontSize: 12,
                }}
              >
                Cancel
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Main Page
// ---------------------------------------------------------------------------

type View = 'directory' | 'detail';

export default function CoachPage() {
  const [coaches, setCoaches] = useState<Coach[]>([]);
  const [view, setView] = useState<View>('directory');
  const [selectedCoach, setSelectedCoach] = useState<Coach | null>(null);
  const [upcomingSessions, setUpcomingSessions] = useState<CoachSession[]>([]);
  const [filterText, setFilterText] = useState('');

  // Booking confirmation state
  const [bookingPending, setBookingPending] = useState<{
    coach: Coach;
    type: SessionType;
    slot: string;
  } | null>(null);
  const [bookingSuccess, setBookingSuccess] = useState(false);

  const userId = 'current-user'; // placeholder

  useEffect(() => {
    CoachService.getCoaches().then(setCoaches);
    CoachService.getUpcomingSessions(userId).then(setUpcomingSessions);
  }, []);

  const refreshSessions = () =>
    CoachService.getUpcomingSessions(userId).then(setUpcomingSessions);

  // Filtering
  const filtered = coaches.filter((c) => {
    if (!filterText) return true;
    const q = filterText.toLowerCase();
    return (
      c.name.toLowerCase().includes(q) ||
      c.specialties.some((s) => s.toLowerCase().includes(q)) ||
      c.zodiacExpertise.some((z) => z.toLowerCase().includes(q))
    );
  });

  // Handlers
  const handleSelectCoach = (coach: Coach) => {
    setSelectedCoach(coach);
    setView('detail');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleBookRequest = (coach: Coach, type: SessionType, slot: string) => {
    setBookingPending({ coach, type, slot });
  };

  const handleConfirmBooking = async () => {
    if (!bookingPending) return;
    const { coach, type, slot } = bookingPending;
    // Build a future ISO date from day + slot (next occurrence)
    const now = new Date();
    const dayIndex = [
      'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    ].indexOf(
      coach.availability.find((a) =>
        a.slots.includes(slot),
      )?.day ?? '',
    );
    const diff = ((dayIndex - now.getDay()) + 7) % 7 || 7;
    const target = new Date(now);
    target.setDate(now.getDate() + diff);
    const [h, m] = slot.split(':').map(Number);
    target.setHours(h, m, 0, 0);

    await CoachService.bookSession({
      coachId: coach.id,
      userId,
      scheduledAt: target.toISOString(),
      duration: 60,
      type,
    });

    setBookingPending(null);
    setBookingSuccess(true);
    refreshSessions();
    setTimeout(() => setBookingSuccess(false), 3000);
  };

  const handleCancelSession = async (sessionId: string) => {
    await CoachService.cancelSession(sessionId);
    refreshSessions();
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        background: T.bg,
        fontFamily: T.font,
        color: T.darkGreen,
      }}
    >
      {/* Header */}
      <header
        style={{
          background: `linear-gradient(135deg, ${T.darkGreen}, ${T.green})`,
          padding: '48px 24px 36px',
          textAlign: 'center',
        }}
      >
        <h1
          style={{
            margin: 0,
            color: T.gold,
            fontSize: 32,
            fontWeight: 700,
            letterSpacing: 1,
          }}
        >
          Astrology Coaches
        </h1>
        <p style={{ margin: '8px 0 0', color: 'rgba(255,255,255,0.7)', fontSize: 15 }}>
          Personalised guidance from expert astrologers
        </p>
      </header>

      <main
        style={{
          maxWidth: 960,
          margin: '0 auto',
          padding: '32px 20px 64px',
          display: 'flex',
          flexDirection: 'column',
          gap: 28,
        }}
      >
        {/* Success toast */}
        {bookingSuccess && (
          <div
            style={{
              ...glassCard,
              background: `${T.green}14`,
              border: `1px solid ${T.green}44`,
              padding: '14px 20px',
              color: T.green,
              fontWeight: 600,
              textAlign: 'center',
            }}
          >
            Session booked successfully!
          </div>
        )}

        {/* Upcoming sessions */}
        <UpcomingSessionsPanel
          sessions={upcomingSessions}
          coaches={coaches}
          onCancel={handleCancelSession}
        />

        {view === 'directory' && (
          <>
            {/* Search */}
            <div style={{ ...glassCard, padding: '14px 20px' }}>
              <input
                type="text"
                placeholder="Search coaches by name, specialty, or zodiac sign..."
                value={filterText}
                onChange={(e) => setFilterText(e.target.value)}
                style={{
                  width: '100%',
                  border: 'none',
                  outline: 'none',
                  background: 'transparent',
                  fontSize: 15,
                  color: T.darkGreen,
                  fontFamily: T.font,
                }}
              />
            </div>

            {/* Coach grid */}
            <div
              style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
                gap: 20,
              }}
            >
              {filtered.map((c) => (
                <CoachCard key={c.id} coach={c} onSelect={handleSelectCoach} />
              ))}
            </div>

            {filtered.length === 0 && (
              <p style={{ textAlign: 'center', color: '#999', marginTop: 40 }}>
                No coaches match your search.
              </p>
            )}
          </>
        )}

        {view === 'detail' && selectedCoach && (
          <CoachDetail
            coach={selectedCoach}
            onBack={() => setView('directory')}
            onBook={handleBookRequest}
          />
        )}
      </main>

      {/* Booking confirmation modal */}
      {bookingPending && (
        <BookingConfirmation
          coach={bookingPending.coach}
          sessionType={bookingPending.type}
          slot={bookingPending.slot}
          onConfirm={handleConfirmBooking}
          onCancel={() => setBookingPending(null)}
        />
      )}
    </div>
  );
}
