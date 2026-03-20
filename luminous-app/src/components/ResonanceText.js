import React from 'react';
import { Text, StyleSheet, Platform } from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Typography } from '../theme/tokens';

export default function ResonanceText({
  children,
  variant = 'body',
  color,
  style,
  serif = false,
  ...props
}) {
  const { colors } = useTheme();

  const variants = {
    hero: {
      fontSize: Typography.sizes.hero,
      fontWeight: Typography.weights.light,
      lineHeight: Typography.sizes.hero * Typography.lineHeights.tight,
      letterSpacing: -1.5,
      fontFamily: Typography.serif,
    },
    h1: {
      fontSize: Typography.sizes['4xl'],
      fontWeight: Typography.weights.light,
      lineHeight: Typography.sizes['4xl'] * Typography.lineHeights.tight,
      letterSpacing: -1,
      fontFamily: Typography.serif,
    },
    h2: {
      fontSize: Typography.sizes['3xl'],
      fontWeight: Typography.weights.regular,
      lineHeight: Typography.sizes['3xl'] * Typography.lineHeights.tight,
      letterSpacing: -0.5,
      fontFamily: Typography.serif,
    },
    h3: {
      fontSize: Typography.sizes['2xl'],
      fontWeight: Typography.weights.regular,
      lineHeight: Typography.sizes['2xl'] * Typography.lineHeights.tight,
      fontFamily: Typography.serif,
    },
    h4: {
      fontSize: Typography.sizes.xl,
      fontWeight: Typography.weights.medium,
      lineHeight: Typography.sizes.xl * Typography.lineHeights.normal,
      fontFamily: serif ? Typography.serif : Typography.sans,
    },
    subtitle: {
      fontSize: Typography.sizes.md,
      fontWeight: Typography.weights.medium,
      lineHeight: Typography.sizes.md * Typography.lineHeights.normal,
      fontFamily: Typography.sans,
    },
    body: {
      fontSize: Typography.sizes.base,
      fontWeight: Typography.weights.regular,
      lineHeight: Typography.sizes.base * Typography.lineHeights.relaxed,
      fontFamily: Typography.sans,
    },
    bodySmall: {
      fontSize: Typography.sizes.sm,
      fontWeight: Typography.weights.regular,
      lineHeight: Typography.sizes.sm * Typography.lineHeights.relaxed,
      fontFamily: Typography.sans,
    },
    caption: {
      fontSize: Typography.sizes.xs,
      fontWeight: Typography.weights.medium,
      lineHeight: Typography.sizes.xs * Typography.lineHeights.normal,
      fontFamily: Typography.sans,
      textTransform: 'uppercase',
      letterSpacing: 1.2,
    },
    label: {
      fontSize: Typography.sizes.sm,
      fontWeight: Typography.weights.semibold,
      lineHeight: Typography.sizes.sm * Typography.lineHeights.normal,
      fontFamily: Typography.sans,
    },
    quote: {
      fontSize: Typography.sizes.xl,
      fontWeight: Typography.weights.light,
      lineHeight: Typography.sizes.xl * Typography.lineHeights.relaxed,
      fontFamily: Typography.serif,
      fontStyle: 'italic',
    },
  };

  const colorMap = {
    main: colors.textMain,
    muted: colors.textMuted,
    light: colors.textLight,
    gold: colors.gold,
    inverse: colors.bgBase,
  };

  return (
    <Text
      style={[
        variants[variant] || variants.body,
        { color: colorMap[color] || color || colors.textMain },
        style,
      ]}
      {...props}
    >
      {children}
    </Text>
  );
}
