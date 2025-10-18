import { Hash, TrendingUp, Flame } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function TopicTags() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';

  const topics = [
    { 
      id: 1, 
      name: '减脂打卡', 
      count: '2.3k', 
      trending: true,
      color: 'bg-red-100 text-red-600 border-red-200'
    },
    { 
      id: 2, 
      name: '力量训练', 
      count: '1.8k', 
      trending: false,
      color: 'bg-blue-100 text-blue-600 border-blue-200'
    },
    { 
      id: 3, 
      name: '瑜伽冥想', 
      count: '1.2k', 
      trending: true,
      color: 'bg-purple-100 text-purple-600 border-purple-200'
    },
    { 
      id: 4, 
      name: '跑步', 
      count: '3.1k', 
      trending: false,
      color: 'bg-green-100 text-green-600 border-green-200'
    },
    { 
      id: 5, 
      name: '健身房', 
      count: '920', 
      trending: false,
      color: 'bg-orange-100 text-orange-600 border-orange-200'
    },
    { 
      id: 6, 
      name: '搭子征集', 
      count: '1.5k', 
      trending: true,
      color: 'bg-pink-100 text-pink-600 border-pink-200'
    }
  ];

  return (
    <div className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-4 mb-6 border border-gray-200`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Hash className="w-5 h-5 text-primary" />
          <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>热门话题</h3>
        </div>
        <button className="text-sm text-primary">查看全部</button>
      </div>

      {/* Topics Grid */}
      <div className="flex flex-wrap gap-2">
        {topics.map((topic) => (
          <button
            key={topic.id}
            className={`relative flex items-center space-x-2 px-3 py-2 rounded-${isIOS ? 'xl' : 'lg'} border transition-all ${
              isIOS ? 'active:scale-95' : 'hover:scale-105'
            } ${topic.color}`}
          >
            {/* Trending indicator */}
            {topic.trending && (
              <div className="absolute -top-1 -right-1">
                <Flame className="w-3 h-3 text-red-500" />
              </div>
            )}
            
            <Hash className="w-3 h-3" />
            <span className="text-sm">{topic.name}</span>
            <span className="text-xs opacity-70">{topic.count}</span>
          </button>
        ))}
      </div>

      {/* Trending Section */}
      <div className="mt-4 pt-4 border-t border-gray-100">
        <div className="flex items-center space-x-2 mb-3">
          <TrendingUp className="w-4 h-4 text-orange-500" />
          <span className="text-sm text-gray-700">正在热议</span>
        </div>
        
        <div className="space-y-2">
          <div className="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
            <span className="text-sm text-gray-900">今天你训练了吗？</span>
            <span className="text-xs text-gray-500">156讨论</span>
          </div>
          <div className="flex items-center justify-between p-2 bg-gray-50 rounded-lg">
            <span className="text-sm text-gray-900">分享你的健身餐</span>
            <span className="text-xs text-gray-500">89讨论</span>
          </div>
        </div>
      </div>
    </div>
  );
}