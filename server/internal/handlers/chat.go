package handlers

import (
	"chat-app/internal/models"
	"chat-app/internal/websocket"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

type ChatHandler struct {
	hub *websocket.Hub
	db  *models.InMemoryDB
}

func NewChatHandler(hub *websocket.Hub, db *models.InMemoryDB) *ChatHandler {
	return &ChatHandler{
		hub: hub,
		db:  db,
	}
}

type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Email    string `json:"email" binding:"required"`
}

func (h *ChatHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	user, err := h.db.GetUserByUsername(req.Username)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户名或密码错误"})
		return
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户名或密码错误"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user": user,
		"token": user.ID, // 简单token，生产环境应使用JWT
	})
}

func (h *ChatHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	user, err := h.db.CreateUser(req.Username, req.Password, req.Email)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"user": user,
		"token": user.ID,
	})
}

func (h *ChatHandler) HandleWebSocket(c *gin.Context) {
	userID := c.Query("user_id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "缺少user_id参数"})
		return
	}

	user, err := h.db.GetUserByID(userID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户不存在"})
		return
	}

	conn, err := websocket.Upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "WebSocket升级失败"})
		return
	}

	client := websocket.NewClient(h.hub, conn, user, h.db)
	h.hub.Register(client)
	h.db.SetUserOnline(userID, true)

	go client.WritePump()
	go client.ReadPump()
}

func (h *ChatHandler) GetUsers(c *gin.Context) {
	users := h.db.GetAllUsers()
	c.JSON(http.StatusOK, gin.H{"users": users})
}

func (h *ChatHandler) GetMessages(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "50")
	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		limit = 50
	}

	messages := h.db.GetMessages(limit)
	c.JSON(http.StatusOK, gin.H{"messages": messages})
}
