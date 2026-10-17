package repository

import (
	"context"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"pun-account-backend/internal/wallets/models"
)

type AuthRepository interface {
	FindUserByGoogleID(ctx context.Context, googleID string) (*models.User, error)
	FindUserByEmail(ctx context.Context, email string) (*models.User, error)
	FindUserByID(ctx context.Context, id uuid.UUID) (*models.User, error)
	CreateUserWithBusiness(ctx context.Context, user *models.User, businessName, currency string) (*models.User, *models.Business, error)
	UpdateUser(ctx context.Context, user *models.User) error
	GetFirstBusinessByOwnerID(ctx context.Context, ownerID uuid.UUID) (*models.Business, error)
}

type authRepository struct {
	db *gorm.DB
}

func NewAuthRepository(db *gorm.DB) AuthRepository {
	return &authRepository{db: db}
}

func (r *authRepository) FindUserByGoogleID(ctx context.Context, googleID string) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).
		Preload("Businesses").
		Where("google_id = ?", googleID).
		First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find user by google_id: %w", err)
	}
	return &user, nil
}

func (r *authRepository) FindUserByEmail(ctx context.Context, email string) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).
		Preload("Businesses").
		Where("email = ?", email).
		First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find user by email: %w", err)
	}
	return &user, nil
}

func (r *authRepository) FindUserByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	var user models.User
	err := r.db.WithContext(ctx).
		Preload("Businesses").
		Where("id = ?", id).
		First(&user).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find user by id: %w", err)
	}
	return &user, nil
}

func (r *authRepository) CreateUserWithBusiness(
	ctx context.Context,
	user *models.User,
	businessName,
	currency string,
) (*models.User, *models.Business, error) {
	if businessName == "" {
		businessName = "My Business"
	}
	if currency == "" {
		currency = "THB"
	}

	var createdBusiness models.Business

	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 1. Generate UUIDv7 for User if not present
		if user.ID == uuid.Nil {
			userID, err := uuid.NewV7()
			if err != nil {
				return fmt.Errorf("failed to generate user UUIDv7: %w", err)
			}
			user.ID = userID
		}

		if err := tx.Create(user).Error; err != nil {
			return fmt.Errorf("failed to create user: %w", err)
		}

		// 2. Create default business with UUIDv7
		busID, err := uuid.NewV7()
		if err != nil {
			return fmt.Errorf("failed to generate business UUIDv7: %w", err)
		}

		createdBusiness = models.Business{
			ID:       busID,
			OwnerID:  user.ID,
			Name:     businessName,
			Currency: currency,
		}

		if err := tx.Create(&createdBusiness).Error; err != nil {
			return fmt.Errorf("failed to create default business: %w", err)
		}

		// 3. Create initial default wallet ("Cash") with UUIDv7
		walletID, err := uuid.NewV7()
		if err != nil {
			return fmt.Errorf("failed to generate wallet UUIDv7: %w", err)
		}

		defaultWallet := models.Wallet{
			ID:         walletID,
			BusinessID: createdBusiness.ID,
			Name:       "Cash Wallet",
			Type:       models.WalletTypeCash,
			Currency:   currency,
			Balance:    0.00,
			IsActive:   true,
			UI: models.WalletUI{
				AuroraAccent: "amber",
				CardBrand:    strPtr("cash"),
			},
		}

		if err := tx.Create(&defaultWallet).Error; err != nil {
			return fmt.Errorf("failed to create default wallet: %w", err)
		}

		return nil
	})

	if err != nil {
		return nil, nil, err
	}

	user.Businesses = []models.Business{createdBusiness}
	return user, &createdBusiness, nil
}

func (r *authRepository) UpdateUser(ctx context.Context, user *models.User) error {
	if err := r.db.WithContext(ctx).Save(user).Error; err != nil {
		return fmt.Errorf("failed to update user: %w", err)
	}
	return nil
}

func (r *authRepository) GetFirstBusinessByOwnerID(ctx context.Context, ownerID uuid.UUID) (*models.Business, error) {
	var bus models.Business
	err := r.db.WithContext(ctx).
		Where("owner_id = ?", ownerID).
		Order("created_at ASC").
		First(&bus).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, fmt.Errorf("failed to find business: %w", err)
	}
	return &bus, nil
}

func strPtr(s string) *string {
	return &s
}
