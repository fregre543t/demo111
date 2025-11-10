package config

import (
	"os"
	"strings"
)

// Config 代表服务运行所需的基础配置。
type Config struct {
	AppPort       string
	AdminPassword string
	CORSOrigins   []string
}

// Load 从环境变量加载配置并填充默认值。
func Load() Config {
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	adminPassword := os.Getenv("ADMIN_PASSWORD")
	if adminPassword == "" {
		adminPassword = "admin123" // demo 默认值，生产环境必须覆盖
	}

	corsOrigins := os.Getenv("CORS_ALLOW_ORIGINS")
	var origins []string
	if corsOrigins == "" {
		origins = []string{"*"}
	} else {
		for _, origin := range strings.Split(corsOrigins, ",") {
			if trimmed := strings.TrimSpace(origin); trimmed != "" {
				origins = append(origins, trimmed)
			}
		}
		if len(origins) == 0 {
			origins = []string{"*"}
		}
	}

	return Config{
		AppPort:       port,
		AdminPassword: adminPassword,
		CORSOrigins:   origins,
	}
}
