package main

import (
	"fmt"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	authHandlers "pun-account-backend/internal/auth/handlers"
	authRepository "pun-account-backend/internal/auth/repository"
	authServices "pun-account-backend/internal/auth/services"
	serviceHandlers "pun-account-backend/internal/services/handlers"
	serviceRepository "pun-account-backend/internal/services/repository"
	serviceServices "pun-account-backend/internal/services/services"
	transactionHandlers "pun-account-backend/internal/transactions/handlers"
	transactionRepository "pun-account-backend/internal/transactions/repository"
	transactionServices "pun-account-backend/internal/transactions/services"
	"pun-account-backend/internal/wallets/handlers"
	"pun-account-backend/internal/wallets/repository"
	"pun-account-backend/internal/wallets/services"
)

func main() {
	// 1. Load local environment variables if present
	_ = godotenv.Load()

	// 2. Connect to PostgreSQL
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		host := os.Getenv("DB_HOST")
		if host == "" {
			host = "localhost"
		}
		port := os.Getenv("DB_PORT")
		if port == "" {
			port = "5432"
		}
		user := os.Getenv("DB_USER")
		if user == "" {
			user = "noah"
		}
		password := os.Getenv("DB_PASSWORD")
		dbname := os.Getenv("DB_NAME")
		if dbname == "" {
			dbname = "pun_account"
		}
		sslmode := os.Getenv("DB_SSLMODE")
		if sslmode == "" {
			sslmode = "disable"
		}

		if password != "" {
			dsn = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=%s", user, password, host, port, dbname, sslmode)
		} else {
			dsn = fmt.Sprintf("postgres://%s@%s:%s/%s?sslmode=%s", user, host, port, dbname, sslmode)
		}
	}

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// 3. Initialize layers
	authRepo := authRepository.NewAuthRepository(db)
	authService := authServices.NewAuthService(authRepo)
	authHandler := authHandlers.NewAuthHandler(authService)

	walletRepo := repository.NewWalletRepository(db)
	walletService := services.NewWalletService(walletRepo)
	walletHandler := handlers.NewWalletHandler(walletService)

	serviceRepo := serviceRepository.NewServiceRepository(db)
	serviceService := serviceServices.NewServiceService(serviceRepo)
	serviceHandler := serviceHandlers.NewServiceHandler(serviceService)

	transactionRepo := transactionRepository.NewTransactionRepository(db)
	transactionService := transactionServices.NewTransactionService(transactionRepo)
	transactionHandler := transactionHandlers.NewTransactionHandler(transactionService)

	// 4. Setup Fiber Web Application
	app := fiber.New(fiber.Config{
		AppName: "Pun Account API v1",
	})

	app.Use(recover.New())
	app.Use(logger.New())
	app.Use(cors.New())

	// Health Check
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status": "healthy",
			"app":    "pun-account-backend",
		})
	})

	// API v1 Routing
	apiV1 := app.Group("/api/v1")
	authHandler.RegisterRoutes(apiV1)
	walletHandler.RegisterRoutes(apiV1)
	serviceHandler.RegisterRoutes(apiV1)
	transactionHandler.RegisterRoutes(apiV1)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server listening on port %s", port)
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("Server stopped: %v", err)
	}
}
