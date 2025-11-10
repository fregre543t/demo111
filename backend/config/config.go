package config

import (
	"os"
)

type Config struct {
	Port        string
	Environment string
	JWTSecret   string
	DBPath      string
}

func Load() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	env := os.Getenv("ENVIRONMENT")
	if env == "" {
		env = "development"
	}

	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "your-secret-key-change-in-production"
	}

	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "chat.db"
	}

	return &Config{
		Port:        port,
		Environment: env,
		JWTSecret:   jwtSecret,
		DBPath:      dbPath,
	}
}
