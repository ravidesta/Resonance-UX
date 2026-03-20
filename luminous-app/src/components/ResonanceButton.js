import React, { useRef } from 'react';
import { TouchableOpacity, StyleSheet, Animated, Platform } from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Radii, Spacing, Typography } from '../theme/tokens';
import ResonanceText from './ResonanceText';

export default function ResonanceButton({
  title,
  onPress,
  variant = 'primary',   // primary | secondary | ghost | gold
  size = 'md',           // sm | md | lg
  icon,
  style,
  disabled = false,
}) {
  const { colors } = useTheme();
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.spring(scaleAnim, {
      toValue: 0.96,
      damping: 15,
      stiffness: 200,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      damping: 12,
      stiffness: 180,
      useNativeDriver: true,
    }).start();
  };

  const variantStyles = {
    primary: {
      bg: colors.green800,
      text: '#FAFAF8',
      border: 'transparent',
    },
    secondary: {
      bg: colors.bgGlassCard,
      text: colors.textMain,
      border: colors.borderLight,
    },
    ghost: {
      bg: 'transparent',
      text: colors.textMuted,
      border: 'transparent',
    },
    gold: {
      bg: colors.gold,
      text: '#FFFFFF',
      border: 'transparent',
    },
  };

  const sizeStyles = {
    sm: { paddingVertical: 8, paddingHorizontal: 16, fontSize: Typography.sizes.sm },
    md: { paddingVertical: 14, paddingHorizontal: 24, fontSize: Typography.sizes.base },
    lg: { paddingVertical: 18, paddingHorizontal: 32, fontSize: Typography.sizes.md },
  };

  const v = variantStyles[variant];
  const s = sizeStyles[size];

  return (
    <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
      <TouchableOpacity
        onPress={onPress}
        onPressIn={handlePressIn}
        onPressOut={handlePressOut}
        disabled={disabled}
        activeOpacity={0.85}
        style={[
          styles.button,
          {
            backgroundColor: v.bg,
            borderColor: v.border,
            paddingVertical: s.paddingVertical,
            paddingHorizontal: s.paddingHorizontal,
            opacity: disabled ? 0.5 : 1,
          },
          Platform.OS === 'web' && {
            cursor: disabled ? 'not-allowed' : 'pointer',
            transition: 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)',
          },
          style,
        ]}
      >
        {icon}
        <ResonanceText
          variant="label"
          style={{ color: v.text, fontSize: s.fontSize, marginLeft: icon ? 8 : 0 }}
        >
          {title}
        </ResonanceText>
      </TouchableOpacity>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: Radii.pill,
    borderWidth: 1,
  },
});
