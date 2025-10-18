import { Play, Clock, Target } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';

export function TodayPlanCard() {
  return (
    <div className="bg-gradient-to-r from-primary to-purple-600 rounded-xl p-6 text-white mb-6">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-xl mb-1">今日训练计划</h3>
          <p className="text-primary-foreground/80">上肢力量训练</p>
        </div>
        <div className="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center">
          <Play className="w-8 h-8" />
        </div>
      </div>
      
      <div className="flex items-center space-x-6 mb-4">
        <div className="flex items-center space-x-2">
          <Clock className="w-4 h-4" />
          <span className="text-sm">45分钟</span>
        </div>
        <div className="flex items-center space-x-2">
          <Target className="w-4 h-4" />
          <span className="text-sm">5个动作</span>
        </div>
      </div>

      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <div className="w-2 h-2 bg-white rounded-full"></div>
          <div className="w-2 h-2 bg-white/50 rounded-full"></div>
          <div className="w-2 h-2 bg-white/50 rounded-full"></div>
          <div className="w-2 h-2 bg-white/50 rounded-full"></div>
          <div className="w-2 h-2 bg-white/50 rounded-full"></div>
        </div>
        <button className="bg-white text-primary px-4 py-2 rounded-lg">
          开始训练
        </button>
      </div>
    </div>
  );
}