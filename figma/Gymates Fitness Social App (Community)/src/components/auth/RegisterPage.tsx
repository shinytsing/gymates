import React, { useState } from 'react';
import { motion } from 'motion/react';
import { ArrowLeft, User, Phone, Mail, Eye, EyeOff, Sparkles, Heart, Target } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function RegisterPage() {
  const { theme, setAuthState } = useTheme();
  const [formData, setFormData] = useState({
    nickname: '',
    name: '',
    phone: '',
    email: '',
    gender: '',
    password: '',
    confirmPassword: ''
  });
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const isIOS = theme === 'ios';

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = () => {
    if (formData.nickname && formData.name && formData.phone && formData.gender) {
      setAuthState('onboarding');
    }
  };

  const handleBack = () => {
    setAuthState('login');
  };

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'}`}>
      {/* Header */}
      <div className={`${isIOS ? 'bg-white' : 'bg-white'} px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
        <div className="flex items-center">
          <button
            onClick={handleBack}
            className={`w-10 h-10 rounded-full flex items-center justify-center ${
              isIOS ? 'hover:bg-gray-100' : 'hover:bg-gray-50'
            } active:scale-95 transition-all`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          <h1 className={`ml-4 text-xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
            注册账号
          </h1>
        </div>
      </div>

      {/* Content */}
      <div className="px-6 py-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          {/* Brand */}
          <div className="text-center mb-8">
            <div className={`w-16 h-16 bg-gradient-to-br from-primary to-purple-600 rounded-${isIOS ? '2xl' : 'xl'} mx-auto mb-4 flex items-center justify-center shadow-lg`}>
              <div className="text-2xl">💪</div>
            </div>
            <h2 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-2`}>
              开始你的健身之旅
            </h2>
            <div className="flex items-center justify-center space-x-2 text-gray-600">
              <Sparkles className="w-4 h-4 text-yellow-500" />
              <p>填写基本信息，找到最适合的健身伙伴</p>
              <Heart className="w-4 h-4 text-red-500" />
            </div>
          </div>

          {/* Form */}
          <div className="space-y-5">
            {/* Nickname */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                昵称 *
              </label>
              <div className="relative">
                <Sparkles className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-yellow-500" />
                <input
                  type="text"
                  value={formData.nickname}
                  onChange={(e) => handleInputChange('nickname', e.target.value)}
                  placeholder="设置一个酷炫的昵称"
                  className={`w-full pl-10 pr-4 py-3 border rounded-${isIOS ? 'xl' : 'lg'} ${
                    isIOS 
                      ? 'border-gray-200 bg-white focus:border-primary focus:ring-0' 
                      : 'border-gray-200 bg-white focus:border-primary focus:ring-1 focus:ring-primary/20'
                  } transition-colors`}
                />
              </div>
            </div>

            {/* Gender */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                性别 *
              </label>
              <div className="grid grid-cols-2 gap-3">
                <button
                  type="button"
                  onClick={() => handleInputChange('gender', '男')}
                  className={`p-3 rounded-${isIOS ? 'xl' : 'lg'} border transition-all ${
                    formData.gender === '男'
                      ? 'border-blue-500 bg-blue-50 text-blue-700'
                      : 'border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                  }`}
                >
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-lg">🚹</span>
                    <span>男</span>
                  </div>
                </button>
                <button
                  type="button"
                  onClick={() => handleInputChange('gender', '女')}
                  className={`p-3 rounded-${isIOS ? 'xl' : 'lg'} border transition-all ${
                    formData.gender === '女'
                      ? 'border-pink-500 bg-pink-50 text-pink-700'
                      : 'border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                  }`}
                >
                  <div className="flex items-center justify-center space-x-2">
                    <span className="text-lg">🚺</span>
                    <span>女</span>
                  </div>
                </button>
              </div>
            </div>

            {/* Name */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                姓名 *
              </label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => handleInputChange('name', e.target.value)}
                  placeholder="请输入您的真实姓名"
                  className={`w-full pl-10 pr-4 py-3 border rounded-${isIOS ? 'xl' : 'lg'} ${
                    isIOS 
                      ? 'border-gray-200 bg-white focus:border-primary focus:ring-0' 
                      : 'border-gray-200 bg-white focus:border-primary focus:ring-1 focus:ring-primary/20'
                  } transition-colors`}
                />
              </div>
            </div>

            {/* Phone */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                手机号 *
              </label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => handleInputChange('phone', e.target.value)}
                  placeholder="请输入手机号"
                  className={`w-full pl-10 pr-4 py-3 border rounded-${isIOS ? 'xl' : 'lg'} ${
                    isIOS 
                      ? 'border-gray-200 bg-white focus:border-primary focus:ring-0' 
                      : 'border-gray-200 bg-white focus:border-primary focus:ring-1 focus:ring-primary/20'
                  } transition-colors`}
                />
              </div>
            </div>

            {/* Email */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                邮箱
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleInputChange('email', e.target.value)}
                  placeholder="请输入邮箱地址（可选）"
                  className={`w-full pl-10 pr-4 py-3 border rounded-${isIOS ? 'xl' : 'lg'} ${
                    isIOS 
                      ? 'border-gray-200 bg-white focus:border-primary focus:ring-0' 
                      : 'border-gray-200 bg-white focus:border-primary focus:ring-1 focus:ring-primary/20'
                  } transition-colors`}
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                密码 *
              </label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={formData.password}
                  onChange={(e) => handleInputChange('password', e.target.value)}
                  placeholder="请设置密码"
                  className={`w-full pl-4 pr-12 py-3 border rounded-${isIOS ? 'xl' : 'lg'} ${
                    isIOS 
                      ? 'border-gray-200 bg-white focus:border-primary focus:ring-0' 
                      : 'border-gray-200 bg-white focus:border-primary focus:ring-1 focus:ring-primary/20'
                  } transition-colors`}
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2"
                >
                  {showPassword ? (
                    <EyeOff className="w-5 h-5 text-gray-400" />
                  ) : (
                    <Eye className="w-5 h-5 text-gray-400" />
                  )}
                </button>
              </div>
            </div>

            {/* Confirm Password */}
            <div>
              <label className={`block text-gray-700 mb-2 ${isIOS ? 'font-medium' : ''}`}>
                确认密码 *
              </label>
              <div className="relative">
                <input
                  type={showConfirmPassword ? 'text' : 'password'}
                  value={formData.confirmPassword}
                  onChange={(e) => handleInputChange('confirmPassword', e.target.value)}
                  placeholder="请再次输入密码"
                  className={`w-full pl-4 pr-12 py-3 border rounded-${isIOS ? 'xl' : 'lg'} ${
                    isIOS 
                      ? 'border-gray-200 bg-white focus:border-primary focus:ring-0' 
                      : 'border-gray-200 bg-white focus:border-primary focus:ring-1 focus:ring-primary/20'
                  } transition-colors`}
                />
                <button
                  type="button"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                  className="absolute right-3 top-1/2 transform -translate-y-1/2"
                >
                  {showConfirmPassword ? (
                    <EyeOff className="w-5 h-5 text-gray-400" />
                  ) : (
                    <Eye className="w-5 h-5 text-gray-400" />
                  )}
                </button>
              </div>
            </div>
          </div>

          {/* Submit Button */}
          <motion.button
            whileTap={{ scale: 0.98 }}
            onClick={handleSubmit}
            disabled={!formData.nickname || !formData.name || !formData.phone || !formData.gender || !formData.password || !formData.confirmPassword}
            className={`w-full mt-8 py-3 rounded-${isIOS ? 'xl' : 'lg'} transition-all ${
              (!formData.nickname || !formData.name || !formData.phone || !formData.gender || !formData.password || !formData.confirmPassword)
                ? 'bg-gray-300 text-gray-500'
                : isIOS
                  ? 'bg-gradient-to-r from-primary to-purple-600 text-white shadow-lg'
                  : 'bg-gradient-to-r from-primary to-purple-600 text-white shadow-lg hover:shadow-xl'
            } ${isIOS ? 'font-semibold' : 'font-medium'} flex items-center justify-center space-x-2`}
          >
            <Target className="w-5 h-5" />
            <span>下一步</span>
          </motion.button>

          {/* Terms */}
          <p className="text-center text-sm text-gray-500 mt-6 leading-relaxed">
            注册即表示您同意我们的
            <button className="text-primary underline mx-1" onClick={() => console.log('服务条款')}>
              服务条款
            </button>
            和
            <button className="text-primary underline mx-1" onClick={() => console.log('隐私政策')}>
              隐私政策
            </button>
          </p>
        </motion.div>
      </div>
    </div>
  );
}