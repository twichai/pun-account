package services

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"github.com/google/uuid"

	"pun-account-backend/internal/wallets/models"
	"pun-account-backend/internal/wallets/repository"
)

var (
	ErrInvalidInput = errors.New("invalid input")
	ErrNotFound     = errors.New("wallet not found")
)

// CreateWalletInput holds parameters required to create a new wallet.
type CreateWalletInput struct {
	BusinessID     uuid.UUID       `json:"business_id"`
	Name           string          `json:"name"`
	Type           string          `json:"type"`
	Currency       string          `json:"currency"`
	InitialBalance float64         `json:"initial_balance"`
	UI             models.WalletUI `json:"ui"`
}

// UpdateWalletInput holds parameters that can be updated on an existing wallet.
type UpdateWalletInput struct {
	Name     *string          `json:"name"`
	Type     *string          `json:"type"`
	Currency *string          `json:"currency"`
	Balance  *float64         `json:"balance"`
	IsActive *bool            `json:"is_active"`
	UI       *models.WalletUI `json:"ui"`
}

// WalletService defines domain business logic for wallets.
type WalletService interface {
	CreateWallet(ctx context.Context, input CreateWalletInput) (*models.Wallet, error)
	GetWallet(ctx context.Context, id uuid.UUID) (*models.Wallet, error)
	ListWallets(ctx context.Context, businessID uuid.UUID) ([]models.Wallet, error)
	UpdateWallet(ctx context.Context, id uuid.UUID, input UpdateWalletInput) (*models.Wallet, error)
	DeleteWallet(ctx context.Context, id uuid.UUID) error
}

type walletService struct {
	repo repository.WalletRepository
}

// NewWalletService creates a new instance of WalletService.
func NewWalletService(repo repository.WalletRepository) WalletService {
	return &walletService{repo: repo}
}

func isValidWalletType(t string) bool {
	switch t {
	case models.WalletTypeCash,
		models.WalletTypeBank,
		models.WalletTypeEWallet,
		models.WalletTypeCreditCard,
		models.WalletTypeOther:
		return true
	default:
		return false
	}
}

func (s *walletService) CreateWallet(ctx context.Context, input CreateWalletInput) (*models.Wallet, error) {
	if input.BusinessID == uuid.Nil {
		return nil, fmt.Errorf("%w: business_id is required and cannot be empty", ErrInvalidInput)
	}
	name := strings.TrimSpace(input.Name)
	if name == "" {
		return nil, fmt.Errorf("%w: name cannot be empty", ErrInvalidInput)
	}
	if !isValidWalletType(input.Type) {
		return nil, fmt.Errorf("%w: invalid wallet type '%s'", ErrInvalidInput, input.Type)
	}

	currency := strings.ToUpper(strings.TrimSpace(input.Currency))
	if currency == "" {
		currency = "THB"
	}

	// Default aurora accent if not specified
	ui := input.UI
	if ui.AuroraAccent == "" {
		ui.AuroraAccent = "emerald"
	}

	// UUIDv7 primary key generation (monotonic timestamp ordered)
	id, err := uuid.NewV7()
	if err != nil {
		return nil, fmt.Errorf("failed to generate uuidv7: %w", err)
	}

	wallet := &models.Wallet{
		ID:         id,
		BusinessID: input.BusinessID,
		Name:       name,
		Type:       input.Type,
		Currency:   currency,
		Balance:    input.InitialBalance,
		UI:         ui,
		IsActive:   true,
	}

	if err := s.repo.Create(ctx, wallet); err != nil {
		return nil, err
	}

	return wallet, nil
}

func (s *walletService) GetWallet(ctx context.Context, id uuid.UUID) (*models.Wallet, error) {
	if id == uuid.Nil {
		return nil, fmt.Errorf("%w: invalid wallet id", ErrInvalidInput)
	}
	wallet, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrWalletNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return wallet, nil
}

func (s *walletService) ListWallets(ctx context.Context, businessID uuid.UUID) ([]models.Wallet, error) {
	if businessID == uuid.Nil {
		return nil, fmt.Errorf("%w: business_id is required", ErrInvalidInput)
	}
	return s.repo.ListByBusinessID(ctx, businessID)
}

func (s *walletService) UpdateWallet(ctx context.Context, id uuid.UUID, input UpdateWalletInput) (*models.Wallet, error) {
	wallet, err := s.GetWallet(ctx, id)
	if err != nil {
		return nil, err
	}

	if input.Name != nil {
		trimmed := strings.TrimSpace(*input.Name)
		if trimmed == "" {
			return nil, fmt.Errorf("%w: name cannot be empty", ErrInvalidInput)
		}
		wallet.Name = trimmed
	}

	if input.Type != nil {
		if !isValidWalletType(*input.Type) {
			return nil, fmt.Errorf("%w: invalid wallet type '%s'", ErrInvalidInput, *input.Type)
		}
		wallet.Type = *input.Type
	}

	if input.Currency != nil {
		trimmed := strings.ToUpper(strings.TrimSpace(*input.Currency))
		if trimmed != "" {
			wallet.Currency = trimmed
		}
	}

	if input.Balance != nil {
		wallet.Balance = *input.Balance
	}

	if input.IsActive != nil {
		wallet.IsActive = *input.IsActive
	}

	if input.UI != nil {
		wallet.UI = *input.UI
	}

	if err := s.repo.Update(ctx, wallet); err != nil {
		return nil, err
	}

	return wallet, nil
}

func (s *walletService) DeleteWallet(ctx context.Context, id uuid.UUID) error {
	if id == uuid.Nil {
		return fmt.Errorf("%w: invalid wallet id", ErrInvalidInput)
	}
	err := s.repo.Delete(ctx, id)
	if err != nil {
		if errors.Is(err, repository.ErrWalletNotFound) {
			return ErrNotFound
		}
		return err
	}
	return nil
}
