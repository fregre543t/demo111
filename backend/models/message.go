package models

import (
	"time"

	"gorm.io/gorm"
)

type Message struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	RoomID    uint           `json:"room_id" gorm:"not null;index"`
	UserID    uint           `json:"user_id" gorm:"not null;index"`
	User      User           `json:"user" gorm:"foreignKey:UserID"`
	Content   string         `json:"content" gorm:"type:text;not null"`
	Type      string         `json:"type" gorm:"default:text"` // text, image, file
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}
