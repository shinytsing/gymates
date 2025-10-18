# 🏗️ Gymates Project - Architecture & Development Rules

## 📋 Project Overview

Gymates is a **fully decoupled frontend-backend architecture** fitness social app:

- **Frontend**: Flutter (Dart) - UI, UX, animations, routing, mobile logic
- **Backend**: Go (Golang + Gin) - Business logic, API services, database, authentication
- **Communication**: RESTful APIs + WebSocket only

## 🚨 CRITICAL RULES - MUST FOLLOW

### ❌ NEVER DO
- ❌ Put Go code in Flutter files
- ❌ Put Flutter code in Go files  
- ❌ Mix UI logic with business logic
- ❌ Create placeholder code without concrete function
- ❌ Modify other end's files unless API contract changes

### ✅ ALWAYS DO
- ✅ Keep Flutter for UI/UX/animations only
- ✅ Keep Go for business logic/database only
- ✅ Use APIs for all communication
- ✅ Maintain clean architecture separation
- ✅ Follow API contract consistency

## 📚 Documentation

### 🎯 Core Rules
- **[PROJECT_RULES.md](PROJECT_RULES.md)** - Main development rules and principles
- **[ARCHITECTURE_GUIDE.md](ARCHITECTURE_GUIDE.md)** - Detailed architecture separation guide
- **[ENFORCEMENT_RULES.md](ENFORCEMENT_RULES.md)** - Enforcement mechanisms and compliance
- **[API_CONTRACT.md](API_CONTRACT.md)** - API communication standards and contracts

### 🔧 Implementation
- **[.git/hooks/pre-commit](.git/hooks/pre-commit)** - Git hook for local compliance checking
- **[.github/workflows/architecture-compliance.yml](.github/workflows/architecture-compliance.yml)** - CI/CD pipeline for automated checking

## 🏗️ Architecture Separation

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

## 🔌 API Communication

### Standard Response Format
```json
{
  "status": "success|error",
  "message": "Human readable message",
  "data": {
    // Response payload
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Authentication
- JWT tokens for authentication
- Store tokens in Flutter secure storage
- Send tokens in Authorization header
- Handle token refresh in Go middleware

## 🔒 Enforcement Mechanisms

### 1. Git Hooks
- **Pre-commit hook** automatically checks architecture compliance
- Prevents commits that violate separation rules
- Runs local validation before code reaches repository

### 2. CI/CD Pipeline
- **GitHub Actions** workflow for automated checking
- Runs on every push and pull request
- Blocks merging if compliance checks fail
- Generates architecture compliance reports

### 3. Code Review Requirements
- Every PR must be reviewed for architecture compliance
- No Go code in Flutter files - automatic rejection
- No Flutter UI code in Go files - automatic rejection
- API changes must be documented in both frontend and backend

## 🚨 Critical Violations - IMMEDIATE REJECTION

1. **Go code in `.dart` files**
2. **Dart code in `.go` files**
3. **Database calls in Flutter**
4. **UI rendering in Go**
5. **Mixed architecture patterns**

## 📋 Development Checklist

### Before Every Commit
- [ ] No Go code in Flutter files
- [ ] No Flutter code in Go files
- [ ] Business logic only in Go
- [ ] UI logic only in Flutter
- [ ] API calls through service layer
- [ ] Proper error handling
- [ ] Tests updated

### For API Changes
- [ ] Frontend service updated
- [ ] Backend routes updated
- [ ] Documentation updated
- [ ] Tests updated
- [ ] Version compatibility checked

## 🧪 Testing Strategy

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

## 📊 Monitoring & Validation

### Automated Checks
- Lint rules prevent cross-language imports
- CI/CD pipeline validation
- Architecture compliance tests
- API contract validation

### Manual Reviews
- Code review for architecture compliance
- API documentation review
- Integration testing
- Performance validation

## 🎯 Success Criteria

### Project Health Indicators
- ✅ Zero cross-language code violations
- ✅ 100% API contract compliance
- ✅ All PRs reviewed for architecture
- ✅ Independent deployment capability
- ✅ Clear separation of concerns

### Quality Gates
1. **Code Review Gate**: All PRs must pass architecture review
2. **Testing Gate**: Both frontend and backend tests must pass
3. **Integration Gate**: API communication must work correctly
4. **Deployment Gate**: Independent deployment must be possible

## 🚀 Quick Start

### Setting Up Development Environment
1. **Clone repository**
2. **Read all documentation** (PROJECT_RULES.md, ARCHITECTURE_GUIDE.md, etc.)
3. **Set up Flutter environment** for frontend development
4. **Set up Go environment** for backend development
5. **Run pre-commit hook** to ensure compliance
6. **Follow API contract** for communication

### Running the Project
```bash
# Backend
cd backend
go run main.go

# Frontend  
cd gymates_flutter
flutter run
```

## 📞 Support & Escalation

### Violation Response
1. **First Violation**: Warning and education
2. **Second Violation**: Mandatory review session
3. **Third Violation**: Temporary access restriction
4. **Repeated Violations**: Project role review

### Dispute Resolution
- Technical lead reviews disputed violations
- Architecture committee makes final decisions
- Documentation updated based on learnings

---

## 🎉 Remember

**Clean separation = Maintainable code = Better product**

These rules ensure the Gymates project maintains high quality, scalability, and maintainability through proper architecture separation.

**These rules are MANDATORY and non-negotiable.**
**Compliance ensures project success and maintainability.**

---

*Last Updated: $(date)*  
*Version: 1.0*  
*Enforcement Level: CRITICAL*
