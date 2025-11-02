# Gymates Backend Architecture

## 📁 Project Structure

```
backend/
├── cmd/                          # Application entry points
│   ├── server.go                 # Main server entry point (NEW)
│   ├── migrate.go                # Database migration tool
│   └── seed_*.go                 # Data seeding scripts
│
├── api/                          # API layer (NEW)
│   ├── routes.go                 # Main route configuration
│   ├── handlers/                 # HTTP request handlers by feature
│   │   ├── auth_handler.go       # Authentication handlers
│   │   ├── community_handler.go  # Community/social handlers
│   │   ├── training_handler.go   # Training plan handlers
│   │   ├── mates_handler.go      # Mate matching handlers
│   │   └── messages_handler.go   # Messaging handlers
│   └── middlewares/              # HTTP middlewares
│       ├── auth.go               # JWT authentication
│       └── common.go             # Common middlewares (CORS, logging, etc.)
│
├── services/                     # Business logic layer
│   ├── ai_service.go             # AI-related business logic
│   ├── training_service.go       # Training business logic
│   └── websocket_service.go      # Real-time communication
│
├── repositories/                 # Data access layer (NEW)
│   ├── user_repository.go        # User data operations
│   ├── post_repository.go        # Post data operations
│   ├── training_repository.go    # Training data operations
│   ├── message_repository.go     # Message data operations
│   └── mate_repository.go        # Mate relationship operations
│
├── models/                       # Data models
│   ├── models.go                 # Core domain models (User, Post, etc.)
│   ├── dto.go                    # Data Transfer Objects
│   ├── training_models.go        # Training-specific models
│   └── ai_training_models.go     # AI training models
│
├── config/                       # Configuration
│   ├── config.go                 # App configuration and DB initialization
│   └── test_config.go            # Test configuration
│
├── controllers/                  # Legacy controllers (being phased out)
│   └── *.go                      # Old controller files (backward compatibility)
│
├── routes/                       # Legacy routes (simplified)
│   └── routes.go                 # Main route entry (delegates to api/)
│
├── middleware/                   # Legacy middleware (deprecated)
│   └── auth.go                   # Old auth middleware (use api/middlewares instead)
│
├── internal/                     # Internal packages
│   └── utils/                    # Internal utilities
│
├── db/                           # Database related
│   └── migrations/               # Database migration files
│
├── main.go                       # Legacy main (use cmd/server.go instead)
└── gymates.db                    # SQLite database file
```

## 🏗️ Architecture Layers

### 1. **Entry Point Layer** (`cmd/`)
- **server.go**: Main application entry point
- Initializes database, services, and starts HTTP server
- Configures middleware and routes

### 2. **API Layer** (`api/`)
- **routes.go**: Central route configuration
- **handlers/**: HTTP request handlers organized by feature modules
  - Each handler focuses on a specific domain (auth, community, training, etc.)
  - Handlers coordinate between services and repositories
  - Handle HTTP-specific concerns (request parsing, response formatting)

### 3. **Middleware Layer** (`api/middlewares/`)
- **auth.go**: JWT token generation, validation, and authentication
- **common.go**: CORS, logging, rate limiting, error handling
- Applied at route level or globally

### 4. **Service Layer** (`services/`)
- Contains business logic and complex operations
- Coordinates between multiple repositories
- Handles AI operations, training algorithms, etc.
- Independent of HTTP concerns

### 5. **Repository Layer** (`repositories/`)
- **Data Access Objects (DAO)**
- Encapsulates all database operations
- Provides clean interface for CRUD operations
- Handles database queries and transactions

### 6. **Model Layer** (`models/`)
- **Domain Models**: Core business entities (User, Post, TrainingPlan)
- **DTOs**: Request/Response data structures
- **Database Models**: GORM models with table mappings

### 7. **Configuration Layer** (`config/`)
- Database initialization and connection management
- Environment variables and app settings
- Configuration utilities

## 🔄 Request Flow

```
Client Request
    ↓
HTTP Server (Gin)
    ↓
Middleware (Auth, CORS, Logging)
    ↓
Route Handler (api/routes.go)
    ↓
Feature Handler (api/handlers/*.go)
    ↓
Service Layer (services/*.go) [Optional - for complex logic]
    ↓
Repository Layer (repositories/*.go)
    ↓
Database (SQLite/PostgreSQL)
    ↓
Response (JSON)
```

## 📝 Coding Conventions

### Handler Naming
- Handlers are named by feature: `AuthHandler`, `CommunityHandler`
- Methods follow REST conventions: `GetPosts`, `CreatePost`, `UpdatePost`, `DeletePost`

### Repository Naming
- Repositories are named by entity: `UserRepository`, `PostRepository`
- Methods are CRUD-focused: `Create`, `GetByID`, `Update`, `Delete`, `List`

### Service Naming
- Services are named by domain: `AIService`, `TrainingService`
- Methods describe business operations: `AnalyzeWorkout`, `GenerateTrainingPlan`

### Error Handling
- Use standard HTTP status codes
- Return structured error responses using `models.ErrorResponse`
- Log errors appropriately

### Authentication
- Use JWT tokens with Bearer authentication
- Access tokens expire in 30 minutes
- Refresh tokens expire in 7 days
- Store refresh tokens in database for revocation

## 🚀 Running the Application

### Development
```bash
# Run with the new entry point
go run cmd/server.go

# Or use the legacy main.go (redirects to cmd/server.go)
go run main.go
```

### Database Migrations
```bash
# Run migrations
go run cmd/migrate.go

# Seed test data
go run cmd/seed_test_data.go
```

### Testing
```bash
# Run all tests
go test ./...

# Run specific package tests
go test ./api/handlers
go test ./repositories
```

## 🔧 Configuration

### Environment Variables
- `GIN_MODE`: `debug` or `release`
- `PORT`: Server port (default: 8080)
- `HOST`: Server host (default: localhost)
- `DB_TYPE`: Database type (default: sqlite)
- `JWT_SECRET`: JWT signing key

## 📦 Key Dependencies

- **Gin**: HTTP web framework
- **GORM**: ORM and database toolkit
- **JWT-Go**: JWT token handling
- **bcrypt**: Password hashing
- **godotenv**: Environment variable loading

## 🔄 Migration from Old Structure

### Completed
✅ Created modular handler structure in `api/handlers/`
✅ Implemented repository layer for data access
✅ Moved middlewares to `api/middlewares/`
✅ Created new entry point in `cmd/server.go`
✅ Simplified main routing in `api/routes.go`

### In Progress
🔄 Migrating remaining controllers to handlers
🔄 Moving business logic to service layer
🔄 Adding comprehensive unit tests

### Future
⏳ Complete migration of all legacy controllers
⏳ Add integration tests for all endpoints
⏳ Implement database migrations system
⏳ Add API documentation with Swagger

## 🎯 Best Practices

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Injection**: Repositories and services are injected into handlers
3. **Error Handling**: Consistent error response structure
4. **Security**: JWT authentication, password hashing, input validation
5. **Scalability**: Modular structure allows easy addition of new features
6. **Testability**: Each layer can be tested independently
7. **Documentation**: Code is well-documented with comments

## 🔐 Security Considerations

- ✅ JWT token-based authentication
- ✅ Password hashing with bcrypt
- ✅ CORS configuration for production
- ✅ Rate limiting middleware
- ✅ Input validation on all endpoints
- ✅ SQL injection protection (GORM parameterized queries)
- ✅ Refresh token revocation support

## 📚 API Documentation

API endpoints are organized by feature modules:

- `/api/auth/*` - Authentication and user management
- `/api/community/*` - Social features and posts
- `/api/training/*` - Training plans and exercises
- `/api/mates/*` - Mate matching and relationships
- `/api/messages/*` - Direct messaging
- `/api/ai/*` - AI coach and recommendations
- `/api/map/*` - Gym location services
- `/api/ws/*` - WebSocket connections

See individual handler files for detailed endpoint documentation.

