import React, { createContext, useContext, useState, useCallback } from 'react';

export type ThemeType = 'ios' | 'android';
export type AuthState = 'login' | 'register' | 'onboarding' | 'authenticated';

interface User {
  id: string;
  name: string;
  phone: string;
  avatar?: string;
  height?: number;
  weight?: number;
  experience?: string;
  goal?: string;
  bmi?: number;
}

interface ThemeContextType {
  theme: ThemeType;
  setTheme: (theme: ThemeType) => void;
  authState: AuthState;
  setAuthState: (state: AuthState) => void;
  user: User | null;
  setUser: (user: User | null) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

// 自动检测设备类型
const detectDeviceType = (): ThemeType => {
  const userAgent = navigator.userAgent;
  if (/iPad|iPhone|iPod/.test(userAgent)) {
    return 'ios';
  }
  return 'android'; // 默认为Android Material 3
};

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<ThemeType>(() => {
    const detectedTheme = detectDeviceType();
    // Set initial theme on document
    if (typeof document !== 'undefined') {
      document.documentElement.setAttribute('data-theme', detectedTheme);
    }
    return detectedTheme;
  });
  const [authState, setAuthState] = useState<AuthState>('login');
  const [user, setUser] = useState<User | null>(null);

  const handleSetTheme = useCallback((newTheme: ThemeType) => {
    setTheme(newTheme);
    document.documentElement.setAttribute('data-theme', newTheme);
  }, []);

  const handleSetAuthState = useCallback((state: AuthState) => {
    setAuthState(state);
  }, []);

  const handleSetUser = useCallback((userData: User | null) => {
    setUser(userData);
  }, []);

  return (
    <ThemeContext.Provider value={{
      theme,
      setTheme: handleSetTheme,
      authState,
      setAuthState: handleSetAuthState,
      user,
      setUser: handleSetUser
    }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}