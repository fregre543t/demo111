package main

import (
	"log"

	"chatapp/internal/server"
)

func main() {
	if err := server.Run(); err != nil {
		log.Fatalf("unable to start server: %v", err)
	}
}
