package handlers

import (
	"net/http"
	"strconv"

	"gymates-backend/models"

	"github.com/gin-gonic/gin"
)

// BaseHandler provides common handler utilities
type BaseHandler struct{}

// NewBaseHandler creates a new base handler
func NewBaseHandler() *BaseHandler {
	return &BaseHandler{}
}

// SuccessResponse sends a successful JSON response
func (h *BaseHandler) SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}

// SuccessResponseWithMessage sends a successful JSON response with message
func (h *BaseHandler) SuccessResponseWithMessage(c *gin.Context, message string, data interface{}) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": message,
		"data":    data,
	})
}

// CreatedResponse sends a created JSON response
func (h *BaseHandler) CreatedResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    data,
	})
}

// ErrorResponse sends an error JSON response
func (h *BaseHandler) ErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, models.ErrorResponse{
		Success: false,
		Message: message,
	})
}

// BadRequestResponse sends a bad request error response
func (h *BaseHandler) BadRequestResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusBadRequest, message)
}

// UnauthorizedResponse sends an unauthorized error response
func (h *BaseHandler) UnauthorizedResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusUnauthorized, message)
}

// ForbiddenResponse sends a forbidden error response
func (h *BaseHandler) ForbiddenResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusForbidden, message)
}

// NotFoundResponse sends a not found error response
func (h *BaseHandler) NotFoundResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusNotFound, message)
}

// InternalServerErrorResponse sends an internal server error response
func (h *BaseHandler) InternalServerErrorResponse(c *gin.Context, message string) {
	h.ErrorResponse(c, http.StatusInternalServerError, message)
}

// GetUserID extracts user ID from context
func (h *BaseHandler) GetUserID(c *gin.Context) (uint, bool) {
	userID, exists := c.Get("user_id")
	if !exists {
		return 0, false
	}

	switch v := userID.(type) {
	case uint:
		return v, true
	case int:
		return uint(v), true
	case float64:
		return uint(v), true
	case string:
		id, err := strconv.ParseUint(v, 10, 32)
		if err != nil {
			return 0, false
		}
		return uint(id), true
	default:
		return 0, false
	}
}

// GetUserIDOrAbort extracts user ID or aborts with unauthorized
func (h *BaseHandler) GetUserIDOrAbort(c *gin.Context) uint {
	userID, ok := h.GetUserID(c)
	if !ok {
		h.UnauthorizedResponse(c, "User not authenticated")
		c.Abort()
		return 0
	}
	return userID
}

// GetPathParamUint extracts uint parameter from path
func (h *BaseHandler) GetPathParamUint(c *gin.Context, param string) (uint, error) {
	value := c.Param(param)
	id, err := strconv.ParseUint(value, 10, 32)
	if err != nil {
		return 0, err
	}
	return uint(id), nil
}

// GetQueryParamInt extracts int parameter from query
func (h *BaseHandler) GetQueryParamInt(c *gin.Context, param string, defaultValue int) int {
	value := c.DefaultQuery(param, strconv.Itoa(defaultValue))
	result, err := strconv.Atoi(value)
	if err != nil {
		return defaultValue
	}
	return result
}

// GetPaginationParams extracts pagination parameters
func (h *BaseHandler) GetPaginationParams(c *gin.Context) (page, limit int) {
	page = h.GetQueryParamInt(c, "page", 1)
	limit = h.GetQueryParamInt(c, "limit", 20)

	// Ensure page is at least 1
	if page < 1 {
		page = 1
	}

	// Ensure limit is between 1 and 100
	if limit < 1 {
		limit = 20
	} else if limit > 100 {
		limit = 100
	}

	return page, limit
}

// CalculateOffset calculates offset for pagination
func (h *BaseHandler) CalculateOffset(page, limit int) int {
	return (page - 1) * limit
}

// BindJSON binds and validates JSON request body
func (h *BaseHandler) BindJSON(c *gin.Context, obj interface{}) bool {
	if err := c.ShouldBindJSON(obj); err != nil {
		h.BadRequestResponse(c, "Invalid request body: "+err.Error())
		return false
	}
	return true
}

// PaginatedResponse sends a paginated response
func (h *BaseHandler) PaginatedResponse(c *gin.Context, data interface{}, page, limit int, total int64) {
	totalPages := int(total) / limit
	if int(total)%limit > 0 {
		totalPages++
	}

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
		"pagination": gin.H{
			"page":        page,
			"limit":       limit,
			"total":       total,
			"total_pages": totalPages,
			"has_more":    page < totalPages,
		},
	})
}

