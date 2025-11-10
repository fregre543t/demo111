package handlers

import (
	"chat-app/internal/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AdminHandler struct {
	db *models.InMemoryDB
}

func NewAdminHandler(db *models.InMemoryDB) *AdminHandler {
	return &AdminHandler{db: db}
}

type AdminLoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// 简单的管理员验证（生产环境应使用更安全的方式）
const (
	AdminUsername = "admin"
	AdminPassword = "admin123"
)

func (h *AdminHandler) Login(c *gin.Context) {
	var req AdminLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请求参数错误"})
		return
	}

	if req.Username != AdminUsername || req.Password != AdminPassword {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "管理员用户名或密码错误"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": "admin_token",
		"message": "登录成功",
	})
}

func (h *AdminHandler) GetAllUsers(c *gin.Context) {
	users := h.db.GetAllUsers()
	c.JSON(http.StatusOK, gin.H{"users": users})
}

func (h *AdminHandler) DeleteUser(c *gin.Context) {
	userID := c.Param("id")
	if err := h.db.DeleteUser(userID); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "用户删除成功"})
}

func (h *AdminHandler) GetAllMessages(c *gin.Context) {
	messages := h.db.GetAllMessages()
	c.JSON(http.StatusOK, gin.H{"messages": messages})
}

func (h *AdminHandler) DeleteMessage(c *gin.Context) {
	messageID := c.Param("id")
	if err := h.db.DeleteMessage(messageID); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "消息删除成功"})
}

func (h *AdminHandler) GetStats(c *gin.Context) {
	stats := h.db.GetStats()
	c.JSON(http.StatusOK, stats)
}
