import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Easing, Dimensions, Platform } from 'react-native';
import { useTheme } from '../theme/ThemeContext';

const { width, height } = Dimensions.get('window');

function Blob({ color, size, top, left, delay = 0 }) {
  const scale = useRef(new Animated.Value(1)).current;
  const translateX = useRef(new Animated.Value(0)).current;
  const translateY = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const breathe = () => {
      Animated.loop(
        Animated.sequence([
          Animated.parallel([
            Animated.timing(scale, {
              toValue: 1.08,
              duration: 15000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
            Animated.timing(translateX, {
              toValue: 15,
              duration: 15000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
            Animated.timing(translateY, {
              toValue: 20,
              duration: 15000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
          ]),
          Animated.parallel([
            Animated.timing(scale, {
              toValue: 1,
              duration: 15000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
            Animated.timing(translateX, {
              toValue: 0,
              duration: 15000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
            Animated.timing(translateY, {
              toValue: 0,
              duration: 15000,
              easing: Easing.inOut(Easing.ease),
              useNativeDriver: true,
            }),
          ]),
        ])
      ).start();
    };

    const timer = setTimeout(breathe, delay);
    return () => clearTimeout(timer);
  }, []);

  return (
    <Animated.View
      style={[
        styles.blob,
        {
          width: size,
          height: size,
          top,
          left,
          backgroundColor: color,
          transform: [{ scale }, { translateX }, { translateY }],
        },
      ]}
    />
  );
}

export default function OrganicBackground() {
  const { colors, isDark } = useTheme();
  const blobOpacity = isDark ? 0.2 : 0.5;

  return (
    <View style={[styles.container, { backgroundColor: colors.bgBase }]} pointerEvents="none">
      <View style={{ opacity: blobOpacity }}>
        <Blob
          color={colors.green200}
          size={width * 0.8}
          top={-height * 0.1}
          left={-width * 0.3}
        />
        <Blob
          color={colors.goldGlow}
          size={width * 1.0}
          top={height * 0.5}
          left={width * 0.3}
          delay={5000}
        />
        <Blob
          color={colors.green100}
          size={width * 0.6}
          top={height * 0.2}
          left={width * 0.5}
          delay={8000}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFillObject,
    overflow: 'hidden',
  },
  blob: {
    position: 'absolute',
    borderRadius: 9999,
    ...Platform.select({
      web: { filter: 'blur(80px)' },
      default: { opacity: 0.6 },
    }),
  },
});
