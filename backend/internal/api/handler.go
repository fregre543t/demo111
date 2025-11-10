package api

import (
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"websocket-chat/internal/config"
	"websocket-chat/internal/store"
	"websocket-chat/internal/ws"
)

// Handler 聚合所有 HTTP / WebSocket 处理逻辑。
type Handler struct {
	cfg         config.Config
	store       *store.Store
	hub         *ws.Hub
	upgrader    websocket.Upgrader
	adminTokens map[string]time.Time
	adminMu     sync.RWMutex
	adminTTL    time.Duration
}

// NewHandler 创建 Handler 实例。
func NewHandler(cfg config.Config, st *store.Store, hub *ws.Hub) *Handler {
	return &Handler{
		cfg:   cfg,
		store: st,
		hub:   hub,
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
			CheckOrigin: func(r *http.Request) bool {
				return true
			},
		},
		adminTokens: make(map[string]time.Time),
		adminTTL:    24 * time.Hour,
	}
}

// SetupRouter 注册所有路由。
func (h *Handler) SetupRouter() *gin.Engine {
	router := gin.Default()
	router.Use(cors.New(cors.Config{
		AllowOrigins:     h.cfg.CORSOrigins,
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	router.GET("/healthz", func(ctx *gin.Context) {
		ctx.JSON(http.StatusOK, gin.H{"status": "ok"})
	})
	router.GET("/ws", h.handleWebSocket)

	apiGroup := router.Group("/api")
	{
		auth := apiGroup.Group("/auth")
		auth.POST("/register", h.registerUser)
		auth.POST("/login", h.loginUser)
		auth.POST("/logout", h.authRequired(), h.logoutUser)

		roomGroup := apiGroup.Group("/rooms")
		roomGroup.Use(h.authRequired())
		roomGroup.GET("", h.listRooms)
		roomGroup.GET("/:id/messages", h.getRoomMessages)
	}

	adminGroup := apiGroup.Group("/admin")
	{
		adminGroup.POST("/login", h.adminLogin)
		secured := adminGroup.Group("/")
		secured.Use(h.adminRequired())
		secured.GET("/users", h.adminListUsers)
		secured.GET("/rooms", h.adminListRooms)
		secured.PATCH("/users/:id/status", h.adminToggleUser)
		secured.POST("/rooms", h.adminCreateRoom)
		secured.PUT("/rooms/:id", h.adminUpdateRoom)
		secured.DELETE("/rooms/:id", h.adminDeleteRoom)
	}

	return router
}

// ==== Auth Helpers ====

func (h *Handler) authRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractToken(c.GetHeader("Authorization"))
		if token == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "缺少访问令牌"})
			return
		}
		session, ok := h.store.GetSession(token)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "会话已失效"})
			return
		}
		user, exists := h.store.GetUser(session.UserID)
		if !exists || user.Disabled {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "用户状态异常"})
			return
		}
		c.Set("user", user)
		c.Set("token", token)
		c.Next()
	}
}

func (h *Handler) adminRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		token := extractToken(c.GetHeader("Authorization"))
		if token == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "缺少管理员令牌"})
			return
		}
		if !h.validateAdminToken(token) {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "管理员令牌无效"})
			return
		}
		c.Next()
	}
}

func extractToken(header string) string {
	if header == "" {
		return ""
	}
	parts := strings.SplitN(header, " ", 2)
	if len(parts) == 2 && strings.ToLower(parts[0]) == "bearer" {
		return parts[1]
	}
	return header
}

// ==== Auth Handlers ====

type registerRequest struct {
	Username string `json:"username" binding:"required,min=3,max=32"`
	Password string `json:"password" binding:"required,min=6,max=64"`
}

func (h *Handler) registerUser(c *gin.Context) {
	var req registerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := h.store.CreateUser(req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	session, err := h.store.CreateSession(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建会话失败"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{
		"user":  sanitizeUser(user),
		"token": session.Token,
	})
}

type loginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

func (h *Handler) loginUser(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	user, err := h.store.ValidateUser(req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}
	session, err := h.store.CreateSession(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建会话失败"})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"user":  sanitizeUser(user),
		"token": session.Token,
	})
}

func (h *Handler) logoutUser(c *gin.Context) {
	token, _ := c.Get("token")
	if tokenStr, ok := token.(string); ok {
		h.store.DeleteSession(tokenStr)
	}
	c.JSON(http.StatusOK, gin.H{"message": "已退出登录"})
}

type adminLoginRequest struct {
	Password string `json:"password" binding:"required"`
}

func (h *Handler) adminLogin(c *gin.Context) {
	var req adminLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Password != h.cfg.AdminPassword {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "管理员密码错误"})
		return
	}
	token := uuid.NewString()
	h.storeAdminToken(token)
	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"ttl":   h.adminTTL.Seconds(),
	})
}

func (h *Handler) storeAdminToken(token string) {
	h.adminMu.Lock()
	defer h.adminMu.Unlock()
	h.adminTokens[token] = time.Now().Add(h.adminTTL)
}

func (h *Handler) validateAdminToken(token string) bool {
	h.adminMu.Lock()
	defer h.adminMu.Unlock()
	expireAt, ok := h.adminTokens[token]
	if !ok {
		return false
	}
	if time.Now().After(expireAt) {
		delete(h.adminTokens, token)
		return false
	}
	return true
}

// ==== Room & Message API ====

func (h *Handler) listRooms(c *gin.Context) {
	rooms := h.store.ListRooms()
	active := make([]*store.Room, 0, len(rooms))
	for _, r := range rooms {
		if r.Active {
			active = append(active, r)
		}
	}
	c.JSON(http.StatusOK, gin.H{"rooms": active})
}

func (h *Handler) getRoomMessages(c *gin.Context) {
	roomID := c.Param("id")
	messages := h.store.ListMessages(roomID)
	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

// ==== Admin API ====

func (h *Handler) adminListUsers(c *gin.Context) {
	users := h.store.ListUsers()
	sanitized := make([]map[string]interface{}, 0, len(users))
	for _, u := range users {
		sanitized = append(sanitized, sanitizeUser(u))
	}
	c.JSON(http.StatusOK, gin.H{"users": sanitized})
}

type toggleUserRequest struct {
	Disabled bool `json:"disabled"`
}

func (h *Handler) adminToggleUser(c *gin.Context) {
	var req toggleUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := h.store.SetUserDisabled(c.Param("id"), req.Disabled); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "更新成功"})
}

func (h *Handler) adminListRooms(c *gin.Context) {
	rooms := h.store.ListRooms()
	c.JSON(http.StatusOK, gin.H{"rooms": rooms})
}

type createRoomRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description" binding:"required"`
}

func (h *Handler) adminCreateRoom(c *gin.Context) {
	var req createRoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	room, err := h.store.CreateRoom(req.Name, req.Description)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"room": room})
}

type updateRoomRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description" binding:"required"`
	Active      bool   `json:"active"`
}

func (h *Handler) adminUpdateRoom(c *gin.Context) {
	var req updateRoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	room, err := h.store.UpdateRoom(c.Param("id"), req.Name, req.Description, req.Active)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"room": room})
}

func (h *Handler) adminDeleteRoom(c *gin.Context) {
	if err := h.store.DeleteRoom(c.Param("id")); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "房间已删除"})
}

// ==== WebSocket Handler ====

func (h *Handler) handleWebSocket(c *gin.Context) {
	token := c.Query("token")
	roomID := c.Query("room_id")
	if token == "" || roomID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "缺少参数 token 或 room_id"})
		return
	}

	session, ok := h.store.GetSession(token)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "会话无效"})
		return
	}
	user, ok := h.store.GetUser(session.UserID)
	if !ok || user.Disabled {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户状态异常"})
		return
	}

	room, ok := h.store.GetRoom(roomID)
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "房间不存在"})
		return
	}
	if !room.Active {
		c.JSON(http.StatusForbidden, gin.H{"error": "房间已停用"})
		return
	}

	conn, err := h.upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "升级 WebSocket 失败"})
		return
	}

	client := &ws.Client{
		ID:     uuid.NewString(),
		User:   user,
		RoomID: roomID,
		Hub:    h.hub,
		Conn:   conn,
		Send:   make(chan store.Message, 64),
	}
	h.hub.RegisterClient(client)
}

// ==== Utilities ====

func sanitizeUser(user *store.User) map[string]interface{} {
	return map[string]interface{}{
		"id":        user.ID,
		"username":  user.Username,
		"role":      user.Role,
		"disabled":  user.Disabled,
		"createdAt": user.CreatedAt,
	}
}
