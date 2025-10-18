import { MapPin, Star, Clock, Users, Phone, UserPlus } from 'lucide-react';
import { ImageWithFallback } from '../figma/ImageWithFallback';
import { useTheme } from '../context/ThemeContext';

export function GymList() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';

  const gyms = [
    {
      id: 1,
      name: '力美健健身中心',
      image: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjBpbnRlcmlvcnxlbnwxfHx8fDE3NTk1MzMwODB8MA&ixlib=rb-4.1.0&q=80&w=1080',
      rating: 4.8,
      reviewCount: 156,
      distance: '0.8km',
      address: '朝阳区三里屯路12号',
      openTime: '6:00-23:00',
      memberCount: 1200,
      facilities: ['游泳池', '私教', '团课'],
      price: '¥188/月',
      tags: ['高端', '设备新'],
      seekingCount: 23
    },
    {
      id: 2,
      name: '金吉鸟健身',
      image: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxneW0lMjBmaXRuZXNzJTIwZXF1aXBtZW50fGVufDF8fHx8MTc1OTUzMzA4MHww&ixlib=rb-4.1.0&q=80&w=1080',
      rating: 4.5,
      reviewCount: 89,
      distance: '1.2km',
      address: '海淀区中关村大街38号',
      openTime: '6:30-22:30',
      memberCount: 800,
      facilities: ['器械区', '有氧区', '瑜伽室'],
      price: '¥128/月',
      tags: ['性价比高', '教练专业'],
      seekingCount: 15
    },
    {
      id: 3,
      name: '超级猩猩健身',
      image: 'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwY2xhc3MlMjBncm91cHxlbnwxfHx8fDE3NTk1MzMwODB8MA&ixlib=rb-4.1.0&q=80&w=1080',
      rating: 4.6,
      reviewCount: 203,
      distance: '2.1km',
      address: '东城区王府井大街88号',
      openTime: '7:00-22:00',
      memberCount: 600,
      facilities: ['团课', '拳击', '蹦床'],
      price: '¥168/月',
      tags: ['团课丰富', '环境好'],
      seekingCount: 31
    }
  ];

  return (
    <div className={`bg-white rounded-${isIOS ? '3xl' : '2xl'} p-4 mb-6 border border-gray-200`}>
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <MapPin className="w-5 h-5 text-primary" />
          <h3 className={`text-lg ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>附近健身房</h3>
        </div>
        <button className="text-sm text-primary">查看地图</button>
      </div>

      {/* Gym List */}
      <div className="space-y-4">
        {gyms.map((gym) => (
          <div
            key={gym.id}
            className={`border border-gray-200 rounded-${isIOS ? '2xl' : 'xl'} overflow-hidden ${
              isIOS ? 'active:scale-95' : 'hover:shadow-md'
            } transition-all`}
          >
            {/* Gym Image */}
            <div className="relative h-32">
              <ImageWithFallback
                src={gym.image}
                alt={gym.name}
                className="w-full h-full object-cover"
              />
              <div className="absolute top-2 right-2 bg-white/90 backdrop-blur-sm rounded-full px-2 py-1">
                <span className="text-xs text-gray-700">{gym.distance}</span>
              </div>
            </div>

            {/* Gym Info */}
            <div className="p-4">
              <div className="flex items-start justify-between mb-2">
                <div>
                  <h4 className={`${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900 mb-1`}>
                    {gym.name}
                  </h4>
                  <div className="flex items-center space-x-1 mb-1">
                    <Star className="w-4 h-4 text-yellow-500 fill-current" />
                    <span className="text-sm text-gray-900">{gym.rating}</span>
                    <span className="text-sm text-gray-500">({gym.reviewCount}条评价)</span>
                  </div>
                  <p className="text-sm text-gray-600">{gym.address}</p>
                </div>
                <div className="text-right">
                  <p className={`${isIOS ? 'font-semibold' : 'font-medium'} text-primary mb-1`}>
                    {gym.price}
                  </p>
                </div>
              </div>

              {/* Facilities */}
              <div className="flex flex-wrap gap-1 mb-3">
                {gym.facilities.map((facility, index) => (
                  <span
                    key={index}
                    className="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full"
                  >
                    {facility}
                  </span>
                ))}
              </div>

              {/* Additional Info */}
              <div className="flex items-center justify-between text-sm text-gray-600 mb-3">
                <div className="flex items-center space-x-1">
                  <Clock className="w-4 h-4" />
                  <span>{gym.openTime}</span>
                </div>
                <div className="flex items-center space-x-1">
                  <Users className="w-4 h-4" />
                  <span>{gym.memberCount}+会员</span>
                </div>
              </div>

              {/* Seeking Count */}
              <div className="flex items-center space-x-2 mb-3">
                <div className="bg-orange-100 rounded-full px-3 py-1">
                  <span className="text-orange-600 text-xs">
                    🔥 {gym.seekingCount}人想练
                  </span>
                </div>
              </div>

              {/* Tags */}
              <div className="flex items-center justify-between mb-3">
                <div className="flex space-x-1">
                  {gym.tags.map((tag, index) => (
                    <span
                      key={index}
                      className="px-2 py-1 bg-primary/10 text-primary text-xs rounded-full"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
                <button className="flex items-center space-x-1 text-primary text-sm">
                  <Phone className="w-4 h-4" />
                  <span>咨询</span>
                </button>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-2">
                <button className={`flex-1 bg-primary/10 text-primary py-2 px-3 rounded-${isIOS ? 'xl' : 'lg'} flex items-center justify-center space-x-1 text-sm ${isIOS ? 'active:scale-95' : 'hover:bg-primary/20'} transition-all`}>
                  <UserPlus className="w-4 h-4" />
                  <span>求搭</span>
                </button>
                <button className={`flex-1 bg-primary text-white py-2 px-3 rounded-${isIOS ? 'xl' : 'lg'} text-sm ${isIOS ? 'active:scale-95' : 'hover:bg-primary/90'} transition-all`}>
                  查看详情
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* View More Button */}
      <button className={`w-full mt-4 py-3 border border-gray-300 rounded-${isIOS ? 'xl' : 'lg'} text-gray-700 ${
        isIOS ? 'active:bg-gray-50' : 'hover:bg-gray-50'
      } transition-colors`}>
        查看更多健身房
      </button>
    </div>
  );
}