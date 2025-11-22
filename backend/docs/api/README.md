# Gymates API Documentation (Clean Architecture v1)

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication
Most endpoints require Bearer token authentication. Include the token in the `Authorization` header:
```
Authorization: Bearer <access_token>
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error description"
  }
}
```

## Endpoints

### 1. Health Check
Check if the API is running.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "time": "2025-11-15T14:20:09+08:00"
}
```

### 2. Register (Email)
Register a new user with email and password.

**Endpoint:** `POST /api/v1/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe"
}
```

**Response:** (201 Created)
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "John Doe",
      "avatar": "",
      "followers_count": 0,
      "following_count": 0,
      "mates_count": 0,
      "posts_count": 0,
      "total_workouts": 0,
      "total_duration": 0,
      "total_calories": 0,
      "current_streak": 0,
      "is_email_verified": false,
      "is_phone_verified": false,
      "created_at": "2025-11-15T14:20:09Z"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 86400
  }
}
```

**Error Responses:**
- 400 Bad Request: Invalid email format, password too short, or user already exists

### 3. Login (Email)
Authenticate with email and password.

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:** (200 OK)
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "access_token": "...",
    "refresh_token": "...",
    "token_type": "Bearer",
    "expires_in": 86400
  }
}
```

**Error Responses:**
- 401 Unauthorized: Invalid credentials or inactive account

### 4. Phone Login
Login with phone number and verification code.

**Endpoint:** `POST /api/v1/auth/phone/login`

**Request Body:**
```json
{
  "phone": "13800138000",
  "code": "123456"
}
```

**Response:** (200 OK)
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "access_token": "...",
    "refresh_token": "...",
    "token_type": "Bearer",
    "expires_in": 86400
  }
}
```

**Error Responses:**
- 400 Bad Request: Invalid phone format
- 401 Unauthorized: Invalid or expired code, or user not found

### 5. Get Current User
Get the authenticated user's information.

**Endpoint:** `GET /api/v1/auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** (200 OK)
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "avatar": "",
    "bio": "",
    ...
  }
}
```

**Error Responses:**
- 401 Unauthorized: Missing or invalid token

### 6. Logout
Logout the current user (revoke tokens).

**Endpoint:** `POST /api/v1/auth/logout`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** (200 OK)
```json
{
  "success": true,
  "data": {
    "message": "Logged out successfully"
  }
}
```

## Error Codes

| Code | Description |
|------|-------------|
| `BAD_REQUEST` | Invalid request parameters |
| `UNAUTHORIZED` | Missing or invalid authentication |
| `FORBIDDEN` | Insufficient permissions |
| `NOT_FOUND` | Resource not found |
| `INTERNAL_ERROR` | Server error |

## Testing

### Using cURL

1. Register a user:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'
```

2. Login:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

3. Get current user:
```bash
curl -X GET http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer <your_access_token>"
```

## Architecture

This API is built using Clean Architecture principles:
- **Domain Layer**: Business entities and interfaces
- **Application Layer**: Use cases and DTOs
- **Infrastructure Layer**: External services and persistence
- **Interface Layer**: HTTP handlers and middleware

## Next Steps

Future endpoints to be implemented:
- User profile management
- Training plans and exercises
- Community posts and interactions
- Mate matching system
- Messaging
- AI features

For more details, see the main architecture documentation.

