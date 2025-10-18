import { 
  BarChart3, 
  Users, 
  MessageSquare, 
  Settings, 
  HelpCircle, 
  Info,
  ChevronRight 
} from 'lucide-react';

export function FunctionCard() {
  const functions = [
    {
      icon: BarChart3,
      label: '训练数据',
      subtitle: '查看详细训练记录',
      color: 'bg-blue-100 text-blue-600'
    },
    {
      icon: Users,
      label: '我的社区',
      subtitle: '动态、关注、粉丝',
      color: 'bg-green-100 text-green-600'
    },
    {
      icon: MessageSquare,
      label: '消息中心',
      subtitle: '系统通知、私信',
      color: 'bg-purple-100 text-purple-600'
    },
    {
      icon: Settings,
      label: '设置',
      subtitle: '账号、隐私、通知',
      color: 'bg-gray-100 text-gray-600'
    },
    {
      icon: HelpCircle,
      label: '帮助中心',
      subtitle: '常见问题、意见反馈',
      color: 'bg-yellow-100 text-yellow-600'
    },
    {
      icon: Info,
      label: '关于我们',
      subtitle: '版本信息、用户协议',
      color: 'bg-red-100 text-red-600'
    }
  ];

  return (
    <div>
      <h3 className="text-lg text-gray-900 mb-4">功能菜单</h3>
      
      <div className="space-y-2">
        {functions.map((func, index) => (
          <button
            key={index}
            className="w-full bg-white rounded-xl p-4 border border-gray-200 flex items-center space-x-4 hover:bg-gray-50 transition-colors"
          >
            <div className={`w-10 h-10 ${func.color} rounded-full flex items-center justify-center`}>
              <func.icon className="w-5 h-5" />
            </div>
            <div className="flex-1 text-left">
              <p className="text-gray-900">{func.label}</p>
              <p className="text-sm text-gray-600">{func.subtitle}</p>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400" />
          </button>
        ))}
      </div>
    </div>
  );
}