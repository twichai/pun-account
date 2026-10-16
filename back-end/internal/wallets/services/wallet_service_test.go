package services_test

import (
	"context"
	"testing"

	"pun-account-backend/internal/wallets/models"
	"pun-account-backend/internal/wallets/repository"
	"pun-account-backend/internal/wallets/services"

	"github.com/google/uuid"
)

type mockWalletRepo struct {
	wallets map[uuid.UUID]*models.Wallet
}

func newMockWalletRepo() *mockWalletRepo {
	return &mockWalletRepo{
		wallets: make(map[uuid.UUID]*models.Wallet),
	}
}

func (m *mockWalletRepo) Create(ctx context.Context, wallet *models.Wallet) error {
	m.wallets[wallet.ID] = wallet
	return nil
}

func (m *mockWalletRepo) GetByID(ctx context.Context, id uuid.UUID) (*models.Wallet, error) {
	w, exists := m.wallets[id]
	if !exists {
		return nil, repository.ErrWalletNotFound
	}
	return w, nil
}

func (m *mockWalletRepo) ListByBusinessID(ctx context.Context, businessID uuid.UUID) ([]models.Wallet, error) {
	var list []models.Wallet
	for _, w := range m.wallets {
		if w.BusinessID == businessID {
			list = append(list, *w)
		}
	}
	return list, nil
}

func (m *mockWalletRepo) Update(ctx context.Context, wallet *models.Wallet) error {
	if _, exists := m.wallets[wallet.ID]; !exists {
		return repository.ErrWalletNotFound
	}
	m.wallets[wallet.ID] = wallet
	return nil
}

func (m *mockWalletRepo) Delete(ctx context.Context, id uuid.UUID) error {
	if _, exists := m.wallets[id]; !exists {
		return repository.ErrWalletNotFound
	}
	delete(m.wallets, id)
	return nil
}

func TestWalletService_CRUDLifecycle(t *testing.T) {
	ctx := context.Background()
	repo := newMockWalletRepo()
	svc := services.NewWalletService(repo)

	businessID := uuid.MustParse("01927500-0000-7000-8000-000000000001")
	cardHolder := "PAVLO D."
	last4 := "7642"
	cardBrand := "visa"

	// 1. Create Wallet
	created, err := svc.CreateWallet(ctx, services.CreateWalletInput{
		BusinessID:     businessID,
		Name:           "Visa Card",
		Type:           models.WalletTypeCreditCard,
		Currency:       "THB",
		InitialBalance: 50000.0,
		UI: models.WalletUI{
			AuroraAccent: "cyan",
			CardHolder:   &cardHolder,
			Last4:        &last4,
			CardBrand:    &cardBrand,
		},
	})
	if err != nil {
		t.Fatalf("CreateWallet failed: %v", err)
	}

	if created.ID == uuid.Nil {
		t.Errorf("expected non-nil UUIDv7 ID")
	}
	if created.UI.AuroraAccent != "cyan" {
		t.Errorf("expected aurora accent 'cyan', got %s", created.UI.AuroraAccent)
	}

	// 2. Get Wallet
	fetched, err := svc.GetWallet(ctx, created.ID)
	if err != nil {
		t.Fatalf("GetWallet failed: %v", err)
	}
	if fetched.Name != "Visa Card" {
		t.Errorf("expected name 'Visa Card', got %s", fetched.Name)
	}

	// 3. List Wallets
	list, err := svc.ListWallets(ctx, businessID)
	if err != nil {
		t.Fatalf("ListWallets failed: %v", err)
	}
	if len(list) != 1 {
		t.Fatalf("expected 1 wallet, got %d", len(list))
	}

	// 4. Update Wallet UI & Name
	newName := "Visa Corporate Gold"
	newAccent := "violet"
	updated, err := svc.UpdateWallet(ctx, created.ID, services.UpdateWalletInput{
		Name: &newName,
		UI: &models.WalletUI{
			AuroraAccent: newAccent,
			CardHolder:   &cardHolder,
			Last4:        &last4,
			CardBrand:    &cardBrand,
		},
	})
	if err != nil {
		t.Fatalf("UpdateWallet failed: %v", err)
	}
	if updated.Name != "Visa Corporate Gold" {
		t.Errorf("expected updated name 'Visa Corporate Gold', got %s", updated.Name)
	}
	if updated.UI.AuroraAccent != "violet" {
		t.Errorf("expected updated accent 'violet', got %s", updated.UI.AuroraAccent)
	}

	// 5. Delete Wallet
	err = svc.DeleteWallet(ctx, created.ID)
	if err != nil {
		t.Fatalf("DeleteWallet failed: %v", err)
	}

	// 6. Get after Delete should return ErrNotFound
	_, err = svc.GetWallet(ctx, created.ID)
	if err != services.ErrNotFound {
		t.Errorf("expected ErrNotFound after deletion, got %v", err)
	}
}

func TestWalletService_ValidationErrors(t *testing.T) {
	ctx := context.Background()
	repo := newMockWalletRepo()
	svc := services.NewWalletService(repo)

	// Missing business ID
	_, err := svc.CreateWallet(ctx, services.CreateWalletInput{
		Name: "Test Wallet",
		Type: models.WalletTypeCash,
	})
	if err == nil {
		t.Error("expected error for missing business_id, got nil")
	}

	// Invalid Wallet Type
	_, err = svc.CreateWallet(ctx, services.CreateWalletInput{
		BusinessID: uuid.New(),
		Name:       "Test Wallet",
		Type:       "invalid_type",
	})
	if err == nil {
		t.Error("expected error for invalid type, got nil")
	}
}
