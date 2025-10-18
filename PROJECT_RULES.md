# ⚙️ Global Development Rules for Gymates Project

## 🧩 Project Overview

This project is a **fully decoupled frontend-backend architecture**.

- **Frontend**: Flutter (Dart) — Responsible for all UI, UX, animation, routing, and mobile logic. Must fully support iOS and Android.
- **Backend**: Go (Golang, using Gin framework) — Responsible for all business logic, API services, database interaction, and authentication.

The two communicate **only through RESTful APIs / WebSocket** — absolutely no cross-end logic.

## 🚫 DO NOT

❌ **Do not generate backend (Go) code inside Flutter files or vice versa.**

❌ **Do not mix UI logic with business logic** (e.g., DB calls or Go structs inside Dart code).

❌ **Do not modify the other end's files** when implementing a change unless it explicitly involves an API contract.

❌ **Do not create placeholder code** without concrete function.

## ✅ DO

✅ **All UI / animation / state management / navigation** must be done in Flutter (Dart).

✅ **All logic / data persistence / computation / API endpoints** must be implemented in Go backend.

✅ **Keep API interfaces consistent** — if the frontend changes request or response structure, update backend routes accordingly.

✅ **Maintain clean architecture**:
```
frontend/flutter_app/lib/ → Flutter UI + State + Networking layer
backend/go_app/ → Go logic + Database + Routes
```

✅ **Follow these communication principles**:
- Use `GET / POST / PUT / DELETE` for REST APIs.
- Use `WebSocket` for live updates (chat, AI training feedback, etc.).

## 🧠 Additional Conventions

- **Flutter** should handle data display, animations, and error prompts gracefully (never crash).
- **Backend Go services** should return structured JSON responses (`status`, `message`, `data`).
- **Both sides** must be independently testable and deployable.
- **Ensure CORS and authentication tokens** are handled correctly when connecting.
- **Frontend's `config/api.dart`** should define base URLs and endpoints, synced with backend's `routes.go`.

## 📦 Summary Rule

### 💡 Rule of Separation:
- **Flutter = Everything the user can see or interact with.**
- **Go = Everything that makes it actually work.**
- **No code from one side should appear in the other.**

## 🔒 Enforcement Rules

### Code Review Requirements
1. **Every PR must be reviewed** for architecture separation compliance
2. **No Go code in Flutter files** - automatic rejection
3. **No Flutter UI code in Go files** - automatic rejection
4. **API changes must be documented** in both frontend and backend

### File Structure Validation
```
✅ CORRECT:
- Flutter: lib/pages/, lib/widgets/, lib/services/
- Go: controllers/, models/, routes/, middleware/

❌ WRONG:
- Flutter files containing Go structs
- Go files containing Flutter widgets
- Mixed logic in single files
```

### API Contract Enforcement
- All API endpoints must be defined in `backend/routes/routes.go`
- All API calls must be defined in `frontend/lib/services/api_service.dart`
- Response structures must match between frontend and backend
- Version changes must be coordinated

## 🚨 Critical Violations

**IMMEDIATE REJECTION** for:
1. Go code in `.dart` files
2. Dart code in `.go` files
3. Database calls in Flutter
4. UI rendering in Go
5. Mixed architecture patterns

## 📋 Checklist for Every Change

### Frontend Changes
- [ ] Only Dart/Flutter code
- [ ] No business logic (only UI/UX)
- [ ] API calls through service layer
- [ ] Proper error handling
- [ ] Animation/state management only

### Backend Changes
- [ ] Only Go code
- [ ] No UI/rendering logic
- [ ] Proper JSON responses
- [ ] Database operations only
- [ ] Authentication/authorization

### API Changes
- [ ] Frontend service updated
- [ ] Backend routes updated
- [ ] Documentation updated
- [ ] Tests updated
- [ ] Version compatibility checked

---

**This document is MANDATORY and must be followed by ALL developers.**
**Violations will result in immediate code rejection.**

Last Updated: $(date)
Version: 1.0
