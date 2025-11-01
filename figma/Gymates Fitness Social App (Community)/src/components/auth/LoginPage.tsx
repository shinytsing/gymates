import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Activity, Mail, Lock, Eye, EyeOff, Sparkles, ArrowRight } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { ImageWithFallback } from '../figma/ImageWithFallback';

export function LoginPage() {
  const { theme, setAuthState } = useTheme();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [showPassword, setShowPassword] = useState(false);

  const isIOS = theme === 'ios';

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleLogin = () => {
    if (formData.email && formData.password) {
      setAuthState('authenticated');
    }
  };

  const handleRegister = () => {
    setAuthState('register');
  };

  return (
    <div className="min-h-screen relative overflow-hidden bg-gradient-to-br from-green-50 via-blue-50 to-purple-50">
      {/* Hero Image Section */}
      <div className="relative h-[45vh] overflow-hidden">
        <div className="absolute inset-0">
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1669989179336-b2234d2878df?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwd29ya291dCUyMG1vdGl2YXRpb258ZW58MXx8fHwxNzYxOTMxMTg1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
            alt="Fitness motivation"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-transparent via-green-900/20 to-green-50" />
        </div>

        {/* Logo & Brand */}
        <motion.div
          initial={{ opacity: 0, y: -30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="relative z-10 h-full flex flex-col justify-center items-center px-6"
        >
          <div className={`w-20 h-20 bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} mb-4 flex items-center justify-center shadow-2xl`}>
            <Activity className="w-10 h-10 text-green-500" strokeWidth={2.5} />
          </div>
          <h1 className="text-4xl text-white drop-shadow-lg mb-2">Gymates</h1>
          <div className="flex items-center space-x-2">
            <Sparkles className="w-4 h-4 text-yellow-300" />
            <p className="text-white/90 drop-shadow text-lg">Your AI Fitness Partner</p>
            <Sparkles className="w-4 h-4 text-yellow-300" />
          </div>
        </motion.div>
      </div>

      {/* Login Form Section */}
      <motion.div
        initial={{ opacity: 0, y: 50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.3 }}
        className="relative px-6 -mt-8"
      >
        <div className={`bg-white ${isIOS ? 'rounded-3xl' : 'rounded-2xl'} shadow-2xl p-6 mb-6`}>
          <h2 className="text-2xl text-gray-900 mb-2 text-center">Welcome Back!</h2>
          <p className="text-gray-600 text-center mb-6">Continue your fitness journey</p>

          <div className="space-y-4">
            {/* Email */}
            <div>
              <label className="block text-gray-700 mb-2">Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => handleInputChange('email', e.target.value)}
                  placeholder="Enter your email"
                  className={`w-full pl-11 pr-4 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-gray-50 focus:bg-white focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all outline-none`}
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="block text-gray-700 mb-2">Password</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={formData.password}
                  onChange={(e) => handleInputChange('password', e.target.value)}
                  placeholder="Enter your password"
                  className={`w-full pl-11 pr-12 py-3 border border-gray-200 ${isIOS ? 'rounded-xl' : 'rounded-lg'} bg-gray-50 focus:bg-white focus:border-green-500 focus:ring-2 focus:ring-green-100 transition-all outline-none`}
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

            {/* Forgot Password */}
            <div className="text-right">
              <button className="text-green-600 text-sm hover:underline">
                Forgot Password?
              </button>
            </div>

            {/* Login Button */}
            <motion.button
              whileTap={{ scale: 0.98 }}
              onClick={handleLogin}
              disabled={!formData.email || !formData.password}
              className={`w-full py-4 ${isIOS ? 'rounded-xl' : 'rounded-lg'} transition-all ${
                (!formData.email || !formData.password)
                  ? 'bg-gray-300 text-gray-500'
                  : 'bg-gradient-to-r from-green-400 to-blue-500 text-white shadow-lg hover:shadow-xl active:scale-95'
              } flex items-center justify-center space-x-2`}
            >
              <span>Log In</span>
              <ArrowRight className="w-5 h-5" />
            </motion.button>
          </div>

          {/* Divider */}
          <div className="flex items-center my-6">
            <div className="flex-1 border-t border-gray-200"></div>
            <span className="px-4 text-gray-400 text-sm">OR</span>
            <div className="flex-1 border-t border-gray-200"></div>
          </div>

          {/* Social Login Options */}
          <div className="space-y-3">
            <button className={`w-full py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 border-gray-200 bg-white hover:bg-gray-50 transition-all flex items-center justify-center space-x-2`}>
              <div className="w-5 h-5 bg-gradient-to-br from-blue-400 to-blue-600 rounded-full"></div>
              <span className="text-gray-700">Continue with Apple</span>
            </button>
            <button className={`w-full py-3 ${isIOS ? 'rounded-xl' : 'rounded-lg'} border-2 border-gray-200 bg-white hover:bg-gray-50 transition-all flex items-center justify-center space-x-2`}>
              <div className="w-5 h-5 bg-green-500 rounded-full"></div>
              <span className="text-gray-700">Continue with WeChat</span>
            </button>
          </div>
        </div>

        {/* Register Link */}
        <div className="text-center pb-8">
          <p className="text-gray-600">
            Don't have an account?{' '}
            <button
              onClick={handleRegister}
              className="text-green-600 hover:underline"
            >
              Create Your Free AI Plan
            </button>
          </p>
        </div>
      </motion.div>
    </div>
  );
}
