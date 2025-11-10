package handlers

import (
	"chat-backend/internal/database"
	"chat-backend/internal/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// SendMessageRequest 发送消息请求
type SendMessageRequest struct {
	ToUserID    uint   `json:"to_user_id" binding:"required"`
	Content     string `json:"content" binding:"required"`
	MessageType string `json:"message_type"`
}

// SendMessage 发送消息（保存到数据库）
func SendMessage(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	msgType := req.MessageType
	if msgType == "" {
		msgType = "text"
	}

	message := models.Message{
		FromUserID:  userID.(uint),
		ToUserID:    req.ToUserID,
		Content:     req.Content,
		MessageType: msgType,
		IsRead:      false,
	}

	if err := database.DB.Create(&message).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "发送消息失败"})
		return
	}

	// 预加载发送者信息
	database.DB.Preload("FromUser").Preload("ToUser").First(&message, message.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "发送成功",
		"data":    message,
	})
}

// GetMessages 获取与某个用户的聊天记录
func GetMessages(c *gin.Context) {
	userID, _ := c.Get("user_id")
	otherUserIDStr := c.Param("user_id")
	otherUserID, err := strconv.ParseUint(otherUserIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	// 获取分页参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "50"))
	offset := (page - 1) * pageSize

	var messages []models.Message
	err = database.DB.
		Where("(from_user_id = ? AND to_user_id = ?) OR (from_user_id = ? AND to_user_id = ?)",
			userID, otherUserID, otherUserID, userID).
		Order("created_at DESC").
		Limit(pageSize).
		Offset(offset).
		Preload("FromUser").
		Preload("ToUser").
		Find(&messages).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取消息失败"})
		return
	}

	// 标记消息为已读
	database.DB.Model(&models.Message{}).
		Where("from_user_id = ? AND to_user_id = ? AND is_read = ?", otherUserID, userID, false).
		Update("is_read", true)

	c.JSON(http.StatusOK, gin.H{
		"messages": messages,
		"page":     page,
		"page_size": pageSize,
	})
}

// GetConversations 获取会话列表
func GetConversations(c *gin.Context) {
	userID, _ := c.Get("user_id")

	type Conversation struct {
		UserID       uint      `json:"user_id"`
		Username     string    `json:"username"`
		Nickname     string    `json:"nickname"`
		Avatar       string    `json:"avatar"`
		LastMessage  string    `json:"last_message"`
		LastTime     time.Time `json:"last_time"`
		UnreadCount  int64     `json:"unread_count"`
		IsOnline     bool      `json:"is_online"`
	}

	var conversations []Conversation

	// 查询最近的聊天对象
	err := database.DB.Raw(`
		SELECT 
			u.id as user_id,
			u.username,
			u.nickname,
			u.avatar,
			u.is_online,
			m.content as last_message,
			m.created_at as last_time,
			(SELECT COUNT(*) FROM messages 
			 WHERE from_user_id = u.id AND to_user_id = ? AND is_read = false) as unread_count
		FROM users u
		INNER JOIN messages m ON (m.from_user_id = u.id OR m.to_user_id = u.id)
		WHERE (m.from_user_id = ? OR m.to_user_id = ?) AND u.id != ?
		GROUP BY u.id
		ORDER BY m.created_at DESC
	`, userID, userID, userID, userID).Scan(&conversations).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取会话列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"conversations": conversations})
}

// MarkAsRead 标记消息为已读
func MarkAsRead(c *gin.Context) {
	userID, _ := c.Get("user_id")
	fromUserIDStr := c.Param("user_id")
	fromUserID, err := strconv.ParseUint(fromUserIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	result := database.DB.Model(&models.Message{}).
		Where("from_user_id = ? AND to_user_id = ? AND is_read = ?", fromUserID, userID, false).
		Update("is_read", true)

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "标记失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "标记成功",
		"count":   result.RowsAffected,
	})
}

// GetUnreadCount 获取未读消息数
func GetUnreadCount(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var count int64
	database.DB.Model(&models.Message{}).
		Where("to_user_id = ? AND is_read = ?", userID, false).
		Count(&count)

	c.JSON(http.StatusOK, gin.H{"unread_count": count})
}
