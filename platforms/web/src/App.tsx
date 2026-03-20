import React, { useEffect, useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from './hooks/useTheme';
import CosmicBackground from './components/CosmicBackground';
import NavigationBar from './components/NavigationBar';
import OnboardingPage from './pages/OnboardingPage';
import DashboardPage from './pages/DashboardPage';
import NatalChartPage from './pages/NatalChartPage';
import DailyReflectionPage from './pages/DailyReflectionPage';
import MeditationPage from './pages/MeditationPage';
import ChapterLibraryPage from './pages/ChapterLibraryPage';

/**
 * App root component with routing and theme management.
 * Redirects to onboarding if the user hasn't completed it yet.
 */
const AppRoutes: React.FC = () => {
  const [onboardingComplete, setOnboardingComplete] = useState<boolean | null>(null);

  useEffect(() => {
    const complete = localStorage.getItem('lca-onboarding-complete') === 'true';
    setOnboardingComplete(complete);
  }, []);

  // Show nothing until we know onboarding status (prevents flash)
  if (onboardingComplete === null) {
    return null;
  }

  return (
    <BrowserRouter>
      <CosmicBackground />

      <Routes>
        {/* Onboarding */}
        <Route path="/onboarding" element={<OnboardingPage />} />

        {/* Main app routes (guarded) */}
        <Route
          path="/dashboard"
          element={
            onboardingComplete ? (
              <>
                <DashboardPage />
                <NavigationBar />
              </>
            ) : (
              <Navigate to="/onboarding" replace />
            )
          }
        />
        <Route
          path="/chart"
          element={
            onboardingComplete ? (
              <>
                <NatalChartPage />
                <NavigationBar />
              </>
            ) : (
              <Navigate to="/onboarding" replace />
            )
          }
        />
        <Route
          path="/reflection"
          element={
            onboardingComplete ? (
              <>
                <DailyReflectionPage />
                <NavigationBar />
              </>
            ) : (
              <Navigate to="/onboarding" replace />
            )
          }
        />
        <Route
          path="/meditation"
          element={
            onboardingComplete ? (
              <>
                <MeditationPage />
                <NavigationBar />
              </>
            ) : (
              <Navigate to="/onboarding" replace />
            )
          }
        />
        <Route
          path="/library"
          element={
            onboardingComplete ? (
              <>
                <ChapterLibraryPage />
                <NavigationBar />
              </>
            ) : (
              <Navigate to="/onboarding" replace />
            )
          }
        />

        {/* Default redirect */}
        <Route
          path="*"
          element={
            <Navigate to={onboardingComplete ? '/dashboard' : '/onboarding'} replace />
          }
        />
      </Routes>
    </BrowserRouter>
  );
};

const App: React.FC = () => {
  return (
    <ThemeProvider>
      <AppRoutes />
    </ThemeProvider>
  );
};

export default App;
