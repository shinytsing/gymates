import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ArrowLeft, Search, Filter, Plus, Star, Heart, Info, Upload, X } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface ExerciseSelectionPageProps {
  onBack: () => void;
  onAddToPlann?: (exerciseId: number) => void;
  onViewDetail?: (exerciseId: number) => void;
}

export function ExerciseSelectionPage({ onBack, onAddToPlann, onViewDetail }: ExerciseSelectionPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [selectedType, setSelectedType] = useState('all');
  const [selectedDifficulty, setSelectedDifficulty] = useState('all');
  const [showFilters, setShowFilters] = useState(false);
  const [showUploadModal, setShowUploadModal] = useState(false);
  const [favorites, setFavorites] = useState<number[]>([1, 3]);

  const categories = [
    { id: 'all', label: '全部', icon: '🎯' },
    { id: 'chest', label: '胸部', icon: '💪' },
    { id: 'back', label: '背部', icon: '🦾' },
    { id: 'legs', label: '腿部', icon: '🦵' },
    { id: 'core', label: '核心', icon: '⚡' },
    { id: 'arms', label: '手臂', icon: '💪' },
    { id: 'shoulders', label: '肩部', icon: '🏋️' }
  ];

  const types = [
    { id: 'all', label: '全部' },
    { id: 'bodyweight', label: '徒手' },
    { id: 'equipment', label: '器材' },
    { id: 'cardio', label: '有氧' },
    { id: 'strength', label: '力量' }
  ];

  const difficulties = [
    { id: 'all', label: '全部' },
    { id: 'beginner', label: '初学', icon: '⭐' },
    { id: 'intermediate', label: '中级', icon: '⭐⭐' },
    { id: 'advanced', label: '高级', icon: '⭐⭐⭐' }
  ];

  const recommendedExercises = [
    {
      id: 1,
      name: '深蹲',
      category: '腿部',
      type: 'bodyweight',
      difficulty: 'beginner',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '10分钟',
      calories: 80
    },
    {
      id: 2,
      name: '平板支撑',
      category: '核心',
      type: 'bodyweight',
      difficulty: 'beginner',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '5分钟',
      calories: 50
    },
    {
      id: 3,
      name: '俯卧撑',
      category: '胸部',
      type: 'bodyweight',
      difficulty: 'intermediate',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '8分钟',
      calories: 70
    }
  ];

  const allExercises = [
    ...recommendedExercises,
    {
      id: 4,
      name: '卷腹',
      category: '核心',
      type: 'bodyweight',
      difficulty: 'beginner',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '10分钟',
      calories: 75
    },
    {
      id: 5,
      name: '波比跳',
      category: '全身',
      type: 'cardio',
      difficulty: 'advanced',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '12分钟',
      calories: 120
    },
    {
      id: 6,
      name: '引体向上',
      category: '背部',
      type: 'equipment',
      difficulty: 'advanced',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '10分钟',
      calories: 85
    }
  ];

  const toggleFavorite = (id: number) => {
    setFavorites(prev => 
      prev.includes(id) ? prev.filter(fav => fav !== id) : [...prev, id]
    );
  };

  const getDifficultyStars = (difficulty: string) => {
    const diff = difficulties.find(d => d.id === difficulty);
    return diff?.icon || '⭐';
  };

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-3 flex-1">
            <button
              onClick={onBack}
              className={`w-10 h-10 ${isIOS ? 'bg-gray-100 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}
            >
              <ArrowLeft className="w-5 h-5 text-gray-900" />
            </button>
            <h1 className="text-xl text-gray-900">动作库</h1>
          </div>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={`px-4 py-2 ${isIOS ? 'bg-gray-100 rounded-xl' : 'bg-gray-100 rounded-lg'} flex items-center space-x-2 transition-colors`}
          >
            <Filter className="w-4 h-4 text-gray-700" />
            <span className="text-sm text-gray-700">筛选</span>
          </button>
        </div>

        {/* Search Bar */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="搜索动作名称，例如：深蹲、俯卧撑"
            className={`w-full pl-10 pr-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary text-gray-900 text-sm`}
          />
        </div>

        {/* Filters */}
        <AnimatePresence>
          {showFilters && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="overflow-hidden"
            >
              <div className="pt-4 space-y-3">
                {/* Type Filter */}
                <div>
                  <p className="text-xs text-gray-600 mb-2">类型</p>
                  <div className="flex flex-wrap gap-2">
                    {types.map(type => (
                      <button
                        key={type.id}
                        onClick={() => setSelectedType(type.id)}
                        className={`px-3 py-1.5 text-sm ${isIOS ? 'rounded-lg' : 'rounded'} border transition-colors ${
                          selectedType === type.id
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
                        }`}
                      >
                        {type.label}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Difficulty Filter */}
                <div>
                  <p className="text-xs text-gray-600 mb-2">难度</p>
                  <div className="flex flex-wrap gap-2">
                    {difficulties.map(diff => (
                      <button
                        key={diff.id}
                        onClick={() => setSelectedDifficulty(diff.id)}
                        className={`px-3 py-1.5 text-sm ${isIOS ? 'rounded-lg' : 'rounded'} border transition-colors ${
                          selectedDifficulty === diff.id
                            ? 'border-primary bg-primary/10 text-primary'
                            : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
                        }`}
                      >
                        {diff.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      <div className="px-4 py-6 space-y-6">
        {/* Category Tabs */}
        <div className="flex overflow-x-auto space-x-3 pb-2 -mx-4 px-4 scrollbar-hide">
          {categories.map(category => (
            <button
              key={category.id}
              onClick={() => setSelectedCategory(category.id)}
              className={`flex-shrink-0 px-4 py-2 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 transition-all flex items-center space-x-2 ${
                selectedCategory === category.id
                  ? 'border-primary bg-primary/10 text-primary'
                  : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
              }`}
            >
              <span className="text-lg">{category.icon}</span>
              <span className="text-sm whitespace-nowrap">{category.label}</span>
            </button>
          ))}
        </div>

        {/* Recommended Section */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg text-gray-900">我的精选动作</h2>
            <Star className="w-5 h-5 text-yellow-500" />
          </div>
          <div className="flex overflow-x-auto space-x-4 pb-2 -mx-4 px-4 scrollbar-hide">
            {recommendedExercises.map(exercise => (
              <motion.div
                key={exercise.id}
                whileHover={{ scale: 1.02 }}
                className={`flex-shrink-0 w-48 bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border border-gray-200 overflow-hidden shadow-sm`}
              >
                <div className="relative">
                  <ImageWithFallback
                    src={exercise.image}
                    alt={exercise.name}
                    className="w-full h-32 object-cover"
                  />
                  <button
                    onClick={() => toggleFavorite(exercise.id)}
                    className="absolute top-2 right-2 w-8 h-8 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-sm"
                  >
                    <Heart className={`w-4 h-4 ${favorites.includes(exercise.id) ? 'fill-red-500 text-red-500' : 'text-gray-600'}`} />
                  </button>
                </div>
                <div className="p-3">
                  <h3 className="text-sm text-gray-900 mb-1">{exercise.name}</h3>
                  <p className="text-xs text-gray-500 mb-2">{exercise.category}</p>
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-gray-600">{exercise.duration}</span>
                    <span className="text-primary">{exercise.calories}卡</span>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* All Exercises */}
        <div>
          <h2 className="text-lg text-gray-900 mb-4">全部动作</h2>
          <div className="space-y-3">
            {allExercises.map((exercise, index) => (
              <motion.div
                key={exercise.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
                className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border border-gray-200 overflow-hidden shadow-sm`}
              >
                <div className="flex items-center p-4 space-x-4">
                  {/* Exercise Image */}
                  <div className="relative flex-shrink-0">
                    <ImageWithFallback
                      src={exercise.image}
                      alt={exercise.name}
                      className={`w-24 h-24 object-cover ${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
                    />
                    <div className="absolute top-1 left-1 px-2 py-0.5 bg-black/60 backdrop-blur-sm rounded text-xs text-white">
                      {getDifficultyStars(exercise.difficulty)}
                    </div>
                  </div>

                  {/* Exercise Info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <h3 className="text-gray-900 mb-1">{exercise.name}</h3>
                        <p className="text-sm text-gray-500">{exercise.category}</p>
                      </div>
                      <button
                        onClick={() => toggleFavorite(exercise.id)}
                        className={`w-8 h-8 flex items-center justify-center transition-transform ${isIOS ? 'active:scale-90' : 'hover:scale-110'}`}
                      >
                        <Heart className={`w-5 h-5 ${favorites.includes(exercise.id) ? 'fill-red-500 text-red-500' : 'text-gray-400'}`} />
                      </button>
                    </div>
                    <div className="flex items-center space-x-4 text-sm text-gray-600 mb-3">
                      <span>{exercise.duration}</span>
                      <span className="text-orange-600">{exercise.calories}卡</span>
                    </div>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => onAddToPlann?.(exercise.id)}
                        className={`flex-1 py-2 bg-primary text-white text-sm ${isIOS ? 'rounded-lg' : 'rounded'} transition-all ${
                          isIOS ? 'active:scale-95' : 'hover:bg-primary/90'
                        }`}
                      >
                        添加进计划
                      </button>
                      <button
                        onClick={() => onViewDetail?.(exercise.id)}
                        className={`px-4 py-2 border border-gray-300 text-gray-700 text-sm ${isIOS ? 'rounded-lg' : 'rounded'} flex items-center space-x-1 transition-colors ${
                          isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50'
                        }`}
                      >
                        <Info className="w-4 h-4" />
                        <span>详情</span>
                      </button>
                    </div>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>

      {/* Floating Action Button */}
      <button
        onClick={() => setShowUploadModal(true)}
        className={`fixed bottom-24 right-4 w-14 h-14 bg-gradient-to-br from-primary to-purple-600 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center shadow-lg transition-transform ${
          isIOS ? 'active:scale-90' : 'hover:scale-105'
        }`}
      >
        <Upload className="w-6 h-6 text-white" />
      </button>

      {/* Upload Modal */}
      <AnimatePresence>
        {showUploadModal && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowUploadModal(false)}
              className="fixed inset-0 bg-black/50 z-40"
            />
            <motion.div
              initial={{ y: '100%' }}
              animate={{ y: 0 }}
              exit={{ y: '100%' }}
              transition={{ type: 'spring', damping: 30, stiffness: 300 }}
              className={`fixed bottom-0 left-0 right-0 bg-white ${isIOS ? 'rounded-t-3xl' : 'rounded-t-2xl'} shadow-2xl z-50 max-h-[90vh] overflow-auto pb-8`}
            >
              <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
                <h3 className="text-lg text-gray-900">上传自定义动作</h3>
                <button
                  onClick={() => setShowUploadModal(false)}
                  className={`w-8 h-8 ${isIOS ? 'bg-gray-100 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}
                >
                  <X className="w-5 h-5 text-gray-600" />
                </button>
              </div>

              <div className="px-6 py-6 space-y-4">
                <div>
                  <label className="block text-sm text-gray-700 mb-2">动作名称</label>
                  <input
                    type="text"
                    placeholder="例如：深蹲"
                    className={`w-full px-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary`}
                  />
                </div>

                <div>
                  <label className="block text-sm text-gray-700 mb-2">动作描述</label>
                  <textarea
                    placeholder="描述动作要练习的目标和肌肉部位"
                    rows={3}
                    className={`w-full px-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none`}
                  />
                </div>

                <div>
                  <label className="block text-sm text-gray-700 mb-2">动作强度</label>
                  <div className="flex space-x-3">
                    {['轻松', '适中', '高强度'].map((level) => (
                      <button
                        key={level}
                        className={`flex-1 py-2 border-2 border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} text-sm transition-colors hover:border-primary hover:text-primary`}
                      >
                        {level}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-sm text-gray-700 mb-2">动作类型</label>
                  <div className="flex space-x-3">
                    {['徒手', '装备类'].map((type) => (
                      <button
                        key={type}
                        className={`flex-1 py-2 border-2 border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} text-sm transition-colors hover:border-primary hover:text-primary`}
                      >
                        {type}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-sm text-gray-700 mb-2">上传文件</label>
                  <div className={`border-2 border-dashed border-gray-300 ${isIOS ? 'rounded-xl' : 'rounded-lg'} p-8 text-center hover:border-primary transition-colors cursor-pointer`}>
                    <Upload className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                    <p className="text-sm text-gray-600">点击上传图片、GIF或视频</p>
                    <p className="text-xs text-gray-400 mt-1">支持 JPG, PNG, GIF, MP4</p>
                  </div>
                </div>

                <button
                  className={`w-full py-4 bg-gradient-to-r from-primary to-purple-600 text-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} transition-all ${
                    isIOS ? 'active:scale-95' : 'hover:shadow-lg'
                  } shadow-md`}
                >
                  提交动作
                </button>
              </div>

              {isIOS && (
                <div className="w-32 h-1 bg-gray-900 rounded-full mx-auto mt-4 opacity-30" />
              )}
            </motion.div>
          </>
        )}
      </AnimatePresence>

      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
