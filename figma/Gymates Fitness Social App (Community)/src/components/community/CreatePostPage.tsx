import React, { useState, useCallback } from 'react';
import { ArrowLeft, Camera, MapPin, Smile, Hash } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';

interface CreatePostPageProps {
  postType: string;
  onBack: () => void;
  onPublish: (content: any) => void;
}

export const CreatePostPage = React.memo(function CreatePostPage({ 
  postType, 
  onBack, 
  onPublish 
}: CreatePostPageProps) {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [content, setContent] = useState('');
  const [selectedImages, setSelectedImages] = useState<string[]>([]);

  const getPageTitle = useCallback(() => {
    switch (postType) {
      case 'workout':
        return '发布训练';
      case 'nutrition':
        return '发布饮食';
      case 'moment':
        return '发布动态';
      case 'photo':
        return '发布照片';
      default:
        return '发布内容';
    }
  }, [postType]);

  const getPlaceholderText = useCallback(() => {
    switch (postType) {
      case 'workout':
        return '分享你的训练内容，动作、组数、重量...';
      case 'nutrition':
        return '分享你的健康饮食，食谱、营养搭配...';
      case 'moment':
        return '分享你的健身感悟，今天的心情...';
      case 'photo':
        return '为你的照片添加一些描述...';
      default:
        return '说点什么...';
    }
  }, [postType]);

  const handlePublish = useCallback(() => {
    if (content.trim() || selectedImages.length > 0) {
      onPublish({
        type: postType,
        content: content.trim(),
        images: selectedImages,
        timestamp: new Date().toISOString()
      });
    }
  }, [content, selectedImages, postType, onPublish]);

  const canPublish = content.trim().length > 0 || selectedImages.length > 0;

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className={`bg-white px-4 py-4 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'} sticky top-0 z-10`}>
        <div className="flex items-center justify-between">
          <button
            onClick={onBack}
            className={`w-10 h-10 ${isIOS ? 'bg-gray-100 rounded-full' : 'bg-gray-100 rounded-lg'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}
          >
            <ArrowLeft className="w-5 h-5 text-gray-600" />
          </button>
          
          <h1 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
            {getPageTitle()}
          </h1>
          
          <button
            onClick={handlePublish}
            disabled={!canPublish}
            className={`px-4 py-2 ${isIOS ? 'rounded-2xl' : 'rounded-lg'} ${
              canPublish 
                ? 'bg-primary text-white' 
                : 'bg-gray-200 text-gray-400'
            } ${isIOS ? 'font-semibold' : 'font-medium'} ${isIOS ? 'active:scale-95' : 'hover:opacity-90'} transition-all`}
          >
            发布
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="p-4 space-y-6">
        {/* Text Input */}
        <div className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 border border-gray-200`}>
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder={getPlaceholderText()}
            className="w-full h-32 resize-none bg-transparent border-none outline-none placeholder-gray-400 text-gray-900"
            maxLength={500}
          />
          <div className="flex justify-between items-center mt-4 pt-4 border-t border-gray-100">
            <div className="flex space-x-3">
              <button className={`w-8 h-8 bg-gray-100 ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
                <Camera className="w-4 h-4 text-gray-600" />
              </button>
              <button className={`w-8 h-8 bg-gray-100 ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
                <MapPin className="w-4 h-4 text-gray-600" />
              </button>
              <button className={`w-8 h-8 bg-gray-100 ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
                <Smile className="w-4 h-4 text-gray-600" />
              </button>
              <button className={`w-8 h-8 bg-gray-100 ${isIOS ? 'rounded-full' : 'rounded-lg'} flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
                <Hash className="w-4 h-4 text-gray-600" />
              </button>
            </div>
            <span className="text-sm text-gray-400">
              {content.length}/500
            </span>
          </div>
        </div>

        {/* Post Type Specific Content */}
        {postType === 'workout' && (
          <div className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 border border-gray-200`}>
            <h3 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-4`}>训练详情</h3>
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-gray-600">训练时长</span>
                <span className="text-gray-900">45分钟</span>
              </div>
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-gray-600">消耗卡路里</span>
                <span className="text-gray-900">320 kcal</span>
              </div>
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                <span className="text-gray-600">训练部位</span>
                <span className="text-gray-900">胸部</span>
              </div>
            </div>
          </div>
        )}

        {postType === 'nutrition' && (
          <div className={`bg-white ${isIOS ? 'rounded-2xl' : 'rounded-xl'} p-4 border border-gray-200`}>
            <h3 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-4`}>营养信息</h3>
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 bg-gray-50 rounded-lg text-center">
                <div className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>450</div>
                <div className="text-sm text-gray-600">卡路里</div>
              </div>
              <div className="p-3 bg-gray-50 rounded-lg text-center">
                <div className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>35g</div>
                <div className="text-sm text-gray-600">蛋白质</div>
              </div>
              <div className="p-3 bg-gray-50 rounded-lg text-center">
                <div className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>45g</div>
                <div className="text-sm text-gray-600">碳水</div>
              </div>
              <div className="p-3 bg-gray-50 rounded-lg text-center">
                <div className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>15g</div>
                <div className="text-sm text-gray-600">脂肪</div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
});