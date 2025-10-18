package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gymates-backend/config"
	"gymates-backend/models"
)

// CommunityController 社区控制器
type CommunityController struct{}

// NewCommunityController 创建社区控制器
func NewCommunityController() *CommunityController {
	return &CommunityController{}
}

// GetPosts 获取帖子列表
func (cc *CommunityController) GetPosts(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	typeFilter := c.Query("type")

	var posts []models.Post
	var total int64

	query := config.DB.Model(&models.Post{}).Where("is_public = ?", true)

	// 根据类型过滤
	if typeFilter != "" {
		query = query.Where("type = ?", typeFilter)
	}

	// 获取总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Preload("User").
		Offset(offset).Limit(limit).Order("created_at DESC").Find(&posts).Error; err != nil {
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

// GetPost 获取单个帖子
func (cc *CommunityController) GetPost(c *gin.Context) {
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

	var post models.Post
	if err := config.DB.Preload("User").First(&post, uint(postID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "帖子不存在",
			Error:   "Post not found",
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

// CreatePost 创建帖子
func (cc *CommunityController) CreatePost(c *gin.Context) {
	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

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

	currentUser := user.(*models.User)

	// 处理图片
	var imagesStr string
	if len(req.Images) > 0 {
		imagesStr = strings.Join(req.Images, ",")
	}

	// 创建帖子
	post := models.Post{
		UserID:   currentUser.ID,
		Content:  req.Content,
		Images:   imagesStr,
		Type:     req.Type,
		IsPublic: true,
	}

	if err := config.DB.Create(&post).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建帖子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").First(&post, post.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建帖子成功",
		Data:    post,
	})
}

// LikePost 点赞帖子
func (cc *CommunityController) LikePost(c *gin.Context) {
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

	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	// 检查帖子是否存在
	var post models.Post
	if err := config.DB.First(&post, uint(postID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "帖子不存在",
			Error:   "Post not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 检查是否已经点赞
	var existingLike models.PostLike
	if err := config.DB.Where("post_id = ? AND user_id = ?", uint(postID), currentUser.ID).
		First(&existingLike).Error; err == nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "已经点赞过了",
			Error:   "Already liked",
			Code:    http.StatusConflict,
		})
		return
	}

	// 创建点赞记录
	like := models.PostLike{
		PostID: uint(postID),
		UserID: currentUser.ID,
	}

	if err := config.DB.Create(&like).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "点赞失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新帖子点赞数
	config.DB.Model(&post).Update("likes", post.Likes+1)

	// 重新加载数据
	config.DB.Preload("User").First(&post, post.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "点赞成功",
		Data:    post,
	})
}

// UnlikePost 取消点赞帖子
func (cc *CommunityController) UnlikePost(c *gin.Context) {
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

	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	currentUser := user.(*models.User)

	// 查找点赞记录
	var like models.PostLike
	if err := config.DB.Where("post_id = ? AND user_id = ?", uint(postID), currentUser.ID).
		First(&like).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "未找到点赞记录",
			Error:   "Like not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 删除点赞记录
	if err := config.DB.Delete(&like).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "取消点赞失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新帖子点赞数
	var post models.Post
	config.DB.First(&post, uint(postID))
	if post.Likes > 0 {
		config.DB.Model(&post).Update("likes", post.Likes-1)
	}

	// 重新加载数据
	config.DB.Preload("User").First(&post, post.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "取消点赞成功",
		Data:    post,
	})
}

// GetComments 获取帖子评论
func (cc *CommunityController) GetComments(c *gin.Context) {
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

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	var comments []models.Comment
	var total int64

	// 获取总数
	config.DB.Model(&models.Comment{}).Where("post_id = ?", uint(postID)).Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := config.DB.Where("post_id = ?", uint(postID)).
		Preload("User").
		Offset(offset).Limit(limit).Order("created_at ASC").Find(&comments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取评论失败",
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
		Message: "获取评论成功",
		Data: models.CommentsResponse{
			Comments:   comments,
			Pagination: pagination,
		},
	})
}

// CreateComment 创建评论
func (cc *CommunityController) CreateComment(c *gin.Context) {
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

	user, exists := c.Get("user")
	if !exists {
		c.JSON(http.StatusUnauthorized, models.ErrorResponse{
			Success: false,
			Message: "用户未认证",
			Error:   "User not authenticated",
			Code:    http.StatusUnauthorized,
		})
		return
	}

	var req models.CreateCommentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	currentUser := user.(*models.User)

	// 检查帖子是否存在
	var post models.Post
	if err := config.DB.First(&post, uint(postID)).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "帖子不存在",
			Error:   "Post not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 创建评论
	comment := models.Comment{
		PostID:  uint(postID),
		UserID:  currentUser.ID,
		Content: req.Content,
	}

	if err := config.DB.Create(&comment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建评论失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 更新帖子评论数
	config.DB.Model(&post).Update("comments", post.Comments+1)

	// 重新加载数据
	config.DB.Preload("User").First(&comment, comment.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建评论成功",
		Data:    comment,
	})
}

// SearchPosts 搜索帖子
func (cc *CommunityController) SearchPosts(c *gin.Context) {
	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "搜索关键词不能为空",
			Error:   "Query parameter is required",
			Code:    http.StatusBadRequest,
		})
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	var posts []models.Post
	var total int64

	// 搜索帖子
	searchQuery := config.DB.Model(&models.Post{}).Where("is_public = ? AND content LIKE ?", true, "%"+query+"%")

	// 获取总数
	searchQuery.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := searchQuery.Preload("User").
		Offset(offset).Limit(limit).Order("created_at DESC").Find(&posts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "搜索帖子失败",
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
		Message: "搜索帖子成功",
		Data: models.PostsResponse{
			Posts:      posts,
			Pagination: pagination,
		},
	})
}
