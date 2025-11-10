package server

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	"chatapp/internal/auth"
	"chatapp/internal/chat"
	"chatapp/internal/handlers"
	"chatapp/internal/models"
	"chatapp/internal/store/memory"
)

func Run() error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	store := memory.New()
	if err := store.CreateRoom(ctx, &models.Room{
		ID:        "default",
		Name:      "公共大厅",
		CreatedAt: time.Now(),
	}); err != nil {
		return err
	}

	tokenManager := auth.NewManager(getEnv("JWT_SECRET", "change-me"), 24*time.Hour)
	hub := chat.NewHub(store)
	go hub.Run(ctx)

	handler := handlers.NewHandler(store, hub, tokenManager)
	mw := handlers.NewMiddleware(tokenManager, store)

	r := chi.NewRouter()
	r.Use(chimiddleware.RequestID)
	r.Use(chimiddleware.RealIP)
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Recoverer)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	handler.RegisterRoutes(r, mw)

	srv := &http.Server{
		Addr:              ":8080",
		Handler:           r,
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		<-ctx.Done()
		log.Println("shutting down server...")
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := srv.Shutdown(shutdownCtx); err != nil {
			log.Printf("server shutdown error: %v", err)
		}
	}()

	log.Println("server listening on :8080")
	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		return err
	}
	return nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
