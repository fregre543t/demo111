package websocket

import (
	"encoding/json"
	"log"
	"sync"
)

// Hub WebSocket连接管理中心
type Hub struct {
	// 注册的客户端
	clients map[uint]*Client
	// 注册请求
	register chan *Client
	// 注销请求
	unregister chan *Client
	// 广播消息
	broadcast chan *Message
	// 私聊消息
	privateMsgChan chan *Message
	// 互斥锁
	mu sync.RWMutex
}

// Message WebSocket消息结构
type Message struct {
	Type       string      `json:"type"` // message, typing, online, offline
	FromUserID uint        `json:"from_user_id"`
	ToUserID   uint        `json:"to_user_id"`
	Content    string      `json:"content"`
	Data       interface{} `json:"data,omitempty"`
	Timestamp  int64       `json:"timestamp"`
}

// NewHub 创建新的Hub
func NewHub() *Hub {
	return &Hub{
		clients:        make(map[uint]*Client),
		register:       make(chan *Client),
		unregister:     make(chan *Client),
		broadcast:      make(chan *Message),
		privateMsgChan: make(chan *Message),
	}
}

// Run 启动Hub
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.UserID] = client
			h.mu.Unlock()
			log.Printf("用户 %d 已连接, 当前在线: %d", client.UserID, len(h.clients))
			
			// 通知其他用户该用户上线
			h.broadcastUserStatus(client.UserID, true)

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.UserID]; ok {
				delete(h.clients, client.UserID)
				close(client.send)
			}
			h.mu.Unlock()
			log.Printf("用户 %d 已断开, 当前在线: %d", client.UserID, len(h.clients))
			
			// 通知其他用户该用户下线
			h.broadcastUserStatus(client.UserID, false)

		case message := <-h.broadcast:
			h.mu.RLock()
			for _, client := range h.clients {
				select {
				case client.send <- message:
				default:
					close(client.send)
					delete(h.clients, client.UserID)
				}
			}
			h.mu.RUnlock()

		case message := <-h.privateMsgChan:
			h.mu.RLock()
			if client, ok := h.clients[message.ToUserID]; ok {
				select {
				case client.send <- message:
					log.Printf("私聊消息已发送: %d -> %d", message.FromUserID, message.ToUserID)
				default:
					log.Printf("发送失败，关闭连接: %d", client.UserID)
				}
			} else {
				log.Printf("用户 %d 不在线，消息未发送", message.ToUserID)
			}
			h.mu.RUnlock()
		}
	}
}

// SendPrivateMessage 发送私聊消息
func (h *Hub) SendPrivateMessage(msg *Message) {
	h.privateMsgChan <- msg
}

// BroadcastMessage 广播消息
func (h *Hub) BroadcastMessage(msg *Message) {
	h.broadcast <- msg
}

// broadcastUserStatus 广播用户在线状态
func (h *Hub) broadcastUserStatus(userID uint, isOnline bool) {
	status := "offline"
	if isOnline {
		status = "online"
	}

	msg := &Message{
		Type:       status,
		FromUserID: userID,
		Data: map[string]interface{}{
			"user_id":   userID,
			"is_online": isOnline,
		},
	}

	data, _ := json.Marshal(msg)
	h.mu.RLock()
	for _, client := range h.clients {
		if client.UserID != userID {
			select {
			case client.send <- msg:
			default:
				log.Printf("无法发送状态更新到用户 %d", client.UserID)
			}
		}
	}
	h.mu.RUnlock()
	log.Printf("广播用户状态: 用户 %d %s, 消息: %s", userID, status, string(data))
}

// GetOnlineUsers 获取在线用户列表
func (h *Hub) GetOnlineUsers() []uint {
	h.mu.RLock()
	defer h.mu.RUnlock()
	
	users := make([]uint, 0, len(h.clients))
	for userID := range h.clients {
		users = append(users, userID)
	}
	return users
}

// IsUserOnline 检查用户是否在线
func (h *Hub) IsUserOnline(userID uint) bool {
	h.mu.RLock()
	defer h.mu.RUnlock()
	_, exists := h.clients[userID]
	return exists
}
