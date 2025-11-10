package handlers

import (
	"chat-backend/internal/database"
	"chat-backend/internal/middleware"
	"chat-backend/internal/models"
	ws "chat-backend/internal/websocket"
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // 允许所有跨域请求，生产环境需要限制
	},
}

var Hub = ws.NewHub()

func init() {
	go Hub.Run()
}

// HandleWebSocket 处理WebSocket连接
func HandleWebSocket(c *gin.Context) {
	// 从查询参数或header中获取token
	token := c.Query("token")
	if token == "" {
		token = c.GetHeader("Authorization")
		if token != "" {
			parts := strings.SplitN(token, " ", 2)
			if len(parts) == 2 {
				token = parts[1]
			}
		}
	}

	if token == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未提供认证令牌"})
		return
	}

	// 验证token
	claims := &middleware.Claims{}
	jwtToken, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte("your-secret-key-change-in-production"), nil
	})

	if err != nil || !jwtToken.Valid {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的令牌"})
		return
	}

	// 升级HTTP连接为WebSocket
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Printf("WebSocket升级失败: %v", err)
		return
	}

	// 更新用户在线状态
	database.DB.Model(&models.User{}).Where("id = ?", claims.UserID).Update("is_online", true)

	// 创建客户端并注册
	client := ws.NewClient(Hub, conn, claims.UserID)
	Hub.register <- client

	// 启动读写协程
	go client.WritePump()
	go client.ReadPump()
}

// GetOnlineUsers 获取在线用户
func GetWSOnlineUsers(c *gin.Context) {
	onlineUsers := Hub.GetOnlineUsers()
	
	var users []models.User
	if len(onlineUsers) > 0 {
		database.DB.Where("id IN ?", onlineUsers).
			Select("id", "username", "nickname", "avatar").
			Find(&users)
	}

	c.JSON(http.StatusOK, gin.H{
		"online_users": users,
		"count":        len(users),
	})
}
