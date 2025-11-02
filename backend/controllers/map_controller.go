package controllers

import (
	"net/http"
	"strconv"

	"gymates-backend/services"

	"github.com/gin-gonic/gin"
)

// MapController 地图控制器
type MapController struct {
	amapService *services.AmapService
}

// NewMapController 创建地图控制器
func NewMapController() *MapController {
	return &MapController{
		amapService: services.NewAmapService(),
	}
}

// LocationRequest 位置请求
type LocationRequest struct {
	Address string `json:"address" binding:"required"`
}

// NearbyGymsRequest 附近健身房请求
type NearbyGymsRequest struct {
	Latitude  float64 `json:"latitude" binding:"required"`
	Longitude float64 `json:"longitude" binding:"required"`
	Radius    int     `json:"radius,omitempty"` // 默认3000米
}

// DistanceRequest 距离计算请求
type DistanceRequest struct {
	OriginLat      float64 `json:"origin_lat" binding:"required"`
	OriginLng      float64 `json:"origin_lng" binding:"required"`
	DestinationLat float64 `json:"destination_lat" binding:"required"`
	DestinationLng float64 `json:"destination_lng" binding:"required"`
}

// CityGymsRequest 城市健身房搜索请求
type CityGymsRequest struct {
	City     string `form:"city" binding:"required"`
	Page     int    `form:"page,omitempty"`
	PageSize int    `form:"page_size,omitempty"`
}

// GeocodeAddress 地理编码
// @Summary 地理编码
// @Description 将地址转换为经纬度
// @Tags Map
// @Accept json
// @Produce json
// @Param request body LocationRequest true "位置请求"
// @Success 200 {object} services.Location
// @Router /api/map/geocode [post]
func (c *MapController) GeocodeAddress(ctx *gin.Context) {
	var req LocationRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid request: " + err.Error(),
		})
		return
	}

	location, err := c.amapService.GeocodeAddress(req.Address)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to geocode address: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success":  true,
		"location": location,
	})
}

// SearchNearbyGyms 搜索附近健身房
// @Summary 搜索附近健身房
// @Description 根据位置和半径搜索附近的健身房
// @Tags Map
// @Accept json
// @Produce json
// @Param request body NearbyGymsRequest true "附近健身房请求"
// @Success 200 {array} services.Gym
// @Router /api/map/gyms/nearby [post]
func (c *MapController) SearchNearbyGyms(ctx *gin.Context) {
	var req NearbyGymsRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid request: " + err.Error(),
		})
		return
	}

	// 默认半径3000米
	if req.Radius == 0 {
		req.Radius = 3000
	}

	location := services.Location{
		Latitude:  req.Latitude,
		Longitude: req.Longitude,
	}

	gyms, err := c.amapService.SearchNearbyGyms(location, req.Radius)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to search gyms: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"gyms":    gyms,
		"count":   len(gyms),
	})
}

// CalculateDistance 计算距离
// @Summary 计算距离
// @Description 计算两个位置之间的距离
// @Tags Map
// @Accept json
// @Produce json
// @Param request body DistanceRequest true "距离请求"
// @Success 200 {object} services.DistanceResult
// @Router /api/map/distance [post]
func (c *MapController) CalculateDistance(ctx *gin.Context) {
	var req DistanceRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "Invalid request: " + err.Error(),
		})
		return
	}

	origin := services.Location{
		Latitude:  req.OriginLat,
		Longitude: req.OriginLng,
	}

	destination := services.Location{
		Latitude:  req.DestinationLat,
		Longitude: req.DestinationLng,
	}

	result, err := c.amapService.CalculateDistance(origin, destination)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to calculate distance: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"result":  result,
	})
}

// GetGymDetails 获取健身房详情
// @Summary 获取健身房详情
// @Description 根据POI ID获取健身房详细信息
// @Tags Map
// @Produce json
// @Param id path string true "POI ID"
// @Success 200 {object} services.Gym
// @Router /api/map/gyms/{id} [get]
func (c *MapController) GetGymDetails(ctx *gin.Context) {
	poiID := ctx.Param("id")
	if poiID == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "POI ID is required",
		})
		return
	}

	gym, err := c.amapService.GetGymDetails(poiID)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to get gym details: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success": true,
		"gym":     gym,
	})
}

// SearchGymsByCity 按城市搜索健身房
// @Summary 按城市搜索健身房
// @Description 根据城市名称搜索健身房
// @Tags Map
// @Produce json
// @Param city query string true "城市名称"
// @Param page query int false "页码"
// @Param page_size query int false "每页数量"
// @Success 200 {array} services.Gym
// @Router /api/map/gyms/city [get]
func (c *MapController) SearchGymsByCity(ctx *gin.Context) {
	city := ctx.Query("city")
	if city == "" {
		ctx.JSON(http.StatusBadRequest, gin.H{
			"success": false,
			"message": "City parameter is required",
		})
		return
	}

	page := 1
	if pageStr := ctx.Query("page"); pageStr != "" {
		if p, err := strconv.Atoi(pageStr); err == nil {
			page = p
		}
	}

	pageSize := 20
	if sizeStr := ctx.Query("page_size"); sizeStr != "" {
		if s, err := strconv.Atoi(sizeStr); err == nil {
			pageSize = s
		}
	}

	gyms, err := c.amapService.SearchGymsByCity(city, page, pageSize)
	if err != nil {
		ctx.JSON(http.StatusInternalServerError, gin.H{
			"success": false,
			"message": "Failed to search gyms: " + err.Error(),
		})
		return
	}

	ctx.JSON(http.StatusOK, gin.H{
		"success":   true,
		"gyms":      gyms,
		"count":     len(gyms),
		"page":      page,
		"page_size": pageSize,
	})
}
