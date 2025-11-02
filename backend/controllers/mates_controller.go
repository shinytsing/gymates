package controllers

import (
	"math"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gymates-backend/config"
	"gymates-backend/models"
)

// MatesController 搭子控制器
type MatesController struct{}

// NewMatesController 创建搭子控制器
func NewMatesController() *MatesController {
	return &MatesController{}
}

// GetMates 获取搭子列表
func (mc *MatesController) GetMates(c *gin.Context) {
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

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))

	currentUser := user.(*models.User)

	var mates []models.User
	var total int64

	// 获取当前用户的搭子
	query := config.DB.Table("users").
		Joins("JOIN mates ON users.id = mates.mate_id").
		Where("mates.user_id = ? AND mates.status = ?", currentUser.ID, "accepted")

	// 获取总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Offset(offset).Limit(limit).Find(&mates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取搭子列表失败",
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
		Message: "获取搭子列表成功",
		Data: models.MatesResponse{
			Mates:      mates,
			Pagination: pagination,
		},
	})
}

// GetMateRequests 获取搭子请求
func (mc *MatesController) GetMateRequests(c *gin.Context) {
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

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	requestType := c.DefaultQuery("type", "received") // received or sent

	currentUser := user.(*models.User)

	var requests []models.Mate
	var total int64

	var query *gorm.DB
	if requestType == "received" {
		// 收到的请求
		query = config.DB.Where("mate_id = ? AND status = ?", currentUser.ID, "pending")
	} else {
		// 发送的请求
		query = config.DB.Where("user_id = ? AND status = ?", currentUser.ID, "pending")
	}

	// 获取总数
	query.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := query.Preload("User").Preload("Mate").
		Offset(offset).Limit(limit).Order("created_at DESC").Find(&requests).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取搭子请求失败",
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
		Message: "获取搭子请求成功",
		Data: models.PaginationResponse{
			Data:       requests,
			Pagination: pagination,
		},
	})
}

// SendMateRequest 发送搭子请求
func (mc *MatesController) SendMateRequest(c *gin.Context) {
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

	var req models.SendMateRequestRequest
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

	// 不能添加自己为搭子
	if req.MateID == currentUser.ID {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "不能添加自己为搭子",
			Error:   "Cannot add yourself as mate",
			Code:    http.StatusBadRequest,
		})
		return
	}

	// 检查目标用户是否存在
	var targetUser models.User
	if err := config.DB.First(&targetUser, req.MateID).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "目标用户不存在",
			Error:   "Target user not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 检查是否已经存在关系
	var existingMate models.Mate
	if err := config.DB.Where("user_id = ? AND mate_id = ?", currentUser.ID, req.MateID).
		First(&existingMate).Error; err == nil {
		c.JSON(http.StatusConflict, models.ErrorResponse{
			Success: false,
			Message: "搭子关系已存在",
			Error:   "Mate relationship already exists",
			Code:    http.StatusConflict,
		})
		return
	}

	// 创建搭子请求
	mate := models.Mate{
		UserID: currentUser.ID,
		MateID: req.MateID,
		Status: "pending",
	}

	if err := config.DB.Create(&mate).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "发送搭子请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 重新加载数据
	config.DB.Preload("User").Preload("Mate").First(&mate, mate.ID)

	c.JSON(http.StatusCreated, models.SuccessResponse{
		Success: true,
		Message: "发送搭子请求成功",
		Data:    mate,
	})
}

// AcceptMateRequest 接受搭子请求
func (mc *MatesController) AcceptMateRequest(c *gin.Context) {
	requestIDStr := c.Param("id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的请求ID",
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

	// 查找搭子请求
	var mate models.Mate
	if err := config.DB.Where("id = ? AND mate_id = ? AND status = ?", uint(requestID), currentUser.ID, "pending").
		First(&mate).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "搭子请求不存在",
			Error:   "Mate request not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 更新状态为已接受
	if err := config.DB.Model(&mate).Update("status", "accepted").Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "接受搭子请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 创建反向关系
	reverseMate := models.Mate{
		UserID: currentUser.ID,
		MateID: mate.UserID,
		Status: "accepted",
	}
	config.DB.Create(&reverseMate)

	// 重新加载数据
	config.DB.Preload("User").Preload("Mate").First(&mate, mate.ID)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "接受搭子请求成功",
		Data:    mate,
	})
}

// RejectMateRequest 拒绝搭子请求
func (mc *MatesController) RejectMateRequest(c *gin.Context) {
	requestIDStr := c.Param("id")
	requestID, err := strconv.ParseUint(requestIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的请求ID",
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

	// 查找搭子请求
	var mate models.Mate
	if err := config.DB.Where("id = ? AND mate_id = ? AND status = ?", uint(requestID), currentUser.ID, "pending").
		First(&mate).Error; err != nil {
		c.JSON(http.StatusNotFound, models.ErrorResponse{
			Success: false,
			Message: "搭子请求不存在",
			Error:   "Mate request not found",
			Code:    http.StatusNotFound,
		})
		return
	}

	// 更新状态为已拒绝
	if err := config.DB.Model(&mate).Update("status", "rejected").Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "拒绝搭子请求失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "拒绝搭子请求成功",
	})
}

// RemoveMate 移除搭子
func (mc *MatesController) RemoveMate(c *gin.Context) {
	mateIDStr := c.Param("id")
	mateID, err := strconv.ParseUint(mateIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, models.ErrorResponse{
			Success: false,
			Message: "无效的搭子ID",
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

	// 删除搭子关系（双向）
	if err := config.DB.Where("user_id = ? AND mate_id = ?", currentUser.ID, uint(mateID)).
		Delete(&models.Mate{}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "移除搭子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 删除反向关系
	config.DB.Where("user_id = ? AND mate_id = ?", uint(mateID), currentUser.ID).
		Delete(&models.Mate{})

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "移除搭子成功",
	})
}

// SearchMates 搜索搭子
func (mc *MatesController) SearchMates(c *gin.Context) {
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

	var users []models.User
	var total int64

	// 搜索用户
	searchQuery := config.DB.Model(&models.User{}).Where("name LIKE ? OR bio LIKE ?", "%"+query+"%", "%"+query+"%")

	// 获取总数
	searchQuery.Count(&total)

	// 分页查询
	offset := (page - 1) * limit
	if err := searchQuery.Offset(offset).Limit(limit).Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "搜索搭子失败",
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
		Message: "搜索搭子成功",
		Data: models.MatesResponse{
			Mates:      users,
			Pagination: pagination,
		},
	})
}

// GetMateStats 获取搭子统计
func (mc *MatesController) GetMateStats(c *gin.Context) {
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

	var stats struct {
		TotalMates      int64 `json:"total_mates"`
		PendingRequests int64 `json:"pending_requests"`
		SentRequests    int64 `json:"sent_requests"`
	}

	// 统计搭子数量
	config.DB.Model(&models.Mate{}).Where("user_id = ? AND status = ?", currentUser.ID, "accepted").Count(&stats.TotalMates)

	// 统计待处理的请求
	config.DB.Model(&models.Mate{}).Where("mate_id = ? AND status = ?", currentUser.ID, "pending").Count(&stats.PendingRequests)

	// 统计发送的请求
	config.DB.Model(&models.Mate{}).Where("user_id = ? AND status = ?", currentUser.ID, "pending").Count(&stats.SentRequests)

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取搭子统计成功",
		Data:    stats,
	})
}

// GetMateRecommendations 获取搭子推荐
func (mc *MatesController) GetMateRecommendations(c *gin.Context) {
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

	// 解析请求参数
	var req models.MateRecommendationRequest
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
	if req.MaxDistance == 0 {
		req.MaxDistance = 5000 // 默认5公里
	}
	if req.Page == 0 {
		req.Page = 1
	}
	if req.Limit == 0 {
		req.Limit = 20
	}

	// 构建查询
	query := config.DB.Model(&models.User{}).
		Where("id != ? AND looking_for_mate = ?", currentUser.ID, true)

	// 性别过滤
	if req.Gender != "" {
		query = query.Where("gender = ?", req.Gender)
	}

	// 经验等级过滤
	if req.Experience != "" {
		query = query.Where("experience = ?", req.Experience)
	}

	// 健身目标过滤
	if len(req.Goals) > 0 {
		goalConditions := make([]string, len(req.Goals))
		for i := range req.Goals {
			goalConditions[i] = "goal = ?"
		}
		goalArgs := make([]interface{}, len(req.Goals))
		for i, goal := range req.Goals {
			goalArgs[i] = goal
		}
		query = query.Where(strings.Join(goalConditions, " OR "), goalArgs...)
	}

	// 偏好时间过滤
	if req.PreferredTime != "" {
		query = query.Where("preferred_time LIKE ?", "%"+req.PreferredTime+"%")
	}

	// 获取候选用户
	var candidates []models.User
	var total int64

	query.Count(&total)

	offset := (req.Page - 1) * req.Limit
	if err := query.Offset(offset).Limit(req.Limit).Find(&candidates).Error; err != nil {
		c.JSON(http.StatusInternalServerError, models.ErrorResponse{
			Success: false,
			Message: "获取推荐搭子失败",
			Error:   err.Error(),
			Code:    http.StatusInternalServerError,
		})
		return
	}

	// 计算距离和匹配度
	recommendations := make([]models.MateProfile, 0, len(candidates))
	for _, candidate := range candidates {
		// 计算距离（如果有位置信息）
		distance := mc.calculateDistance(
			currentUser.Latitude, currentUser.Longitude,
			candidate.Latitude, candidate.Longitude,
		)

		// 跳过超出距离限制的用户
		if distance > float64(req.MaxDistance) {
			continue
		}

		// 计算匹配度分数
		matchScore := mc.calculateMatchScore(currentUser, &candidate)

		// 计算共同目标和类型
		commonGoals := mc.findCommonItems(currentUser.Goal, candidate.Goal)
		commonTypes := mc.findCommonItems(currentUser.TrainingTypes, candidate.TrainingTypes)

		profile := models.MateProfile{
			User:         candidate,
			Distance:     distance,
			MatchScore:   matchScore,
			CommonGoals:  commonGoals,
			CommonTypes:  commonTypes,
			IsOnline:     false, // TODO: 实现在线状态
			LastActiveAt: candidate.UpdatedAt.Format("2006-01-02 15:04:05"),
		}

		recommendations = append(recommendations, profile)
	}

	// 按匹配度和距离排序
	mc.sortRecommendations(recommendations)

	pagination := models.Pagination{
		Page:       req.Page,
		Limit:      req.Limit,
		Total:      int64(len(recommendations)),
		TotalPages: int((int64(len(recommendations)) + int64(req.Limit) - 1) / int64(req.Limit)),
		HasMore:    int64(req.Page*req.Limit) < int64(len(recommendations)),
	}

	c.JSON(http.StatusOK, models.SuccessResponse{
		Success: true,
		Message: "获取推荐搭子成功",
		Data: map[string]interface{}{
			"recommendations": recommendations,
			"pagination":      pagination,
		},
	})
}

// calculateDistance 计算两点间距离（使用Haversine公式）
func (mc *MatesController) calculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	// 如果坐标不完整，返回无穷大
	if lat1 == 0 || lon1 == 0 || lat2 == 0 || lon2 == 0 {
		return math.MaxFloat64
	}

	const earthRadius = 6371000 // 地球半径（米）

	// 转换为弧度
	lat1Rad := lat1 * math.Pi / 180
	lat2Rad := lat2 * math.Pi / 180
	deltaLat := (lat2 - lat1) * math.Pi / 180
	deltaLon := (lon2 - lon1) * math.Pi / 180

	// Haversine公式
	a := math.Sin(deltaLat/2)*math.Sin(deltaLat/2) +
		math.Cos(lat1Rad)*math.Cos(lat2Rad)*
			math.Sin(deltaLon/2)*math.Sin(deltaLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

	return earthRadius * c
}

// calculateMatchScore 计算匹配度分数
func (mc *MatesController) calculateMatchScore(user *models.User, candidate *models.User) int {
	score := 50 // 基础分数

	// 相同健身目标 +20分
	if user.Goal == candidate.Goal && user.Goal != "" {
		score += 20
	}

	// 相同经验等级 +15分
	if user.Experience == candidate.Experience && user.Experience != "" {
		score += 15
	}

	// 年龄相近 +10分
	if user.Age > 0 && candidate.Age > 0 {
		ageDiff := math.Abs(float64(user.Age - candidate.Age))
		if ageDiff <= 5 {
			score += 10
		} else if ageDiff <= 10 {
			score += 5
		}
	}

	// 训练类型匹配 +5分
	if user.TrainingTypes != "" && candidate.TrainingTypes != "" {
		userTypes := strings.Split(user.TrainingTypes, ",")
		candTypes := strings.Split(candidate.TrainingTypes, ",")
		for _, ut := range userTypes {
			for _, ct := range candTypes {
				if strings.TrimSpace(ut) == strings.TrimSpace(ct) {
					score += 5
					break
				}
			}
		}
	}

	// 确保分数在0-100之间
	if score > 100 {
		score = 100
	}

	return score
}

// findCommonItems 查找共同项
func (mc *MatesController) findCommonItems(items1, items2 string) []string {
	if items1 == "" || items2 == "" {
		return []string{}
	}

	list1 := strings.Split(items1, ",")
	list2 := strings.Split(items2, ",")

	common := []string{}
	for _, item1 := range list1 {
		for _, item2 := range list2 {
			if strings.TrimSpace(item1) == strings.TrimSpace(item2) {
				common = append(common, strings.TrimSpace(item1))
				break
			}
		}
	}

	return common
}

// sortRecommendations 对推荐结果排序
func (mc *MatesController) sortRecommendations(recommendations []models.MateProfile) {
	// 按匹配度降序，匹配度相同时按距离升序
	for i := 0; i < len(recommendations)-1; i++ {
		for j := i + 1; j < len(recommendations); j++ {
			if recommendations[i].MatchScore < recommendations[j].MatchScore ||
				(recommendations[i].MatchScore == recommendations[j].MatchScore &&
					recommendations[i].Distance > recommendations[j].Distance) {
				recommendations[i], recommendations[j] = recommendations[j], recommendations[i]
			}
		}
	}
}
