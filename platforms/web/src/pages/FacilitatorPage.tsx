/**
 * FacilitatorPage.tsx
 * Luminous Cosmic Architecture™ — Web Facilitator
 *
 * Full chat interface with glassmorphic message bubbles,
 * Web Speech API integration, animated cosmic guide avatar,
 * typing indicator, conversation starters, and responsive layout.
 */

import React, {
  useState,
  useEffect,
  useRef,
  useCallback,
  type CSSProperties,
} from 'react';
import { useTheme } from '../hooks/useTheme';
import GlassPanel from '../components/GlassPanel';

// ─────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────

interface Message {
  id: string;
  role: 'user' | 'guide';
  content: string;
  timestamp: number;
  inputMode: 'text' | 'voice';
}

interface ConversationStarter {
  label: string;
  prompt: string;
  icon: string;
}

// ─────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────

const STARTERS: ConversationStarter[] = [
  {
    label: 'Tell me about my chart',
    prompt:
      'I would love to understand my natal chart more deeply. Can you walk me through the key themes?',
    icon: '\u2609',
  },
  {
    label: 'What should I focus on today?',
    prompt:
      'Based on the current transits and my chart, what energies are most relevant for me today?',
    icon: '\u2728',
  },
  {
    label: 'Help me understand my Moon sign',
    prompt:
      'I want to explore what my Moon sign means for my emotional world. Can you guide me?',
    icon: '\u263D',
  },
  {
    label: 'Guide me through a reflection',
    prompt:
      'I would like a guided reflection connecting me with the current cosmic energies.',
    icon: '\u2618',
  },
];

const GUIDE_RESPONSES = [
  "That\u2019s a wonderful question to sit with. Your chart holds layers of meaning that unfold as you engage with them. The Sun illuminates your core vitality, but it\u2019s the Moon that reveals your emotional depths. What feels most alive for you right now?",
  "I appreciate your curiosity. In the cosmic framework, this moment is colored by the current transits \u2014 inviting you to notice where expansion meets your inner knowing. Rather than seeking a definitive answer, let\u2019s explore what resonates.",
  "There\u2019s something profound in what you\u2019re noticing. The astrological tradition would say you\u2019re touching on themes of your chart\u2019s deeper architecture. Trust your own experience. What does your intuition say?",
  "Growth often begins at the edge of what we know. The cosmos doesn\u2019t give easy answers, but it offers lenses \u2014 ways of seeing that illuminate what we might miss. What part of this feels most essential to you?",
  "Let\u2019s take a gentle look at this together. The current lunar energy supports reflective awareness. This isn\u2019t about forcing insight, but about creating space for it to arrive. Take a breath, and notice what surfaces.",
];

// ─────────────────────────────────────────────
// Component
// ─────────────────────────────────────────────

const FacilitatorPage: React.FC = () => {
  const { isDark } = useTheme();
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputText, setInputText] = useState('');
  const [isGuideTyping, setIsGuideTyping] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [voiceMode, setVoiceMode] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);
  const recognitionRef = useRef<SpeechRecognition | null>(null);

  // Auto-scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isGuideTyping]);

  // ── Send Message ──

  const sendMessage = useCallback(
    (text?: string, mode: 'text' | 'voice' = 'text') => {
      const content = (text ?? inputText).trim();
      if (!content) return;
      setInputText('');

      const userMsg: Message = {
        id: `msg-${Date.now()}-${Math.random().toString(36).slice(2)}`,
        role: 'user',
        content,
        timestamp: Date.now(),
        inputMode: mode,
      };
      setMessages((prev) => [...prev, userMsg]);

      // Simulate guide response
      setIsGuideTyping(true);
      const delay = 1000 + Math.random() * 1500;
      setTimeout(() => {
        const response =
          GUIDE_RESPONSES[Math.floor(Math.random() * GUIDE_RESPONSES.length)];
        const guideMsg: Message = {
          id: `msg-${Date.now()}-${Math.random().toString(36).slice(2)}`,
          role: 'guide',
          content: response,
          timestamp: Date.now(),
          inputMode: 'text',
        };
        setIsGuideTyping(false);
        setMessages((prev) => [...prev, guideMsg]);

        // Voice playback
        if (voiceMode && 'speechSynthesis' in window) {
          const utterance = new SpeechSynthesisUtterance(response);
          utterance.rate = 0.92;
          utterance.pitch = 1.05;
          speechSynthesis.speak(utterance);
        }
      }, delay);
    },
    [inputText, voiceMode]
  );

  // ── Voice Input ──

  const toggleRecording = useCallback(() => {
    if (isRecording) {
      recognitionRef.current?.stop();
      setIsRecording(false);
      return;
    }

    const SpeechRecognitionAPI =
      (window as any).SpeechRecognition ||
      (window as any).webkitSpeechRecognition;
    if (!SpeechRecognitionAPI) {
      console.warn('Speech recognition not supported');
      return;
    }

    const recognition = new SpeechRecognitionAPI();
    recognition.continuous = false;
    recognition.interimResults = false;
    recognition.lang = 'en-US';

    recognition.onresult = (event: SpeechRecognitionEvent) => {
      const transcript = event.results[0]?.[0]?.transcript;
      if (transcript) {
        sendMessage(transcript, 'voice');
      }
      setIsRecording(false);
    };

    recognition.onerror = () => setIsRecording(false);
    recognition.onend = () => setIsRecording(false);

    recognitionRef.current = recognition;
    recognition.start();
    setIsRecording(true);
  }, [isRecording, sendMessage]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  // ── Styles ──

  const colors = {
    bg: isDark ? '#05100B' : '#FAFAF8',
    surface: isDark ? 'rgba(10, 28, 20, 0.6)' : 'rgba(250, 250, 248, 0.7)',
    text: isDark ? '#FAFAF8' : '#0A1C14',
    textSecondary: isDark ? '#8A9C91' : '#5C7065',
    textTertiary: isDark ? '#5C7065' : '#8A9C91',
    gold: '#C5A059',
    goldLight: '#E6D0A1',
    goldDark: '#9A7A3A',
    forest: '#122E21',
    border: isDark
      ? '1px solid rgba(197, 160, 89, 0.15)'
      : '1px solid rgba(138, 156, 145, 0.25)',
    userBubble: isDark
      ? 'rgba(197, 160, 89, 0.15)'
      : 'rgba(197, 160, 89, 0.1)',
    guideBubble: isDark
      ? 'rgba(18, 46, 33, 0.5)'
      : 'rgba(18, 46, 33, 0.06)',
  };

  // ── Render ──

  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        minHeight: '100vh',
        maxWidth: '900px',
        margin: '0 auto',
        width: '100%',
        background: colors.bg,
      }}
    >
      {/* Header */}
      <header
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.75rem',
          padding: '0.75rem 1rem',
          borderBottom: colors.border,
          backdropFilter: 'blur(12px)',
          position: 'sticky',
          top: 0,
          zIndex: 10,
          background: isDark ? 'rgba(5, 16, 11, 0.9)' : 'rgba(250, 250, 248, 0.9)',
        }}
      >
        <CosmicAvatar size={36} isActive={isGuideTyping} isDark={isDark} />
        <div style={{ flex: 1 }}>
          <div
            style={{
              fontFamily: "'Cormorant Garamond', serif",
              fontSize: '1.25rem',
              fontWeight: 500,
              color: colors.text,
            }}
          >
            Cosmic Guide
          </div>
          {isGuideTyping && (
            <div
              style={{
                fontSize: '0.7rem',
                color: colors.gold,
                fontStyle: 'italic',
                animation: 'fadeIn 300ms ease both',
              }}
            >
              reflecting...
            </div>
          )}
        </div>
        <button
          onClick={() => setVoiceMode(!voiceMode)}
          title={voiceMode ? 'Disable voice playback' : 'Enable voice playback'}
          aria-label={voiceMode ? 'Disable voice playback' : 'Enable voice playback'}
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            fontSize: '1.2rem',
            color: voiceMode ? colors.gold : colors.textTertiary,
            padding: '0.5rem',
            borderRadius: '50%',
            transition: 'color 200ms ease',
          }}
        >
          {voiceMode ? '\uD83D\uDD0A' : '\uD83D\uDD07'}
        </button>
      </header>

      {/* Messages / Welcome */}
      <div
        style={{
          flex: 1,
          overflowY: 'auto',
          padding: '1rem',
        }}
      >
        {messages.length === 0 ? (
          <WelcomeContent
            starters={STARTERS}
            onSelect={(s) => sendMessage(s.prompt)}
            isDark={isDark}
            colors={colors}
          />
        ) : (
          <div
            style={{
              display: 'flex',
              flexDirection: 'column',
              gap: '0.75rem',
            }}
          >
            {messages.map((msg) => (
              <MessageBubble
                key={msg.id}
                message={msg}
                isDark={isDark}
                colors={colors}
              />
            ))}
            {isGuideTyping && (
              <TypingIndicator isDark={isDark} colors={colors} />
            )}
            <div ref={messagesEndRef} />
          </div>
        )}
      </div>

      {/* Input Bar */}
      <div
        style={{
          borderTop: colors.border,
          padding: '0.75rem 1rem',
          backdropFilter: 'blur(12px)',
          background: isDark ? 'rgba(5, 16, 11, 0.9)' : 'rgba(250, 250, 248, 0.9)',
          display: 'flex',
          alignItems: 'flex-end',
          gap: '0.75rem',
          position: 'sticky',
          bottom: 0,
        }}
      >
        {/* Mic button */}
        <button
          onClick={toggleRecording}
          aria-label={isRecording ? 'Stop recording' : 'Start voice input'}
          style={{
            width: '40px',
            height: '40px',
            borderRadius: '50%',
            border: 'none',
            background: isRecording
              ? 'rgba(197, 160, 89, 0.2)'
              : isDark
              ? 'rgba(255,255,255,0.06)'
              : 'rgba(0,0,0,0.04)',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '1.1rem',
            position: 'relative',
            transition: 'all 200ms ease',
            flexShrink: 0,
            boxShadow: isRecording ? `0 0 0 4px rgba(197, 160, 89, 0.15), 0 0 0 8px rgba(197, 160, 89, 0.08)` : 'none',
            animation: isRecording ? 'micPulse 1.5s ease-in-out infinite' : 'none',
          }}
        >
          {isRecording ? '\uD83C\uDF99\uFE0F' : '\uD83C\uDF99'}
        </button>

        {/* Text input */}
        <div
          style={{
            flex: 1,
            display: 'flex',
            alignItems: 'flex-end',
            gap: '0.5rem',
            background: isDark
              ? 'rgba(10, 28, 20, 0.5)'
              : 'rgba(250, 250, 248, 0.7)',
            backdropFilter: 'blur(8px)',
            border: isDark
              ? '1px solid rgba(197, 160, 89, 0.15)'
              : '1px solid rgba(138, 156, 145, 0.25)',
            borderRadius: '1.5rem',
            padding: '0.5rem 1rem',
            transition: 'border-color 200ms ease',
          }}
        >
          <textarea
            ref={inputRef}
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Ask the cosmos..."
            rows={1}
            aria-label="Message input"
            style={{
              flex: 1,
              background: 'none',
              border: 'none',
              outline: 'none',
              fontFamily: "'Manrope', sans-serif",
              fontSize: '0.95rem',
              color: colors.text,
              resize: 'none',
              lineHeight: 1.5,
              maxHeight: '120px',
              overflow: 'auto',
            }}
          />
          {inputText.trim() && (
            <button
              onClick={() => sendMessage()}
              aria-label="Send message"
              style={{
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                border: 'none',
                background: `linear-gradient(135deg, ${colors.goldDark}, ${colors.gold})`,
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: isDark ? '#05100B' : '#FAFAF8',
                fontSize: '0.9rem',
                flexShrink: 0,
                transition: 'transform 200ms cubic-bezier(0.34, 1.56, 0.64, 1)',
                boxShadow: '0 4px 12px rgba(154, 122, 58, 0.3)',
              }}
              onMouseEnter={(e) =>
                ((e.target as HTMLElement).style.transform = 'scale(1.1)')
              }
              onMouseLeave={(e) =>
                ((e.target as HTMLElement).style.transform = 'scale(1)')
              }
            >
              &#x2191;
            </button>
          )}
        </div>
      </div>

      {/* Injected keyframe styles */}
      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(12px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes micPulse {
          0%, 100% { box-shadow: 0 0 0 4px rgba(197, 160, 89, 0.15), 0 0 0 8px rgba(197, 160, 89, 0.08); }
          50% { box-shadow: 0 0 0 8px rgba(197, 160, 89, 0.2), 0 0 0 16px rgba(197, 160, 89, 0.1); }
        }
        @keyframes typingDot {
          0%, 80%, 100% { transform: scale(0.5); opacity: 0.4; }
          40% { transform: scale(1); opacity: 1; }
        }
        @keyframes avatarRotate {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
        @keyframes avatarPulse {
          0%, 100% { transform: scale(1); }
          50% { transform: scale(1.06); }
        }
        @keyframes avatarGlow {
          0%, 100% { opacity: 0.3; }
          50% { opacity: 0.6; }
        }
      `}</style>
    </div>
  );
};

// ─────────────────────────────────────────────
// Welcome Content
// ─────────────────────────────────────────────

interface WelcomeContentProps {
  starters: ConversationStarter[];
  onSelect: (s: ConversationStarter) => void;
  isDark: boolean;
  colors: Record<string, string>;
}

const WelcomeContent: React.FC<WelcomeContentProps> = ({
  starters,
  onSelect,
  isDark,
  colors,
}) => (
  <div
    style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: '1.5rem',
      padding: '3rem 1rem',
      animation: 'fadeInUp 600ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
    }}
  >
    <CosmicAvatar size={96} isActive isDark={isDark} />

    <div style={{ textAlign: 'center' }}>
      <h2
        style={{
          fontFamily: "'Cormorant Garamond', serif",
          fontSize: '1.75rem',
          fontWeight: 500,
          color: colors.text,
          marginBottom: '0.5rem',
        }}
      >
        Your Cosmic Guide
      </h2>
      <p
        style={{
          fontSize: '0.9rem',
          color: colors.textSecondary,
          lineHeight: 1.7,
          maxWidth: '400px',
          margin: '0 auto',
        }}
      >
        Wise counsel through the language of the stars.
        <br />
        Ask anything about your chart, transits, or inner world.
      </p>
    </div>

    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        gap: '0.6rem',
        width: '100%',
        maxWidth: '460px',
      }}
    >
      {starters.map((s) => (
        <GlassPanel
          key={s.label}
          padding="0.85rem 1rem"
          borderRadius="0.75rem"
          onClick={() => onSelect(s)}
        >
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '0.75rem',
            }}
          >
            <span style={{ fontSize: '1.2rem', width: '28px', textAlign: 'center' }}>
              {s.icon}
            </span>
            <span
              style={{
                flex: 1,
                fontSize: '0.9rem',
                fontWeight: 500,
                color: colors.text,
              }}
            >
              {s.label}
            </span>
            <span style={{ fontSize: '0.75rem', color: colors.gold }}>
              &#x2192;
            </span>
          </div>
        </GlassPanel>
      ))}
    </div>
  </div>
);

// ─────────────────────────────────────────────
// Message Bubble
// ─────────────────────────────────────────────

interface MessageBubbleProps {
  message: Message;
  isDark: boolean;
  colors: Record<string, string>;
}

const MessageBubble: React.FC<MessageBubbleProps> = ({
  message,
  isDark,
  colors,
}) => {
  const isUser = message.role === 'user';
  const time = new Date(message.timestamp).toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
  });

  return (
    <div
      style={{
        display: 'flex',
        justifyContent: isUser ? 'flex-end' : 'flex-start',
        alignItems: 'flex-start',
        gap: '0.5rem',
        animation: 'fadeInUp 350ms cubic-bezier(0.34, 1.56, 0.64, 1) both',
      }}
    >
      {!isUser && <CosmicAvatar size={28} isActive={false} isDark={isDark} />}
      <div
        style={{
          maxWidth: '78%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: isUser ? 'flex-end' : 'flex-start',
        }}
      >
        <div
          style={{
            background: isUser ? colors.userBubble : colors.guideBubble,
            backdropFilter: 'blur(12px)',
            WebkitBackdropFilter: 'blur(12px)',
            border: isUser
              ? '1px solid rgba(197, 160, 89, 0.2)'
              : isDark
              ? '1px solid rgba(138, 156, 145, 0.15)'
              : '1px solid rgba(138, 156, 145, 0.2)',
            borderRadius: '1rem',
            padding: '0.7rem 1rem',
            fontSize: '0.95rem',
            lineHeight: 1.65,
            color: colors.text,
            fontFamily: "'Manrope', sans-serif",
          }}
        >
          {message.content}
        </div>
        <span
          style={{
            fontSize: '0.7rem',
            color: colors.textTertiary,
            padding: '0.15rem 0.3rem',
            marginTop: '2px',
          }}
        >
          {time}
        </span>
      </div>
    </div>
  );
};

// ─────────────────────────────────────────────
// Typing Indicator
// ─────────────────────────────────────────────

interface TypingIndicatorProps {
  isDark: boolean;
  colors: Record<string, string>;
}

const TypingIndicator: React.FC<TypingIndicatorProps> = ({ isDark, colors }) => (
  <div
    style={{
      display: 'flex',
      alignItems: 'flex-start',
      gap: '0.5rem',
      animation: 'fadeIn 300ms ease both',
    }}
  >
    <CosmicAvatar size={28} isActive isDark={isDark} />
    <div
      style={{
        background: colors.guideBubble,
        backdropFilter: 'blur(12px)',
        border: isDark
          ? '1px solid rgba(138, 156, 145, 0.15)'
          : '1px solid rgba(138, 156, 145, 0.2)',
        borderRadius: '1rem',
        padding: '0.85rem 1rem',
        display: 'flex',
        gap: '5px',
        alignItems: 'center',
      }}
    >
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          style={{
            width: '7px',
            height: '7px',
            borderRadius: '50%',
            background: colors.gold,
            opacity: 0.6,
            animation: `typingDot 1.4s ease-in-out ${i * 0.2}s infinite`,
          }}
        />
      ))}
    </div>
  </div>
);

// ─────────────────────────────────────────────
// Cosmic Avatar (CSS animated)
// ─────────────────────────────────────────────

interface CosmicAvatarProps {
  size: number;
  isActive: boolean;
  isDark: boolean;
}

const CosmicAvatar: React.FC<CosmicAvatarProps> = ({ size, isActive, isDark }) => {
  const outerSize = size * 1.3;
  return (
    <div
      style={{
        width: `${outerSize}px`,
        height: `${outerSize}px`,
        position: 'relative',
        flexShrink: 0,
        animation: isActive ? 'avatarPulse 3s ease-in-out infinite' : undefined,
      }}
      role="img"
      aria-label="Cosmic Guide"
    >
      {/* Glow */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          borderRadius: '50%',
          background: `radial-gradient(circle, rgba(197, 160, 89, ${isActive ? 0.25 : 0.1}) 30%, transparent 70%)`,
          animation: isActive ? 'avatarGlow 3s ease-in-out infinite' : undefined,
        }}
      />
      {/* Ring */}
      <div
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          width: `${size}px`,
          height: `${size}px`,
          marginTop: `${-size / 2}px`,
          marginLeft: `${-size / 2}px`,
          borderRadius: '50%',
          border: '2px solid transparent',
          backgroundImage: `conic-gradient(from 0deg, #9A7A3A, #C5A059, #E6D0A1, #C5A059, #9A7A3A)`,
          backgroundOrigin: 'border-box',
          backgroundClip: 'border-box',
          WebkitMask:
            'linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0)',
          WebkitMaskComposite: 'xor',
          maskComposite: 'exclude',
          padding: `${Math.max(1, size * 0.05)}px`,
          animation: 'avatarRotate 20s linear infinite',
        }}
      />
      {/* Inner star symbol */}
      <svg
        viewBox="0 0 24 24"
        width={size * 0.45}
        height={size * 0.45}
        style={{
          position: 'absolute',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      >
        <path
          d={generateStarPath(12, 12, 10, 4.5, 8)}
          fill="#C5A059"
          opacity={isActive ? 0.75 : 0.5}
        />
      </svg>
    </div>
  );
};

function generateStarPath(
  cx: number,
  cy: number,
  outerR: number,
  innerR: number,
  points: number
): string {
  const parts: string[] = [];
  for (let i = 0; i < points; i++) {
    const outerAngle = (i / points) * Math.PI * 2 - Math.PI / 2;
    const innerAngle = ((i + 0.5) / points) * Math.PI * 2 - Math.PI / 2;
    const ox = cx + Math.cos(outerAngle) * outerR;
    const oy = cy + Math.sin(outerAngle) * outerR;
    const ix = cx + Math.cos(innerAngle) * innerR;
    const iy = cy + Math.sin(innerAngle) * innerR;
    parts.push(i === 0 ? `M${ox},${oy}` : `L${ox},${oy}`);
    parts.push(`L${ix},${iy}`);
  }
  parts.push('Z');
  return parts.join(' ');
}

export default FacilitatorPage;
