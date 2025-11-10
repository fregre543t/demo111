package handlers

import (
	"context"

	"chatapp/internal/models"
)

type contextKey string

const userContextKey contextKey = "user"

func contextWithUser(ctx context.Context, user *models.User) context.Context {
	return context.WithValue(ctx, userContextKey, user)
}

func userFromContext(ctx context.Context) (*models.User, bool) {
	user, ok := ctx.Value(userContextKey).(*models.User)
	return user, ok
}
