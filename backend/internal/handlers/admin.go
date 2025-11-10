package handlers

import (
	"chat-backend/internal/database"
	"chat-backend/internal/models"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

// GetDashboardStats 获取仪表板统计数据
func GetDashboardStats(c *gin.Context) {
	var totalUsers, totalMessages, onlineUsers int64

	database.DB.Model(&models.User{}).Count(&totalUsers)
	database.DB.Model(&models.Message{}).Count(&totalMessages)
	database.DB.Model(&models.User{}).Where("is_online = ?", true).Count(&onlineUsers)

	// 今日新增用户
	today := time.Now().Truncate(24 * time.Hour)
	var todayNewUsers int64
	database.DB.Model(&models.User{}).Where("created_at >= ?", today).Count(&todayNewUsers)

	// 今日消息数
	var todayMessages int64
	database.DB.Model(&models.Message{}).Where("created_at >= ?", today).Count(&todayMessages)

	c.JSON(http.StatusOK, gin.H{
		"total_users":     totalUsers,
		"total_messages":  totalMessages,
		"online_users":    onlineUsers,
		"today_new_users": todayNewUsers,
		"today_messages":  todayMessages,
	})
}

// GetAllUsers 管理员获取所有用户
func GetAllUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))
	offset := (page - 1) * pageSize

	var users []models.User
	var total int64

	database.DB.Model(&models.User{}).Count(&total)
	err := database.DB.
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

// DeleteUser 删除用户
func DeleteUser(c *gin.Context) {
	userIDStr := c.Param("id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	// 删除用户及相关消息
	tx := database.DB.Begin()
	
	// 删除用户发送的消息
	if err := tx.Where("from_user_id = ?", userID).Delete(&models.Message{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	// 删除用户接收的消息
	if err := tx.Where("to_user_id = ?", userID).Delete(&models.Message{}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	// 删除用户
	if err := tx.Delete(&models.User{}, userID).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	tx.Commit()
	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

// GetAllMessages 管理员获取所有消息
func GetAllMessages(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "50"))
	offset := (page - 1) * pageSize

	var messages []models.Message
	var total int64

	database.DB.Model(&models.Message{}).Count(&total)
	err := database.DB.
		Preload("FromUser").
		Preload("ToUser").
		Limit(pageSize).
		Offset(offset).
		Order("created_at DESC").
		Find(&messages).Error

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取消息列表失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"messages":  messages,
		"total":     total,
		"page":      page,
		"page_size": pageSize,
	})
}

// DeleteMessage 删除消息
func DeleteMessage(c *gin.Context) {
	messageIDStr := c.Param("id")
	messageID, err := strconv.ParseUint(messageIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的消息ID"})
		return
	}

	if err := database.DB.Delete(&models.Message{}, messageID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
}

// UpdateUserStatus 更新用户状态（禁用/启用）
func UpdateUserStatus(c *gin.Context) {
	userIDStr := c.Param("id")
	userID, err := strconv.ParseUint(userIDStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的用户ID"})
		return
	}

	var req struct {
		IsAdmin bool `json:"is_admin"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := database.DB.Model(&models.User{}).Where("id = ?", userID).Update("is_admin", req.IsAdmin).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "更新成功"})
}
