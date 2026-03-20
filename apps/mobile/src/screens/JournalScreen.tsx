import React, { useState, useRef, useCallback } from 'react';
import {
  View,
  Text,
  ScrollView,
  TextInput,
  TouchableOpacity,
  FlatList,
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
// Types
// ---------------------------------------------------------------------------

type JournalMode = 'typed' | 'voice' | 'drawing';

interface JournalEntry {
  id: string;
  date: string;
  time: string;
  mode: JournalMode;
  title: string;
  preview: string;
  moodIndex: number;
  wordCount: number;
  sentToCoach: boolean;
  tags: string[];
}

interface Prompt {
  text: string;
  category: string;
  chapter?: number;
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const moods = ['\uD83D\uDE14', '\uD83D\uDE10', '\uD83D\uDE42', '\uD83D\uDE0A', '\u2728'];
const moodLabels = ['Low', 'Flat', 'Calm', 'Good', 'Radiant'];
const moodColors = ['#8B6B6B', '#8B8B7A', '#6B8B7A', '#5A9E7A', '#C5A059'];

const prompts: Prompt[] = [
  { text: 'What pattern did you notice repeating today?', category: 'Awareness', chapter: 3 },
  { text: 'Describe a moment when you felt fully present.', category: 'Presence' },
  { text: 'Write a letter to your younger self about what you have learned.', category: 'Compassion', chapter: 2 },
  { text: 'What are you avoiding, and what would it mean to face it gently?', category: 'Shadow', chapter: 4 },
  { text: 'Name three things your body is telling you right now.', category: 'Somatic', chapter: 6 },
  { text: 'What does "enough" look like for you today?', category: 'Values' },
];

const sampleEntries: JournalEntry[] = [
  {
    id: '1', date: 'Mar 19', time: '9:14 AM', mode: 'typed',
    title: 'Morning pages',
    preview: 'Woke up with that familiar tightness in my chest again. Instead of pushing through it I sat with it for a few minutes like the book suggested. The tightness had a shape \u2014 something round and heavy...',
    moodIndex: 2, wordCount: 340, sentToCoach: false, tags: ['somatic', 'morning'],
  },
  {
    id: '2', date: 'Mar 18', time: '10:32 PM', mode: 'voice',
    title: 'Evening reflection',
    preview: 'Transcribed: Today was a turning point. I caught myself mid-reaction in the meeting and actually paused. The old me would have fired back immediately but I felt the anger, named it, and chose differently...',
    moodIndex: 3, wordCount: 280, sentToCoach: true, tags: ['growth', 'work'],
  },
  {
    id: '3', date: 'Mar 17', time: '3:15 PM', mode: 'drawing',
    title: 'Drawing exercise',
    preview: 'Freeform drawing exploring the relationship between control and surrender. Used circles and spirals. Added words that arose: release, trust, river, roots...',
    moodIndex: 3, wordCount: 120, sentToCoach: false, tags: ['creative', 'shadow'],
  },
  {
    id: '4', date: 'Mar 16', time: '8:00 AM', mode: 'typed',
    title: 'Chapter 3 response',
    preview: 'The section on family patterns hit hard. I always thought my need to fix everyone was just being kind, but I can see now it is a way of managing my own anxiety...',
    moodIndex: 1, wordCount: 450, sentToCoach: true, tags: ['family', 'chapter-3'],
  },
  {
    id: '5', date: 'Mar 15', time: '7:22 PM', mode: 'typed',
    title: 'Gratitude list',
    preview: 'Three things: the way light fell through the kitchen window this morning, my friend\'s laugh on the phone, the feeling of my feet on cool grass...',
    moodIndex: 4, wordCount: 180, sentToCoach: false, tags: ['gratitude'],
  },
];

// ---------------------------------------------------------------------------
// Components
// ---------------------------------------------------------------------------

const GlassCard: React.FC<{ children: React.ReactNode; style?: object }> = ({ children, style }) => {
  const { theme } = useTheme();
  return (
    <View style={[jStyles.glassCard, { backgroundColor: theme.glassSurface, borderColor: theme.glassBorder }, style]}>
      {children}
    </View>
  );
};

// ---------------------------------------------------------------------------
// Journal Screen
// ---------------------------------------------------------------------------

const JournalScreen: React.FC = () => {
  const { theme } = useTheme();
  const navigation = useNavigation<any>();
  const [tab, setTab] = useState<'write' | 'entries' | 'mood'>('write');
  const [mode, setMode] = useState<JournalMode>('typed');
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [selectedMood, setSelectedMood] = useState(-1);
  const [isRecording, setIsRecording] = useState(false);
  const [showPrompts, setShowPrompts] = useState(false);

  const goToShare = () => navigation.navigate('Share');

  const wordCount = body.split(/\s+/).filter(Boolean).length;

  return (
    <View style={[jStyles.container, { backgroundColor: theme.bg }]}>
      {/* Header */}
      <View style={jStyles.header}>
        <Text style={[jStyles.heading, { color: theme.textPrimary }]}>Journal</Text>
        <Text style={{ color: Colors.goldPrimary, fontSize: 13 }}>
          {sampleEntries.length} entries
        </Text>
      </View>

      {/* Tabs */}
      <View style={jStyles.tabRow}>
        {(['write', 'entries', 'mood'] as const).map((t) => (
          <TouchableOpacity
            key={t}
            style={[jStyles.tab, tab === t && jStyles.tabActive]}
            onPress={() => setTab(t)}
          >
            <Text
              style={[
                jStyles.tabText,
                { color: tab === t ? Colors.goldPrimary : theme.textSecondary },
              ]}
            >
              {t === 'write' ? 'Write' : t === 'entries' ? 'Entries' : 'Mood Graph'}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Content */}
      {tab === 'write' && (
        <ScrollView contentContainerStyle={jStyles.scrollContent} showsVerticalScrollIndicator={false}>
          {/* Mode selector */}
          <View style={jStyles.modeRow}>
            {([
              { key: 'typed' as const, label: 'Type', icon: '\u2328' },
              { key: 'voice' as const, label: 'Voice', icon: '\uD83C\uDF99' },
              { key: 'drawing' as const, label: 'Draw', icon: '\uD83C\uDFA8' },
            ]).map((m) => (
              <TouchableOpacity
                key={m.key}
                style={[
                  jStyles.modeChip,
                  mode === m.key && { backgroundColor: Colors.goldPrimary + '25' },
                ]}
                onPress={() => setMode(m.key)}
              >
                <Text style={{ fontSize: 14 }}>{m.icon}</Text>
                <Text
                  style={{
                    fontSize: 12,
                    marginLeft: 4,
                    color: mode === m.key ? Colors.goldPrimary : theme.textSecondary,
                  }}
                >
                  {m.label}
                </Text>
              </TouchableOpacity>
            ))}
            <View style={{ flex: 1 }} />
            <TouchableOpacity onPress={() => setShowPrompts(!showPrompts)}>
              <Text style={{ fontSize: 22, color: Colors.goldPrimary }}>
                {showPrompts ? '\uD83D\uDCA1' : '\uD83D\uDCA1'}
              </Text>
            </TouchableOpacity>
          </View>

          {/* Prompts */}
          {showPrompts && (
            <View style={{ marginBottom: 16 }}>
              <Text style={[jStyles.goldLabel, { color: Colors.goldPrimary }]}>
                Writing Prompts
              </Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                {prompts.map((p, i) => (
                  <TouchableOpacity
                    key={i}
                    style={[jStyles.promptCard, { backgroundColor: Colors.goldPrimary + '15' }]}
                    onPress={() => setBody(body + `\n\nPrompt: ${p.text}\n\n`)}
                  >
                    <Text style={{ color: Colors.goldPrimary, fontSize: 11, fontWeight: '600' }}>
                      {p.category}
                    </Text>
                    <Text style={{ color: theme.textPrimary, fontSize: 13, marginTop: 4 }} numberOfLines={3}>
                      {p.text}
                    </Text>
                    {p.chapter && (
                      <Text style={{ color: theme.textSecondary, fontSize: 10, marginTop: 4 }}>
                        From Chapter {p.chapter}
                      </Text>
                    )}
                  </TouchableOpacity>
                ))}
              </ScrollView>
            </View>
          )}

          {/* Editor */}
          {mode === 'typed' && (
            <>
              <TextInput
                value={title}
                onChangeText={setTitle}
                placeholder="Entry title..."
                placeholderTextColor={theme.textSecondary + '80'}
                style={[jStyles.titleInput, { color: theme.textPrimary }]}
              />
              <TextInput
                value={body}
                onChangeText={setBody}
                placeholder="Begin writing... let the words flow without judgement."
                placeholderTextColor={theme.textSecondary + '60'}
                multiline
                textAlignVertical="top"
                style={[jStyles.bodyInput, { color: theme.textPrimary }]}
              />
              <Text style={{ color: theme.textSecondary, fontSize: 11 }}>
                {wordCount} words
              </Text>
            </>
          )}

          {mode === 'voice' && (
            <View style={jStyles.voiceContainer}>
              <TouchableOpacity
                style={[
                  jStyles.recordBtn,
                  {
                    backgroundColor: isRecording
                      ? Colors.error + '90'
                      : Colors.goldPrimary,
                  },
                ]}
                onPress={() => setIsRecording(!isRecording)}
              >
                <Text style={jStyles.recordIcon}>
                  {isRecording ? '\u23F9' : '\uD83C\uDF99'}
                </Text>
              </TouchableOpacity>
              <Text style={{ color: isRecording ? Colors.error : theme.textSecondary, marginTop: 8 }}>
                {isRecording ? 'Recording... tap to stop' : 'Tap to record'}
              </Text>
              <TextInput
                value={body}
                onChangeText={setBody}
                placeholder="Voice transcription will appear here..."
                placeholderTextColor={theme.textSecondary + '60'}
                multiline
                textAlignVertical="top"
                style={[
                  jStyles.transcriptionInput,
                  {
                    color: theme.textPrimary,
                    borderColor: theme.glassBorder,
                  },
                ]}
              />
            </View>
          )}

          {mode === 'drawing' && (
            <View style={jStyles.drawingContainer}>
              {/* Toolbar */}
              <View style={jStyles.drawToolbar}>
                {['\u270F\uFE0F', '\uD83D\uDD8C', '\u2B55', '\uD83C\uDFA8', '\u21A9', '\u21AA'].map(
                  (icon, i) => (
                    <TouchableOpacity key={i} style={jStyles.drawTool}>
                      <Text style={{ fontSize: 18 }}>{icon}</Text>
                    </TouchableOpacity>
                  ),
                )}
              </View>
              {/* Canvas placeholder */}
              <View
                style={[
                  jStyles.canvas,
                  {
                    backgroundColor: theme.dark
                      ? Colors.green900 + '80'
                      : '#FFFFFF',
                    borderColor: theme.glassBorder,
                  },
                ]}
              >
                <Text style={{ fontSize: 36, opacity: 0.3 }}>{'\uD83C\uDFA8'}</Text>
                <Text style={{ color: theme.textSecondary + '80', marginTop: 8 }}>
                  Draw with your finger or Apple Pencil
                </Text>
                <Text style={{ color: theme.textSecondary + '50', fontSize: 11, marginTop: 4 }}>
                  Supports pressure sensitivity via react-native-canvas
                </Text>
              </View>
            </View>
          )}

          {/* Mood selector */}
          <Text style={[jStyles.moodPrompt, { color: theme.textSecondary }]}>
            How does this writing feel?
          </Text>
          <View style={jStyles.moodRow}>
            {moods.map((emoji, idx) => (
              <TouchableOpacity
                key={idx}
                style={[
                  jStyles.moodCircle,
                  selectedMood === idx && {
                    backgroundColor: moodColors[idx] + '30',
                    borderColor: moodColors[idx],
                    borderWidth: 2,
                  },
                ]}
                onPress={() => setSelectedMood(idx)}
              >
                <Text style={{ fontSize: 22 }}>{emoji}</Text>
              </TouchableOpacity>
            ))}
          </View>

          {/* Action buttons */}
          <View style={jStyles.actionRow}>
            <TouchableOpacity
              style={[jStyles.actionBtn, jStyles.outlineBtn, { borderColor: Colors.goldPrimary + '60' }]}
            >
              <Text style={{ color: Colors.goldPrimary, fontSize: 14 }}>
                {'\uD83D\uDCAC'} Send to Coach
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[jStyles.actionBtn, { backgroundColor: Colors.goldPrimary }]}
            >
              <Text style={{ color: '#fff', fontSize: 14, fontWeight: '600' }}>
                {'\uD83D\uDCBE'} Save Entry
              </Text>
            </TouchableOpacity>
          </View>

          {body.length > 50 && (
            <TouchableOpacity style={jStyles.shareExcerptBtn} onPress={goToShare}>
              <Text style={{ color: Colors.goldPrimary, fontSize: 13 }}>
                {'\u2B06'} Share an excerpt from this entry
              </Text>
            </TouchableOpacity>
          )}
        </ScrollView>
      )}

      {tab === 'entries' && (
        <FlatList
          data={sampleEntries}
          keyExtractor={(e) => e.id}
          contentContainerStyle={{ padding: 20 }}
          ItemSeparatorComponent={() => <View style={{ height: 12 }} />}
          renderItem={({ item }) => (
            <EntryCard entry={item} goToShare={goToShare} />
          )}
        />
      )}

      {tab === 'mood' && <MoodGraphView entries={sampleEntries} />}
    </View>
  );
};

// ---------------------------------------------------------------------------
// Entry card
// ---------------------------------------------------------------------------

const EntryCard: React.FC<{ entry: JournalEntry; goToShare: () => void }> = ({
  entry,
  goToShare,
}) => {
  const { theme } = useTheme();
  const modeIcons: Record<JournalMode, string> = { typed: '\u2328', voice: '\uD83C\uDF99', drawing: '\uD83C\uDFA8' };

  return (
    <GlassCard>
      <View style={jStyles.entryHeader}>
        <View style={{ flexDirection: 'row', alignItems: 'center', flex: 1 }}>
          <Text style={{ fontSize: 20, marginRight: 8 }}>{moods[entry.moodIndex]}</Text>
          <View style={{ flex: 1 }}>
            <Text style={[jStyles.entryTitle, { color: theme.textPrimary }]}>{entry.title}</Text>
            <Text style={{ color: theme.textSecondary, fontSize: 11 }}>
              {entry.date} {'\u2022'} {entry.time}
            </Text>
          </View>
        </View>
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          <Text style={{ fontSize: 13, color: theme.textSecondary }}>{modeIcons[entry.mode]}</Text>
          {entry.sentToCoach && (
            <Text style={{ fontSize: 13, color: Colors.goldPrimary, marginLeft: 4 }}>{'\uD83D\uDCAC'}</Text>
          )}
        </View>
      </View>

      <Text
        style={[
          jStyles.entryPreview,
          {
            color: theme.textPrimary + 'DD',
            fontStyle: entry.mode === 'voice' ? 'italic' : 'normal',
          },
        ]}
        numberOfLines={3}
      >
        {entry.preview}
      </Text>

      {entry.tags.length > 0 && (
        <View style={jStyles.tagsRow}>
          {entry.tags.map((tag) => (
            <View key={tag} style={[jStyles.tag, { backgroundColor: Colors.goldPrimary + '15' }]}>
              <Text style={{ color: Colors.goldPrimary, fontSize: 10 }}>{tag}</Text>
            </View>
          ))}
        </View>
      )}

      <View style={jStyles.entryFooter}>
        <Text style={{ color: theme.textSecondary, fontSize: 11 }}>{entry.wordCount} words</Text>
        <View style={{ flexDirection: 'row' }}>
          <TouchableOpacity onPress={goToShare} style={{ padding: 4, marginRight: 8 }}>
            <Text style={{ color: Colors.goldPrimary, fontSize: 14 }}>{'\u2B06'}</Text>
          </TouchableOpacity>
          <TouchableOpacity style={{ padding: 4 }}>
            <Text style={{ color: theme.textSecondary, fontSize: 14 }}>{'\uD83D\uDCAC'}</Text>
          </TouchableOpacity>
        </View>
      </View>
    </GlassCard>
  );
};

// ---------------------------------------------------------------------------
// Mood graph
// ---------------------------------------------------------------------------

const MoodGraphView: React.FC<{ entries: JournalEntry[] }> = ({ entries }) => {
  const { theme } = useTheme();
  const reversed = [...entries].reverse();

  return (
    <ScrollView contentContainerStyle={{ padding: 20 }}>
      <Text style={[jStyles.sectionTitle, { color: theme.textPrimary }]}>
        Mood Over Time
      </Text>
      <Text style={{ color: theme.textSecondary, fontSize: 13, marginBottom: 16 }}>
        Your emotional landscape across journal entries
      </Text>

      {/* Simple text-based graph */}
      <GlassCard>
        {reversed.map((entry, idx) => {
          const barWidth = ((entry.moodIndex + 1) / 5) * 100;
          return (
            <View key={entry.id} style={jStyles.graphRow}>
              <Text style={{ width: 50, fontSize: 10, color: theme.textSecondary }}>
                {entry.date}
              </Text>
              <View style={jStyles.graphBarBg}>
                <View
                  style={[
                    jStyles.graphBar,
                    {
                      width: `${barWidth}%`,
                      backgroundColor: moodColors[entry.moodIndex],
                    },
                  ]}
                />
              </View>
              <Text style={{ fontSize: 16, marginLeft: 8 }}>{moods[entry.moodIndex]}</Text>
            </View>
          );
        })}
      </GlassCard>

      {/* Summary */}
      <GlassCard style={{ marginTop: 16 }}>
        <Text style={[jStyles.goldLabel, { color: Colors.goldPrimary, marginBottom: 12 }]}>
          This Week's Summary
        </Text>
        <View style={{ flexDirection: 'row', justifyContent: 'space-evenly' }}>
          <View style={{ alignItems: 'center' }}>
            <Text style={{ fontSize: 24 }}>
              {moods[Math.round(entries.reduce((s, e) => s + e.moodIndex, 0) / entries.length)]}
            </Text>
            <Text style={{ color: theme.textSecondary, fontSize: 11 }}>Average</Text>
          </View>
          <View style={{ alignItems: 'center' }}>
            <Text style={{ color: Colors.goldPrimary, fontSize: 24, fontWeight: '700' }}>
              {entries.length}
            </Text>
            <Text style={{ color: theme.textSecondary, fontSize: 11 }}>Entries</Text>
          </View>
          <View style={{ alignItems: 'center' }}>
            <Text style={{ color: Colors.goldPrimary, fontSize: 24, fontWeight: '700' }}>
              {entries.reduce((s, e) => s + e.wordCount, 0)}
            </Text>
            <Text style={{ color: theme.textSecondary, fontSize: 11 }}>Words</Text>
          </View>
        </View>
      </GlassCard>
    </ScrollView>
  );
};

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

const jStyles = StyleSheet.create({
  container: { flex: 1 },
  scrollContent: { paddingHorizontal: 20, paddingBottom: 32 },

  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: Platform.OS === 'ios' ? 60 : 16,
    paddingBottom: 8,
  },
  heading: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 28,
    fontWeight: '700',
  },

  tabRow: { flexDirection: 'row', paddingHorizontal: 20, marginBottom: 8 },
  tab: { paddingVertical: 8, paddingHorizontal: 16 },
  tabActive: { borderBottomWidth: 2, borderBottomColor: Colors.goldPrimary },
  tabText: { fontSize: 14, fontWeight: '500' },

  glassCard: {
    borderRadius: 20,
    borderWidth: 1,
    padding: 16,
    marginBottom: 12,
  },

  modeRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  modeChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 16,
    marginRight: 8,
  },

  goldLabel: { fontSize: 12, fontWeight: '600', letterSpacing: 0.5, marginBottom: 8 },

  promptCard: {
    width: 220,
    padding: 12,
    borderRadius: 14,
    marginRight: 12,
  },

  titleInput: {
    fontFamily: Platform.OS === 'ios' ? 'Georgia' : 'serif',
    fontSize: 22,
    fontWeight: '600',
    paddingVertical: 8,
  },
  bodyInput: {
    fontSize: 16,
    lineHeight: 26,
    minHeight: 180,
    paddingVertical: 8,
  },

  voiceContainer: { alignItems: 'center', paddingVertical: 16 },
  recordBtn: {
    width: 64,
    height: 64,
    borderRadius: 32,
    justifyContent: 'center',
    alignItems: 'center',
  },
  recordIcon: { fontSize: 28, color: '#fff' },
  transcriptionInput: {
    width: '100%',
    fontSize: 16,
    lineHeight: 26,
    minHeight: 120,
    padding: 14,
    borderWidth: 1,
    borderRadius: 16,
    marginTop: 16,
  },

  drawingContainer: { marginBottom: 16 },
  drawToolbar: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 8,
  },
  drawTool: { padding: 8 },
  canvas: {
    height: 280,
    borderRadius: 16,
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },

  moodPrompt: { fontSize: 14, fontWeight: '600', marginTop: 16, marginBottom: 8 },
  moodRow: { flexDirection: 'row', justifyContent: 'space-evenly', marginBottom: 16 },
  moodCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },

  actionRow: { flexDirection: 'row', gap: 12 },
  actionBtn: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  outlineBtn: { borderWidth: 1, backgroundColor: 'transparent' },

  shareExcerptBtn: { alignItems: 'center', paddingVertical: 12, marginTop: 8 },

  sectionTitle: { fontSize: 16, fontWeight: '600', marginBottom: 4 },

  entryHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  entryTitle: { fontSize: 14, fontWeight: '600' },
  entryPreview: { fontSize: 14, lineHeight: 20, marginBottom: 8 },
  tagsRow: { flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginBottom: 6 },
  tag: { paddingHorizontal: 8, paddingVertical: 2, borderRadius: 8 },
  entryFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  graphRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 10,
  },
  graphBarBg: {
    flex: 1,
    height: 8,
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 4,
    overflow: 'hidden',
  },
  graphBar: { height: '100%', borderRadius: 4 },
});

export default JournalScreen;
