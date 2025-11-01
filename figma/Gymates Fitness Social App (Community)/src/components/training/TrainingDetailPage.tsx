import React, { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, Clock, Flame, Target, Plus, Play, CheckCircle, Info } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { ImageWithFallback } from '../figma/ImageWithFallback';

interface TrainingDetailPageProps {
  onBack: () => void;
  onStartExercise?: (exerciseId: number) => void;
  onAddExercise?: () => void;
}

export function TrainingDetailPage({ onBack, onStartExercise, onAddExercise }: TrainingDetailPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [completedExercises, setCompletedExercises] = useState<number[]>([1, 2]);

  const todayGoals = {
    totalTime: 45, // minutes
    targetCalories: 350,
    totalExercises: 5,
    completedTime: 20,
    burnedCalories: 180,
    completedExercises: 2
  };

  const exercises = [
    {
      id: 1,
      name: '深蹲',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '10分钟',
      reps: '4组 x 15次',
      calories: 80,
      completed: true
    },
    {
      id: 2,
      name: '平板支撑',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '5分钟',
      reps: '3组 x 60秒',
      calories: 50,
      completed: true
    },
    {
      id: 3,
      name: '俯卧撑',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '8分钟',
      reps: '4组 x 12次',
      calories: 70,
      completed: false
    },
    {
      id: 4,
      name: '卷腹',
      image: 'https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwZW9wbGUlMjB3b3Jrb3V0JTIwdG9nZXRoZXIlMjBzb2NpYWx8ZW58MXx8fHwxNzU5NTMyOTgwfDA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '10分钟',
      reps: '4组 x 20次',
      calories: 75,
      completed: false
    },
    {
      id: 5,
      name: '波比跳',
      image: 'https://images.unsplash.com/photo-1756115484694-009466dbaa67?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dHxlbnwxfHx8fDE3NTk0NjYwNjZ8MA&ixlib=rb-4.1.0&q=80&w=1080',
      duration: '12分钟',
      reps: '3组 x 10次',
      calories: 75,
      completed: false
    }
  ];

  const timeProgress = (todayGoals.completedTime / todayGoals.totalTime) * 100;
  const caloriesProgress = (todayGoals.burnedCalories / todayGoals.targetCalories) * 100;
  const exercisesProgress = (todayGoals.completedExercises / todayGoals.totalExercises) * 100;

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center space-x-3">
          <button
            onClick={onBack}
            className={`w-10 h-10 ${isIOS ? 'bg-gray-100 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-900" />
          </button>
          <div>
            <h1 className="text-xl text-gray-900">今日训练详情</h1>
            <p className="text-sm text-gray-500">高效减脂计划</p>
          </div>
        </div>
      </div>

      <div className="px-4 py-6 space-y-6">
        {/* Today Goals Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className={`bg-gradient-to-br from-primary to-purple-600 ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} p-6 text-white shadow-lg`}
        >
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg">今日目标</h2>
            <Target className="w-6 h-6" />
          </div>
          
          <p className="text-sm opacity-90 mb-6">💪 适合您当前目标的计划，高效减脂</p>

          {/* Progress Indicators */}
          <div className="space-y-4">
            {/* Time Progress */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center space-x-2">
                  <Clock className="w-4 h-4" />
                  <span className="text-sm">训练时间</span>
                </div>
                <span className="text-sm">{todayGoals.completedTime}/{todayGoals.totalTime}分钟</span>
              </div>
              <div className="w-full h-2 bg-white/20 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-white rounded-full transition-all duration-500"
                  style={{ width: `${timeProgress}%` }}
                />
              </div>
            </div>

            {/* Calories Progress */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center space-x-2">
                  <Flame className="w-4 h-4" />
                  <span className="text-sm">消耗卡路里</span>
                </div>
                <span className="text-sm">{todayGoals.burnedCalories}/{todayGoals.targetCalories}卡</span>
              </div>
              <div className="w-full h-2 bg-white/20 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-white rounded-full transition-all duration-500"
                  style={{ width: `${caloriesProgress}%` }}
                />
              </div>
            </div>

            {/* Exercises Progress */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center space-x-2">
                  <CheckCircle className="w-4 h-4" />
                  <span className="text-sm">完成动作</span>
                </div>
                <span className="text-sm">{todayGoals.completedExercises}/{todayGoals.totalExercises}个</span>
              </div>
              <div className="w-full h-2 bg-white/20 rounded-full overflow-hidden">
                <div 
                  className="h-full bg-white rounded-full transition-all duration-500"
                  style={{ width: `${exercisesProgress}%` }}
                />
              </div>
            </div>
          </div>
        </motion.div>

        {/* Progress Summary */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className={`bg-blue-50 border-2 border-blue-200 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4`}
        >
          <div className="flex items-start space-x-3">
            <Info className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm text-blue-900">
                今日任务完成 <span className="font-semibold">{todayGoals.completedExercises}/{todayGoals.totalExercises}</span>
              </p>
              <p className="text-sm text-blue-700 mt-1">
                还差 <span className="font-semibold">{todayGoals.totalTime - todayGoals.completedTime}分钟</span> 完成目标时间！
              </p>
            </div>
          </div>
        </motion.div>

        {/* Exercises List */}
        <div>
          <h3 className="text-lg text-gray-900 mb-4">训练动作</h3>
          <div className="space-y-3">
            {exercises.map((exercise, index) => (
              <motion.div
                key={exercise.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.1 * index }}
                className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border-2 ${
                  exercise.completed ? 'border-green-200 bg-green-50/50' : 'border-gray-200'
                } overflow-hidden transition-all ${isIOS ? 'active:scale-98' : 'hover:shadow-md'}`}
              >
                <div className="flex items-center p-4 space-x-4">
                  {/* Exercise Image */}
                  <div className="relative flex-shrink-0">
                    <ImageWithFallback
                      src={exercise.image}
                      alt={exercise.name}
                      className={`w-20 h-20 object-cover ${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
                    />
                    {exercise.completed && (
                      <div className="absolute -top-2 -right-2 w-6 h-6 bg-green-500 rounded-full flex items-center justify-center shadow-lg">
                        <CheckCircle className="w-4 h-4 text-white" />
                      </div>
                    )}
                  </div>

                  {/* Exercise Info */}
                  <div className="flex-1 min-w-0">
                    <h4 className="text-gray-900 mb-1">{exercise.name}</h4>
                    <div className="flex items-center space-x-3 text-sm text-gray-600">
                      <div className="flex items-center space-x-1">
                        <Clock className="w-3 h-3" />
                        <span>{exercise.duration}</span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Target className="w-3 h-3" />
                        <span>{exercise.reps}</span>
                      </div>
                      <div className="flex items-center space-x-1">
                        <Flame className="w-3 h-3" />
                        <span>{exercise.calories}卡</span>
                      </div>
                    </div>
                  </div>

                  {/* Action Button */}
                  {!exercise.completed && (
                    <button
                      onClick={() => onStartExercise?.(exercise.id)}
                      className={`px-4 py-2 bg-primary text-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} flex items-center space-x-2 transition-all ${
                        isIOS ? 'active:scale-95' : 'hover:bg-primary/90'
                      } shadow-sm`}
                    >
                      <Play className="w-4 h-4" />
                      <span className="text-sm">开始</span>
                    </button>
                  )}
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Add Exercise Button */}
        <button
          onClick={onAddExercise}
          className={`w-full py-4 border-2 border-dashed border-gray-300 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center space-x-2 text-gray-600 transition-all ${
            isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50 hover:border-primary hover:text-primary'
          }`}
        >
          <Plus className="w-5 h-5" />
          <span>添加新动作</span>
        </button>

        {/* Bottom Actions */}
        <div className="flex space-x-3">
          <button
            className={`flex-1 py-4 border-2 border-gray-300 text-gray-700 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} transition-all ${
              isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50'
            }`}
          >
            保存计划
          </button>
          <button
            className={`flex-1 py-4 bg-gradient-to-r from-primary to-purple-600 text-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} transition-all ${
              isIOS ? 'active:scale-95' : 'hover:shadow-lg'
            } shadow-md`}
          >
            完成训练
          </button>
        </div>
      </div>
    </div>
  );
}
