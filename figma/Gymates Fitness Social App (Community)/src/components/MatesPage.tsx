import { useState, useCallback } from 'react';
import { motion } from 'motion/react';
import { Button } from './ui/button';
import { Card, CardContent } from './ui/card';
import { Badge } from './ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from './ui/avatar';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from './ui/sheet';
import { 
  Heart, 
  X, 
  MapPin, 
  Clock, 
  Target, 
  Activity,
  User,
  Users,
  Star,
  MessageCircle,
  Calendar,
  Award,
  UserPlus
} from 'lucide-react';
import { useTheme } from './context/ThemeContext';
import { GymList } from './community/GymList';

export function MatesPage() {
  const { theme } = useTheme();
  const [currentCardIndex, setCurrentCardIndex] = useState(0);
  const [swipeDirection, setSwipeDirection] = useState<'left' | 'right' | null>(null);
  const [activeTab, setActiveTab] = useState('mates');

  const handleTabChange = useCallback((tab: string) => {
    setActiveTab(tab);
  }, []);

  const mates = [
    {
      id: 1,
      name: "陈雨晨",
      age: 25,
      avatar: "https://images.unsplash.com/photo-1541338784564-51087dabc0de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwd29tYW4lMjB0cmFpbmluZyUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxMnww&ixlib=rb-4.1.0&q=80&w=400",
      distance: "2.5km",
      matchRate: 92,
      workoutTime: "晚上 7-9点",
      preferences: ["力量训练", "瑜伽", "跑步"],
      goal: "减脂塑形",
      experience: "中级",
      bio: "热爱运动的设计师，希望找到一起坚持健身的伙伴！每周至少4次训练，追求健康生活方式。",
      rating: 4.8,
      workouts: 156
    },
    {
      id: 2,
      name: "张健康",
      age: 28,
      avatar: "https://images.unsplash.com/photo-1607286908165-b8b6a2874fc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwcG9ydHJhaXQlMjBhdGhsZXRlJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MTV8MA&ixlib=rb-4.1.0&q=80&w=400",
      distance: "1.8km",
      matchRate: 85,
      workoutTime: "早上 6-8点",
      preferences: ["力量训练", "CrossFit", "游泳"],
      goal: "增肌",
      experience: "高级",
      bio: "健身教练，专注力量训练5年+。喜欢挑战自己，也乐于帮助健身新手。",
      rating: 4.9,
      workouts: 324
    },
    {
      id: 3,
      name: "李小雅",
      age: 23,
      avatar: "https://images.unsplash.com/photo-1669989179336-b2234d2878df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dCUyMG1vdGl2YXRpb258ZW58MXx8fHwxNzU5NTMwOTA5fDA&ixlib=rb-4.1.0&q=80&w=400",
      distance: "3.2km",
      matchRate: 78,
      workoutTime: "下午 2-4点",
      preferences: ["瑜伽", "普拉提", "舞蹈"],
      goal: "塑形",
      experience: "初级",
      bio: "刚开始健身的大学生，希望找到耐心的健身伙伴一起进步。",
      rating: 4.6,
      workouts: 42
    }
  ];

  const currentMate = mates[currentCardIndex];
  const isIOS = theme === 'ios';

  const handleSwipe = (direction: 'left' | 'right') => {
    setSwipeDirection(direction);
    setTimeout(() => {
      setCurrentCardIndex((prev) => (prev + 1) % mates.length);
      setSwipeDirection(null);
    }, 300);
  };

  const iosStyles = {
    container: "bg-white rounded-3xl shadow-sm border-gray-100",
    card: "rounded-3xl border-0 shadow-lg bg-white",
    button: "rounded-full h-14 w-14",
    sheet: "rounded-t-3xl"
  };

  const androidStyles = {
    container: "bg-white rounded-2xl shadow-md",
    card: "rounded-2xl border shadow-lg bg-white",
    button: "rounded-full h-16 w-16",
    sheet: "rounded-t-2xl"
  };

  const styles = isIOS ? iosStyles : androidStyles;

  const MateDetailSheet = ({ mate }: { mate: any }) => (
    <Sheet>
      <SheetTrigger asChild>
        <button className="absolute top-4 right-4 p-2 bg-white/80 backdrop-blur-sm rounded-full hover:bg-white/90 transition-colors">
          <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clipRule="evenodd" />
          </svg>
        </button>
      </SheetTrigger>
      <SheetContent side="bottom" className={`${styles.sheet} max-h-[80vh]`}>
        <SheetHeader className="pb-4">
          <SheetTitle className="text-xl text-gray-900">
            {mate.name}的详细资料
          </SheetTitle>
        </SheetHeader>
        
        <div className="space-y-4 pb-6">
          {/* Basic Info */}
          <div className="flex items-center gap-4">
            <Avatar className="w-16 h-16">
              <AvatarImage src={mate.avatar} alt={mate.name} />
              <AvatarFallback>{mate.name[0]}</AvatarFallback>
            </Avatar>
            <div>
              <h3 className="text-lg text-gray-900">{mate.name}, {mate.age}</h3>
              <div className="flex items-center gap-2 mt-1">
                <MapPin className="w-4 h-4 text-gray-500" />
                <span className="text-sm text-gray-600">{mate.distance}</span>
                <div className="flex items-center gap-1 ml-2">
                  <Star className="w-4 h-4 text-yellow-500 fill-current" />
                  <span className="text-sm">{mate.rating}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Match Rate */}
          <div className="bg-green-50 rounded-lg p-3">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-green-800">匹配度</span>
              <span className="text-lg text-green-600">{mate.matchRate}%</span>
            </div>
            <div className="w-full bg-green-200 rounded-full h-2">
              <div 
                className="bg-green-500 h-2 rounded-full" 
                style={{ width: `${mate.matchRate}%` }}
              />
            </div>
          </div>

          {/* Bio */}
          <div>
            <h4 className="text-gray-900 mb-2">个人介绍</h4>
            <p className="text-gray-600 text-sm leading-relaxed">{mate.bio}</p>
          </div>

          {/* Workout Info */}
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-gray-50 rounded-lg p-3">
              <div className="flex items-center gap-2 mb-1">
                <Target className="w-4 h-4 text-blue-500" />
                <span className="text-sm text-gray-700">目标</span>
              </div>
              <p className="text-sm text-gray-900">{mate.goal}</p>
            </div>
            <div className="bg-gray-50 rounded-lg p-3">
              <div className="flex items-center gap-2 mb-1">
                <Award className="w-4 h-4 text-purple-500" />
                <span className="text-sm text-gray-700">经验</span>
              </div>
              <p className="text-sm text-gray-900">{mate.experience}</p>
            </div>
            <div className="bg-gray-50 rounded-lg p-3">
              <div className="flex items-center gap-2 mb-1">
                <Clock className="w-4 h-4 text-orange-500" />
                <span className="text-sm text-gray-700">时间</span>
              </div>
              <p className="text-sm text-gray-900">{mate.workoutTime}</p>
            </div>
            <div className="bg-gray-50 rounded-lg p-3">
              <div className="flex items-center gap-2 mb-1">
                <Calendar className="w-4 h-4 text-green-500" />
                <span className="text-sm text-gray-700">训练</span>
              </div>
              <p className="text-sm text-gray-900">{mate.workouts}次</p>
            </div>
          </div>

          {/* Preferences */}
          <div>
            <h4 className="text-gray-900 mb-2">运动偏好</h4>
            <div className="flex flex-wrap gap-2">
              {mate.preferences.map((pref: string, index: number) => (
                <Badge key={index} variant="secondary" className="bg-green-100 text-green-800">
                  {pref}
                </Badge>
              ))}
            </div>
          </div>

          {/* Action Button */}
          <Button className={`w-full bg-green-500 hover:bg-green-600 text-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} h-12`}>
            <MessageCircle className="w-4 h-4 mr-2" />
            发起搭子邀请
          </Button>
        </div>
      </SheetContent>
    </Sheet>
  );

  if (!currentMate) return null;

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className={`bg-white px-4 pt-6 pb-4`}>
        <div className="flex items-center justify-between mb-4">
          <div className="flex-1">
            <h1 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>搭子</h1>
            <p className="text-sm text-gray-600">滑动卡片寻找你的健身伙伴</p>
          </div>
          <div className="flex items-center space-x-3">
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center`}>
              <UserPlus className="w-5 h-5 text-gray-600" />
            </button>
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center relative`}>
              <MessageCircle className="w-5 h-5 text-gray-600" />
              <div className="absolute -top-1 -right-1 w-3 h-3 bg-red-500 rounded-full"></div>
            </button>
          </div>
        </div>
        
        {/* Tabs */}
        <div className="flex space-x-1 bg-gray-100 rounded-lg p-1">
          <button
            onClick={() => handleTabChange('mates')}
            className={`flex-1 py-2 px-4 rounded-md transition-colors ${
              activeTab === 'mates'
                ? 'bg-white text-primary shadow-sm'
                : 'text-gray-600'
            }`}
          >
            搭子
          </button>
          <button
            onClick={() => handleTabChange('gyms')}
            className={`flex-1 py-2 px-4 rounded-md transition-colors ${
              activeTab === 'gyms'
                ? 'bg-white text-primary shadow-sm'
                : 'text-gray-600'
            }`}
          >
            健身房见
          </button>
        </div>
      </div>

      {/* Content based on active tab */}
      {activeTab === 'mates' ? (
        <>
          {/* Card Stack */}
          <div className="relative px-4 mb-8" style={{ height: '500px' }}>
            <motion.div
              key={currentMate.id}
              className={`absolute inset-0 ${styles.card} overflow-hidden`}
              animate={
                swipeDirection === 'left' 
                  ? { x: -300, rotate: -10, opacity: 0 }
                  : swipeDirection === 'right'
                  ? { x: 300, rotate: 10, opacity: 0 }
                  : { x: 0, rotate: 0, opacity: 1 }
              }
              transition={{ duration: 0.3 }}
            >
              {/* Background Image */}
              <div 
                className="absolute inset-0 bg-cover bg-center"
                style={{ backgroundImage: `url(${currentMate.avatar})` }}
              >
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
              </div>

              {/* Content */}
              <div className="relative h-full flex flex-col justify-end p-6 text-white">
                <div className="mb-4">
                  <div className="flex items-center justify-between mb-2">
                    <h2 className="text-2xl">{currentMate.name}, {currentMate.age}</h2>
                    <div className="bg-green-500 rounded-full px-3 py-1">
                      <span className="text-sm">{currentMate.matchRate}%</span>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-4 text-sm mb-3">
                    <div className="flex items-center gap-1">
                      <MapPin className="w-4 h-4" />
                      <span>{currentMate.distance}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Clock className="w-4 h-4" />
                      <span>{currentMate.workoutTime}</span>
                    </div>
                  </div>

                  <div className="flex flex-wrap gap-2 mb-3">
                    {currentMate.preferences.slice(0, 3).map((pref: string, index: number) => (
                      <Badge key={index} variant="secondary" className="bg-white/20 text-white border-white/30">
                        {pref}
                      </Badge>
                    ))}
                  </div>

                  <p className="text-sm opacity-90 line-clamp-2">{currentMate.bio}</p>
                </div>
              </div>

              {/* Detail Sheet Trigger */}
              <MateDetailSheet mate={currentMate} />
            </motion.div>
          </div>

          {/* Action Buttons */}
          <div className="flex justify-center gap-6 px-4">
            <Button
              variant="outline"
              className={`${styles.button} border-2 border-gray-300 bg-white hover:bg-gray-50`}
              onClick={() => handleSwipe('left')}
            >
              <X className="w-6 h-6 text-gray-600" />
            </Button>
            
            <Button
              className={`${styles.button} bg-green-500 hover:bg-green-600 text-white`}
              onClick={() => handleSwipe('right')}
            >
              <Heart className="w-6 h-6" />
            </Button>
          </div>
        </>
      ) : (
        <div className="px-4">
          <GymList />
        </div>
      )}

      {/* iOS Home Indicator */}
      {isIOS && (
        <div className="w-32 h-1 bg-gray-900 rounded-full mx-auto mt-6 opacity-60" />
      )}
    </div>
  );
}