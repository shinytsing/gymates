package services

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"time"
)

// AmapService 高德地图服务
type AmapService struct {
	APIKey  string
	BaseURL string
	Client  *http.Client
}

// Location 位置信息
type Location struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
	Address   string  `json:"address,omitempty"`
	City      string  `json:"city,omitempty"`
	District  string  `json:"district,omitempty"`
}

// Gym 健身房信息
type Gym struct {
	ID        string   `json:"id"`
	Name      string   `json:"name"`
	Address   string   `json:"address"`
	Location  Location `json:"location"`
	Distance  float64  `json:"distance"` // 距离（米）
	Phone     string   `json:"phone"`
	Rating    float64  `json:"rating"`
	Photos    []string `json:"photos"`
	Tags      []string `json:"tags"`
	OpenHours string   `json:"open_hours"`
}

// DistanceResult 距离计算结果
type DistanceResult struct {
	Distance float64 `json:"distance"` // 米
	Duration int     `json:"duration"` // 秒
	Route    string  `json:"route"`    // 路线描述
}

// AmapGeoResponse 高德地图地理编码响应
type AmapGeoResponse struct {
	Status   string `json:"status"`
	Info     string `json:"info"`
	Geocodes []struct {
		FormattedAddress string `json:"formatted_address"`
		Province         string `json:"province"`
		City             string `json:"city"`
		District         string `json:"district"`
		Location         string `json:"location"` // "经度,纬度"
	} `json:"geocodes"`
}

// AmapPOIResponse 高德地图POI搜索响应
type AmapPOIResponse struct {
	Status string `json:"status"`
	Info   string `json:"info"`
	Count  string `json:"count"`
	Pois   []struct {
		ID       string `json:"id"`
		Name     string `json:"name"`
		Type     string `json:"type"`
		Address  string `json:"address"`
		Location string `json:"location"` // "经度,纬度"
		Tel      string `json:"tel"`
		Distance string `json:"distance"`
		Photos   []struct {
			URL string `json:"url"`
		} `json:"photos"`
	} `json:"pois"`
}

// AmapDistanceResponse 高德地图距离计算响应
type AmapDistanceResponse struct {
	Status  string `json:"status"`
	Info    string `json:"info"`
	Results []struct {
		OriginID string `json:"origin_id"`
		DestID   string `json:"dest_id"`
		Distance string `json:"distance"` // 米
		Duration string `json:"duration"` // 秒
	} `json:"results"`
}

// NewAmapService 创建高德地图服务实例
func NewAmapService() *AmapService {
	apiKey := os.Getenv("AMAP_API_KEY")
	baseURL := os.Getenv("AMAP_API_URL")

	if baseURL == "" {
		baseURL = "https://restapi.amap.com/v3"
	}

	return &AmapService{
		APIKey:  apiKey,
		BaseURL: baseURL,
		Client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// GeocodeAddress 地理编码：将地址转换为经纬度
func (s *AmapService) GeocodeAddress(address string) (*Location, error) {
	if s.APIKey == "" {
		return nil, fmt.Errorf("Amap API key not configured")
	}

	// 构建请求URL
	params := url.Values{}
	params.Add("key", s.APIKey)
	params.Add("address", address)

	url := fmt.Sprintf("%s/geocode/geo?%s", s.BaseURL, params.Encode())

	// 发送请求
	resp, err := s.Client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// 解析响应
	var geoResp AmapGeoResponse
	if err := json.Unmarshal(body, &geoResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	if geoResp.Status != "1" || len(geoResp.Geocodes) == 0 {
		return nil, fmt.Errorf("geocoding failed: %s", geoResp.Info)
	}

	// 解析经纬度
	geocode := geoResp.Geocodes[0]
	var lng, lat float64
	fmt.Sscanf(geocode.Location, "%f,%f", &lng, &lat)

	return &Location{
		Latitude:  lat,
		Longitude: lng,
		Address:   geocode.FormattedAddress,
		City:      geocode.City,
		District:  geocode.District,
	}, nil
}

// SearchNearbyGyms 搜索附近的健身房
func (s *AmapService) SearchNearbyGyms(location Location, radius int) ([]Gym, error) {
	if s.APIKey == "" {
		return nil, fmt.Errorf("Amap API key not configured")
	}

	// 构建请求URL
	params := url.Values{}
	params.Add("key", s.APIKey)
	params.Add("keywords", "健身房|健身中心|健身俱乐部|gym")
	params.Add("location", fmt.Sprintf("%f,%f", location.Longitude, location.Latitude))
	params.Add("radius", strconv.Itoa(radius))
	params.Add("sortrule", "distance") // 按距离排序
	params.Add("offset", "20")         // 返回数量
	params.Add("extensions", "all")    // 返回详细信息

	url := fmt.Sprintf("%s/place/around?%s", s.BaseURL, params.Encode())

	// 发送请求
	resp, err := s.Client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// 解析响应
	var poiResp AmapPOIResponse
	if err := json.Unmarshal(body, &poiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	if poiResp.Status != "1" {
		return nil, fmt.Errorf("POI search failed: %s", poiResp.Info)
	}

	// 转换为Gym结构
	gyms := make([]Gym, 0, len(poiResp.Pois))
	for _, poi := range poiResp.Pois {
		var lng, lat, dist float64
		fmt.Sscanf(poi.Location, "%f,%f", &lng, &lat)

		if poi.Distance != "" {
			dist, _ = strconv.ParseFloat(poi.Distance, 64)
		}

		photos := make([]string, 0)
		for _, photo := range poi.Photos {
			photos = append(photos, photo.URL)
		}

		gym := Gym{
			ID:      poi.ID,
			Name:    poi.Name,
			Address: poi.Address,
			Location: Location{
				Latitude:  lat,
				Longitude: lng,
			},
			Distance: dist,
			Phone:    poi.Tel,
			Photos:   photos,
		}

		gyms = append(gyms, gym)
	}

	return gyms, nil
}

// CalculateDistance 计算两点之间的距离
func (s *AmapService) CalculateDistance(origin Location, destination Location) (*DistanceResult, error) {
	if s.APIKey == "" {
		return nil, fmt.Errorf("Amap API key not configured")
	}

	// 构建请求URL
	params := url.Values{}
	params.Add("key", s.APIKey)
	params.Add("origins", fmt.Sprintf("%f,%f", origin.Longitude, origin.Latitude))
	params.Add("destination", fmt.Sprintf("%f,%f", destination.Longitude, destination.Latitude))
	params.Add("type", "1") // 驾车距离

	url := fmt.Sprintf("%s/distance?%s", s.BaseURL, params.Encode())

	// 发送请求
	resp, err := s.Client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// 解析响应
	var distResp AmapDistanceResponse
	if err := json.Unmarshal(body, &distResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	if distResp.Status != "1" || len(distResp.Results) == 0 {
		return nil, fmt.Errorf("distance calculation failed: %s", distResp.Info)
	}

	result := distResp.Results[0]
	distance, _ := strconv.ParseFloat(result.Distance, 64)
	duration, _ := strconv.Atoi(result.Duration)

	return &DistanceResult{
		Distance: distance,
		Duration: duration,
		Route:    fmt.Sprintf("距离: %.2f 公里, 预计时间: %d 分钟", distance/1000, duration/60),
	}, nil
}

// GetGymDetails 获取健身房详情
func (s *AmapService) GetGymDetails(poiID string) (*Gym, error) {
	if s.APIKey == "" {
		return nil, fmt.Errorf("Amap API key not configured")
	}

	// 构建请求URL
	params := url.Values{}
	params.Add("key", s.APIKey)
	params.Add("id", poiID)
	params.Add("extensions", "all")

	url := fmt.Sprintf("%s/place/detail?%s", s.BaseURL, params.Encode())

	// 发送请求
	resp, err := s.Client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// 解析响应
	var poiResp AmapPOIResponse
	if err := json.Unmarshal(body, &poiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	if poiResp.Status != "1" || len(poiResp.Pois) == 0 {
		return nil, fmt.Errorf("POI detail failed: %s", poiResp.Info)
	}

	poi := poiResp.Pois[0]
	var lng, lat float64
	fmt.Sscanf(poi.Location, "%f,%f", &lng, &lat)

	photos := make([]string, 0)
	for _, photo := range poi.Photos {
		photos = append(photos, photo.URL)
	}

	return &Gym{
		ID:      poi.ID,
		Name:    poi.Name,
		Address: poi.Address,
		Location: Location{
			Latitude:  lat,
			Longitude: lng,
		},
		Phone:  poi.Tel,
		Photos: photos,
	}, nil
}

// SearchGymsByCity 按城市搜索健身房
func (s *AmapService) SearchGymsByCity(city string, page int, pageSize int) ([]Gym, error) {
	if s.APIKey == "" {
		return nil, fmt.Errorf("Amap API key not configured")
	}

	// 构建请求URL
	params := url.Values{}
	params.Add("key", s.APIKey)
	params.Add("keywords", "健身房|健身中心|健身俱乐部")
	params.Add("city", city)
	params.Add("offset", strconv.Itoa(pageSize))
	params.Add("page", strconv.Itoa(page))
	params.Add("extensions", "all")

	url := fmt.Sprintf("%s/place/text?%s", s.BaseURL, params.Encode())

	// 发送请求
	resp, err := s.Client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// 解析响应
	var poiResp AmapPOIResponse
	if err := json.Unmarshal(body, &poiResp); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response: %w", err)
	}

	if poiResp.Status != "1" {
		return nil, fmt.Errorf("POI search failed: %s", poiResp.Info)
	}

	// 转换为Gym结构
	gyms := make([]Gym, 0, len(poiResp.Pois))
	for _, poi := range poiResp.Pois {
		var lng, lat float64
		fmt.Sscanf(poi.Location, "%f,%f", &lng, &lat)

		photos := make([]string, 0)
		for _, photo := range poi.Photos {
			photos = append(photos, photo.URL)
		}

		gym := Gym{
			ID:      poi.ID,
			Name:    poi.Name,
			Address: poi.Address,
			Location: Location{
				Latitude:  lat,
				Longitude: lng,
			},
			Phone:  poi.Tel,
			Photos: photos,
		}

		gyms = append(gyms, gym)
	}

	return gyms, nil
}
