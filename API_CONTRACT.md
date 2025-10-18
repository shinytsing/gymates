# 📋 Gymates API Contract Documentation

## 🔌 API Communication Standards

### Base URL Configuration
```dart
// Frontend: lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';
  static const String wsUrl = 'ws://localhost:8080/ws';
  static const Duration timeout = Duration(seconds: 30);
}
```

```go
// Backend: config/config.go
type Config struct {
    ServerPort string `env:"SERVER_PORT" envDefault:"8080"`
    APIPrefix  string `env:"API_PREFIX" envDefault:"/api"`
    WSPrefix   string `env:"WS_PREFIX" envDefault:"/ws"`
}
```

## 📡 Standard Response Format

### Success Response
```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": {
    // Response payload
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Human readable error message",
  "error_code": "VALIDATION_ERROR",
  "details": {
    // Additional error details
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 🔐 Authentication Endpoints

### POST /api/auth/login
```dart
// Frontend Request
class LoginRequest {
  final String email;
  final String password;
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```

```go
// Backend Response
type LoginResponse struct {
    Status  string `json:"status"`
    Message string `json:"message"`
    Data    struct {
        Token string `json:"token"`
        User  User   `json:"user"`
    } `json:"data"`
}
```

### POST /api/auth/register
```dart
// Frontend Request
class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? profileImage;
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
    'profile_image': profileImage,
  };
}
```

```go
// Backend Request
type RegisterRequest struct {
    Email       string `json:"email" binding:"required,email"`
    Password    string `json:"password" binding:"required,min=6"`
    Name        string `json:"name" binding:"required"`
    ProfileImage string `json:"profile_image"`
}
```

## 👤 User Management Endpoints

### GET /api/users/profile
```dart
// Frontend Response Model
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final UserStats stats;
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      stats: UserStats.fromJson(json['stats']),
    );
  }
}
```

```go
// Backend Response Model
type UserProfile struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Email       string    `json:"email"`
    ProfileImage string   `json:"profile_image"`
    CreatedAt   time.Time `json:"created_at"`
    Stats       UserStats `json:"stats"`
}

type UserStats struct {
    WorkoutsCompleted int `json:"workouts_completed"`
    TotalMinutes      int `json:"total_minutes"`
    StreakDays        int `json:"streak_days"`
}
```

### PUT /api/users/profile
```dart
// Frontend Request
class UpdateProfileRequest {
  final String? name;
  final String? profileImage;
  final Map<String, dynamic>? preferences;
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'profile_image': profileImage,
    'preferences': preferences,
  };
}
```

```go
// Backend Request
type UpdateProfileRequest struct {
    Name        *string                `json:"name"`
    ProfileImage *string               `json:"profile_image"`
    Preferences  map[string]interface{} `json:"preferences"`
}
```

## 🏋️ Training Endpoints

### GET /api/training/plans
```dart
// Frontend Response Model
class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int estimatedDuration;
  final DifficultyLevel difficulty;
  
  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      exercises: (json['exercises'] as List)
          .map((e) => Exercise.fromJson(e))
          .toList(),
      estimatedDuration: json['estimated_duration'],
      difficulty: DifficultyLevel.fromString(json['difficulty']),
    );
  }
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced;
  
  static DifficultyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner': return DifficultyLevel.beginner;
      case 'intermediate': return DifficultyLevel.intermediate;
      case 'advanced': return DifficultyLevel.advanced;
      default: return DifficultyLevel.beginner;
    }
  }
}
```

```go
// Backend Response Model
type TrainingPlan struct {
    ID               string     `json:"id"`
    Name             string     `json:"name"`
    Description      string     `json:"description"`
    Exercises        []Exercise `json:"exercises"`
    EstimatedDuration int       `json:"estimated_duration"`
    Difficulty       string     `json:"difficulty"`
}

type Exercise struct {
    ID          string `json:"id"`
    Name        string `json:"name"`
    Description string `json:"description"`
    Sets        int    `json:"sets"`
    Reps        int    `json:"reps"`
    Duration    int    `json:"duration"` // in seconds
}
```

### POST /api/training/sessions
```dart
// Frontend Request
class StartSessionRequest {
  final String planId;
  final DateTime startTime;
  
  Map<String, dynamic> toJson() => {
    'plan_id': planId,
    'start_time': startTime.toIso8601String(),
  };
}
```

```go
// Backend Request
type StartSessionRequest struct {
    PlanID    string    `json:"plan_id" binding:"required"`
    StartTime time.Time `json:"start_time" binding:"required"`
}
```

## 👥 Community Endpoints

### GET /api/community/posts
```dart
// Frontend Response Model
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImage;
  final String content;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;
  
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      authorId: json['author_id'],
      authorName: json['author_name'],
      authorImage: json['author_image'],
      content: json['content'],
      images: List<String>.from(json['images'] ?? []),
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      createdAt: DateTime.parse(json['created_at']),
      isLiked: json['is_liked'] ?? false,
    );
  }
}
```

```go
// Backend Response Model
type CommunityPost struct {
    ID            string    `json:"id"`
    AuthorID      string    `json:"author_id"`
    AuthorName    string    `json:"author_name"`
    AuthorImage   string    `json:"author_image"`
    Content       string    `json:"content"`
    Images        []string  `json:"images"`
    LikesCount    int       `json:"likes_count"`
    CommentsCount int       `json:"comments_count"`
    CreatedAt     time.Time `json:"created_at"`
    IsLiked       bool      `json:"is_liked"`
}
```

### POST /api/community/posts
```dart
// Frontend Request
class CreatePostRequest {
  final String content;
  final List<String> images;
  
  Map<String, dynamic> toJson() => {
    'content': content,
    'images': images,
  };
}
```

```go
// Backend Request
type CreatePostRequest struct {
    Content string   `json:"content" binding:"required"`
    Images  []string `json:"images"`
}
```

## 💬 Messaging Endpoints

### GET /api/messages/conversations
```dart
// Frontend Response Model
class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantId: json['participant_id'],
      participantName: json['participant_name'],
      participantImage: json['participant_image'],
      lastMessage: json['last_message'],
      lastMessageTime: DateTime.parse(json['last_message_time']),
      unreadCount: json['unread_count'],
    );
  }
}
```

```go
// Backend Response Model
type Conversation struct {
    ID                string    `json:"id"`
    ParticipantID     string    `json:"participant_id"`
    ParticipantName   string    `json:"participant_name"`
    ParticipantImage  string    `json:"participant_image"`
    LastMessage       string    `json:"last_message"`
    LastMessageTime   time.Time `json:"last_message_time"`
    UnreadCount       int       `json:"unread_count"`
}
```

## 🔄 WebSocket Events

### Connection
```dart
// Frontend WebSocket Connection
class WebSocketService {
  late WebSocketChannel channel;
  
  void connect(String token) {
    channel = WebSocketChannel.connect(
      Uri.parse('${ApiConfig.wsUrl}?token=$token'),
    );
  }
  
  Stream<dynamic> get messageStream => channel.stream;
  
  void sendMessage(Map<String, dynamic> message) {
    channel.sink.add(jsonEncode(message));
  }
}
```

```go
// Backend WebSocket Handler
func handleWebSocket(c *gin.Context) {
    token := c.Query("token")
    userID, err := validateToken(token)
    if err != nil {
        c.JSON(401, gin.H{"error": "Invalid token"})
        return
    }
    
    conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
    if err != nil {
        return
    }
    defer conn.Close()
    
    // Register client
    clients[userID] = conn
    
    // Handle messages
    for {
        var msg Message
        err := conn.ReadJSON(&msg)
        if err != nil {
            delete(clients, userID)
            break
        }
        
        // Process message
        processMessage(userID, msg)
    }
}
```

### Message Types
```dart
// Frontend Message Types
abstract class WebSocketMessage {
  String get type;
  Map<String, dynamic> toJson();
}

class ChatMessage extends WebSocketMessage {
  final String conversationId;
  final String content;
  final DateTime timestamp;
  
  @override
  String get type => 'chat_message';
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'conversation_id': conversationId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

```go
// Backend Message Types
type WebSocketMessage struct {
    Type string          `json:"type"`
    Data json.RawMessage `json:"data"`
}

type ChatMessage struct {
    ConversationID string    `json:"conversation_id"`
    Content        string    `json:"content"`
    Timestamp      time.Time `json:"timestamp"`
}
```

## 📊 Error Codes

### Standard Error Codes
```dart
// Frontend Error Handling
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;
  
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['error_code'],
      message: json['message'],
      details: json['details'],
    );
  }
}

enum ErrorCode {
  validationError('VALIDATION_ERROR'),
  authenticationError('AUTH_ERROR'),
  authorizationError('AUTHZ_ERROR'),
  notFound('NOT_FOUND'),
  serverError('SERVER_ERROR');
  
  const ErrorCode(this.value);
  final String value;
}
```

```go
// Backend Error Codes
const (
    ErrValidation     = "VALIDATION_ERROR"
    ErrAuthentication = "AUTH_ERROR"
    ErrAuthorization  = "AUTHZ_ERROR"
    ErrNotFound       = "NOT_FOUND"
    ErrServerError    = "SERVER_ERROR"
)

type APIError struct {
    Code    string                 `json:"error_code"`
    Message string                 `json:"message"`
    Details map[string]interface{} `json:"details,omitempty"`
}
```

## 🔄 Version Management

### API Versioning
```dart
// Frontend API Version
class ApiVersion {
  static const String current = 'v1';
  static const String baseUrl = '${ApiConfig.baseUrl}/$current';
}
```

```go
// Backend API Version
const APIVersion = "v1"

func setupRoutes(r *gin.Engine) {
    v1 := r.Group(fmt.Sprintf("/api/%s", APIVersion))
    {
        v1.POST("/auth/login", authController.Login)
        v1.GET("/users/profile", userController.GetProfile)
        // ... other routes
    }
}
```

## 📝 Contract Validation

### Automated Testing
```dart
// Frontend Contract Tests
class ApiContractTests {
  test('Login endpoint contract', () async {
    final request = LoginRequest(email: 'test@example.com', password: 'password');
    final response = await apiService.login(request);
    
    expect(response.status, 'success');
    expect(response.data, isA<Map<String, dynamic>>());
    expect(response.data['token'], isA<String>());
    expect(response.data['user'], isA<Map<String, dynamic>>());
  });
}
```

```go
// Backend Contract Tests
func TestLoginEndpoint(t *testing.T) {
    request := LoginRequest{
        Email:    "test@example.com",
        Password: "password",
    }
    
    w := httptest.NewRecorder()
    c, _ := gin.CreateTestContext(w)
    c.Request = httptest.NewRequest("POST", "/api/v1/auth/login", 
        strings.NewReader(toJSON(request)))
    
    authController.Login(c)
    
    assert.Equal(t, 200, w.Code)
    
    var response map[string]interface{}
    json.Unmarshal(w.Body.Bytes(), &response)
    
    assert.Equal(t, "success", response["status"])
    assert.NotNil(t, response["data"])
}
```

---

**This contract must be maintained and updated whenever API changes are made.**
**Both frontend and backend must implement these exact interfaces.**

Last Updated: $(date)
Version: 1.0
Contract Status: ACTIVE
