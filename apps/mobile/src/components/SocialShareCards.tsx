import React from 'react';
import { View, Text, StyleSheet, Dimensions, Platform } from 'react-native';
import { Colors } from '../App';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

// ---------------------------------------------------------------------------
// Shared types
// ---------------------------------------------------------------------------

export interface ShareCardData {
  type: 'quote' | 'insight' | 'progress' | 'journal_excerpt' | 'milestone' | 'mood';
  title: string;
  body: string;
  subtitle?: string;
  author?: string;
  stat?: string;
  emoji?: string;
}

// ---------------------------------------------------------------------------
// Brand footer (appears on every card)
// ---------------------------------------------------------------------------

const BrandFooter: React.FC<{ light?: boolean }> = ({ light = true }) => (
  <View style={cardStyles.footer}>
    <View style={[cardStyles.divider, { backgroundColor: light ? Colors.goldPrimary + '30' : Colors.goldPrimary + '20' }]} />
    <View style={cardStyles.footerRow}>
      <View>
        <Text style={[cardStyles.brandName, { color: Colors.goldPrimary }]}>
          Luminous Attachment
        </Text>
        <Text style={[cardStyles.brandSub, { color: light ? Colors.goldLight + '80' : Colors.goldPrimary + '60' }]}>
          by Resonance UX
        </Text>
      </View>
      <View style={{ alignItems: 'flex-end' }}>
        <Text style={[cardStyles.appLink, { color: Colors.goldPrimary + '90' }]}>
          resonance.app
        </Text>
        <Text style={[cardStyles.storeLink, { color: light ? Colors.goldLight + '60' : Colors.goldPrimary + '40' }]}>
          App Store {'\u2022'} Google Play
        </Text>
      </View>
    </View>
  </View>
);

// ---------------------------------------------------------------------------
// Gold accent bar
// ---------------------------------------------------------------------------

const GoldBar: React.FC = () => (
  <View style={cardStyles.goldBar} />
);

// ---------------------------------------------------------------------------
// 1. Quote Card
// ---------------------------------------------------------------------------

export const QuoteCard: React.FC<{ data: ShareCardData }> = ({ data }) => (
  <View style={[cardStyles.card, { backgroundColor: Colors.green900 }]}>
    {/* Organic blob overlay */}
    <View style={[cardStyles.blob, { top: '10%', left: '5%', backgroundColor: Colors.goldPrimary + '15' }]} />
    <View style={[cardStyles.blob, cardStyles.blobSmall, { bottom: '15%', right: '10%', backgroundColor: Colors.green400 + '12' }]} />

    <Text style={cardStyles.topLabel}>{data.title}</Text>
    <GoldBar />

    <Text style={cardStyles.quoteText}>
      {'\u201C'}{data.body}{'\u201D'}
    </Text>

    {data.author && (
      <Text style={cardStyles.authorText}>
        {'\u2014'} {data.author}
      </Text>
    )}

    {data.subtitle && (
      <Text style={cardStyles.subtitleText}>{data.subtitle}</Text>
    )}

    <BrandFooter />
  </View>
);

// ---------------------------------------------------------------------------
// 2. Insight Card
// ---------------------------------------------------------------------------

export const InsightCard: React.FC<{ data: ShareCardData }> = ({ data }) => (
  <View style={[cardStyles.card, { backgroundColor: Colors.green800 }]}>
    <View style={[cardStyles.blob, { top: '20%', right: '5%', backgroundColor: Colors.goldPrimary + '12' }]} />
    <View style={[cardStyles.blob, cardStyles.blobSmall, { bottom: '25%', left: '8%', backgroundColor: Colors.green500 + '15' }]} />

    <Text style={cardStyles.topLabel}>{data.title}</Text>
    <GoldBar />

    <Text style={cardStyles.insightBody}>{data.body}</Text>

    {data.subtitle && (
      <Text style={[cardStyles.subtitleText, { marginTop: 12 }]}>
        {data.subtitle}
      </Text>
    )}

    <BrandFooter />
  </View>
);

// ---------------------------------------------------------------------------
// 3. Progress Card
// ---------------------------------------------------------------------------

export const ProgressCard: React.FC<{ data: ShareCardData }> = ({ data }) => (
  <View
    style={[
      cardStyles.card,
      {
        backgroundColor: Colors.green900,
        borderColor: Colors.goldPrimary + '30',
        borderWidth: 1,
      },
    ]}
  >
    <View style={[cardStyles.blob, { top: '5%', left: '15%', backgroundColor: Colors.goldDark + '20' }]} />

    <Text style={cardStyles.topLabel}>{data.title}</Text>
    <GoldBar />

    {data.emoji && <Text style={cardStyles.bigEmoji}>{data.emoji}</Text>}

    <Text style={cardStyles.progressStat}>{data.body}</Text>

    {data.subtitle && (
      <Text style={[cardStyles.subtitleText, { marginTop: 8, lineHeight: 20 }]}>
        {data.subtitle}
      </Text>
    )}

    {/* Progress bar */}
    <View style={cardStyles.progressBarBg}>
      <View
        style={[
          cardStyles.progressBarFill,
          { width: `${(4 / 12) * 100}%` },
        ]}
      />
    </View>
    <Text style={cardStyles.progressBarLabel}>4 of 12 chapters complete</Text>

    <BrandFooter />
  </View>
);

// ---------------------------------------------------------------------------
// 4. Journal Excerpt Card
// ---------------------------------------------------------------------------

export const JournalExcerptCard: React.FC<{ data: ShareCardData }> = ({ data }) => (
  <View style={[cardStyles.card, { backgroundColor: Colors.bgDark }]}>
    <View style={[cardStyles.blob, { top: '15%', left: '5%', backgroundColor: Colors.green600 + '18' }]} />

    <Text style={cardStyles.topLabel}>{data.title}</Text>
    <GoldBar />

    <View style={cardStyles.excerptQuoteBar}>
      <View style={cardStyles.excerptBar} />
      <Text style={cardStyles.excerptBody}>{data.body}</Text>
    </View>

    {data.subtitle && (
      <Text style={[cardStyles.subtitleText, { marginTop: 12, fontStyle: 'italic' }]}>
        {data.subtitle}
      </Text>
    )}

    <BrandFooter />
  </View>
);

// ---------------------------------------------------------------------------
// 5. Milestone Card
// ---------------------------------------------------------------------------

export const MilestoneCard: React.FC<{ data: ShareCardData }> = ({ data }) => (
  <View
    style={[
      cardStyles.card,
      {
        backgroundColor: Colors.green800,
        borderColor: Colors.goldPrimary + '25',
        borderWidth: 1,
      },
    ]}
  >
    <View style={[cardStyles.blob, { top: '10%', right: '10%', backgroundColor: Colors.goldPrimary + '15' }]} />
    <View style={[cardStyles.blob, cardStyles.blobSmall, { bottom: '20%', left: '5%', backgroundColor: Colors.green400 + '10' }]} />

    <Text style={cardStyles.topLabel}>{data.title}</Text>
    <GoldBar />

    {data.emoji && <Text style={cardStyles.bigEmoji}>{data.emoji}</Text>}

    <Text style={cardStyles.milestoneBody}>{data.body}</Text>

    {data.stat && (
      <View style={cardStyles.milestoneStatRow}>
        <Text style={cardStyles.milestoneStat}>{data.stat}</Text>
        <Text style={cardStyles.milestoneStatLabel}>chapters</Text>
      </View>
    )}

    {data.subtitle && (
      <Text style={[cardStyles.subtitleText, { marginTop: 8 }]}>
        {data.subtitle}
      </Text>
    )}

    <BrandFooter />
  </View>
);

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

const cardStyles = StyleSheet.create({
  card: {
    borderRadius: 24,
    padding: 28,
    overflow: 'hidden',
    // Shadow for the card
    ...(Platform.OS === 'ios'
      ? { shadowColor: '#000', shadowOpacity: 0.15, shadowRadius: 16, shadowOffset: { width: 0, height: 8 } }
      : { elevation: 8 }),
  },

  // Blobs
  blob: {
    position: 'absolute',
    width: 200,
    height: 200,
    borderRadius: 100,
  },
  blobSmall: { width: 140, height: 140, borderRadius: 70 },

  // Top label
  topLabel: {
    color: Colors.goldLight,
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.5,
    marginBottom: 6,
  },

  // Gold bar
  goldBar: {
    width: 32,
    height: 2,
    backgroundColor: Colors.goldPrimary,
    borderRadius: 1,
    marginBottom: 20,
  },

  // Quote
  quoteText: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 22,
    fontStyle: 'italic',
    lineHeight: 32,
    color: '#FFFFFF',
    marginBottom: 8,
  },
  authorText: {
    color: Colors.goldPrimary,
    fontSize: 14,
    marginBottom: 12,
  },

  // Insight
  insightBody: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 18,
    lineHeight: 28,
    color: '#FFFFFF',
  },

  // Subtitle (shared)
  subtitleText: {
    color: Colors.goldLight + 'B0',
    fontSize: 12,
    lineHeight: 18,
  },

  // Progress
  bigEmoji: { fontSize: 40, marginBottom: 12 },
  progressStat: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 28,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  progressBarBg: {
    height: 6,
    backgroundColor: Colors.goldPrimary + '25',
    borderRadius: 3,
    marginTop: 16,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: Colors.goldPrimary,
    borderRadius: 3,
  },
  progressBarLabel: {
    color: Colors.goldLight + '80',
    fontSize: 10,
    marginTop: 4,
  },

  // Journal excerpt
  excerptQuoteBar: { flexDirection: 'row' },
  excerptBar: {
    width: 3,
    backgroundColor: Colors.goldPrimary,
    borderRadius: 1.5,
    marginRight: 14,
  },
  excerptBody: {
    flex: 1,
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 17,
    fontStyle: 'italic',
    lineHeight: 26,
    color: '#FFFFFF',
  },

  // Milestone
  milestoneBody: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 20,
    fontWeight: '600',
    lineHeight: 28,
    color: '#FFFFFF',
  },
  milestoneStatRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginTop: 8,
  },
  milestoneStat: {
    fontSize: 36,
    fontWeight: '700',
    color: Colors.goldPrimary,
  },
  milestoneStatLabel: {
    color: Colors.goldLight + '80',
    fontSize: 14,
    marginLeft: 6,
  },

  // Footer
  footer: { marginTop: 24 },
  divider: { height: 1, marginBottom: 12 },
  footerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
  },
  brandName: { fontSize: 12, fontWeight: '600' },
  brandSub: { fontSize: 10, marginTop: 1 },
  appLink: { fontSize: 10 },
  storeLink: { fontSize: 8, marginTop: 1 },
});
