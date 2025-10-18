import React, { useState } from 'react';
import { ArrowLeft, Camera, Save } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { useTheme } from '../context/ThemeContext';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Textarea } from '../ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';

interface EditProfilePageProps {
  onBack: () => void;
}

export function EditProfilePage({ onBack }: EditProfilePageProps) {
  const { theme, user, setUser } = useTheme();
  const isIOS = theme === 'ios';

  const [formData, setFormData] = useState({
    name: user?.name || '健身爱好者',
    bio: '坚持就是胜利 💪',
    height: user?.height || 170,
    weight: user?.weight || 65,
    experience: user?.experience || '1-2年',
    goal: user?.goal || '增肌',
    workoutTypes: ['力量训练', '有氧运动'],
    workoutTimes: ['晚上 7-9点'],
    location: '北京市朝阳区'
  });

  const handleSave = () => {
    // 更新用户信息
    if (user) {
      setUser({
        ...user,
        name: formData.name,
        height: formData.height,
        weight: formData.weight,
        experience: formData.experience,
        goal: formData.goal
      });
    }
    onBack();
  };

  const handleInputChange = (field: string, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'}`}>
      {/* Header */}
      <div className={`bg-white px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <button
              onClick={onBack}
              className={`w-10 h-10 rounded-full flex items-center justify-center ${
                isIOS ? 'bg-gray-100 active:scale-95' : 'bg-gray-100 hover:bg-gray-200'
              } transition-all`}
            >
              <ArrowLeft className="w-5 h-5 text-gray-600" />
            </button>
            <h1 className={`text-xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>
              编辑资料
            </h1>
          </div>
          <Button
            onClick={handleSave}
            className={`px-4 py-2 ${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
          >
            <Save className="w-4 h-4 mr-2" />
            保存
          </Button>
        </div>
      </div>

      <div className="px-4 py-6 space-y-6">
        {/* Avatar Section */}
        <div className="flex flex-col items-center space-y-4">
          <div className="relative">
            <ImageWithFallback
              src="https://images.unsplash.com/photo-1704726135027-9c6f034cfa41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx1c2VyJTIwcHJvZmlsZSUyMGF2YXRhcnxlbnwxfHx8fDE3NTk1MjI5MTl8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
              alt="Profile"
              className="w-24 h-24 rounded-full object-cover"
            />
            <button className="absolute -bottom-2 -right-2 w-8 h-8 bg-primary rounded-full flex items-center justify-center shadow-lg">
              <Camera className="w-4 h-4 text-white" />
            </button>
          </div>
          <p className="text-sm text-gray-600">点击更换头像</p>
        </div>

        {/* Basic Info */}
        <div className={`bg-white rounded-${isIOS ? 'xl' : 'lg'} p-4 space-y-4`}>
          <h3 className="font-medium text-gray-900 mb-3">基本信息</h3>
          
          <div className="space-y-2">
            <Label htmlFor="name">昵称</Label>
            <Input
              id="name"
              value={formData.name}
              onChange={(e) => handleInputChange('name', e.target.value)}
              className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="bio">个人简介</Label>
            <Textarea
              id="bio"
              value={formData.bio}
              onChange={(e) => handleInputChange('bio', e.target.value)}
              className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
              rows={3}
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="location">所在地区</Label>
            <Input
              id="location"
              value={formData.location}
              onChange={(e) => handleInputChange('location', e.target.value)}
              className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
            />
          </div>
        </div>

        {/* Physical Info */}
        <div className={`bg-white rounded-${isIOS ? 'xl' : 'lg'} p-4 space-y-4`}>
          <h3 className="font-medium text-gray-900 mb-3">身体数据</h3>
          
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="height">身高 (cm)</Label>
              <Input
                id="height"
                type="number"
                value={formData.height}
                onChange={(e) => handleInputChange('height', parseInt(e.target.value) || 0)}
                className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="weight">体重 (kg)</Label>
              <Input
                id="weight"
                type="number"
                value={formData.weight}
                onChange={(e) => handleInputChange('weight', parseInt(e.target.value) || 0)}
                className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}
              />
            </div>
          </div>
        </div>

        {/* Fitness Info */}
        <div className={`bg-white rounded-${isIOS ? 'xl' : 'lg'} p-4 space-y-4`}>
          <h3 className="font-medium text-gray-900 mb-3">健身信息</h3>
          
          <div className="space-y-2">
            <Label htmlFor="experience">运动年限</Label>
            <Select value={formData.experience} onValueChange={(value) => handleInputChange('experience', value)}>
              <SelectTrigger className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="新手">新手</SelectItem>
                <SelectItem value="1-2年">1-2年</SelectItem>
                <SelectItem value="2-3年">2-3年</SelectItem>
                <SelectItem value="3年以上">3年以上</SelectItem>
                <SelectItem value="5年以上">5年以上</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="goal">训练目标</Label>
            <Select value={formData.goal} onValueChange={(value) => handleInputChange('goal', value)}>
              <SelectTrigger className={`${isIOS ? 'rounded-xl' : 'rounded-lg'}`}>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="减脂">减脂</SelectItem>
                <SelectItem value="增肌">增肌</SelectItem>
                <SelectItem value="塑形">塑形</SelectItem>
                <SelectItem value="提升耐力">提升耐力</SelectItem>
                <SelectItem value="保持健康">保持健康</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Workout Types */}
          <div className="space-y-3">
            <Label>运动类型</Label>
            <div className="flex flex-wrap gap-2">
              {['力量训练', '有氧运动', '瑜伽', '跑步', '游泳', '骑行', '篮球', '羽毛球'].map((type) => (
                <button
                  key={type}
                  onClick={() => {
                    const newTypes = formData.workoutTypes.includes(type)
                      ? formData.workoutTypes.filter(t => t !== type)
                      : [...formData.workoutTypes, type];
                    handleInputChange('workoutTypes', newTypes);
                  }}
                  className={`px-3 py-1 rounded-full text-sm transition-colors ${
                    formData.workoutTypes.includes(type)
                      ? 'bg-primary text-white'
                      : isIOS
                      ? 'bg-gray-100 text-gray-700 active:bg-gray-200'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {type}
                </button>
              ))}
            </div>
          </div>

          {/* Workout Times */}
          <div className="space-y-3">
            <Label>运动时间</Label>
            <div className="flex flex-wrap gap-2">
              {['早晨 6-8点', '上午 9-11点', '下午 2-4点', '傍晚 5-7点', '晚上 7-9点', '晚上 9-11点'].map((time) => (
                <button
                  key={time}
                  onClick={() => {
                    const newTimes = formData.workoutTimes.includes(time)
                      ? formData.workoutTimes.filter(t => t !== time)
                      : [...formData.workoutTimes, time];
                    handleInputChange('workoutTimes', newTimes);
                  }}
                  className={`px-3 py-1 rounded-full text-sm transition-colors ${
                    formData.workoutTimes.includes(time)
                      ? 'bg-primary text-white'
                      : isIOS
                      ? 'bg-gray-100 text-gray-700 active:bg-gray-200'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {time}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* 底部安全间距 */}
        <div className="h-20" />
      </div>
    </div>
  );
}