import React, { useState, useCallback, useMemo } from 'react';
import { Search, Filter, TrendingUp } from 'lucide-react';
import { FeedList } from './community/FeedList';
import { ChallengeCards } from './community/ChallengeCards';
import { PostCreator } from './community/PostCreator';
import { CreatePostPage } from './community/CreatePostPage';
import { TopicTags } from './community/TopicTags';
import { useTheme } from './context/ThemeContext';

export const CommunityPage = React.memo(function CommunityPage() {
  const { theme } = useTheme();
  const isIOS = theme === 'ios';
  const [activeTab, setActiveTab] = useState('following');
  const [showCreatePost, setShowCreatePost] = useState(false);
  const [createPostType, setCreatePostType] = useState<string>('');

  const handleTabChange = useCallback((tabId: string) => {
    setActiveTab(tabId);
  }, []);

  const handleCreatePost = useCallback((type: string) => {
    console.log('Creating post of type:', type);
  }, []);

  const handleNavigateToCreate = useCallback((type: string) => {
    setCreatePostType(type);
    setShowCreatePost(true);
  }, []);

  const handleBackFromCreate = useCallback(() => {
    setShowCreatePost(false);
    setCreatePostType('');
  }, []);

  const handlePublishPost = useCallback((postData: any) => {
    console.log('Publishing post:', postData);
    // Here you would typically send the data to your backend
    setShowCreatePost(false);
    setCreatePostType('');
  }, []);

  const tabs = useMemo(() => [
    { id: 'following', label: '关注' },
    { id: 'recommended', label: '推荐' },
    { id: 'trending', label: '热门' },
  ], []);

  // Show create post page if user is creating a post
  if (showCreatePost) {
    return (
      <CreatePostPage
        postType={createPostType}
        onBack={handleBackFromCreate}
        onPublish={handlePublishPost}
      />
    );
  }

  return (
    <div className={`min-h-screen ${isIOS ? 'bg-gray-50' : 'bg-background'} pb-20`}>
      {/* Header */}
      <div className={`bg-white px-4 py-6 border-b ${isIOS ? 'border-gray-200' : 'border-gray-200'}`}>
        <div className="flex items-center justify-between mb-4">
          <h1 className={`text-2xl ${isIOS ? 'font-semibold' : 'font-medium'} text-gray-900`}>社区</h1>
          <div className="flex items-center space-x-3">
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
              <Search className="w-5 h-5 text-gray-600" />
            </button>
            <button className={`w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center ${isIOS ? 'active:scale-95' : 'hover:bg-gray-200'} transition-all`}>
              <Filter className="w-5 h-5 text-gray-600" />
            </button>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex space-x-1 bg-gray-100 rounded-lg p-1">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => handleTabChange(tab.id)}
              className={`flex-1 py-2 px-4 rounded-md transition-colors ${
                activeTab === tab.id
                  ? 'bg-white text-primary shadow-sm'
                  : 'text-gray-600'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-6 space-y-6">
        {/* Post Creator - Always shown */}
        <PostCreator 
          onCreatePost={handleCreatePost} 
          onNavigateToCreate={handleNavigateToCreate}
        />

        {/* Following Tab - Only show feed */}
        {activeTab === 'following' && (
          <div>
            <h3 className="text-lg text-gray-900 mb-4">关注动态</h3>
            <FeedList />
          </div>
        )}

        {/* Recommended and Trending Tabs - Show full content */}
        {(activeTab === 'recommended' || activeTab === 'trending') && (
          <>
            {/* Quick Actions */}
            <div className="grid grid-cols-2 gap-4">
              <button className="bg-white rounded-xl p-4 border border-gray-200 flex flex-col items-center space-y-2">
                <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-blue-600" />
                </div>
                <span className="text-sm text-gray-900">挑战</span>
              </button>
              <button className="bg-white rounded-xl p-4 border border-gray-200 flex flex-col items-center space-y-2">
                <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                  <Search className="w-5 h-5 text-green-600" />
                </div>
                <span className="text-sm text-gray-900">找搭子</span>
              </button>
            </div>

            {/* Topics */}
            <TopicTags />

            {/* Challenges */}
            <ChallengeCards />

            {/* Feed */}
            <div>
              <h3 className="text-lg text-gray-900 mb-4">
                {activeTab === 'recommended' ? '推荐内容' : '热门动态'}
              </h3>
              <FeedList />
            </div>
          </>
        )}
      </div>
    </div>
  );
});