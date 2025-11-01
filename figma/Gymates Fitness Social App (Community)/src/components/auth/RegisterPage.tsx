import React, { useState } from 'react';
import { motion } from 'motion/react';
import { User, Calendar, Ruler, Weight, Target, Sparkles, Heart, Activity } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function RegisterPage() {
  const { theme, setAuthState } = useTheme();
  const [formData, setFormData] = useState({
    fullName: '',
    gender: '',
    dateOfBirth: '',
    height: '',
    weight: '',
    goal: ''
  });

  const isIOS = theme === 'ios';

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmit = () => {
    if (formData.fullName && formData.gender && formData.dateOfBirth && 
        formData.height && formData.weight && formData.goal) {
      setAuthState('onboarding');
    }
  };

  const handleLogin = () => {
    setAuthState('login');
  };

  const goals = [
    { id: 'lose-weight', label: 'Lose Weight', emoji: '🔥', color: 'from-orange-400 to-red-500' },
    { id: 'build-muscle', label: 'Build Muscle', emoji: '💪', color: 'from-blue-400 to-indigo-500' },
    { id: 'improve-fitness', label: 'Improve Fitness', emoji: '⚡', color: 'from-green-400 to-emerald-500' },
    { id: 'stay-healthy', label: 'Stay Healthy', emoji: '❤️', color: 'from-pink-400 to-rose-500' }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-purple-50 overflow-auto">
      <div className="min-h-screen flex flex-col px-6 py-8">
        {/* Logo Section */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="text-center pt-4 pb-6"
        >
          <div className={`w-16 h-16 bg-gradient-to-br from-green-400 to-blue-500 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} mx-auto mb-3 flex items-center justify-center shadow-lg`}>
            <Activity className="w-8 h-8 text-white" strokeWidth={2.5} />
          </div>
          <h1 className="text-2xl text-gray-900 mb-1">Gymates</h1>
          <p className="text-gray-600">AI-Powered Fitness Journey</p>
        </motion.div>

        {/* Main Form */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="flex-1"
        >
          <div className={`bg-white ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} shadow-xl p-6 mb-6`}>
            <div className="flex items-center justify-center space-x-2 mb-6">
              <Sparkles className="w-5 h-5 text-green-500" />
              <h2 className="text-xl text-gray-900 text-center">Create Your AI Plan</h2>
              <Heart className="w-5 h-5 text-red-500" />
            </div>

            <div className="space-y-4">
              {/* Full Name */}
              <div>
                <label className="block text-gray-700 mb-2">
                  Full Name <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="text"
                    value={formData.fullName}
                    onChange={(e) => handleInputChange('fullName', e.target.value)}
                    placeholder="Enter your full name"
                    className={`w-full pl-11 pr-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-gray-50 focus:bg-white focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all outline-none`}
                  />
                </div>
              </div>

              {/* Gender */}
              <div>
                <label className="block text-gray-700 mb-2">
                  Gender <span className="text-red-500">*</span>
                </label>
                <div className="grid grid-cols-3 gap-3">
                  {['Male', 'Female', 'Other'].map((gender) => (
                    <button
                      key={gender}
                      type="button"
                      onClick={() => handleInputChange('gender', gender)}
                      className={`py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 transition-all ${
                        formData.gender === gender
                          ? 'border-green-500 bg-green-50 text-green-700 shadow-sm'
                          : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
                      }`}
                    >
                      {gender}
                    </button>
                  ))}
                </div>
              </div>

              {/* Date of Birth */}
              <div>
                <label className="block text-gray-700 mb-2">
                  Date of Birth <span className="text-red-500">*</span>
                </label>
                <div className="relative">
                  <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="date"
                    value={formData.dateOfBirth}
                    onChange={(e) => handleInputChange('dateOfBirth', e.target.value)}
                    className={`w-full pl-11 pr-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-gray-50 focus:bg-white focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all outline-none`}
                  />
                </div>
              </div>

              {/* Height & Weight */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-gray-700 mb-2">
                    Height <span className="text-red-500">*</span>
                  </label>
                  <div className="relative">
                    <Ruler className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input
                      type="number"
                      value={formData.height}
                      onChange={(e) => handleInputChange('height', e.target.value)}
                      placeholder="cm"
                      className={`w-full pl-11 pr-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-gray-50 focus:bg-white focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all outline-none`}
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-gray-700 mb-2">
                    Weight <span className="text-red-500">*</span>
                  </label>
                  <div className="relative">
                    <Weight className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input
                      type="number"
                      value={formData.weight}
                      onChange={(e) => handleInputChange('weight', e.target.value)}
                      placeholder="kg"
                      className={`w-full pl-11 pr-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-gray-50 focus:bg-white focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all outline-none`}
                    />
                  </div>
                </div>
              </div>

              {/* Goals */}
              <div>
                <label className="block text-gray-700 mb-2">
                  Select a Goal <span className="text-red-500">*</span>
                </label>
                <div className="grid grid-cols-2 gap-3">
                  {goals.map((goal) => (
                    <motion.button
                      key={goal.id}
                      type="button"
                      whileTap={{ scale: 0.95 }}
                      onClick={() => handleInputChange('goal', goal.id)}
                      className={`p-4 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 transition-all ${
                        formData.goal === goal.id
                          ? 'border-green-500 bg-gradient-to-br ' + goal.color + ' text-white shadow-lg'
                          : 'border-gray-200 bg-white text-gray-700 hover:border-gray-300'
                      }`}
                    >
                      <div className="text-2xl mb-1">{goal.emoji}</div>
                      <div className={`text-sm ${formData.goal === goal.id ? '' : ''}`}>
                        {goal.label}
                      </div>
                    </motion.button>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="space-y-3 pb-6">
            <motion.button
              whileTap={{ scale: 0.98 }}
              onClick={handleSubmit}
              disabled={!formData.fullName || !formData.gender || !formData.dateOfBirth || 
                       !formData.height || !formData.weight || !formData.goal}
              className={`w-full py-4 ${isIOS ? 'rounded-xl' : 'rounded-lg'} transition-all ${
                (!formData.fullName || !formData.gender || !formData.dateOfBirth || 
                 !formData.height || !formData.weight || !formData.goal)
                  ? 'bg-gray-300 text-gray-500'
                  : 'bg-gradient-to-r from-green-400 to-blue-500 text-white shadow-lg hover:shadow-xl active:scale-95'
              } flex items-center justify-center space-x-2`}
            >
              <Target className="w-5 h-5" />
              <span>Create My Plan</span>
            </motion.button>

            <button
              onClick={handleLogin}
              className={`w-full py-4 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 border-gray-300 bg-white text-gray-700 hover:bg-gray-50 transition-all active:scale-95`}
            >
              Log In
            </button>
          </div>

          {/* Footer */}
          <p className="text-center text-sm text-gray-500 leading-relaxed pb-4">
            By creating an account, you agree to our
            <button className="text-green-600 underline mx-1" onClick={() => console.log('Terms')}>
              Terms of Service
            </button>
            and
            <button className="text-green-600 underline mx-1" onClick={() => console.log('Privacy')}>
              Privacy Policy
            </button>
          </p>
        </motion.div>
      </div>
    </div>
  );
}
