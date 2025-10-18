import { useState } from 'react';
import { ProfileHeader } from './profile/ProfileHeader';
import { StatsWidget } from './profile/StatsWidget';
import { FunctionCard } from './profile/FunctionCard';
import { EditProfilePage } from './profile/EditProfilePage';
import { AchievementGrid } from './training/AchievementGrid';
import { AchievementDetailPage } from './profile/AchievementDetailPage';
import { useTheme } from './context/ThemeContext';

export function ProfilePage() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [showEditProfile, setShowEditProfile] = useState(false);
  const [showAchievementDetail, setShowAchievementDetail] = useState(false);

  if (showEditProfile) {
    return <EditProfilePage onBack={() => setShowEditProfile(false)} />;
  }

  if (showAchievementDetail) {
    return <AchievementDetailPage onBack={() => setShowAchievementDetail(false)} />;
  }
  
  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      <ProfileHeader onEditProfile={() => setShowEditProfile(true)} />
      
      <div className="px-4 py-6 space-y-6">
        <StatsWidget />
        <AchievementGrid onViewDetails={() => setShowAchievementDetail(true)} />
        <FunctionCard />
      </div>
    </div>
  );
}