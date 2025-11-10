package main

import (
	"chat-app/internal/handlers"
	"chat-app/internal/models"
	"chat-app/internal/websocket"
	"log"
	"net/http"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化数据库（内存存储）
	db := models.NewInMemoryDB()

	// 初始化Hub
	hub := websocket.NewHubWithDB(db)
	go hub.Run()

	// 创建路由
	r := gin.Default()

	// 配置CORS
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"Origin", "Content-Type", "Authorization"}
	r.Use(cors.New(config))

	// 初始化handlers
	chatHandler := handlers.NewChatHandler(hub, db)
	adminHandler := handlers.NewAdminHandler(db)

	// WebSocket路由
	r.GET("/ws", chatHandler.HandleWebSocket)

	// 聊天API路由
	api := r.Group("/api")
	{
		api.POST("/auth/login", chatHandler.Login)
		api.POST("/auth/register", chatHandler.Register)
		api.GET("/users", chatHandler.GetUsers)
		api.GET("/messages", chatHandler.GetMessages)
	}

	// 后台管理API路由
	admin := r.Group("/admin")
	{
		admin.POST("/login", adminHandler.Login)
		admin.GET("/users", adminHandler.GetAllUsers)
		admin.DELETE("/users/:id", adminHandler.DeleteUser)
		admin.GET("/messages", adminHandler.GetAllMessages)
		admin.DELETE("/messages/:id", adminHandler.DeleteMessage)
		admin.GET("/stats", adminHandler.GetStats)
	}

	log.Println("服务器启动在 :8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal("服务器启动失败:", err)
	}
}
