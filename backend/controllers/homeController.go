package controllers

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gymates-backend/config"
	"gymates-backend/models"
)

// HomeController 首页控制器
type HomeController struct{}

// NewHomeController 创建首页控制器
func NewHomeController() *HomeController {
	return &HomeController{}
}

// GetHomeList 获取首页列表
func (hc *HomeController) GetHomeList(c *gin.Context) {
	var req models.HomeListRequest
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

	var items []models.HomeItem
	var total int64

	// 构建查询
	query := config.DB.Model(&models.HomeItem{})

	// 添加筛选条件
	if req.Category != "" {
		query = query.Where("category = ?", req.Category)
	}
	if req.Status != "" {
		query = query.Where("status = ?", req.Status)
	}
	if req.Keyword != "" {
		query = query.Where("title LIKE ? OR description LIKE ? OR tags LIKE ?", 
			"%"+req.Keyword+"%", "%"+req.Keyword+"%", "%"+req.Keyword+"%")
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
	if err := query.Preload("User").
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
		Data: models.HomeListResponse{
			Items:      items,
			Pagination: pagination,
		},
	})
}

// AddHomeItem 新增首页项
func (hc *HomeController) AddHomeItem(c *gin.Context) {
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

	var req models.HomeAddRequest
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

	// 创建新项
	item := models.HomeItem{
		Title:       req.Title,
		Description: req.Description,
		Image:       req.Image,
		Category:    req.Category,
		Tags:        req.Tags,
		Priority:    req.Priority,
		UserID:      currentUser.ID,
		Status:      "active",
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
	config.DB.Preload("User").First(&item, item.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "创建成功",
		Data: models.HomeDetailResponse{
			Item: item,
		},
	})
}

// UpdateHomeItem 更新首页项
func (hc *HomeController) UpdateHomeItem(c *gin.Context) {
	itemIDStr := c.Param("id")
	itemID, err := strconv.ParseUint(itemIDStr, 10, 32)
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

	var req models.HomeUpdateRequest
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
	var item models.HomeItem
	if err := config.DB.First(&item, uint(itemID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "项目不存在",
				Error:   "Item not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找项目失败",
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
			Message: "无权限修改此项目",
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
	if req.Description != "" {
		updates["description"] = req.Description
	}
	if req.Image != "" {
		updates["image"] = req.Image
	}
	if req.Category != "" {
		updates["category"] = req.Category
	}
	if req.Tags != "" {
		updates["tags"] = req.Tags
	}
	if req.Status != "" {
		updates["status"] = req.Status
	}
	if req.Priority != 0 {
		updates["priority"] = req.Priority
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
	config.DB.Preload("User").First(&item, item.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "更新成功",
		Data: models.HomeDetailResponse{
			Item: item,
		},
	})
}

// DeleteHomeItem 删除首页项
func (hc *HomeController) DeleteHomeItem(c *gin.Context) {
	itemIDStr := c.Param("id")
	itemID, err := strconv.ParseUint(itemIDStr, 10, 32)
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
	var item models.HomeItem
	if err := config.DB.First(&item, uint(itemID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "项目不存在",
				Error:   "Item not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找项目失败",
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
			Message: "无权限删除此项目",
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

// GetHomeItem 获取首页项详情
func (hc *HomeController) GetHomeItem(c *gin.Context) {
	itemIDStr := c.Param("id")
	itemID, err := strconv.ParseUint(itemIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的ID",
			Error:   err.Error(),
			Code:    http.StatusBadRequest,
		})
		return
	}

	var item models.HomeItem
	if err := config.DB.Preload("User").First(&item, uint(itemID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "项目不存在",
				Error:   "Item not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "获取项目失败",
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
		Data: models.HomeDetailResponse{
			Item: item,
		},
	})
}

// GetHomeStats 获取首页统计
func (hc *HomeController) GetHomeStats(c *gin.Context) {
	var stats models.HomeStatsResponse

	// 统计总项目数
	config.DB.Model(&models.HomeItem{}).Count(&stats.TotalItems)

	// 统计活跃项目数
	config.DB.Model(&models.HomeItem{}).Where("status = ?", "active").Count(&stats.ActiveItems)

	// 统计总浏览数
	config.DB.Model(&models.HomeItem{}).Select("COALESCE(SUM(view_count), 0)").Scan(&stats.TotalViews)

	// 统计总点赞数
	config.DB.Model(&models.HomeItem{}).Select("COALESCE(SUM(like_count), 0)").Scan(&stats.TotalLikes)

	// 统计总评论数
	config.DB.Model(&models.HomeItem{}).Select("COALESCE(SUM(comment_count), 0)").Scan(&stats.TotalComments)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取统计成功",
		Data:    stats,
	})
}

// LikeHomeItem 点赞首页项
func (hc *HomeController) LikeHomeItem(c *gin.Context) {
	itemIDStr := c.Param("id")
	itemID, err := strconv.ParseUint(itemIDStr, 10, 32)
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
	var item models.HomeItem
	if err := config.DB.First(&item, uint(itemID)).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, models.ErrorResponse{
				Success: false,
				Message: "项目不存在",
				Error:   "Item not found",
				Code:    http.StatusNotFound,
			})
		} else {
			c.JSON(http.StatusInternalServerError, models.ErrorResponse{
				Success: false,
				Message: "查找项目失败",
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
		Data: models.HomeDetailResponse{
			Item: item,
		},
	})
}
