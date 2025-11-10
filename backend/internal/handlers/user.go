package handlers

import (
	"chat-backend/internal/database"
	"chat-backend/internal/models"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// GetUsers 获取用户列表
func GetUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))
	offset := (page - 1) * pageSize

	var users []models.User
	var total int64

	database.DB.Model(&models.User{}).Count(&total)
	err := database.DB.
		Select("id", "username", "nickname", "avatar", "is_online", "last_seen", "created_at").
		Limit(pageSize).
		Offset(offset).
		Order("created_at DESC").
		Find(&users).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取用户列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"users":     users,
		"total":     total,
		"page":      page,
		"page_size": pageSize,
	})
}

// SearchUsers 搜索用户
func SearchUsers(c *gin.Context) {
	keyword := c.Query("keyword")
	if keyword == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "请提供搜索关键词"})
		return
	}

	var users []models.User
	err := database.DB.
		Select("id", "username", "nickname", "avatar", "is_online").
		Where("username LIKE ? OR nickname LIKE ?", "%"+keyword+"%", "%"+keyword+"%").
		Limit(20).
		Find(&users).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "搜索失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"users": users})
}

// GetUserByID 获取用户信息
func GetUserByID(c *gin.Context) {
	userIDStr := c.Param("id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	var user models.User
	if err := database.DB.
		Select("id", "username", "nickname", "avatar", "is_online", "last_seen", "created_at").
		First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, user)
}

// GetOnlineUsers 获取在线用户列表
func GetOnlineUsers(c *gin.Context) {
	var users []models.User
	err := database.DB.
		Select("id", "username", "nickname", "avatar", "last_seen").
		Where("is_online = ?", true).
		Find(&users).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取在线用户失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"online_users": users})
}
