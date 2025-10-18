import React from 'react';
import { Heart, MessageCircle, Share, MoreHorizontal } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';

export const FeedList = React.memo(function FeedList() {
  const posts = [
    {
      id: 1,
      user: {
        name: '健身达人小王',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        time: '2小时前'
      },
      content: '今天完成了一个小时的力量训练，感觉状态非常好！坚持就是胜利 💪',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      likes: 128,
      comments: 24,
      tags: ['#力量训练', '#坚持', '#健身']
    },
    {
      id: 2,
      user: {
        name: '瑜伽小姐姐',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        time: '4小时前'
      },
      content: '早晨瑜伽课程结束，今天学会了一个新的体式，分享给大家～',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      likes: 89,
      comments: 16,
      tags: ['#瑜伽', '#晨练', '#新体式']
    }
  ];

  return (
    <div className="space-y-6">
      {posts.map((post) => (
        <div key={post.id} className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          {/* User info */}
          <div className="p-4 flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <ImageWithFallback
                src={post.user.avatar}
                alt={post.user.name}
                className="w-10 h-10 rounded-full object-cover"
              />
              <div>
                <p className="text-gray-900">{post.user.name}</p>
                <p className="text-sm text-gray-600">{post.user.time}</p>
              </div>
            </div>
            <button className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
              <MoreHorizontal className="w-4 h-4 text-gray-600" />
            </button>
          </div>

          {/* Content */}
          <div className="px-4 pb-3">
            <p className="text-gray-900 mb-3">{post.content}</p>
            <div className="flex flex-wrap gap-2">
              {post.tags.map((tag, index) => (
                <span key={index} className="text-primary text-sm bg-primary/10 px-2 py-1 rounded">
                  {tag}
                </span>
              ))}
            </div>
          </div>

          {/* Image */}
          <ImageWithFallback
            src={post.image}
            alt="Post image"
            className="w-full h-64 object-cover"
          />

          {/* Actions */}
          <div className="p-4 flex items-center justify-between">
            <div className="flex items-center space-x-6">
              <button className="flex items-center space-x-2 text-gray-600">
                <Heart className="w-5 h-5" />
                <span className="text-sm">{post.likes}</span>
              </button>
              <button className="flex items-center space-x-2 text-gray-600">
                <MessageCircle className="w-5 h-5" />
                <span className="text-sm">{post.comments}</span>
              </button>
            </div>
            <button className="text-gray-600">
              <Share className="w-5 h-5" />
            </button>
          </div>
        </div>
      ))}
    </div>
  );
});