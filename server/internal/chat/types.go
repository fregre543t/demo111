package chat

import (
	"time"

	"chatapp/internal/models"
)

type IncomingMessage struct {
	Type       string `json:"type"`
	Content    string `json:"content"`
	RoomID     string `json:"room_id,omitempty"`
	ReceiverID string `json:"receiver_id,omitempty"`
}

type OutgoingMessage struct {
	Type       string `json:"type"`
	MessageID  string `json:"id"`
	SenderID   string `json:"sender_id"`
	ReceiverID string `json:"receiver_id,omitempty"`
	RoomID     string `json:"room_id,omitempty"`
	Content    string `json:"content"`
	CreatedAt  string `json:"created_at"`
}

func NewOutgoingMessage(msg *models.Message) OutgoingMessage {
	return OutgoingMessage{
		Type:       "chat_message",
		MessageID:  msg.ID,
		SenderID:   msg.SenderID,
		ReceiverID: msg.ReceiverID,
		RoomID:     msg.RoomID,
		Content:    msg.Content,
		CreatedAt:  msg.CreatedAt.Format(time.RFC3339Nano),
	}
}
