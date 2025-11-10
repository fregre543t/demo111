package handlers

import (
	"chat-app-backend/database"
	"chat-app-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetRooms(c *gin.Context) {
	var rooms []models.Room
	if err := database.GetDB().Where("is_public = ?", true).Find(&rooms).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取聊天室失败"})
		return
	}

	c.JSON(http.StatusOK, rooms)
}

type CreateRoomRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	IsPublic    bool   `json:"is_public"`
}

func CreateRoom(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req CreateRoomRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	room := models.Room{
		Name:        req.Name,
		Description: req.Description,
		IsPublic:    req.IsPublic,
		CreatedBy:   userID.(uint),
	}

	if err := database.GetDB().Create(&room).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建聊天室失败"})
		return
	}

	c.JSON(http.StatusCreated, room)
}

func GetRoom(c *gin.Context) {
	id := c.Param("id")

	var room models.Room
	if err := database.GetDB().First(&room, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "聊天室不存在"})
		return
	}

	c.JSON(http.StatusOK, room)
}

func GetMessages(c *gin.Context) {
	roomID := c.Param("id")
	limit := c.DefaultQuery("limit", "50")
	offset := c.DefaultQuery("offset", "0")

	limitInt, _ := strconv.Atoi(limit)
	offsetInt, _ := strconv.Atoi(offset)

	var messages []models.Message
	if err := database.GetDB().
		Preload("User").
		Where("room_id = ?", roomID).
		Order("created_at DESC").
		Limit(limitInt).
		Offset(offsetInt).
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取消息失败"})
		return
	}

	// 反转消息顺序（最新的在最后）
	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	c.JSON(http.StatusOK, messages)
}
