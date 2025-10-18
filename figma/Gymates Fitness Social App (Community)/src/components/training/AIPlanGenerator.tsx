import { Sparkles, ArrowRight } from 'lucide-react';

export function AIPlanGenerator() {
  const suggestions = [
    { title: '胸部训练', subtitle: '针对胸大肌发展', duration: '30分钟' },
    { title: '有氧燃脂', subtitle: 'HIIT高强度训练', duration: '20分钟' },
    { title: '腿部训练', subtitle: '下肢力量强化', duration: '40分钟' },
  ];

  return (
    <div className="mb-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Sparkles className="w-5 h-5 text-primary" />
          <h3 className="text-lg text-gray-900">AI训练推荐</h3>
        </div>
        <button className="text-primary text-sm">
          更多推荐
        </button>
      </div>

      <div className="space-y-3">
        {suggestions.map((item, index) => (
          <div key={index} className="bg-white rounded-xl p-4 border border-gray-200 flex items-center justify-between">
            <div className="flex-1">
              <h4 className="text-gray-900 mb-1">{item.title}</h4>
              <p className="text-sm text-gray-600 mb-1">{item.subtitle}</p>
              <span className="text-xs text-gray-500">{item.duration}</span>
            </div>
            <button className="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center">
              <ArrowRight className="w-4 h-4 text-primary" />
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}