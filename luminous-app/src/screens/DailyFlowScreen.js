import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, ScrollView, TouchableOpacity,
  Animated, Dimensions, Platform,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Spacing, Radii, Shadows } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';

const { width } = Dimensions.get('window');

const phases = [
  { key: 'ascend', label: 'Ascend', time: '6am–12pm', emoji: '🌅', desc: 'Rising energy, fresh clarity' },
  { key: 'zenith', label: 'Zenith', time: '12pm–5pm', emoji: '☀️', desc: 'Peak vitality, deep work' },
  { key: 'descent', label: 'Descent', time: '5pm–9pm', emoji: '🌇', desc: 'Gentle winding, connection' },
  { key: 'rest', label: 'Deep Rest', time: '9pm–6am', emoji: '🌙', desc: 'Restoration, dreaming' },
];

const sampleTasks = [
  { id: 1, title: 'Morning lifewheel check-in', phase: 'ascend', energy: 'light', done: true, domain: 'Practice' },
  { id: 2, title: 'Deep work: Client session prep', phase: 'ascend', energy: 'deep', done: false, domain: 'Purpose' },
  { id: 3, title: 'Luminous community circle call', phase: 'zenith', energy: 'flow', done: false, domain: 'Community' },
  { id: 4, title: 'Creative writing — journal entry', phase: 'zenith', energy: 'flow', done: false, domain: 'Creative' },
  { id: 5, title: 'Walk in nature — embodiment practice', phase: 'descent', energy: 'restorative', done: false, domain: 'Physical' },
  { id: 6, title: 'Partner check-in with 5D quantum partner', phase: 'descent', energy: 'light', done: false, domain: 'Relations' },
  { id: 7, title: 'Evening gratitude practice', phase: 'rest', energy: 'restorative', done: false, domain: 'Spiritual' },
];

const energyColors = {
  deep: '#9B7FD4',
  flow: '#5B9BD5',
  light: '#6BB5A0',
  restorative: '#D4AF37',
};

export default function DailyFlowScreen({ navigation }) {
  const { colors, isDark, toggle } = useTheme();
  const [currentPhase, setCurrentPhase] = useState('ascend');
  const [tasks, setTasks] = useState(sampleTasks);
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const hour = new Date().getHours();
    if (hour >= 6 && hour < 12) setCurrentPhase('ascend');
    else if (hour >= 12 && hour < 17) setCurrentPhase('zenith');
    else if (hour >= 17 && hour < 21) setCurrentPhase('descent');
    else setCurrentPhase('rest');

    Animated.timing(fadeAnim, { toValue: 1, duration: 600, useNativeDriver: true }).start();
  }, []);

  const toggleTask = (id) => {
    setTasks(prev => prev.map(t => t.id === id ? { ...t, done: !t.done } : t));
  };

  const phaseTasks = (phaseKey) => tasks.filter(t => t.phase === phaseKey);
  const completedCount = tasks.filter(t => t.done).length;
  const totalTasks = tasks.length;

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={{ opacity: fadeAnim }}>
          {/* Header */}
          <View style={styles.header}>
            <View style={{ flex: 1 }}>
              <ResonanceText variant="h2">Daily Flow</ResonanceText>
              <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
                Energy-aligned rhythm for today
              </ResonanceText>
            </View>
            <TouchableOpacity onPress={toggle} style={[styles.modeToggle, { backgroundColor: colors.bgGlassCard, borderColor: colors.borderLight }]}>
              <ResonanceText style={{ fontSize: 18 }}>{isDark ? '☀️' : '🌙'}</ResonanceText>
            </TouchableOpacity>
          </View>

          {/* Progress Ring */}
          <GlassCard variant="raised" style={styles.progressCard}>
            <View style={styles.progressRing}>
              <View style={[styles.ringOuter, { borderColor: colors.borderLight }]}>
                <View style={[styles.ringInner, { borderColor: colors.gold }]}>
                  <ResonanceText variant="h3" color="gold">{completedCount}</ResonanceText>
                  <ResonanceText variant="caption" color="muted">of {totalTasks}</ResonanceText>
                </View>
              </View>
            </View>
            <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
              Seeds planted today
            </ResonanceText>
          </GlassCard>

          {/* Phase Selector */}
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.phaseScroll}>
            {phases.map((phase) => (
              <TouchableOpacity
                key={phase.key}
                onPress={() => setCurrentPhase(phase.key)}
                style={[
                  styles.phaseChip,
                  {
                    backgroundColor: currentPhase === phase.key ? colors.gold + '15' : colors.bgGlassCard,
                    borderColor: currentPhase === phase.key ? colors.gold : colors.borderLight,
                  },
                ]}
              >
                <ResonanceText style={{ fontSize: 16 }}>{phase.emoji}</ResonanceText>
                <ResonanceText
                  variant="label"
                  style={{ marginLeft: 6, color: currentPhase === phase.key ? colors.gold : colors.textMuted }}
                >
                  {phase.label}
                </ResonanceText>
              </TouchableOpacity>
            ))}
          </ScrollView>

          {/* Phase sections */}
          {phases.map((phase) => (
            <View key={phase.key} style={styles.phaseSection}>
              <View style={styles.phaseHeader}>
                <ResonanceText style={{ fontSize: 20 }}>{phase.emoji}</ResonanceText>
                <View style={{ marginLeft: 10, flex: 1 }}>
                  <ResonanceText variant="subtitle">{phase.label}</ResonanceText>
                  <ResonanceText variant="caption" color="light">{phase.time}</ResonanceText>
                </View>
                {phase.key === currentPhase && (
                  <View style={[styles.nowBadge, { backgroundColor: colors.gold + '20' }]}>
                    <ResonanceText variant="caption" color="gold">NOW</ResonanceText>
                  </View>
                )}
              </View>

              <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 4, marginBottom: 12, fontStyle: 'italic' }}>
                {phase.desc}
              </ResonanceText>

              {phaseTasks(phase.key).map((task) => (
                <TouchableOpacity
                  key={task.id}
                  onPress={() => toggleTask(task.id)}
                  activeOpacity={0.7}
                >
                  <GlassCard style={[styles.taskCard, task.done && { opacity: 0.6 }]}>
                    <View style={styles.taskRow}>
                      <View style={[
                        styles.checkbox,
                        {
                          borderColor: task.done ? colors.gold : colors.borderLight,
                          backgroundColor: task.done ? colors.gold : 'transparent',
                        },
                      ]}>
                        {task.done && <ResonanceText style={{ color: '#fff', fontSize: 12 }}>✓</ResonanceText>}
                      </View>
                      <View style={{ flex: 1, marginLeft: 12 }}>
                        <ResonanceText
                          variant="body"
                          style={task.done ? { textDecorationLine: 'line-through' } : {}}
                        >
                          {task.title}
                        </ResonanceText>
                        <View style={styles.taskMeta}>
                          <View style={[styles.energyDot, { backgroundColor: energyColors[task.energy] }]} />
                          <ResonanceText variant="caption" color="light" style={{ marginLeft: 4 }}>
                            {task.energy}
                          </ResonanceText>
                          <ResonanceText variant="caption" color="light" style={{ marginLeft: 12 }}>
                            {task.domain}
                          </ResonanceText>
                        </View>
                      </View>
                    </View>
                  </GlassCard>
                </TouchableOpacity>
              ))}

              {phaseTasks(phase.key).length === 0 && (
                <ResonanceText variant="bodySmall" color="light" style={{ fontStyle: 'italic', marginLeft: 4 }}>
                  Spacious — room to breathe
                </ResonanceText>
              )}
            </View>
          ))}

          {/* Add task */}
          <ResonanceButton
            title="+ Plant a Seed"
            variant="secondary"
            size="md"
            style={{ alignSelf: 'center', marginTop: 16 }}
          />

          <View style={{ height: 100 }} />
        </Animated.View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  scroll: { flex: 1, zIndex: 10 },
  scrollContent: { paddingHorizontal: 20, paddingTop: Platform.OS === 'ios' ? 60 : 40 },
  header: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 20 },
  modeToggle: { width: 40, height: 40, borderRadius: 20, alignItems: 'center', justifyContent: 'center', borderWidth: 1 },
  progressCard: { alignItems: 'center', padding: 24, marginBottom: 20 },
  progressRing: { alignItems: 'center' },
  ringOuter: { width: 88, height: 88, borderRadius: 44, borderWidth: 3, alignItems: 'center', justifyContent: 'center' },
  ringInner: { width: 72, height: 72, borderRadius: 36, borderWidth: 3, alignItems: 'center', justifyContent: 'center' },
  phaseScroll: { marginBottom: 20 },
  phaseChip: {
    flexDirection: 'row', alignItems: 'center',
    paddingHorizontal: 16, paddingVertical: 10, borderRadius: Radii.pill,
    borderWidth: 1, marginRight: 8,
  },
  phaseSection: { marginBottom: 24 },
  phaseHeader: { flexDirection: 'row', alignItems: 'center' },
  nowBadge: { paddingHorizontal: 8, paddingVertical: 3, borderRadius: 8 },
  taskCard: { marginBottom: 8, padding: 14 },
  taskRow: { flexDirection: 'row', alignItems: 'flex-start' },
  checkbox: {
    width: 22, height: 22, borderRadius: 11, borderWidth: 2,
    alignItems: 'center', justifyContent: 'center', marginTop: 2,
  },
  taskMeta: { flexDirection: 'row', alignItems: 'center', marginTop: 4 },
  energyDot: { width: 8, height: 8, borderRadius: 4 },
});
