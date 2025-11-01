import React, { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, Target, Clock, Calendar, Plus, Trash2, Edit, Save, Sparkles, GripVertical } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface CustomPlanPageProps {
  onBack: () => void;
  onSavePlan?: (plan: any) => void;
  onBrowseExercises?: () => void;
}

export function CustomPlanPage({ onBack, onSavePlan, onBrowseExercises }: CustomPlanPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [planName, setPlanName] = useState('我的训练计划');
  const [isEditingName, setIsEditingName] = useState(false);

  const userGoal = {
    type: '减脂',
    weeklyDays: 3,
    recommendedDuration: 45
  };

  const [exercises, setExercises] = useState([
    {
      id: 1,
      name: '拉伸运动',
      category: 'warm-up',
      categoryName: '热身',
      duration: 5,
      sets: 1,
      reps: '全身',
      order: 1
    },
    {
      id: 2,
      name: '深蹲',
      category: 'strength',
      categoryName: '力量训练',
      duration: 10,
      sets: 4,
      reps: '15次',
      targetMuscle: '腿部',
      order: 2
    },
    {
      id: 3,
      name: '平板支撑',
      category: 'core',
      categoryName: '核心训练',
      duration: 5,
      sets: 3,
      reps: '60秒',
      targetMuscle: '核心',
      order: 3
    },
    {
      id: 4,
      name: '跑步',
      category: 'cardio',
      categoryName: '有氧运动',
      duration: 15,
      sets: 1,
      reps: '持续',
      order: 4
    },
    {
      id: 5,
      name: '拉伸放松',
      category: 'cooldown',
      categoryName: '放松',
      duration: 10,
      sets: 1,
      reps: '全身',
      order: 5
    }
  ]);

  const totalDuration = exercises.reduce((sum, ex) => sum + ex.duration, 0);

  const getCategoryColor = (category: string) => {
    const colors: Record<string, string> = {
      'warm-up': 'bg-green-100 text-green-700 border-green-200',
      'strength': 'bg-blue-100 text-blue-700 border-blue-200',
      'core': 'bg-purple-100 text-purple-700 border-purple-200',
      'cardio': 'bg-orange-100 text-orange-700 border-orange-200',
      'cooldown': 'bg-teal-100 text-teal-700 border-teal-200'
    };
    return colors[category] || 'bg-gray-100 text-gray-700 border-gray-200';
  };

  const handleDeleteExercise = (id: number) => {
    setExercises(exercises.filter(ex => ex.id !== id));
  };

  const handleSavePlan = () => {
    const plan = {
      name: planName,
      exercises,
      totalDuration,
      goal: userGoal
    };
    onSavePlan?.(plan);
  };

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className="bg-white px-4 py-4 border-b border-gray-200 sticky top-0 z-10">
        <div className="flex items-center justify-between mb-4">
          <button
            onClick={onBack}
            className={`w-10 h-10 ${isIOS ? 'bg-gray-100 rounded-full' : 'hover:bg-gray-100 rounded-lg'} flex items-center justify-center transition-colors`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-900" />
          </button>
          <div className="flex-1 mx-4">
            {isEditingName ? (
              <input
                type="text"
                value={planName}
                onChange={(e) => setPlanName(e.target.value)}
                onBlur={() => setIsEditingName(false)}
                autoFocus
                className="text-lg text-gray-900 border-b-2 border-primary focus:outline-none w-full"
              />
            ) : (
              <div className="flex items-center space-x-2">
                <h1 className="text-lg text-gray-900">{planName}</h1>
                <button
                  onClick={() => setIsEditingName(true)}
                  className="w-6 h-6 text-gray-400 hover:text-gray-600"
                >
                  <Edit className="w-4 h-4" />
                </button>
              </div>
            )}
            <p className="text-sm text-gray-500">自定义训练计划</p>
          </div>
          <button
            onClick={handleSavePlan}
            className={`px-4 py-2 bg-primary text-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} flex items-center space-x-2 transition-all ${
              isIOS ? 'active:scale-95' : 'hover:bg-primary/90'
            }`}
          >
            <Save className="w-4 h-4" />
            <span className="text-sm">保存</span>
          </button>
        </div>
      </div>

      <div className="px-4 py-6 space-y-6">
        {/* User Goal Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className={`bg-gradient-to-br from-primary/10 to-purple-100 border-2 border-primary/20 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-5`}
        >
          <div className="flex items-center space-x-2 mb-4">
            <Sparkles className="w-5 h-5 text-primary" />
            <h2 className="text-lg text-gray-900">您的训练目标</h2>
          </div>
          
          <div className="grid grid-cols-3 gap-4">
            <div className={`bg-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} p-3 text-center`}>
              <Target className="w-5 h-5 text-primary mx-auto mb-2" />
              <p className="text-sm text-gray-600 mb-1">目标</p>
              <p className="text-gray-900">{userGoal.type}</p>
            </div>
            <div className={`bg-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} p-3 text-center`}>
              <Calendar className="w-5 h-5 text-primary mx-auto mb-2" />
              <p className="text-sm text-gray-600 mb-1">每周</p>
              <p className="text-gray-900">{userGoal.weeklyDays}次</p>
            </div>
            <div className={`bg-white ${isIOS ? 'rounded-xl' : 'rounded-lg'} p-3 text-center`}>
              <Clock className="w-5 h-5 text-primary mx-auto mb-2" />
              <p className="text-sm text-gray-600 mb-1">时长</p>
              <p className="text-gray-900">{totalDuration}分</p>
            </div>
          </div>
        </motion.div>

        {/* AI Recommendation Banner */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className={`bg-gradient-to-r from-blue-500 to-purple-600 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 text-white`}
        >
          <div className="flex items-start space-x-3">
            <Sparkles className="w-5 h-5 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm mb-1">🤖 AI 推荐</p>
              <p className="text-xs opacity-90">
                根据您的{userGoal.type}目标，我们为您定制了这套训练计划，建议每周训练{userGoal.weeklyDays}次，每次{userGoal.recommendedDuration}分钟左右。
              </p>
            </div>
          </div>
        </motion.div>

        {/* Exercises List */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg text-gray-900">训练动作</h3>
            <span className="text-sm text-gray-500">{exercises.length}个动作</span>
          </div>

          <div className="space-y-3">
            {exercises.map((exercise, index) => (
              <motion.div
                key={exercise.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.05 }}
                className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} border border-gray-200 overflow-hidden`}
              >
                <div className="p-4">
                  <div className="flex items-start space-x-3">
                    {/* Drag Handle */}
                    <div className="pt-1">
                      <GripVertical className="w-5 h-5 text-gray-400 cursor-move" />
                    </div>

                    {/* Exercise Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center space-x-2 mb-2">
                        <span className={`inline-flex items-center justify-center w-6 h-6 ${isIOS ? 'rounded-lg' : 'rounded'} bg-primary text-white text-xs`}>
                          {exercise.order}
                        </span>
                        <h4 className="text-gray-900">{exercise.name}</h4>
                      </div>

                      <div className={`inline-flex px-2 py-1 ${isIOS ? 'rounded-lg' : 'rounded'} border text-xs mb-2 ${getCategoryColor(exercise.category)}`}>
                        {exercise.categoryName}
                      </div>

                      <div className="flex flex-wrap gap-3 text-sm text-gray-600">
                        <div className="flex items-center space-x-1">
                          <Clock className="w-4 h-4" />
                          <span>{exercise.duration}分钟</span>
                        </div>
                        {exercise.sets > 1 && (
                          <div>
                            {exercise.sets}组 × {exercise.reps}
                          </div>
                        )}
                        {exercise.targetMuscle && (
                          <div className="flex items-center space-x-1">
                            <Target className="w-4 h-4" />
                            <span>{exercise.targetMuscle}</span>
                          </div>
                        )}
                      </div>

                      {/* Inline Edit Controls */}
                      <div className="mt-3 flex items-center space-x-2">
                        <div className="flex items-center space-x-2 text-sm">
                          <span className="text-gray-600">时长:</span>
                          <input
                            type="number"
                            value={exercise.duration}
                            onChange={(e) => {
                              const newExercises = exercises.map(ex =>
                                ex.id === exercise.id ? { ...ex, duration: parseInt(e.target.value) || 0 } : ex
                              );
                              setExercises(newExercises);
                            }}
                            className={`w-16 px-2 py-1 border border-gray-200 ${isIOS ? 'rounded-lg' : 'rounded'} focus:outline-none focus:ring-2 focus:ring-primary/50`}
                          />
                          <span className="text-gray-600">分钟</span>
                        </div>
                      </div>
                    </div>

                    {/* Delete Button */}
                    <button
                      onClick={() => handleDeleteExercise(exercise.id)}
                      className={`w-8 h-8 ${isIOS ? 'bg-red-50 rounded-full' : 'hover:bg-red-50 rounded-lg'} flex items-center justify-center transition-colors text-red-600`}
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Add Exercise Button */}
        <button
          onClick={onBrowseExercises}
          className={`w-full py-4 border-2 border-dashed border-gray-300 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center space-x-2 text-gray-600 transition-all ${
            isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50 hover:border-primary hover:text-primary'
          }`}
        >
          <Plus className="w-5 h-5" />
          <span>从动作库添加</span>
        </button>

        {/* Quick Add from Favorites */}
        <div className={`bg-gray-50 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 border border-gray-200`}>
          <h4 className="text-sm text-gray-700 mb-3">快速添加收藏动作</h4>
          <div className="flex flex-wrap gap-2">
            {['俯卧撑', '卷腹', '波比跳', '引体向上'].map((name) => (
              <button
                key={name}
                className={`px-3 py-1.5 bg-white border border-gray-200 ${isIOS ? 'rounded-lg' : 'rounded'} text-sm text-gray-700 transition-colors ${
                  isIOS ? 'active:bg-primary/10' : 'hover:bg-primary/10 hover:border-primary'
                }`}
              >
                + {name}
              </button>
            ))}
          </div>
        </div>

        {/* Summary Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className={`bg-gradient-to-br from-green-50 to-blue-50 border-2 border-green-200 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-5`}
        >
          <h3 className="text-lg text-gray-900 mb-3">计划概览</h3>
          <div className="space-y-2 text-sm">
            <div className="flex items-center justify-between">
              <span className="text-gray-600">总时长</span>
              <span className="text-gray-900">{totalDuration} 分钟</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-gray-600">动作数量</span>
              <span className="text-gray-900">{exercises.length} 个</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-gray-600">预计消耗</span>
              <span className="text-orange-600">~{totalDuration * 8} 卡路里</span>
            </div>
          </div>
        </motion.div>

        {/* Action Buttons */}
        <div className="flex space-x-3">
          <button
            className={`flex-1 py-4 border-2 border-gray-300 text-gray-700 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} transition-all ${
              isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50'
            }`}
          >
            预览计划
          </button>
          <button
            onClick={handleSavePlan}
            className={`flex-1 py-4 bg-gradient-to-r from-primary to-purple-600 text-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center space-x-2 transition-all ${
              isIOS ? 'active:scale-95' : 'hover:shadow-lg'
            } shadow-md`}
          >
            <Save className="w-5 h-5" />
            <span>保存并使用</span>
          </button>
        </div>
      </div>
    </div>
  );
}
