package store

import (
	"errors"
	"sync"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

const (
	roleUser = "user"
)

// User 表示系统中的用户。
type User struct {
	ID           string    `json:"id"`
	Username     string    `json:"username"`
	PasswordHash string    `json:"-"`
	Role         string    `json:"role"`
	Disabled     bool      `json:"disabled"`
	CreatedAt    time.Time `json:"createdAt"`
}

// Session 保存登录状态。
type Session struct {
	Token     string    `json:"token"`
	UserID    string    `json:"userId"`
	CreatedAt time.Time `json:"createdAt"`
}

// Room 表示聊天房间。
type Room struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Active      bool      `json:"active"`
	CreatedAt   time.Time `json:"createdAt"`
}

// Message 表示单条聊天记录。
type Message struct {
	ID         string    `json:"id"`
	RoomID     string    `json:"roomId"`
	SenderID   string    `json:"senderId"`
	SenderName string    `json:"senderName"`
	Content    string    `json:"content"`
	SentAt     time.Time `json:"sentAt"`
}

// Store 用于管理内存数据。
type Store struct {
	mu        sync.RWMutex
	users     map[string]*User
	sessions  map[string]*Session
	rooms     map[string]*Room
	roomMsgs  map[string][]Message
	userIndex map[string]string // username -> userID
}

// New 创建一个 Store，并初始化默认房间。
func New() *Store {
	s := &Store{
		users:     make(map[string]*User),
		sessions:  make(map[string]*Session),
		rooms:     make(map[string]*Room),
		roomMsgs:  make(map[string][]Message),
		userIndex: make(map[string]string),
	}
	s.bootstrap()
	return s
}

func (s *Store) bootstrap() {
	room := &Room{
		ID:          uuid.NewString(),
		Name:        "公共大厅",
		Description: "默认聊天室，所有用户均可加入",
		Active:      true,
		CreatedAt:   time.Now(),
	}
	s.rooms[room.ID] = room
}

// CreateUser 注册用户。
func (s *Store) CreateUser(username, password string) (*User, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, exists := s.userIndex[username]; exists {
		return nil, errors.New("用户名已存在")
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := &User{
		ID:           uuid.NewString(),
		Username:     username,
		PasswordHash: string(hashed),
		Role:         roleUser,
		Disabled:     false,
		CreatedAt:    time.Now(),
	}
	s.users[user.ID] = user
	s.userIndex[user.Username] = user.ID

	return user, nil
}

// ValidateUser 校验用户名和密码。
func (s *Store) ValidateUser(username, password string) (*User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	userID, ok := s.userIndex[username]
	if !ok {
		return nil, errors.New("用户不存在")
	}

	user := s.users[userID]
	if user.Disabled {
		return nil, errors.New("用户已被禁用")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(password)); err != nil {
		return nil, errors.New("密码错误")
	}

	return user, nil
}

// GetUser 根据ID获取用户。
func (s *Store) GetUser(userID string) (*User, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	user, ok := s.users[userID]
	return user, ok
}

// ListUsers 返回所有用户。
func (s *Store) ListUsers() []*User {
	s.mu.RLock()
	defer s.mu.RUnlock()

	res := make([]*User, 0, len(s.users))
	for _, u := range s.users {
		res = append(res, u)
	}
	return res
}

// SetUserDisabled 设置用户是否禁用。
func (s *Store) SetUserDisabled(userID string, disabled bool) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	user, ok := s.users[userID]
	if !ok {
		return errors.New("用户不存在")
	}
	user.Disabled = disabled
	return nil
}

// CreateSession 创建会话并返回 token。
func (s *Store) CreateSession(userID string) (*Session, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, ok := s.users[userID]; !ok {
		return nil, errors.New("用户不存在")
	}
	session := &Session{
		Token:     uuid.NewString(),
		UserID:    userID,
		CreatedAt: time.Now(),
	}
	s.sessions[session.Token] = session
	return session, nil
}

// GetSession 根据 token 获取会话。
func (s *Store) GetSession(token string) (*Session, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	session, ok := s.sessions[token]
	return session, ok
}

// DeleteSession 删除会话。
func (s *Store) DeleteSession(token string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.sessions, token)
}

// CreateRoom 创建房间。
func (s *Store) CreateRoom(name, description string) (*Room, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	room := &Room{
		ID:          uuid.NewString(),
		Name:        name,
		Description: description,
		Active:      true,
		CreatedAt:   time.Now(),
	}
	s.rooms[room.ID] = room
	return room, nil
}

// UpdateRoom 更新房间信息。
func (s *Store) UpdateRoom(roomID, name, description string, active bool) (*Room, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	room, ok := s.rooms[roomID]
	if !ok {
		return nil, errors.New("房间不存在")
	}
	room.Name = name
	room.Description = description
	room.Active = active
	return room, nil
}

// DeleteRoom 删除房间。
func (s *Store) DeleteRoom(roomID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, ok := s.rooms[roomID]; !ok {
		return errors.New("房间不存在")
	}
	delete(s.rooms, roomID)
	delete(s.roomMsgs, roomID)
	return nil
}

// ListRooms 返回所有房间。
func (s *Store) ListRooms() []*Room {
	s.mu.RLock()
	defer s.mu.RUnlock()

	res := make([]*Room, 0, len(s.rooms))
	for _, room := range s.rooms {
		res = append(res, room)
	}
	return res
}

// GetRoom 根据 ID 获取房间。
func (s *Store) GetRoom(roomID string) (*Room, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	room, ok := s.rooms[roomID]
	return room, ok
}

// AppendMessage 添加消息并返回最新消息集合。
func (s *Store) AppendMessage(roomID string, msg Message) []Message {
	s.mu.Lock()
	defer s.mu.Unlock()

	msgs := append(s.roomMsgs[roomID], msg)
	// 仅保留最近 100 条消息
	if len(msgs) > 100 {
		msgs = msgs[len(msgs)-100:]
	}
	s.roomMsgs[roomID] = msgs
	return msgs
}

// ListMessages 获取房间最近的消息。
func (s *Store) ListMessages(roomID string) []Message {
	s.mu.RLock()
	defer s.mu.RUnlock()

	msgs := s.roomMsgs[roomID]
	result := make([]Message, len(msgs))
	copy(result, msgs)
	return result
}
