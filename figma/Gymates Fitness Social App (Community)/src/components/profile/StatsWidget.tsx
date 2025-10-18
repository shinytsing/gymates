import { TrendingUp, Calendar, Trophy, Target } from 'lucide-react';

export function StatsWidget() {
  const stats = [
    {
      icon: Calendar,
      label: '训练天数',
      value: '127',
      subtitle: '连续打卡',
      color: 'bg-blue-500'
    },
    {
      icon: TrendingUp,
      label: '消耗卡路里',
      value: '12.5k',
      subtitle: '本月累计',
      color: 'bg-green-500'
    },
    {
      icon: Trophy,
      label: '获得徽章',
      value: '8',
      subtitle: '成就解锁',
      color: 'bg-yellow-500'
    },
    {
      icon: Target,
      label: '目标完成',
      value: '85%',
      subtitle: '本周进度',
      color: 'bg-purple-500'
    }
  ];

  return (
    <div className="mb-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg text-gray-900">运动数据</h3>
        <button className="text-primary text-sm">查看详情</button>
      </div>

      <div className="grid grid-cols-2 gap-4">
        {stats.map((stat, index) => (
          <div key={index} className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-center space-x-3 mb-3">
              <div className={`w-10 h-10 ${stat.color} rounded-full flex items-center justify-center`}>
                <stat.icon className="w-5 h-5 text-white" />
              </div>
              <div className="flex-1">
                <p className="text-2xl text-gray-900">{stat.value}</p>
                <p className="text-sm text-gray-600">{stat.label}</p>
              </div>
            </div>
            <p className="text-xs text-gray-500">{stat.subtitle}</p>
          </div>
        ))}
      </div>
    </div>
  );
}