import React, { createContext, useContext, useState, useMemo, useCallback } from 'react';
import {
  SafeAreaView,
  StatusBar,
  useColorScheme,
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Platform,
  Dimensions,
} from 'react-native';
import { NavigationContainer, DefaultTheme, DarkTheme } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

import HomeScreen from './screens/HomeScreen';
import JournalScreen from './screens/JournalScreen';
import CoachScreen from './screens/CoachScreen';
import ShareScreen from './screens/ShareScreen';

// ---------------------------------------------------------------------------
// Resonance colour tokens
// ---------------------------------------------------------------------------

export const Colors = {
  green900: '#0A1C14',
  green800: '#122E21',
  green700: '#1B402E',
  green600: '#2A5A42',
  green500: '#3D7A5C',
  green400: '#5A9E7A',
  green300: '#8EC4A4',
  green200: '#D1E0D7',
  green100: '#E8F0EB',
  green50:  '#F4F8F5',

  goldPrimary: '#C5A059',
  goldLight:   '#E6D0A1',
  goldDark:    '#9A7A3A',
  goldDeep:    '#7A5F28',
  goldMuted:   '#D4BC83',
  goldShimmer: '#F0E4C8',

  bgLight: '#FAFAF8',
  bgDark:  '#05100B',

  surfaceLight:     '#FFFFFF',
  surfaceDark:      '#0D1F16',
  surfaceVariantLt: '#F0F2EF',
  surfaceVariantDk: '#152A1F',

  error:   '#B85C5C',
  success: '#5CB87A',
  info:    '#5C8CB8',
  warning: '#B8A25C',

  textPrimaryLight:   '#1A1A18',
  textSecondaryLight: '#4A4A46',
  textPrimaryDark:    '#F0EDE6',
  textSecondaryDark:  '#B0ADA6',
} as const;

// ---------------------------------------------------------------------------
// Theme context
// ---------------------------------------------------------------------------

export interface ResonanceTheme {
  dark: boolean;
  bg: string;
  surface: string;
  surfaceVariant: string;
  glassSurface: string;
  glassBorder: string;
  textPrimary: string;
  textSecondary: string;
  gold: typeof Colors.goldPrimary;
  goldLight: typeof Colors.goldLight;
  goldDark: typeof Colors.goldDark;
  green700: typeof Colors.green700;
  green800: typeof Colors.green800;
  green900: typeof Colors.green900;
  green200: typeof Colors.green200;
}

const lightTheme: ResonanceTheme = {
  dark: false,
  bg: Colors.bgLight,
  surface: Colors.surfaceLight,
  surfaceVariant: Colors.surfaceVariantLt,
  glassSurface: 'rgba(255,255,255,0.65)',
  glassBorder: 'rgba(255,255,255,0.40)',
  textPrimary: Colors.textPrimaryLight,
  textSecondary: Colors.textSecondaryLight,
  gold: Colors.goldPrimary,
  goldLight: Colors.goldLight,
  goldDark: Colors.goldDark,
  green700: Colors.green700,
  green800: Colors.green800,
  green900: Colors.green900,
  green200: Colors.green200,
};

const darkTheme: ResonanceTheme = {
  dark: true,
  bg: Colors.bgDark,
  surface: Colors.surfaceDark,
  surfaceVariant: Colors.surfaceVariantDk,
  glassSurface: 'rgba(255,255,255,0.06)',
  glassBorder: 'rgba(255,255,255,0.10)',
  textPrimary: Colors.textPrimaryDark,
  textSecondary: Colors.textSecondaryDark,
  gold: Colors.goldPrimary,
  goldLight: Colors.goldLight,
  goldDark: Colors.goldDark,
  green700: Colors.green700,
  green800: Colors.green800,
  green900: Colors.green900,
  green200: Colors.green200,
};

export const ThemeContext = createContext<{
  theme: ResonanceTheme;
  toggleTheme: () => void;
}>({
  theme: lightTheme,
  toggleTheme: () => {},
});

export const useTheme = () => useContext(ThemeContext);

// ---------------------------------------------------------------------------
// Tab navigator
// ---------------------------------------------------------------------------

const Tab = createBottomTabNavigator();

const TabIcon = ({ name, focused }: { name: string; focused: boolean }) => {
  const icons: Record<string, string> = {
    Home: focused ? '\u2302' : '\u2302',
    Journal: focused ? '\u270E' : '\u270E',
    Coach: focused ? '\u2709' : '\u2709',
    Share: focused ? '\u2B06' : '\u2B06',
  };
  return (
    <Text
      style={{
        fontSize: 20,
        color: focused ? Colors.goldPrimary : Colors.green200,
      }}
    >
      {icons[name] ?? '\u2022'}
    </Text>
  );
};

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------

const App: React.FC = () => {
  const systemScheme = useColorScheme();
  const [isDark, setIsDark] = useState(systemScheme === 'dark');

  const theme = useMemo(() => (isDark ? darkTheme : lightTheme), [isDark]);
  const toggleTheme = useCallback(() => setIsDark((d) => !d), []);

  const navTheme = useMemo(
    () => ({
      ...(isDark ? DarkTheme : DefaultTheme),
      colors: {
        ...(isDark ? DarkTheme : DefaultTheme).colors,
        background: theme.bg,
        card: isDark ? Colors.green900 : Colors.surfaceLight,
        text: theme.textPrimary,
        border: theme.glassBorder,
        primary: Colors.goldPrimary,
      },
    }),
    [isDark, theme],
  );

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      <StatusBar
        barStyle={isDark ? 'light-content' : 'dark-content'}
        backgroundColor={theme.bg}
      />
      <NavigationContainer theme={navTheme}>
        <Tab.Navigator
          screenOptions={({ route }) => ({
            headerShown: false,
            tabBarStyle: {
              backgroundColor: isDark
                ? 'rgba(10,28,20,0.85)'
                : 'rgba(255,255,255,0.85)',
              borderTopColor: theme.glassBorder,
              paddingTop: 4,
              height: Platform.OS === 'ios' ? 88 : 64,
            },
            tabBarActiveTintColor: Colors.goldPrimary,
            tabBarInactiveTintColor: isDark ? Colors.green200 : Colors.green700,
            tabBarLabelStyle: {
              fontFamily: Platform.OS === 'ios' ? 'System' : 'sans-serif',
              fontSize: 11,
            },
            tabBarIcon: ({ focused }) => (
              <TabIcon name={route.name} focused={focused} />
            ),
          })}
        >
          <Tab.Screen name="Home" component={HomeScreen} />
          <Tab.Screen name="Journal" component={JournalScreen} />
          <Tab.Screen name="Coach" component={CoachScreen} />
          <Tab.Screen name="Share" component={ShareScreen} />
        </Tab.Navigator>
      </NavigationContainer>
    </ThemeContext.Provider>
  );
};

export default App;
