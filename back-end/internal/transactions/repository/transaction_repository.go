package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

var (
	ErrTransactionNotFound = errors.New("transaction not found")
	ErrWalletNotFound      = errors.New("wallet not found")
	ErrServiceNotFound     = errors.New("service not found")
	ErrCategoryNotFound    = errors.New("category not found")
)

// ListFilter represents query filters for listing transactions.
type ListFilter struct {
	BusinessID *uuid.UUID
	WalletID   *uuid.UUID
	ServiceID  *uuid.UUID
	CategoryID *uuid.UUID
	Type       string
	StartDate  *time.Time
	EndDate    *time.Time
	Limit      int
	Offset     int
}

// TransactionRepository defines persistence operations for transactions.
type TransactionRepository interface {
	Create(ctx context.Context, tx *models.Transaction) error
	GetByID(ctx context.Context, id uuid.UUID) (*models.Transaction, error)
	List(ctx context.Context, filter ListFilter) ([]models.Transaction, int64, error)
	Update(ctx context.Context, tx *models.Transaction, oldWalletID uuid.UUID, oldType string, oldAmount float64) error
	Delete(ctx context.Context, id uuid.UUID) error
}

type transactionRepository struct {
	db *gorm.DB
}

// NewTransactionRepository creates a new instance of TransactionRepository.
func NewTransactionRepository(db *gorm.DB) TransactionRepository {
	return &transactionRepository{db: db}
}

// applyBalanceDelta computes how a transaction type and amount affect a wallet balance.
func applyBalanceDelta(txType string, amount float64) float64 {
	switch txType {
	case models.TransactionTypeIncome, models.TransactionTypeOwnerContribution:
		return amount
	case models.TransactionTypeExpense, models.TransactionTypeOwnerWithdrawal:
		return -amount
	default:
		return 0
	}
}

func (r *transactionRepository) Create(ctx context.Context, tx *models.Transaction) error {
	return r.db.WithContext(ctx).Transaction(func(dbTx *gorm.DB) error {
		// 1. Verify and lock the wallet row
		var wallet models.Wallet
		if err := dbTx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&wallet, "id = ?", tx.WalletID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return ErrWalletNotFound
			}
			return fmt.Errorf("failed to query wallet: %w", err)
		}

		// 2. Verify service exists
		var service models.Service
		if err := dbTx.First(&service, "id = ?", tx.ServiceID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return ErrServiceNotFound
			}
			return fmt.Errorf("failed to query service: %w", err)
		}

		// 3. Verify category if provided
		if tx.CategoryID != nil && *tx.CategoryID != uuid.Nil {
			var category models.Category
			if err := dbTx.First(&category, "id = ?", *tx.CategoryID).Error; err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					return ErrCategoryNotFound
				}
				return fmt.Errorf("failed to query category: %w", err)
			}
		}

		// 4. Update wallet balance
		delta := applyBalanceDelta(tx.Type, tx.Amount)
		newBalance := wallet.Balance + delta
		if err := dbTx.Model(&wallet).Update("balance", newBalance).Error; err != nil {
			return fmt.Errorf("failed to update wallet balance: %w", err)
		}

		// 5. Insert transaction
		if err := dbTx.Create(tx).Error; err != nil {
			return fmt.Errorf("failed to create transaction: %w", err)
		}

		// 6. Preload relations for returning
		return dbTx.
			Preload("Wallet").
			Preload("Service").
			Preload("Category").
			First(tx, "id = ?", tx.ID).Error
	})
}

func (r *transactionRepository) GetByID(ctx context.Context, id uuid.UUID) (*models.Transaction, error) {
	var tx models.Transaction
	err := r.db.WithContext(ctx).
		Preload("Wallet").
		Preload("Service").
		Preload("Category").
		First(&tx, "id = ?", id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrTransactionNotFound
		}
		return nil, fmt.Errorf("failed to get transaction %s: %w", id, err)
	}
	return &tx, nil
}

func (r *transactionRepository) List(ctx context.Context, filter ListFilter) ([]models.Transaction, int64, error) {
	var transactions []models.Transaction
	var total int64

	query := r.db.WithContext(ctx).Model(&models.Transaction{})

	if filter.BusinessID != nil && *filter.BusinessID != uuid.Nil {
		query = query.Where("business_id = ?", *filter.BusinessID)
	}
	if filter.WalletID != nil && *filter.WalletID != uuid.Nil {
		query = query.Where("wallet_id = ?", *filter.WalletID)
	}
	if filter.ServiceID != nil && *filter.ServiceID != uuid.Nil {
		query = query.Where("service_id = ?", *filter.ServiceID)
	}
	if filter.CategoryID != nil && *filter.CategoryID != uuid.Nil {
		query = query.Where("category_id = ?", *filter.CategoryID)
	}
	if filter.Type != "" {
		query = query.Where("type = ?", filter.Type)
	}
	if filter.StartDate != nil {
		query = query.Where("transaction_date >= ?", *filter.StartDate)
	}
	if filter.EndDate != nil {
		query = query.Where("transaction_date <= ?", *filter.EndDate)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, fmt.Errorf("failed to count transactions: %w", err)
	}

	limit := filter.Limit
	if limit <= 0 || limit > 100 {
		limit = 50
	}

	err := query.
		Preload("Wallet").
		Preload("Service").
		Preload("Category").
		Order("transaction_date DESC, created_at DESC").
		Limit(limit).
		Offset(filter.Offset).
		Find(&transactions).Error
	if err != nil {
		return nil, 0, fmt.Errorf("failed to list transactions: %w", err)
	}

	return transactions, total, nil
}

func (r *transactionRepository) Update(ctx context.Context, tx *models.Transaction, oldWalletID uuid.UUID, oldType string, oldAmount float64) error {
	return r.db.WithContext(ctx).Transaction(func(dbTx *gorm.DB) error {
		// 1. Check service and category if updated
		var service models.Service
		if err := dbTx.First(&service, "id = ?", tx.ServiceID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return ErrServiceNotFound
			}
			return fmt.Errorf("failed to query service: %w", err)
		}

		if tx.CategoryID != nil && *tx.CategoryID != uuid.Nil {
			var category models.Category
			if err := dbTx.First(&category, "id = ?", *tx.CategoryID).Error; err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					return ErrCategoryNotFound
				}
				return fmt.Errorf("failed to query category: %w", err)
			}
		}

		// 2. Adjust wallet balances with row locking
		oldDelta := applyBalanceDelta(oldType, oldAmount)
		newDelta := applyBalanceDelta(tx.Type, tx.Amount)

		if tx.WalletID == oldWalletID {
			var wallet models.Wallet
			if err := dbTx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&wallet, "id = ?", tx.WalletID).Error; err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					return ErrWalletNotFound
				}
				return fmt.Errorf("failed to lock wallet: %w", err)
			}
			// Revert old effect and apply new effect
			wallet.Balance = wallet.Balance - oldDelta + newDelta
			if err := dbTx.Model(&wallet).Update("balance", wallet.Balance).Error; err != nil {
				return fmt.Errorf("failed to update wallet balance: %w", err)
			}
		} else {
			// Lock both wallets in deterministic order to prevent deadlocks
			firstID, secondID := oldWalletID, tx.WalletID
			if firstID.String() > secondID.String() {
				firstID, secondID = secondID, firstID
			}

			var w1, w2 models.Wallet
			if err := dbTx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&w1, "id = ?", firstID).Error; err != nil {
				return fmt.Errorf("failed to lock wallet %s: %w", firstID, err)
			}
			if err := dbTx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&w2, "id = ?", secondID).Error; err != nil {
				return fmt.Errorf("failed to lock wallet %s: %w", secondID, err)
			}

			// Map back to old and new
			var oldWallet, newWallet *models.Wallet
			if w1.ID == oldWalletID {
				oldWallet = &w1
				newWallet = &w2
			} else {
				oldWallet = &w2
				newWallet = &w1
			}

			oldWallet.Balance -= oldDelta
			newWallet.Balance += newDelta

			if err := dbTx.Model(oldWallet).Update("balance", oldWallet.Balance).Error; err != nil {
				return fmt.Errorf("failed to update old wallet balance: %w", err)
			}
			if err := dbTx.Model(newWallet).Update("balance", newWallet.Balance).Error; err != nil {
				return fmt.Errorf("failed to update new wallet balance: %w", err)
			}
		}

		// 3. Save transaction update
		if err := dbTx.Save(tx).Error; err != nil {
			return fmt.Errorf("failed to update transaction: %w", err)
		}

		// 4. Reload preloaded associations
		return dbTx.
			Preload("Wallet").
			Preload("Service").
			Preload("Category").
			First(tx, "id = ?", tx.ID).Error
	})
}

func (r *transactionRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Transaction(func(dbTx *gorm.DB) error {
		var tx models.Transaction
		if err := dbTx.First(&tx, "id = ?", id).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return ErrTransactionNotFound
			}
			return fmt.Errorf("failed to find transaction: %w", err)
		}

		// Lock wallet and revert balance
		var wallet models.Wallet
		if err := dbTx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&wallet, "id = ?", tx.WalletID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return ErrWalletNotFound
			}
			return fmt.Errorf("failed to lock wallet: %w", err)
		}

		delta := applyBalanceDelta(tx.Type, tx.Amount)
		wallet.Balance -= delta
		if err := dbTx.Model(&wallet).Update("balance", wallet.Balance).Error; err != nil {
			return fmt.Errorf("failed to revert wallet balance: %w", err)
		}

		// Soft delete transaction
		if err := dbTx.Delete(&tx).Error; err != nil {
			return fmt.Errorf("failed to delete transaction: %w", err)
		}

		return nil
	})
}
