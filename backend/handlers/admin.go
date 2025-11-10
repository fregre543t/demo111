package handlers

import (
	"chat-app-backend/database"
	"chat-app-backend/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func AdminGetUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))
	offset := (page - 1) * pageSize

	var users []models.User
	var total int64

	database.GetDB().Model(&models.User{}).Count(&total)
	if err := database.GetDB().Offset(offset).Limit(pageSize).Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取用户列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users": users,
		"total": total,
		"page":  page,
		"page_size": pageSize,
	})
}

type AdminUpdateUserRequest struct {
	Nickname string `json:"nickname"`
	IsAdmin  *bool  `json:"is_admin"`
	IsActive *bool  `json:"is_active"`
}

func AdminUpdateUser(c *gin.Context) {
	id := c.Param("id")

	var user models.User
	if err := database.GetDB().First(&user, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	var req AdminUpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Nickname != "" {
		user.Nickname = req.Nickname
	}
	if req.IsAdmin != nil {
		user.IsAdmin = *req.IsAdmin
	}
	if req.IsActive != nil {
		user.IsActive = *req.IsActive
	}

	if err := database.GetDB().Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "更新成功",
		"user":    user,
	})
}

func AdminDeleteUser(c *gin.Context) {
	id := c.Param("id")

	if err := database.GetDB().Delete(&models.User{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

func AdminGetMessages(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "50"))
	offset := (page - 1) * pageSize

	var messages []models.Message
	var total int64

	database.GetDB().Model(&models.Message{}).Count(&total)
	if err := database.GetDB().
		Preload("User").
		Offset(offset).
		Limit(pageSize).
		Order("created_at DESC").
		Find(&messages).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取消息列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"messages": messages,
		"total":    total,
		"page":     page,
		"page_size": pageSize,
	})
}

func AdminDeleteMessage(c *gin.Context) {
	id := c.Param("id")

	if err := database.GetDB().Delete(&models.Message{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

func AdminGetRooms(c *gin.Context) {
	var rooms []models.Room
	if err := database.GetDB().Find(&rooms).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取聊天室列表失败"})
		return
	}

	c.JSON(http.StatusOK, rooms)
}

func AdminDeleteRoom(c *gin.Context) {
	id := c.Param("id")

	if err := database.GetDB().Delete(&models.Room{}, id).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

func AdminGetStats(c *gin.Context) {
	var userCount, messageCount, roomCount int64

	database.GetDB().Model(&models.User{}).Count(&userCount)
	database.GetDB().Model(&models.Message{}).Count(&messageCount)
	database.GetDB().Model(&models.Room{}).Count(&roomCount)

	c.JSON(http.StatusOK, gin.H{
		"users":    userCount,
		"messages": messageCount,
		"rooms":    roomCount,
	})
}
