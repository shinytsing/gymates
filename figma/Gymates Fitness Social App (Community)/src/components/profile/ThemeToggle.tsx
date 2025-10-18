import React from 'react';
import { motion } from 'motion/react';
import { Smartphone, Monitor } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const isIOS = theme === 'ios';

  return (
    <div className={`bg-white rounded-${isIOS ? '2xl' : 'xl'} p-4 border ${isIOS ? 'border-gray-200' : 'border-gray-200'} shadow-sm`}>
      <div className="flex items-center justify-between mb-4">
        <h3 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
          界面风格
        </h3>
        <div className="text-sm text-gray-500">
          {isIOS ? 'iOS' : 'Android'}
        </div>
      </div>
      
      <div className={`flex space-x-3 p-1 bg-gray-100 rounded-${isIOS ? 'xl' : 'lg'}`}>
        {/* iOS Option */}
        <motion.button
          whileTap={{ scale: 0.95 }}
          onClick={() => setTheme('ios')}
          className={`flex-1 flex items-center justify-center space-x-2 py-3 px-4 rounded-${isIOS ? 'lg' : 'md'} transition-all ${
            theme === 'ios'
              ? 'bg-white text-primary shadow-sm'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          <Smartphone className="w-4 h-4" />
          <span className={`text-sm ${theme === 'ios' ? 'font-semibold' : 'font-medium'}`}>
            iOS
          </span>
        </motion.button>

        {/* Android Option */}
        <motion.button
          whileTap={{ scale: 0.95 }}
          onClick={() => setTheme('android')}
          className={`flex-1 flex items-center justify-center space-x-2 py-3 px-4 rounded-${isIOS ? 'lg' : 'md'} transition-all ${
            theme === 'android'
              ? 'bg-white text-primary shadow-sm'
              : 'text-gray-600 hover:text-gray-900'
          }`}
        >
          <Monitor className="w-4 h-4" />
          <span className={`text-sm ${theme === 'android' ? 'font-semibold' : 'font-medium'}`}>
            Android
          </span>
        </motion.button>
      </div>

      <p className="text-xs text-gray-500 mt-3 text-center">
        选择您喜欢的界面设计风格
      </p>
    </div>
  );
}