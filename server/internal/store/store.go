package store

import (
	"context"

	"chatapp/internal/models"
)

type Store interface {
	CreateUser(ctx context.Context, user *models.User) error
	GetUserByUsername(ctx context.Context, username string) (*models.User, error)
	GetUserByID(ctx context.Context, id string) (*models.User, error)
	ListUsers(ctx context.Context) ([]*models.User, error)

	CreateRoom(ctx context.Context, room *models.Room) error
	GetRoom(ctx context.Context, id string) (*models.Room, error)
	ListRooms(ctx context.Context) ([]*models.Room, error)

	SaveMessage(ctx context.Context, msg *models.Message) error
	ListMessages(ctx context.Context, roomID string, limit int) ([]*models.Message, error)
}
