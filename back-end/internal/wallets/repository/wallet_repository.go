package repository

import (
	"context"
	"errors"
	"fmt"

	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ErrWalletNotFound is returned when the specified wallet doesn't exist.
var ErrWalletNotFound = errors.New("wallet not found")

// WalletRepository defines persistence operations for wallets.
type WalletRepository interface {
	Create(ctx context.Context, wallet *models.Wallet) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Wallet, error)
	ListByBusinessID(ctx context.Context, businessID uuid.UUID) ([]models.Wallet, error)
	Update(ctx context.Context, wallet *models.Wallet) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type walletRepository struct {
	db *gorm.DB
}

// NewWalletRepository creates a new GORM-backed WalletRepository.
func NewWalletRepository(db *gorm.DB) WalletRepository {
	return &walletRepository{db: db}
}

func (r *walletRepository) Create(ctx context.Context, wallet *models.Wallet) error {
	if err := r.db.WithContext(ctx).Create(wallet).Error; err != nil {
		return fmt.Errorf("failed to create wallet: %w", err)
	}
	return nil
}

func (r *walletRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.Wallet, error) {
	var wallet models.Wallet
	err := r.db.WithContext(ctx).First(&wallet, "id = ?", id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrWalletNotFound
		}
		return nil, fmt.Errorf("failed to get wallet %s: %w", id, err)
	}
	return &wallet, nil
}

func (r *walletRepository) ListByBusinessID(ctx context.Context, businessID uuid.UUID) ([]models.Wallet, error) {
	var wallets []models.Wallet
	err := r.db.WithContext(ctx).
		Where("business_id = ?", businessID).
		Order("created_at ASC").
		Find(&wallets).Error
	if err != nil {
		return nil, fmt.Errorf("failed to list wallets for business %s: %w", businessID, err)
	}
	return wallets, nil
}

func (r *walletRepository) Update(ctx context.Context, wallet *models.Wallet) error {
	result := r.db.WithContext(ctx).Save(wallet)
	if result.Error != nil {
		return fmt.Errorf("failed to update wallet %s: %w", wallet.ID, result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrWalletNotFound
	}
	return nil
}

func (r *walletRepository) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Delete(&models.Wallet{}, "id = ?", id)
	if result.Error != nil {
		return fmt.Errorf("failed to delete wallet %s: %w", id, result.Error)
	}
	if result.RowsAffected == 0 {
		return ErrWalletNotFound
	}
	return nil
}
