package handlers

import (
	"errors"
	"net/http"

	"pun-account-backend/internal/wallets/models"
	"pun-account-backend/internal/wallets/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// ErrorResponse represents standard API error response body.
type ErrorResponse struct {
	Error ErrorDetail `json:"error"`
}

type ErrorDetail struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

func sendError(c *fiber.Ctx, status int, code, message string) error {
	return c.Status(status).JSON(ErrorResponse{
		Error: ErrorDetail{
			Code:    code,
			Message: message,
		},
	})
}

// WalletHandler handles HTTP requests for wallet resources.
type WalletHandler struct {
	service services.WalletService
}

// NewWalletHandler constructs a new WalletHandler.
func NewWalletHandler(service services.WalletService) *WalletHandler {
	return &WalletHandler{service: service}
}

// RegisterRoutes registers wallet routes on the Fiber router.
func (h *WalletHandler) RegisterRoutes(router fiber.Router) {
	wallets := router.Group("/wallets")
	wallets.Post("/", h.CreateWallet)
	wallets.Get("/", h.ListWallets)
	wallets.Get("/:id", h.GetWallet)
	wallets.Put("/:id", h.UpdateWallet)
	wallets.Delete("/:id", h.DeleteWallet)
}

type createWalletRequest struct {
	BusinessID     string          `json:"business_id"`
	Name           string          `json:"name"`
	Type           string          `json:"type"`
	Currency       string          `json:"currency"`
	InitialBalance float64         `json:"initial_balance"`
	UI             models.WalletUI `json:"ui"`
}

// CreateWallet creates a new wallet for a business.
func (h *WalletHandler) CreateWallet(c *fiber.Ctx) error {
	var req createWalletRequest
	if err := c.BodyParser(&req); err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_JSON", "Unable to parse request body")
	}

	businessUUID, err := uuid.Parse(req.BusinessID)
	if err != nil || businessUUID == uuid.Nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Valid business_id UUID is required")
	}

	wallet, err := h.service.CreateWallet(c.Context(), services.CreateWalletInput{
		BusinessID:     businessUUID,
		Name:           req.Name,
		Type:           req.Type,
		Currency:       req.Currency,
		InitialBalance: req.InitialBalance,
		UI:             req.UI,
	})
	if err != nil {
		if errors.Is(err, services.ErrInvalidInput) {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to create wallet")
	}

	return c.Status(http.StatusCreated).JSON(wallet)
}

// GetWallet retrieves a single wallet by ID.
func (h *WalletHandler) GetWallet(c *fiber.Ctx) error {
	idParam := c.Params("id")
	walletUUID, err := uuid.Parse(idParam)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid wallet UUID")
	}

	wallet, err := h.service.GetWallet(c.Context(), walletUUID)
	if err != nil {
		if errors.Is(err, services.ErrNotFound) {
			return sendError(c, http.StatusNotFound, "NOT_FOUND", "Wallet not found")
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to retrieve wallet")
	}

	return c.Status(http.StatusOK).JSON(wallet)
}

// ListWallets returns all wallets for a given business_id query parameter.
func (h *WalletHandler) ListWallets(c *fiber.Ctx) error {
	businessIDStr := c.Query("business_id")
	if businessIDStr == "" {
		return sendError(c, http.StatusBadRequest, "MISSING_QUERY_PARAM", "Query parameter 'business_id' is required")
	}

	businessUUID, err := uuid.Parse(businessIDStr)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid business_id UUID format")
	}

	wallets, err := h.service.ListWallets(c.Context(), businessUUID)
	if err != nil {
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to retrieve wallets")
	}

	return c.Status(http.StatusOK).JSON(wallets)
}

type updateWalletRequest struct {
	Name     *string          `json:"name"`
	Type     *string          `json:"type"`
	Currency *string          `json:"currency"`
	IsActive *bool            `json:"is_active"`
	UI       *models.WalletUI `json:"ui"`
}

// UpdateWallet updates an existing wallet.
func (h *WalletHandler) UpdateWallet(c *fiber.Ctx) error {
	idParam := c.Params("id")
	walletUUID, err := uuid.Parse(idParam)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid wallet UUID")
	}

	var req updateWalletRequest
	if err := c.BodyParser(&req); err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_JSON", "Unable to parse request body")
	}

	updated, err := h.service.UpdateWallet(c.Context(), walletUUID, services.UpdateWalletInput{
		Name:     req.Name,
		Type:     req.Type,
		Currency: req.Currency,
		IsActive: req.IsActive,
		UI:       req.UI,
	})
	if err != nil {
		if errors.Is(err, services.ErrNotFound) {
			return sendError(c, http.StatusNotFound, "NOT_FOUND", "Wallet not found")
		}
		if errors.Is(err, services.ErrInvalidInput) {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to update wallet")
	}

	return c.Status(http.StatusOK).JSON(updated)
}

// DeleteWallet performs soft deletion of a wallet by ID.
func (h *WalletHandler) DeleteWallet(c *fiber.Ctx) error {
	idParam := c.Params("id")
	walletUUID, err := uuid.Parse(idParam)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid wallet UUID")
	}

	if err := h.service.DeleteWallet(c.Context(), walletUUID); err != nil {
		if errors.Is(err, services.ErrNotFound) {
			return sendError(c, http.StatusNotFound, "NOT_FOUND", "Wallet not found")
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to delete wallet")
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Wallet deleted successfully",
	})
}
