import React, { useState, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  Dimensions,
  Platform,
  Alert,
} from 'react-native';
import { useTheme, Colors } from '../App';
import {
  QuoteCard,
  InsightCard,
  ProgressCard,
  JournalExcerptCard,
  MilestoneCard,
  ShareCardData,
} from '../components/SocialShareCards';
import { SharingService, SocialPlatform } from '../services/SharingService';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

// ---------------------------------------------------------------------------
// Sample share cards
// ---------------------------------------------------------------------------

const sampleCards: ShareCardData[] = [
  {
    type: 'quote',
    title: 'Daily Wisdom',
    body: 'The wound is the place where the Light enters you.',
    author: 'Rumi',
    subtitle: 'From Luminous Attachment',
  },
  {
    type: 'insight',
    title: "Today's Insight",
    body: 'Your need to fix others may be a way of managing your own anxiety. True compassion begins with self-compassion.',
    subtitle: 'Chapter 3: Roots & Soil',
  },
  {
    type: 'progress',
    title: 'My Journey',
    body: '12-day streak',
    stat: '12',
    subtitle: '4 chapters \u2022 23 journal entries \u2022 8 coaching sessions',
    emoji: '\uD83D\uDD25',
  },
  {
    type: 'journal_excerpt',
    title: 'From My Journal',
    body: 'I caught myself mid-reaction and actually paused. The old me would have fired back immediately but I felt the anger, named it, and chose differently.',
    subtitle: 'A moment of growth',
  },
  {
    type: 'milestone',
    title: 'Milestone Reached',
    body: 'Completed Chapter 3: Roots & Soil',
    stat: '3/12',
    subtitle: 'Understanding my foundation',
    emoji: '\u2728',
  },
];

// ---------------------------------------------------------------------------
// Platform configs
// ---------------------------------------------------------------------------

const platforms: Array<{
  platform: SocialPlatform;
  label: string;
  icon: string;
  color: string;
}> = [
  { platform: 'twitter', label: 'X / Twitter', icon: '\uD83D\uDC26', color: '#1DA1F2' },
  { platform: 'instagram', label: 'Instagram', icon: '\uD83D\uDCF7', color: '#E4405F' },
  { platform: 'instagram_stories', label: 'IG Stories', icon: '\uD83C\uDF1F', color: '#C13584' },
  { platform: 'tiktok', label: 'TikTok', icon: '\uD83C\uDFB5', color: '#010101' },
  { platform: 'facebook', label: 'Facebook', icon: '\uD83D\uDC64', color: '#1877F2' },
  { platform: 'whatsapp', label: 'WhatsApp', icon: '\uD83D\uDCAC', color: '#25D366' },
  { platform: 'telegram', label: 'Telegram', icon: '\u2708', color: '#0088CC' },
  { platform: 'pinterest', label: 'Pinterest', icon: '\uD83D\uDCCC', color: '#BD081C' },
  { platform: 'linkedin', label: 'LinkedIn', icon: '\uD83D\uDCBC', color: '#0A66C2' },
  { platform: 'threads', label: 'Threads', icon: '@', color: '#000000' },
  { platform: 'snapchat', label: 'Snapchat', icon: '\uD83D\uDC7B', color: '#FFFC00' },
  { platform: 'reddit', label: 'Reddit', icon: '\uD83E\uDD16', color: '#FF4500' },
  { platform: 'email', label: 'Email', icon: '\u2709', color: '#666666' },
  { platform: 'sms', label: 'iMessage', icon: '\uD83D\uDCF1', color: '#34C759' },
  { platform: 'copy', label: 'Copy Link', icon: '\uD83D\uDCCB', color: '#888888' },
  { platform: 'more', label: 'More...', icon: '\u2022\u2022\u2022', color: '#AAAAAA' },
];

const quickSharePlatforms = platforms.filter((p) =>
  ['instagram_stories', 'twitter', 'whatsapp', 'facebook'].includes(p.platform),
);

// ---------------------------------------------------------------------------
// Share Screen
// ---------------------------------------------------------------------------

const ShareScreen: React.FC = () => {
  const { theme } = useTheme();
  const [selectedIndex, setSelectedIndex] = useState(0);
  const selectedCard = sampleCards[selectedIndex];
  const sharingService = useRef(new SharingService()).current;

  const handleShare = async (platform: SocialPlatform) => {
    try {
      await sharingService.share(platform, selectedCard);
    } catch (err) {
      Alert.alert('Sharing', 'Opening share sheet...');
    }
  };

  // Card component selector
  const renderFullCard = () => {
    switch (selectedCard.type) {
      case 'quote':
        return <QuoteCard data={selectedCard} />;
      case 'insight':
        return <InsightCard data={selectedCard} />;
      case 'progress':
        return <ProgressCard data={selectedCard} />;
      case 'journal_excerpt':
        return <JournalExcerptCard data={selectedCard} />;
      case 'milestone':
        return <MilestoneCard data={selectedCard} />;
      default:
        return <QuoteCard data={selectedCard} />;
    }
  };

  return (
    <ScrollView
      style={[sStyles.container, { backgroundColor: theme.bg }]}
      contentContainerStyle={sStyles.scrollContent}
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={sStyles.header}>
        <Text style={[sStyles.heading, { color: theme.textPrimary }]}>
          Share Your Light
        </Text>
        <Text style={{ color: Colors.goldPrimary, fontSize: 14 }}>
          Create beautiful cards to inspire others
        </Text>
      </View>

      {/* Card carousel */}
      <Text style={[sStyles.sectionLabel, { color: theme.textSecondary }]}>
        Choose a card
      </Text>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={sStyles.carouselContent}
      >
        {sampleCards.map((card, idx) => {
          const isSelected = idx === selectedIndex;
          const bgColors: Record<string, string> = {
            quote: Colors.green800,
            insight: Colors.green700,
            progress: Colors.goldDark,
            journal_excerpt: Colors.green900,
            milestone: Colors.goldPrimary,
          };

          return (
            <TouchableOpacity
              key={idx}
              style={[
                sStyles.thumbnail,
                { backgroundColor: bgColors[card.type] || Colors.green700 },
                isSelected && { borderColor: Colors.goldPrimary, borderWidth: 2 },
              ]}
              onPress={() => setSelectedIndex(idx)}
            >
              <Text style={sStyles.thumbLabel}>{card.title}</Text>
              {card.emoji && <Text style={{ fontSize: 24 }}>{card.emoji}</Text>}
              <Text style={sStyles.thumbBody} numberOfLines={3}>
                {card.body}
              </Text>
              <Text style={sStyles.thumbBrand}>Resonance</Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      {/* Full preview */}
      <Text style={[sStyles.sectionLabel, { color: theme.textSecondary }]}>
        Preview
      </Text>
      <View style={sStyles.previewContainer}>{renderFullCard()}</View>

      {/* Platform grid */}
      <Text style={[sStyles.sectionLabel, { color: theme.textSecondary }]}>
        Share to
      </Text>
      <View style={sStyles.platformGrid}>
        {platforms.map((p) => (
          <TouchableOpacity
            key={p.platform}
            style={sStyles.platformItem}
            onPress={() => handleShare(p.platform)}
          >
            <View
              style={[sStyles.platformCircle, { backgroundColor: p.color + '25' }]}
            >
              <Text style={{ fontSize: 20 }}>{p.icon}</Text>
            </View>
            <Text
              style={[sStyles.platformLabel, { color: theme.textSecondary }]}
              numberOfLines={1}
            >
              {p.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Quick share */}
      <View style={sStyles.quickRow}>
        {quickSharePlatforms.map((p) => (
          <TouchableOpacity
            key={p.platform}
            style={[sStyles.quickBtn, { backgroundColor: p.color + '20' }]}
            onPress={() => handleShare(p.platform)}
          >
            <Text style={{ fontSize: 14 }}>{p.icon}</Text>
            <Text
              style={{ color: p.color, fontSize: 11, marginLeft: 4, fontWeight: '600' }}
              numberOfLines={1}
            >
              {p.label.split(' ')[0]}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Branding note */}
      <Text style={[sStyles.brandingNote, { color: theme.textSecondary + '80' }]}>
        All cards include subtle Resonance branding and app store links
      </Text>
    </ScrollView>
  );
};

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

const sStyles = StyleSheet.create({
  container: { flex: 1 },
  scrollContent: { paddingBottom: 32 },

  header: {
    paddingHorizontal: 20,
    paddingTop: Platform.OS === 'ios' ? 60 : 16,
    marginBottom: 20,
  },
  heading: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 28,
    fontWeight: '700',
  },

  sectionLabel: { fontSize: 13, fontWeight: '500', paddingHorizontal: 20, marginBottom: 8 },

  carouselContent: { paddingHorizontal: 20, gap: 14, marginBottom: 24 },
  thumbnail: {
    width: 140,
    height: 180,
    borderRadius: 16,
    padding: 12,
    justifyContent: 'space-between',
  },
  thumbLabel: { color: Colors.goldLight, fontSize: 10, fontWeight: '600' },
  thumbBody: { color: '#fff', fontSize: 11, lineHeight: 14 },
  thumbBrand: { color: Colors.goldPrimary + '90', fontSize: 8 },

  previewContainer: { paddingHorizontal: 20, marginBottom: 24 },

  platformGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  platformItem: {
    width: '25%',
    alignItems: 'center',
    marginBottom: 16,
  },
  platformCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  platformLabel: { fontSize: 10, marginTop: 4, textAlign: 'center' },

  quickRow: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    gap: 8,
    marginBottom: 12,
  },
  quickBtn: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 10,
    borderRadius: 12,
  },

  brandingNote: {
    textAlign: 'center',
    fontSize: 11,
    paddingHorizontal: 40,
  },
});

export default ShareScreen;
