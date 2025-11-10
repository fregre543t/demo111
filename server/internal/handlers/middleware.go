package handlers

import (
	"net/http"
	"strings"

	"chatapp/internal/auth"
	"chatapp/internal/models"
	"chatapp/internal/store"
)

type Middleware struct {
	tokenManager *auth.Manager
	store        store.Store
}

func NewMiddleware(tokenManager *auth.Manager, store store.Store) *Middleware {
	return &Middleware{
		tokenManager: tokenManager,
		store:        store,
	}
}

func (m *Middleware) Auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			http.Error(w, "missing Authorization header", http.StatusUnauthorized)
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")
		if token == authHeader {
			http.Error(w, "invalid Authorization header", http.StatusUnauthorized)
			return
		}

		claims, err := m.tokenManager.Parse(token)
		if err != nil {
			http.Error(w, "invalid token", http.StatusUnauthorized)
			return
		}

		user, err := m.store.GetUserByID(r.Context(), claims.UserID)
		if err != nil {
			http.Error(w, "user not found", http.StatusUnauthorized)
			return
		}

		ctx := contextWithUser(r.Context(), user)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func (m *Middleware) Admin(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		user, ok := userFromContext(r.Context())
		if !ok || user.Role != models.RoleAdmin {
			http.Error(w, "admin access required", http.StatusForbidden)
			return
		}
		next.ServeHTTP(w, r)
	})
}
