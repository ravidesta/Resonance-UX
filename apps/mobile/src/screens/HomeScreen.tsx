import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Easing,
  Dimensions,
  Platform,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { useTheme, Colors } from '../App';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

interface DailyInsight {
  quote: string;
  author: string;
  reflection: string;
  chapter: string;
}

const dailyInsight: DailyInsight = {
  quote: 'The wound is the place where the Light enters you.',
  author: 'Rumi',
  reflection:
    'Consider today how your most painful experiences have opened doors to deeper understanding.',
  chapter: 'Chapter 4: Embracing Shadow',
};

const moodOptions = [
  { emoji: '\uD83D\uDE14', label: 'Low' },
  { emoji: '\uD83D\uDE10', label: 'Flat' },
  { emoji: '\uD83D\uDE42', label: 'Calm' },
  { emoji: '\uD83D\uDE0A', label: 'Good' },
  { emoji: '\u2728',       label: 'Radiant' },
];

const stats = [
  { icon: '\uD83D\uDD25', value: '12 days', label: 'Streak' },
  { icon: '\uD83D\uDCD6', value: '4 / 12',  label: 'Chapters' },
  { icon: '\u270E',       value: '23',       label: 'Entries' },
  { icon: '\uD83D\uDCAC', value: '8',        label: 'Sessions' },
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function timeOfDay(): string {
  const h = new Date().getHours();
  if (h < 12) return 'morning';
  if (h < 17) return 'afternoon';
  return 'evening';
}

// ---------------------------------------------------------------------------
// Glass card wrapper
// ---------------------------------------------------------------------------

const GlassCard: React.FC<{
  children: React.ReactNode;
  style?: object;
}> = ({ children, style }) => {
  const { theme } = useTheme();
  return (
    <View
      style={[
        styles.glassCard,
        {
          backgroundColor: theme.glassSurface,
          borderColor: theme.glassBorder,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
};

// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------

const HomeScreen: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const navigation = useNavigation<any>();
  const [selectedMood, setSelectedMood] = useState(-1);
  const [breathActive, setBreathActive] = useState(false);
  const [breathPhase, setBreathPhase] = useState('Tap to begin');

  // Breathing animation
  const breathAnim = useRef(new Animated.Value(0.6)).current;

  useEffect(() => {
    if (!breathActive) {
      breathAnim.setValue(0.6);
      return;
    }

    const phases = [
      { label: 'Inhale...', dur: 4000 },
      { label: 'Hold...',   dur: 4000 },
      { label: 'Exhale...', dur: 6000 },
    ];

    let idx = 0;
    let cancelled = false;

    const runCycle = () => {
      if (cancelled) return;
      const { label, dur } = phases[idx % phases.length];
      setBreathPhase(label);

      const toVal = label === 'Exhale...' ? 0.6 : 1;
      Animated.timing(breathAnim, {
        toValue: toVal,
        duration: dur,
        easing: Easing.inOut(Easing.ease),
        useNativeDriver: true,
      }).start(() => {
        idx++;
        runCycle();
      });
    };

    runCycle();
    return () => {
      cancelled = true;
      breathAnim.stopAnimation();
    };
  }, [breathActive]);

  const goToShare = () => navigation.navigate('Share');

  return (
    <ScrollView
      style={[styles.container, { backgroundColor: theme.bg }]}
      contentContainerStyle={styles.scrollContent}
      showsVerticalScrollIndicator={false}
    >
      {/* Header */}
      <View style={styles.headerRow}>
        <View>
          <Text style={[styles.headingLarge, { color: theme.textPrimary }]}>
            Good {timeOfDay()}
          </Text>
          <Text style={[styles.subHeading, { color: Colors.goldPrimary }]}>
            Day 12 of your journey
          </Text>
        </View>
        <TouchableOpacity onPress={toggleTheme} style={styles.themeBtn}>
          <Text style={{ fontSize: 22 }}>{theme.dark ? '\u2600' : '\uD83C\uDF19'}</Text>
        </TouchableOpacity>
      </View>

      {/* Daily Insight */}
      <GlassCard>
        <View style={styles.insightHeader}>
          <Text style={[styles.goldLabel, { color: Colors.goldPrimary }]}>Daily Insight</Text>
          <Text style={[styles.chapterLabel, { color: theme.textSecondary }]}>
            {dailyInsight.chapter}
          </Text>
        </View>
        <View style={styles.goldBar} />
        <Text style={[styles.quoteText, { color: theme.textPrimary }]}>
          {'\u201C'}{dailyInsight.quote}{'\u201D'}
        </Text>
        <Text style={[styles.authorText, { color: Colors.goldPrimary }]}>
          {'\u2014'} {dailyInsight.author}
        </Text>
        <Text style={[styles.reflectionText, { color: theme.textSecondary }]}>
          {dailyInsight.reflection}
        </Text>
        <TouchableOpacity style={styles.shareBtn} onPress={goToShare}>
          <Text style={styles.shareBtnText}>{'\u2B06'} Share this insight</Text>
        </TouchableOpacity>
      </GlassCard>

      {/* Mood Check-in */}
      <GlassCard>
        <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>
          How are you feeling?
        </Text>
        <View style={styles.moodRow}>
          {moodOptions.map((m, idx) => (
            <TouchableOpacity
              key={m.label}
              style={[
                styles.moodItem,
                selectedMood === idx && {
                  backgroundColor: Colors.goldPrimary + '30',
                  borderRadius: 16,
                },
              ]}
              onPress={() => setSelectedMood(idx)}
            >
              <Text style={styles.moodEmoji}>{m.emoji}</Text>
              <Text
                style={[
                  styles.moodLabel,
                  {
                    color:
                      selectedMood === idx
                        ? Colors.goldPrimary
                        : theme.textSecondary,
                  },
                ]}
              >
                {m.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
        {selectedMood >= 0 && (
          <TouchableOpacity style={styles.miniShareBtn} onPress={goToShare}>
            <Text style={styles.miniShareText}>{'\u2B06'} Share mood</Text>
          </TouchableOpacity>
        )}
      </GlassCard>

      {/* Breathing Widget */}
      <GlassCard>
        <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>
          Breathing Space
        </Text>
        <View style={styles.breathContainer}>
          <TouchableOpacity
            onPress={() => setBreathActive(!breathActive)}
            activeOpacity={0.7}
          >
            <Animated.View
              style={[
                styles.breathCircle,
                {
                  transform: [{ scale: breathAnim }],
                  backgroundColor: Colors.goldPrimary + '99',
                },
              ]}
            >
              {!breathActive && <Text style={styles.playIcon}>{'\u25B6'}</Text>}
            </Animated.View>
          </TouchableOpacity>
          <Text style={[styles.breathPhaseText, { color: Colors.goldPrimary }]}>
            {breathActive ? breathPhase : 'Tap to begin'}
          </Text>
          {breathActive && (
            <TouchableOpacity onPress={() => setBreathActive(false)}>
              <Text style={[styles.stopText, { color: theme.textSecondary }]}>
                Stop
              </Text>
            </TouchableOpacity>
          )}
        </View>
      </GlassCard>

      {/* Stats */}
      <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.statsRow}>
        {stats.map((s) => (
          <View
            key={s.label}
            style={[
              styles.statCard,
              {
                backgroundColor: theme.glassSurface,
                borderColor: theme.glassBorder,
              },
            ]}
          >
            <Text style={styles.statIcon}>{s.icon}</Text>
            <Text style={[styles.statValue, { color: theme.textPrimary }]}>{s.value}</Text>
            <Text style={[styles.statLabel, { color: theme.textSecondary }]}>{s.label}</Text>
          </View>
        ))}
      </ScrollView>

      {/* Share Prompt Banner */}
      <TouchableOpacity
        style={[
          styles.shareBanner,
          {
            backgroundColor: theme.dark
              ? Colors.goldDark + '25'
              : Colors.goldLight + '55',
            borderColor: Colors.goldPrimary + '40',
          },
        ]}
        onPress={goToShare}
      >
        <Text style={styles.shareBannerIcon}>{'\u2728'}</Text>
        <View style={styles.shareBannerText}>
          <Text style={[styles.shareBannerTitle, { color: Colors.goldPrimary }]}>
            Share your light
          </Text>
          <Text style={[styles.shareBannerSub, { color: theme.textSecondary }]}>
            Create beautiful cards from your journey to inspire others
          </Text>
        </View>
        <Text style={{ color: Colors.goldPrimary, fontSize: 18 }}>{'\u2192'}</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

const styles = StyleSheet.create({
  container: { flex: 1 },
  scrollContent: { paddingHorizontal: 20, paddingBottom: 32 },

  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: Platform.OS === 'ios' ? 60 : 16,
    marginBottom: 24,
  },
  headingLarge: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 28,
    fontWeight: '700',
  },
  subHeading: { fontSize: 14, marginTop: 2 },
  themeBtn: { padding: 8 },

  // Glass card
  glassCard: {
    borderRadius: 24,
    borderWidth: 1,
    padding: 20,
    marginBottom: 20,
    ...(Platform.OS === 'ios'
      ? { shadowColor: '#000', shadowOpacity: 0.06, shadowRadius: 12, shadowOffset: { width: 0, height: 4 } }
      : { elevation: 2 }),
  },

  // Insight
  insightHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  goldLabel: { fontSize: 12, fontWeight: '600', letterSpacing: 0.5 },
  chapterLabel: { fontSize: 11 },
  goldBar: {
    width: 40,
    height: 2,
    backgroundColor: Colors.goldPrimary,
    borderRadius: 1,
    marginBottom: 14,
  },
  quoteText: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 22,
    fontStyle: 'italic',
    lineHeight: 32,
    marginBottom: 8,
  },
  authorText: { fontSize: 14, marginBottom: 14 },
  reflectionText: { fontSize: 15, lineHeight: 22 },

  shareBtn: {
    alignSelf: 'flex-end',
    marginTop: 14,
    backgroundColor: Colors.goldPrimary + '25',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 12,
  },
  shareBtnText: { color: Colors.goldPrimary, fontSize: 13, fontWeight: '600' },

  // Mood
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 14,
  },
  moodRow: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
  },
  moodItem: { alignItems: 'center', padding: 10 },
  moodEmoji: { fontSize: 28 },
  moodLabel: { fontSize: 11, marginTop: 4 },
  miniShareBtn: { alignSelf: 'flex-end', marginTop: 8 },
  miniShareText: { color: Colors.goldPrimary, fontSize: 12 },

  // Breathing
  breathContainer: { alignItems: 'center', paddingVertical: 16 },
  breathCircle: {
    width: 80,
    height: 80,
    borderRadius: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playIcon: { color: '#fff', fontSize: 24 },
  breathPhaseText: { fontSize: 16, marginTop: 12 },
  stopText: { fontSize: 14, marginTop: 8 },

  // Stats
  statsRow: { marginBottom: 20 },
  statCard: {
    borderRadius: 16,
    borderWidth: 1,
    padding: 16,
    marginRight: 12,
    alignItems: 'center',
    minWidth: 90,
  },
  statIcon: { fontSize: 22, marginBottom: 6 },
  statValue: { fontSize: 16, fontWeight: '700' },
  statLabel: { fontSize: 11, marginTop: 2 },

  // Share banner
  shareBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: 20,
    borderWidth: 1,
  },
  shareBannerIcon: { fontSize: 24, marginRight: 12 },
  shareBannerText: { flex: 1 },
  shareBannerTitle: { fontSize: 14, fontWeight: '600' },
  shareBannerSub: { fontSize: 12, marginTop: 2 },
});

export default HomeScreen;
