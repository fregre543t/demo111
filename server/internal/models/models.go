package models

import "time"

type Role string

const (
	RoleUser  Role = "user"
	RoleAdmin Role = "admin"
)

type User struct {
	ID           string    `json:"id"`
	Username     string    `json:"username"`
	PasswordHash string    `json:"-"`
	Role         Role      `json:"role"`
	CreatedAt    time.Time `json:"created_at"`
	LastSeenAt   time.Time `json:"last_seen_at"`
}

type Message struct {
	ID         string    `json:"id"`
	SenderID   string    `json:"sender_id"`
	ReceiverID string    `json:"receiver_id,omitempty"`
	RoomID     string    `json:"room_id,omitempty"`
	Content    string    `json:"content"`
	CreatedAt  time.Time `json:"created_at"`
}

type Room struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	CreatedAt time.Time `json:"created_at"`
}
