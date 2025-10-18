import { useState } from 'react';
import { Search, MoreHorizontal, Phone, Video, Plus } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { ChatDetail } from './messages/ChatDetail';
import { useTheme } from './context/ThemeContext';

export function MessagesPage() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [activeTab, setActiveTab] = useState('messages');
  const [selectedChat, setSelectedChat] = useState<any>(null);

  const tabs = [
    { id: 'messages', label: '消息' },
    { id: 'notifications', label: '通知' },
  ];

  const messages = [
    {
      id: 1,
      user: {
        name: '健身教练Mike',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        online: true
      },
      lastMessage: '今天的训练计划我已经发给你了，记得按时完成哦',
      time: '10:30',
      unread: 2,
      type: 'text'
    },
    {
      id: 2,
      user: {
        name: '跑步小组',
        avatar: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        online: false
      },
      lastMessage: '明天早上7点公园见，准时出发！',
      time: '昨天',
      unread: 0,
      type: 'group'
    },
    {
      id: 3,
      user: {
        name: '瑜伽小姐姐',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        online: true
      },
      lastMessage: '感谢你的瑜伽指导，进步很大！',
      time: '周一',
      unread: 0,
      type: 'text'
    }
  ];

  const notifications = [
    {
      id: 1,
      title: '训练提醒',
      content: '距离今日训练计划还有30分钟',
      time: '1小时前',
      type: 'reminder',
      unread: true
    },
    {
      id: 2,
      title: '挑战更新',
      content: '你参与的"30天俯卧撑挑战"有新进展',
      time: '3小时前',
      type: 'challenge',
      unread: true
    },
    {
      id: 3,
      title: '点赞通知',
      content: '用户"健身达人小王"点赞了你的动态',
      time: '1天前',
      type: 'like',
      unread: false
    }
  ];

  // Show chat detail if a chat is selected
  if (selectedChat) {
    return (
      <ChatDetail
        user={selectedChat.user}
        onBack={() => setSelectedChat(null)}
      />
    );
  }

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className={`bg-white px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
        <div className="flex items-center justify-between mb-4">
          <h1 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>消息</h1>
          <div className="flex items-center space-x-3">
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
              <Search className="w-5 h-5 text-gray-600" />
            </button>
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
              <MoreHorizontal className="w-5 h-5 text-gray-600" />
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex space-x-1 bg-gray-100 rounded-lg p-1">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex-1 py-2 px-4 rounded-md transition-colors ${
                activeTab === tab.id
                  ? 'bg-white text-primary shadow-sm'
                  : 'text-gray-600'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-6">
        {activeTab === 'messages' ? (
          <div className="space-y-1">
            {messages.map((message) => (
              <div 
                key={message.id} 
                className={`bg-white rounded-xl p-4 border border-gray-200 flex items-center space-x-3 cursor-pointer ${
                  isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50'
                } transition-colors`}
                onClick={() => setSelectedChat(message)}
              >
                <div className="relative">
                  <ImageWithFallback
                    src={message.user.avatar}
                    alt={message.user.name}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  {message.user.online && (
                    <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
                  )}
                </div>
                
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className="text-gray-900 truncate">{message.user.name}</h4>
                    <span className="text-xs text-gray-500">{message.time}</span>
                  </div>
                  <p className="text-sm text-gray-600 truncate">{message.lastMessage}</p>
                </div>

                <div className="flex flex-col items-end space-y-2">
                  {message.unread > 0 && (
                    <div className="w-5 h-5 bg-primary rounded-full flex items-center justify-center">
                      <span className="text-xs text-white">{message.unread}</span>
                    </div>
                  )}
                  <div className="flex space-x-1">
                    <button className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                      <Phone className="w-4 h-4 text-gray-600" />
                    </button>
                    <button className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                      <Video className="w-4 h-4 text-gray-600" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="space-y-3">
            {notifications.map((notification) => (
              <div key={notification.id} className={`bg-white rounded-xl p-4 border border-gray-200 ${notification.unread ? 'border-l-4 border-l-primary' : ''}`}>
                <div className="flex items-start justify-between mb-2">
                  <h4 className="text-gray-900">{notification.title}</h4>
                  <span className="text-xs text-gray-500">{notification.time}</span>
                </div>
                <p className="text-sm text-gray-600">{notification.content}</p>
                {notification.unread && (
                  <div className="mt-2">
                    <div className="w-2 h-2 bg-primary rounded-full"></div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button */}
      {activeTab === 'messages' && (
        <button
          className={`fixed bottom-24 right-4 w-14 h-14 bg-primary rounded-full flex items-center justify-center shadow-lg ${
            isIOS ? 'active:scale-95' : 'hover:scale-105'
          } transition-transform`}
        >
          <Plus className="w-6 h-6 text-white" />
        </button>
      )}

      {/* iOS Home Indicator */}
      {isIOS && (
        <div className="w-32 h-1 bg-gray-900 rounded-full mx-auto mt-6 opacity-60" />
      )}
    </div>
  );
}