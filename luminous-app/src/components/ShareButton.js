/**
 * ShareButton — Beautiful share trigger with optional social menu
 *
 * A delightful share button that opens the native share sheet
 * or a glass morphism social menu on web.
 */

import React, { useState, useRef } from 'react';
import {
  View, StyleSheet, TouchableOpacity, Animated,
  Platform, Linking, Modal,
} from 'react-native';
import { useTheme } from '../theme/ThemeContext';
import { Radii, Shadows } from '../theme/tokens';
import ResonanceText from './ResonanceText';
import { shareLuminous, getSocialLinks } from '../utils/SocialShare';

const socialPlatforms = [
  { key: 'native', emoji: '📤', label: 'Share' },
  { key: 'twitter', emoji: '𝕏', label: 'X / Twitter' },
  { key: 'facebook', emoji: '📘', label: 'Facebook' },
  { key: 'instagram', emoji: '📸', label: 'Instagram' },
  { key: 'linkedin', emoji: '💼', label: 'LinkedIn' },
  { key: 'whatsapp', emoji: '💬', label: 'WhatsApp' },
  { key: 'telegram', emoji: '✈️', label: 'Telegram' },
  { key: 'threads', emoji: '🧵', label: 'Threads' },
  { key: 'pinterest', emoji: '📌', label: 'Pinterest' },
  { key: 'reddit', emoji: '🔴', label: 'Reddit' },
  { key: 'email', emoji: '📧', label: 'Email' },
];

export default function ShareButton({
  content,           // { title, message } from shareContent generators
  variant = 'icon',  // icon | pill | card | mini
  label = 'Share',
  style,
  onShared,
}) {
  const { colors } = useTheme();
  const [showMenu, setShowMenu] = useState(false);
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const menuAnim = useRef(new Animated.Value(0)).current;

  const handlePress = () => {
    // Spring animation on press
    Animated.sequence([
      Animated.spring(scaleAnim, { toValue: 0.9, damping: 15, stiffness: 300, useNativeDriver: true }),
      Animated.spring(scaleAnim, { toValue: 1, damping: 12, stiffness: 200, useNativeDriver: true }),
    ]).start();

    if (Platform.OS === 'web') {
      setShowMenu(true);
      Animated.spring(menuAnim, { toValue: 1, damping: 15, stiffness: 150, useNativeDriver: true }).start();
    } else {
      handleNativeShare();
    }
  };

  const handleNativeShare = async () => {
    const result = await shareLuminous(content);
    if (result.shared && onShared) {
      onShared(result);
    }
  };

  const handleSocialShare = async (platform) => {
    setShowMenu(false);
    menuAnim.setValue(0);

    if (platform === 'native') {
      handleNativeShare();
      return;
    }

    if (platform === 'instagram') {
      // Instagram doesn't support text sharing via URL — use native share
      handleNativeShare();
      return;
    }

    const links = getSocialLinks(content);
    const url = links[platform];
    if (url) {
      try {
        await Linking.openURL(url);
        if (onShared) onShared({ shared: true, platform });
      } catch (e) {
        console.warn('Could not open:', url);
      }
    }
  };

  const closeMenu = () => {
    Animated.timing(menuAnim, { toValue: 0, duration: 200, useNativeDriver: true }).start(() => {
      setShowMenu(false);
    });
  };

  // ─── Render variants ───

  if (variant === 'mini') {
    return (
      <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
        <TouchableOpacity onPress={handlePress} activeOpacity={0.7} style={style}>
          <ResonanceText style={{ fontSize: 16 }}>↗</ResonanceText>
        </TouchableOpacity>
      </Animated.View>
    );
  }

  if (variant === 'icon') {
    return (
      <>
        <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
          <TouchableOpacity
            onPress={handlePress}
            activeOpacity={0.7}
            style={[
              styles.iconBtn,
              { backgroundColor: colors.bgGlassCard, borderColor: colors.borderLight },
              style,
            ]}
          >
            <ResonanceText style={{ fontSize: 18 }}>↗</ResonanceText>
          </TouchableOpacity>
        </Animated.View>
        {showMenu && renderSocialMenu()}
      </>
    );
  }

  if (variant === 'pill') {
    return (
      <>
        <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
          <TouchableOpacity
            onPress={handlePress}
            activeOpacity={0.7}
            style={[
              styles.pillBtn,
              { backgroundColor: colors.gold + '15', borderColor: colors.gold + '40' },
              style,
            ]}
          >
            <ResonanceText style={{ fontSize: 14, marginRight: 6 }}>↗</ResonanceText>
            <ResonanceText variant="label" style={{ color: colors.gold, fontSize: 13 }}>
              {label}
            </ResonanceText>
          </TouchableOpacity>
        </Animated.View>
        {showMenu && renderSocialMenu()}
      </>
    );
  }

  // card variant — full width share CTA
  if (variant === 'card') {
    return (
      <>
        <Animated.View style={{ transform: [{ scale: scaleAnim }] }}>
          <TouchableOpacity
            onPress={handlePress}
            activeOpacity={0.8}
            style={[
              styles.cardBtn,
              {
                backgroundColor: colors.bgGlassCard,
                borderColor: colors.gold + '30',
              },
              Platform.OS === 'web' && {
                backdropFilter: 'blur(16px)',
                WebkitBackdropFilter: 'blur(16px)',
              },
              style,
            ]}
          >
            <ResonanceText style={{ fontSize: 24 }}>✨</ResonanceText>
            <View style={{ marginLeft: 14, flex: 1 }}>
              <ResonanceText variant="label">Share Your Luminosity</ResonanceText>
              <ResonanceText variant="caption" color="muted">
                Inspire others on their journey
              </ResonanceText>
            </View>
            <View style={[styles.shareArrow, { backgroundColor: colors.gold + '15' }]}>
              <ResonanceText style={{ color: colors.gold, fontSize: 16 }}>↗</ResonanceText>
            </View>
          </TouchableOpacity>
        </Animated.View>
        {showMenu && renderSocialMenu()}
      </>
    );
  }

  function renderSocialMenu() {
    return (
      <Modal transparent visible={showMenu} animationType="none" onRequestClose={closeMenu}>
        <TouchableOpacity
          style={styles.menuOverlay}
          activeOpacity={1}
          onPress={closeMenu}
        >
          <Animated.View
            style={[
              styles.menuContainer,
              {
                backgroundColor: colors.bgSurface,
                borderColor: colors.borderLight,
                opacity: menuAnim,
                transform: [{
                  translateY: menuAnim.interpolate({
                    inputRange: [0, 1],
                    outputRange: [40, 0],
                  }),
                }],
              },
              Platform.OS === 'web' && {
                backdropFilter: 'blur(24px)',
                WebkitBackdropFilter: 'blur(24px)',
              },
            ]}
          >
            <ResonanceText variant="label" style={{ marginBottom: 16, textAlign: 'center' }}>
              Share to...
            </ResonanceText>

            <View style={styles.socialGrid}>
              {socialPlatforms.map((platform) => (
                <TouchableOpacity
                  key={platform.key}
                  onPress={() => handleSocialShare(platform.key)}
                  style={[styles.socialBtn, { backgroundColor: colors.bgGlassCard }]}
                  activeOpacity={0.7}
                >
                  <ResonanceText style={{ fontSize: 22 }}>{platform.emoji}</ResonanceText>
                  <ResonanceText variant="caption" color="muted" style={{ marginTop: 4, fontSize: 10 }}>
                    {platform.label}
                  </ResonanceText>
                </TouchableOpacity>
              ))}
            </View>

            <TouchableOpacity
              onPress={closeMenu}
              style={[styles.cancelBtn, { borderTopColor: colors.borderLight }]}
            >
              <ResonanceText variant="label" color="muted">Cancel</ResonanceText>
            </TouchableOpacity>
          </Animated.View>
        </TouchableOpacity>
      </Modal>
    );
  }

  return null;
}

const styles = StyleSheet.create({
  iconBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    ...Shadows.sm,
  },
  pillBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: Radii.pill,
    borderWidth: 1,
  },
  cardBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderRadius: Radii['2xl'],
    borderWidth: 1,
    ...Shadows.md,
  },
  shareArrow: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
  menuOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
    justifyContent: 'flex-end',
  },
  menuContainer: {
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    borderWidth: 1,
    borderBottomWidth: 0,
    padding: 24,
    paddingBottom: Platform.OS === 'ios' ? 40 : 24,
    ...Shadows.lg,
  },
  socialGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    justifyContent: 'center',
  },
  socialBtn: {
    width: 72,
    height: 72,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cancelBtn: {
    marginTop: 20,
    paddingTop: 16,
    borderTopWidth: StyleSheet.hairlineWidth,
    alignItems: 'center',
  },
});
