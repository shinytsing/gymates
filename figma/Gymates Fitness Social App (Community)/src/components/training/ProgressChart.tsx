import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer, LineChart, Line } from 'recharts';
import { TrendingUp, BarChart3 } from 'lucide-react';
import { useState } from 'react';
import { useTheme } from '../context/ThemeContext';

export function ProgressChart() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [chartType, setChartType] = useState<'weekly' | 'monthly'>('weekly');

  const weeklyData = [
    { name: '周一', workouts: 2, calories: 450 },
    { name: '周二', workouts: 1, calories: 300 },
    { name: '周三', workouts: 0, calories: 0 },
    { name: '周四', workouts: 2, calories: 520 },
    { name: '周五', workouts: 1, calories: 380 },
    { name: '周六', workouts: 3, calories: 680 },
    { name: '周日', workouts: 1, calories: 350 }
  ];

  const monthlyData = [
    { name: '第1周', workouts: 8, calories: 2100 },
    { name: '第2周', workouts: 6, calories: 1800 },
    { name: '第3周', workouts: 9, calories: 2400 },
    { name: '第4周', workouts: 7, calories: 2000 }
  ];

  const currentData = chartType === 'weekly' ? weeklyData : monthlyData;

  return (
    <div className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-4 mb-6 border border-gray-200`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <BarChart3 className="w-5 h-5 text-primary" />
          <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>训练统计</h3>
        </div>
        
        {/* Chart Type Toggle */}
        <div className="flex bg-gray-100 rounded-lg p-1">
          <button
            onClick={() => setChartType('weekly')}
            className={`px-3 py-1 rounded-md text-xs transition-colors ${
              chartType === 'weekly'
                ? 'bg-white text-primary shadow-sm'
                : 'text-gray-600'
            }`}
          >
            本周
          </button>
          <button
            onClick={() => setChartType('monthly')}
            className={`px-3 py-1 rounded-md text-xs transition-colors ${
              chartType === 'monthly'
                ? 'bg-white text-primary shadow-sm'
                : 'text-gray-600'
            }`}
          >
            本月
          </button>
        </div>
      </div>

      {/* Chart */}
      <div style={{ width: '100%', height: '200px' }}>
        <ResponsiveContainer>
          <BarChart data={currentData}>
            <XAxis 
              dataKey="name" 
              axisLine={false}
              tickLine={false}
              tick={{ fontSize: 12, fill: '#6B7280' }}
            />
            <YAxis hide />
            <Bar 
              dataKey="workouts" 
              fill="#6366F1" 
              radius={[4, 4, 0, 0]}
              maxBarSize={40}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Stats Summary */}
      <div className="grid grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-100">
        <div className="text-center">
          <div className="flex items-center justify-center space-x-1 mb-1">
            <TrendingUp className="w-4 h-4 text-green-500" />
            <span className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
              {chartType === 'weekly' ? '9' : '30'}
            </span>
          </div>
          <p className="text-xs text-gray-600">
            {chartType === 'weekly' ? '本周训练' : '本月训练'}
          </p>
        </div>
        
        <div className="text-center">
          <div className="flex items-center justify-center space-x-1 mb-1">
            <div className="w-2 h-2 bg-orange-500 rounded-full"></div>
            <span className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
              {chartType === 'weekly' ? '2.7k' : '8.3k'}
            </span>
          </div>
          <p className="text-xs text-gray-600">消耗卡路里</p>
        </div>
        
        <div className="text-center">
          <div className="flex items-center justify-center space-x-1 mb-1">
            <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
            <span className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
              {chartType === 'weekly' ? '1.3' : '1.8'}
            </span>
          </div>
          <p className="text-xs text-gray-600">日均训练</p>
        </div>
      </div>

      {/* Progress towards goal */}
      <div className="mt-4 p-3 bg-primary/5 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <span className="text-sm text-gray-700">周目标进度</span>
          <span className="text-sm text-primary">9/12 次</span>
        </div>
        <div className="w-full bg-gray-200 rounded-full h-2">
          <div 
            className="bg-primary h-2 rounded-full transition-all duration-500"
            style={{ width: '75%' }}
          />
        </div>
        <p className="text-xs text-gray-600 mt-1">还需3次训练完成本周目标</p>
      </div>
    </div>
  );
}