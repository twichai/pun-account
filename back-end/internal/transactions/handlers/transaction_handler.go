package handlers

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"pun-account-backend/internal/transactions/repository"
	"pun-account-backend/internal/transactions/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

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

// TransactionHandler handles HTTP requests for transaction resources.
type TransactionHandler struct {
	service services.TransactionService
}

// NewTransactionHandler constructs a new TransactionHandler.
func NewTransactionHandler(service services.TransactionService) *TransactionHandler {
	return &TransactionHandler{service: service}
}

// RegisterRoutes registers transaction routes on the Fiber router.
func (h *TransactionHandler) RegisterRoutes(router fiber.Router) {
	group := router.Group("/transactions")
	group.Post("/", h.CreateTransaction)
	group.Get("/", h.ListTransactions)
	group.Get("/:id", h.GetTransaction)
	group.Put("/:id", h.UpdateTransaction)
	group.Delete("/:id", h.DeleteTransaction)
}

type createTransactionRequest struct {
	BusinessID      string   `json:"business_id"`
	WalletID        string   `json:"wallet_id"`
	ServiceID       string   `json:"service_id"`
	CategoryID      *string  `json:"category_id"`
	Type            string   `json:"type"`
	Amount          float64  `json:"amount"`
	TransactionDate *string  `json:"transaction_date"`
	Description     *string  `json:"description"`
}

type updateTransactionRequest struct {
	WalletID        *string  `json:"wallet_id"`
	ServiceID       *string  `json:"service_id"`
	CategoryID      *string  `json:"category_id"`
	Type            *string  `json:"type"`
	Amount          *float64 `json:"amount"`
	TransactionDate *string  `json:"transaction_date"`
	Description     *string  `json:"description"`
}

func (h *TransactionHandler) CreateTransaction(c *fiber.Ctx) error {
	var req createTransactionRequest
	if err := c.BodyParser(&req); err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_BODY", "Invalid JSON payload")
	}

	businessID, err := uuid.Parse(req.BusinessID)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid business_id format")
	}

	walletID, err := uuid.Parse(req.WalletID)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid wallet_id format")
	}

	serviceID, err := uuid.Parse(req.ServiceID)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid service_id format")
	}

	var categoryID *uuid.UUID
	if req.CategoryID != nil && *req.CategoryID != "" {
		parsed, err := uuid.Parse(*req.CategoryID)
		if err != nil {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid category_id format")
		}
		categoryID = &parsed
	}

	var txDate *time.Time
	if req.TransactionDate != nil && *req.TransactionDate != "" {
		parsed, err := time.Parse(time.RFC3339, *req.TransactionDate)
		if err != nil {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid transaction_date format (RFC3339 required)")
		}
		txDate = &parsed
	}

	tx, err := h.service.CreateTransaction(c.Context(), services.CreateTransactionInput{
		BusinessID:      businessID,
		WalletID:        walletID,
		ServiceID:       serviceID,
		CategoryID:      categoryID,
		Type:            req.Type,
		Amount:          req.Amount,
		TransactionDate: txDate,
		Description:     req.Description,
	})
	if err != nil {
		if errors.Is(err, services.ErrInvalidInput) {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to create transaction")
	}

	return c.Status(http.StatusCreated).JSON(tx)
}

func (h *TransactionHandler) GetTransaction(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid transaction ID format")
	}

	tx, err := h.service.GetTransaction(c.Context(), id)
	if err != nil {
		if errors.Is(err, services.ErrTransactionNotFound) {
			return sendError(c, http.StatusNotFound, "NOT_FOUND", "Transaction not found")
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to get transaction")
	}

	return c.Status(http.StatusOK).JSON(tx)
}

func (h *TransactionHandler) ListTransactions(c *fiber.Ctx) error {
	filter := repository.ListFilter{}

	if bID := c.Query("business_id"); bID != "" {
		if parsed, err := uuid.Parse(bID); err == nil {
			filter.BusinessID = &parsed
		}
	}
	if wID := c.Query("wallet_id"); wID != "" {
		if parsed, err := uuid.Parse(wID); err == nil {
			filter.WalletID = &parsed
		}
	}
	if sID := c.Query("service_id"); sID != "" {
		if parsed, err := uuid.Parse(sID); err == nil {
			filter.ServiceID = &parsed
		}
	}
	if cID := c.Query("category_id"); cID != "" {
		if parsed, err := uuid.Parse(cID); err == nil {
			filter.CategoryID = &parsed
		}
	}
	if txType := c.Query("type"); txType != "" {
		filter.Type = txType
	}
	if start := c.Query("start_date"); start != "" {
		if parsed, err := time.Parse(time.RFC3339, start); err == nil {
			filter.StartDate = &parsed
		}
	}
	if end := c.Query("end_date"); end != "" {
		if parsed, err := time.Parse(time.RFC3339, end); err == nil {
			filter.EndDate = &parsed
		}
	}

	if limitStr := c.Query("limit"); limitStr != "" {
		if val, err := strconv.Atoi(limitStr); err == nil {
			filter.Limit = val
		}
	}
	if offsetStr := c.Query("offset"); offsetStr != "" {
		if val, err := strconv.Atoi(offsetStr); err == nil {
			filter.Offset = val
		}
	}

	transactions, total, err := h.service.ListTransactions(c.Context(), filter)
	if err != nil {
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to list transactions")
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"data":   transactions,
		"total":  total,
		"limit":  filter.Limit,
		"offset": filter.Offset,
	})
}

func (h *TransactionHandler) UpdateTransaction(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid transaction ID format")
	}

	var req updateTransactionRequest
	if err := c.BodyParser(&req); err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_BODY", "Invalid JSON payload")
	}

	var walletUUID *uuid.UUID
	if req.WalletID != nil {
		parsed, err := uuid.Parse(*req.WalletID)
		if err != nil {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid wallet_id format")
		}
		walletUUID = &parsed
	}

	var serviceUUID *uuid.UUID
	if req.ServiceID != nil {
		parsed, err := uuid.Parse(*req.ServiceID)
		if err != nil {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid service_id format")
		}
		serviceUUID = &parsed
	}

	var categoryUUID *uuid.UUID
	if req.CategoryID != nil {
		if *req.CategoryID != "" {
			parsed, err := uuid.Parse(*req.CategoryID)
			if err != nil {
				return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid category_id format")
			}
			categoryUUID = &parsed
		} else {
			// Explicit empty string clears category
			categoryUUID = nil
		}
	}

	var txDate *time.Time
	if req.TransactionDate != nil && *req.TransactionDate != "" {
		parsed, err := time.Parse(time.RFC3339, *req.TransactionDate)
		if err != nil {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid transaction_date format (RFC3339 required)")
		}
		txDate = &parsed
	}

	tx, err := h.service.UpdateTransaction(c.Context(), id, services.UpdateTransactionInput{
		WalletID:        walletUUID,
		ServiceID:       serviceUUID,
		CategoryID:      categoryUUID,
		Type:            req.Type,
		Amount:          req.Amount,
		TransactionDate: txDate,
		Description:     req.Description,
	})
	if err != nil {
		if errors.Is(err, services.ErrTransactionNotFound) {
			return sendError(c, http.StatusNotFound, "NOT_FOUND", "Transaction not found")
		}
		if errors.Is(err, services.ErrInvalidInput) {
			return sendError(c, http.StatusBadRequest, "INVALID_INPUT", err.Error())
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to update transaction")
	}

	return c.Status(http.StatusOK).JSON(tx)
}

func (h *TransactionHandler) DeleteTransaction(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return sendError(c, http.StatusBadRequest, "INVALID_INPUT", "Invalid transaction ID format")
	}

	err = h.service.DeleteTransaction(c.Context(), id)
	if err != nil {
		if errors.Is(err, services.ErrTransactionNotFound) {
			return sendError(c, http.StatusNotFound, "NOT_FOUND", "Transaction not found")
		}
		return sendError(c, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to delete transaction")
	}

	return c.Status(http.StatusOK).JSON(fiber.Map{
		"message": "Transaction deleted successfully",
	})
}
