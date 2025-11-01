import React from 'react';
import { Bell, Heart, MessageCircle, Users, Trophy, Calendar, UserPlus, Sparkles } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { useTheme } from '../context/ThemeContext';

export function NotificationList() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';

  const notifications = [
    {
      id: 1,
      type: 'match',
      title: '新匹配成功！',
      content: '你和「健身达人Mike」互相喜欢，快去打招呼吧！',
      time: '刚刚',
      unread: true,
      icon: '🎉',
      iconBg: 'bg-pink-100',
      iconColor: 'text-pink-600',
      user: {
        name: '健身达人Mike',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
      },
      action: '查看详情'
    },
    {
      id: 2,
      type: 'like',
      title: '有人点赞了你的动态',
      content: '「瑜伽小姐姐」点赞了你的动态「今天完成了10公里晨跑」',
      time: '30分钟前',
      unread: true,
      icon: null,
      iconBg: 'bg-red-100',
      iconColor: 'text-red-600',
      IconComponent: Heart,
      user: {
        name: '瑜伽小姐姐',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
      },
      action: '查看动态'
    },
    {
      id: 3,
      type: 'comment',
      title: '新评论',
      content: '「跑步达人Alex」评论了你的动态：「一起组队晨跑啊！」',
      time: '1小时前',
      unread: true,
      icon: null,
      iconBg: 'bg-blue-100',
      iconColor: 'text-blue-600',
      IconComponent: MessageCircle,
      user: {
        name: '跑步达人Alex',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
      },
      action: '回复'
    },
    {
      id: 4,
      type: 'follow',
      title: '新粉丝',
      content: '「健身教练Lisa」关注了你',
      time: '2小时前',
      unread: false,
      icon: null,
      iconBg: 'bg-purple-100',
      iconColor: 'text-purple-600',
      IconComponent: UserPlus,
      user: {
        name: '健身教练Lisa',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
      },
      action: '回关'
    },
    {
      id: 5,
      type: 'challenge',
      title: '挑战更新',
      content: '你参与的「30天俯卧撑挑战」已有156人完成今日任务',
      time: '3小时前',
      unread: false,
      icon: null,
      iconBg: 'bg-orange-100',
      iconColor: 'text-orange-600',
      IconComponent: Trophy
    },
    {
      id: 6,
      type: 'system',
      title: '训练提醒',
      content: '距离今日训练计划还有30分钟，记得准时开始哦！',
      time: '4小时前',
      unread: false,
      icon: null,
      iconBg: 'bg-green-100',
      iconColor: 'text-green-600',
      IconComponent: Bell
    },
    {
      id: 7,
      type: 'achievement',
      title: '成就解锁',
      content: '恭喜你解锁新成就「连续打卡7天」，获得50积分奖励！',
      time: '1天前',
      unread: false,
      icon: null,
      iconBg: 'bg-yellow-100',
      iconColor: 'text-yellow-600',
      IconComponent: Sparkles
    },
    {
      id: 8,
      type: 'group',
      title: '小组邀请',
      content: '「跑步小组」邀请你加入，已有28位成员',
      time: '1天前',
      unread: false,
      icon: null,
      iconBg: 'bg-indigo-100',
      iconColor: 'text-indigo-600',
      IconComponent: Users
    }
  ];

  return (
    <div className="space-y-2">
      {notifications.map((notification) => (
        <div
          key={notification.id}
          className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 border ${
            notification.unread ? 'border-primary/30 bg-primary/5' : 'border-gray-200'
          } transition-all ${isIOS ? 'active:bg-gray-50' : 'hover:shadow-md'}`}
        >
          <div className="flex items-start space-x-3">
            {/* Icon or Avatar */}
            <div className="flex-shrink-0">
              {notification.user ? (
                <div className="relative">
                  <ImageWithFallback
                    src={notification.user.avatar}
                    alt={notification.user.name}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  {notification.icon && (
                    <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-sm">
                      <span className="text-sm">{notification.icon}</span>
                    </div>
                  )}
                  {notification.IconComponent && (
                    <div className={`absolute -bottom-1 -right-1 w-6 h-6 ${notification.iconBg} rounded-full flex items-center justify-center shadow-sm`}>
                      <notification.IconComponent className={`w-3 h-3 ${notification.iconColor}`} />
                    </div>
                  )}
                </div>
              ) : (
                <div className={`w-12 h-12 ${notification.iconBg} ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center`}>
                  {notification.IconComponent && (
                    <notification.IconComponent className={`w-6 h-6 ${notification.iconColor}`} />
                  )}
                </div>
              )}
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0">
              <div className="flex items-start justify-between mb-1">
                <h4 className="text-gray-900">{notification.title}</h4>
                {notification.unread && (
                  <div className="w-2 h-2 bg-primary rounded-full flex-shrink-0 mt-1.5 ml-2"></div>
                )}
              </div>
              <p className="text-sm text-gray-600 mb-2 leading-relaxed">{notification.content}</p>
              <div className="flex items-center justify-between">
                <span className="text-xs text-gray-500">{notification.time}</span>
                {notification.action && (
                  <button className={`text-sm text-primary ${isIOS ? 'active:opacity-60' : 'hover:underline'} transition-opacity`}>
                    {notification.action}
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
