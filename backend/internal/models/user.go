package models

import (
	"time"
	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        uint           `gorm:"primarykey" json:"id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Username  string         `gorm:"uniqueIndex;not null" json:"username"`
	Password  string         `gorm:"not null" json:"-"`
	Nickname  string         `json:"nickname"`
	Avatar    string         `json:"avatar"`
	IsOnline  bool           `gorm:"default:false" json:"is_online"`
	IsAdmin   bool           `gorm:"default:false" json:"is_admin"`
	LastSeen  time.Time      `json:"last_seen"`
}

// Message 消息模型
type Message struct {
	ID         uint      `gorm:"primarykey" json:"id"`
	CreatedAt  time.Time `json:"created_at"`
	FromUserID uint      `gorm:"not null;index" json:"from_user_id"`
	ToUserID   uint      `gorm:"not null;index" json:"to_user_id"`
	Content    string    `gorm:"type:text;not null" json:"content"`
	MessageType string   `gorm:"default:'text'" json:"message_type"` // text, image, file
	IsRead     bool      `gorm:"default:false" json:"is_read"`
	FromUser   User      `gorm:"foreignKey:FromUserID" json:"from_user,omitempty"`
	ToUser     User      `gorm:"foreignKey:ToUserID" json:"to_user,omitempty"`
}

// ChatRoom 聊天室模型（群聊）
type ChatRoom struct {
	ID        uint           `gorm:"primarykey" json:"id"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
	Name      string         `gorm:"not null" json:"name"`
	CreatorID uint           `json:"creator_id"`
	Creator   User           `gorm:"foreignKey:CreatorID" json:"creator,omitempty"`
}

// RoomMessage 聊天室消息
type RoomMessage struct {
	ID        uint      `gorm:"primarykey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	RoomID    uint      `gorm:"not null;index" json:"room_id"`
	UserID    uint      `gorm:"not null;index" json:"user_id"`
	Content   string    `gorm:"type:text;not null" json:"content"`
	MessageType string  `gorm:"default:'text'" json:"message_type"`
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Room      ChatRoom  `gorm:"foreignKey:RoomID" json:"room,omitempty"`
}
