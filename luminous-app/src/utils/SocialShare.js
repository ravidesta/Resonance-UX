/**
 * Social Sharing — Wonton sharing of beautiful things
 *
 * Every beautiful moment in the app becomes shareable content.
 * Free advertising through genuine luminosity.
 */

import { Share, Platform } from 'react-native';

const APP_URL = 'https://luminous.life';
const HASHTAGS = '#LuminousLifewheel #Luminous #NDHA #Resonance';

// ─── Share Content Generators ───

export const shareContent = {
  // Lifewheel results
  lifewheelResults: (scores) => {
    const avg = Object.values(scores).reduce((a, b) => a + b, 0) / Object.values(scores).length;
    const top = Object.entries(scores).sort(([,a], [,b]) => b - a)[0];
    const dimensionNames = {
      physical: 'Physical Vitality 🌿',
      emotional: 'Emotional Well-Being 🌊',
      mental: 'Mental Clarity 🧠',
      spiritual: 'Spiritual Connection ✨',
      relationships: 'Relationships 💛',
      purpose: 'Purpose & Contribution 🔥',
      creative: 'Creative Expression 🎨',
      environment: 'Environment & Resources 🏡',
    };
    return {
      title: 'My Luminous Lifewheel',
      message: `🌀 I just completed my Luminous Lifewheel Assessment!\n\nMy brightest dimension: ${dimensionNames[top[0]]} (${top[1]}/10)\nOverall luminosity: ${avg.toFixed(1)}/10\n\nYou are already luminous. ✨\n\nDiscover yours → ${APP_URL}\n\n${HASHTAGS}`,
    };
  },

  // Individual dimension score
  dimensionScore: (dimension, score) => ({
    title: `My ${dimension.label} Score`,
    message: `${dimension.emoji} My ${dimension.label} is at ${score}/10 on the Luminous Lifewheel!\n\n"${dimension.description}"\n\nWhat would your score be? → ${APP_URL}\n\n${HASHTAGS}`,
  }),

  // Luminous quotes
  quote: (quoteText, source = 'The Luminous Lifewheel') => ({
    title: 'Luminous Wisdom',
    message: `✨ "${quoteText}"\n\n— ${source}\n\n${APP_URL}\n${HASHTAGS}`,
  }),

  // Daily check-in completion
  dailyCheckin: (checkinWords, gratitude) => {
    const wordsSummary = Object.entries(checkinWords)
      .map(([key, word]) => word)
      .filter(Boolean)
      .join(' · ');
    return {
      title: 'Daily Luminous Check-In',
      message: `☀️ Daily Luminous Check-In complete!\n\n${wordsSummary ? `Today I feel: ${wordsSummary}\n\n` : ''}${gratitude ? `Grateful for: ${gratitude}\n\n` : ''}Arrive. Notice. Appreciate. Done. ✓\n\n${APP_URL}\n${HASHTAGS}`,
    };
  },

  // Journal prompt
  journalPrompt: (prompt) => ({
    title: 'Luminous Journal Prompt',
    message: `📝 Today's luminous journal prompt:\n\n"${prompt}"\n\nWhat would you write? ✨\n\n${APP_URL}\n${HASHTAGS}`,
  }),

  // Daily flow progress
  dailyFlowProgress: (completedCount, totalTasks, currentPhase) => {
    const phaseEmojis = { ascend: '🌅', zenith: '☀️', descent: '🌇', rest: '🌙' };
    return {
      title: 'Daily Flow Progress',
      message: `${phaseEmojis[currentPhase] || '✨'} ${completedCount}/${totalTasks} seeds planted today in the ${currentPhase} phase!\n\nEnergy-aligned living — working with my natural rhythm, not against it.\n\n${APP_URL}\n${HASHTAGS}`,
    };
  },

  // Community circle
  communityCircle: (circle) => ({
    title: `Join ${circle.name}`,
    message: `🔮 ${circle.emoji} ${circle.name}\n\n${circle.focus}\n\n👥 ${circle.members} luminous souls growing together\n\nNext session: ${circle.nextSession}\n\nJoin us → ${APP_URL}/community\n\n${HASHTAGS}`,
  }),

  // Event
  communityEvent: (event) => ({
    title: event.title,
    message: `${event.emoji} ${event.title}\n\n📅 ${event.date}\n\nTransformation happens in community. ✨\n\nRSVP → ${APP_URL}/events\n\n${HASHTAGS}`,
  }),

  // Discussion thread
  discussionThread: (discussion) => ({
    title: discussion.topic,
    message: `💬 "${discussion.topic}"\n\n— ${discussion.author} in the Luminous Community\n💬 ${discussion.replies} replies and counting\n\nJoin the conversation → ${APP_URL}/community\n\n${HASHTAGS}`,
  }),

  // Book recommendation
  bookRecommendation: (book) => ({
    title: book.title,
    message: `📚 Reading: "${book.title}" — ${book.subtitle}\n\n${book.description}\n\n${book.format === 'audiobook' ? '🎧 Also available as audiobook!' : ''}\n\nExplore the Luminous Library → ${APP_URL}/library\n\n${HASHTAGS}`,
  }),

  // Phase wisdom
  phaseWisdom: (phase) => {
    const wisdoms = {
      ascend: { emoji: '🌅', text: 'The morning is for rising — fresh clarity, new possibility. What wants to emerge today?' },
      zenith: { emoji: '☀️', text: 'Peak vitality, deep work, full expression. The sun is high and so am I.' },
      descent: { emoji: '🌇', text: 'Gentle winding, sweet connection. The day\'s gifts are being gathered.' },
      rest: { emoji: '🌙', text: 'Deep restoration, dreaming, integration. Even the earth rests in winter.' },
    };
    const w = wisdoms[phase.key] || wisdoms.ascend;
    return {
      title: `${phase.label} Phase`,
      message: `${w.emoji} ${phase.label} Phase (${phase.time})\n\n"${w.text}"\n\nLiving in rhythm with your energy. ✨\n\n${APP_URL}\n${HASHTAGS}`,
    };
  },

  // 5D Partner invitation
  quantumPartner: () => ({
    title: 'Find Your 5D Quantum Partner',
    message: `🔮 Looking for my 5D Quantum Partner!\n\n"Together, you turn lead into gold. Together, you see in each other what you cannot yet see in yourselves."\n\nDiscover → Dream → Design → Deliver → Delight\n\n${APP_URL}/partner\n\n${HASHTAGS}`,
  }),

  // General app share
  appInvite: () => ({
    title: 'The Luminous Lifewheel',
    message: `✨ You are already luminous.\n\nThe Luminous Lifewheel — an 8-dimension assessment for conscious evolution, energy-aligned daily flow, and transformative community.\n\n🌀 Lifewheel Assessment\n📝 Luminous Journal\n🌊 Daily Flow\n💛 Community Circles\n📚 Library & Audiobooks\n🔮 5D Quantum Partner\n\nDownload → ${APP_URL}\n\n${HASHTAGS}`,
  }),

  // Gratitude
  gratitude: (text) => ({
    title: 'Luminous Gratitude',
    message: `🙏 Today I'm grateful for:\n\n"${text}"\n\nWhat are you grateful for? ✨\n\n${APP_URL}\n${HASHTAGS}`,
  }),

  // Workbook progress
  workbookProgress: (partsCompleted, totalParts) => ({
    title: 'Luminous Workbook Progress',
    message: `📖 ${partsCompleted}/${totalParts} parts complete in The Luminous Lifewheel Workbook!\n\nEvery exercise is a conversation with your deeper wisdom. ✨\n\n${APP_URL}/library\n\n${HASHTAGS}`,
  }),
};

// ─── Share Action ───

export async function shareLuminous(content) {
  try {
    const result = await Share.share(
      {
        title: content.title,
        message: content.message,
        ...(Platform.OS === 'web' ? { url: APP_URL } : {}),
      },
      {
        subject: content.title,
        dialogTitle: `Share ${content.title}`,
        ...(Platform.OS === 'ios' ? {
          excludedActivityTypes: [],
        } : {}),
      }
    );

    if (result.action === Share.sharedAction) {
      return { shared: true, activityType: result.activityType };
    }
    return { shared: false };
  } catch (error) {
    console.warn('Share failed:', error);
    return { shared: false, error };
  }
}

// ─── Platform-specific deep link URLs for social media ───

export function getSocialLinks(content) {
  const encoded = encodeURIComponent(content.message);
  const encodedUrl = encodeURIComponent(APP_URL);
  const encodedTitle = encodeURIComponent(content.title);

  return {
    twitter: `https://twitter.com/intent/tweet?text=${encoded}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}&quote=${encoded}`,
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`,
    whatsapp: `https://wa.me/?text=${encoded}`,
    telegram: `https://t.me/share/url?url=${encodedUrl}&text=${encoded}`,
    email: `mailto:?subject=${encodedTitle}&body=${encoded}`,
    threads: `https://threads.net/intent/post?text=${encoded}`,
    pinterest: `https://pinterest.com/pin/create/button/?url=${encodedUrl}&description=${encoded}`,
    reddit: `https://reddit.com/submit?url=${encodedUrl}&title=${encodedTitle}`,
  };
}
