package main

import (
	"chat-backend/internal/database"
	"chat-backend/internal/handlers"
	"chat-backend/internal/middleware"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	// 初始化数据库
	if err := database.InitDatabase(); err != nil {
		log.Fatal("数据库初始化失败:", err)
	}

	// 设置Gin模式
	gin.SetMode(gin.ReleaseMode)
	r := gin.Default()

	// CORS中间件
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

	// 公开路由
	public := r.Group("/api")
	{
		public.POST("/register", handlers.Register)
		public.POST("/login", handlers.Login)
	}

	// 需要认证的路由
	protected := r.Group("/api")
	protected.Use(middleware.AuthMiddleware())
	{
		// WebSocket连接
		protected.GET("/ws", handlers.HandleWebSocket)

		// 用户相关
		protected.GET("/profile", handlers.GetProfile)
		protected.PUT("/profile", handlers.UpdateProfile)
		protected.GET("/users", handlers.GetUsers)
		protected.GET("/users/search", handlers.SearchUsers)
		protected.GET("/users/:id", handlers.GetUserByID)
		protected.GET("/users/online/list", handlers.GetOnlineUsers)
		protected.GET("/ws/online", handlers.GetWSOnlineUsers)

		// 消息相关
		protected.POST("/messages", handlers.SendMessage)
		protected.GET("/messages/:user_id", handlers.GetMessages)
		protected.GET("/conversations", handlers.GetConversations)
		protected.PUT("/messages/:user_id/read", handlers.MarkAsRead)
		protected.GET("/messages/unread/count", handlers.GetUnreadCount)
	}

	// 管理员路由
	admin := r.Group("/api/admin")
	admin.Use(middleware.AuthMiddleware(), middleware.AdminMiddleware())
	{
		admin.GET("/stats", handlers.GetDashboardStats)
		admin.GET("/users", handlers.GetAllUsers)
		admin.DELETE("/users/:id", handlers.DeleteUser)
		admin.PUT("/users/:id/status", handlers.UpdateUserStatus)
		admin.GET("/messages", handlers.GetAllMessages)
		admin.DELETE("/messages/:id", handlers.DeleteMessage)
	}

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	log.Println("服务器启动在 :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatal("服务器启动失败:", err)
	}
}
