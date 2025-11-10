package memory

import (
	"context"
	"errors"
	"sync"

	"chatapp/internal/models"
)

var (
	ErrUserNotFound = errors.New("user not found")
	ErrRoomNotFound = errors.New("room not found")
)

type MemoryStore struct {
	mu       sync.RWMutex
	users    map[string]*models.User
	byName   map[string]*models.User
	rooms    map[string]*models.Room
	messages map[string][]*models.Message
}

func New() *MemoryStore {
	return &MemoryStore{
		users:    make(map[string]*models.User),
		byName:   make(map[string]*models.User),
		rooms:    make(map[string]*models.Room),
		messages: make(map[string][]*models.Message),
	}
}

func (s *MemoryStore) CreateUser(_ context.Context, user *models.User) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, exists := s.byName[user.Username]; exists {
		return errors.New("username already exists")
	}
	s.users[user.ID] = user
	s.byName[user.Username] = user
	return nil
}

func (s *MemoryStore) GetUserByUsername(_ context.Context, username string) (*models.User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	user, ok := s.byName[username]
	if !ok {
		return nil, ErrUserNotFound
	}
	return user, nil
}

func (s *MemoryStore) GetUserByID(_ context.Context, id string) (*models.User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	user, ok := s.users[id]
	if !ok {
		return nil, ErrUserNotFound
	}
	return user, nil
}

func (s *MemoryStore) ListUsers(_ context.Context) ([]*models.User, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	users := make([]*models.User, 0, len(s.users))
	for _, user := range s.users {
		users = append(users, user)
	}
	return users, nil
}

func (s *MemoryStore) CreateRoom(_ context.Context, room *models.Room) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.rooms[room.ID] = room
	return nil
}

func (s *MemoryStore) GetRoom(_ context.Context, id string) (*models.Room, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	room, ok := s.rooms[id]
	if !ok {
		return nil, ErrRoomNotFound
	}
	return room, nil
}

func (s *MemoryStore) ListRooms(_ context.Context) ([]*models.Room, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	rooms := make([]*models.Room, 0, len(s.rooms))
	for _, room := range s.rooms {
		rooms = append(rooms, room)
	}
	return rooms, nil
}

func (s *MemoryStore) SaveMessage(_ context.Context, msg *models.Message) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if msg.RoomID == "" {
		msg.RoomID = "default"
	}
	s.messages[msg.RoomID] = append(s.messages[msg.RoomID], msg)
	return nil
}

func (s *MemoryStore) ListMessages(_ context.Context, roomID string, limit int) ([]*models.Message, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if roomID == "" {
		roomID = "default"
	}
	msgs := s.messages[roomID]
	if len(msgs) == 0 {
		return []*models.Message{}, nil
	}
	if limit > 0 && len(msgs) > limit {
		return append([]*models.Message(nil), msgs[len(msgs)-limit:]...), nil
	}
	return append([]*models.Message(nil), msgs...), nil
}
