package handlers

import (
	"net/http"
	"strconv"

	"gymates-backend/models"
	"gymates-backend/repositories"

	"github.com/gin-gonic/gin"
)

// CommunityHandler handles community-related requests
type CommunityHandler struct {
	postRepo *repositories.PostRepository
	userRepo *repositories.UserRepository
}

// NewCommunityHandler creates a new community handler
func NewCommunityHandler() *CommunityHandler {
	return &CommunityHandler{
		postRepo: repositories.NewPostRepository(),
		userRepo: repositories.NewUserRepository(),
	}
}

// GetPosts retrieves a list of posts
func (h *CommunityHandler) GetPosts(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	typeFilter := c.Query("type")
	tab := c.DefaultQuery("tab", "recommended")

	posts, total, err := h.postRepo.List(page, limit, typeFilter, tab)
	if err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取帖子列表失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	pagination := models.Pagination{
		Page:       page,
		Limit:      limit,
		Total:      total,
		TotalPages: int((total + int64(limit) - 1) / int64(limit)),
		HasMore:    int64(page*limit) < total,
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取帖子列表成功",
		Data: models.PostsResponse{
			Posts:      posts,
			Pagination: pagination,
		},
	})
}

// GetPost retrieves a single post by ID
func (h *CommunityHandler) GetPost(c *gin.Context) {
	postIDStr := c.Param("id")
	postID, err := strconv.ParseUint(postIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的帖子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	post, err := h.postRepo.GetByID(uint(postID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "帖子不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取帖子成功",
		Data:    post,
	})
}

// CreatePost creates a new post
func (h *CommunityHandler) CreatePost(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	var req models.CreatePostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Convert images slice to comma-separated string
	imagesStr := ""
	if len(req.Images) > 0 {
		for i, img := range req.Images {
			if i > 0 {
				imagesStr += ","
			}
			imagesStr += img
		}
	}

	post := models.Post{
		UserID:   currentUser.ID,
		Content:  req.Content,
		Images:   imagesStr,
		Type:     req.Type,
		IsPublic: true, // Default to public
	}

	if err := h.postRepo.Create(&post); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建帖子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// Reload post with user information
	reloadedPost, _ := h.postRepo.GetByID(post.ID)
	if reloadedPost != nil {
		post = *reloadedPost
	}

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建帖子成功",
		Data:    post,
	})
}

// UpdatePost updates an existing post
func (h *CommunityHandler) UpdatePost(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	postIDStr := c.Param("id")
	postID, err := strconv.ParseUint(postIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的帖子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	post, err := h.postRepo.GetByID(uint(postID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "帖子不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check if user owns the post
	if post.UserID != currentUser.ID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权限修改此帖子",
			Error:   "Forbidden",
			Code:    http.StatusForbidden,
		})
		return
	}

	var req models.CreatePostRequest // Reuse CreatePostRequest for simplicity
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// Update fields
	if req.Content != "" {
		post.Content = req.Content
	}
	if len(req.Images) > 0 {
		imagesStr := ""
		for i, img := range req.Images {
			if i > 0 {
				imagesStr += ","
			}
			imagesStr += img
		}
		post.Images = imagesStr
	}
	if req.Type != "" {
		post.Type = req.Type
	}

	if err := h.postRepo.Update(post); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新帖子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新帖子成功",
		Data:    post,
	})
}

// DeletePost deletes a post
func (h *CommunityHandler) DeletePost(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	postIDStr := c.Param("id")
	postID, err := strconv.ParseUint(postIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的帖子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	post, err := h.postRepo.GetByID(uint(postID))
	if err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "帖子不存在",
			Error:   err.Error(),
			Code:    http.StatusNotFound,
		})
		return
	}

	// Check if user owns the post
	if post.UserID != currentUser.ID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权限删除此帖子",
			Error:   "Forbidden",
			Code:    http.StatusForbidden,
		})
		return
	}

	if err := h.postRepo.Delete(uint(postID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "删除帖子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "删除帖子成功",
		Data:    nil,
	})
}

// LikePost likes a post
func (h *CommunityHandler) LikePost(c *gin.Context) {
	_, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	postIDStr := c.Param("id")
	postID, err := strconv.ParseUint(postIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的帖子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	if err := h.postRepo.IncrementLikes(uint(postID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "点赞失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "点赞成功",
		Data:    nil,
	})
}

// UnlikePost unlikes a post
func (h *CommunityHandler) UnlikePost(c *gin.Context) {
	_, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "未认证",
			Error:   "Unauthorized",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	postIDStr := c.Param("id")
	postID, err := strconv.ParseUint(postIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的帖子ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	if err := h.postRepo.DecrementLikes(uint(postID)); err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "取消点赞失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "取消点赞成功",
		Data:    nil,
	})
}

