import { Trophy, Star, Target, Zap, Award, Medal } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface AchievementGridProps {
  onViewDetails?: () => void;
}

export function AchievementGrid({ onViewDetails }: AchievementGridProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';

  const achievements = [
    {
      id: 1,
      title: '新手起步',
      description: '完成第一次训练',
      icon: Star,
      color: 'bg-yellow-100 text-yellow-600',
      unlocked: true,
      progress: 100
    },
    {
      id: 2,
      title: '连续7天',
      description: '连续训练7天',
      icon: Target,
      color: 'bg-green-100 text-green-600',
      unlocked: true,
      progress: 100
    },
    {
      id: 3,
      title: '力量之星',
      description: '力量训练30次',
      icon: Trophy,
      color: 'bg-blue-100 text-blue-600',
      unlocked: true,
      progress: 100
    },
    {
      id: 4,
      title: '燃脂达人',
      description: '累计燃烧5000卡路里',
      icon: Zap,
      color: 'bg-orange-100 text-orange-600',
      unlocked: false,
      progress: 75
    },
    {
      id: 5,
      title: '月度冠军',
      description: '单月训练25次',
      icon: Medal,
      color: 'bg-purple-100 text-purple-600',
      unlocked: false,
      progress: 45
    },
    {
      id: 6,
      title: '健身大师',
      description: '累计训练100天',
      icon: Award,
      color: 'bg-red-100 text-red-600',
      unlocked: false,
      progress: 20
    }
  ];

  return (
    <div className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-4 mb-6 border border-gray-200`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Trophy className="w-5 h-5 text-primary" />
          <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>成就徽章</h3>
        </div>
        <button 
          className="text-sm text-primary"
          onClick={onViewDetails}
        >
          查看全部
        </button>
      </div>

      {/* Achievement Grid */}
      <div className="grid grid-cols-3 gap-3">
        {achievements.map((achievement) => {
          const Icon = achievement.icon;
          return (
            <div
              key={achievement.id}
              className={`relative p-3 rounded-${isIOS ? '2xl' : 'xl'} border ${
                achievement.unlocked 
                  ? 'border-gray-200 bg-gray-50' 
                  : 'border-dashed border-gray-300 bg-gray-50/50'
              }`}
            >
              {/* Achievement Icon */}
              <div className={`w-8 h-8 rounded-full flex items-center justify-center mb-2 ${
                achievement.unlocked ? achievement.color : 'bg-gray-200 text-gray-400'
              }`}>
                <Icon className="w-4 h-4" />
              </div>

              {/* Achievement Info */}
              <h4 className={`text-xs ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-1 ${
                achievement.unlocked ? '' : 'opacity-50'
              }`}>
                {achievement.title}
              </h4>
              <p className={`text-xs text-gray-600 ${achievement.unlocked ? '' : 'opacity-50'}`}>
                {achievement.description}
              </p>

              {/* Progress bar for locked achievements */}
              {!achievement.unlocked && (
                <div className="mt-2">
                  <div className="w-full bg-gray-200 rounded-full h-1">
                    <div 
                      className="bg-primary h-1 rounded-full transition-all duration-300"
                      style={{ width: `${achievement.progress}%` }}
                    />
                  </div>
                  <span className="text-xs text-gray-500 mt-1">{achievement.progress}%</span>
                </div>
              )}

              {/* Unlocked badge */}
              {achievement.unlocked && (
                <div className="absolute -top-1 -right-1 w-4 h-4 bg-green-500 rounded-full flex items-center justify-center">
                  <svg className="w-2 h-2 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                  </svg>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Summary Stats */}
      <div className="mt-4 pt-4 border-t border-gray-100 flex items-center justify-center space-x-6">
        <div className="text-center">
          <p className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>3</p>
          <p className="text-xs text-gray-600">已解锁</p>
        </div>
        <div className="text-center">
          <p className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-primary`}>3</p>
          <p className="text-xs text-gray-600">进行中</p>
        </div>
      </div>
    </div>
  );
}