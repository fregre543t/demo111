package handlers

import (
	"chat-app-backend/config"
	"chat-app-backend/database"
	"chat-app-backend/models"
	"encoding/json"
	"log"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // 在生产环境中应该检查来源
	},
}

type Client struct {
	Hub      *Hub
	Conn     *websocket.Conn
	Send     chan []byte
	UserID   uint
	Username string
	RoomID   uint
}

type Hub struct {
	clients    map[*Client]bool
	broadcast  chan []byte
	register   chan *Client
	unregister chan *Client
}

type MessageData struct {
	Type      string      `json:"type"` // message, join, leave, typing
	RoomID    uint        `json:"room_id"`
	UserID    uint        `json:"user_id"`
	Username  string      `json:"username"`
	Content   string      `json:"content,omitempty"`
	Message   interface{} `json:"message,omitempty"`
	Timestamp string      `json:"timestamp,omitempty"`
}

func NewHub() *Hub {
	return &Hub{
		clients:    make(map[*Client]bool),
		broadcast:  make(chan []byte),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.clients[client] = true
			log.Printf("客户端连接: UserID=%d, RoomID=%d", client.UserID, client.RoomID)

		case client := <-h.unregister:
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.Send)
				log.Printf("客户端断开: UserID=%d", client.UserID)
			}

		case message := <-h.broadcast:
			for client := range h.clients {
				select {
				case client.Send <- message:
				default:
					close(client.Send)
					delete(h.clients, client)
				}
			}
		}
	}
}

func (c *Client) readPump() {
	defer func() {
		c.Hub.unregister <- c
		c.Conn.Close()
	}()

	for {
		_, messageBytes, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("WebSocket错误: %v", err)
			}
			break
		}

		var msgData MessageData
		if err := json.Unmarshal(messageBytes, &msgData); err != nil {
			log.Printf("消息解析错误: %v", err)
			continue
		}

		// 处理不同类型的消息
		switch msgData.Type {
		case "message":
			// 保存消息到数据库
			message := models.Message{
				RoomID:  msgData.RoomID,
				UserID:  c.UserID,
				Content: msgData.Content,
				Type:    "text",
			}
			if err := database.GetDB().Create(&message).Error; err != nil {
				log.Printf("保存消息失败: %v", err)
				continue
			}

			// 加载用户信息
			var user models.User
			database.GetDB().First(&user, c.UserID)

			// 构建响应消息
			response := MessageData{
				Type:     "message",
				RoomID:   msgData.RoomID,
				UserID:   c.UserID,
				Username: user.Nickname,
				Content:  msgData.Content,
				Message: map[string]interface{}{
					"id":         message.ID,
					"room_id":    message.RoomID,
					"user_id":    message.UserID,
					"content":    message.Content,
					"created_at": message.CreatedAt,
					"user": map[string]interface{}{
						"id":       user.ID,
						"username": user.Username,
						"nickname": user.Nickname,
						"avatar":   user.Avatar,
					},
				},
			}

			responseBytes, _ := json.Marshal(response)
			c.Hub.broadcast <- responseBytes

		case "join":
			c.RoomID = msgData.RoomID
			response := MessageData{
				Type:     "join",
				RoomID:   msgData.RoomID,
				UserID:   c.UserID,
				Username: c.Username,
				Content:  c.Username + " 加入了聊天室",
			}
			responseBytes, _ := json.Marshal(response)
			c.Hub.broadcast <- responseBytes

		case "leave":
			response := MessageData{
				Type:     "leave",
				RoomID:   c.RoomID,
				UserID:   c.UserID,
				Username: c.Username,
				Content:  c.Username + " 离开了聊天室",
			}
			responseBytes, _ := json.Marshal(response)
			c.Hub.broadcast <- responseBytes
		}
	}
}

func (c *Client) writePump() {
	defer c.Conn.Close()

	for {
		select {
		case message, ok := <-c.Send:
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			if err := c.Conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("写入消息错误: %v", err)
				return
			}
		}
	}
}

func HandleWebSocket(hub *Hub) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 从查询参数或Header获取token
		tokenString := c.Query("token")
		if tokenString == "" {
			authHeader := c.GetHeader("Authorization")
			if authHeader != "" {
				parts := strings.Split(authHeader, " ")
				if len(parts) == 2 && parts[0] == "Bearer" {
					tokenString = parts[1]
				}
			}
		}

		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "缺少认证令牌"})
			return
		}

		// 验证token
		cfg := config.Load()
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			return []byte(cfg.JWTSecret), nil
		})

		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的认证令牌"})
			return
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的令牌声明"})
			return
		}

		userID := uint(claims["user_id"].(float64))
		var user models.User
		if err := database.GetDB().First(&user, userID).Error; err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "用户不存在"})
			return
		}

		// 升级连接
		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			log.Printf("WebSocket升级失败: %v", err)
			return
		}

		// 创建客户端
		client := &Client{
			Hub:      hub,
			Conn:     conn,
			Send:     make(chan []byte, 256),
			UserID:   user.ID,
			Username: user.Username,
		}

		client.Hub.register <- client

		// 启动读写协程
		go client.writePump()
		go client.readPump()
	}
}
