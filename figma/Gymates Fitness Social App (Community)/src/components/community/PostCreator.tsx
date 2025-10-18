import React, { useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Camera, Dumbbell, Apple, PenTool, X, Image } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface PostCreatorProps {
  onCreatePost?: (type: string) => void;
  onNavigateToCreate?: (type: string) => void;
}

export const PostCreator = React.memo(function PostCreator({ onCreatePost, onNavigateToCreate }: PostCreatorProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [showExpanded, setShowExpanded] = useState(false);

  const handleShowExpanded = useCallback(() => {
    setShowExpanded(true);
  }, []);

  const handleCloseExpanded = useCallback(() => {
    setShowExpanded(false);
  }, []);

  const handleCreatePost = useCallback((type: string) => {
    onCreatePost?.(type);
    onNavigateToCreate?.(type);
    setShowExpanded(false);
  }, [onCreatePost, onNavigateToCreate]);

  const postTypes = [
    { 
      id: 'workout', 
      icon: Dumbbell, 
      label: '发布训练', 
      description: '分享你的训练记录和成果',
      color: 'bg-blue-500',
      lightBg: 'bg-blue-50',
      textColor: 'text-blue-600'
    },
    { 
      id: 'nutrition', 
      icon: Apple, 
      label: '发布饮食', 
      description: '分享健康饮食和营养搭配',
      color: 'bg-green-500',
      lightBg: 'bg-green-50',
      textColor: 'text-green-600'
    },
    { 
      id: 'moment', 
      icon: PenTool, 
      label: '发布动态', 
      description: '分享健身日常和生活感悟',
      color: 'bg-purple-500',
      lightBg: 'bg-purple-50',
      textColor: 'text-purple-600'
    },
    { 
      id: 'photo', 
      icon: Camera, 
      label: '发布照片', 
      description: '展示你的健身变化和成果',
      color: 'bg-orange-500',
      lightBg: 'bg-orange-50',
      textColor: 'text-orange-600'
    }
  ];

  return (
    <>
      {/* Simple Post Creator Card */}
      <div 
        className={`bg-white ${isIOS ? 'rounded-2xl shadow-sm' : 'rounded-xl shadow-sm'} border border-gray-200 p-4 mb-6`}
      >
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
            <PenTool className="w-5 h-5 text-gray-500" />
          </div>
          <button
            onClick={handleShowExpanded}
            className={`flex-1 bg-gray-100 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} px-4 py-3 text-left text-gray-500 ${isIOS ? 'active:scale-98' : 'hover:bg-gray-200'} transition-all`}
          >
            分享你的健身动态...
          </button>
          <button
            onClick={handleShowExpanded}
            className={`w-10 h-10 bg-primary ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-primary/90'} transition-all`}
          >
            <Image className="w-5 h-5 text-white" />
          </button>
        </div>
      </div>

      {/* Expanded Post Creator Modal */}
      <AnimatePresence>
        {showExpanded && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black bg-opacity-50 z-40"
              onClick={handleCloseExpanded}
            />
            <motion.div
              initial={{ opacity: 0, y: '100%' }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="fixed inset-x-0 bottom-0 z-50"
            >
              <div className={`bg-white ${isIOS ? 'rounded-t-3xl' : 'rounded-t-2xl'} ${isIOS ? 'shadow-2xl' : 'shadow-xl'} max-h-[80vh] overflow-y-auto`}>
                {/* Handle bar for iOS */}
                {isIOS && (
                  <div className="flex justify-center pt-3 pb-2">
                    <div className="w-10 h-1 bg-gray-300 rounded-full" />
                  </div>
                )}
                
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-gray-100">
                  <h2 className={`text-xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
                    发布内容
                  </h2>
                  <button
                    onClick={handleCloseExpanded}
                    className={`w-8 h-8 ${isIOS ? 'bg-gray-100 rounded-full' : 'bg-gray-100 rounded-lg'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}
                  >
                    <X className="w-4 h-4 text-gray-600" />
                  </button>
                </div>

                {/* Post Type Options */}
                <div className="p-6 space-y-4">
                  {postTypes.map((type, index) => (
                    <motion.button
                      key={type.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.1 }}
                      onClick={() => handleCreatePost(type.id)}
                      className={`w-full flex items-center space-x-4 p-4 ${isIOS ? 'rounded-2xl' : 'rounded-xl'} ${isIOS ? 'active:scale-98' : 'hover:bg-gray-50'} transition-all border border-gray-100`}
                    >
                      <div className={`w-12 h-12 ${type.color} ${isIOS ? 'rounded-2xl' : 'rounded-xl'} flex items-center justify-center`}>
                        <type.icon className="w-6 h-6 text-white" />
                      </div>
                      <div className="flex-1 text-left">
                        <div className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-1`}>
                          {type.label}
                        </div>
                        <div className="text-sm text-gray-500">
                          {type.description}
                        </div>
                      </div>
                      <div className={`w-8 h-8 ${type.lightBg} ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center`}>
                        <div className={`w-2 h-2 ${type.color} rounded-full`} />
                      </div>
                    </motion.button>
                  ))}
                </div>

                {/* Bottom Safe Area */}
                <div className="h-8" />
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
});