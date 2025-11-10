package chat

import (
	"context"
	"encoding/json"
	"errors"
	"log"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"

	"chatapp/internal/models"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 5120
)

var ErrUnsupportedMessageType = errors.New("unsupported message type")

type Client struct {
	hub  *Hub
	conn *websocket.Conn
	send chan []byte
	user *models.User
}

func NewClient(hub *Hub, conn *websocket.Conn, user *models.User) *Client {
	return &Client{
		hub:  hub,
		conn: conn,
		send: make(chan []byte, 256),
		user: user,
	}
}

func (c *Client) Run(ctx context.Context) {
	go c.writePump(ctx)
	c.readPump(ctx)
}

func (c *Client) readPump(ctx context.Context) {
	defer func() {
		c.hub.unregister <- c
	}()
	c.conn.SetReadLimit(maxMessageSize)
	_ = c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		return c.conn.SetReadDeadline(time.Now().Add(pongWait))
	})

	for {
		_, data, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsCloseError(err, websocket.CloseNormalClosure, websocket.CloseGoingAway) {
				log.Printf("client disconnect: %v", err)
			} else {
				log.Printf("read error: %v", err)
			}
			break
		}

		var incoming IncomingMessage
		if err := json.Unmarshal(data, &incoming); err != nil {
			log.Printf("invalid message payload: %v", err)
			continue
		}

		if incoming.Type != "chat_message" {
			log.Printf("unsupported message type: %s", incoming.Type)
			continue
		}

		msg := &models.Message{
			ID:         uuid.New().String(),
			SenderID:   c.user.ID,
			ReceiverID: incoming.ReceiverID,
			RoomID:     incoming.RoomID,
			Content:    incoming.Content,
			CreatedAt:  time.Now(),
		}

		if err := c.hub.SaveAndBroadcast(ctx, msg); err != nil {
			log.Printf("save message: %v", err)
		}
	}
}

func (c *Client) writePump(ctx context.Context) {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				_ = c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}
			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				log.Printf("write message: %v", err)
				return
			}
		case <-ticker.C:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				log.Printf("write ping: %v", err)
				return
			}
		case <-ctx.Done():
			return
		}
	}
}

func (c *Client) Close() {
	_ = c.conn.Close()
	close(c.send)
}
