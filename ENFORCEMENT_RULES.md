# 🔒 Gymates Project Enforcement Rules

## 🚨 Mandatory Compliance Rules

### 1. Code Review Requirements
- **Every PR must be reviewed** for architecture separation compliance
- **No Go code in Flutter files** - automatic rejection
- **No Flutter UI code in Go files** - automatic rejection
- **API changes must be documented** in both frontend and backend

### 2. File Structure Validation
```
✅ CORRECT:
- Flutter: lib/pages/, lib/widgets/, lib/services/
- Go: controllers/, models/, routes/, middleware/

❌ WRONG:
- Flutter files containing Go structs
- Go files containing Flutter widgets
- Mixed logic in single files
```

### 3. API Contract Enforcement
- All API endpoints must be defined in `backend/routes/routes.go`
- All API calls must be defined in `frontend/lib/services/api_service.dart`
- Response structures must match between frontend and backend
- Version changes must be coordinated

## 🚫 Critical Violations - IMMEDIATE REJECTION

1. **Go code in `.dart` files**
2. **Dart code in `.go` files**
3. **Database calls in Flutter**
4. **UI rendering in Go**
5. **Mixed architecture patterns**

## 📋 Pre-commit Checklist

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

## 🔧 Enforcement Tools

### 1. Git Hooks
```bash
#!/bin/sh
# pre-commit hook
echo "Checking architecture compliance..."

# Check for Go code in Dart files
if grep -r "package main\|func \|type.*struct" lib/ --include="*.dart"; then
    echo "❌ ERROR: Go code found in Flutter files!"
    exit 1
fi

# Check for Dart code in Go files
if grep -r "import.*flutter\|class.*extends\|Widget" . --include="*.go"; then
    echo "❌ ERROR: Flutter code found in Go files!"
    exit 1
fi

echo "✅ Architecture compliance check passed!"
```

### 2. CI/CD Pipeline Rules
```yaml
# .github/workflows/architecture-check.yml
name: Architecture Compliance Check
on: [push, pull_request]

jobs:
  architecture-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check Flutter files for Go code
        run: |
          if grep -r "package main\|func \|type.*struct" gymates_flutter/lib/ --include="*.dart"; then
            echo "❌ Go code found in Flutter files!"
            exit 1
          fi
      - name: Check Go files for Flutter code
        run: |
          if grep -r "import.*flutter\|class.*extends\|Widget" backend/ --include="*.go"; then
            echo "❌ Flutter code found in Go files!"
            exit 1
          fi
      - name: API Contract Validation
        run: |
          # Validate API endpoints match between frontend and backend
          python scripts/validate_api_contract.py
```

### 3. Linting Rules

#### Flutter (analysis_options.yaml)
```yaml
analyzer:
  rules:
    # Prevent Go-like patterns
    avoid_function_literals_in_foreach_calls: true
    avoid_renaming_method_parameters: true
    # Ensure proper separation
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true

linter:
  rules:
    # Architecture compliance
    avoid_web_libraries_in_flutter: true
    prefer_single_quotes: true
    # Prevent business logic in UI
    avoid_print: true
    avoid_web_libraries_in_flutter: true
```

#### Go (golangci-lint.yml)
```yaml
linters-settings:
  gocritic:
    enabled-tags:
      - diagnostic
      - style
      - performance
    disabled-checks:
      - dupImport # Allow duplicate imports for clarity
      
linters:
  enable:
    - gocritic
    - gosec
    - govet
    - ineffassign
    - misspell
    - unused
```

## 📊 Monitoring Dashboard

### Key Metrics to Track
1. **Architecture Violations**: Count of cross-language imports
2. **API Contract Compliance**: Endpoint matching between frontend/backend
3. **Code Review Coverage**: Percentage of PRs reviewed for architecture
4. **Test Coverage**: Separate metrics for frontend and backend

### Automated Alerts
- Slack notification for architecture violations
- Email alerts for critical compliance failures
- Dashboard updates for real-time monitoring

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

## 🚀 Implementation Timeline

### Phase 1: Immediate (Week 1)
- [ ] Create enforcement documentation
- [ ] Set up git hooks
- [ ] Configure linting rules
- [ ] Train team on rules

### Phase 2: Automation (Week 2)
- [ ] Set up CI/CD pipeline
- [ ] Implement automated checks
- [ ] Create monitoring dashboard
- [ ] Set up alerts

### Phase 3: Optimization (Week 3)
- [ ] Refine rules based on feedback
- [ ] Optimize performance
- [ ] Add advanced monitoring
- [ ] Document best practices

## 📞 Escalation Process

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

**These rules are MANDATORY and non-negotiable.**
**Compliance ensures project success and maintainability.**

Last Updated: $(date)
Version: 1.0
Enforcement Level: CRITICAL
