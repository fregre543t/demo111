package database

import (
	"chat-backend/internal/models"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

// InitDatabase 初始化数据库
func InitDatabase() error {
	var err error
	DB, err = gorm.Open(sqlite.Open("chat.db"), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return err
	}

	// 自动迁移模型
	err = DB.AutoMigrate(
		&models.User{},
		&models.Message{},
		&models.ChatRoom{},
		&models.RoomMessage{},
	)
	if err != nil {
		return err
	}

	log.Println("数据库初始化成功")
	return nil
}

// GetDB 获取数据库实例
func GetDB() *gorm.DB {
	return DB
}
