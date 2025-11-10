package main

import (
	"fmt"
	"log"

	"websocket-chat/internal/api"
	"websocket-chat/internal/config"
	"websocket-chat/internal/store"
	"websocket-chat/internal/ws"
)

func main() {
	cfg := config.Load()
	st := store.New()
	hub := ws.NewHub(st)

	go hub.Run()

	handler := api.NewHandler(cfg, st, hub)
	router := handler.SetupRouter()

	addr := fmt.Sprintf(":%s", cfg.AppPort)
	log.Printf("服务器启动，监听 %s", addr)
	if err := router.Run(addr); err != nil {
		log.Fatalf("服务器启动失败: %v", err)
	}
}
