package main

import (
	"log"
	"net/http"
	"path/filepath"
	"time"

	"api/handlers"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
)

func main() {
	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(60 * time.Second))

	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"}, // TODO: Thay bằng domain Frontend khi deploy
		AllowedMethods:   []string{"GET", "POST", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Content-Type"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	dataPath := filepath.Join("data", "omikuji.json")
	
	omikujiHandler, err := handlers.NewOmikujiHandler(dataPath)
	if err != nil {
		log.Fatalf("Khởi động thất bại. Không thể load data: %v", err)
	}

	log.Printf("Đã load thành công %d quẻ xăm vào bộ nhớ.", len(omikujiHandler.Fortunes))

	r.Get("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})

	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/omikuji/draw", omikujiHandler.Draw)
		r.Get("/omikuji/all", omikujiHandler.GetAll)
	})

	log.Println("Server đang chạy tại cổng :8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatal(err)
	}
}