import { Edit3, Settings } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { useTheme } from '../context/ThemeContext';

interface ProfileHeaderProps {
  onEditProfile: () => void;
}

export function ProfileHeader({ onEditProfile }: ProfileHeaderProps) {
  const { theme, user } = useTheme();
  const isIOS = theme === 'ios';
  
  return (
    <div className={`bg-white px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
      <div className="flex items-center justify-between mb-6">
        <h1 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>我的</h1>
        <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
          <Settings className="w-5 h-5 text-gray-600" />
        </button>
      </div>

      {/* Profile Info */}
      <div className="flex items-center space-x-4 mb-6">
        <div className="relative">
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
            alt="Profile"
            className="w-20 h-20 rounded-full object-cover"
          />
          <button className="absolute -bottom-1 -right-1 w-6 h-6 bg-primary rounded-full flex items-center justify-center">
            <Edit3 className="w-3 h-3 text-white" />
          </button>
        </div>
        
        <div className="flex-1">
          <h2 className="text-xl text-gray-900 mb-1">健身爱好者</h2>
          <p className="text-gray-600 mb-3">坚持就是胜利 💪</p>
          
          <div className="flex space-x-6">
            <div className="text-center">
              <p className="text-xl text-gray-900">156</p>
              <p className="text-sm text-gray-600">关注</p>
            </div>
            <div className="text-center">
              <p className="text-xl text-gray-900">1.2k</p>
              <p className="text-sm text-gray-600">粉丝</p>
            </div>
            <div className="text-center">
              <p className="text-xl text-gray-900">89</p>
              <p className="text-sm text-gray-600">动态</p>
            </div>
          </div>
        </div>
      </div>

      <button 
        onClick={onEditProfile}
        className={`w-full bg-primary text-white py-3 ${isIOS ? 'rounded-xl font-semibold' : 'rounded-lg font-medium'} ${
          isIOS ? 'active:scale-98' : 'hover:bg-primary/90'
        } transition-all`}
      >
        编辑资料
      </button>
    </div>
  );
}