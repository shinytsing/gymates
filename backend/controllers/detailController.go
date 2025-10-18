package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"gymates-backend/config"
	"gymates-backend/models"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// DetailController 详情控制器
type DetailController struct{}

// NewDetailController 创建详情控制器
func NewDetailController() *DetailController {
	return &DetailController{}
}

// GetDetailList 获取详情列表
func (dc *DetailController) GetDetailList(c *gin.Context) {
	var req models.DetailListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "请求参数错误",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 设置默认值
	if req.Page <= 0 {
		req.Page = 1
	}
	if req.Limit <= 0 {
		req.Limit = 10
	}
	if req.Limit > 100 {
		req.Limit = 100
	}
	if req.SortBy == "" {
		req.SortBy = "created_at"
	}
	if req.Order == "" {
		req.Order = "desc"
	}

	var items []models.DetailItem
	var total int64

	// 构建查询
	query := config.DB.Model(&models.DetailItem{})

	// 添加筛选条件
	if req.Category != "" {
		query = query.Where("category = ?", req.Category)
	}
	if req.Type != "" {
		query = query.Where("type = ?", req.Type)
	}
	if req.Status != "" {
		query = query.Where("status = ?", req.Status)
	}
	if req.UserID > 0 {
		query = query.Where("user_id = ?", req.UserID)
	}
	if req.ParentID != nil {
		query = query.Where("parent_id = ?", *req.ParentID)
	}
	if req.Keyword != "" {
		query = query.Where("title LIKE ? OR content LIKE ? OR description LIKE ? OR tags LIKE ?",
			"%"+req.Keyword+"%", "%"+req.Keyword+"%", "%"+req.Keyword+"%", "%"+req.Keyword+"%")
	}

	// 获取总数
	if err := query.Count(&total).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取数据总数失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 排序
	orderClause := req.SortBy + " " + strings.ToUpper(req.Order)
	if err := query.Preload("User").Preload("Parent").
		Order(orderClause).
		Offset((req.Page - 1) * req.Limit).
		Limit(req.Limit).
		Find(&items).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取列表数据失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 计算分页信息
	totalPages := int((total + int64(req.Limit) - 1) / int64(req.Limit))
	hasMore := int64(req.Page*req.Limit) < total

	pagination := models.Pagination{
		Page:       req.Page,
		Limit:      req.Limit,
		Total:      total,
		TotalPages: totalPages,
		HasMore:    hasMore,
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取列表成功",
		Data: models.DetailListResponse{
			Items:      items,
			Pagination: pagination,
		},
	})
}

// GetDetail 获取详情
func (dc *DetailController) GetDetail(c *gin.Context) {
	detailIDStr := c.Param("id")
	detailID, err := strconv.ParseUint(detailIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var item models.DetailItem
	if err := config.DB.Preload("User").Preload("Parent").Preload("Children").
		First(&item, uint(detailID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "详情不存在",
				Error:   "Detail not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "获取详情失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
		}
		return
	}

	// 增加浏览次数
	config.DB.Model(&item).Update("view_count", item.ViewCount+1)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取详情成功",
		Data: models.DetailResponse{
			Item: item,
		},
	})
}

// SubmitDetail 提交详情
func (dc *DetailController) SubmitDetail(c *gin.Context) {
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

	var req models.DetailSubmitRequest
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

	// 处理数组字段
	imagesStr := strings.Join(req.Images, ",")
	videosStr := strings.Join(req.Videos, ",")
	filesStr := strings.Join(req.Files, ",")
	tagsStr := strings.Join(req.Tags, ",")

	// 创建新项
	item := models.DetailItem{
		Title:       req.Title,
		Content:     req.Content,
		Description: req.Description,
		Images:      imagesStr,
		Videos:      videosStr,
		Files:       filesStr,
		Category:    req.Category,
		Type:        req.Type,
		Status:      req.Status,
		Priority:    req.Priority,
		Tags:        tagsStr,
		Metadata:    req.Metadata,
		UserID:      currentUser.ID,
		ParentID:    req.ParentID,
	}

	if item.Status == "" {
		item.Status = "draft"
	}

	if err := config.DB.Create(&item).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "创建失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("Parent").First(&item, item.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建成功",
		Data: models.DetailResponse{
			Item: item,
		},
	})
}

// UpdateDetail 更新详情
func (dc *DetailController) UpdateDetail(c *gin.Context) {
	detailIDStr := c.Param("id")
	detailID, err := strconv.ParseUint(detailIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的ID",
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

	var req models.DetailUpdateRequest
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

	// 查找项目
	var item models.DetailItem
	if err := config.DB.First(&item, uint(detailID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "详情不存在",
				Error:   "Detail not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找详情失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
		}
		return
	}

	// 检查权限（只有创建者可以修改）
	if item.UserID != currentUser.ID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权限修改此详情",
			Error:   "Permission denied",
			Code:    http.StatusForbidden,
		})
		return
	}

	// 更新字段
	updates := make(map[string]interface{})
	if req.Title != "" {
		updates["title"] = req.Title
	}
	if req.Content != "" {
		updates["content"] = req.Content
	}
	if req.Description != "" {
		updates["description"] = req.Description
	}
	if len(req.Images) > 0 {
		updates["images"] = strings.Join(req.Images, ",")
	}
	if len(req.Videos) > 0 {
		updates["videos"] = strings.Join(req.Videos, ",")
	}
	if len(req.Files) > 0 {
		updates["files"] = strings.Join(req.Files, ",")
	}
	if req.Category != "" {
		updates["category"] = req.Category
	}
	if req.Type != "" {
		updates["type"] = req.Type
	}
	if req.Status != "" {
		updates["status"] = req.Status
	}
	if req.Priority != 0 {
		updates["priority"] = req.Priority
	}
	if len(req.Tags) > 0 {
		updates["tags"] = strings.Join(req.Tags, ",")
	}
	if req.Metadata != "" {
		updates["metadata"] = req.Metadata
	}

	if err := config.DB.Model(&item).Updates(updates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "更新失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("Parent").First(&item, item.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新成功",
		Data: models.DetailResponse{
			Item: item,
		},
	})
}

// DeleteDetail 删除详情
func (dc *DetailController) DeleteDetail(c *gin.Context) {
	detailIDStr := c.Param("id")
	detailID, err := strconv.ParseUint(detailIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的ID",
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

	// 查找项目
	var item models.DetailItem
	if err := config.DB.First(&item, uint(detailID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "详情不存在",
				Error:   "Detail not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找详情失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
		}
		return
	}

	// 检查权限（只有创建者可以删除）
	if item.UserID != currentUser.ID {
		c.JSON(http.StatusForbidden, models.ErrorResponse{
			Success: false,
			Message: "无权限删除此详情",
			Error:   "Permission denied",
			Code:    http.StatusForbidden,
		})
		return
	}

	// 软删除
	if err := config.DB.Delete(&item).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "删除失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "删除成功",
	})
}

// GetDetailStats 获取详情统计
func (dc *DetailController) GetDetailStats(c *gin.Context) {
	var stats models.DetailStatsResponse

	// 统计总项目数
	config.DB.Model(&models.DetailItem{}).Count(&stats.TotalItems)

	// 统计草稿数
	config.DB.Model(&models.DetailItem{}).Where("status = ?", "draft").Count(&stats.DraftItems)

	// 统计已发布数
	config.DB.Model(&models.DetailItem{}).Where("status = ?", "published").Count(&stats.PublishedItems)

	// 统计总浏览数
	config.DB.Model(&models.DetailItem{}).Select("COALESCE(SUM(view_count), 0)").Scan(&stats.TotalViews)

	// 统计总点赞数
	config.DB.Model(&models.DetailItem{}).Select("COALESCE(SUM(like_count), 0)").Scan(&stats.TotalLikes)

	// 统计总评论数
	config.DB.Model(&models.DetailItem{}).Select("COALESCE(SUM(comment_count), 0)").Scan(&stats.TotalComments)

	// 统计总分享数
	config.DB.Model(&models.DetailItem{}).Select("COALESCE(SUM(share_count), 0)").Scan(&stats.TotalShares)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取统计成功",
		Data:    stats,
	})
}

// LikeDetail 点赞详情
func (dc *DetailController) LikeDetail(c *gin.Context) {
	detailIDStr := c.Param("id")
	detailID, err := strconv.ParseUint(detailIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 查找项目
	var item models.DetailItem
	if err := config.DB.First(&item, uint(detailID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "详情不存在",
				Error:   "Detail not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找详情失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
		}
		return
	}

	// 增加点赞数
	if err := config.DB.Model(&item).Update("like_count", item.LikeCount+1).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "点赞失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").First(&item, item.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "点赞成功",
		Data: models.DetailResponse{
			Item: item,
		},
	})
}

// ShareDetail 分享详情
func (dc *DetailController) ShareDetail(c *gin.Context) {
	detailIDStr := c.Param("id")
	detailID, err := strconv.ParseUint(detailIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 查找项目
	var item models.DetailItem
	if err := config.DB.First(&item, uint(detailID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "详情不存在",
				Error:   "Detail not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找详情失败",
				Error:   err.Error(),
				Code:    http.StatusInternalServerError,
			})
		}
		return
	}

	// 增加分享数
	if err := config.DB.Model(&item).Update("share_count", item.ShareCount+1).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "分享失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").First(&item, item.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "分享成功",
		Data: models.DetailResponse{
			Item: item,
		},
	})
}
