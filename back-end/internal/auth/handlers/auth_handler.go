package handlers

import (
	"errors"
	"strings"

	"github.com/gofiber/fiber/v2"

	"pun-account-backend/internal/auth/services"
)

type AuthHandler struct {
	authService services.AuthService
}

func NewAuthHandler(authService services.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

func (h *AuthHandler) RegisterRoutes(router fiber.Router) {
	auth := router.Group("/auth")
	auth.Post("/google", h.SignInWithGoogle)
	auth.Get("/me", h.GetMe)
}

// SignInWithGoogle handles Google Sign-In requests (ID token or direct profile payload)
func (h *AuthHandler) SignInWithGoogle(c *fiber.Ctx) error {
	var req services.GoogleSignInRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INVALID_PAYLOAD",
				"message": "Malformed JSON request body",
			},
		})
	}

	if req.IDToken == "" && req.Email == "" && req.GoogleID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INVALID_INPUT",
				"message": "Either id_token, email, or google_id must be provided",
			},
		})
	}

	resp, err := h.authService.SignInWithGoogle(c.Context(), req)
	if err != nil {
		if errors.Is(err, services.ErrInvalidRequest) {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": fiber.Map{
					"code":    "INVALID_INPUT",
					"message": err.Error(),
				},
			})
		}

		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "AUTH_FAILED",
				"message": "Failed to authenticate with Google: " + err.Error(),
			},
		})
	}

	return c.Status(fiber.StatusOK).JSON(resp)
}

// GetMe fetches current authenticated user info
func (h *AuthHandler) GetMe(c *fiber.Ctx) error {
	authHeader := c.Get("Authorization")
	if authHeader == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "UNAUTHORIZED",
				"message": "Missing Authorization header",
			},
		})
	}

	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "UNAUTHORIZED",
				"message": "Invalid Authorization header format. Expected 'Bearer <token>'",
			},
		})
	}

	token := strings.TrimSpace(parts[1])
	claims, err := h.authService.VerifyToken(token)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "UNAUTHORIZED",
				"message": "Token is invalid or expired",
			},
		})
	}

	resp, err := h.authService.GetMe(c.Context(), claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "USER_NOT_FOUND",
				"message": "User not found",
			},
		})
	}

	return c.Status(fiber.StatusOK).JSON(resp)
}

// AuthRequiredMiddleware is a reusable middleware to guard protected routes
func AuthRequiredMiddleware(authService services.AuthService) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": fiber.Map{
					"code":    "UNAUTHORIZED",
					"message": "Authorization header is required",
				},
			})
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": fiber.Map{
					"code":    "UNAUTHORIZED",
					"message": "Invalid authorization format",
				},
			})
		}

		claims, err := authService.VerifyToken(strings.TrimSpace(parts[1]))
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": fiber.Map{
					"code":    "UNAUTHORIZED",
					"message": "Invalid or expired token",
				},
			})
		}

		c.Locals("user_id", claims.UserID)
		c.Locals("email", claims.Email)
		c.Locals("business_id", claims.BusinessID)

		return c.Next()
	}
}
