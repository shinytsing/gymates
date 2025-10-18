import { Trophy, Star, Target, Zap, Award, Medal, ArrowLeft } from 'lucide-react';
import { Button } from '../ui/button';
import { Badge } from '../ui/badge';
import { useTheme } from '../context/ThemeContext';

interface AchievementDetailPageProps {
  onBack: () => void;
}

export function AchievementDetailPage({ onBack }: AchievementDetailPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';

  const achievements = [
    {
      id: 1,
      title: '新手起步',
      description: '完成第一次训练',
      longDescription: '恭喜你完成人生中第一次正式的健身训练！这是一个重要的里程碑，标志着你开始了健康生活的新篇章。每一个健身大神都是从第一次训练开始的，坚持下去，你也能成为更好的自己！',
      icon: Star,
      color: 'bg-yellow-100 text-yellow-600',
      unlocked: true,
      progress: 100,
      unlockedDate: '2024-01-15',
      category: '入门',
      points: 10
    },
    {
      id: 2,
      title: '连续7天',
      description: '连续训练7天',
      longDescription: '坚持连续7天训练是一个了不起的成就！研究表明，需要21天才能养成一个习惯，而你已经完成了第一个重要阶段。保持这个节奏，健身将成为你生活中不可缺少的一部分。',
      icon: Target,
      color: 'bg-green-100 text-green-600',
      unlocked: true,
      progress: 100,
      unlockedDate: '2024-01-22',
      category: '坚持',
      points: 25
    },
    {
      id: 3,
      title: '力量之星',
      description: '力量训练30次',
      longDescription: '30次力量训练让你的肌肉力量有了显著提升！力量训练不仅能够塑造更好的身材，还能提高基础代谢率，让你在日常生活中更有活力。继续挑战更重的重量吧！',
      icon: Trophy,
      color: 'bg-blue-100 text-blue-600',
      unlocked: true,
      progress: 100,
      unlockedDate: '2024-02-10',
      category: '力量',
      points: 50
    },
    {
      id: 4,
      title: '燃脂达人',
      description: '累计燃烧5000卡路里',
      longDescription: '你已经燃烧了5000卡路里！这相当于减掉了大约0.65公斤的脂肪。每一滴汗水都是对更好自己的投资，继续保持这种燃脂的激情吧！',
      icon: Zap,
      color: 'bg-orange-100 text-orange-600',
      unlocked: false,
      progress: 75,
      category: '燃脂',
      points: 40,
      currentValue: 3750,
      targetValue: 5000
    },
    {
      id: 5,
      title: '月度冠军',
      description: '单月训练25次',
      longDescription: '单月完成25次训练将展现你对健身���真正承诺！这意味着你几乎每天都在为自己的健康努力，这种毅力和决心值得所有人的敬佩。',
      icon: Medal,
      color: 'bg-purple-100 text-purple-600',
      unlocked: false,
      progress: 45,
      category: '挑战',
      points: 75,
      currentValue: 11,
      targetValue: 25
    },
    {
      id: 6,
      title: '健身大师',
      description: '累计训练100天',
      longDescription: '100天的坚持训练是健身路上的重要里程碑！这表明你已经将健身深深融入了生活中，形成了良好的运动习惯。真正的健身大师不是一天练成的，而是日复一日的坚持成就的。',
      icon: Award,
      color: 'bg-red-100 text-red-600',
      unlocked: false,
      progress: 20,
      category: '大师',
      points: 100,
      currentValue: 20,
      targetValue: 100
    }
  ];

  const unlockedAchievements = achievements.filter(a => a.unlocked);
  const lockedAchievements = achievements.filter(a => !a.unlocked);
  const totalPoints = unlockedAchievements.reduce((sum, a) => sum + a.points, 0);

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className="bg-white px-4 py-6 border-b border-gray-200">
        <div className="flex items-center mb-4">
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={onBack}
            className="mr-3 p-2"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div>
            <h1 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>成就中心</h1>
            <p className="text-gray-600">查看你的健身成就和进度</p>
          </div>
        </div>

        {/* Achievement Summary */}
        <div className="grid grid-cols-3 gap-4">
          <div className={`bg-gradient-to-r from-yellow-400 to-yellow-600 rounded-${isIOS ? '2xl' : 'xl'} p-4 text-white`}>
            <p className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} mb-1`}>{unlockedAchievements.length}</p>
            <p className="text-sm opacity-90">已解锁</p>
          </div>
          <div className={`bg-gradient-to-r from-blue-400 to-blue-600 rounded-${isIOS ? '2xl' : 'xl'} p-4 text-white`}>
            <p className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} mb-1`}>{lockedAchievements.length}</p>
            <p className="text-sm opacity-90">进行中</p>
          </div>
          <div className={`bg-gradient-to-r from-purple-400 to-purple-600 rounded-${isIOS ? '2xl' : 'xl'} p-4 text-white`}>
            <p className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} mb-1`}>{totalPoints}</p>
            <p className="text-sm opacity-90">总积分</p>
          </div>
        </div>
      </div>

      {/* Achievement List */}
      <div className="px-4 py-6 space-y-6">
        {/* Unlocked Achievements */}
        <div>
          <h2 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-4`}>
            已解锁成就 ({unlockedAchievements.length})
          </h2>
          <div className="space-y-4">
            {unlockedAchievements.map((achievement) => {
              const Icon = achievement.icon;
              return (
                <div
                  key={achievement.id}
                  className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-6 border border-gray-200 relative overflow-hidden`}
                >
                  {/* Success Badge */}
                  <div className="absolute top-4 right-4">
                    <div className="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center">
                      <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    </div>
                  </div>

                  <div className="flex items-start space-x-4">
                    {/* Achievement Icon */}
                    <div className={`w-16 h-16 rounded-full flex items-center justify-center ${achievement.color}`}>
                      <Icon className="w-8 h-8" />
                    </div>

                    {/* Achievement Info */}
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <h3 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
                          {achievement.title}
                        </h3>
                        <Badge variant="secondary" className="text-xs">
                          {achievement.category}
                        </Badge>
                        <Badge variant="outline" className="text-xs">
                          +{achievement.points}分
                        </Badge>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">{achievement.description}</p>
                      <p className="text-xs text-gray-500 leading-relaxed">{achievement.longDescription}</p>
                      <div className="mt-3 flex items-center gap-2">
                        <span className="text-xs text-gray-500">解锁时间：</span>
                        <span className="text-xs text-gray-700">{achievement.unlockedDate}</span>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* In Progress Achievements */}
        <div>
          <h2 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-4`}>
            进行中 ({lockedAchievements.length})
          </h2>
          <div className="space-y-4">
            {lockedAchievements.map((achievement) => {
              const Icon = achievement.icon;
              return (
                <div
                  key={achievement.id}
                  className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-6 border border-dashed border-gray-300 relative`}
                >
                  <div className="flex items-start space-x-4">
                    {/* Achievement Icon */}
                    <div className="w-16 h-16 rounded-full flex items-center justify-center bg-gray-200 text-gray-400">
                      <Icon className="w-8 h-8" />
                    </div>

                    {/* Achievement Info */}
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <h3 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
                          {achievement.title}
                        </h3>
                        <Badge variant="secondary" className="text-xs">
                          {achievement.category}
                        </Badge>
                        <Badge variant="outline" className="text-xs">
                          +{achievement.points}分
                        </Badge>
                      </div>
                      <p className="text-sm text-gray-600 mb-3">{achievement.description}</p>
                      <p className="text-xs text-gray-500 leading-relaxed mb-4">{achievement.longDescription}</p>
                      
                      {/* Progress */}
                      <div className="space-y-2">
                        <div className="flex items-center justify-between">
                          <span className="text-xs text-gray-500">进度</span>
                          <span className="text-xs text-gray-700">
                            {achievement.currentValue}/{achievement.targetValue}
                          </span>
                        </div>
                        <div className="w-full bg-gray-200 rounded-full h-2">
                          <div 
                            className="bg-primary h-2 rounded-full transition-all duration-300"
                            style={{ width: `${achievement.progress}%` }}
                          />
                        </div>
                        <div className="text-right">
                          <span className="text-xs text-primary">{achievement.progress}%</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}