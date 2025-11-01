import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ArrowLeft, Play, Pause, SkipForward, Volume2, CheckCircle, Flame, Clock, TrendingUp } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface AITrainerPageProps {
  onBack: () => void;
  onComplete?: () => void;
}

export function AITrainerPage({ onBack, onComplete }: AITrainerPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [isPaused, setIsPaused] = useState(false);
  const [currentExercise, setCurrentExercise] = useState(0);
  const [timeRemaining, setTimeRemaining] = useState(30);
  const [showFeedback, setShowFeedback] = useState(false);

  const exercises = [
    {
      id: 1,
      name: '平板支撑',
      duration: 60,
      calories: 50,
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      tips: [
        '保持身体呈一条直线',
        '不要让臀部过高或过低',
        '收紧核心肌群',
        '保持自然呼吸'
      ]
    },
    {
      id: 2,
      name: '深蹲',
      duration: 90,
      calories: 80,
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      tips: [
        '双脚与肩同宽站立',
        '膝盖不要超过脚尖',
        '保持背部挺直',
        '臀部向后坐'
      ]
    },
    {
      id: 3,
      name: '俯卧撑',
      duration: 60,
      calories: 70,
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      tips: [
        '双手与肩同宽撑地',
        '身体保持一条直线',
        '肘部向后弯曲',
        '完全伸展手臂'
      ]
    },
    {
      id: 4,
      name: '卷腹',
      duration: 60,
      calories: 75,
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      tips: [
        '仰卧，双脚平放',
        '用腹部力量抬起上身',
        '不要用颈部发力',
        '缓慢控制动作'
      ]
    },
    {
      id: 5,
      name: '波比跳',
      duration: 90,
      calories: 120,
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      tips: [
        '保持动作流畅连贯',
        '跳跃时全力向上',
        '着地时膝盖微曲',
        '控制好呼吸节奏'
      ]
    }
  ];

  const feedbackMessages = [
    '你太棒了，继续加油！💪',
    '保持这个状态，你做得很好！🔥',
    '完美的姿势，继续保持！⭐',
    '你的进步让人惊叹！👏',
    '很好！注意保持呼吸！✨'
  ];

  const current = exercises[currentExercise];
  const totalExercises = exercises.length;
  const progress = ((currentExercise + 1) / totalExercises) * 100;
  const totalCalories = exercises.slice(0, currentExercise + 1).reduce((sum, ex) => sum + ex.calories, 0);
  const totalTime = exercises.slice(0, currentExercise).reduce((sum, ex) => sum + ex.duration, 0) + (current.duration - timeRemaining);

  // Timer effect
  useEffect(() => {
    if (!isPaused && timeRemaining > 0) {
      const timer = setInterval(() => {
        setTimeRemaining(prev => {
          if (prev <= 1) {
            handleNextExercise();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

      return () => clearInterval(timer);
    }
  }, [isPaused, timeRemaining]);

  // Show feedback periodically
  useEffect(() => {
    const feedbackInterval = setInterval(() => {
      setShowFeedback(true);
      setTimeout(() => setShowFeedback(false), 3000);
    }, 15000);

    return () => clearInterval(feedbackInterval);
  }, []);

  const handleNextExercise = () => {
    if (currentExercise < totalExercises - 1) {
      setCurrentExercise(prev => prev + 1);
      setTimeRemaining(exercises[currentExercise + 1].duration);
    } else {
      onComplete?.();
    }
  };

  const handlePauseResume = () => {
    setIsPaused(!isPaused);
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-900 via-gray-800 to-gray-900 text-white pb-20 relative overflow-hidden">
      {/* Animated Background */}
      <div className="absolute inset-0 opacity-30">
        <motion.div
          animate={{
            scale: [1, 1.2, 1],
            rotate: [0, 90, 0],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute top-1/4 -left-20 w-96 h-96 bg-primary/20 rounded-full blur-3xl"
        />
        <motion.div
          animate={{
            scale: [1.2, 1, 1.2],
            rotate: [90, 0, 90],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: "linear"
          }}
          className="absolute bottom-1/4 -right-20 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl"
        />
      </div>

      {/* Header */}
      <div className="relative z-10 px-4 py-4 flex items-center justify-between">
        <button
          onClick={onBack}
          className={`w-10 h-10 bg-white/10 backdrop-blur-sm ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center transition-colors hover:bg-white/20`}
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <div className="text-center">
          <p className="text-sm text-white/70">正在训练</p>
          <h1 className="text-lg">目标达成计划</h1>
        </div>
        <button className={`w-10 h-10 bg-white/10 backdrop-blur-sm ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center transition-colors hover:bg-white/20`}>
          <Volume2 className="w-5 h-5" />
        </button>
      </div>

      {/* Progress Bar */}
      <div className="relative z-10 px-4 mt-4">
        <div className="flex items-center justify-between text-sm mb-2">
          <span>{currentExercise + 1}/{totalExercises} 动作完成</span>
          <span>{Math.round(progress)}%</span>
        </div>
        <div className="w-full h-2 bg-white/10 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            className="h-full bg-gradient-to-r from-primary to-purple-500 rounded-full"
          />
        </div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 px-4 mt-8">
        {/* Timer */}
        <motion.div
          key={currentExercise}
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="text-center mb-6"
        >
          <motion.div
            animate={!isPaused ? { scale: [1, 1.05, 1] } : {}}
            transition={{ duration: 1, repeat: Infinity }}
            className={`inline-flex items-center justify-center w-32 h-32 ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} bg-gradient-to-br from-primary to-purple-600 shadow-2xl mb-4`}
          >
            <span className="text-5xl font-mono">{formatTime(timeRemaining)}</span>
          </motion.div>
        </motion.div>

        {/* Exercise Info */}
        <div className="text-center mb-6">
          <h2 className="text-3xl mb-2">{current.name}</h2>
          <p className="text-white/70">保持姿势，注意呼吸</p>
        </div>

        {/* Exercise Demonstration */}
        <motion.div
          key={currentExercise}
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className={`relative ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} overflow-hidden mb-6 shadow-2xl`}
        >
          <ImageWithFallback
            src={current.image}
            alt={current.name}
            className="w-full h-64 object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
          {isPaused && (
            <div className="absolute inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center">
              <div className={`w-20 h-20 bg-white/20 ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} flex items-center justify-center`}>
                <Pause className="w-10 h-10" />
              </div>
            </div>
          )}
        </motion.div>

        {/* Exercise Tips */}
        <div className={`bg-white/5 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 mb-6`}>
          <h3 className="text-sm text-white/70 mb-3">动作要点</h3>
          <div className="space-y-2">
            {current.tips.map((tip, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
                className="flex items-start space-x-2"
              >
                <CheckCircle className="w-4 h-4 text-primary flex-shrink-0 mt-0.5" />
                <span className="text-sm">{tip}</span>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className={`bg-white/5 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-center`}>
            <Clock className="w-5 h-5 mx-auto mb-2 text-blue-400" />
            <p className="text-2xl mb-1">{Math.floor(totalTime / 60)}</p>
            <p className="text-xs text-white/70">分钟</p>
          </div>
          <div className={`bg-white/5 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-center`}>
            <Flame className="w-5 h-5 mx-auto mb-2 text-orange-400" />
            <p className="text-2xl mb-1">{totalCalories}</p>
            <p className="text-xs text-white/70">卡路里</p>
          </div>
          <div className={`bg-white/5 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-center`}>
            <TrendingUp className="w-5 h-5 mx-auto mb-2 text-green-400" />
            <p className="text-2xl mb-1">{currentExercise + 1}</p>
            <p className="text-xs text-white/70">/ {totalExercises}</p>
          </div>
        </div>

        {/* Control Buttons */}
        <div className="flex items-center justify-center space-x-4">
          <button
            onClick={handlePauseResume}
            className={`w-20 h-20 bg-gradient-to-br from-primary to-purple-600 ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} flex items-center justify-center shadow-2xl transition-all ${
              isIOS ? 'active:scale-90' : 'hover:scale-105'
            }`}
          >
            {isPaused ? (
              <Play className="w-8 h-8 ml-1" />
            ) : (
              <Pause className="w-8 h-8" />
            )}
          </button>
          <button
            onClick={handleNextExercise}
            className={`w-16 h-16 bg-white/10 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center transition-all ${
              isIOS ? 'active:scale-90' : 'hover:bg-white/20'
            }`}
          >
            <SkipForward className="w-6 h-6" />
          </button>
        </div>
      </div>

      {/* AI Feedback Toast */}
      <AnimatePresence>
        {showFeedback && (
          <motion.div
            initial={{ y: -100, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -100, opacity: 0 }}
            className="fixed top-20 left-1/2 -translate-x-1/2 z-50"
          >
            <div className={`bg-gradient-to-r from-primary to-purple-600 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} px-6 py-3 shadow-2xl`}>
              <p className="text-sm whitespace-nowrap">
                {feedbackMessages[Math.floor(Math.random() * feedbackMessages.length)]}
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Data Analysis (Concept) */}
      {!isPaused && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="fixed bottom-24 left-4 right-4 z-10"
        >
          <div className={`bg-white/5 backdrop-blur-sm ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 border border-white/10`}>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs text-white/70 mb-1">预计热量消耗</p>
                <p className="text-sm">约 {current.calories}卡/动作</p>
              </div>
              <div className="w-12 h-12 bg-gradient-to-br from-orange-400 to-red-500 rounded-full flex items-center justify-center">
                <Flame className="w-6 h-6" />
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </div>
  );
}
