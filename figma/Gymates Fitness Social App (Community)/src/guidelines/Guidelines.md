# Gymates App Guidelines

## Performance Optimization
- Components are memoized to prevent unnecessary re-renders
- useCallback and useMemo are used for expensive operations
- Image loading is optimized with fallback handling

## Design System
- Primary color: #6366F1 (Indigo-500)
- Background: #F9FAFB / #FFFFFF
- Text colors: #1F2937 (primary), #6B7280 (secondary)
- Spacing: 16px page margins, 8/12/16px component spacing
- Border radius: 12px cards, 8px buttons, 50% avatars
- iOS style: rounded-2xl (16px) for cards, rounded-xl (12px) for buttons
- Android style: rounded-xl (12px) for cards, rounded-lg (8px) for buttons

## Component Structure
- Modular component architecture
- Consistent naming conventions
- Props interface definitions
- Error handling for images and API calls

## Responsive Design
- Mobile-first approach
- iOS: 375x812px, Android: 360x800px
- Flexible layouts for different screen sizes
- Touch-friendly interactive elements

## Animation Guidelines
- Smooth page transitions using Motion (motion/react)
- Tab switching animations
- Button interaction feedback (scale transform)
- Modal sliding animations from bottom
- Filter panel slides up from bottom with spring animation

## Feature Updates (Nov 2025)

### Community Page
- **4 Tabs**: 关注 (Following), 推荐 (Recommended), 附近 (Nearby), 挑战 (Challenge)
- **Nearby Tab Features**:
  - Shows posts from nearby users with distance information
  - Advanced filtering: distance (1-20km), gender, fitness goals
  - Filter button appears only in Nearby tab
  - Location-based social experience

### Messages Page
- **2 Tabs**: 聊天 (Chats), 通知 (Notifications)
- **Notifications Tab Features**:
  - System notifications (training reminders, achievements)
  - Match notifications (new matches from partner feature)
  - Social notifications (likes, comments, follows)
  - Challenge updates
  - Badge count on tab for unread notifications
  - Rich notification cards with avatars and icons
  - Action buttons for quick responses

### New Components
- `FilterBar.tsx`: Advanced filtering panel for nearby feed
- `NearbyFeedList.tsx`: Location-based feed with user profiles
- `NotificationList.tsx`: Comprehensive notification center

## Training Module Updates (Nov 2025)

### New Training Pages
All training pages support iOS and Android dual themes with smooth animations and modern design.

#### 1. TrainingDetailPage
- **Purpose**: Display daily training plan details
- **Features**:
  - Progress tracking (time, calories, exercises completed)
  - Exercise list with start/completion status
  - Real-time progress bars
  - Add custom exercises
  - Save and complete training actions

#### 2. ExerciseSelectionPage
- **Purpose**: Browse and select exercises
- **Features**:
  - Search and filter exercises (type, difficulty, muscle group)
  - Category tabs with icons
  - Recommended exercises carousel
  - Favorite exercises
  - Upload custom exercises modal
  - Add to plan functionality

#### 3. AITrainerPage
- **Purpose**: Real-time training guidance
- **Features**:
  - Live countdown timer
  - Exercise demonstration with GIF/video
  - Step-by-step instructions
  - AI feedback messages
  - Progress tracking (current exercise, calories, time)
  - Pause/resume controls
  - Animated gradient background
  - Real-time stats display

#### 4. CustomPlanPage
- **Purpose**: Create personalized training plans
- **Features**:
  - User goal display (type, frequency, duration)
  - AI recommendations
  - Drag-and-drop exercise ordering
  - Inline editing (duration, sets, reps)
  - Exercise categorization (warm-up, strength, core, cardio, cooldown)
  - Quick add from favorites
  - Plan summary and save

#### 5. ExerciseDetailPage
- **Purpose**: Detailed exercise information
- **Features**:
  - Video/GIF demonstration with controls
  - Exercise rating and reviews
  - Stats display (duration, calories, difficulty)
  - Adjustable reps counter
  - Step-by-step instructions with emojis
  - Tips and warnings with color coding
  - Benefits grid
  - Animated wave background
  - Favorite and start training actions

### Design Patterns
- **Gradient Backgrounds**: Used for headers and important cards (primary to purple)
- **Animated Elements**: Motion library for smooth transitions and interactions
- **Color Coding**: Category-based colors (warm-up: green, strength: blue, core: purple, cardio: orange, cooldown: teal)
- **Interactive Controls**: Video playback, counters, drag handles
- **Real-time Feedback**: AI messages, progress bars, timers
- **Emoji Integration**: Visual enhancement for steps, tips, and categories