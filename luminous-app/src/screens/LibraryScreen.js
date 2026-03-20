import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, ScrollView, TouchableOpacity,
  Animated, Dimensions, Platform,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Radii, Spacing } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';

const { width } = Dimensions.get('window');

// ─── eBook Library ───
const ebooks = [
  {
    id: 1,
    title: 'Your Luminous Lifewheel',
    subtitle: 'A Comprehensive Guide to Transformative Living',
    author: 'Luminous Prosperity',
    cover: '🌀',
    chapters: 11,
    format: 'ebook',
    description: 'The foundational methodology for conscious evolution — the bridge between philosophy and practice.',
    tableOfContents: [
      'Part 1: The Living Force — Our Foundational Philosophy',
      'Part 2: The Luminous 5D Model',
      'Part 3: The Luminous Lifewheel in Practice',
      'Part 4: Integration with the Luminous Ecosystem',
      'Part 5: What Makes Us Exceptional',
      'Part 6: The Eight Dimensions',
      'Part 7: NDHA Integration',
      'Part 8: The Workbook',
      'Part 9: Special Topics & Advanced Work',
      'Part 10: For Practitioners',
      'Part 11: Resources & References',
    ],
  },
  {
    id: 2,
    title: 'Luminous Self',
    subtitle: 'Luminous Holonics Volume I',
    author: 'Luminous Prosperity',
    cover: '✨',
    chapters: 12,
    format: 'ebook',
    description: 'Transform inner conflicts into personal strength through gentle integration.',
  },
  {
    id: 3,
    title: 'Quantum Ontology',
    subtitle: "A User's Manual for Your Native Reality",
    author: 'Luminous Prosperity',
    cover: '🔬',
    chapters: 9,
    format: 'ebook',
    description: 'The foundational philosophy — non-dual, quantum-informed understanding of consciousness.',
  },
  {
    id: 4,
    title: "The Multipotentiate's Guide to Life",
    subtitle: 'Career, Creativity, Relationships & Happiness',
    author: 'Luminous Prosperity',
    cover: '🌈',
    chapters: 8,
    format: 'ebook',
    description: 'Lifewheel methodology applied to career, work, and the joy of multiple passions.',
  },
  {
    id: 5,
    title: 'The Chrysalis Journal',
    subtitle: 'For Those in Dissolution',
    author: 'Luminous Prosperity',
    cover: '🦋',
    chapters: 7,
    format: 'ebook',
    description: 'Guided transformation journal for the first phase of metamorphosis.',
  },
];

// ─── Audiobooks ───
const audiobooks = [
  {
    id: 101,
    title: 'Your Luminous Lifewheel',
    subtitle: 'The Complete Audio Experience',
    narrator: 'Luminous Audio',
    cover: '🎧',
    duration: '12h 30m',
    format: 'audiobook',
    chapters: [
      { title: 'Introduction: Welcome to Something Extraordinary', duration: '15:00', progress: 100 },
      { title: 'Part 1: Beyond Mechanics — Life as Creative Intelligence', duration: '45:00', progress: 100 },
      { title: 'Part 1: Appreciative Inquiry as Sacred Practice', duration: '38:00', progress: 72 },
      { title: 'Part 1: The Wholeness Principle', duration: '42:00', progress: 0 },
      { title: 'Part 2: The Luminous 5D Model — Discover', duration: '35:00', progress: 0 },
      { title: 'Part 2: Dream, Design, Deliver, Delight', duration: '52:00', progress: 0 },
      { title: 'Part 3: The Eight Dimensions Deep Dive', duration: '1:20:00', progress: 0 },
      { title: 'Part 4: NDHA Integration', duration: '48:00', progress: 0 },
      { title: 'Part 5: The Complete Workbook Guide', duration: '2:15:00', progress: 0 },
      { title: 'Part 6: For Practitioners', duration: '1:45:00', progress: 0 },
    ],
  },
  {
    id: 102,
    title: 'Luminous Guided Meditations',
    subtitle: 'Practices for Each Dimension',
    narrator: 'Luminous Audio',
    cover: '🧘',
    duration: '3h 20m',
    format: 'audiobook',
    chapters: [
      { title: 'Physical Vitality Body Scan', duration: '18:00', progress: 0 },
      { title: 'Emotional Landscape Meditation', duration: '22:00', progress: 0 },
      { title: 'Mental Clarity Spaciousness', duration: '15:00', progress: 0 },
      { title: 'Spiritual Connection Practice', duration: '25:00', progress: 0 },
      { title: 'Relational Heart Opening', duration: '20:00', progress: 0 },
      { title: 'Purpose Discovery Visualization', duration: '28:00', progress: 0 },
      { title: 'Creative Flow Activation', duration: '18:00', progress: 0 },
      { title: 'Environmental Harmony Attunement', duration: '15:00', progress: 0 },
    ],
  },
  {
    id: 103,
    title: 'The Daily Luminous Practice',
    subtitle: 'Morning & Evening Audio Rituals',
    narrator: 'Luminous Audio',
    cover: '☀️',
    duration: '1h 45m',
    format: 'audiobook',
    description: 'Guided morning and evening practices aligned with the Lifewheel dimensions.',
  },
];

export default function LibraryScreen({ navigation }) {
  const { colors } = useTheme();
  const [tab, setTab] = useState('ebooks');
  const [selectedBook, setSelectedBook] = useState(null);
  const [selectedAudio, setSelectedAudio] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentChapter, setCurrentChapter] = useState(0);
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    fadeAnim.setValue(0);
    Animated.timing(fadeAnim, { toValue: 1, duration: 500, useNativeDriver: true }).start();
  }, [tab, selectedBook, selectedAudio]);

  const renderBookDetail = (book) => (
    <Animated.View style={{ opacity: fadeAnim }}>
      <TouchableOpacity onPress={() => setSelectedBook(null)}>
        <ResonanceText color="gold">← Back to Library</ResonanceText>
      </TouchableOpacity>

      <View style={styles.bookHeader}>
        <View style={[styles.coverLarge, { backgroundColor: colors.gold + '10' }]}>
          <ResonanceText style={{ fontSize: 56 }}>{book.cover}</ResonanceText>
        </View>
        <ResonanceText variant="h2" style={{ textAlign: 'center', marginTop: 16 }}>
          {book.title}
        </ResonanceText>
        <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 4 }}>
          {book.subtitle}
        </ResonanceText>
        <ResonanceText variant="caption" color="light" style={{ marginTop: 8 }}>
          {book.chapters} chapters · {book.author}
        </ResonanceText>
      </View>

      <View style={{ flexDirection: 'row', gap: 12, justifyContent: 'center', marginTop: 20 }}>
        <ResonanceButton title="Read Now" variant="gold" size="lg" />
        <ResonanceButton title="Download" variant="secondary" size="lg" />
      </View>

      <GlassCard style={{ marginTop: 24 }}>
        <ResonanceText variant="body" color="muted">{book.description}</ResonanceText>
      </GlassCard>

      {book.tableOfContents && (
        <GlassCard style={{ marginTop: 16 }}>
          <ResonanceText variant="label" style={{ marginBottom: 12 }}>Table of Contents</ResonanceText>
          {book.tableOfContents.map((chapter, i) => (
            <TouchableOpacity key={i} style={[styles.tocRow, { borderBottomColor: colors.borderLight }]}>
              <ResonanceText variant="bodySmall" color="muted" style={{ width: 24 }}>{i + 1}</ResonanceText>
              <ResonanceText variant="body" style={{ flex: 1 }}>{chapter}</ResonanceText>
            </TouchableOpacity>
          ))}
        </GlassCard>
      )}
    </Animated.View>
  );

  const renderAudioPlayer = (audio) => (
    <Animated.View style={{ opacity: fadeAnim }}>
      <TouchableOpacity onPress={() => setSelectedAudio(null)}>
        <ResonanceText color="gold">← Back to Library</ResonanceText>
      </TouchableOpacity>

      <View style={styles.bookHeader}>
        <View style={[styles.coverLarge, { backgroundColor: colors.gold + '10' }]}>
          <ResonanceText style={{ fontSize: 56 }}>{audio.cover}</ResonanceText>
        </View>
        <ResonanceText variant="h2" style={{ textAlign: 'center', marginTop: 16 }}>
          {audio.title}
        </ResonanceText>
        <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 4 }}>
          {audio.subtitle}
        </ResonanceText>
        <ResonanceText variant="caption" color="light" style={{ marginTop: 8 }}>
          {audio.duration} · {audio.narrator}
        </ResonanceText>
      </View>

      {/* Audio Player Controls */}
      <GlassCard variant="raised" style={styles.playerCard}>
        <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center' }}>
          {audio.chapters?.[currentChapter]?.title || 'Ready to play'}
        </ResonanceText>

        {/* Progress bar */}
        <View style={[styles.progressTrack, { backgroundColor: colors.borderLight }]}>
          <View style={[styles.progressFill, {
            backgroundColor: colors.gold,
            width: `${audio.chapters?.[currentChapter]?.progress || 0}%`,
          }]} />
        </View>

        {/* Controls */}
        <View style={styles.playerControls}>
          <TouchableOpacity
            onPress={() => setCurrentChapter(Math.max(0, currentChapter - 1))}
            style={styles.controlBtn}
          >
            <ResonanceText style={{ fontSize: 20 }}>⏮️</ResonanceText>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => setIsPlaying(!isPlaying)}
            style={[styles.playBtn, { backgroundColor: colors.gold }]}
          >
            <ResonanceText style={{ fontSize: 24, color: '#fff' }}>
              {isPlaying ? '⏸' : '▶️'}
            </ResonanceText>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => setCurrentChapter(Math.min((audio.chapters?.length || 1) - 1, currentChapter + 1))}
            style={styles.controlBtn}
          >
            <ResonanceText style={{ fontSize: 20 }}>⏭️</ResonanceText>
          </TouchableOpacity>
        </View>

        <View style={styles.speedRow}>
          {['0.75x', '1x', '1.25x', '1.5x', '2x'].map((speed) => (
            <TouchableOpacity
              key={speed}
              style={[styles.speedBtn, speed === '1x' && { backgroundColor: colors.gold + '15', borderColor: colors.gold }]}
            >
              <ResonanceText variant="caption" style={speed === '1x' ? { color: colors.gold } : { color: colors.textLight }}>
                {speed}
              </ResonanceText>
            </TouchableOpacity>
          ))}
        </View>
      </GlassCard>

      {/* Chapter list */}
      {audio.chapters && (
        <GlassCard style={{ marginTop: 16 }}>
          <ResonanceText variant="label" style={{ marginBottom: 12 }}>Chapters</ResonanceText>
          {audio.chapters.map((ch, i) => (
            <TouchableOpacity
              key={i}
              onPress={() => setCurrentChapter(i)}
              style={[
                styles.chapterRow,
                { borderBottomColor: colors.borderLight },
                i === currentChapter && { backgroundColor: colors.gold + '08' },
              ]}
            >
              <View style={{ flex: 1 }}>
                <ResonanceText
                  variant="body"
                  style={i === currentChapter ? { color: colors.gold } : {}}
                >
                  {ch.title}
                </ResonanceText>
                <ResonanceText variant="caption" color="light">{ch.duration}</ResonanceText>
              </View>
              {ch.progress > 0 && ch.progress < 100 && (
                <View style={[styles.miniProgress, { backgroundColor: colors.borderLight }]}>
                  <View style={[styles.miniProgressFill, {
                    backgroundColor: colors.gold,
                    width: `${ch.progress}%`,
                  }]} />
                </View>
              )}
              {ch.progress === 100 && (
                <ResonanceText style={{ color: colors.dimensionPhysical }}>✓</ResonanceText>
              )}
            </TouchableOpacity>
          ))}
        </GlassCard>
      )}

      {/* Sleep Timer */}
      <GlassCard style={{ marginTop: 16 }}>
        <ResonanceText variant="label">🌙 Sleep Timer</ResonanceText>
        <View style={styles.timerRow}>
          {['15 min', '30 min', '45 min', '1 hour', 'End of chapter'].map((t) => (
            <TouchableOpacity key={t} style={[styles.timerBtn, { borderColor: colors.borderLight }]}>
              <ResonanceText variant="bodySmall" color="muted">{t}</ResonanceText>
            </TouchableOpacity>
          ))}
        </View>
      </GlassCard>
    </Animated.View>
  );

  const renderLibrary = () => (
    <Animated.View style={{ opacity: fadeAnim }}>
      <ResonanceText variant="h2">Luminous Library</ResonanceText>
      <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
        The complete Luminous Prosperity ecosystem — read and listen
      </ResonanceText>

      {/* Tabs */}
      <View style={styles.tabs}>
        {['ebooks', 'audiobooks', 'workbooks'].map((t) => (
          <TouchableOpacity
            key={t}
            onPress={() => setTab(t)}
            style={[
              styles.tab,
              {
                backgroundColor: tab === t ? colors.gold + '15' : 'transparent',
                borderColor: tab === t ? colors.gold : colors.borderLight,
              },
            ]}
          >
            <ResonanceText variant="label" style={{ color: tab === t ? colors.gold : colors.textMuted }}>
              {t === 'ebooks' ? '📚 eBooks' : t === 'audiobooks' ? '🎧 Audio' : '📖 Workbooks'}
            </ResonanceText>
          </TouchableOpacity>
        ))}
      </View>

      {/* eBooks */}
      {tab === 'ebooks' && ebooks.map((book) => (
        <TouchableOpacity
          key={book.id}
          activeOpacity={0.7}
          onPress={() => setSelectedBook(book)}
        >
          <GlassCard style={styles.bookCard}>
            <View style={{ flexDirection: 'row' }}>
              <View style={[styles.coverSmall, { backgroundColor: colors.gold + '10' }]}>
                <ResonanceText style={{ fontSize: 28 }}>{book.cover}</ResonanceText>
              </View>
              <View style={{ flex: 1, marginLeft: 16 }}>
                <ResonanceText variant="subtitle">{book.title}</ResonanceText>
                <ResonanceText variant="bodySmall" color="muted">{book.subtitle}</ResonanceText>
                <ResonanceText variant="caption" color="light" style={{ marginTop: 4 }}>
                  {book.chapters} chapters
                </ResonanceText>
              </View>
              <ResonanceText color="gold">→</ResonanceText>
            </View>
          </GlassCard>
        </TouchableOpacity>
      ))}

      {/* Audiobooks */}
      {tab === 'audiobooks' && audiobooks.map((audio) => (
        <TouchableOpacity
          key={audio.id}
          activeOpacity={0.7}
          onPress={() => setSelectedAudio(audio)}
        >
          <GlassCard style={styles.bookCard}>
            <View style={{ flexDirection: 'row' }}>
              <View style={[styles.coverSmall, { backgroundColor: colors.gold + '10' }]}>
                <ResonanceText style={{ fontSize: 28 }}>{audio.cover}</ResonanceText>
              </View>
              <View style={{ flex: 1, marginLeft: 16 }}>
                <ResonanceText variant="subtitle">{audio.title}</ResonanceText>
                <ResonanceText variant="bodySmall" color="muted">{audio.subtitle}</ResonanceText>
                <ResonanceText variant="caption" color="light" style={{ marginTop: 4 }}>
                  {audio.duration} · {audio.narrator}
                </ResonanceText>
              </View>
              <ResonanceText color="gold">▶</ResonanceText>
            </View>
          </GlassCard>
        </TouchableOpacity>
      ))}

      {/* Workbooks */}
      {tab === 'workbooks' && (
        <View>
          <GlassCard variant="raised" style={{ padding: 24 }}>
            <ResonanceText style={{ fontSize: 36, textAlign: 'center' }}>📖</ResonanceText>
            <ResonanceText variant="h4" serif style={{ textAlign: 'center', marginTop: 12 }}>
              The Luminous Lifewheel Workbook
            </ResonanceText>
            <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
              The complete interactive workbook — all 10 parts, every exercise, every reflection prompt.
              Work through it digitally with auto-save, or export to PDF for printing.
            </ResonanceText>
            <View style={{ flexDirection: 'row', gap: 12, justifyContent: 'center', marginTop: 16 }}>
              <ResonanceButton title="Open Workbook" variant="gold" />
              <ResonanceButton title="Export PDF" variant="secondary" />
            </View>
          </GlassCard>

          {[
            'Part 1: Welcome to Your Luminous Journey',
            'Part 2: The Eight Dimensions Exploration',
            'Part 3: Your Luminous Lifewheel Visualization',
            'Part 4: Celebrating Your Luminosity',
            'Part 5: Invitations for Growth',
            'Part 6: Luminous Intention Setting',
            'Part 7: Your Luminous Action Plan',
            'Part 8: Integration Practices',
            'Part 9: Special Topics & Advanced Work',
            'Part 10: For Practitioners',
          ].map((part, i) => (
            <TouchableOpacity key={i} activeOpacity={0.7}>
              <GlassCard style={styles.partCard}>
                <ResonanceText variant="body">{part}</ResonanceText>
                <View style={[styles.partProgress, { backgroundColor: colors.borderLight }]}>
                  <View style={[styles.partProgressFill, {
                    backgroundColor: colors.gold,
                    width: i < 2 ? '100%' : i === 2 ? '60%' : '0%',
                  }]} />
                </View>
              </GlassCard>
            </TouchableOpacity>
          ))}
        </View>
      )}
    </Animated.View>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {selectedBook ? renderBookDetail(selectedBook)
          : selectedAudio ? renderAudioPlayer(selectedAudio)
          : renderLibrary()}
        <View style={{ height: 100 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { flex: 1, zIndex: 10 },
  scrollContent: { paddingHorizontal: 20, paddingTop: Platform.OS === 'ios' ? 60 : 40 },
  tabs: { flexDirection: 'row', gap: 8, marginVertical: 20 },
  tab: { flex: 1, paddingVertical: 10, borderRadius: Radii.pill, borderWidth: 1, alignItems: 'center' },
  bookCard: { marginBottom: 10, padding: 16 },
  coverSmall: { width: 60, height: 80, borderRadius: 12, alignItems: 'center', justifyContent: 'center' },
  coverLarge: { width: 140, height: 180, borderRadius: 20, alignItems: 'center', justifyContent: 'center', alignSelf: 'center' },
  bookHeader: { alignItems: 'center', marginTop: 20 },
  tocRow: { flexDirection: 'row', paddingVertical: 12, borderBottomWidth: StyleSheet.hairlineWidth },
  playerCard: { marginTop: 20, padding: 24, alignItems: 'center' },
  progressTrack: { width: '100%', height: 4, borderRadius: 2, marginTop: 16 },
  progressFill: { height: 4, borderRadius: 2 },
  playerControls: { flexDirection: 'row', alignItems: 'center', gap: 32, marginTop: 20 },
  controlBtn: { padding: 8 },
  playBtn: { width: 56, height: 56, borderRadius: 28, alignItems: 'center', justifyContent: 'center' },
  speedRow: { flexDirection: 'row', gap: 8, marginTop: 16 },
  speedBtn: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8, borderWidth: 1, borderColor: 'transparent' },
  chapterRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 12, paddingHorizontal: 8, borderBottomWidth: StyleSheet.hairlineWidth, borderRadius: 8 },
  miniProgress: { width: 40, height: 3, borderRadius: 2, marginLeft: 8 },
  miniProgressFill: { height: 3, borderRadius: 2 },
  timerRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 12 },
  timerBtn: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 12, borderWidth: 1 },
  partCard: { marginTop: 8, padding: 16 },
  partProgress: { height: 3, borderRadius: 2, marginTop: 8 },
  partProgressFill: { height: 3, borderRadius: 2 },
});
