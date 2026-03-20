import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, TextInput, ScrollView, TouchableOpacity,
  Animated, Dimensions, Platform, KeyboardAvoidingView,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Spacing, Radii, Typography } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';

const { width } = Dimensions.get('window');

const sampleDocuments = [
  { id: 1, title: 'Morning Reflections', date: 'Today', words: 342, excerpt: 'The dawn light filters through...' },
  { id: 2, title: 'Growth Intentions Q1', date: 'Mar 15', words: 1205, excerpt: 'As I reflect on my lifewheel...' },
  { id: 3, title: 'Letter to Future Self', date: 'Mar 10', words: 867, excerpt: 'Dear luminous future me...' },
  { id: 4, title: 'Gratitude Practice', date: 'Mar 8', words: 234, excerpt: 'Three things I notice today...' },
  { id: 5, title: 'Creative Exploration', date: 'Mar 5', words: 1543, excerpt: 'What if I allowed myself...' },
];

export default function WriterScreen({ navigation }) {
  const { colors, isDark } = useTheme();
  const [view, setView] = useState('library'); // library | editor
  const [content, setContent] = useState('');
  const [title, setTitle] = useState('');
  const [focusMode, setFocusMode] = useState(false);
  const [isLuminizing, setIsLuminizing] = useState(false);
  const [showLibrary, setShowLibrary] = useState(true);
  const fadeAnim = useRef(new Animated.Value(1)).current;

  const wordCount = content.trim().split(/\s+/).filter(Boolean).length;
  const readingTime = Math.max(1, Math.ceil(wordCount / 200));

  const handleLuminize = () => {
    setIsLuminizing(true);
    // Simulated AI prose refinement
    setTimeout(() => {
      setIsLuminizing(false);
    }, 2000);
  };

  const renderLibrary = () => (
    <ScrollView showsVerticalScrollIndicator={false} style={{ flex: 1 }}>
      <View style={styles.libraryHeader}>
        <ResonanceText variant="h2">Sanctuary</ResonanceText>
        <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
          Your luminous writing space
        </ResonanceText>
      </View>

      <ResonanceButton
        title="New Document"
        variant="gold"
        size="lg"
        style={{ marginTop: 16, alignSelf: 'flex-start' }}
        onPress={() => {
          setView('editor');
          setTitle('');
          setContent('');
        }}
      />

      <ResonanceText variant="caption" color="muted" style={{ marginTop: 24, marginBottom: 12 }}>
        YOUR LIBRARY
      </ResonanceText>

      {sampleDocuments.map((doc) => (
        <TouchableOpacity
          key={doc.id}
          activeOpacity={0.7}
          onPress={() => {
            setView('editor');
            setTitle(doc.title);
            setContent(doc.excerpt);
          }}
        >
          <GlassCard style={styles.docCard}>
            <ResonanceText variant="subtitle">{doc.title}</ResonanceText>
            <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 4 }} numberOfLines={2}>
              {doc.excerpt}
            </ResonanceText>
            <View style={styles.docMeta}>
              <ResonanceText variant="caption" color="light">{doc.date}</ResonanceText>
              <ResonanceText variant="caption" color="light">{doc.words} words</ResonanceText>
            </View>
          </GlassCard>
        </TouchableOpacity>
      ))}

      <View style={{ height: 100 }} />
    </ScrollView>
  );

  const renderEditor = () => (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      {/* Editor toolbar */}
      {!focusMode && (
        <Animated.View style={[styles.toolbar, { borderBottomColor: colors.borderLight }]}>
          <TouchableOpacity onPress={() => setView('library')}>
            <ResonanceText color="gold">← Library</ResonanceText>
          </TouchableOpacity>
          <View style={{ flexDirection: 'row', gap: 12 }}>
            <TouchableOpacity
              onPress={() => setFocusMode(true)}
              style={[styles.toolbarBtn, { borderColor: colors.borderLight }]}
            >
              <ResonanceText variant="bodySmall">🎯 Focus</ResonanceText>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={handleLuminize}
              style={[styles.toolbarBtn, { borderColor: colors.gold, backgroundColor: colors.gold + '10' }]}
            >
              <ResonanceText variant="bodySmall" color="gold">
                {isLuminizing ? '✨ Refining...' : '✨ Luminize'}
              </ResonanceText>
            </TouchableOpacity>
          </View>
        </Animated.View>
      )}

      <ScrollView style={{ flex: 1 }} keyboardDismissMode="interactive">
        {/* Title */}
        <TextInput
          style={[
            styles.titleInput,
            {
              color: colors.textMain,
              fontFamily: Typography.serif,
            },
          ]}
          placeholder="Title"
          placeholderTextColor={colors.textLight}
          value={title}
          onChangeText={setTitle}
        />

        {/* Content */}
        <TextInput
          style={[
            styles.contentInput,
            {
              color: colors.textMain,
              fontFamily: Typography.sans,
            },
          ]}
          placeholder="Begin writing..."
          placeholderTextColor={colors.textLight}
          value={content}
          onChangeText={setContent}
          multiline
          textAlignVertical="top"
          scrollEnabled={false}
        />
      </ScrollView>

      {/* Footer stats */}
      {!focusMode && (
        <View style={[styles.editorFooter, { borderTopColor: colors.borderLight }]}>
          <ResonanceText variant="caption" color="light">
            {wordCount} words · {readingTime} min read
          </ResonanceText>
          <ResonanceText variant="caption" color="light">
            Saved automatically
          </ResonanceText>
        </View>
      )}

      {/* Focus mode exit */}
      {focusMode && (
        <TouchableOpacity
          style={styles.focusExit}
          onPress={() => setFocusMode(false)}
        >
          <ResonanceText variant="bodySmall" color="light">Exit Focus Mode</ResonanceText>
        </TouchableOpacity>
      )}
    </KeyboardAvoidingView>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <View style={[styles.content, { paddingTop: Platform.OS === 'ios' ? 60 : 40 }]}>
        {view === 'library' ? renderLibrary() : renderEditor()}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { flex: 1, paddingHorizontal: 20, zIndex: 10 },
  libraryHeader: { marginTop: 10 },
  docCard: { marginBottom: 10, padding: 16 },
  docMeta: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 8 },
  toolbar: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    paddingVertical: 12, borderBottomWidth: StyleSheet.hairlineWidth,
  },
  toolbarBtn: {
    paddingHorizontal: 12, paddingVertical: 6, borderRadius: Radii.lg, borderWidth: 1,
  },
  titleInput: {
    fontSize: 36, fontWeight: '300', marginTop: 24, marginBottom: 8,
  },
  contentInput: {
    fontSize: 17, lineHeight: 28, minHeight: 400, paddingBottom: 100,
  },
  editorFooter: {
    flexDirection: 'row', justifyContent: 'space-between',
    paddingVertical: 12, borderTopWidth: StyleSheet.hairlineWidth,
    paddingBottom: Platform.OS === 'ios' ? 34 : 12,
  },
  focusExit: {
    position: 'absolute', bottom: 40, alignSelf: 'center',
    paddingHorizontal: 16, paddingVertical: 8, borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.3)',
  },
});
