package dto

// Response represents a standard API response
type Response struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Message string      `json:"message,omitempty"`
	Error   *ErrorDTO   `json:"error,omitempty"`
}

// ErrorDTO represents an error response
type ErrorDTO struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details string `json:"details,omitempty"`
}

// PaginationDTO represents pagination information
type PaginationDTO struct {
	Page       int   `json:"page"`
	Limit      int   `json:"limit"`
	Total      int64 `json:"total"`
	TotalPages int   `json:"total_pages"`
}

// PaginatedResponse represents a paginated API response
type PaginatedResponse struct {
	Success    bool           `json:"success"`
	Data       interface{}    `json:"data"`
	Pagination *PaginationDTO `json:"pagination"`
}

// SuccessResponse creates a success response
func SuccessResponse(data interface{}) *Response {
	return &Response{
		Success: true,
		Data:    data,
	}
}

// ErrorResponse creates an error response
func ErrorResponse(code, message string) *Response {
	return &Response{
		Success: false,
		Error: &ErrorDTO{
			Code:    code,
			Message: message,
		},
	}
}

// PaginatedSuccessResponse creates a paginated success response
func PaginatedSuccessResponse(data interface{}, pagination *PaginationDTO) *PaginatedResponse {
	return &PaginatedResponse{
		Success:    true,
		Data:       data,
		Pagination: pagination,
	}
}

