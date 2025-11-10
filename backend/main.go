package main

import (
	"chat-app-backend/config"
	"chat-app-backend/database"
	"chat-app-backend/handlers"
	"chat-app-backend/middleware"
	"chat-app-backend/models"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化配置
	cfg := config.Load()

	// 初始化数据库
	db := database.InitDB()
	
	// 自动迁移
	db.AutoMigrate(&models.User{}, &models.Message{}, &models.Room{})

	// 初始化WebSocket Hub
	hub := handlers.NewHub()
	go hub.Run()

	// 设置Gin模式
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建Gin路由
	r := gin.Default()

	// CORS配置
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// API路由组
	api := r.Group("/api")
	{
		// 认证路由
		auth := api.Group("/auth")
		{
			auth.POST("/register", handlers.Register)
			auth.POST("/login", handlers.Login)
		}

		// 需要认证的路由
		protected := api.Group("")
		protected.Use(middleware.AuthMiddleware())
		{
			// 用户相关
			protected.GET("/user/profile", handlers.GetUserProfile)
			protected.PUT("/user/profile", handlers.UpdateUserProfile)

			// 聊天室相关
			protected.GET("/rooms", handlers.GetRooms)
			protected.POST("/rooms", handlers.CreateRoom)
			protected.GET("/rooms/:id", handlers.GetRoom)
			protected.GET("/rooms/:id/messages", handlers.GetMessages)

			// WebSocket连接
			protected.GET("/ws", handlers.HandleWebSocket(hub))
		}

		// 后台管理路由
		admin := api.Group("/admin")
		admin.Use(middleware.AuthMiddleware())
		admin.Use(middleware.AdminMiddleware())
		{
			admin.GET("/users", handlers.AdminGetUsers)
			admin.PUT("/users/:id", handlers.AdminUpdateUser)
			admin.DELETE("/users/:id", handlers.AdminDeleteUser)
			admin.GET("/messages", handlers.AdminGetMessages)
			admin.DELETE("/messages/:id", handlers.AdminDeleteMessage)
			admin.GET("/rooms", handlers.AdminGetRooms)
			admin.DELETE("/rooms/:id", handlers.AdminDeleteRoom)
			admin.GET("/stats", handlers.AdminGetStats)
		}
	}

	// 启动服务器
	log.Printf("服务器启动在端口 %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal("服务器启动失败:", err)
	}
}
