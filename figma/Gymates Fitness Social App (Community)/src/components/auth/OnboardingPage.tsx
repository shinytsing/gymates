import React, { useState } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { ArrowLeft, ArrowRight, User, Ruler, Weight, Calendar, Target, TrendingUp, Info, Sparkles, Heart } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function OnboardingPage() {
  const { theme, setAuthState, setUser } = useTheme();
  const [currentStep, setCurrentStep] = useState(0);
  const [profileData, setProfileData] = useState({
    height: '',
    weight: '',
    experience: '',
    goal: '',
    avatar: '',
    name: '健身新手' // 从注册页面传来
  });

  const isIOS = theme === 'ios';

  const steps = [
    {
      title: '基本信息',
      subtitle: '让我们了解您的身体状况和运动经验',
      icon: User,
      content: 'basic',
      bgColor: 'bg-gradient-to-br from-blue-500 to-cyan-500',
      emoji: '📋'
    },
    {
      title: '健身目标',
      subtitle: '您希望达成什么目标？',
      icon: Target,
      content: 'goal',
      bgColor: 'bg-gradient-to-br from-purple-500 to-pink-500',
      emoji: '🎯'
    }
  ];

  const experienceOptions = [
    { 
      id: 'beginner', 
      label: '初学者', 
      desc: '刚开始健身', 
      value: '0-6个月',
      emoji: '🌱',
      color: 'from-green-400 to-emerald-500'
    },
    { 
      id: 'intermediate', 
      label: '进阶者', 
      desc: '有一定基础', 
      value: '6个月-2年',
      emoji: '🔥',
      color: 'from-orange-400 to-red-500'
    },
    { 
      id: 'advanced', 
      label: '高手', 
      desc: '经验丰富', 
      value: '2年以上',
      emoji: '💎',
      color: 'from-purple-400 to-indigo-500'
    }
  ];

  const goalOptions = [
    { 
      id: 'lose_weight', 
      label: '减脂', 
      desc: '减少体脂率', 
      icon: '🔥',
      gradient: 'from-red-400 to-orange-500'
    },
    { 
      id: 'gain_muscle', 
      label: '增肌', 
      desc: '增加肌肉量', 
      icon: '💪',
      gradient: 'from-blue-400 to-cyan-500'
    },
    { 
      id: 'shape', 
      label: '塑形', 
      desc: '塑造身材线条', 
      icon: '✨',
      gradient: 'from-purple-400 to-pink-500'
    },
    { 
      id: 'health', 
      label: '保持健康', 
      desc: '维持良好状态', 
      icon: '❤️',
      gradient: 'from-green-400 to-emerald-500'
    }
  ];

  const calculateBMI = () => {
    const h = parseFloat(profileData.height) / 100; // 转换为米
    const w = parseFloat(profileData.weight);
    if (h > 0 && w > 0) {
      return (w / (h * h)).toFixed(1);
    }
    return null;
  };

  const getBMIStatus = (bmi: string) => {
    const value = parseFloat(bmi);
    if (value < 18.5) return { status: '偏瘦', color: 'text-blue-600', bgColor: 'bg-blue-50' };
    if (value < 24) return { status: '正常', color: 'text-green-600', bgColor: 'bg-green-50' };
    if (value < 28) return { status: '超重', color: 'text-orange-600', bgColor: 'bg-orange-50' };
    return { status: '肥胖', color: 'text-red-600', bgColor: 'bg-red-50' };
  };

  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      // 完成注册流程
      const bmi = calculateBMI();
      setUser({
        id: Date.now().toString(),
        name: profileData.name,
        phone: '186****1234',
        height: parseFloat(profileData.height),
        weight: parseFloat(profileData.weight),
        experience: profileData.experience,
        goal: profileData.goal,
        bmi: bmi ? parseFloat(bmi) : undefined
      });
      setAuthState('authenticated');
    }
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    } else {
      setAuthState('register');
    }
  };

  const isStepValid = () => {
    switch (currentStep) {
      case 0:
        return profileData.height && profileData.weight && profileData.experience;
      case 1:
        return profileData.goal;
      default:
        return false;
    }
  };

  const renderStepContent = () => {
    const step = steps[currentStep];
    
    switch (step.content) {
      case 'basic':
        return (
          <div className="space-y-8">
            {/* 身体数据部分 */}
            <div className="space-y-6">
              <div className="flex items-center space-x-2 mb-4">
                <div className="w-8 h-8 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
                  <Ruler className="w-4 h-4 text-white" />
                </div>
                <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>身体数据</h3>
              </div>
              
              {/* Height */}
              <div>
                <label className={`block text-gray-700 mb-3 ${isIOS ? 'font-medium' : ''} flex items-center space-x-2`}>
                  <Ruler className="w-5 h-5 text-blue-500" />
                  <span>身高 (cm) *</span>
                </label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-2xl">📏</div>
                  <input
                    type="number"
                    value={profileData.height}
                    onChange={(e) => setProfileData(prev => ({ ...prev, height: e.target.value }))}
                    placeholder="170"
                    className={`w-full pl-12 pr-4 py-4 border-2 rounded-${isIOS ? 'xl' : 'lg'} text-lg ${
                      isIOS 
                        ? 'border-blue-200 bg-blue-50/30 focus:border-blue-500 focus:ring-0 focus:bg-white' 
                        : 'border-blue-200 bg-blue-50/30 focus:border-blue-500 focus:ring-1 focus:ring-blue-500/20 focus:bg-white'
                    } transition-all`}
                  />
                </div>
              </div>

              {/* Weight */}
              <div>
                <label className={`block text-gray-700 mb-3 ${isIOS ? 'font-medium' : ''} flex items-center space-x-2`}>
                  <Weight className="w-5 h-5 text-green-500" />
                  <span>体重 (kg) *</span>
                </label>
                <div className="relative">
                  <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-2xl">⚖️</div>
                  <input
                    type="number"
                    value={profileData.weight}
                    onChange={(e) => setProfileData(prev => ({ ...prev, weight: e.target.value }))}
                    placeholder="65"
                    className={`w-full pl-12 pr-4 py-4 border-2 rounded-${isIOS ? 'xl' : 'lg'} text-lg ${
                      isIOS 
                        ? 'border-green-200 bg-green-50/30 focus:border-green-500 focus:ring-0 focus:bg-white' 
                        : 'border-green-200 bg-green-50/30 focus:border-green-500 focus:ring-1 focus:ring-green-500/20 focus:bg-white'
                    } transition-all`}
                  />
                </div>
              </div>

              {/* BMI Display */}
              {profileData.height && profileData.weight && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className={`p-4 rounded-${isIOS ? 'xl' : 'lg'} ${getBMIStatus(calculateBMI()!).bgColor} border-2 border-opacity-20`}
                >
                  <div className="flex items-center space-x-2 mb-2">
                    <Info className="w-5 h-5 text-indigo-600" />
                    <span className="font-medium text-gray-900">BMI 计算结果</span>
                    <Sparkles className="w-4 h-4 text-yellow-500" />
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-3xl font-bold text-gray-900">{calculateBMI()}</span>
                    <div className="text-right">
                      <span className={`${getBMIStatus(calculateBMI()!).color} font-semibold text-lg`}>
                        {getBMIStatus(calculateBMI()!).status}
                      </span>
                      <p className="text-sm text-gray-600">
                        健康参考指标
                      </p>
                    </div>
                  </div>
                </motion.div>
              )}
            </div>

            {/* 分隔线 */}
            <div className="flex items-center">
              <div className="flex-1 border-t border-gray-200"></div>
              <div className="px-4 text-sm text-gray-500">运动经验</div>
              <div className="flex-1 border-t border-gray-200"></div>
            </div>

            {/* 运动经验部分 */}
            <div className="space-y-4">
              <div className="flex items-center space-x-2 mb-4">
                <div className="w-8 h-8 bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center">
                  <Calendar className="w-4 h-4 text-white" />
                </div>
                <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>运动经验</h3>
              </div>
              
              {experienceOptions.map((option, index) => (
                <motion.button
                  key={option.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.1 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setProfileData(prev => ({ ...prev, experience: option.value }))}
                  className={`w-full p-4 rounded-${isIOS ? 'xl' : 'lg'} border-2 transition-all ${
                    profileData.experience === option.value
                      ? isIOS
                        ? `border-primary bg-gradient-to-r ${option.color} text-white shadow-lg`
                        : `border-primary bg-gradient-to-r ${option.color} text-white shadow-lg`
                      : 'border-gray-200 bg-white hover:border-gray-300 hover:shadow-md'
                  }`}
                >
                  <div className="flex items-center space-x-4">
                    <div className="text-3xl">{option.emoji}</div>
                    <div className="text-left flex-1">
                      <div className={`${isIOS ? 'font-semibold' : 'font-medium'} ${
                        profileData.experience === option.value ? 'text-white' : 'text-gray-900'
                      } mb-1`}>
                        {option.label}
                      </div>
                      <div className={`text-sm ${
                        profileData.experience === option.value ? 'text-white/90' : 'text-gray-500'
                      }`}>
                        {option.desc}
                      </div>
                      <div className={`text-xs ${
                        profileData.experience === option.value ? 'text-white/75' : 'text-gray-400'
                      } mt-1`}>
                        {option.value}
                      </div>
                    </div>
                  </div>
                </motion.button>
              ))}
            </div>
          </div>
        );



      case 'goal':
        return (
          <div className="grid grid-cols-2 gap-4">
            {goalOptions.map((option, index) => (
              <motion.button
                key={option.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => setProfileData(prev => ({ ...prev, goal: option.label }))}
                className={`p-6 rounded-${isIOS ? 'xl' : 'lg'} border-2 transition-all ${
                  profileData.goal === option.label
                    ? isIOS
                      ? `border-primary bg-gradient-to-br ${option.gradient} text-white shadow-lg`
                      : `border-primary bg-gradient-to-br ${option.gradient} text-white shadow-lg`
                    : 'border-gray-200 bg-white hover:border-gray-300 hover:shadow-md'
                }`}
              >
                <div className="text-center">
                  <div className="text-4xl mb-3">{option.icon}</div>
                  <div className={`${isIOS ? 'font-semibold' : 'font-medium'} ${
                    profileData.goal === option.label ? 'text-white' : 'text-gray-900'
                  } mb-1`}>
                    {option.label}
                  </div>
                  <div className={`text-xs ${
                    profileData.goal === option.label ? 'text-white/90' : 'text-gray-500'
                  }`}>
                    {option.desc}
                  </div>
                </div>
              </motion.button>
            ))}
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'}`}>
      {/* Header */}
      <div className={`${isIOS ? 'bg-white' : 'bg-white'} px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
        <div className="flex items-center justify-between">
          <button
            onClick={handleBack}
            className={`w-10 h-10 rounded-full flex items-center justify-center ${
              isIOS ? 'hover:bg-gray-100' : 'hover:bg-gray-50'
            } active:scale-95 transition-all`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          
          <div className="text-center">
            <h1 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
              完善资料
            </h1>
            <p className="text-sm text-gray-500">{currentStep + 1} / {steps.length}</p>
          </div>
          
          <div className="w-10" />
        </div>

        {/* Progress Bar */}
        <div className="mt-4">
          <div className={`h-2 bg-gray-200 rounded-full overflow-hidden ${isIOS ? '' : ''}`}>
            <motion.div
              className="h-full bg-gradient-to-r from-primary to-purple-500"
              initial={{ width: 0 }}
              animate={{ width: `${((currentStep + 1) / steps.length) * 100}%` }}
              transition={{ duration: 0.3 }}
            />
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="px-6 py-8">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentStep}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.3 }}
          >
            {/* Step Header */}
            <div className="text-center mb-8">
              <div className={`w-16 h-16 ${steps[currentStep].bgColor} rounded-${isIOS ? '2xl' : 'xl'} mx-auto mb-4 flex items-center justify-center shadow-lg`}>
                <div className="text-3xl">{steps[currentStep].emoji}</div>
              </div>
              <h2 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-2`}>
                {steps[currentStep].title}
              </h2>
              <div className="flex items-center justify-center space-x-2 text-gray-600">
                <Sparkles className="w-4 h-4 text-yellow-500" />
                <p>{steps[currentStep].subtitle}</p>
                <Heart className="w-4 h-4 text-red-500" />
              </div>
            </div>

            {/* Step Content */}
            <div className="mb-8">
              {renderStepContent()}
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom Actions */}
      <div className="fixed bottom-0 left-0 right-0 p-6 bg-white border-t border-gray-200">
        <div className="max-w-md mx-auto">
          <motion.button
            whileTap={{ scale: 0.98 }}
            onClick={handleNext}
            disabled={!isStepValid()}
            className={`w-full py-3 rounded-${isIOS ? 'xl' : 'lg'} transition-all flex items-center justify-center space-x-2 ${
              !isStepValid()
                ? 'bg-gray-300 text-gray-500'
                : isIOS
                  ? 'bg-gradient-to-r from-primary to-purple-600 text-white shadow-lg'
                  : 'bg-gradient-to-r from-primary to-purple-600 text-white shadow-lg hover:shadow-xl'
            } ${isIOS ? 'font-semibold' : 'font-medium'}`}
          >
            <span>{currentStep === steps.length - 1 ? '完成注册' : '下一步'}</span>
            <ArrowRight className="w-5 h-5" />
          </motion.button>
        </div>
      </div>
    </div>
  );
}