package websocket

import (
	"encoding/json"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 512 * 1024 // 512KB
)

// Client WebSocket客户端
type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	send   chan *Message
	UserID uint
}

// NewClient 创建新客户端
func NewClient(hub *Hub, conn *websocket.Conn, userID uint) *Client {
	return &Client{
		hub:    hub,
		conn:   conn,
		send:   make(chan *Message, 256),
		UserID: userID,
	}
}

// ReadPump 读取客户端消息
func (c *Client) ReadPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("错误: %v", err)
			}
			break
		}

		var msg Message
		if err := json.Unmarshal(message, &msg); err != nil {
			log.Printf("解析消息失败: %v", err)
			continue
		}

		msg.FromUserID = c.UserID
		msg.Timestamp = time.Now().Unix()

		// 根据消息类型处理
		switch msg.Type {
		case "message":
			if msg.ToUserID > 0 {
				// 私聊消息
				c.hub.SendPrivateMessage(&msg)
			} else {
				// 广播消息
				c.hub.BroadcastMessage(&msg)
			}
		case "typing":
			// 正在输入通知
			if msg.ToUserID > 0 {
				c.hub.SendPrivateMessage(&msg)
			}
		default:
			log.Printf("未知消息类型: %s", msg.Type)
		}
	}
}

// WritePump 向客户端发送消息
func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			data, err := json.Marshal(message)
			if err != nil {
				log.Printf("序列化消息失败: %v", err)
				continue
			}

			if err := c.conn.WriteMessage(websocket.TextMessage, data); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
