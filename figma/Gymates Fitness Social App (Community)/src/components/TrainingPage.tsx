import { useState, useCallback } from 'react';
import { TodayPlanCard } from './training/TodayPlanCard';
import { AIPlanGenerator } from './training/AIPlanGenerator';
import { TrainingHistoryList } from './training/TrainingHistoryList';
import { CheckinCalendar } from './training/CheckinCalendar';
import { ProgressChart } from './training/ProgressChart';
import { Bell, Search } from 'lucide-react';
import { useTheme } from './context/ThemeContext';

export function TrainingPage() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [activeTab, setActiveTab] = useState('today');

  const handleTabChange = useCallback((tab: string) => {
    setActiveTab(tab);
  }, []);
  
  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className={`bg-white px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>训练</h1>
            <p className="text-gray-600">让我们开始今天的训练吧！</p>
          </div>
          <div className="flex items-center space-x-3">
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
              <Search className="w-5 h-5 text-gray-600" />
            </button>
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center relative ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
              <Bell className="w-5 h-5 text-gray-600" />
              <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></div>
            </button>
          </div>
        </div>

        {/* Progress Stats */}
        <div className="flex space-x-4 mb-4">
          <div className={`flex-1 ${isIOS ? 'bg-gray-50' : 'bg-gray-50'} rounded-${isIOS ? '2xl' : 'xl'} p-4`}>
            <p className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-1`}>12</p>
            <p className="text-sm text-gray-600">本周训练</p>
          </div>
          <div className={`flex-1 ${isIOS ? 'bg-gray-50' : 'bg-gray-50'} rounded-${isIOS ? '2xl' : 'xl'} p-4`}>
            <p className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-1`}>2.3k</p>
            <p className="text-sm text-gray-600">消耗卡路里</p>
          </div>
          <div className={`flex-1 ${isIOS ? 'bg-gray-50' : 'bg-gray-50'} rounded-${isIOS ? '2xl' : 'xl'} p-4`}>
            <p className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-1`}>85%</p>
            <p className="text-sm text-gray-600">目标完成</p>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex space-x-1 bg-gray-100 rounded-lg p-1">
          <button
            onClick={() => handleTabChange('today')}
            className={`flex-1 py-2 px-4 rounded-md transition-colors ${
              activeTab === 'today'
                ? 'bg-white text-primary shadow-sm'
                : 'text-gray-600'
            }`}
          >
            今日训练
          </button>
          <button
            onClick={() => handleTabChange('history')}
            className={`flex-1 py-2 px-4 rounded-md transition-colors ${
              activeTab === 'history'
                ? 'bg-white text-primary shadow-sm'
                : 'text-gray-600'
            }`}
          >
            历史
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-6">
        {activeTab === 'today' ? (
          <>
            <TodayPlanCard />
            <AIPlanGenerator />
          </>
        ) : (
          <>
            <ProgressChart />
            <CheckinCalendar />
            <TrainingHistoryList />
          </>
        )}
      </div>
    </div>
  );
}