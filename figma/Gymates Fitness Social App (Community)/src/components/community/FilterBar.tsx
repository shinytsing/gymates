import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { SlidersHorizontal, MapPin, User, Target, X } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface FilterBarProps {
  onFilterChange?: (filters: FilterOptions) => void;
}

export interface FilterOptions {
  distance: number;
  gender: string;
  goal: string;
}

export function FilterBar({ onFilterChange }: FilterBarProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [showFilters, setShowFilters] = useState(false);
  const [filters, setFilters] = useState<FilterOptions>({
    distance: 5,
    gender: 'all',
    goal: 'all'
  });

  const genderOptions = [
    { value: 'all', label: '全部' },
    { value: 'male', label: '男性' },
    { value: 'female', label: '女性' },
    { value: 'other', label: '其他' }
  ];

  const goalOptions = [
    { value: 'all', label: '全部', emoji: '🎯' },
    { value: 'lose-weight', label: '减脂', emoji: '🔥' },
    { value: 'build-muscle', label: '增肌', emoji: '💪' },
    { value: 'improve-fitness', label: '塑形', emoji: '⚡' },
    { value: 'stay-healthy', label: '健康', emoji: '❤️' }
  ];

  const handleFilterChange = (key: keyof FilterOptions, value: any) => {
    const newFilters = { ...filters, [key]: value };
    setFilters(newFilters);
    onFilterChange?.(newFilters);
  };

  const handleReset = () => {
    const defaultFilters = {
      distance: 5,
      gender: 'all',
      goal: 'all'
    };
    setFilters(defaultFilters);
    onFilterChange?.(defaultFilters);
  };

  const activeFilterCount = 
    (filters.distance !== 5 ? 1 : 0) + 
    (filters.gender !== 'all' ? 1 : 0) + 
    (filters.goal !== 'all' ? 1 : 0);

  return (
    <>
      {/* Filter Button */}
      <button
        onClick={() => setShowFilters(true)}
        className={`flex items-center space-x-2 px-4 py-2 ${isIOS ? 'bg-gray-100 rounded-xl' : 'bg-white border border-gray-200 rounded-lg'} transition-colors ${isIOS ? 'active:bg-gray-200' : 'hover:bg-gray-50'}`}
      >
        <SlidersHorizontal className="w-4 h-4 text-gray-600" />
        <span className="text-sm text-gray-700">筛选</span>
        {activeFilterCount > 0 && (
          <span className="w-5 h-5 bg-primary text-white text-xs rounded-full flex items-center justify-center">
            {activeFilterCount}
          </span>
        )}
      </button>

      {/* Filter Panel */}
      <AnimatePresence>
        {showFilters && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowFilters(false)}
              className="fixed inset-0 bg-black/50 z-40"
            />

            {/* Filter Panel */}
            <motion.div
              initial={{ y: '100%' }}
              animate={{ y: 0 }}
              exit={{ y: '100%' }}
              transition={{ type: 'spring', damping: 30, stiffness: 300 }}
              className={`fixed bottom-0 left-0 right-0 bg-white ${isIOS ? 'rounded-t-3xl' : 'rounded-t-2xl'} shadow-2xl z-50 max-h-[80vh] overflow-auto pb-8`}
            >
              {/* Header */}
              <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
                <h3 className="text-lg text-gray-900">筛选条件</h3>
                <button
                  onClick={() => setShowFilters(false)}
                  className={`w-8 h-8 ${isIOS ? 'bg-gray-100 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}
                >
                  <X className="w-5 h-5 text-gray-600" />
                </button>
              </div>

              <div className="px-6 py-6 space-y-6">
                {/* Distance Filter */}
                <div>
                  <div className="flex items-center space-x-2 mb-3">
                    <MapPin className="w-5 h-5 text-primary" />
                    <label className="text-gray-900">距离范围</label>
                  </div>
                  <div className="space-y-3">
                    <input
                      type="range"
                      min="1"
                      max="20"
                      value={filters.distance}
                      onChange={(e) => handleFilterChange('distance', parseInt(e.target.value))}
                      className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
                      style={{
                        background: `linear-gradient(to right, #6366F1 0%, #6366F1 ${(filters.distance - 1) / 19 * 100}%, #E5E7EB ${(filters.distance - 1) / 19 * 100}%, #E5E7EB 100%)`
                      }}
                    />
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-gray-600">1 km</span>
                      <span className={`px-3 py-1 ${isIOS ? 'bg-primary/10 rounded-lg' : 'bg-primary/10 rounded'} text-primary`}>
                        {filters.distance} km
                      </span>
                      <span className="text-gray-600">20 km</span>
                    </div>
                  </div>
                </div>

                {/* Gender Filter */}
                <div>
                  <div className="flex items-center space-x-2 mb-3">
                    <User className="w-5 h-5 text-primary" />
                    <label className="text-gray-900">性别</label>
                  </div>
                  <div className="grid grid-cols-4 gap-3">
                    {genderOptions.map((option) => (
                      <button
                        key={option.value}
                        onClick={() => handleFilterChange('gender', option.value)}
                        className={`py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 transition-all ${
                          filters.gender === option.value
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
                        }`}
                      >
                        <span className="text-sm">{option.label}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Goal Filter */}
                <div>
                  <div className="flex items-center space-x-2 mb-3">
                    <Target className="w-5 h-5 text-primary" />
                    <label className="text-gray-900">健身目标</label>
                  </div>
                  <div className="flex overflow-x-auto space-x-3 pb-2 -mx-6 px-6 scrollbar-hide">
                    {goalOptions.map((option) => (
                      <button
                        key={option.value}
                        onClick={() => handleFilterChange('goal', option.value)}
                        className={`flex-shrink-0 px-4 py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 transition-all flex items-center space-x-2 ${
                          filters.goal === option.value
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
                        }`}
                      >
                        <span className="text-lg">{option.emoji}</span>
                        <span className="text-sm whitespace-nowrap">{option.label}</span>
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Actions */}
              <div className="px-6 pt-4 border-t border-gray-200 flex space-x-3">
                <button
                  onClick={handleReset}
                  className={`flex-1 py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 border-gray-300 text-gray-700 hover:bg-gray-50 transition-colors`}
                >
                  重置
                </button>
                <button
                  onClick={() => setShowFilters(false)}
                  className={`flex-1 py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-primary text-white hover:bg-primary/90 transition-colors`}
                >
                  应用筛选
                </button>
              </div>

              {/* iOS Home Indicator */}
              {isIOS && (
                <div className="w-32 h-1 bg-gray-900 rounded-full mx-auto mt-4 opacity-30" />
              )}
            </motion.div>
          </>
        )}
      </AnimatePresence>

      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
        .slider::-webkit-slider-thumb {
          appearance: none;
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: #6366F1;
          cursor: pointer;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .slider::-moz-range-thumb {
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: #6366F1;
          cursor: pointer;
          border: none;
          box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
      `}</style>
    </>
  );
}
