import { useState } from 'react';
import { ArrowLeft, Phone, Video, MoreHorizontal, Send, Mic, Camera, Image } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { useTheme } from '../context/ThemeContext';

interface ChatDetailProps {
  user: {
    name: string;
    avatar: string;
    online: boolean;
  };
  onBack: () => void;
}

export function ChatDetail({ user, onBack }: ChatDetailProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [message, setMessage] = useState('');

  const messages = [
    {
      id: 1,
      text: '嗨！我看到你也在朝阳区健身，有兴趣一起训练吗？',
      sender: 'other',
      time: '10:30',
      type: 'text'
    },
    {
      id: 2,
      text: '当然可以！你一般什么时间训练？',
      sender: 'me',
      time: '10:32',
      type: 'text'
    },
    {
      id: 3,
      text: '我通常晚上7-9点，你觉得怎么样？',
      sender: 'other',
      time: '10:35',
      type: 'text'
    },
    {
      id: 4,
      text: '完美！今天晚上7点健身房见？',
      sender: 'me',
      time: '10:36',
      type: 'text'
    },
    {
      id: 5,
      text: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzMwODB8MA&ixlib=rb-4.1.0&q=80&w=400',
      sender: 'other',
      time: '10:38',
      type: 'image'
    },
    {
      id: 6,
      text: '这是我们健身房的照片，环境不错吧！',
      sender: 'other',
      time: '10:38',
      type: 'text'
    }
  ];

  const handleSendMessage = () => {
    if (message.trim()) {
      console.log('Sending message:', message);
      setMessage('');
    }
  };

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} flex flex-col`}>
      {/* Header */}
      <div className="bg-white px-4 py-3 border-b border-gray-200 flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <button
            onClick={onBack}
            className={`w-8 h-8 rounded-full flex items-center justify-center ${
              isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
            } transition-colors`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          
          <div className="flex items-center space-x-3">
            <div className="relative">
              <ImageWithFallback
                src={user.avatar}
                alt={user.name}
                className="w-10 h-10 rounded-full object-cover"
              />
              {user.online && (
                <div className="absolute -bottom-0.5 -right-0.5 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></div>
              )}
            </div>
            <div>
              <h3 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
                {user.name}
              </h3>
              <p className="text-xs text-gray-500">
                {user.online ? '在线' : '2分钟前在线'}
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center space-x-2">
          <button className={`w-9 h-9 rounded-full flex items-center justify-center ${
            isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
          } transition-colors`}>
            <Phone className="w-5 h-5 text-gray-600" />
          </button>
          <button className={`w-9 h-9 rounded-full flex items-center justify-center ${
            isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
          } transition-colors`}>
            <Video className="w-5 h-5 text-gray-600" />
          </button>
          <button className={`w-9 h-9 rounded-full flex items-center justify-center ${
            isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
          } transition-colors`}>
            <MoreHorizontal className="w-5 h-5 text-gray-600" />
          </button>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 px-4 py-4 space-y-4 overflow-y-auto">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex ${msg.sender === 'me' ? 'justify-end' : 'justify-start'}`}
          >
            <div className={`max-w-xs ${msg.sender === 'me' ? 'order-2' : 'order-1'}`}>
              {msg.type === 'text' ? (
                <div
                  className={`px-4 py-2 rounded-${isIOS ? '3xl' : '2xl'} ${
                    msg.sender === 'me'
                      ? 'bg-primary text-white'
                      : 'bg-white border border-gray-200 text-gray-900'
                  }`}
                >
                  <p className="text-sm">{msg.text}</p>
                </div>
              ) : (
                <div className={`rounded-${isIOS ? '3xl' : '2xl'} overflow-hidden bg-white border border-gray-200`}>
                  <ImageWithFallback
                    src={msg.text}
                    alt="Shared image"
                    className="w-full h-48 object-cover"
                  />
                </div>
              )}
              <p className={`text-xs text-gray-500 mt-1 ${
                msg.sender === 'me' ? 'text-right' : 'text-left'
              }`}>
                {msg.time}
              </p>
            </div>
          </div>
        ))}
      </div>

      {/* Input Bar */}
      <div className="bg-white border-t border-gray-200 px-4 py-3">
        <div className="flex items-center space-x-2">
          <button className={`w-8 h-8 rounded-full flex items-center justify-center ${
            isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
          } transition-colors`}>
            <Camera className="w-5 h-5 text-gray-600" />
          </button>
          
          <button className={`w-8 h-8 rounded-full flex items-center justify-center ${
            isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
          } transition-colors`}>
            <Image className="w-5 h-5 text-gray-600" />
          </button>

          <div className="flex-1 relative">
            <input
              type="text"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="输入消息..."
              className={`w-full px-4 py-2 bg-gray-100 rounded-${isIOS ? '3xl' : '2xl'} border-0 focus:outline-none focus:ring-2 focus:ring-primary/20`}
              onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
            />
          </div>

          {message.trim() ? (
            <button
              onClick={handleSendMessage}
              className={`w-8 h-8 bg-primary rounded-full flex items-center justify-center ${
                isIOS ? 'active:scale-95' : 'hover:scale-105'
              } transition-transform`}
            >
              <Send className="w-4 h-4 text-white" />
            </button>
          ) : (
            <button className={`w-8 h-8 rounded-full flex items-center justify-center ${
              isIOS ? 'active:bg-gray-100' : 'hover:bg-gray-100'
            } transition-colors`}>
              <Mic className="w-5 h-5 text-gray-600" />
            </button>
          )}
        </div>
      </div>

      {/* iOS Home Indicator */}
      {isIOS && (
        <div className="w-32 h-1 bg-gray-900 rounded-full mx-auto mt-2 mb-2 opacity-60" />
      )}
    </div>
  );
}