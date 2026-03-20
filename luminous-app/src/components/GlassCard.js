import React from 'react';
import { View, StyleSheet, Platform } from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Radii, Shadows } from '../theme/tokens';

export default function GlassCard({ children, style, variant = 'base', onPress }) {
  const { colors } = useTheme();

  const bgMap = {
    base: colors.bgGlassCard,
    raised: colors.bgGlassRaised,
    solid: colors.bgSurface,
  };

  return (
    <View
      style={[
        styles.card,
        {
          backgroundColor: bgMap[variant] || bgMap.base,
          borderColor: colors.borderLight,
        },
        Shadows.md,
        style,
      ]}
    >
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: Radii['2xl'],
    borderWidth: 1,
    padding: 20,
    ...Platform.select({
      web: {
        backdropFilter: 'blur(16px) saturate(110%)',
        WebkitBackdropFilter: 'blur(16px) saturate(110%)',
        transition: 'all 0.35s cubic-bezier(0.34, 1.56, 0.64, 1)',
      },
    }),
  },
});
