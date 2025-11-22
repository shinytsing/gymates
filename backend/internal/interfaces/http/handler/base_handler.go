package handler

import (
	"gymates-backend/internal/application/dto"
	"net/http"

	"github.com/gin-gonic/gin"
)

// BaseHandler provides common handler methods
type BaseHandler struct{}

// NewBaseHandler creates a new base handler
func NewBaseHandler() *BaseHandler {
	return &BaseHandler{}
}

// SuccessResponse sends a success response
func (h *BaseHandler) SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, dto.SuccessResponse(data))
}

// CreatedResponse sends a created response
func (h *BaseHandler) CreatedResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, dto.SuccessResponse(data))
}

// ErrorResponse sends an error response
func (h *BaseHandler) ErrorResponse(c *gin.Context, statusCode int, code, message string) {
	c.JSON(statusCode, dto.ErrorResponse(code, message))
}

// BadRequestResponse sends a bad request error
func (h *BaseHandler) BadRequestResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusBadRequest, "BAD_REQUEST", message)
}

// UnauthorizedResponse sends an unauthorized error
func (h *BaseHandler) UnauthorizedResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusUnauthorized, "UNAUTHORIZED", message)
}

// ForbiddenResponse sends a forbidden error
func (h *BaseHandler) ForbiddenResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusForbidden, "FORBIDDEN", message)
}

// NotFoundResponse sends a not found error
func (h *BaseHandler) NotFoundResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusNotFound, "NOT_FOUND", message)
}

// InternalErrorResponse sends an internal server error
func (h *BaseHandler) InternalErrorResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusInternalServerError, "INTERNAL_ERROR", message)
}

// PaginatedResponse sends a paginated response
func (h *BaseHandler) PaginatedResponse(c *gin.Context, data interface{}, pagination *dto.PaginationDTO) {
	c.JSON(http.StatusOK, dto.PaginatedSuccessResponse(data, pagination))
}

// GetUserID extracts user ID from context
func (h *BaseHandler) GetUserID(c *gin.Context) (uint, bool) {
	userID, exists := c.Get("user_id")
	if !exists {
		return 0, false
	}
	
	id, ok := userID.(uint)
	return id, ok
}

// GetUserIDOrAbort extracts user ID or aborts with unauthorized
func (h *BaseHandler) GetUserIDOrAbort(c *gin.Context) uint {
	userID, exists := h.GetUserID(c)
	if !exists {
		h.UnauthorizedResponse(c, "Authentication required")
		c.Abort()
		return 0
	}
	return userID
}

// BindJSON binds JSON request body and returns false on error
func (h *BaseHandler) BindJSON(c *gin.Context, obj interface{}) bool {
	if err := c.ShouldBindJSON(obj); err != nil {
		h.BadRequestResponse(c, err.Error())
		return false
	}
	return true
}

// BindQuery binds query parameters and returns false on error
func (h *BaseHandler) BindQuery(c *gin.Context, obj interface{}) bool {
	if err := c.ShouldBindQuery(obj); err != nil {
		h.BadRequestResponse(c, err.Error())
		return false
	}
	return true
}

