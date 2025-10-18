import React from 'react';
import { Dumbbell, Users, Heart, MessageCircle, User } from 'lucide-react';
import { useTheme } from './context/ThemeContext';

interface BottomNavigationProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export const BottomNavigation = React.memo(function BottomNavigation({ activeTab, onTabChange }: BottomNavigationProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  
  const tabs = [
    { id: 'training', icon: Dumbbell, label: '训练' },
    { id: 'community', icon: Users, label: '社区' },
    { id: 'mates', icon: Heart, label: '搭子' },
    { id: 'messages', icon: MessageCircle, label: '消息' },
    { id: 'profile', icon: User, label: '我的' },
  ];

  return (
    <div className={`fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-sm border-t ${isIOS ? 'border-gray-200/50' : 'border-gray-200'} px-4 ${isIOS ? 'pb-6 pt-2' : 'py-2'} z-50`}>
      <div className="flex justify-between items-center max-w-md mx-auto">
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center px-3 py-2 transition-all ${
                isIOS ? 'active:scale-95' : 'hover:scale-105'
              } ${
                isActive 
                  ? 'text-primary' 
                  : 'text-gray-600'
              }`}
            >
              <div className={`relative ${isActive && isIOS ? 'bg-primary/10 rounded-lg p-1' : ''}`}>
                <tab.icon className={`w-6 h-6 ${
                  isActive 
                    ? 'text-primary' 
                    : 'text-gray-600'
                }`} />
                {/* Android bottom indicator */}
                {isActive && !isIOS && (
                  <div className="absolute -bottom-1 left-1/2 transform -translate-x-1/2 w-4 h-0.5 bg-primary rounded-full" />
                )}
              </div>
              <span className={`text-xs mt-1 ${isIOS ? 'font-medium' : ''} ${isActive ? 'text-primary' : 'text-gray-600'}`}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
      
      {/* iOS Home Indicator */}
      {isIOS && (
        <div className="w-32 h-1 bg-gray-900 rounded-full mx-auto mt-2 opacity-60" />
      )}
    </div>
  );
});