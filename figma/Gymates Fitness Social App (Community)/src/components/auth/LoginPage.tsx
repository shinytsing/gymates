import React, { useState } from 'react';
import { motion } from 'motion/react';
import { Apple, MessageSquare, Smartphone, Eye, EyeOff } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

export function LoginPage() {
  const { theme, setAuthState } = useTheme();
  const [phoneNumber, setPhoneNumber] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [agreedToTerms, setAgreedToTerms] = useState(false);

  const isIOS = theme === 'ios';

  const handleQuickLogin = () => {
    setAuthState('register');
  };

  const handlePhoneLogin = () => {
    setAuthState('register');
  };

  const handleSocialLogin = (provider: string) => {
    console.log(`${provider} login`);
    setAuthState('register');
  };

  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Background Image */}
      <div 
        className="absolute inset-0 bg-cover bg-center bg-no-repeat"
        style={{
          backgroundImage: 'url(https://images.unsplash.com/photo-1738523686534-7055df5858d6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwY291cGxlJTIwd29ya291dCUyMHRvZ2V0aGVyfGVufDF8fHx8MTc1OTYzOTc0NHww&ixlib=rb-4.1.0&q=80&w=1080)'
        }}
      >
        <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent" />
      </div>

      {/* Content */}
      <div className="relative z-10 min-h-screen flex flex-col">
        {/* Status Bar */}
        <div className="text-white text-sm px-6 pt-2 flex justify-between items-center">
          <span>09:49</span>
          <div className="flex items-center space-x-1">
            <div className="w-4 h-2 border border-white rounded-sm opacity-80">
              <div className="w-2 h-full bg-white rounded-sm" />
            </div>
            <span className="text-xs">47</span>
          </div>
        </div>

        {/* Brand Section */}
        <div className="flex-1 flex flex-col justify-center items-center px-8">
          <motion.div
            initial={{ opacity: 0, y: -30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center mb-12"
          >
            {/* App Icon */}
            <div className={`w-20 h-20 ${isIOS ? 'bg-white' : 'bg-primary'} rounded-${isIOS ? '2xl' : 'xl'} mb-6 mx-auto flex items-center justify-center shadow-lg`}>
              <div className={`text-2xl ${isIOS ? 'text-primary' : 'text-white'}`}>💪</div>
            </div>
            
            {/* App Name */}
            <h1 className="text-3xl text-white mb-2">Gymates</h1>
            <p className="text-white/80 text-lg">寻找你的健身搭子</p>
          </motion.div>

          {/* Phone Display */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 0.3 }}
            className="mb-8"
          >
            <div className="text-center">
              <div className="text-white text-xl mb-2">166****3484</div>
              <div className="text-white/70 text-sm">认证服务由中国联通通信提供</div>
            </div>
          </motion.div>
        </div>

        {/* Login Section */}
        <motion.div
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.5 }}
          className="px-8 pb-12"
        >
          {/* Quick Login Button */}
          <button
            onClick={handleQuickLogin}
            className={`w-full py-2.5 rounded-${isIOS ? 'xl' : 'lg'} mb-4 transition-all duration-200 ${
              isIOS 
                ? 'bg-white text-black font-medium shadow-lg active:scale-95'
                : 'bg-green-500 text-white shadow-lg hover:bg-green-600 active:scale-95'
            }`}
          >
            一键登录
          </button>

          {/* Alternative Login */}
          <button
            onClick={handlePhoneLogin}
            className="w-full py-3 text-white/90 text-center mb-6 active:text-white"
          >
            其他手机号登录
          </button>

          {/* Terms Agreement */}
          <div className="flex items-start space-x-3 mb-6">
            <button
              onClick={() => setAgreedToTerms(!agreedToTerms)}
              className={`w-5 h-5 mt-0.5 rounded border-2 border-white/50 flex items-center justify-center ${
                agreedToTerms ? (isIOS ? 'bg-white' : 'bg-primary border-primary') : ''
              }`}
            >
              {agreedToTerms && (
                <div className={`w-2 h-2 ${isIOS ? 'bg-primary' : 'bg-white'} rounded-sm`} />
              )}
            </button>
            <div className="text-white/80 text-sm leading-5">
              已阅读并同意
              <button className="text-white underline mx-1" onClick={() => console.log('服务协议')}>
                《服务协议》
              </button>
              、
              <button className="text-white underline mx-1" onClick={() => console.log('隐私政策')}>
                《用户隐私政策》
              </button>
              和
              <button className="text-white underline mx-1" onClick={() => console.log('信息共享清单')}>
                《第三方信息共享清单》
              </button>
            </div>
          </div>

          {/* Social Login */}
          <div className="flex justify-center space-x-8">
            <button
              onClick={() => handleSocialLogin('apple')}
              className={`w-12 h-12 ${isIOS ? 'bg-white/20' : 'bg-black/30'} rounded-full flex items-center justify-center backdrop-blur-sm active:scale-95 transition-transform`}
            >
              <Apple className="w-6 h-6 text-white" />
            </button>
            <button
              onClick={() => handleSocialLogin('wechat')}
              className={`w-12 h-12 ${isIOS ? 'bg-white/20' : 'bg-green-600/80'} rounded-full flex items-center justify-center backdrop-blur-sm active:scale-95 transition-transform`}
            >
              <MessageSquare className="w-6 h-6 text-white" />
            </button>
          </div>
        </motion.div>
      </div>
    </div>
  );
}