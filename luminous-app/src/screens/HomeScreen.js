import React, { useState, useEffect, useRef } from 'react';
import {
  View, StyleSheet, ScrollView, TouchableOpacity,
  Animated, Dimensions, Platform,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Spacing, Radii, Shadows, LifewheelDimensions } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';
import LifewheelVisualization from '../components/LifewheelVisualization';

const { width } = Dimensions.get('window');
const isTablet = width > 768;

export default function HomeScreen({ navigation }) {
  const { colors, isDark, toggle } = useTheme();
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;

  const [greeting, setGreeting] = useState('');
  const [timePhase, setTimePhase] = useState('');

  // Sample scores for demo wheel
  const [scores] = useState({
    physical: 7,
    emotional: 6,
    mental: 8,
    spiritual: 5,
    relationships: 7,
    purpose: 8,
    creative: 4,
    environment: 6,
  });

  useEffect(() => {
    const hour = new Date().getHours();
    if (hour < 6) { setGreeting('Deep rest'); setTimePhase('rest'); }
    else if (hour < 12) { setGreeting('Good morning'); setTimePhase('ascend'); }
    else if (hour < 17) { setGreeting('Good afternoon'); setTimePhase('zenith'); }
    else if (hour < 21) { setGreeting('Good evening'); setTimePhase('descent'); }
    else { setGreeting('Sweet evening'); setTimePhase('rest'); }

    Animated.parallel([
      Animated.timing(fadeAnim, { toValue: 1, duration: 800, useNativeDriver: true }),
      Animated.timing(slideAnim, { toValue: 0, duration: 800, useNativeDriver: true }),
    ]).start();
  }, []);

  const quickActions = [
    { label: 'Daily Check-In', emoji: '☀️', screen: 'DailyCheckin', color: colors.dimensionSpiritual },
    { label: 'Journal', emoji: '📝', screen: 'Journal', color: colors.dimensionCreative },
    { label: 'Assessment', emoji: '🌀', screen: 'Assessment', color: colors.gold },
    { label: 'Community', emoji: '💛', screen: 'Community', color: colors.dimensionRelations },
  ];

  const ecosystemItems = [
    { title: 'Sanctuary Writer', subtitle: 'Distraction-free luminous writing', emoji: '✍️', screen: 'Writer' },
    { title: 'Daily Flow', subtitle: 'Energy-aligned rhythm management', emoji: '🌊', screen: 'DailyFlow' },
    { title: '5D Partner', subtitle: 'Quantum partnership connection', emoji: '🔮', screen: 'Partner' },
    { title: 'Coaching Hub', subtitle: 'For luminous life coaches', emoji: '🌟', screen: 'CoachDashboard' },
    { title: 'Luminous Library', subtitle: 'Resources & guided practices', emoji: '📚', screen: 'Library' },
    { title: 'Retreats', subtitle: 'Immersive transformation', emoji: '🏔️', screen: 'Retreats' },
  ];

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />

      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={{ opacity: fadeAnim, transform: [{ translateY: slideAnim }] }}>
          {/* Header */}
          <View style={styles.header}>
            <View style={{ flex: 1 }}>
              <ResonanceText variant="caption" color="gold">
                {timePhase.toUpperCase()} PHASE
              </ResonanceText>
              <ResonanceText variant="h2" style={{ marginTop: 4 }}>
                {greeting}
              </ResonanceText>
              <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
                Your luminous journey continues
              </ResonanceText>
            </View>
            <TouchableOpacity
              onPress={toggle}
              style={[styles.themeToggle, { backgroundColor: colors.bgGlassCard, borderColor: colors.borderLight }]}
            >
              <ResonanceText style={{ fontSize: 20 }}>
                {isDark ? '☀️' : '🌙'}
              </ResonanceText>
            </TouchableOpacity>
          </View>

          {/* Lifewheel Card */}
          <GlassCard variant="raised" style={styles.wheelCard}>
            <ResonanceText variant="h4" serif style={{ textAlign: 'center', marginBottom: 4 }}>
              Your Luminous Lifewheel
            </ResonanceText>
            <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginBottom: 16 }}>
              Last assessed 3 days ago
            </ResonanceText>
            <View style={{ alignItems: 'center' }}>
              <LifewheelVisualization
                scores={scores}
                size={isTablet ? 360 : Math.min(width - 80, 300)}
              />
            </View>
            <View style={styles.wheelActions}>
              <ResonanceButton
                title="New Assessment"
                variant="gold"
                size="md"
                onPress={() => navigation?.navigate?.('Assessment')}
              />
              <ResonanceButton
                title="View History"
                variant="ghost"
                size="md"
                onPress={() => {}}
              />
            </View>
          </GlassCard>

          {/* Quick Actions */}
          <ResonanceText variant="caption" color="muted" style={styles.sectionLabel}>
            DAILY PRACTICES
          </ResonanceText>
          <View style={styles.quickGrid}>
            {quickActions.map((action) => (
              <TouchableOpacity
                key={action.label}
                style={[
                  styles.quickCard,
                  {
                    backgroundColor: colors.bgGlassCard,
                    borderColor: colors.borderLight,
                  },
                ]}
                onPress={() => navigation?.navigate?.(action.screen)}
                activeOpacity={0.7}
              >
                <View style={[styles.quickEmoji, { backgroundColor: action.color + '15' }]}>
                  <ResonanceText style={{ fontSize: 24 }}>{action.emoji}</ResonanceText>
                </View>
                <ResonanceText variant="label" style={{ marginTop: 8, textAlign: 'center' }}>
                  {action.label}
                </ResonanceText>
              </TouchableOpacity>
            ))}
          </View>

          {/* Luminous Quote */}
          <GlassCard style={styles.quoteCard}>
            <ResonanceText variant="quote" color="gold" style={{ textAlign: 'center' }}>
              "You are already luminous."
            </ResonanceText>
            <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
              The Luminous Lifewheel
            </ResonanceText>
          </GlassCard>

          {/* Ecosystem */}
          <ResonanceText variant="caption" color="muted" style={styles.sectionLabel}>
            LUMINOUS ECOSYSTEM
          </ResonanceText>
          <View style={isTablet ? styles.ecosystemGrid : null}>
            {ecosystemItems.map((item) => (
              <TouchableOpacity
                key={item.title}
                activeOpacity={0.7}
                onPress={() => navigation?.navigate?.(item.screen)}
              >
                <GlassCard style={[styles.ecoCard, isTablet && { width: (width - 80) / 2 }]}>
                  <View style={styles.ecoRow}>
                    <ResonanceText style={{ fontSize: 28 }}>{item.emoji}</ResonanceText>
                    <View style={{ marginLeft: 16, flex: 1 }}>
                      <ResonanceText variant="subtitle">{item.title}</ResonanceText>
                      <ResonanceText variant="bodySmall" color="muted">{item.subtitle}</ResonanceText>
                    </View>
                    <ResonanceText color="light" style={{ fontSize: 18 }}>→</ResonanceText>
                  </View>
                </GlassCard>
              </TouchableOpacity>
            ))}
          </View>

          {/* Coach CTA */}
          <GlassCard variant="raised" style={[styles.coachCta, { borderColor: colors.gold + '40' }]}>
            <ResonanceText style={{ fontSize: 32, textAlign: 'center' }}>🌟</ResonanceText>
            <ResonanceText variant="h3" style={{ textAlign: 'center', marginTop: 8 }}>
              For Luminous Coaches
            </ResonanceText>
            <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
              Access your client dashboard, session templates, and the complete facilitator toolkit.
            </ResonanceText>
            <ResonanceButton
              title="Coach Dashboard"
              variant="primary"
              size="lg"
              style={{ marginTop: 16, alignSelf: 'center' }}
              onPress={() => navigation?.navigate?.('CoachDashboard')}
            />
          </GlassCard>

          {/* Spacer */}
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
  header: { flexDirection: 'row', alignItems: 'flex-start', marginBottom: 24 },
  themeToggle: {
    width: 44, height: 44, borderRadius: 22,
    alignItems: 'center', justifyContent: 'center',
    borderWidth: 1,
  },
  wheelCard: { marginBottom: 24 },
  wheelActions: {
    flexDirection: 'row', justifyContent: 'center', gap: 12, marginTop: 20,
  },
  sectionLabel: { marginBottom: 12, marginLeft: 4 },
  quickGrid: {
    flexDirection: 'row', flexWrap: 'wrap', gap: 12, marginBottom: 24,
  },
  quickCard: {
    flex: 1, minWidth: (width - 56) / 2 - 6,
    padding: 16, borderRadius: Radii.xl, borderWidth: 1,
    alignItems: 'center',
    ...Shadows.sm,
  },
  quickEmoji: {
    width: 48, height: 48, borderRadius: 24,
    alignItems: 'center', justifyContent: 'center',
  },
  quoteCard: { marginBottom: 24, paddingVertical: 32 },
  ecosystemGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 12 },
  ecoCard: { marginBottom: 12, padding: 16 },
  ecoRow: { flexDirection: 'row', alignItems: 'center' },
  coachCta: { marginTop: 12, marginBottom: 12, padding: 28 },
});
