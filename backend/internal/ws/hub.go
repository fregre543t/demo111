package ws

import (
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"websocket-chat/internal/store"
)

// Hub 负责管理所有房间的 WebSocket 客户端。
type Hub struct {
	store      *store.Store
	clients    map[string]map[*Client]bool
	register   chan *Client
	unregister chan *Client
	broadcast  chan Broadcast
}

// Broadcast 用于广播消息。
type Broadcast struct {
	RoomID  string
	Message store.Message
}

// NewHub 创建 Hub。
func NewHub(store *store.Store) *Hub {
	return &Hub{
		store:      store,
		clients:    make(map[string]map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan Broadcast),
	}
}

// RegisterClient 将客户端加入 Hub，并启动读写协程。
func (h *Hub) RegisterClient(client *Client) {
	h.register <- client
	go client.WritePump()
	go client.ReadPump()
}

// Run 启动 Hub 主循环。
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			if _, ok := h.clients[client.RoomID]; !ok {
				h.clients[client.RoomID] = make(map[*Client]bool)
			}
			h.clients[client.RoomID][client] = true
			// 推送最近消息
			history := h.store.ListMessages(client.RoomID)
			for _, msg := range history {
				client.Send <- msg
			}
		case client := <-h.unregister:
			if roomClients, ok := h.clients[client.RoomID]; ok {
				if _, exists := roomClients[client]; exists {
					delete(roomClients, client)
					close(client.Send)
				}
				if len(roomClients) == 0 {
					delete(h.clients, client.RoomID)
				}
			}
		case packet := <-h.broadcast:
			h.store.AppendMessage(packet.RoomID, packet.Message)
			if roomClients, ok := h.clients[packet.RoomID]; ok {
				for client := range roomClients {
					select {
					case client.Send <- packet.Message:
					default:
						close(client.Send)
						delete(roomClients, client)
					}
				}
			}
		}
	}
}

// Client 表示单个 WebSocket 连接。
type Client struct {
	ID     string
	User   *store.User
	RoomID string
	Hub    *Hub
	Conn   *websocket.Conn
	Send   chan store.Message
}

// InboundMessage 表示客户端发送的消息。
type InboundMessage struct {
	Type    string `json:"type"`
	Content string `json:"content"`
}

// ReadPump 处理来自客户端的消息。
func (c *Client) ReadPump() {
	defer func() {
		c.Hub.unregister <- c
		_ = c.Conn.Close()
	}()

	c.Conn.SetReadLimit(maxMessageSize)
	_ = c.Conn.SetReadDeadline(time.Now().Add(pongWait))
	c.Conn.SetPongHandler(func(string) error {
		_ = c.Conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		var inbound InboundMessage
		if err := c.Conn.ReadJSON(&inbound); err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("read error: %v", err)
			}
			break
		}
		if inbound.Type != "message" || inbound.Content == "" {
			continue
		}
		msg := store.Message{
			ID:         uuid.NewString(),
			RoomID:     c.RoomID,
			SenderID:   c.User.ID,
			SenderName: c.User.Username,
			Content:    inbound.Content,
			SentAt:     time.Now(),
		}
		c.Hub.broadcast <- Broadcast{
			RoomID:  c.RoomID,
			Message: msg,
		}
	}
}

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 512
)

// WritePump 将消息写回客户端。
func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		_ = c.Conn.Close()
	}()

	for {
		select {
		case msg, ok := <-c.Send:
			_ = c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				_ = c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.Conn.WriteJSON(msg); err != nil {
				return
			}
		case <-ticker.C:
			_ = c.Conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.Conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
