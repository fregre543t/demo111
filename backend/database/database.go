package database

import (
	"chat-app-backend/config"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var DB *gorm.DB

func InitDB() *gorm.DB {
	cfg := config.Load()
	
	db, err := gorm.Open(sqlite.Open(cfg.DBPath), &gorm.Config{})
	if err != nil {
		log.Fatal("数据库连接失败:", err)
	}

	DB = db
	return db
}

func GetDB() *gorm.DB {
	return DB
}
