import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, ScrollView, TouchableOpacity,
  TextInput, Animated, Platform,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Radii, Typography, LifewheelDimensions } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';

const journalPrompts = [
  'Write about a time your body surprised you with its wisdom, strength, or resilience.',
  'If your body could speak in sentences right now, what would it say?',
  'Write a letter to an emotion you\'ve been avoiding.',
  'What are you genuinely curious about right now?',
  'Describe a moment of unexpected grace.',
  'What would your closest friend say about how you\'ve been growing?',
  'If impact were guaranteed, what would you create for the world?',
  'Create something in the next 10 minutes — then write about the experience.',
  'Write about your relationship with money as if it were a person.',
  'Write a letter from your luminous future self.',
];

const dailyCheckinSteps = [
  { key: 'arrive', label: 'Arrive', instruction: 'Three slow breaths. Just land here, now.', emoji: '🫁' },
  { key: 'notice', label: 'Notice', instruction: 'Quick scan of your eight dimensions. One word each.', emoji: '👁️' },
  { key: 'appreciate', label: 'Appreciate', instruction: 'Name one thing you\'re genuinely grateful for.', emoji: '🙏' },
];

const sampleEntries = [
  { id: 1, date: 'Today', type: 'checkin', preview: 'Body: Rested. Emotions: Hopeful. Mind: Clear...' },
  { id: 2, date: 'Yesterday', type: 'reflection', preview: 'I notice my creative dimension is waking up...' },
  { id: 3, date: 'Mar 18', type: 'gratitude', preview: 'Three things: The morning light through the kitchen...' },
  { id: 4, date: 'Mar 17', type: 'checkin', preview: 'Body: Tired. Emotions: Tender. Mind: Busy...' },
  { id: 5, date: 'Mar 16', type: 'prompt', preview: 'Letter to my future self: Dear luminous me...' },
];

export default function JournalScreen({ navigation }) {
  const { colors } = useTheme();
  const [view, setView] = useState('main'); // main | checkin | write | prompt
  const [checkinStep, setCheckinStep] = useState(0);
  const [checkinWords, setCheckinWords] = useState({});
  const [gratitude, setGratitude] = useState('');
  const [journalText, setJournalText] = useState('');
  const [currentPrompt, setCurrentPrompt] = useState(0);
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    fadeAnim.setValue(0);
    Animated.timing(fadeAnim, { toValue: 1, duration: 500, useNativeDriver: true }).start();
  }, [view, checkinStep]);

  const renderMain = () => (
    <ScrollView showsVerticalScrollIndicator={false}>
      <ResonanceText variant="h2">Luminous Journal</ResonanceText>
      <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
        Your ongoing conversation with yourself
      </ResonanceText>

      {/* Daily Check-in CTA */}
      <GlassCard variant="raised" style={[styles.checkinCta, { borderColor: colors.gold + '30' }]}>
        <ResonanceText style={{ fontSize: 32, textAlign: 'center' }}>☀️</ResonanceText>
        <ResonanceText variant="h4" serif style={{ textAlign: 'center', marginTop: 8 }}>
          Daily Luminous Check-In
        </ResonanceText>
        <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 4 }}>
          2 minutes. Arrive. Notice. Appreciate. Done.
        </ResonanceText>
        <ResonanceButton
          title="Begin Check-In"
          variant="gold"
          size="md"
          style={{ marginTop: 12, alignSelf: 'center' }}
          onPress={() => { setView('checkin'); setCheckinStep(0); }}
        />
      </GlassCard>

      {/* Quick actions */}
      <View style={styles.quickRow}>
        <TouchableOpacity
          style={[styles.quickAction, { backgroundColor: colors.bgGlassCard, borderColor: colors.borderLight }]}
          onPress={() => setView('write')}
        >
          <ResonanceText style={{ fontSize: 22 }}>📝</ResonanceText>
          <ResonanceText variant="label" style={{ marginTop: 6 }}>Free Write</ResonanceText>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.quickAction, { backgroundColor: colors.bgGlassCard, borderColor: colors.borderLight }]}
          onPress={() => { setView('prompt'); setCurrentPrompt(Math.floor(Math.random() * journalPrompts.length)); }}
        >
          <ResonanceText style={{ fontSize: 22 }}>✨</ResonanceText>
          <ResonanceText variant="label" style={{ marginTop: 6 }}>Today's Prompt</ResonanceText>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.quickAction, { backgroundColor: colors.bgGlassCard, borderColor: colors.borderLight }]}
          onPress={() => {}}
        >
          <ResonanceText style={{ fontSize: 22 }}>🙏</ResonanceText>
          <ResonanceText variant="label" style={{ marginTop: 6 }}>Gratitude</ResonanceText>
        </TouchableOpacity>
      </View>

      {/* Recent Entries */}
      <ResonanceText variant="caption" color="muted" style={{ marginTop: 24, marginBottom: 12 }}>
        RECENT ENTRIES
      </ResonanceText>
      {sampleEntries.map((entry) => (
        <TouchableOpacity key={entry.id} activeOpacity={0.7}>
          <GlassCard style={styles.entryCard}>
            <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
              <ResonanceText variant="caption" color="light">{entry.date}</ResonanceText>
              <ResonanceText variant="caption" color="gold">{entry.type}</ResonanceText>
            </View>
            <ResonanceText variant="body" color="muted" numberOfLines={2} style={{ marginTop: 6 }}>
              {entry.preview}
            </ResonanceText>
          </GlassCard>
        </TouchableOpacity>
      ))}

      {/* 30 Prompts */}
      <GlassCard style={{ marginTop: 16 }}>
        <ResonanceText variant="label">📓 30 Journaling Prompts</ResonanceText>
        <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 4 }}>
          Invitations for deeper exploration — use one a day or sample freely
        </ResonanceText>
        <View style={styles.promptList}>
          {journalPrompts.slice(0, 5).map((prompt, i) => (
            <TouchableOpacity
              key={i}
              style={[styles.promptItem, { borderBottomColor: colors.borderLight }]}
              onPress={() => { setCurrentPrompt(i); setView('prompt'); }}
            >
              <ResonanceText variant="bodySmall" color="muted" style={{ flex: 1 }}>{prompt}</ResonanceText>
              <ResonanceText color="gold" style={{ marginLeft: 8 }}>→</ResonanceText>
            </TouchableOpacity>
          ))}
        </View>
        <ResonanceButton title="See All 30" variant="ghost" size="sm" style={{ marginTop: 8 }} />
      </GlassCard>

      <View style={{ height: 100 }} />
    </ScrollView>
  );

  const renderCheckin = () => {
    const step = dailyCheckinSteps[checkinStep];
    return (
      <Animated.View style={[styles.checkinContainer, { opacity: fadeAnim }]}>
        <TouchableOpacity onPress={() => setView('main')}>
          <ResonanceText color="gold">← Back</ResonanceText>
        </TouchableOpacity>

        <View style={styles.checkinCenter}>
          <ResonanceText style={{ fontSize: 48 }}>{step.emoji}</ResonanceText>
          <ResonanceText variant="h2" style={{ textAlign: 'center', marginTop: 16 }}>
            {step.label}
          </ResonanceText>
          <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 8, paddingHorizontal: 20 }}>
            {step.instruction}
          </ResonanceText>

          {step.key === 'notice' && (
            <GlassCard style={{ marginTop: 24, width: '100%' }}>
              {LifewheelDimensions.map((dim) => (
                <View key={dim.key} style={styles.noticeRow}>
                  <ResonanceText style={{ fontSize: 16 }}>{dim.emoji}</ResonanceText>
                  <ResonanceText variant="bodySmall" style={{ flex: 1, marginLeft: 8 }}>
                    {dim.label.split(' ')[0]}:
                  </ResonanceText>
                  <TextInput
                    style={[styles.noticeInput, {
                      color: colors.textMain,
                      borderBottomColor: colors.borderLight,
                    }]}
                    placeholder="one word"
                    placeholderTextColor={colors.textLight}
                    value={checkinWords[dim.key] || ''}
                    onChangeText={(t) => setCheckinWords(prev => ({ ...prev, [dim.key]: t }))}
                  />
                </View>
              ))}
            </GlassCard>
          )}

          {step.key === 'appreciate' && (
            <GlassCard style={{ marginTop: 24, width: '100%' }}>
              <TextInput
                style={[styles.gratitudeInput, { color: colors.textMain, borderColor: colors.borderLight }]}
                placeholder="What are you genuinely grateful for right now?"
                placeholderTextColor={colors.textLight}
                value={gratitude}
                onChangeText={setGratitude}
                multiline
              />
            </GlassCard>
          )}
        </View>

        <View style={styles.checkinNav}>
          <View style={styles.stepDots}>
            {dailyCheckinSteps.map((_, i) => (
              <View
                key={i}
                style={[styles.stepDot, {
                  backgroundColor: i <= checkinStep ? colors.gold : colors.borderLight,
                  width: i === checkinStep ? 20 : 8,
                }]}
              />
            ))}
          </View>

          <ResonanceButton
            title={checkinStep < 2 ? 'Continue' : 'Complete ✓'}
            variant="gold"
            size="lg"
            onPress={() => {
              if (checkinStep < 2) {
                setCheckinStep(s => s + 1);
              } else {
                setView('main');
              }
            }}
          />
        </View>
      </Animated.View>
    );
  };

  const renderWrite = () => (
    <Animated.View style={[{ flex: 1 }, { opacity: fadeAnim }]}>
      <TouchableOpacity onPress={() => setView('main')}>
        <ResonanceText color="gold">← Back</ResonanceText>
      </TouchableOpacity>
      <ResonanceText variant="h3" style={{ marginTop: 16 }}>Free Write</ResonanceText>
      <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 4, marginBottom: 16 }}>
        Write freely without self-censorship — this is discovery, not performance.
      </ResonanceText>
      <TextInput
        style={[styles.freeWrite, { color: colors.textMain, borderColor: colors.borderLight }]}
        placeholder="Begin writing..."
        placeholderTextColor={colors.textLight}
        value={journalText}
        onChangeText={setJournalText}
        multiline
        textAlignVertical="top"
      />
      <ResonanceButton title="Save Entry" variant="gold" style={{ marginTop: 16, alignSelf: 'flex-end' }} />
    </Animated.View>
  );

  const renderPrompt = () => (
    <Animated.View style={[{ flex: 1 }, { opacity: fadeAnim }]}>
      <TouchableOpacity onPress={() => setView('main')}>
        <ResonanceText color="gold">← Back</ResonanceText>
      </TouchableOpacity>
      <GlassCard variant="raised" style={{ marginTop: 16 }}>
        <ResonanceText variant="caption" color="gold" style={{ marginBottom: 8 }}>
          PROMPT #{currentPrompt + 1}
        </ResonanceText>
        <ResonanceText variant="quote" color="gold">
          {journalPrompts[currentPrompt]}
        </ResonanceText>
      </GlassCard>
      <TextInput
        style={[styles.freeWrite, { color: colors.textMain, borderColor: colors.borderLight, marginTop: 16 }]}
        placeholder="Let the words flow..."
        placeholderTextColor={colors.textLight}
        value={journalText}
        onChangeText={setJournalText}
        multiline
        textAlignVertical="top"
      />
      <View style={{ flexDirection: 'row', gap: 12, marginTop: 16 }}>
        <ResonanceButton
          title="New Prompt"
          variant="ghost"
          onPress={() => setCurrentPrompt(Math.floor(Math.random() * journalPrompts.length))}
        />
        <ResonanceButton title="Save Entry" variant="gold" />
      </View>
    </Animated.View>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <View style={[styles.content, { paddingTop: Platform.OS === 'ios' ? 60 : 40 }]}>
        {view === 'main' && renderMain()}
        {view === 'checkin' && renderCheckin()}
        {view === 'write' && renderWrite()}
        {view === 'prompt' && renderPrompt()}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { flex: 1, paddingHorizontal: 20, zIndex: 10 },
  checkinCta: { marginTop: 20, padding: 24 },
  quickRow: { flexDirection: 'row', gap: 10, marginTop: 16 },
  quickAction: {
    flex: 1, padding: 16, borderRadius: Radii.xl, borderWidth: 1,
    alignItems: 'center',
  },
  entryCard: { marginBottom: 8, padding: 14 },
  promptList: { marginTop: 12 },
  promptItem: { flexDirection: 'row', paddingVertical: 10, borderBottomWidth: StyleSheet.hairlineWidth },
  checkinContainer: { flex: 1 },
  checkinCenter: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  checkinNav: { alignItems: 'center', paddingBottom: Platform.OS === 'ios' ? 34 : 16 },
  stepDots: { flexDirection: 'row', gap: 6, marginBottom: 20 },
  stepDot: { height: 8, borderRadius: 4 },
  noticeRow: { flexDirection: 'row', alignItems: 'center', paddingVertical: 8 },
  noticeInput: {
    borderBottomWidth: 1, width: 100, paddingVertical: 4,
    fontSize: 15, fontFamily: Typography.sans,
  },
  gratitudeInput: {
    borderWidth: 1, borderRadius: Radii.lg, padding: 16,
    minHeight: 100, fontSize: 16, fontFamily: Typography.sans,
  },
  freeWrite: {
    flex: 1, borderWidth: 1, borderRadius: Radii.xl, padding: 20,
    fontSize: 16, lineHeight: 26, fontFamily: Typography.sans, minHeight: 300,
  },
});
