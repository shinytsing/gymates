package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"gymates-backend/models"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// ExerciseImport 用于导入的练习数据结构
type ExerciseImport struct {
	ID              int      `json:"id"`
	Name            string   `json:"name"`
	NameEn          string   `json:"name_en"`
	Description     string   `json:"description"`
	DescriptionEn   string   `json:"description_en"`
	PrimaryMuscle   string   `json:"primary_muscle"`
	PrimaryMuscleEn string   `json:"primary_muscle_en"`
	Equipment       string   `json:"equipment"`
	EquipmentEn     string   `json:"equipment_en"`
	Difficulty      string   `json:"difficulty"`
	Type            string   `json:"type"`
	Steps           []string `json:"steps"`
	Tips            []string `json:"tips"`
	CoverImage      string   `json:"cover_image"`
	VideoURL        string   `json:"video_url"`
	Tags            []string `json:"tags"`
	Category        string   `json:"category"`
	CaloriesPerHour int      `json:"calories_per_hour"`
	DurationMinutes int      `json:"duration_minutes"`
	Sets            int      `json:"sets"`
	Reps            int      `json:"reps"`
	RestSeconds     int      `json:"rest_seconds"`
}

func main() {
	fmt.Println("🏋️‍♀️ Gymates Exercise Library Importer")
	fmt.Println(strings.Repeat("=", 60))

	// 1. 连接数据库
	db, err := connectDatabase()
	if err != nil {
		log.Fatalf("❌ 连接数据库失败: %v", err)
	}

	// 2. 确保表存在
	if err := ensureTables(db); err != nil {
		log.Fatalf("❌ 创建表失败: %v", err)
	}

	// 3. 读取 JSON 文件
	jsonPath := filepath.Join("..", "seed", "seed_exercise_library.json")
	exercises, err := loadExercisesFromJSON(jsonPath)
	if err != nil {
		log.Fatalf("❌ 读取 JSON 文件失败: %v", err)
	}

	fmt.Printf("📥 共读取 %d 条健身动作数据\n", len(exercises))

	// 4. 转换并导入数据
	if err := importExercises(db, exercises); err != nil {
		log.Fatalf("❌ 导入数据失败: %v", err)
	}

	// 5. 统计信息
	printStatistics(db)

	fmt.Println("\n" + strings.Repeat("=", 60))
	fmt.Println("🎉 健身动作库导入完成！")
}

// connectDatabase 连接数据库
func connectDatabase() (*gorm.DB, error) {
	fmt.Println("🔌 连接数据库...")

	db, err := gorm.Open(sqlite.Open("gymates.db"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		return nil, fmt.Errorf("打开数据库失败: %w", err)
	}

	fmt.Println("✅ 数据库连接成功")
	return db, nil
}

// ensureTables 确保表存在
func ensureTables(db *gorm.DB) error {
	fmt.Println("📋 检查数据库表...")

	// 自动迁移
	if err := db.AutoMigrate(&models.ExerciseLibrary{}); err != nil {
		return fmt.Errorf("迁移表失败: %w", err)
	}

	fmt.Println("✅ 数据库表准备就绪")
	return nil
}

// loadExercisesFromJSON 从 JSON 文件加载数据
func loadExercisesFromJSON(filePath string) ([]ExerciseImport, error) {
	fmt.Printf("📖 读取文件: %s\n", filePath)

	// 检查文件是否存在
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return nil, fmt.Errorf("文件不存在: %s", filePath)
	}

	// 打开文件
	file, err := os.Open(filePath)
	if err != nil {
		return nil, fmt.Errorf("打开文件失败: %w", err)
	}
	defer file.Close()

	// 解析 JSON
	var exercises []ExerciseImport
	decoder := json.NewDecoder(file)
	if err := decoder.Decode(&exercises); err != nil {
		return nil, fmt.Errorf("解析 JSON 失败: %w", err)
	}

	return exercises, nil
}

// importExercises 导入练习数据
func importExercises(db *gorm.DB, exercises []ExerciseImport) error {
	fmt.Println("\n💾 开始导入数据...")

	// 询问是否清空现有数据
	fmt.Print("⚠️  是否清空现有健身动作数据？(y/n): ")
	var response string
	fmt.Scanln(&response)

	if response == "y" || response == "Y" {
		if err := db.Exec("DELETE FROM exercise_libraries").Error; err != nil {
			return fmt.Errorf("清空数据失败: %w", err)
		}
		fmt.Println("✅ 已清空现有数据")
	}

	// 转换数据格式
	var exerciseModels []models.ExerciseLibrary
	for _, ex := range exercises {
		// 将 []string 转换为 JSON 字符串
		stepsJSON, _ := json.Marshal(ex.Steps)
		tagsJSON, _ := json.Marshal(ex.Tags)

		// 映射难度级别
		level := ex.Difficulty
		if level == "" {
			level = "intermediate"
		}

		// 组合说明（步骤 + 提示）
		instructions := string(stepsJSON)

		model := models.ExerciseLibrary{
			Name:              ex.Name,
			Part:              ex.PrimaryMuscle,
			Level:             level,
			Type:              ex.Type,
			Equipment:         ex.Equipment,
			Tags:              string(tagsJSON),
			Description:       ex.Description,
			Instructions:      instructions,
			ImageURL:          ex.CoverImage,
			VideoURL:          ex.VideoURL,
			MuscleGroups:      ex.PrimaryMuscle,
			EstimatedCalories: ex.CaloriesPerHour / 12, // 每组预计消耗
			EstimatedDuration: ex.RestSeconds,           // 每组时长
		}

		exerciseModels = append(exerciseModels, model)
	}

	// 批量插入（每次100条）
	batchSize := 100
	for i := 0; i < len(exerciseModels); i += batchSize {
		end := i + batchSize
		if end > len(exerciseModels) {
			end = len(exerciseModels)
		}

		batch := exerciseModels[i:end]
		if err := db.Create(&batch).Error; err != nil {
			return fmt.Errorf("插入批次 %d-%d 失败: %w", i, end, err)
		}

		fmt.Printf("✅ 已导入 %d/%d 条数据\n", end, len(exerciseModels))
	}

	fmt.Printf("\n✅ 成功导入 %d 条健身动作数据\n", len(exerciseModels))
	return nil
}

// printStatistics 打印统计信息
func printStatistics(db *gorm.DB) {
	fmt.Println("\n" + strings.Repeat("=", 60))
	fmt.Println("📊 数据统计")
	fmt.Println(strings.Repeat("=", 60))

	// 总数
	var total int64
	db.Model(&models.ExerciseLibrary{}).Count(&total)
	fmt.Printf("✅ 总动作数: %d\n", total)

	// 按难度统计
	var difficulties []struct {
		Level string
		Count int64
	}
	db.Model(&models.ExerciseLibrary{}).
		Select("level, COUNT(*) as count").
		Group("level").
		Scan(&difficulties)

	fmt.Println("\n📈 按难度分布:")
	for _, d := range difficulties {
		fmt.Printf("  - %s: %d\n", d.Level, d.Count)
	}

	// 按类型统计
	var types []struct {
		Type  string
		Count int64
	}
	db.Model(&models.ExerciseLibrary{}).
		Select("type, COUNT(*) as count").
		Group("type").
		Scan(&types)

	fmt.Println("\n📈 按类型分布:")
	for _, t := range types {
		fmt.Printf("  - %s: %d\n", t.Type, t.Count)
	}

	// 按肌肉群统计
	var muscles []struct {
		Part  string
		Count int64
	}
	db.Model(&models.ExerciseLibrary{}).
		Select("part, COUNT(*) as count").
		Group("part").
		Order("count DESC").
		Limit(10).
		Scan(&muscles)

	fmt.Println("\n📈 Top 10 肌肉群:")
	for i, m := range muscles {
		fmt.Printf("  %d. %s: %d\n", i+1, m.Part, m.Count)
	}
}

