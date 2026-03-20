import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, ScrollView, TouchableOpacity,
  Animated, Dimensions, Platform,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Spacing, Radii, LifewheelDimensions } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';
import LifewheelVisualization from '../components/LifewheelVisualization';

const { width } = Dimensions.get('window');
const isTablet = width > 768;

const clients = [
  { id: 1, name: 'Sarah M.', initials: 'SM', status: 'Active', nextSession: 'Tomorrow, 2pm', scores: { physical: 7, emotional: 5, mental: 8, spiritual: 6, relationships: 7, purpose: 9, creative: 3, environment: 6 } },
  { id: 2, name: 'David K.', initials: 'DK', status: 'Active', nextSession: 'Thursday, 10am', scores: { physical: 4, emotional: 7, mental: 6, spiritual: 8, relationships: 5, purpose: 6, creative: 7, environment: 4 } },
  { id: 3, name: 'Luna R.', initials: 'LR', status: 'Active', nextSession: 'Friday, 3pm', scores: { physical: 8, emotional: 8, mental: 7, spiritual: 9, relationships: 6, purpose: 7, creative: 8, environment: 7 } },
  { id: 4, name: 'James T.', initials: 'JT', status: 'Review', nextSession: 'Next week', scores: { physical: 5, emotional: 4, mental: 7, spiritual: 3, relationships: 6, purpose: 5, creative: 4, environment: 5 } },
];

const sessionTemplates = [
  { id: 1, title: 'Initial Assessment', duration: '90 min', emoji: '🌀', type: 'Template 1' },
  { id: 2, title: 'Deep Dive Session', duration: '60 min', emoji: '🔮', type: 'Template 2' },
  { id: 3, title: 'Review & Course-Correction', duration: '60 min', emoji: '🔧', type: 'Template 3' },
  { id: 4, title: 'Completion & Future-Visioning', duration: '90 min', emoji: '🌟', type: 'Template 4' },
];

export default function CoachDashboardScreen({ navigation }) {
  const { colors } = useTheme();
  const [selectedClient, setSelectedClient] = useState(null);
  const [tab, setTab] = useState('clients');
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(fadeAnim, { toValue: 1, duration: 600, useNativeDriver: true }).start();
  }, []);

  const renderClientList = () => (
    <View>
      <View style={styles.statsRow}>
        {[
          { label: 'Active Clients', value: '4', emoji: '👥' },
          { label: 'Sessions This Week', value: '7', emoji: '📅' },
          { label: 'Avg Growth', value: '+1.3', emoji: '📈' },
        ].map((stat) => (
          <GlassCard key={stat.label} style={styles.statCard}>
            <ResonanceText style={{ fontSize: 22 }}>{stat.emoji}</ResonanceText>
            <ResonanceText variant="h3" color="gold" style={{ marginTop: 4 }}>{stat.value}</ResonanceText>
            <ResonanceText variant="caption" color="muted">{stat.label}</ResonanceText>
          </GlassCard>
        ))}
      </View>

      <ResonanceText variant="caption" color="muted" style={{ marginTop: 20, marginBottom: 12 }}>
        YOUR CLIENTS
      </ResonanceText>

      {clients.map((client) => (
        <TouchableOpacity
          key={client.id}
          activeOpacity={0.7}
          onPress={() => setSelectedClient(client)}
        >
          <GlassCard style={styles.clientCard}>
            <View style={styles.clientRow}>
              <View style={[styles.avatar, { backgroundColor: colors.green200 }]}>
                <ResonanceText variant="label" style={{ color: colors.green800 }}>
                  {client.initials}
                </ResonanceText>
              </View>
              <View style={{ flex: 1, marginLeft: 14 }}>
                <ResonanceText variant="subtitle">{client.name}</ResonanceText>
                <ResonanceText variant="bodySmall" color="muted">
                  Next: {client.nextSession}
                </ResonanceText>
              </View>
              <View style={[
                styles.statusBadge,
                { backgroundColor: client.status === 'Active' ? colors.dimensionPhysical + '15' : colors.gold + '15' },
              ]}>
                <ResonanceText variant="caption" style={{
                  color: client.status === 'Active' ? colors.dimensionPhysical : colors.gold,
                }}>
                  {client.status}
                </ResonanceText>
              </View>
            </View>

            {/* Mini wheel preview */}
            <View style={{ alignItems: 'center', marginTop: 12 }}>
              <LifewheelVisualization
                scores={client.scores}
                size={120}
                showLabels={false}
                animated={false}
              />
            </View>
          </GlassCard>
        </TouchableOpacity>
      ))}
    </View>
  );

  const renderClientDetail = () => {
    if (!selectedClient) return null;
    return (
      <View>
        <TouchableOpacity onPress={() => setSelectedClient(null)}>
          <ResonanceText color="gold" style={{ marginBottom: 16 }}>← Back to clients</ResonanceText>
        </TouchableOpacity>

        <View style={styles.clientDetailHeader}>
          <View style={[styles.avatarLg, { backgroundColor: colors.green200 }]}>
            <ResonanceText variant="h3" style={{ color: colors.green800 }}>
              {selectedClient.initials}
            </ResonanceText>
          </View>
          <ResonanceText variant="h3" style={{ marginTop: 12 }}>{selectedClient.name}</ResonanceText>
          <ResonanceText variant="body" color="muted">Next: {selectedClient.nextSession}</ResonanceText>
        </View>

        <View style={{ alignItems: 'center', marginVertical: 20 }}>
          <LifewheelVisualization
            scores={selectedClient.scores}
            size={Math.min(width - 80, 300)}
          />
        </View>

        {/* Scores detail */}
        <GlassCard style={{ marginBottom: 16 }}>
          <ResonanceText variant="label" style={{ marginBottom: 12 }}>Current Assessment</ResonanceText>
          {LifewheelDimensions.map((dim) => {
            const score = selectedClient.scores[dim.key] || 0;
            return (
              <View key={dim.key} style={styles.dimRow}>
                <ResonanceText style={{ fontSize: 16 }}>{dim.emoji}</ResonanceText>
                <ResonanceText variant="bodySmall" style={{ flex: 1, marginLeft: 8 }}>{dim.label}</ResonanceText>
                <View style={[styles.barBg, { backgroundColor: colors.borderLight }]}>
                  <View style={[styles.barFill, {
                    backgroundColor: colors[dim.colorKey],
                    width: `${score * 10}%`,
                  }]} />
                </View>
                <ResonanceText variant="label" style={{ marginLeft: 8, width: 20, textAlign: 'right' }}>
                  {score}
                </ResonanceText>
              </View>
            );
          })}
        </GlassCard>

        {/* Coach Notes */}
        <GlassCard style={{ marginBottom: 16 }}>
          <ResonanceText variant="label">📝 Session Notes</ResonanceText>
          <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 8 }}>
            Creative Expression identified as primary growth edge.
            Client showing strong leverage from Purpose dimension.
            Recommend exploring creative micro-practices tied to existing work routines.
          </ResonanceText>
        </GlassCard>

        {/* Actions */}
        <View style={{ flexDirection: 'row', gap: 12 }}>
          <ResonanceButton title="Start Session" variant="gold" size="md" style={{ flex: 1 }} />
          <ResonanceButton title="Send Check-in" variant="secondary" size="md" style={{ flex: 1 }} />
        </View>
      </View>
    );
  };

  const renderTemplates = () => (
    <View>
      <GlassCard variant="raised" style={{ marginBottom: 16 }}>
        <ResonanceText variant="h4" serif style={{ textAlign: 'center' }}>
          Session Flow Templates
        </ResonanceText>
        <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
          Structured guides for each type of Luminous coaching session.
          Use as jazz charts — they give you the key and the changes, but the improvisation is yours.
        </ResonanceText>
      </GlassCard>

      {sessionTemplates.map((template) => (
        <TouchableOpacity key={template.id} activeOpacity={0.7}>
          <GlassCard style={styles.templateCard}>
            <View style={{ flexDirection: 'row', alignItems: 'center' }}>
              <ResonanceText style={{ fontSize: 28 }}>{template.emoji}</ResonanceText>
              <View style={{ flex: 1, marginLeft: 14 }}>
                <ResonanceText variant="subtitle">{template.title}</ResonanceText>
                <ResonanceText variant="bodySmall" color="muted">{template.duration} · {template.type}</ResonanceText>
              </View>
              <ResonanceText color="gold">→</ResonanceText>
            </View>
          </GlassCard>
        </TouchableOpacity>
      ))}

      {/* Facilitator Toolkit */}
      <GlassCard variant="raised" style={{ marginTop: 16, padding: 24 }}>
        <ResonanceText variant="h4" serif style={{ textAlign: 'center' }}>🌟 Facilitator Toolkit</ResonanceText>
        <ResonanceText variant="bodySmall" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
          The most important thing you bring to any Lifewheel session isn't your training. It's your presence.
        </ResonanceText>
        <View style={styles.toolkitGrid}>
          {[
            '50+ Coaching Questions', 'Celebration Practices',
            'NDHA Integration Guide', 'Ethics & Boundaries',
            'Cultural Sensitivity', 'Documentation Templates',
          ].map((item) => (
            <View key={item} style={[styles.toolkitItem, { borderColor: colors.borderLight }]}>
              <ResonanceText variant="bodySmall">{item}</ResonanceText>
            </View>
          ))}
        </View>
      </GlassCard>
    </View>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <ScrollView
        style={styles.scroll}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <Animated.View style={{ opacity: fadeAnim }}>
          <ResonanceText variant="h2">Coach Dashboard</ResonanceText>
          <ResonanceText variant="body" color="muted" style={{ marginTop: 4 }}>
            Sacred space for facilitating transformation
          </ResonanceText>

          {/* Tabs */}
          {!selectedClient && (
            <View style={styles.tabs}>
              {['clients', 'templates', 'resources'].map((t) => (
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
                    {t.charAt(0).toUpperCase() + t.slice(1)}
                  </ResonanceText>
                </TouchableOpacity>
              ))}
            </View>
          )}

          {selectedClient ? renderClientDetail() : (
            <>
              {tab === 'clients' && renderClientList()}
              {tab === 'templates' && renderTemplates()}
              {tab === 'resources' && (
                <GlassCard style={{ marginTop: 16 }}>
                  <ResonanceText variant="h4" serif>📚 Luminous Resources</ResonanceText>
                  <ResonanceText variant="body" color="muted" style={{ marginTop: 12 }}>
                    The complete Luminous Holonics Series, Developmental Canon,
                    Transformation Journals, NDHA modules, and practitioner certification materials.
                  </ResonanceText>
                  {[
                    'Luminous Holonics Vol I-VII',
                    'The Luminous Developmental Canon',
                    'Transformation Journal Series',
                    'NDHA Integration Modules',
                    'The Multipotentiate Guide',
                    'Quantum Ontology: A User\'s Manual',
                  ].map((item) => (
                    <TouchableOpacity key={item} style={[styles.resourceRow, { borderBottomColor: colors.borderLight }]}>
                      <ResonanceText variant="body">{item}</ResonanceText>
                      <ResonanceText color="gold">→</ResonanceText>
                    </TouchableOpacity>
                  ))}
                </GlassCard>
              )}
            </>
          )}

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
  statsRow: { flexDirection: 'row', gap: 10 },
  statCard: { flex: 1, alignItems: 'center', padding: 14 },
  clientCard: { marginBottom: 12, padding: 16 },
  clientRow: { flexDirection: 'row', alignItems: 'center' },
  avatar: { width: 44, height: 44, borderRadius: 22, alignItems: 'center', justifyContent: 'center' },
  avatarLg: { width: 72, height: 72, borderRadius: 36, alignItems: 'center', justifyContent: 'center' },
  statusBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 10 },
  clientDetailHeader: { alignItems: 'center', marginBottom: 8 },
  dimRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
  barBg: { flex: 1, height: 6, borderRadius: 3, marginLeft: 8 },
  barFill: { height: 6, borderRadius: 3 },
  templateCard: { marginBottom: 10, padding: 16 },
  toolkitGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginTop: 16 },
  toolkitItem: { paddingHorizontal: 12, paddingVertical: 8, borderRadius: 12, borderWidth: 1 },
  resourceRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 14, borderBottomWidth: StyleSheet.hairlineWidth },
});
