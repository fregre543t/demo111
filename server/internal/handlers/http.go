package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"chatapp/internal/auth"
	"chatapp/internal/chat"
	"chatapp/internal/models"
	"chatapp/internal/store"
)

type Handler struct {
	store        store.Store
	hub          *chat.Hub
	tokenManager *auth.Manager
	upgrader     websocket.Upgrader
}

func NewHandler(store store.Store, hub *chat.Hub, tokenManager *auth.Manager) *Handler {
	return &Handler{
		store:        store,
		hub:          hub,
		tokenManager: tokenManager,
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin: func(r *http.Request) bool {
				return true
			},
		},
	}
}

func (h *Handler) RegisterRoutes(r chi.Router, mw *Middleware) {
	r.Get("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})

	r.Route("/api", func(api chi.Router) {
		api.Post("/auth/register", h.handleRegister)
		api.Post("/auth/login", h.handleLogin)

		api.Group(func(priv chi.Router) {
			priv.Use(mw.Auth)
			priv.Get("/me", h.handleMe)
			priv.Get("/messages", h.handleListMessages)

			priv.Route("/admin", func(admin chi.Router) {
				admin.Use(mw.Admin)
				admin.Get("/users", h.handleListUsers)
				admin.Get("/rooms", h.handleListRooms)
				admin.Post("/rooms", h.handleCreateRoom)
			})
		})
	})

	r.Get("/ws", h.handleWebSocket)
}

func (h *Handler) handleRegister(w http.ResponseWriter, r *http.Request) {
	type request struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	var req request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}
	if req.Username == "" || req.Password == "" {
		http.Error(w, "missing username or password", http.StatusBadRequest)
		return
	}

	hash, err := auth.HashPassword(req.Password)
	if err != nil {
		http.Error(w, "could not hash password", http.StatusInternalServerError)
		return
	}

	now := time.Now()
	user := &models.User{
		ID:           uuid.New().String(),
		Username:     req.Username,
		PasswordHash: hash,
		Role:         models.RoleUser,
		CreatedAt:    now,
		LastSeenAt:   now,
	}

	ctx := r.Context()
	existing, err := h.store.ListUsers(ctx)
	if err != nil {
		http.Error(w, "failed to create user", http.StatusInternalServerError)
		return
	}
	if len(existing) == 0 {
		user.Role = models.RoleAdmin
	}

	if err := h.store.CreateUser(ctx, user); err != nil {
		http.Error(w, err.Error(), http.StatusConflict)
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{
		"id":        user.ID,
		"username":  user.Username,
		"role":      user.Role,
		"createdAt": user.CreatedAt,
	})
}

func (h *Handler) handleLogin(w http.ResponseWriter, r *http.Request) {
	type request struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	var req request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}

	user, err := h.store.GetUserByUsername(r.Context(), req.Username)
	if err != nil || !auth.VerifyPassword(user.PasswordHash, req.Password) {
		http.Error(w, "invalid credentials", http.StatusUnauthorized)
		return
	}

	token, err := h.tokenManager.Generate(user)
	if err != nil {
		http.Error(w, "could not generate token", http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"token": token,
		"user": map[string]any{
			"id":       user.ID,
			"username": user.Username,
			"role":     user.Role,
		},
	})
}

func (h *Handler) handleMe(w http.ResponseWriter, r *http.Request) {
	user, ok := userFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}
	writeJSON(w, http.StatusOK, user)
}

func (h *Handler) handleListMessages(w http.ResponseWriter, r *http.Request) {
	user, ok := userFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	roomID := r.URL.Query().Get("room_id")
	limitStr := r.URL.Query().Get("limit")
	limit := 50
	if limitStr != "" {
		if v, err := strconv.Atoi(limitStr); err == nil && v > 0 {
			limit = v
		}
	}

	msgs, err := h.store.ListMessages(r.Context(), roomID, limit)
	if err != nil {
		http.Error(w, "failed to load messages", http.StatusInternalServerError)
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"messages": msgs,
		"user":     user,
	})
}

func (h *Handler) handleListUsers(w http.ResponseWriter, r *http.Request) {
	users, err := h.store.ListUsers(r.Context())
	if err != nil {
		http.Error(w, "failed to list users", http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"users": users,
	})
}

func (h *Handler) handleListRooms(w http.ResponseWriter, r *http.Request) {
	rooms, err := h.store.ListRooms(r.Context())
	if err != nil {
		http.Error(w, "failed to list rooms", http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{
		"rooms": rooms,
	})
}

func (h *Handler) handleCreateRoom(w http.ResponseWriter, r *http.Request) {
	type request struct {
		Name string `json:"name"`
	}

	var req request
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid payload", http.StatusBadRequest)
		return
	}
	if req.Name == "" {
		http.Error(w, "name required", http.StatusBadRequest)
		return
	}

	room := &models.Room{
		ID:        uuid.New().String(),
		Name:      req.Name,
		CreatedAt: time.Now(),
	}
	if err := h.store.CreateRoom(r.Context(), room); err != nil {
		http.Error(w, "failed to create room", http.StatusInternalServerError)
		return
	}
	writeJSON(w, http.StatusCreated, room)
}

func (h *Handler) handleWebSocket(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		authHeader := r.Header.Get("Authorization")
		if strings.HasPrefix(authHeader, "Bearer ") {
			token = strings.TrimPrefix(authHeader, "Bearer ")
		}
	}
	if token == "" {
		http.Error(w, "missing token", http.StatusUnauthorized)
		return
	}

	claims, err := h.tokenManager.Parse(token)
	if err != nil {
		http.Error(w, "invalid token", http.StatusUnauthorized)
		return
	}

	user, err := h.store.GetUserByID(r.Context(), claims.UserID)
	if err != nil {
		http.Error(w, "user not found", http.StatusUnauthorized)
		return
	}

	roomID := r.URL.Query().Get("room_id")

	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		http.Error(w, "upgrade failed", http.StatusInternalServerError)
		return
	}

	client := chat.NewClient(h.hub, conn, user)
	history, err := h.store.ListMessages(r.Context(), roomID, 50)
	if err == nil {
		h.hub.SendHistory(client, history)
	}
	h.hub.Register(client)
	go client.Run(context.Background())
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
