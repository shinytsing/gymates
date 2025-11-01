import React, { useState } from 'react';
import { Heart, MessageCircle, Share, MoreHorizontal, MapPin, Target } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { useTheme } from '../context/ThemeContext';
import type { FilterOptions } from './FilterBar';

interface NearbyFeedListProps {
  filters: FilterOptions;
}

export function NearbyFeedList({ filters }: NearbyFeedListProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [likedPosts, setLikedPosts] = useState<number[]>([]);

  const allPosts = [
    {
      id: 1,
      user: {
        name: '跑步达人Alex',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        gender: 'male',
        goal: 'lose-weight',
        location: '朝阳公园',
        distance: 2.3
      },
      content: '早晨10公里晨跑完成！天气真好，遇到了几个跑友一起跑，感觉棒极了！有没有附近的朋友一起组队晨跑？',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      time: '30分钟前',
      likes: 45,
      comments: 12,
      tags: ['#晨跑', '#减脂', '#找搭子']
    },
    {
      id: 2,
      user: {
        name: '健身教练Lisa',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        gender: 'female',
        goal: 'build-muscle',
        location: 'FitTime健身房',
        distance: 1.5
      },
      content: '今天练背日！分享一组超有效的背部训练动作，坚持一个月你会看到明显的变化💪',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      time: '1小时前',
      likes: 89,
      comments: 23,
      tags: ['#增肌', '#背部训练', '#健身教练']
    },
    {
      id: 3,
      user: {
        name: '瑜伽爱好者小美',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        gender: 'female',
        goal: 'improve-fitness',
        location: '瑜伽工作室',
        distance: 3.8
      },
      content: '下午的阴瑜伽课程太放松了～分享今天学到的新体式，适合放松肩颈的姐妹们',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
      time: '2小时前',
      likes: 67,
      comments: 15,
      tags: ['#瑜伽', '#塑形', '#放松']
    },
    {
      id: 4,
      user: {
        name: '游泳健将Tom',
        avatar: 'https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
        gender: 'male',
        goal: 'stay-healthy',
        location: '朝阳游泳馆',
        distance: 4.2
      },
      content: '游泳是最好的全身运动！今天游了2000米，身心都得到了放松。附近有游泳爱好者吗？',
      time: '3小时前',
      likes: 34,
      comments: 8,
      tags: ['#游泳', '#健康', '#全身运动']
    }
  ];

  // Filter posts based on filters
  const filteredPosts = allPosts.filter(post => {
    // Distance filter
    if (post.user.distance > filters.distance) return false;
    
    // Gender filter
    if (filters.gender !== 'all' && post.user.gender !== filters.gender) return false;
    
    // Goal filter
    if (filters.goal !== 'all' && post.user.goal !== filters.goal) return false;
    
    return true;
  });

  const toggleLike = (postId: number) => {
    setLikedPosts(prev => 
      prev.includes(postId) 
        ? prev.filter(id => id !== postId)
        : [...prev, postId]
    );
  };

  const goalLabels: Record<string, string> = {
    'lose-weight': '减脂',
    'build-muscle': '增肌',
    'improve-fitness': '塑形',
    'stay-healthy': '健康'
  };

  if (filteredPosts.length === 0) {
    return (
      <div className="text-center py-12">
        <MapPin className="w-16 h-16 text-gray-300 mx-auto mb-4" />
        <p className="text-gray-500">暂无符合条件的附近动态</p>
        <p className="text-sm text-gray-400 mt-2">试试调整筛选条件</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {filteredPosts.map((post) => {
        const isLiked = likedPosts.includes(post.id);
        
        return (
          <div key={post.id} className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border border-gray-200 overflow-hidden`}>
            {/* User info */}
            <div className="p-4 flex items-start justify-between">
              <div className="flex items-start space-x-3 flex-1">
                <ImageWithFallback
                  src={post.user.avatar}
                  alt={post.user.name}
                  className="w-12 h-12 rounded-full object-cover"
                />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center space-x-2">
                    <p className="text-gray-900">{post.user.name}</p>
                    <span className={`px-2 py-0.5 ${isIOS ? 'rounded-lg' : 'rounded'} bg-primary/10 text-primary text-xs`}>
                      {goalLabels[post.user.goal]}
                    </span>
                  </div>
                  <div className="flex items-center space-x-2 mt-1">
                    <MapPin className="w-3 h-3 text-gray-400" />
                    <span className="text-xs text-gray-500">{post.user.location}</span>
                    <span className="text-xs text-gray-400">·</span>
                    <span className="text-xs text-gray-500">{post.user.distance}km</span>
                    <span className="text-xs text-gray-400">·</span>
                    <span className="text-xs text-gray-500">{post.time}</span>
                  </div>
                </div>
              </div>
              <button className={`w-8 h-8 ${isIOS ? 'bg-gray-50 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}>
                <MoreHorizontal className="w-4 h-4 text-gray-600" />
              </button>
            </div>

            {/* Content */}
            <div className="px-4 pb-3">
              <p className="text-gray-900 mb-3 leading-relaxed">{post.content}</p>
              <div className="flex flex-wrap gap-2">
                {post.tags.map((tag, index) => (
                  <span key={index} className={`text-primary text-xs ${isIOS ? 'bg-primary/5 px-2.5 py-1 rounded-lg' : 'bg-primary/10 px-2 py-0.5 rounded'}`}>
                    {tag}
                  </span>
                ))}
              </div>
            </div>

            {/* Image */}
            {post.image && (
              <ImageWithFallback
                src={post.image}
                alt="Post image"
                className="w-full h-64 object-cover"
              />
            )}

            {/* Actions */}
            <div className="p-4 flex items-center justify-between">
              <div className="flex items-center space-x-6">
                <button 
                  onClick={() => toggleLike(post.id)}
                  className={`flex items-center space-x-2 transition-all ${
                    isIOS ? 'active:scale-95' : 'hover:scale-105'
                  } ${isLiked ? 'text-red-500' : 'text-gray-600'}`}
                >
                  <Heart className={`w-5 h-5 ${isLiked ? 'fill-current' : ''}`} />
                  <span className="text-sm">{post.likes + (isLiked ? 1 : 0)}</span>
                </button>
                <button className={`flex items-center space-x-2 text-gray-600 transition-transform ${isIOS ? 'active:scale-95' : 'hover:scale-105'}`}>
                  <MessageCircle className="w-5 h-5" />
                  <span className="text-sm">{post.comments}</span>
                </button>
              </div>
              <button className={`text-gray-600 transition-transform ${isIOS ? 'active:scale-95' : 'hover:scale-105'}`}>
                <Share className="w-5 h-5" />
              </button>
            </div>
          </div>
        );
      })}
    </div>
  );
}
