package models

import (
	"sync"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	Password  string    `json:"-"` // 不返回密码
	Email     string    `json:"email"`
	Avatar    string    `json:"avatar"`
	CreatedAt time.Time `json:"created_at"`
	IsOnline  bool      `json:"is_online"`
}

type Message struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Username  string    `json:"username"`
	Content   string    `json:"content"`
	Type      string    `json:"type"` // text, image, file
	CreatedAt time.Time `json:"created_at"`
}

type InMemoryDB struct {
	users    map[string]*User
	messages []*Message
	mu       sync.RWMutex
}

func NewInMemoryDB() *InMemoryDB {
	return &InMemoryDB{
		users:    make(map[string]*User),
		messages: make([]*Message, 0),
	}
}

func (db *InMemoryDB) CreateUser(username, password, email string) (*User, error) {
	db.mu.Lock()
	defer db.mu.Unlock()

	// 检查用户名是否已存在
	for _, user := range db.users {
		if user.Username == username {
			return nil, ErrUserExists
		}
	}

	// 加密密码
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &User{
		ID:        uuid.New().String(),
		Username:  username,
		Password:  string(hashedPassword),
		Email:     email,
		Avatar:    "",
		CreatedAt: time.Now(),
		IsOnline:  false,
	}

	db.users[user.ID] = user
	return user, nil
}

func (db *InMemoryDB) GetUserByUsername(username string) (*User, error) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	for _, user := range db.users {
		if user.Username == username {
			return user, nil
		}
	}
	return nil, ErrUserNotFound
}

func (db *InMemoryDB) GetUserByID(id string) (*User, error) {
	db.mu.RLock()
	defer db.mu.RUnlock()

	user, exists := db.users[id]
	if !exists {
		return nil, ErrUserNotFound
	}
	return user, nil
}

func (db *InMemoryDB) GetAllUsers() []*User {
	db.mu.RLock()
	defer db.mu.RUnlock()

	users := make([]*User, 0, len(db.users))
	for _, user := range db.users {
		users = append(users, user)
	}
	return users
}

func (db *InMemoryDB) SetUserOnline(userID string, online bool) {
	db.mu.Lock()
	defer db.mu.Unlock()

	if user, exists := db.users[userID]; exists {
		user.IsOnline = online
	}
}

func (db *InMemoryDB) AddMessage(message *Message) {
	db.mu.Lock()
	defer db.mu.Unlock()

	db.messages = append(db.messages, message)
}

func (db *InMemoryDB) GetMessages(limit int) []*Message {
	db.mu.RLock()
	defer db.mu.RUnlock()

	if limit <= 0 || limit > len(db.messages) {
		limit = len(db.messages)
	}

	start := len(db.messages) - limit
	if start < 0 {
		start = 0
	}

	messages := make([]*Message, limit)
	copy(messages, db.messages[start:])
	return messages
}

func (db *InMemoryDB) GetAllMessages() []*Message {
	db.mu.RLock()
	defer db.mu.RUnlock()

	messages := make([]*Message, len(db.messages))
	copy(messages, db.messages)
	return messages
}

func (db *InMemoryDB) DeleteUser(userID string) error {
	db.mu.Lock()
	defer db.mu.Unlock()

	if _, exists := db.users[userID]; !exists {
		return ErrUserNotFound
	}

	delete(db.users, userID)
	return nil
}

func (db *InMemoryDB) DeleteMessage(messageID string) error {
	db.mu.Lock()
	defer db.mu.Unlock()

	for i, msg := range db.messages {
		if msg.ID == messageID {
			db.messages = append(db.messages[:i], db.messages[i+1:]...)
			return nil
		}
	}
	return ErrMessageNotFound
}

func (db *InMemoryDB) GetStats() map[string]interface{} {
	db.mu.RLock()
	defer db.mu.RUnlock()

	onlineCount := 0
	for _, user := range db.users {
		if user.IsOnline {
			onlineCount++
		}
	}

	return map[string]interface{}{
		"total_users":   len(db.users),
		"online_users":  onlineCount,
		"total_messages": len(db.messages),
	}
}
