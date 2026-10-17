package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"pun-account-backend/internal/transactions/handlers"
	"pun-account-backend/internal/transactions/repository"
	"pun-account-backend/internal/transactions/services"
	"pun-account-backend/internal/wallets/models"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type stubTransactionService struct {
	transactions map[uuid.UUID]*models.Transaction
}

func newStubTransactionService() *stubTransactionService {
	return &stubTransactionService{
		transactions: make(map[uuid.UUID]*models.Transaction),
	}
}

func (s *stubTransactionService) CreateTransaction(ctx context.Context, input services.CreateTransactionInput) (*models.Transaction, error) {
	if input.Amount <= 0 {
		return nil, services.ErrInvalidInput
	}
	id, _ := uuid.NewV7()
	tx := &models.Transaction{
		ID:              id,
		BusinessID:      input.BusinessID,
		WalletID:        input.WalletID,
		ServiceID:       input.ServiceID,
		CategoryID:      input.CategoryID,
		Type:            input.Type,
		Amount:          input.Amount,
		TransactionDate: time.Now(),
		Description:     input.Description,
	}
	s.transactions[id] = tx
	return tx, nil
}

func (s *stubTransactionService) GetTransaction(ctx context.Context, id uuid.UUID) (*models.Transaction, error) {
	tx, ok := s.transactions[id]
	if !ok {
		return nil, services.ErrTransactionNotFound
	}
	return tx, nil
}

func (s *stubTransactionService) ListTransactions(ctx context.Context, filter repository.ListFilter) ([]models.Transaction, int64, error) {
	var list []models.Transaction
	for _, tx := range s.transactions {
		list = append(list, *tx)
	}
	return list, int64(len(list)), nil
}

func (s *stubTransactionService) UpdateTransaction(ctx context.Context, id uuid.UUID, input services.UpdateTransactionInput) (*models.Transaction, error) {
	tx, ok := s.transactions[id]
	if !ok {
		return nil, services.ErrTransactionNotFound
	}
	if input.Amount != nil {
		tx.Amount = *input.Amount
	}
	return tx, nil
}

func (s *stubTransactionService) DeleteTransaction(ctx context.Context, id uuid.UUID) error {
	if _, ok := s.transactions[id]; !ok {
		return services.ErrTransactionNotFound
	}
	delete(s.transactions, id)
	return nil
}

func setupTestApp(svc services.TransactionService) *fiber.App {
	app := fiber.New()
	handler := handlers.NewTransactionHandler(svc)
	api := app.Group("/api/v1")
	handler.RegisterRoutes(api)
	return app
}

func TestTransactionHandler_Endpoints(t *testing.T) {
	svc := newStubTransactionService()
	app := setupTestApp(svc)

	busID := uuid.New()
	walletID := uuid.New()
	serviceID := uuid.New()

	var createdID string

	t.Run("POST /api/v1/transactions - success", func(t *testing.T) {
		payload := map[string]any{
			"business_id": busID.String(),
			"wallet_id":   walletID.String(),
			"service_id":  serviceID.String(),
			"type":        "expense",
			"amount":      450.50,
			"description": "Figma Subscription",
		}
		body, _ := json.Marshal(payload)
		req := httptest.NewRequest(http.MethodPost, "/api/v1/transactions", bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, err := app.Test(req)
		if err != nil {
			t.Fatalf("request failed: %v", err)
		}
		if resp.StatusCode != http.StatusCreated {
			respBody, _ := io.ReadAll(resp.Body)
			t.Fatalf("expected 201 Created, got %d: %s", resp.StatusCode, string(respBody))
		}

		var res models.Transaction
		_ = json.NewDecoder(resp.Body).Decode(&res)
		if res.Amount != 450.50 {
			t.Errorf("expected amount 450.50, got %f", res.Amount)
		}
		createdID = res.ID.String()
	})

	t.Run("GET /api/v1/transactions/:id - success", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/transactions/"+createdID, nil)
		resp, err := app.Test(req)
		if err != nil {
			t.Fatalf("request failed: %v", err)
		}
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
		}
	})

	t.Run("GET /api/v1/transactions - list", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/transactions?business_id="+busID.String(), nil)
		resp, err := app.Test(req)
		if err != nil {
			t.Fatalf("request failed: %v", err)
		}
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
		}
	})

	t.Run("PUT /api/v1/transactions/:id - update", func(t *testing.T) {
		payload := map[string]any{
			"amount": 500.00,
		}
		body, _ := json.Marshal(payload)
		req := httptest.NewRequest(http.MethodPut, "/api/v1/transactions/"+createdID, bytes.NewReader(body))
		req.Header.Set("Content-Type", "application/json")

		resp, err := app.Test(req)
		if err != nil {
			t.Fatalf("request failed: %v", err)
		}
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
		}

		var updated models.Transaction
		_ = json.NewDecoder(resp.Body).Decode(&updated)
		if updated.Amount != 500.00 {
			t.Errorf("expected updated amount 500.00, got %f", updated.Amount)
		}
	})

	t.Run("DELETE /api/v1/transactions/:id - delete", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodDelete, "/api/v1/transactions/"+createdID, nil)
		resp, err := app.Test(req)
		if err != nil {
			t.Fatalf("request failed: %v", err)
		}
		if resp.StatusCode != http.StatusOK {
			t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
		}

		// Re-fetch should be 404
		reqGet := httptest.NewRequest(http.MethodGet, "/api/v1/transactions/"+createdID, nil)
		respGet, _ := app.Test(reqGet)
		if respGet.StatusCode != http.StatusNotFound {
			t.Errorf("expected 404 Not Found after delete, got %d", respGet.StatusCode)
		}
	})
}
