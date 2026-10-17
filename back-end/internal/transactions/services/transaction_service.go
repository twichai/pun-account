package services

import (
	"context"
	"errors"
	"fmt"
	"time"

	"pun-account-backend/internal/transactions/repository"
	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
)

var (
	ErrInvalidInput       = errors.New("invalid input")
	ErrTransactionNotFound = errors.New("transaction not found")
)

// CreateTransactionInput holds fields required to create a transaction.
type CreateTransactionInput struct {
	BusinessID      uuid.UUID  `json:"business_id"`
	WalletID        uuid.UUID  `json:"wallet_id"`
	ServiceID       uuid.UUID  `json:"service_id"`
	CategoryID      *uuid.UUID `json:"category_id"`
	Type            string     `json:"type"`
	Amount          float64    `json:"amount"`
	TransactionDate *time.Time `json:"transaction_date"`
	Description     *string    `json:"description"`
}

// UpdateTransactionInput holds fields that can be updated on an existing transaction.
type UpdateTransactionInput struct {
	WalletID        *uuid.UUID `json:"wallet_id"`
	ServiceID       *uuid.UUID `json:"service_id"`
	CategoryID      *uuid.UUID `json:"category_id"`
	Type            *string    `json:"type"`
	Amount          *float64   `json:"amount"`
	TransactionDate *time.Time `json:"transaction_date"`
	Description     *string    `json:"description"`
}

// TransactionService defines business logic for transaction resources.
type TransactionService interface {
	CreateTransaction(ctx context.Context, input CreateTransactionInput) (*models.Transaction, error)
	GetTransaction(ctx context.Context, id uuid.UUID) (*models.Transaction, error)
	ListTransactions(ctx context.Context, filter repository.ListFilter) ([]models.Transaction, int64, error)
	UpdateTransaction(ctx context.Context, id uuid.UUID, input UpdateTransactionInput) (*models.Transaction, error)
	DeleteTransaction(ctx context.Context, id uuid.UUID) error
}

type transactionService struct {
	repo repository.TransactionRepository
}

// NewTransactionService constructs a new TransactionService.
func NewTransactionService(repo repository.TransactionRepository) TransactionService {
	return &transactionService{repo: repo}
}

func isValidTransactionType(t string) bool {
	switch t {
	case models.TransactionTypeIncome,
		models.TransactionTypeExpense,
		models.TransactionTypeOwnerWithdrawal,
		models.TransactionTypeOwnerContribution:
		return true
	default:
		return false
	}
}

func (s *transactionService) CreateTransaction(ctx context.Context, input CreateTransactionInput) (*models.Transaction, error) {
	if input.BusinessID == uuid.Nil {
		return nil, fmt.Errorf("%w: business_id is required", ErrInvalidInput)
	}
	if input.WalletID == uuid.Nil {
		return nil, fmt.Errorf("%w: wallet_id is required", ErrInvalidInput)
	}
	if input.ServiceID == uuid.Nil {
		return nil, fmt.Errorf("%w: service_id is required and cannot be empty", ErrInvalidInput)
	}
	if !isValidTransactionType(input.Type) {
		return nil, fmt.Errorf("%w: invalid transaction type %q", ErrInvalidInput, input.Type)
	}
	if input.Amount <= 0 {
		return nil, fmt.Errorf("%w: amount must be greater than zero", ErrInvalidInput)
	}

	txDate := time.Now()
	if input.TransactionDate != nil && !input.TransactionDate.IsZero() {
		txDate = *input.TransactionDate
	}

	id, err := uuid.NewV7()
	if err != nil {
		id = uuid.New()
	}

	tx := &models.Transaction{
		ID:              id,
		BusinessID:      input.BusinessID,
		WalletID:        input.WalletID,
		ServiceID:       input.ServiceID,
		CategoryID:      input.CategoryID,
		Type:            input.Type,
		Amount:          input.Amount,
		TransactionDate: txDate,
		Description:     input.Description,
	}

	if err := s.repo.Create(ctx, tx); err != nil {
		if errors.Is(err, repository.ErrWalletNotFound) ||
			errors.Is(err, repository.ErrServiceNotFound) ||
			errors.Is(err, repository.ErrCategoryNotFound) {
			return nil, fmt.Errorf("%w: %s", ErrInvalidInput, err.Error())
		}
		return nil, fmt.Errorf("failed to create transaction: %w", err)
	}

	return tx, nil
}

func (s *transactionService) GetTransaction(ctx context.Context, id uuid.UUID) (*models.Transaction, error) {
	if id == uuid.Nil {
		return nil, fmt.Errorf("%w: transaction id is required", ErrInvalidInput)
	}

	tx, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrTransactionNotFound) {
			return nil, ErrTransactionNotFound
		}
		return nil, fmt.Errorf("failed to get transaction: %w", err)
	}
	return tx, nil
}

func (s *transactionService) ListTransactions(ctx context.Context, filter repository.ListFilter) ([]models.Transaction, int64, error) {
	return s.repo.List(ctx, filter)
}

func (s *transactionService) UpdateTransaction(ctx context.Context, id uuid.UUID, input UpdateTransactionInput) (*models.Transaction, error) {
	if id == uuid.Nil {
		return nil, fmt.Errorf("%w: transaction id is required", ErrInvalidInput)
	}

	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrTransactionNotFound) {
			return nil, ErrTransactionNotFound
		}
		return nil, fmt.Errorf("failed to find existing transaction: %w", err)
	}

	oldWalletID := existing.WalletID
	oldType := existing.Type
	oldAmount := existing.Amount

	if input.WalletID != nil {
		if *input.WalletID == uuid.Nil {
			return nil, fmt.Errorf("%w: wallet_id cannot be nil", ErrInvalidInput)
		}
		existing.WalletID = *input.WalletID
	}
	if input.ServiceID != nil {
		if *input.ServiceID == uuid.Nil {
			return nil, fmt.Errorf("%w: service_id cannot be nil", ErrInvalidInput)
		}
		existing.ServiceID = *input.ServiceID
	}
	if input.CategoryID != nil {
		existing.CategoryID = input.CategoryID
	}
	if input.Type != nil {
		if !isValidTransactionType(*input.Type) {
			return nil, fmt.Errorf("%w: invalid transaction type %q", ErrInvalidInput, *input.Type)
		}
		existing.Type = *input.Type
	}
	if input.Amount != nil {
		if *input.Amount <= 0 {
			return nil, fmt.Errorf("%w: amount must be greater than zero", ErrInvalidInput)
		}
		existing.Amount = *input.Amount
	}
	if input.TransactionDate != nil && !input.TransactionDate.IsZero() {
		existing.TransactionDate = *input.TransactionDate
	}
	if input.Description != nil {
		existing.Description = input.Description
	}

	if err := s.repo.Update(ctx, existing, oldWalletID, oldType, oldAmount); err != nil {
		if errors.Is(err, repository.ErrWalletNotFound) ||
			errors.Is(err, repository.ErrServiceNotFound) ||
			errors.Is(err, repository.ErrCategoryNotFound) {
			return nil, fmt.Errorf("%w: %s", ErrInvalidInput, err.Error())
		}
		return nil, fmt.Errorf("failed to update transaction: %w", err)
	}

	return existing, nil
}

func (s *transactionService) DeleteTransaction(ctx context.Context, id uuid.UUID) error {
	if id == uuid.Nil {
		return fmt.Errorf("%w: transaction id is required", ErrInvalidInput)
	}

	err := s.repo.Delete(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrTransactionNotFound) {
			return ErrTransactionNotFound
		}
		return fmt.Errorf("failed to delete transaction: %w", err)
	}
	return nil
}
