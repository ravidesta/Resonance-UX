import React, { useState, useRef } from 'react';
import { View, StyleSheet, PanResponder, Animated, Dimensions } from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Radii, Spacing } from '../theme/tokens';
import ResonanceText from './ResonanceText';

const SLIDER_WIDTH = Dimensions.get('window').width - 80;

export default function DimensionSlider({
  dimension,
  value = 5,
  onChange,
  color,
}) {
  const { colors } = useTheme();
  const [currentValue, setCurrentValue] = useState(value);
  const animWidth = useRef(new Animated.Value((value / 10) * SLIDER_WIDTH)).current;

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: (evt) => {
        const x = evt.nativeEvent.locationX;
        updateValue(x);
      },
      onPanResponderMove: (evt) => {
        const x = evt.nativeEvent.locationX;
        updateValue(x);
      },
    })
  ).current;

  const updateValue = (x) => {
    const clamped = Math.max(0, Math.min(SLIDER_WIDTH, x));
    const score = Math.round((clamped / SLIDER_WIDTH) * 10);
    setCurrentValue(score);
    Animated.spring(animWidth, {
      toValue: (score / 10) * SLIDER_WIDTH,
      damping: 20,
      stiffness: 200,
      useNativeDriver: false,
    }).start();
    if (onChange) onChange(score);
  };

  const seasonLabels = {
    1: 'Deep Winter',
    2: 'Deep Winter',
    3: 'Early Spring',
    4: 'Early Spring',
    5: 'Full Spring',
    6: 'Full Spring',
    7: 'Summer',
    8: 'Summer',
    9: 'Harvest',
    10: 'Harvest',
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <ResonanceText variant="bodySmall" style={{ fontSize: 22 }}>
          {dimension.emoji}
        </ResonanceText>
        <View style={{ flex: 1, marginLeft: 12 }}>
          <ResonanceText variant="label">{dimension.label}</ResonanceText>
          <ResonanceText variant="bodySmall" color="muted">
            {dimension.description}
          </ResonanceText>
        </View>
        <View style={[styles.scoreBadge, { backgroundColor: color + '20', borderColor: color }]}>
          <ResonanceText variant="label" style={{ color, fontSize: 18 }}>
            {currentValue}
          </ResonanceText>
        </View>
      </View>

      <View
        style={[styles.track, { backgroundColor: colors.green100 }]}
        {...panResponder.panHandlers}
      >
        <Animated.View
          style={[
            styles.fill,
            {
              backgroundColor: color,
              width: animWidth,
            },
          ]}
        />
        <Animated.View
          style={[
            styles.thumb,
            {
              backgroundColor: '#FFFFFF',
              borderColor: color,
              left: Animated.subtract(animWidth, 12),
            },
          ]}
        />
      </View>

      <ResonanceText variant="caption" color="light" style={{ marginTop: 4 }}>
        {seasonLabels[currentValue] || 'Seed'}
      </ResonanceText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 24,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  scoreBadge: {
    width: 44,
    height: 44,
    borderRadius: 22,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  track: {
    height: 8,
    borderRadius: 4,
    overflow: 'visible',
    position: 'relative',
  },
  fill: {
    height: 8,
    borderRadius: 4,
    position: 'absolute',
    left: 0,
    top: 0,
  },
  thumb: {
    position: 'absolute',
    top: -8,
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 3,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 4,
  },
});
