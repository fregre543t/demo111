package chat

import (
	"context"
	"encoding/json"
	"log"
	"sync"

	"chatapp/internal/models"
	"chatapp/internal/store"
)

type Hub struct {
	store      store.Store
	register   chan *Client
	unregister chan *Client
	broadcast  chan *models.Message

	mu      sync.RWMutex
	clients map[*Client]bool
}

func NewHub(store store.Store) *Hub {
	return &Hub{
		store:      store,
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan *models.Message, 256),
		clients:    make(map[*Client]bool),
	}
}

func (h *Hub) Run(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			h.shutdown()
			return
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client] = true
			h.mu.Unlock()
		case client := <-h.unregister:
			h.removeClient(client)
		case msg := <-h.broadcast:
			h.dispatch(msg)
		}
	}
}

func (h *Hub) shutdown() {
	h.mu.Lock()
	defer h.mu.Unlock()
	for client := range h.clients {
		client.Close()
		delete(h.clients, client)
	}
}

func (h *Hub) removeClient(client *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if _, ok := h.clients[client]; ok {
		delete(h.clients, client)
		client.Close()
	}
}

func (h *Hub) dispatch(msg *models.Message) {
	data, err := json.Marshal(NewOutgoingMessage(msg))
	if err != nil {
		log.Printf("marshal outgoing message: %v", err)
		return
	}

	h.mu.RLock()
	defer h.mu.RUnlock()
	for client := range h.clients {
		select {
		case client.send <- data:
		default:
			go h.removeClient(client)
		}
	}
}

func (h *Hub) HandleIncoming(msg *models.Message) {
	select {
	case h.broadcast <- msg:
	default:
		log.Printf("dropping message %s due to full channel", msg.ID)
	}
}

func (h *Hub) SaveAndBroadcast(ctx context.Context, msg *models.Message) error {
	if err := h.store.SaveMessage(ctx, msg); err != nil {
		return err
	}
	h.HandleIncoming(msg)
	return nil
}

func (h *Hub) Register(client *Client) {
	h.register <- client
}

func (h *Hub) SendHistory(client *Client, msgs []*models.Message) {
	for _, msg := range msgs {
		data, err := json.Marshal(NewOutgoingMessage(msg))
		if err != nil {
			continue
		}
		select {
		case client.send <- data:
		default:
			return
		}
	}
}
