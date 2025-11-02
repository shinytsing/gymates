# Gymates Flutter Frontend Architecture

## 📁 Project Structure

```
lib/
├── main.dart                          # Application entry point
│
├── modules/                           # Feature modules (NEW)
│   ├── auth/                          # Authentication module
│   │   ├── widgets/                   # Auth-specific widgets
│   │   │   ├── login_form.dart
│   │   │   ├── register_form.dart
│   │   │   └── social_login_buttons.dart
│   │   ├── services/                  # Auth business logic
│   │   │   └── auth_service.dart
│   │   ├── models/                    # Auth data models
│   │   │   └── auth_models.dart
│   │   └── screens/                   # Auth screens
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── onboarding_screen.dart
│   │
│   ├── community/                     # Community/Social module
│   │   ├── widgets/                   # Community widgets
│   │   │   ├── post_card.dart
│   │   │   ├── comment_item.dart
│   │   │   └── create_post_form.dart
│   │   ├── services/                  # Community business logic
│   │   │   └── community_service.dart
│   │   ├── models/                    # Community models
│   │   │   └── post_models.dart
│   │   └── screens/                   # Community screens
│   │       ├── community_screen.dart
│   │       ├── post_detail_screen.dart
│   │       └── create_post_screen.dart
│   │
│   ├── training/                      # Training module
│   │   ├── widgets/                   # Training widgets
│   │   │   ├── exercise_card.dart
│   │   │   ├── workout_timer.dart
│   │   │   └── progress_chart.dart
│   │   ├── services/                  # Training business logic
│   │   │   ├── training_service.dart
│   │   │   └── workout_session_service.dart
│   │   ├── models/                    # Training models
│   │   │   ├── training_plan.dart
│   │   │   └── exercise.dart
│   │   └── screens/                   # Training screens
│   │       ├── training_home_screen.dart
│   │       ├── workout_detail_screen.dart
│   │       └── workout_running_screen.dart
│   │
│   ├── mates/                         # Mate matching module
│   │   ├── widgets/                   # Mate widgets
│   │   │   ├── mate_card.dart
│   │   │   └── match_filter.dart
│   │   ├── services/                  # Mate business logic
│   │   │   └── mate_service.dart
│   │   ├── models/                    # Mate models
│   │   │   └── mate_models.dart
│   │   └── screens/                   # Mate screens
│   │       ├── mates_screen.dart
│   │       └── mate_detail_screen.dart
│   │
│   ├── messages/                      # Messaging module
│   │   ├── widgets/                   # Message widgets
│   │   │   ├── conversation_tile.dart
│   │   │   └── message_bubble.dart
│   │   ├── services/                  # Message business logic
│   │   │   ├── message_service.dart
│   │   │   └── websocket_service.dart
│   │   ├── models/                    # Message models
│   │   │   └── message_models.dart
│   │   └── screens/                   # Message screens
│   │       ├── messages_screen.dart
│   │       └── chat_room_screen.dart
│   │
│   └── profile/                       # Profile module
│       ├── widgets/                   # Profile widgets
│       │   ├── profile_header.dart
│       │   ├── achievement_card.dart
│       │   └── stats_widget.dart
│       ├── services/                  # Profile business logic
│       │   └── profile_service.dart
│       ├── models/                    # Profile models
│       │   └── user_models.dart
│       └── screens/                   # Profile screens
│           ├── profile_screen.dart
│           └── edit_profile_screen.dart
│
├── shared/                            # Shared resources (NEW)
│   ├── widgets/                       # Reusable widgets
│   │   ├── buttons/                   # Button components
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   └── icon_button.dart
│   │   ├── cards/                     # Card components
│   │   │   ├── base_card.dart
│   │   │   └── gradient_card.dart
│   │   ├── inputs/                    # Input components
│   │   │   ├── text_field.dart
│   │   │   └── search_bar.dart
│   │   ├── navigation/                # Navigation components
│   │   │   ├── bottom_nav_bar.dart
│   │   │   └── app_drawer.dart
│   │   └── loading/                   # Loading components
│   │       ├── loading_indicator.dart
│   │       └── skeleton_loader.dart
│   │
│   ├── services/                      # Shared services
│   │   ├── api_service.dart           # Base API client
│   │   ├── storage_service.dart       # Local storage
│   │   └── notification_service.dart  # Push notifications
│   │
│   ├── models/                        # Shared models
│   │   ├── api_response.dart          # API response wrapper
│   │   └── pagination.dart            # Pagination model
│   │
│   ├── utils/                         # Utility functions
│   │   ├── validators.dart            # Form validators
│   │   ├── formatters.dart            # Data formatters
│   │   └── constants.dart             # App constants
│   │
│   └── theme/                         # Theme configuration
│       ├── app_theme.dart             # Main theme
│       ├── colors.dart                # Color palette
│       ├── typography.dart            # Text styles
│       └── dimensions.dart            # Size constants
│
├── core/                              # Core functionality
│   ├── config/                        # App configuration
│   │   └── api_config.dart
│   ├── navigation/                    # Navigation configuration
│   │   └── app_router.dart
│   └── token_manager.dart             # Token management
│
├── pages/                             # Legacy pages (being phased out)
│   └── *.dart                         # Old page files (backward compatibility)
│
├── services/                          # Legacy services (being phased out)
│   └── *.dart                         # Old service files
│
├── models/                            # Legacy models (being phased out)
│   └── *.dart                         # Old model files
│
└── routes/                            # Route definitions
    └── app_routes.dart                # Central route configuration
```

## 🏗️ Architecture Pattern: Feature-Based Modules

### Module Structure
Each feature module is self-contained with:
- **screens/**: Page-level UI components
- **widgets/**: Reusable UI components specific to the module
- **services/**: Business logic and API calls for the module
- **models/**: Data models specific to the module

### Shared Resources
Common components, services, and utilities are placed in `shared/`:
- **widgets/**: Reusable UI components across all modules
- **services/**: Cross-cutting services (API, storage, etc.)
- **models/**: Common data structures
- **utils/**: Helper functions and utilities
- **theme/**: Consistent styling and theming

## 🔄 Data Flow

```
User Interaction
    ↓
Screen Widget (Stateful)
    ↓
Service Layer (Business Logic)
    ↓
API Service (HTTP Client)
    ↓
Backend API
    ↓
Response Processing
    ↓
Model Parsing
    ↓
State Update (setState/Provider)
    ↓
UI Rebuild
```

## 🎨 Design System

### Theme Structure
```dart
// Centralized theme in shared/theme/
AppTheme
  ├── Colors (gradient palettes, semantic colors)
  ├── Typography (font families, sizes, weights)
  ├── Spacing (margins, padding, gaps)
  ├── Borders (radius, width)
  └── Shadows (elevation styles)
```

### Component Library
```
shared/widgets/
  ├── buttons/      # GymatesButton, OutlinedButton, TextButton
  ├── cards/        # GradientCard, GlassCard, InfoCard
  ├── inputs/       # GymatesTextField, SearchField
  ├── navigation/   # BottomNavBar, TabBar, Drawer
  └── loading/      # Spinner, Skeleton, Progress
```

## 📡 API Integration

### Service Layer Pattern
```dart
// Module-specific service
class CommunityService {
  final ApiService _apiService;
  
  Future<List<Post>> getPosts({int page = 1, int limit = 10}) async {
    final response = await _apiService.get('/api/community/posts', 
      queryParameters: {'page': page, 'limit': limit}
    );
    return response.data.map((json) => Post.fromJson(json)).toList();
  }
}

// Shared API service
class ApiService {
  final Dio _dio;
  final TokenManager _tokenManager;
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final headers = await _tokenManager.getAuthHeaders();
    return _dio.get(path, 
      queryParameters: queryParameters,
      options: Options(headers: headers)
    );
  }
}
```

## 🔐 State Management

### Riverpod Providers
```dart
// User state provider
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

// Posts provider
final postsProvider = FutureProvider.autoDispose.family<List<Post>, int>(
  (ref, page) async {
    final communityService = ref.read(communityServiceProvider);
    return communityService.getPosts(page: page);
  }
);
```

## 🧪 Testing Strategy

### Unit Tests
- Test services and business logic
- Test model parsing and serialization
- Test utility functions

### Widget Tests
- Test individual widgets
- Test user interactions
- Test state changes

### Integration Tests
- Test complete user flows
- Test API integration
- Test navigation

## 🚀 Running the Application

### Development
```bash
# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run with specific flavor
flutter run --flavor dev
```

### Build
```bash
# Build for iOS
flutter build ios

# Build for Android
flutter build apk

# Build for release
flutter build appbundle
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

## 📝 Coding Conventions

### File Naming
- Use snake_case for file names: `auth_service.dart`, `post_card.dart`
- Match file name to main class name

### Class Naming
- Use PascalCase for class names: `AuthService`, `PostCard`
- Suffix widgets with Widget if ambiguous: `LoadingWidget`

### Widget Organization
```dart
class MyWidget extends StatelessWidget {
  // 1. Constructor
  const MyWidget({Key? key}) : super(key: key);
  
  // 2. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // 3. Private helper methods
  Widget _buildSection() {
    return Container();
  }
}
```

### Service Organization
```dart
class MyService {
  // 1. Dependencies
  final ApiService _apiService;
  
  // 2. Constructor
  MyService(this._apiService);
  
  // 3. Public methods
  Future<Result> fetchData() async { }
  
  // 4. Private methods
  void _processData() { }
}
```

## 🎯 Best Practices

1. **Single Responsibility**: Each module handles one feature domain
2. **Separation of Concerns**: UI, business logic, and data are separated
3. **Reusability**: Common components in shared folder
4. **Consistency**: Use shared theme and design system
5. **Error Handling**: Consistent error handling across all services
6. **Loading States**: Show appropriate loading indicators
7. **Offline Support**: Cache data when possible
8. **Accessibility**: Support screen readers and large fonts

## 🔄 Migration from Old Structure

### Completed
✅ Created modular folder structure for features
✅ Identified all feature modules
✅ Created shared components directory

### In Progress
🔄 Moving existing pages to module structure
🔄 Extracting shared widgets from pages
🔄 Consolidating theme files

### Future
⏳ Complete migration of all pages
⏳ Create comprehensive component library
⏳ Add widget documentation
⏳ Implement state management with Riverpod
⏳ Add comprehensive tests

## 🎨 UI/UX Guidelines

### Figma Design Fidelity
- All screens must match Figma designs exactly
- Use exact colors, spacing, and typography from design system
- Maintain consistent gradient backgrounds
- Follow rounded corner and shadow specifications

### Responsive Design
- Support both iOS (375x812) and Android (360x800)
- Use responsive sizing (MediaQuery, LayoutBuilder)
- Test on different screen sizes
- Handle safe areas properly

### Animations
- Page transitions: 300ms with easeInOut curve
- Button press: Scale down to 0.95 with 150ms duration
- Loading states: Smooth skeleton animations
- List items: Stagger animation on appearance

## 📚 Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  dio: ^5.3.0                   # HTTP client
  go_router: ^12.0.0            # Routing
  shared_preferences: ^2.2.0    # Local storage
  cached_network_image: ^3.3.0  # Image caching
  flutter_svg: ^2.0.0           # SVG support
  intl: ^0.18.0                 # Internationalization
```

## 🔐 Security

- ✅ Secure token storage (FlutterSecureStorage)
- ✅ HTTPS-only API calls
- ✅ Input validation on all forms
- ✅ Secure user session management
- ✅ Biometric authentication support (optional)

## 📱 Platform Considerations

### iOS
- Follow iOS Human Interface Guidelines
- Support Face ID / Touch ID
- Handle safe areas (notch, home indicator)
- Use iOS-specific transitions

### Android
- Follow Material Design guidelines
- Support fingerprint authentication
- Handle back button navigation
- Use Android-specific transitions

## 🌐 Internationalization (Future)

```dart
// Prepare for i18n
AppLocalizations.of(context).translate('login.title')

// Supported languages
- English (en)
- Chinese (zh)
```

This architecture ensures a scalable, maintainable, and testable Flutter application that aligns with modern development practices and perfectly replicates the Figma design.

