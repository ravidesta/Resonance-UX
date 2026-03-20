import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, ScrollView, TouchableOpacity,
  Animated, Dimensions, Platform, Image,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Spacing, Radii } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';

const circles = [
  {
    id: 1, name: 'Morning Luminaries', members: 12, nextSession: 'Tomorrow, 7am',
    focus: 'Daily check-in & celebration', emoji: '☀️',
  },
  {
    id: 2, name: 'Creative Emergence', members: 8, nextSession: 'Thursday, 6pm',
    focus: 'Creative expression & play', emoji: '🎨',
  },
  {
    id: 3, name: 'Deep Roots', members: 15, nextSession: 'Saturday, 10am',
    focus: 'Spiritual connection & meaning', emoji: '🌳',
  },
  {
    id: 4, name: 'Coaches Circle', members: 6, nextSession: 'Friday, 2pm',
    focus: 'Practitioner support & development', emoji: '🌟',
  },
];

const upcomingEvents = [
  { id: 1, title: 'Quarterly Deep Dive Retreat', date: 'April 12-14', type: 'retreat', emoji: '🏔️' },
  { id: 2, title: 'Lifewheel Workshop: Physical Vitality', date: 'March 28', type: 'workshop', emoji: '🌿' },
  { id: 3, title: 'NDHA Integration Masterclass', date: 'April 2', type: 'class', emoji: '✨' },
  { id: 4, title: '5D Partner Matching Ceremony', date: 'April 5', type: 'ceremony', emoji: '🔮' },
];

const discussions = [
  { id: 1, author: 'Ava M.', topic: 'My creative dimension just jumped from 4 to 7!', replies: 23, emoji: '🎨' },
  { id: 2, author: 'James K.', topic: 'Finding abundance in the gap between scores', replies: 15, emoji: '🌟' },
  { id: 3, author: 'Luna S.', topic: 'How my 5D partner changed everything', replies: 31, emoji: '💛' },
  { id: 4, author: 'River T.', topic: 'Composting my old career — transition lifewheel', replies: 18, emoji: '🌱' },
];

export default function CommunityScreen({ navigation }) {
  const { colors } = useTheme();
  const [tab, setTab] = useState('circles');
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(fadeAnim, { toValue: 1, duration: 600, useNativeDriver: true }).start();
  }, []);

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={{ opacity: fadeAnim }}>
          <ResonanceText variant="h2">Luminous Community</ResonanceText>
          <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
            We rise together. Your luminosity is never yours alone.
          </ResonanceText>

          {/* Tabs */}
          <View style={styles.tabs}>
            {['circles', 'events', 'discuss'].map((t) => (
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
                  {t === 'circles' ? '🔮 Circles' : t === 'events' ? '📅 Events' : '💬 Discuss'}
                </ResonanceText>
              </TouchableOpacity>
            ))}
          </View>

          {/* Circles Tab */}
          {tab === 'circles' && (
            <View>
              <GlassCard variant="raised" style={{ marginBottom: 16, padding: 20 }}>
                <ResonanceText variant="h4" serif style={{ textAlign: 'center' }}>
                  Community Circles
                </ResonanceText>
                <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
                  Structured spaces for shared growth, accountability, and collective wisdom.
                  What emerges in community often exceeds what any individual could access alone.
                </ResonanceText>
              </GlassCard>

              {circles.map((circle) => (
                <TouchableOpacity key={circle.id} activeOpacity={0.7}>
                  <GlassCard style={styles.circleCard}>
                    <View style={styles.circleHeader}>
                      <View style={[styles.circleEmoji, { backgroundColor: colors.gold + '10' }]}>
                        <ResonanceText style={{ fontSize: 24 }}>{circle.emoji}</ResonanceText>
                      </View>
                      <View style={{ flex: 1, marginLeft: 14 }}>
                        <ResonanceText variant="subtitle">{circle.name}</ResonanceText>
                        <ResonanceText variant="bodySmall" color="muted">{circle.focus}</ResonanceText>
                      </View>
                    </View>
                    <View style={styles.circleMeta}>
                      <ResonanceText variant="caption" color="light">
                        👥 {circle.members} members
                      </ResonanceText>
                      <ResonanceText variant="caption" color="gold">
                        Next: {circle.nextSession}
                      </ResonanceText>
                    </View>
                    <ResonanceButton title="Join Circle" variant="secondary" size="sm" style={{ marginTop: 12 }} />
                  </GlassCard>
                </TouchableOpacity>
              ))}
            </View>
          )}

          {/* Events Tab */}
          {tab === 'events' && (
            <View>
              <GlassCard variant="raised" style={{ marginBottom: 16 }}>
                <ResonanceText variant="h4" serif style={{ textAlign: 'center' }}>
                  Luminous Experiences
                </ResonanceText>
                <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
                  Retreats, workshops, and intensives for accelerated transformation.
                </ResonanceText>
              </GlassCard>

              {upcomingEvents.map((event) => (
                <GlassCard key={event.id} style={styles.eventCard}>
                  <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                    <ResonanceText style={{ fontSize: 28 }}>{event.emoji}</ResonanceText>
                    <View style={{ flex: 1, marginLeft: 14 }}>
                      <ResonanceText variant="subtitle">{event.title}</ResonanceText>
                      <ResonanceText variant="bodySmall" color="muted">{event.date}</ResonanceText>
                      <View style={[styles.typeBadge, { backgroundColor: colors.gold + '10' }]}>
                        <ResonanceText variant="caption" color="gold">{event.type.toUpperCase()}</ResonanceText>
                      </View>
                    </View>
                    <ResonanceButton title="RSVP" variant="gold" size="sm" />
                  </View>
                </GlassCard>
              ))}
            </View>
          )}

          {/* Discussions Tab */}
          {tab === 'discuss' && (
            <View>
              <ResonanceButton
                title="Start a Discussion"
                variant="gold"
                style={{ marginBottom: 16, alignSelf: 'flex-start' }}
              />

              {discussions.map((d) => (
                <TouchableOpacity key={d.id} activeOpacity={0.7}>
                  <GlassCard style={styles.discussCard}>
                    <View style={{ flexDirection: 'row', alignItems: 'flex-start' }}>
                      <ResonanceText style={{ fontSize: 22 }}>{d.emoji}</ResonanceText>
                      <View style={{ flex: 1, marginLeft: 12 }}>
                        <ResonanceText variant="subtitle">{d.topic}</ResonanceText>
                        <View style={{ flexDirection: 'row', marginTop: 6 }}>
                          <ResonanceText variant="caption" color="light">{d.author}</ResonanceText>
                          <ResonanceText variant="caption" color="light" style={{ marginLeft: 12 }}>
                            💬 {d.replies} replies
                          </ResonanceText>
                        </View>
                      </View>
                    </View>
                  </GlassCard>
                </TouchableOpacity>
              ))}
            </View>
          )}

          {/* 5D Quantum Partner */}
          <GlassCard variant="raised" style={[styles.partnerCta, { borderColor: colors.gold + '40' }]}>
            <ResonanceText style={{ fontSize: 36, textAlign: 'center' }}>🔮</ResonanceText>
            <ResonanceText variant="h3" style={{ textAlign: 'center', marginTop: 8 }}>
              Find Your 5D Quantum Partner
            </ResonanceText>
            <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
              Together, you turn lead into gold. Together, you see in each other
              what you cannot yet see in yourselves.
            </ResonanceText>
            <ResonanceButton title="Get Matched" variant="gold" size="lg" style={{ marginTop: 16, alignSelf: 'center' }} />
          </GlassCard>

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
  tabs: { flexDirection: 'row', gap: 8, marginVertical: 20 },
  tab: { flex: 1, paddingVertical: 10, borderRadius: Radii.pill, borderWidth: 1, alignItems: 'center' },
  circleCard: { marginBottom: 12, padding: 16 },
  circleHeader: { flexDirection: 'row', alignItems: 'center' },
  circleEmoji: { width: 48, height: 48, borderRadius: 24, alignItems: 'center', justifyContent: 'center' },
  circleMeta: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 12 },
  eventCard: { marginBottom: 12, padding: 16 },
  typeBadge: { alignSelf: 'flex-start', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 6, marginTop: 4 },
  discussCard: { marginBottom: 10, padding: 14 },
  partnerCta: { marginTop: 24, padding: 28 },
});
