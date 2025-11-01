import React, { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, Play, Pause, RotateCcw, Heart, Flame, Clock, TrendingUp, AlertCircle, Star, BookmarkPlus } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface ExerciseDetailPageProps {
  onBack: () => void;
  onStartTraining?: () => void;
}

export function ExerciseDetailPage({ onBack, onStartTraining }: ExerciseDetailPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [isPlaying, setIsPlaying] = useState(false);
  const [isFavorited, setIsFavorited] = useState(false);
  const [reps, setReps] = useState(15);

  const exercise = {
    id: 1,
    name: '深蹲',
    targetMuscle: '腿部',
    secondaryMuscles: ['臀部', '核心'],
    rating: 4.8,
    totalRatings: 2341,
    difficulty: 'intermediate',
    video: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    duration: 10,
    calories: 80,
    intensity: 4,
    steps: [
      {
        emoji: '🧍',
        title: '起始姿势',
        description: '双脚与肩同宽站立，脚尖略微外展，保持背部挺直，眼睛向前看。'
      },
      {
        emoji: '⬇️',
        title: '下蹲动作',
        description: '臀部向后坐，弯曲膝盖缓慢下蹲，保持膝盖不超过脚尖，大腿与地面平行。'
      },
      {
        emoji: '⬆️',
        title: '上升动作',
        description: '用腿部和臀部的力量推起身体，回到起始位置，保持核心收紧。'
      },
      {
        emoji: '🔄',
        title: '重复动作',
        description: '按照既定的次数和组数重复动作，保持呼吸自然流畅。'
      }
    ],
    tips: [
      {
        emoji: '⚠️',
        type: 'warning',
        text: '膝盖不要内扣，保持与脚尖方向一致'
      },
      {
        emoji: '🛑',
        type: 'danger',
        text: '不要弓背，保持脊椎中立位'
      },
      {
        emoji: '💡',
        type: 'tip',
        text: '下蹲时吸气，起立时呼气'
      }
    ],
    benefits: [
      '增强腿部力量',
      '提升核心稳定性',
      '改善下肢灵活性',
      '燃烧大量卡路里'
    ]
  };

  const difficultyLabels: Record<string, { label: string; color: string; stars: string }> = {
    beginner: { label: '初学', color: 'text-green-600', stars: '⭐' },
    intermediate: { label: '中级', color: 'text-yellow-600', stars: '⭐⭐' },
    advanced: { label: '高级', color: 'text-red-600', stars: '⭐⭐⭐' }
  };

  const difficultyInfo = difficultyLabels[exercise.difficulty];

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <button
            onClick={onBack}
            className={`w-10 h-10 ${isIOS ? 'bg-gray-100 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-900" />
          </button>
          <h1 className="text-lg text-gray-900">动作详情</h1>
          <button
            onClick={() => setIsFavorited(!isFavorited)}
            className={`w-10 h-10 flex items-center justify-center transition-transform ${
              isIOS ? 'active:scale-90' : 'hover:scale-110'
            }`}
          >
            <Heart className={`w-6 h-6 ${isFavorited ? 'fill-red-500 text-red-500' : 'text-gray-400'}`} />
          </button>
        </div>
      </div>

      <div className="space-y-6">
        {/* Video/GIF Demo */}
        <div className="relative bg-gradient-to-br from-primary/10 via-purple-50 to-blue-50">
          <ImageWithFallback
            src={exercise.video}
            alt={exercise.name}
            className="w-full h-80 object-cover"
          />
          
          {/* Animated Wave Background */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <motion.div
              animate={{
                x: [0, 100, 0],
                y: [0, 50, 0],
              }}
              transition={{
                duration: 10,
                repeat: Infinity,
                ease: "linear"
              }}
              className="absolute -bottom-10 -left-10 w-96 h-96 bg-blue-400/10 rounded-full blur-3xl"
            />
            <motion.div
              animate={{
                x: [100, 0, 100],
                y: [50, 0, 50],
              }}
              transition={{
                duration: 10,
                repeat: Infinity,
                ease: "linear"
              }}
              className="absolute -top-10 -right-10 w-96 h-96 bg-purple-400/10 rounded-full blur-3xl"
            />
          </div>

          {/* Video Controls */}
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex items-center space-x-4">
            <button
              onClick={() => setIsPlaying(!isPlaying)}
              className={`w-16 h-16 bg-white/90 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} shadow-2xl flex items-center justify-center transition-transform ${
                isIOS ? 'active:scale-90' : 'hover:scale-105'
              }`}
            >
              {isPlaying ? (
                <Pause className="w-8 h-8 text-primary" />
              ) : (
                <Play className="w-8 h-8 text-primary ml-1" />
              )}
            </button>
            <button
              className={`w-12 h-12 bg-white/90 backdrop-blur-sm ${isIOS ? 'rounded-xl' : 'rounded-lg'} shadow-lg flex items-center justify-center transition-transform ${
                isIOS ? 'active:scale-90' : 'hover:scale-105'
              }`}
            >
              <RotateCcw className="w-5 h-5 text-gray-700" />
            </button>
          </div>
        </div>

        <div className="px-4 space-y-6">
          {/* Exercise Header */}
          <div>
            <div className="flex items-start justify-between mb-2">
              <div>
                <h2 className="text-2xl text-gray-900 mb-2">{exercise.name}</h2>
                <div className="flex items-center space-x-3 text-sm">
                  <span className={`px-2 py-1 ${isIOS ? 'rounded-lg' : 'rounded'} bg-primary/10 text-primary`}>
                    {exercise.targetMuscle}
                  </span>
                  {exercise.secondaryMuscles.map((muscle) => (
                    <span key={muscle} className={`px-2 py-1 ${isIOS ? 'rounded-lg' : 'rounded'} bg-gray-100 text-gray-600`}>
                      {muscle}
                    </span>
                  ))}
                </div>
              </div>
              <div className="text-right">
                <div className="flex items-center space-x-1">
                  {[...Array(5)].map((_, i) => (
                    <Star
                      key={i}
                      className={`w-4 h-4 ${
                        i < Math.floor(exercise.rating)
                          ? 'fill-yellow-400 text-yellow-400'
                          : 'text-gray-300'
                      }`}
                    />
                  ))}
                </div>
                <p className="text-xs text-gray-500 mt-1">{exercise.rating} ({exercise.totalRatings}人评价)</p>
              </div>
            </div>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-3 gap-3">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className={`bg-gradient-to-br from-blue-50 to-blue-100 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-center`}
            >
              <Clock className="w-6 h-6 text-blue-600 mx-auto mb-2" />
              <p className="text-2xl text-gray-900 mb-1">{exercise.duration}</p>
              <p className="text-xs text-gray-600">分钟</p>
            </motion.div>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className={`bg-gradient-to-br from-orange-50 to-orange-100 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-center`}
            >
              <Flame className="w-6 h-6 text-orange-600 mx-auto mb-2" />
              <p className="text-2xl text-gray-900 mb-1">{exercise.calories}</p>
              <p className="text-xs text-gray-600">卡路里</p>
            </motion.div>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className={`bg-gradient-to-br from-purple-50 to-purple-100 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-center`}
            >
              <TrendingUp className="w-6 h-6 text-purple-600 mx-auto mb-2" />
              <p className={`text-lg ${difficultyInfo.color} mb-1`}>{difficultyInfo.stars}</p>
              <p className="text-xs text-gray-600">{difficultyInfo.label}</p>
            </motion.div>
          </div>

          {/* Reps Counter */}
          <div className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border-2 border-gray-200 p-4`}>
            <div className="flex items-center justify-between mb-3">
              <h3 className="text-gray-900">目标次数</h3>
              <div className="flex items-center space-x-3">
                <button
                  onClick={() => setReps(Math.max(1, reps - 1))}
                  className={`w-8 h-8 bg-gray-100 ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center text-gray-700 transition-colors ${
                    isIOS ? 'active:bg-gray-200' : 'hover:bg-gray-200'
                  }`}
                >
                  -
                </button>
                <span className="text-2xl text-primary min-w-[3rem] text-center">{reps}</span>
                <button
                  onClick={() => setReps(reps + 1)}
                  className={`w-8 h-8 bg-gray-100 ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center text-gray-700 transition-colors ${
                    isIOS ? 'active:bg-gray-200' : 'hover:bg-gray-200'
                  }`}
                >
                  +
                </button>
              </div>
            </div>
            <p className="text-sm text-gray-500">建议每组{reps}次，共3-4组</p>
          </div>

          {/* Exercise Steps */}
          <div className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border border-gray-200 p-5`}>
            <h3 className="text-lg text-gray-900 mb-4">动作要领</h3>
            <div className="space-y-4">
              {exercise.steps.map((step, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.1 }}
                  className="flex items-start space-x-3"
                >
                  <div className={`flex-shrink-0 w-10 h-10 bg-gradient-to-br from-primary to-purple-600 ${isIOS ? 'rounded-xl' : 'rounded-lg'} flex items-center justify-center text-white shadow-sm`}>
                    <span className="text-lg">{step.emoji}</span>
                  </div>
                  <div className="flex-1">
                    <h4 className="text-gray-900 mb-1">{step.title}</h4>
                    <p className="text-sm text-gray-600 leading-relaxed">{step.description}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Tips & Warnings */}
          <div className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border border-gray-200 p-5`}>
            <h3 className="text-lg text-gray-900 mb-4">注意事项</h3>
            <div className="space-y-3">
              {exercise.tips.map((tip, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.3 + index * 0.1 }}
                  className={`p-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} ${
                    tip.type === 'warning'
                      ? 'bg-yellow-50 border border-yellow-200'
                      : tip.type === 'danger'
                      ? 'bg-red-50 border border-red-200'
                      : 'bg-green-50 border border-green-200'
                  }`}
                >
                  <div className="flex items-start space-x-2">
                    <span className="text-lg flex-shrink-0">{tip.emoji}</span>
                    <p className={`text-sm ${
                      tip.type === 'warning'
                        ? 'text-yellow-800'
                        : tip.type === 'danger'
                        ? 'text-red-800'
                        : 'text-green-800'
                    }`}>
                      {tip.text}
                    </p>
                  </div>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Benefits */}
          <div className={`bg-gradient-to-br from-green-50 to-emerald-50 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border-2 border-green-200 p-5`}>
            <h3 className="text-lg text-gray-900 mb-4">训练效果</h3>
            <div className="grid grid-cols-2 gap-3">
              {exercise.benefits.map((benefit, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 0.5 + index * 0.1 }}
                  className={`bg-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} p-3 flex items-center space-x-2`}
                >
                  <div className="w-2 h-2 bg-green-500 rounded-full" />
                  <span className="text-sm text-gray-700">{benefit}</span>
                </motion.div>
              ))}
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex space-x-3 pb-4">
            <button
              className={`px-6 py-4 border-2 border-gray-300 text-gray-700 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center space-x-2 transition-all ${
                isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50'
              }`}
            >
              <BookmarkPlus className="w-5 h-5" />
              <span>保存到收藏</span>
            </button>
            <button
              onClick={onStartTraining}
              className={`flex-1 py-4 bg-gradient-to-r from-primary to-purple-600 text-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center space-x-2 transition-all ${
                isIOS ? 'active:scale-95' : 'hover:shadow-lg'
              } shadow-md`}
            >
              <Play className="w-5 h-5" />
              <span>开始训练</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
