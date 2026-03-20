import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Platform, Dimensions } from 'react-native';
import { ThemeProvider, useTheme } from './theme/ThemeContext';
import { Radii, Shadows } from './theme/tokens';
import ResonanceText from './components/ResonanceText';

// Screens
import HomeScreen from './screens/HomeScreen';
import AssessmentScreen from './screens/AssessmentScreen';
import WriterScreen from './screens/WriterScreen';
import DailyFlowScreen from './screens/DailyFlowScreen';
import CommunityScreen from './screens/CommunityScreen';
import CoachDashboardScreen from './screens/CoachDashboardScreen';
import JournalScreen from './screens/JournalScreen';
import LibraryScreen from './screens/LibraryScreen';

const { width } = Dimensions.get('window');

const tabs = [
  { key: 'Home', emoji: '✨', label: 'Home' },
  { key: 'Assessment', emoji: '🌀', label: 'Lifewheel' },
  { key: 'DailyFlow', emoji: '🌊', label: 'Flow' },
  { key: 'Journal', emoji: '📝', label: 'Journal' },
  { key: 'Community', emoji: '💛', label: 'Community' },
];

function AppNavigator() {
  const { colors } = useTheme();
  const [activeScreen, setActiveScreen] = useState('Home');
  const [screenStack, setScreenStack] = useState(['Home']);

  const navigate = (screen) => {
    setActiveScreen(screen);
    setScreenStack(prev => [...prev, screen]);
  };

  const goBack = () => {
    if (screenStack.length > 1) {
      const newStack = screenStack.slice(0, -1);
      setScreenStack(newStack);
      setActiveScreen(newStack[newStack.length - 1]);
    }
  };

  const navigation = { navigate, goBack };

  const renderScreen = () => {
    switch (activeScreen) {
      case 'Home': return <HomeScreen navigation={navigation} />;
      case 'Assessment': return <AssessmentScreen navigation={navigation} />;
      case 'Writer': return <WriterScreen navigation={navigation} />;
      case 'DailyFlow': return <DailyFlowScreen navigation={navigation} />;
      case 'Community': return <CommunityScreen navigation={navigation} />;
      case 'CoachDashboard': return <CoachDashboardScreen navigation={navigation} />;
      case 'Journal': return <JournalScreen navigation={navigation} />;
      case 'Library': return <LibraryScreen navigation={navigation} />;
      default: return <HomeScreen navigation={navigation} />;
    }
  };

  return (
    <View style={styles.container}>
      {renderScreen()}

      {/* Bottom Tab Bar */}
      <View style={[
        styles.tabBar,
        {
          backgroundColor: colors.bgGlassRaised,
          borderTopColor: colors.borderLight,
        },
        Platform.OS === 'web' && {
          backdropFilter: 'blur(24px) saturate(130%)',
          WebkitBackdropFilter: 'blur(24px) saturate(130%)',
        },
      ]}>
        {tabs.map((tab) => {
          const isActive = activeScreen === tab.key;
          return (
            <TouchableOpacity
              key={tab.key}
              style={styles.tabItem}
              onPress={() => {
                setActiveScreen(tab.key);
                setScreenStack([tab.key]);
              }}
              activeOpacity={0.7}
            >
              <View style={[
                styles.tabIcon,
                isActive && { backgroundColor: colors.gold + '15' },
              ]}>
                <ResonanceText style={{ fontSize: 20 }}>{tab.emoji}</ResonanceText>
              </View>
              <ResonanceText
                variant="caption"
                style={{
                  marginTop: 2,
                  fontSize: 10,
                  color: isActive ? colors.gold : colors.textLight,
                  letterSpacing: 0.5,
                }}
              >
                {tab.label}
              </ResonanceText>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AppNavigator />
    </ThemeProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  tabBar: {
    flexDirection: 'row',
    borderTopWidth: StyleSheet.hairlineWidth,
    paddingTop: 8,
    paddingBottom: Platform.OS === 'ios' ? 28 : 12,
    paddingHorizontal: 8,
    ...Shadows.sm,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
  },
  tabIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
