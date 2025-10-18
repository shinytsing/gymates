import { Calendar, Users, Trophy } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';

export function ChallengeCards() {
  const challenges = [
    {
      id: 1,
      title: '30天俯卧撑挑战',
      description: '每天增加2个俯卧撑，30天后见证蜕变',
      participants: 1234,
      daysLeft: 15,
      progress: 65,
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    },
    {
      id: 2,
      title: '跑步达人赛',
      description: '本月累计跑步100公里，成为跑步达人',
      participants: 856,
      daysLeft: 8,
      progress: 45,
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    }
  ];

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg text-gray-900">热门挑战</h3>
        <button className="text-primary text-sm">查看全部</button>
      </div>

      <div className="space-y-4">
        {challenges.map((challenge) => (
          <div key={challenge.id} className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div className="relative">
              <ImageWithFallback
                src={challenge.image}
                alt={challenge.title}
                className="w-full h-32 object-cover"
              />
              <div className="absolute top-3 right-3 bg-white/90 backdrop-blur-sm rounded-full px-2 py-1">
                <span className="text-xs text-gray-900">{challenge.daysLeft}天后结束</span>
              </div>
            </div>

            <div className="p-4">
              <h4 className="text-gray-900 mb-2">{challenge.title}</h4>
              <p className="text-sm text-gray-600 mb-3">{challenge.description}</p>

              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center space-x-4 text-sm text-gray-600">
                  <div className="flex items-center space-x-1">
                    <Users className="w-4 h-4" />
                    <span>{challenge.participants}人参与</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Calendar className="w-4 h-4" />
                    <span>{challenge.daysLeft}天剩余</span>
                  </div>
                </div>
              </div>

              <div className="mb-3">
                <div className="flex items-center justify-between mb-1">
                  <span className="text-sm text-gray-600">进度</span>
                  <span className="text-sm text-gray-900">{challenge.progress}%</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-primary h-2 rounded-full" 
                    style={{ width: `${challenge.progress}%` }}
                  ></div>
                </div>
              </div>

              <button className="w-full bg-primary text-white py-2 rounded-lg">
                参加挑战
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}