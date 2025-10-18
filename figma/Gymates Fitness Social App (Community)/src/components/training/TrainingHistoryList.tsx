import { Calendar, Clock, Flame } from 'lucide-react';

export function TrainingHistoryList() {
  const history = [
    {
      date: '2024-01-15',
      title: '胸部 + 三头肌训练',
      duration: 45,
      calories: 320,
      exercises: 6,
    },
    {
      date: '2024-01-13',
      title: '腿部力量训练',
      duration: 60,
      calories: 450,
      exercises: 8,
    },
    {
      date: '2024-01-11',
      title: 'HIIT有氧训练',
      duration: 25,
      calories: 280,
      exercises: 5,
    },
  ];

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg text-gray-900">训练历史</h3>
        <button className="text-primary text-sm">查看全部</button>
      </div>

      <div className="space-y-3">
        {history.map((item, index) => (
          <div key={index} className="bg-white rounded-xl p-4 border border-gray-200">
            <div className="flex items-center justify-between mb-3">
              <h4 className="text-gray-900">{item.title}</h4>
              <span className="text-xs text-gray-500">{item.date}</span>
            </div>
            
            <div className="flex items-center space-x-4 text-sm text-gray-600">
              <div className="flex items-center space-x-1">
                <Clock className="w-4 h-4" />
                <span>{item.duration}分钟</span>
              </div>
              <div className="flex items-center space-x-1">
                <Flame className="w-4 h-4" />
                <span>{item.calories}卡</span>
              </div>
              <div className="flex items-center space-x-1">
                <Calendar className="w-4 h-4" />
                <span>{item.exercises}个动作</span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}