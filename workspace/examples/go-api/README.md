# Go API Starter

Simple Go REST API starter template using Gorilla Mux.

## Setup

```bash
# Download dependencies
go mod download
```

## Run

```bash
go run main.go
```

## Build

```bash
# Build binary
go build -o api

# Run binary
./api
```

## Test

```bash
# In another terminal
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/hello/world
```

## Features

- Go 1.22
- Gorilla Mux router
- JSON middleware
- Basic routing
- Health check endpoint

## Next Steps

- Add database connection (GORM with PostgreSQL)
- Add authentication (JWT)
- Add validation (go-playground/validator)
- Add tests (testing package)
- Add configuration (viper)
- Add logging (zap, logrus)
- Add graceful shutdown
