# 🏗️ Gymates Architecture Separation Guide

## 📁 Directory Structure Rules

### Frontend (Flutter) - `/gymates_flutter/`
```
lib/
├── pages/           # UI screens only
├── widgets/         # Reusable UI components
├── services/        # API communication layer
├── models/          # Data models (Dart classes)
├── utils/           # UI utilities and helpers
├── theme/           # UI theming and styling
└── main.dart        # App entry point
```

**Allowed in Flutter:**
- ✅ UI components and widgets
- ✅ State management (Provider, Bloc, etc.)
- ✅ Navigation and routing
- ✅ Animations and transitions
- ✅ API calls through service layer
- ✅ Local storage (SharedPreferences, etc.)
- ✅ Platform-specific code (iOS/Android)

**Forbidden in Flutter:**
- ❌ Database operations
- ❌ Business logic
- ❌ Go structs or types
- ❌ Server-side computations
- ❌ Authentication logic (only UI)

### Backend (Go) - `/backend/`
```
├── controllers/     # HTTP handlers
├── models/         # Data models (Go structs)
├── routes/         # API route definitions
├── middleware/     # Authentication, CORS, etc.
├── services/       # Business logic
├── config/         # Configuration
└── main.go         # Server entry point
```

**Allowed in Go:**
- ✅ Business logic and computations
- ✅ Database operations
- ✅ Authentication and authorization
- ✅ API endpoints and routing
- ✅ Data validation and processing
- ✅ External service integrations

**Forbidden in Go:**
- ❌ UI rendering or widgets
- ❌ Flutter-specific code
- ❌ Mobile platform logic
- ❌ Client-side state management
- ❌ UI animations or transitions

## 🔌 API Communication Rules

### Request/Response Format
```json
{
  "status": "success|error",
  "message": "Human readable message",
  "data": {
    // Actual response data
  }
}
```

### Authentication
- Use JWT tokens for authentication
- Store tokens in Flutter secure storage
- Send tokens in Authorization header
- Handle token refresh in Go middleware

### Error Handling
- Go: Return structured error responses
- Flutter: Display user-friendly error messages
- Never expose internal errors to users

## 🧪 Testing Rules

### Frontend Testing
- Unit tests for widgets and components
- Integration tests for API calls
- Widget tests for UI behavior
- Mock API responses for testing

### Backend Testing
- Unit tests for business logic
- Integration tests for API endpoints
- Database tests for data operations
- Authentication tests for security

## 📝 Code Review Checklist

### For Frontend PRs
- [ ] No Go code present
- [ ] No business logic in UI
- [ ] API calls through service layer
- [ ] Proper error handling
- [ ] UI/UX follows design guidelines
- [ ] Animations are smooth and performant

### For Backend PRs
- [ ] No Flutter/Dart code present
- [ ] No UI rendering logic
- [ ] Proper JSON responses
- [ ] Database operations are secure
- [ ] Authentication is properly implemented
- [ ] API documentation is updated

### For API Changes
- [ ] Frontend service layer updated
- [ ] Backend routes updated
- [ ] Request/response models match
- [ ] Error handling implemented
- [ ] Tests updated for both sides

## 🚨 Common Violations to Avoid

### ❌ Wrong: Mixed Logic
```dart
// WRONG - Business logic in Flutter
class UserService {
  Future<User> createUser(UserData data) async {
    // This should be in Go backend
    final user = await database.insert(data);
    return user;
  }
}
```

### ✅ Correct: Separation
```dart
// CORRECT - Only API communication
class UserService {
  Future<User> createUser(UserData data) async {
    final response = await http.post('/api/users', data);
    return User.fromJson(response.data);
  }
}
```

### ❌ Wrong: UI in Backend
```go
// WRONG - UI logic in Go
func GetUserProfile(c *gin.Context) {
    // This should be in Flutter
    html := `<div>User Profile</div>`
    c.HTML(200, html)
}
```

### ✅ Correct: API Response
```go
// CORRECT - Only API response
func GetUserProfile(c *gin.Context) {
    user := getUserFromDB()
    c.JSON(200, gin.H{
        "status": "success",
        "data": user,
    })
}
```

## 🔧 Development Workflow

1. **Plan API Changes First**
   - Define request/response structures
   - Update backend routes
   - Update frontend service layer

2. **Implement Backend First**
   - Write business logic
   - Create API endpoints
   - Add tests

3. **Implement Frontend**
   - Create UI components
   - Integrate with API
   - Add animations and interactions

4. **Test Integration**
   - Test API communication
   - Verify error handling
   - Test on both platforms

## 📊 Monitoring and Validation

### Automated Checks
- Lint rules to prevent cross-language imports
- CI/CD pipeline validation
- Architecture compliance tests
- API contract validation

### Manual Reviews
- Code review for architecture compliance
- API documentation review
- Integration testing
- Performance validation

---

**Remember: Clean separation = Maintainable code = Better product**
