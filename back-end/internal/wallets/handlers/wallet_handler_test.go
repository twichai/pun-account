package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"pun-account-backend/internal/wallets/handlers"
	"pun-account-backend/internal/wallets/models"
	"pun-account-backend/internal/wallets/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type stubWalletService struct {
	wallets map[uuid.UUID]*models.Wallet
}

func newStubWalletService() *stubWalletService {
	return &stubWalletService{
		wallets: make(map[uuid.UUID]*models.Wallet),
	}
}

func (s *stubWalletService) CreateWallet(ctx context.Context, input services.CreateWalletInput) (*models.Wallet, error) {
	id, _ := uuid.NewV7()
	w := &models.Wallet{
		ID:         id,
		BusinessID: input.BusinessID,
		Name:       input.Name,
		Type:       input.Type,
		Currency:   input.Currency,
		Balance:    input.InitialBalance,
		UI:         input.UI,
		IsActive:   true,
	}
	s.wallets[id] = w
	return w, nil
}

func (s *stubWalletService) GetWallet(ctx context.Context, id uuid.UUID) (*models.Wallet, error) {
	w, ok := s.wallets[id]
	if !ok {
		return nil, services.ErrNotFound
	}
	return w, nil
}

func (s *stubWalletService) ListWallets(ctx context.Context, businessID uuid.UUID) ([]models.Wallet, error) {
	var list []models.Wallet
	for _, w := range s.wallets {
		if w.BusinessID == businessID {
			list = append(list, *w)
		}
	}
	return list, nil
}

func (s *stubWalletService) UpdateWallet(ctx context.Context, id uuid.UUID, input services.UpdateWalletInput) (*models.Wallet, error) {
	w, ok := s.wallets[id]
	if !ok {
		return nil, services.ErrNotFound
	}
	if input.Name != nil {
		w.Name = *input.Name
	}
	if input.Balance != nil {
		w.Balance = *input.Balance
	}
	if input.UI != nil {
		w.UI = *input.UI
	}
	return w, nil
}

func (s *stubWalletService) DeleteWallet(ctx context.Context, id uuid.UUID) error {
	if _, ok := s.wallets[id]; !ok {
		return services.ErrNotFound
	}
	delete(s.wallets, id)
	return nil
}

func setupTestApp() (*fiber.App, *stubWalletService) {
	app := fiber.New()
	svc := newStubWalletService()
	h := handlers.NewWalletHandler(svc)
	h.RegisterRoutes(app.Group("/api/v1"))
	return app, svc
}

func TestWalletHandler_EndToEndEndpoints(t *testing.T) {
	app, _ := setupTestApp()
	businessID := "01927500-0000-7000-8000-000000000001"

	// 1. POST /api/v1/wallets (Create)
	payload := map[string]interface{}{
		"business_id": businessID,
		"name":        "Test Cash Wallet",
		"type":        "cash",
		"currency":    "THB",
		"ui": map[string]interface{}{
			"aurora_accent": "emerald",
		},
	}
	jsonBody, _ := json.Marshal(payload)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/wallets", bytes.NewReader(jsonBody))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("app.Test error: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("expected status 201 Created, got %d", resp.StatusCode)
	}

	body, _ := io.ReadAll(resp.Body)
	var created models.Wallet
	if err := json.Unmarshal(body, &created); err != nil {
		t.Fatalf("failed to parse response body: %v", err)
	}
	if created.UI.AuroraAccent != "emerald" {
		t.Errorf("expected aurora_accent 'emerald', got '%s'", created.UI.AuroraAccent)
	}

	// 2. GET /api/v1/wallets/:id
	reqGet := httptest.NewRequest(http.MethodGet, "/api/v1/wallets/"+created.ID.String(), nil)
	respGet, err := app.Test(reqGet)
	if err != nil || respGet.StatusCode != http.StatusOK {
		t.Fatalf("failed GET /wallets/:id, status: %d", respGet.StatusCode)
	}

	// 3. GET /api/v1/wallets?business_id=...
	reqList := httptest.NewRequest(http.MethodGet, "/api/v1/wallets?business_id="+businessID, nil)
	respList, err := app.Test(reqList)
	if err != nil || respList.StatusCode != http.StatusOK {
		t.Fatalf("failed GET /wallets?business_id=..., status: %d", respList.StatusCode)
	}

	// 4. PUT /api/v1/wallets/:id
	updatePayload := map[string]interface{}{
		"name":    "Updated Cash Wallet",
		"balance": 18500.25,
		"ui": map[string]interface{}{
			"aurora_accent": "amber",
		},
	}
	updateBody, _ := json.Marshal(updatePayload)
	reqPut := httptest.NewRequest(http.MethodPut, "/api/v1/wallets/"+created.ID.String(), bytes.NewReader(updateBody))
	reqPut.Header.Set("Content-Type", "application/json")
	respPut, err := app.Test(reqPut)
	if err != nil || respPut.StatusCode != http.StatusOK {
		t.Fatalf("failed PUT /wallets/:id, status: %d", respPut.StatusCode)
	}

	putBody, _ := io.ReadAll(respPut.Body)
	var updated models.Wallet
	if err := json.Unmarshal(putBody, &updated); err != nil {
		t.Fatalf("failed to parse updated response: %v", err)
	}
	if updated.Balance != 18500.25 {
		t.Errorf("expected updated balance 18500.25, got %f", updated.Balance)
	}

	// 5. DELETE /api/v1/wallets/:id
	reqDel := httptest.NewRequest(http.MethodDelete, "/api/v1/wallets/"+created.ID.String(), nil)
	respDel, err := app.Test(reqDel)
	if err != nil || respDel.StatusCode != http.StatusOK {
		t.Fatalf("failed DELETE /wallets/:id, status: %d", respDel.StatusCode)
	}
}
