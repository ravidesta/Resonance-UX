import React, { useState, useRef, useEffect } from 'react';
import {
  View, StyleSheet, ScrollView, Animated,
  Dimensions, Platform, TouchableOpacity,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Spacing, Radii, LifewheelDimensions } from '../theme/tokens';
import OrganicBackground from '../components/OrganicBackground';
import GlassCard from '../components/GlassCard';
import ResonanceText from '../components/ResonanceText';
import ResonanceButton from '../components/ResonanceButton';
import DimensionSlider from '../components/DimensionSlider';
import LifewheelVisualization from '../components/LifewheelVisualization';
import ShareButton from '../components/ShareButton';
import { shareContent } from '../utils/SocialShare';

const { width } = Dimensions.get('window');

// Luminous guided reflection questions per dimension
const reflectionQuestions = {
  physical: [
    'When do you feel most alive and at home in your body?',
    'What does your body do well — perhaps so well you\'ve stopped noticing?',
    'What physical pleasures genuinely nourish you?',
  ],
  emotional: [
    'When do you feel most emotionally alive and open?',
    'What emotions do you experience most easily and freely?',
    'Think of a recent emotional challenge you navigated. What inner resources did you draw on?',
  ],
  mental: [
    'When does your mind feel most clear, spacious, and alive?',
    'What are you genuinely curious about right now?',
    'When was the last time you had an "aha" moment?',
  ],
  spiritual: [
    'What connects you with a sense of meaning larger than your individual concerns?',
    'When was the last time you experienced genuine awe or wonder?',
    'What practices help you reconnect when you feel disconnected?',
  ],
  relationships: [
    'When do you feel most genuinely connected to another person?',
    'Who in your life truly sees you?',
    'What relational skill are you most proud of?',
  ],
  purpose: [
    'When do you feel most useful or meaningfully engaged?',
    'What problems in the world do you actually care about?',
    'What do people come to you for?',
  ],
  creative: [
    'When do you feel most creatively alive?',
    'What did you love to create as a child?',
    'What would you create if no one would judge it?',
  ],
  environment: [
    'What spaces in your environment feel most nourishing?',
    'Where is your relationship with money healthiest?',
    'What material resources genuinely enhance your quality of life?',
  ],
};

export default function AssessmentScreen({ navigation }) {
  const { colors } = useTheme();
  const [step, setStep] = useState('intro'); // intro | assess | reflect | results
  const [currentDimIndex, setCurrentDimIndex] = useState(0);
  const [scores, setScores] = useState({});
  const [reflections, setReflections] = useState({});
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(fadeAnim, { toValue: 1, duration: 600, useNativeDriver: true }).start();
  }, [step, currentDimIndex]);

  const handleScoreChange = (key, score) => {
    setScores(prev => ({ ...prev, [key]: score }));
  };

  const currentDim = LifewheelDimensions[currentDimIndex];

  const renderIntro = () => (
    <View style={styles.centerContent}>
      <ResonanceText style={{ fontSize: 64, textAlign: 'center' }}>🌀</ResonanceText>
      <ResonanceText variant="h1" style={{ textAlign: 'center', marginTop: 20 }}>
        Your Luminous{'\n'}Lifewheel
      </ResonanceText>
      <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 16, paddingHorizontal: 20 }}>
        You're about to explore eight dimensions of your life with honesty and appreciation.
        This isn't a report card — it's a love letter to the fullness of who you are.
      </ResonanceText>

      <GlassCard style={{ marginTop: 32, width: '100%' }}>
        <ResonanceText variant="quote" color="gold" style={{ textAlign: 'center' }}>
          "You are already luminous. Not luminous someday — luminous now."
        </ResonanceText>
      </GlassCard>

      <View style={styles.scaleGuide}>
        <ResonanceText variant="label" style={{ marginBottom: 12 }}>The Luminous Scale</ResonanceText>
        {[
          { range: '1-2', season: 'Deep Winter', desc: 'Dormant — needs warmth and attention' },
          { range: '3-4', season: 'Early Spring', desc: 'Shoots emerging, possibility stirring' },
          { range: '5-6', season: 'Full Spring', desc: 'Growing! Full of momentum' },
          { range: '7-8', season: 'Summer', desc: 'Flourishing with genuine abundance' },
          { range: '9-10', season: 'Harvest', desc: 'Radiating. A source of nourishment' },
        ].map((item) => (
          <View key={item.range} style={styles.scaleRow}>
            <View style={[styles.scaleBadge, { backgroundColor: colors.gold + '15' }]}>
              <ResonanceText variant="label" color="gold">{item.range}</ResonanceText>
            </View>
            <View style={{ marginLeft: 12, flex: 1 }}>
              <ResonanceText variant="label">{item.season}</ResonanceText>
              <ResonanceText variant="bodySmall" color="muted">{item.desc}</ResonanceText>
            </View>
          </View>
        ))}
      </View>

      <ResonanceButton
        title="Begin Assessment"
        variant="gold"
        size="lg"
        style={{ marginTop: 28, alignSelf: 'center' }}
        onPress={() => { setStep('assess'); fadeAnim.setValue(0); }}
      />
    </View>
  );

  const renderAssessment = () => (
    <Animated.View style={{ opacity: fadeAnim, flex: 1 }}>
      {/* Progress */}
      <View style={styles.progressBar}>
        {LifewheelDimensions.map((dim, i) => (
          <View
            key={dim.key}
            style={[
              styles.progressDot,
              {
                backgroundColor: i <= currentDimIndex ? colors[dim.colorKey] : colors.borderLight,
                width: i === currentDimIndex ? 24 : 8,
              },
            ]}
          />
        ))}
      </View>

      <ResonanceText variant="caption" color="light" style={{ textAlign: 'center', marginTop: 12 }}>
        {currentDimIndex + 1} of {LifewheelDimensions.length}
      </ResonanceText>

      <ScrollView showsVerticalScrollIndicator={false} style={{ flex: 1 }}>
        <View style={{ paddingVertical: 20 }}>
          <ResonanceText style={{ fontSize: 48, textAlign: 'center' }}>
            {currentDim.emoji}
          </ResonanceText>
          <ResonanceText variant="h2" style={{ textAlign: 'center', marginTop: 8 }}>
            {currentDim.label}
          </ResonanceText>
          <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 8, paddingHorizontal: 20 }}>
            {currentDim.description}
          </ResonanceText>

          <GlassCard style={{ marginTop: 24 }}>
            <ResonanceText variant="label" style={{ marginBottom: 16 }}>
              Where is this dimension on its journey from seed to full flower?
            </ResonanceText>
            <DimensionSlider
              dimension={currentDim}
              value={scores[currentDim.key] || 5}
              onChange={(val) => handleScoreChange(currentDim.key, val)}
              color={colors[currentDim.colorKey]}
            />
          </GlassCard>

          {/* Reflection Questions */}
          <GlassCard style={{ marginTop: 16 }}>
            <ResonanceText variant="label" style={{ marginBottom: 12 }}>
              🔮 Guided Reflection
            </ResonanceText>
            {(reflectionQuestions[currentDim.key] || []).map((q, i) => (
              <View key={i} style={styles.questionRow}>
                <ResonanceText variant="bodySmall" color="muted" style={{ fontStyle: 'italic' }}>
                  {q}
                </ResonanceText>
              </View>
            ))}
          </GlassCard>

          {/* NDHA Abundance Inquiry */}
          <GlassCard style={{ marginTop: 16 }}>
            <ResonanceText variant="label" style={{ marginBottom: 8 }}>
              🌟 Abundance Inquiry
            </ResonanceText>
            <ResonanceText variant="bodySmall" color="muted" style={{ fontStyle: 'italic' }}>
              What abundance already exists in this dimension that you haven't fully acknowledged?
            </ResonanceText>
            <ResonanceText variant="bodySmall" color="muted" style={{ fontStyle: 'italic', marginTop: 8 }}>
              What scarcity belief are you ready to release?
            </ResonanceText>
          </GlassCard>

          {/* Energy Check */}
          <View style={styles.energyCheck}>
            <ResonanceText variant="label" style={{ marginBottom: 12 }}>⚡ Energy Check</ResonanceText>
            <View style={styles.energyRow}>
              {[
                { emoji: '☀️', label: 'Energizing' },
                { emoji: '➖', label: 'Neutral' },
                { emoji: '🔋', label: 'Draining' },
              ].map((opt) => (
                <TouchableOpacity
                  key={opt.label}
                  style={[styles.energyOption, { borderColor: colors.borderLight }]}
                  activeOpacity={0.7}
                >
                  <ResonanceText style={{ fontSize: 20 }}>{opt.emoji}</ResonanceText>
                  <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 4 }}>
                    {opt.label}
                  </ResonanceText>
                </TouchableOpacity>
              ))}
            </View>
          </View>
        </View>
      </ScrollView>

      {/* Nav buttons */}
      <View style={styles.navButtons}>
        {currentDimIndex > 0 && (
          <ResonanceButton
            title="Previous"
            variant="ghost"
            onPress={() => { setCurrentDimIndex(i => i - 1); fadeAnim.setValue(0); }}
          />
        )}
        <View style={{ flex: 1 }} />
        <ResonanceButton
          title={currentDimIndex < 7 ? 'Next Dimension' : 'See Your Wheel'}
          variant="gold"
          onPress={() => {
            if (currentDimIndex < 7) {
              setCurrentDimIndex(i => i + 1);
              fadeAnim.setValue(0);
            } else {
              setStep('results');
              fadeAnim.setValue(0);
            }
          }}
        />
      </View>
    </Animated.View>
  );

  const renderResults = () => (
    <Animated.View style={{ opacity: fadeAnim }}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <ResonanceText variant="h1" style={{ textAlign: 'center', marginTop: 20 }}>
          Your Luminous{'\n'}Lifewheel
        </ResonanceText>
        <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 8 }}>
          A portrait of your life in this beautiful moment
        </ResonanceText>

        <View style={{ alignItems: 'center', marginTop: 24 }}>
          <LifewheelVisualization
            scores={scores}
            size={Math.min(width - 40, 360)}
          />
        </View>

        {/* Score summary */}
        <GlassCard style={{ marginTop: 24 }}>
          <ResonanceText variant="label" style={{ marginBottom: 16 }}>Dimension Scores</ResonanceText>
          {LifewheelDimensions.map((dim) => {
            const score = scores[dim.key] || 5;
            return (
              <View key={dim.key} style={styles.scoreRow}>
                <ResonanceText style={{ fontSize: 20 }}>{dim.emoji}</ResonanceText>
                <ResonanceText variant="body" style={{ flex: 1, marginLeft: 12 }}>{dim.label}</ResonanceText>
                <View style={[styles.scoreChip, { backgroundColor: colors[dim.colorKey] + '20' }]}>
                  <ResonanceText variant="label" style={{ color: colors[dim.colorKey] }}>
                    {score}
                  </ResonanceText>
                </View>
                <ShareButton
                  content={shareContent.dimensionScore(dim, score)}
                  variant="mini"
                  style={{ marginLeft: 8, padding: 4 }}
                />
              </View>
            );
          })}
        </GlassCard>

        {/* Celebration */}
        <GlassCard variant="raised" style={{ marginTop: 16 }}>
          <ResonanceText variant="h3" style={{ textAlign: 'center' }}>
            🎉 Celebrate Your Luminosity
          </ResonanceText>
          <ResonanceText variant="body" color="muted" style={{ textAlign: 'center', marginTop: 12 }}>
            You've just done something remarkable. You've looked at your entire life with honesty,
            appreciation, and curiosity. Whatever your scores say, this is the deeper truth:
            you've been doing remarkable things all along.
          </ResonanceText>
        </GlassCard>

        {/* Growth Invitations */}
        <GlassCard style={{ marginTop: 16 }}>
          <ResonanceText variant="h4" serif>🌱 Growth Invitations</ResonanceText>
          <ResonanceText variant="bodySmall" color="muted" style={{ marginTop: 8 }}>
            The areas calling for your loving attention aren't failures — they're invitations.
            The living force is gently, persistently calling you toward fuller expression.
          </ResonanceText>

          {LifewheelDimensions
            .filter(dim => (scores[dim.key] || 5) <= 5)
            .slice(0, 3)
            .map((dim) => (
              <View key={dim.key} style={[styles.growthRow, { borderLeftColor: colors[dim.colorKey] }]}>
                <ResonanceText variant="label">
                  {dim.emoji} {dim.label}
                </ResonanceText>
                <ResonanceText variant="bodySmall" color="muted">
                  Score: {scores[dim.key] || 5}/10 — What small, beautiful step might you take?
                </ResonanceText>
              </View>
            ))
          }
        </GlassCard>

        {/* Share Results */}
        <ShareButton
          content={shareContent.lifewheelResults(scores)}
          variant="card"
          style={{ marginTop: 16 }}
        />

        <View style={{ flexDirection: 'row', justifyContent: 'center', gap: 12, marginTop: 24 }}>
          <ResonanceButton
            title="Set Intentions"
            variant="gold"
            size="lg"
            onPress={() => navigation?.navigate?.('Intentions')}
          />
          <ResonanceButton
            title="Save & Continue"
            variant="secondary"
            size="lg"
            onPress={() => navigation?.navigate?.('Home')}
          />
        </View>

        <View style={{ height: 120 }} />
      </ScrollView>
    </Animated.View>
  );

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]}>
      <OrganicBackground />
      <View style={styles.content}>
        {step === 'intro' && (
          <ScrollView showsVerticalScrollIndicator={false}>
            {renderIntro()}
          </ScrollView>
        )}
        {step === 'assess' && renderAssessment()}
        {step === 'results' && renderResults()}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { flex: 1, paddingHorizontal: 20, paddingTop: Platform.OS === 'ios' ? 60 : 40, zIndex: 10 },
  centerContent: { alignItems: 'center', paddingTop: 40 },
  progressBar: { flexDirection: 'row', justifyContent: 'center', alignItems: 'center', gap: 6 },
  progressDot: { height: 8, borderRadius: 4, transition: 'all 0.3s' },
  questionRow: {
    paddingVertical: 10,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: 'rgba(0,0,0,0.05)',
  },
  energyCheck: { marginTop: 16 },
  energyRow: { flexDirection: 'row', gap: 12 },
  energyOption: {
    flex: 1, padding: 12, borderRadius: Radii.lg,
    borderWidth: 1, alignItems: 'center',
  },
  navButtons: {
    flexDirection: 'row', paddingVertical: 16, paddingBottom: Platform.OS === 'ios' ? 34 : 16,
  },
  scoreRow: {
    flexDirection: 'row', alignItems: 'center', paddingVertical: 10,
    borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: 'rgba(0,0,0,0.05)',
  },
  scoreChip: {
    paddingHorizontal: 12, paddingVertical: 4, borderRadius: 12,
  },
  scaleGuide: { marginTop: 24, width: '100%' },
  scaleRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 10 },
  scaleBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 8, minWidth: 42, alignItems: 'center' },
  growthRow: {
    marginTop: 12, paddingLeft: 16, borderLeftWidth: 3,
  },
});
