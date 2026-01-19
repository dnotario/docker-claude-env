package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
)

type Response struct {
	Message   string                 `json:"message"`
	Endpoints map[string]string      `json:"endpoints,omitempty"`
	Data      map[string]interface{} `json:"data,omitempty"`
}

type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp string `json:"timestamp"`
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	response := Response{
		Message: "Welcome to Go API starter!",
		Endpoints: map[string]string{
			"health": "/health",
			"hello":  "/hello/{name}",
		},
	}
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now().Format(time.RFC3339),
	}
	json.NewEncoder(w).Encode(response)
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	name := vars["name"]

	response := Response{
		Message: fmt.Sprintf("Hello, %s!", name),
	}
	json.NewEncoder(w).Encode(response)
}

func main() {
	r := mux.NewRouter()

	// Middleware
	r.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			next.ServeHTTP(w, r)
		})
	})

	// Routes
	r.HandleFunc("/", indexHandler).Methods("GET")
	r.HandleFunc("/health", healthHandler).Methods("GET")
	r.HandleFunc("/hello/{name}", helloHandler).Methods("GET")

	port := "8000"
	log.Printf("Server starting on port %s", port)
	log.Printf("Try: curl http://localhost:%s/", port)

	if err := http.ListenAndServe(":"+port, r); err != nil {
		log.Fatal(err)
	}
}
