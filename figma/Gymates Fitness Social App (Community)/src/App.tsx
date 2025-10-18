import { useState, useCallback, useMemo, Suspense, useEffect } from 'react';
import { BottomNavigation } from './components/BottomNavigation';
import { LoadingSpinner } from './components/LoadingSpinner';
import { ErrorBoundary } from './components/ErrorBoundary';
import { TrainingPage } from './components/TrainingPage';
import { CommunityPage } from './components/CommunityPage';
import { MessagesPage } from './components/MessagesPage';
import { ProfilePage } from './components/ProfilePage';
import { MatesPage } from './components/MatesPage';
import { LoginPage } from './components/auth/LoginPage';
import { RegisterPage } from './components/auth/RegisterPage';
import { OnboardingPage } from './components/auth/OnboardingPage';
import { ThemeProvider, useTheme } from './components/context/ThemeContext';

function AppContent() {
  const { theme, authState } = useTheme();
  const [activeTab, setActiveTab] = useState('training');

  // Set theme on document
  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme]);

  const handleTabChange = useCallback((tab: string) => {
    setActiveTab(tab);
  }, []);

  // Always call useMemo to maintain hook order
  const currentPage = useMemo(() => {
    switch (activeTab) {
      case 'training':
        return <TrainingPage />;
      case 'community':
        return <CommunityPage />;
      case 'mates':
        return <MatesPage />;
      case 'messages':
        return <MessagesPage />;
      case 'profile':
        return <ProfilePage />;
      default:
        return <TrainingPage />;
    }
  }, [activeTab]);

  // Auth flow pages - moved after all hooks
  if (authState === 'login') {
    return <LoginPage />;
  }
  
  if (authState === 'register') {
    return <RegisterPage />;
  }
  
  if (authState === 'onboarding') {
    return <OnboardingPage />;
  }

  return (
    <ErrorBoundary>
      <div className="size-full bg-background relative">
        {/* Mobile container - responsive design */}
        <div className="max-w-md mx-auto bg-white min-h-screen relative">
          <Suspense fallback={<LoadingSpinner />}>
            {currentPage}
          </Suspense>
          
          <BottomNavigation
            activeTab={activeTab}
            onTabChange={handleTabChange}
          />
        </div>
      </div>
    </ErrorBoundary>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AppContent />
    </ThemeProvider>
  );
}