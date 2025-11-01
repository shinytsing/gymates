package routes

import (
	"gymates-backend/controllers"
	"gymates-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupMapRoutes 设置地图服务路由
func SetupMapRoutes(api *gin.RouterGroup) {
	mapController := controllers.NewMapController()

	mapGroup := api.Group("/map")
	{
		// 地理编码
		mapGroup.POST("/geocode", middleware.AuthMiddleware(), mapController.GeocodeAddress)

		// 搜索附近健身房
		mapGroup.POST("/gyms/nearby", middleware.AuthMiddleware(), mapController.SearchNearbyGyms)

		// 计算距离
		mapGroup.POST("/distance", middleware.AuthMiddleware(), mapController.CalculateDistance)

		// 获取健身房详情
		mapGroup.GET("/gyms/:id", middleware.AuthMiddleware(), mapController.GetGymDetails)

		// 按城市搜索健身房
		mapGroup.GET("/gyms/city", middleware.AuthMiddleware(), mapController.SearchGymsByCity)
	}
}

