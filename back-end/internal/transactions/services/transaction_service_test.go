package services_test

import (
	"context"
	"testing"

	"pun-account-backend/internal/transactions/repository"
	"pun-account-backend/internal/transactions/services"
	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
)

type mockTransactionRepo struct {
	transactions map[uuid.UUID]*models.Transaction
}

func newMockTransactionRepo() *mockTransactionRepo {
	return &mockTransactionRepo{
		transactions: make(map[uuid.UUID]*models.Transaction),
	}
}

func (m *mockTransactionRepo) Create(ctx context.Context, tx *models.Transaction) error {
	m.transactions[tx.ID] = tx
	return nil
}

func (m *mockTransactionRepo) GetByID(ctx context.Context, id uuid.UUID) (*models.Transaction, error) {
	tx, exists := m.transactions[id]
	if !exists {
		return nil, repository.ErrTransactionNotFound
	}
	return tx, nil
}

func (m *mockTransactionRepo) List(ctx context.Context, filter repository.ListFilter) ([]models.Transaction, int64, error) {
	var list []models.Transaction
	for _, tx := range m.transactions {
		if filter.BusinessID != nil && tx.BusinessID != *filter.BusinessID {
			continue
		}
		if filter.WalletID != nil && tx.WalletID != *filter.WalletID {
			continue
		}
		if filter.ServiceID != nil && tx.ServiceID != *filter.ServiceID {
			continue
		}
		if filter.Type != "" && tx.Type != filter.Type {
			continue
		}
		list = append(list, *tx)
	}
	return list, int64(len(list)), nil
}

func (m *mockTransactionRepo) Update(ctx context.Context, tx *models.Transaction, oldWalletID uuid.UUID, oldType string, oldAmount float64) error {
	if _, exists := m.transactions[tx.ID]; !exists {
		return repository.ErrTransactionNotFound
	}
	m.transactions[tx.ID] = tx
	return nil
}

func (m *mockTransactionRepo) Delete(ctx context.Context, id uuid.UUID) error {
	if _, exists := m.transactions[id]; !exists {
		return repository.ErrTransactionNotFound
	}
	delete(m.transactions, id)
	return nil
}

func TestTransactionService_CreateTransaction(t *testing.T) {
	repo := newMockTransactionRepo()
	svc := services.NewTransactionService(repo)
	ctx := context.Background()

	busID := uuid.New()
	walletID := uuid.New()
	serviceID := uuid.New()

	t.Run("success create expense", func(t *testing.T) {
		desc := "Subscription payment"
		tx, err := svc.CreateTransaction(ctx, services.CreateTransactionInput{
			BusinessID:  busID,
			WalletID:    walletID,
			ServiceID:   serviceID,
			Type:        models.TransactionTypeExpense,
			Amount:      299.00,
			Description: &desc,
		})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if tx.ID == uuid.Nil {
			t.Errorf("expected non-nil ID")
		}
		if tx.Amount != 299.00 {
			t.Errorf("expected amount 299.00, got %f", tx.Amount)
		}
		if tx.ServiceID != serviceID {
			t.Errorf("expected serviceID %s, got %s", serviceID, tx.ServiceID)
		}
	})

	t.Run("missing service_id", func(t *testing.T) {
		_, err := svc.CreateTransaction(ctx, services.CreateTransactionInput{
			BusinessID: busID,
			WalletID:   walletID,
			ServiceID:  uuid.Nil,
			Type:       models.TransactionTypeExpense,
			Amount:     100.00,
		})
		if err == nil {
			t.Errorf("expected error for nil service_id, got nil")
		}
	})

	t.Run("invalid amount <= 0", func(t *testing.T) {
		_, err := svc.CreateTransaction(ctx, services.CreateTransactionInput{
			BusinessID: busID,
			WalletID:   walletID,
			ServiceID:  serviceID,
			Type:       models.TransactionTypeExpense,
			Amount:     0,
		})
		if err == nil {
			t.Errorf("expected error for amount <= 0, got nil")
		}
	})

	t.Run("invalid transaction type", func(t *testing.T) {
		_, err := svc.CreateTransaction(ctx, services.CreateTransactionInput{
			BusinessID: busID,
			WalletID:   walletID,
			ServiceID:  serviceID,
			Type:       "invalid_type",
			Amount:     50,
		})
		if err == nil {
			t.Errorf("expected error for invalid type, got nil")
		}
	})
}

func TestTransactionService_GetUpdateDelete(t *testing.T) {
	repo := newMockTransactionRepo()
	svc := services.NewTransactionService(repo)
	ctx := context.Background()

	busID := uuid.New()
	walletID := uuid.New()
	serviceID := uuid.New()

	created, err := svc.CreateTransaction(ctx, services.CreateTransactionInput{
		BusinessID: busID,
		WalletID:   walletID,
		ServiceID:  serviceID,
		Type:       models.TransactionTypeIncome,
		Amount:     1500.00,
	})
	if err != nil {
		t.Fatalf("failed to create: %v", err)
	}

	t.Run("get existing transaction", func(t *testing.T) {
		found, err := svc.GetTransaction(ctx, created.ID)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if found.ID != created.ID {
			t.Errorf("expected %s, got %s", created.ID, found.ID)
		}
	})

	t.Run("update transaction amount", func(t *testing.T) {
		newAmount := 2000.00
		updated, err := svc.UpdateTransaction(ctx, created.ID, services.UpdateTransactionInput{
			Amount: &newAmount,
		})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if updated.Amount != 2000.00 {
			t.Errorf("expected 2000.00, got %f", updated.Amount)
		}
	})

	t.Run("list transactions", func(t *testing.T) {
		list, total, err := svc.ListTransactions(ctx, repository.ListFilter{
			BusinessID: &busID,
		})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if total != 1 || len(list) != 1 {
			t.Errorf("expected 1 item, got %d", total)
		}
	})

	t.Run("delete transaction", func(t *testing.T) {
		err := svc.DeleteTransaction(ctx, created.ID)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		_, err = svc.GetTransaction(ctx, created.ID)
		if err == nil {
			t.Errorf("expected not found error after delete, got nil")
		}
	})
}
