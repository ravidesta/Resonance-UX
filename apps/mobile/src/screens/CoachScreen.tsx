import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Animated,
  Easing,
  Platform,
  KeyboardAvoidingView,
} from 'react-native';
import { useTheme, Colors } from '../App';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type MessageSender = 'user' | 'coach';
type MessageType = 'text' | 'voice_memo' | 'journal_ref' | 'exercise_card';

interface ChatMessage {
  id: string;
  sender: MessageSender;
  type: MessageType;
  text?: string;
  timestamp: string;
  voiceDurationSec?: number;
  journalTitle?: string;
  journalDate?: string;
  journalExcerpt?: string;
  exerciseTitle?: string;
  exerciseDescription?: string;
  exerciseSteps?: string[];
  exerciseDurationMin?: number;
}

interface QuickReply {
  text: string;
  icon: string;
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const initialMessages: ChatMessage[] = [
  {
    id: '1', sender: 'coach', type: 'text', timestamp: '9:15 AM',
    text: 'Welcome back. I noticed you completed your morning journal entry \u2014 that is three days in a row now. How are you feeling about the consistency?',
  },
  {
    id: '2', sender: 'user', type: 'text', timestamp: '9:18 AM',
    text: 'It feels good actually. I almost skipped today but then I remembered what you said about showing up even when it feels pointless.',
  },
  {
    id: '3', sender: 'coach', type: 'text', timestamp: '9:19 AM',
    text: 'That is a beautiful observation. The moments when you show up despite resistance are often the most transformative ones. Your journal entry today touched on family patterns \u2014 would you like to explore that further?',
  },
  {
    id: '4', sender: 'user', type: 'journal_ref', timestamp: '9:20 AM',
    journalTitle: 'Chapter 3 response', journalDate: 'Mar 16',
    journalExcerpt: 'The section on family patterns hit hard. I always thought my need to fix everyone was just being kind, but I can see now it is a way of managing my own anxiety...',
  },
  {
    id: '5', sender: 'coach', type: 'exercise_card', timestamp: '9:21 AM',
    exerciseTitle: 'Pattern Pause Practice',
    exerciseDescription: 'A somatic exercise for interrupting automatic caretaking responses.',
    exerciseSteps: [
      'Notice when the urge to "fix" arises in your body',
      'Place one hand on your heart and one on your belly',
      'Take three slow breaths, counting to five on each exhale',
      'Ask yourself: "Is this mine to carry?"',
      'Allow whatever answer comes without judging it',
    ],
    exerciseDurationMin: 5,
  },
  {
    id: '6', sender: 'user', type: 'voice_memo', timestamp: '9:25 AM',
    text: 'Voice memo', voiceDurationSec: 83,
  },
  {
    id: '7', sender: 'coach', type: 'text', timestamp: '9:27 AM',
    text: 'Thank you for sharing that voice note. I can hear the emotion in your voice, and I want you to know that is completely valid. What you described \u2014 the tightness in your throat when you try to set boundaries \u2014 is very common for people with caretaking patterns.\n\nYou are not broken. You are becoming aware. And awareness is the first step toward choice.',
  },
];

const quickReplies: QuickReply[] = [
  { text: 'Tell me more', icon: '\u2193' },
  { text: 'I need an exercise', icon: '\uD83C\uDFCB' },
  { text: 'How do I sit with this?', icon: '\uD83E\uDDD8' },
  { text: 'Share from my journal', icon: '\u270E' },
  { text: "I'm struggling today", icon: '\u2764' },
  { text: 'Breathing exercise?', icon: '\uD83C\uDF2C' },
];

// ---------------------------------------------------------------------------
// Coach Screen
// ---------------------------------------------------------------------------

const CoachScreen: React.FC = () => {
  const { theme } = useTheme();
  const [messages, setMessages] = useState<ChatMessage[]>(initialMessages);
  const [inputText, setInputText] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const [showQuickReplies, setShowQuickReplies] = useState(true);
  const flatListRef = useRef<FlatList>(null);

  useEffect(() => {
    setTimeout(() => {
      flatListRef.current?.scrollToEnd({ animated: true });
    }, 100);
  }, [messages.length]);

  const sendMessage = (text: string) => {
    if (!text.trim()) return;
    const newMsg: ChatMessage = {
      id: String(messages.length + 1),
      sender: 'user',
      type: 'text',
      text: text.trim(),
      timestamp: 'Now',
    };
    setMessages((prev) => [...prev, newMsg]);
    setInputText('');
    setShowQuickReplies(false);
  };

  const formatDuration = (sec: number) => {
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  // ---------------------------------------------------------------------------
  // Message bubble
  // ---------------------------------------------------------------------------

  const renderMessage = ({ item }: { item: ChatMessage }) => {
    const isUser = item.sender === 'user';

    switch (item.type) {
      case 'text':
        return (
          <View style={[cStyles.bubbleRow, isUser && cStyles.bubbleRowUser]}>
            <View
              style={[
                cStyles.bubble,
                isUser
                  ? [cStyles.bubbleUser, { backgroundColor: Colors.goldPrimary + '30' }]
                  : [cStyles.bubbleCoach, { backgroundColor: theme.glassSurface, borderColor: theme.glassBorder }],
              ]}
            >
              <Text style={[cStyles.bubbleText, { color: theme.textPrimary }]}>
                {item.text}
              </Text>
            </View>
            <Text style={[cStyles.timestamp, { color: theme.textSecondary + '90' }]}>
              {item.timestamp}
            </Text>
          </View>
        );

      case 'voice_memo':
        return (
          <View style={[cStyles.bubbleRow, isUser && cStyles.bubbleRowUser]}>
            <View
              style={[
                cStyles.bubble,
                cStyles.voiceBubble,
                {
                  backgroundColor: isUser
                    ? Colors.goldPrimary + '30'
                    : theme.glassSurface,
                  borderColor: theme.glassBorder,
                },
              ]}
            >
              <TouchableOpacity style={cStyles.playBtn}>
                <Text style={cStyles.playBtnText}>{'\u25B6'}</Text>
              </TouchableOpacity>
              {/* Waveform */}
              <View style={cStyles.waveform}>
                {Array.from({ length: 20 }).map((_, i) => (
                  <View
                    key={i}
                    style={[
                      cStyles.waveBar,
                      {
                        height: 6 + Math.sin(i * 0.8) * 10,
                        backgroundColor: Colors.goldPrimary + (i < 8 ? 'CC' : '50'),
                      },
                    ]}
                  />
                ))}
              </View>
              <Text style={{ color: theme.textSecondary, fontSize: 11 }}>
                {formatDuration(item.voiceDurationSec ?? 0)}
              </Text>
            </View>
            <Text style={[cStyles.timestamp, { color: theme.textSecondary + '90' }]}>
              {item.timestamp}
            </Text>
          </View>
        );

      case 'journal_ref':
        return (
          <View style={[cStyles.bubbleRow, cStyles.bubbleRowUser]}>
            <View
              style={[
                cStyles.bubble,
                cStyles.journalRef,
                { backgroundColor: Colors.goldPrimary + '18', borderColor: Colors.goldPrimary + '40' },
              ]}
            >
              <View style={cStyles.journalRefHeader}>
                <Text style={{ fontSize: 13 }}>{'\u270E'}</Text>
                <Text style={{ color: Colors.goldPrimary, fontSize: 11, fontWeight: '600', marginLeft: 4 }}>
                  Journal Entry
                </Text>
              </View>
              <Text style={[cStyles.journalRefTitle, { color: theme.textPrimary }]}>
                {item.journalTitle}
              </Text>
              <Text style={{ color: theme.textSecondary, fontSize: 11 }}>
                {item.journalDate}
              </Text>
              <Text
                style={[cStyles.journalRefExcerpt, { color: theme.textPrimary + 'CC' }]}
                numberOfLines={3}
              >
                {item.journalExcerpt}
              </Text>
            </View>
            <Text style={[cStyles.timestamp, { color: theme.textSecondary + '90' }]}>
              {item.timestamp}
            </Text>
          </View>
        );

      case 'exercise_card':
        return <ExerciseCard item={item} />;

      default:
        return null;
    }
  };

  // ---------------------------------------------------------------------------
  // Exercise card sub-component
  // ---------------------------------------------------------------------------

  const ExerciseCard: React.FC<{ item: ChatMessage }> = ({ item }) => {
    const [expanded, setExpanded] = useState(false);

    return (
      <View style={cStyles.bubbleRow}>
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={() => setExpanded(!expanded)}
          style={[
            cStyles.bubble,
            cStyles.exerciseCard,
            {
              backgroundColor: theme.dark ? Colors.green800 + '99' : Colors.green100 + 'BB',
              borderColor: Colors.goldPrimary + '40',
            },
          ]}
        >
          <View style={cStyles.exerciseHeader}>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <Text style={{ fontSize: 16 }}>{'\uD83E\uDDD8'}</Text>
              <Text style={{ color: Colors.goldPrimary, fontSize: 12, fontWeight: '600', marginLeft: 6 }}>
                Exercise
              </Text>
            </View>
            <Text style={{ color: theme.textSecondary, fontSize: 11 }}>
              {item.exerciseDurationMin} min
            </Text>
          </View>

          <Text style={[cStyles.exerciseTitle, { color: theme.textPrimary }]}>
            {item.exerciseTitle}
          </Text>
          <Text style={{ color: theme.textSecondary, fontSize: 12 }}>
            {item.exerciseDescription}
          </Text>

          {expanded && item.exerciseSteps && (
            <View style={cStyles.exerciseSteps}>
              <View style={[cStyles.divider, { backgroundColor: Colors.goldPrimary + '25' }]} />
              {item.exerciseSteps.map((step, idx) => (
                <View key={idx} style={cStyles.stepRow}>
                  <View style={cStyles.stepBadge}>
                    <Text style={cStyles.stepNum}>{idx + 1}</Text>
                  </View>
                  <Text style={[cStyles.stepText, { color: theme.textPrimary }]}>
                    {step}
                  </Text>
                </View>
              ))}
              <TouchableOpacity
                style={[cStyles.beginBtn, { backgroundColor: Colors.goldPrimary }]}
              >
                <Text style={{ color: '#fff', fontWeight: '600' }}>
                  {'\u25B6'} Begin Exercise
                </Text>
              </TouchableOpacity>
            </View>
          )}

          {!expanded && (
            <Text style={{ color: Colors.goldPrimary + '90', fontSize: 11, marginTop: 6 }}>
              Tap to expand {'\u2022'} {item.exerciseSteps?.length ?? 0} steps
            </Text>
          )}
        </TouchableOpacity>
        <Text style={[cStyles.timestamp, { color: theme.textSecondary + '90' }]}>
          {item.timestamp}
        </Text>
      </View>
    );
  };

  return (
    <KeyboardAvoidingView
      style={[cStyles.container, { backgroundColor: theme.bg }]}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 88 : 0}
    >
      {/* Header */}
      <View style={cStyles.header}>
        <View
          style={[
            cStyles.avatar,
            { backgroundColor: Colors.goldPrimary },
          ]}
        >
          <Text style={{ color: '#fff', fontSize: 18 }}>{'\u2728'}</Text>
        </View>
        <View style={{ flex: 1, marginLeft: 12 }}>
          <Text style={[cStyles.headerTitle, { color: theme.textPrimary }]}>
            Your Coach
          </Text>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <View style={cStyles.onlineDot} />
            <Text style={{ color: Colors.success, fontSize: 11, marginLeft: 4 }}>
              Available now
            </Text>
          </View>
        </View>
        <TouchableOpacity>
          <Text style={{ fontSize: 20, color: theme.textSecondary }}>{'\u2699'}</Text>
        </TouchableOpacity>
      </View>

      <View style={[cStyles.headerDivider, { backgroundColor: theme.glassBorder }]} />

      {/* Messages */}
      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={(m) => m.id}
        renderItem={renderMessage}
        contentContainerStyle={{ paddingHorizontal: 16, paddingVertical: 8 }}
        onContentSizeChange={() => flatListRef.current?.scrollToEnd({ animated: true })}
      />

      {/* Quick replies */}
      {showQuickReplies && (
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={cStyles.quickRow}
        >
          {quickReplies.map((qr) => (
            <TouchableOpacity
              key={qr.text}
              style={[cStyles.quickChip, { borderColor: Colors.goldPrimary + '35', backgroundColor: Colors.goldPrimary + '12' }]}
              onPress={() => sendMessage(qr.text)}
            >
              <Text style={{ fontSize: 13, marginRight: 4 }}>{qr.icon}</Text>
              <Text style={{ color: Colors.goldPrimary, fontSize: 12 }}>{qr.text}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      )}

      {/* Input bar */}
      <View
        style={[
          cStyles.inputBar,
          {
            backgroundColor: theme.dark
              ? Colors.green900 + 'E6'
              : '#FFFFFFE6',
          },
        ]}
      >
        <TouchableOpacity style={cStyles.attachBtn}>
          <Text style={{ fontSize: 20, color: theme.textSecondary }}>{'\uD83D\uDCCE'}</Text>
        </TouchableOpacity>

        <TextInput
          value={inputText}
          onChangeText={setInputText}
          placeholder="Message your coach..."
          placeholderTextColor={theme.textSecondary + '80'}
          style={[
            cStyles.textInput,
            {
              color: theme.textPrimary,
              borderColor: theme.glassBorder,
            },
          ]}
          multiline
          maxLength={2000}
        />

        {inputText.trim() ? (
          <TouchableOpacity
            style={[cStyles.sendBtn, { backgroundColor: Colors.goldPrimary }]}
            onPress={() => sendMessage(inputText)}
          >
            <Text style={{ color: '#fff', fontSize: 16 }}>{'\u2191'}</Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity
            style={[
              cStyles.micBtn,
              isRecording && { backgroundColor: Colors.error + '25' },
            ]}
            onPress={() => setIsRecording(!isRecording)}
          >
            <Text style={{ fontSize: 20, color: isRecording ? Colors.error : Colors.goldPrimary }}>
              {isRecording ? '\u23F9' : '\uD83C\uDF99'}
            </Text>
          </TouchableOpacity>
        )}
      </View>
    </KeyboardAvoidingView>
  );
};

// ---------------------------------------------------------------------------
// Styles
// ---------------------------------------------------------------------------

const cStyles = StyleSheet.create({
  container: { flex: 1 },

  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: Platform.OS === 'ios' ? 60 : 16,
    paddingBottom: 12,
  },
  headerTitle: {
    fontSize: 17,
    fontWeight: '600',
  },
  avatar: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  onlineDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: Colors.success,
  },
  headerDivider: { height: 1, marginBottom: 4 },

  // Bubbles
  bubbleRow: { marginBottom: 8 },
  bubbleRowUser: { alignItems: 'flex-end' },
  bubble: {
    maxWidth: '85%',
    borderRadius: 20,
    padding: 14,
  },
  bubbleUser: {
    borderBottomRightRadius: 4,
  },
  bubbleCoach: {
    borderBottomLeftRadius: 4,
    borderWidth: 1,
  },
  bubbleText: { fontSize: 14, lineHeight: 21 },
  timestamp: { fontSize: 10, marginTop: 2, marginHorizontal: 4 },

  // Voice
  voiceBubble: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    maxWidth: '70%',
  },
  playBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Colors.goldPrimary + '25',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 8,
  },
  playBtnText: { color: Colors.goldPrimary, fontSize: 14 },
  waveform: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    gap: 2,
    marginRight: 8,
  },
  waveBar: { width: 3, borderRadius: 1 },

  // Journal ref
  journalRef: { borderWidth: 1 },
  journalRefHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 4 },
  journalRefTitle: { fontSize: 14, fontWeight: '600' },
  journalRefExcerpt: { fontSize: 12, fontStyle: 'italic', marginTop: 4, lineHeight: 18 },

  // Exercise
  exerciseCard: { borderWidth: 1, maxWidth: '90%' },
  exerciseHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 6 },
  exerciseTitle: { fontSize: 15, fontWeight: '700', marginBottom: 2 },
  exerciseSteps: { marginTop: 8 },
  divider: { height: 1, marginBottom: 12 },
  stepRow: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 8 },
  stepBadge: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: Colors.goldPrimary + '25',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  stepNum: { color: Colors.goldPrimary, fontSize: 11, fontWeight: '600' },
  stepText: { flex: 1, fontSize: 14, lineHeight: 20 },
  beginBtn: {
    marginTop: 8,
    paddingVertical: 10,
    borderRadius: 12,
    alignItems: 'center',
  },

  // Quick replies
  quickRow: { paddingHorizontal: 16, paddingVertical: 8, gap: 8 },
  quickChip: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
    borderWidth: 1,
  },

  // Input
  inputBar: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingHorizontal: 12,
    paddingVertical: 8,
    paddingBottom: Platform.OS === 'ios' ? 24 : 8,
  },
  attachBtn: { padding: 8 },
  textInput: {
    flex: 1,
    borderWidth: 1,
    borderRadius: 24,
    paddingHorizontal: 16,
    paddingVertical: 8,
    maxHeight: 100,
    fontSize: 14,
  },
  sendBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 8,
  },
  micBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: 8,
  },
});

export default CoachScreen;
