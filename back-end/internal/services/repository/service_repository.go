package repository

import (
	"context"

	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ServiceRepository defines database operations for services and categories.
type ServiceRepository interface {
	ListServiceCategories(ctx context.Context, businessID *uuid.UUID) ([]models.ServiceCategory, error)
	ListServices(ctx context.Context, businessID *uuid.UUID, categoryKey string) ([]models.Service, error)
	CreateService(ctx context.Context, service *models.Service) error
	GetService(ctx context.Context, id uuid.UUID) (*models.Service, error)
}

type serviceRepository struct {
	db *gorm.DB
}

// NewServiceRepository constructs a new ServiceRepository with GORM.
func NewServiceRepository(db *gorm.DB) ServiceRepository {
	return &serviceRepository{db: db}
}

func (r *serviceRepository) ListServiceCategories(ctx context.Context, businessID *uuid.UUID) ([]models.ServiceCategory, error) {
	var categories []models.ServiceCategory
	query := r.db.WithContext(ctx).Where("is_active = ?", true)

	if businessID != nil {
		query = query.Where("business_id = ? OR business_id IS NULL", *businessID)
	} else {
		query = query.Where("business_id IS NULL")
	}

	err := query.Order("created_at ASC").Find(&categories).Error
	return categories, err
}

func (r *serviceRepository) ListServices(ctx context.Context, businessID *uuid.UUID, categoryKey string) ([]models.Service, error) {
	var services []models.Service
	query := r.db.WithContext(ctx).
		Preload("ServiceCategory").
		Where("is_active = ?", true)

	if businessID != nil {
		query = query.Where("services.business_id = ? OR services.business_id IS NULL", *businessID)
	} else {
		query = query.Where("services.business_id IS NULL")
	}

	if categoryKey != "" && categoryKey != "all" {
		query = query.Joins("LEFT JOIN service_categories ON service_categories.id = services.service_category_id").
			Where("service_categories.key = ?", categoryKey)
	}

	err := query.Order("services.is_quick DESC, services.created_at ASC").Find(&services).Error
	return services, err
}

func (r *serviceRepository) CreateService(ctx context.Context, service *models.Service) error {
	return r.db.WithContext(ctx).Create(service).Error
}

func (r *serviceRepository) GetService(ctx context.Context, id uuid.UUID) (*models.Service, error) {
	var service models.Service
	err := r.db.WithContext(ctx).Preload("ServiceCategory").First(&service, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &service, nil
}
